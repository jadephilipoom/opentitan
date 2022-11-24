// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/sphincsplus/drivers/kmac.h"

#include <assert.h>

#include "sw/device/lib/base/abs_mmio.h"
#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/macros.h"
#include "sw/device/lib/base/memory.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "kmac_regs.h"  // Generated.

#define RETURN_IF_ERROR(_expr)     \
  kmac_error_t _local_err = _expr; \
  if (_local_err != kKmacOk) {     \
    return _local_err;             \
  }

enum {
  /**
   * Base address of the KMAC hardware MMIO interface.
   */
  kBase = TOP_EARLGREY_KMAC_BASE_ADDR,
  /**
   * Keccak capacity for SHAKE256.
   *
   * See FIPS 202, section 6.2.
   */
  kShake256KeccakCapacity = 2 * 256,
  /**
   * Keccak rate for SHAKE256 (bits).
   *
   * Rate is 1600 - capacity (FIPS 202, section 6.2).
   */
  kShake256KeccakRateBits = 1600 - kShake256KeccakCapacity,
  /**
   * Keccak rate for SHAKE256 (bytes).
   */
  kShake256KeccakRateBytes = kShake256KeccakRateBits / 8,
  /**
   * Keccak rate for SHAKE256 (words).
   */
  kShake256KeccakRateWords = kShake256KeccakRateBytes / sizeof(uint32_t),
  /**
   * Address of first share of Keccak state.
   */
  kAddrStateShare0 = kBase + KMAC_STATE_REG_OFFSET,
  /**
   * Address of second share of Keccak state.
   */
  kAddrStateShare1 =
      kBase + KMAC_STATE_REG_OFFSET + (KMAC_STATE_SIZE_BYTES / 2),
};

// Double-check that calculated rate is smaller than one share of the state.
static_assert(kShake256KeccakRateWords <= (KMAC_STATE_SIZE_BYTES / 2),
              "assert SHAKE256 rate is <= share size");

static inline kmac_error_t check_err_bits() {
  uint32_t reg = abs_mmio_read32(kBase + KMAC_INTR_STATE_REG_OFFSET);
  if (bitfield_bit32_read(reg, KMAC_INTR_STATE_KMAC_ERR_BIT)) {
    // An error occurred.
    return kKmacErrorUnknown;
  }
  return kKmacOk;
}

static kmac_error_t poll_state(uint32_t flag) {
  while (true) {
    uint32_t reg = abs_mmio_read32(kBase + KMAC_STATUS_REG_OFFSET);
    if (bitfield_bit32_read(reg, flag)) {
      break;
    }
    RETURN_IF_ERROR(check_err_bits());
  }
  return kKmacOk;
}

static inline void issue_command(uint32_t cmd_value) {
  uint32_t cmd_reg = bitfield_field32_write(0, KMAC_CMD_CMD_FIELD, cmd_value);
  abs_mmio_write32(kBase + KMAC_CMD_REG_OFFSET, cmd_reg);
}

/**
 * Write `inlen` bytes from `in` to the message FIFO.
 *
 * The caller should check `STATUS.FIFO_DEPTH` first and set `len <=
 * STATUS.FIFO_DEPTH`, and should ensure that KMAC is in the "absorb" state
 * before calling.
 *
 * For best performance, use a word-aligned buffer for `in`.
 *
 * @param in Input buffer
 * @param len Length of input buffer in bytes.
 */
static inline void msg_fifo_write(const uint8_t *in, size_t len) {
  // Use byte-wide writes until the input pointer is aligned.
  ptrdiff_t offset = misalignment32_of((uintptr_t)in);
  size_t idx = 0;
  if (offset != 0) {
    size_t nbytes = alignof(uint32_t) - offset;
    for (; idx < nbytes && len > 0; idx++) {
      abs_mmio_write8(kBase + KMAC_MSG_FIFO_REG_OFFSET, in[idx]);
    }
  }

  // Use word writes for all full words.
  for (; idx + sizeof(uint32_t) <= len; idx += sizeof(uint32_t)) {
    abs_mmio_write32(kBase + KMAC_MSG_FIFO_REG_OFFSET,
                     read_32((uint32_t *)(&in[idx])));
  }

  // Use byte-wide writes for anything left over.
  for (; idx < len; idx++) {
    abs_mmio_write8(kBase + KMAC_MSG_FIFO_REG_OFFSET, in[idx]);
  }
}

/**
 * Read `len` words from the KMAC block's state registers.
 *
 * The caller should ensure that KMAC is in the "squeeze" state and that `len +
 * ctx->state_offset` is less than or equal to the SHAKE256 rate (i.e. that
 * there are enough bytes left in the state to read).
 *
 * @param out Output buffer
 * @param len Desired length of output (in words)
 * @param ctx KMAC squeeze context
 */
static void kmac_state_read(uint32_t *out, size_t len, size_t offset) {
  for (size_t i = 0; i < len; i++) {
    // Read both shares from state register and combine using XOR.
    uint32_t share0 = abs_mmio_read32(kAddrStateShare0 + (offset + i) * sizeof(uint32_t));
    uint32_t share1 = abs_mmio_read32(kAddrStateShare1 + (offset + i) * sizeof(uint32_t));
    out[i] = share0 ^ share1;
  }
}

/**
 * Configure the KMAC block at startup.
 *
 * Sets the KMAC block to use software entropy with an all-zero seed (since we
 * have no secret inputs for SPHINCS+) and sets the mode to SHAKE-256.
 *
 * @return Error code indicating if the operation succeeded.
 */
kmac_error_t kmac_shake256_configure(void) {
  RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_IDLE_BIT));

  uint32_t entropy_period_reg = KMAC_ENTROPY_PERIOD_REG_RESVAL;
  // Set the wait timer to the maximum count.
  entropy_period_reg = bitfield_field32_write(
      entropy_period_reg, KMAC_ENTROPY_PERIOD_WAIT_TIMER_FIELD,
      KMAC_ENTROPY_PERIOD_WAIT_TIMER_MASK);
  // Set the prescaler to the maximum number of cycles.
  entropy_period_reg = bitfield_field32_write(
      entropy_period_reg, KMAC_ENTROPY_PERIOD_PRESCALER_FIELD,
      KMAC_ENTROPY_PERIOD_PRESCALER_MASK);
  abs_mmio_write32(kBase + KMAC_ENTROPY_PERIOD_REG_OFFSET, entropy_period_reg);

  uint32_t cfg_reg = KMAC_CFG_SHADOWED_REG_RESVAL;
  // Set `CFG.KMAC_EN` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_KMAC_EN_BIT, 0);
  // Set `CFG.KSTRENGTH` field to 256-bit strength.
  cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_KSTRENGTH_FIELD,
                                   KMAC_CFG_SHADOWED_KSTRENGTH_VALUE_L256);
  // Set `CFG.MODE` field to SHAKE.
  cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_MODE_FIELD,
                                   KMAC_CFG_SHADOWED_MODE_VALUE_SHAKE);
  // Set `CFG.MSG_ENDIANNESS` bit to 0.
  cfg_reg =
      bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_MSG_ENDIANNESS_BIT, 0);
  // Set `CFG.STATE_ENDIANNESS` bit to 0.
  cfg_reg =
      bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_STATE_ENDIANNESS_BIT, 0);
  // Set `CFG.SIDELOAD` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_SIDELOAD_BIT, 0);
  // Set `CFG.ENTROPY_MODE` field to use software entropy.
  cfg_reg =
      bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_ENTROPY_MODE_FIELD,
                             KMAC_CFG_SHADOWED_ENTROPY_MODE_VALUE_SW_MODE);
  // Set `CFG.ENTROPY_FAST_PROCESS` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg,
                                 KMAC_CFG_SHADOWED_ENTROPY_FAST_PROCESS_BIT, 0);
  // Set `CFG.MSG_MASK` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_MSG_MASK_BIT, 0);
  // Set `CFG.ENTROPY_READY` bit to 1.
  cfg_reg =
      bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_ENTROPY_READY_BIT, 1);
  // Set `CFG.ERR_PROCESSED` bit to 0.
  cfg_reg =
      bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_ERR_PROCESSED_BIT, 0);
  // Set `CFG.EN_UNSUPPORTED_MODESTRENGTH` bit to 0.
  cfg_reg = bitfield_bit32_write(
      cfg_reg, KMAC_CFG_SHADOWED_EN_UNSUPPORTED_MODESTRENGTH_BIT, 0);
  abs_mmio_write32_shadowed(kBase + KMAC_CFG_SHADOWED_REG_OFFSET, cfg_reg);

  // Write entropy seed registers (all-zero).
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_0_REG_OFFSET, 0);
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_1_REG_OFFSET, 0);
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_2_REG_OFFSET, 0);
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_3_REG_OFFSET, 0);
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_4_REG_OFFSET, 0);

  return kKmacOk;
}

kmac_error_t kmac_shake256_start(void) {
  // Block until KMAC hardware is idle.
  RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_IDLE_BIT));

  // Issue `CMD.START` to start the operation.
  issue_command(KMAC_CMD_CMD_VALUE_START);

  return kKmacOk;
}

kmac_error_t kmac_shake256_absorb(const uint8_t *in, size_t inlen) {
  // This implementation uses the recommended approach from the KMAC
  // documentation:
  //   https://docs.opentitan.org/hw/ip/kmac/doc/#fifo-depth-and-empty-status
  //
  // 1. Check the FIFO depth with `STATUS.fifo_depth`.
  // 2. Write the remaining size (`KMAC_MSG_FIFO_SIZE_BYTES` - depth).
  // 3. Then repeat.
  //
  // The documentation also specifies that writes to the message FIFO do not
  // need to be aligned.

  // Block until KMAC hardware is in the `absorb` state.
  RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_ABSORB_BIT));

  size_t idx = 0;
  while (idx < inlen) {
    uint32_t status = abs_mmio_read32(kBase + KMAC_STATUS_REG_OFFSET);
    uint32_t fifo_depth =
        bitfield_field32_read(status, KMAC_STATUS_FIFO_DEPTH_FIELD);
    size_t max_len = KMAC_MSG_FIFO_SIZE_BYTES - fifo_depth;
    size_t write_len = ((inlen - idx) < max_len) ? (inlen - idx) : max_len;
    msg_fifo_write(&in[idx], write_len);
    idx += write_len;
  }

  return kKmacOk;
}

kmac_error_t kmac_shake256_squeeze_start(kmac_squeeze_context_t *ctx) {
  // Poll until we are in the `absorb` state.
  RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_ABSORB_BIT));

  // Issue `CMD.PROCESS` to move to the squeezing state.
  issue_command(KMAC_CMD_CMD_VALUE_PROCESS);

  // Initialize the offset to 0.
  ctx->state_offset = 0;

  return kKmacOk;
}

kmac_error_t kmac_shake256_squeeze(uint32_t *out, size_t outlen,
                                   kmac_squeeze_context_t *ctx) {
  size_t idx = 0;
  while (idx < outlen) {
    // Poll the status register until in the 'squeeze' state.
    RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_SQUEEZE_BIT));

    // Read words from the state registers (either `outlen` or the maximum
    // number of words available).
    size_t max_len = kShake256KeccakRateWords - ctx->state_offset;
    size_t read_len = (max_len < (outlen - idx)) ? max_len : (outlen - idx);
    kmac_state_read(&out[idx], read_len, ctx->state_offset);
    idx += read_len;
    ctx->state_offset += read_len;

    // If we read all the remaining words, issue `CMD.RUN` to generate more
    // state.
    if (read_len == max_len) {
      issue_command(KMAC_CMD_CMD_VALUE_RUN);
      ctx->state_offset = 0;
    }
  }
  return kKmacOk;
}

kmac_error_t kmac_shake256_end(void) {
  // Poll the status register until in the 'squeeze' state.
  RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_SQUEEZE_BIT));

  // Issue `CMD.RUN` to finish the operation.
  issue_command(KMAC_CMD_CMD_VALUE_DONE);
  return kKmacOk;
}
