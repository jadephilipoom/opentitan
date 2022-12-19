// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/lib/drivers/kmac.h"

#include "sw/device/lib/base/abs_mmio.h"
#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/error.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "kmac_regs.h"  // Generated.

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

static rom_error_t poll_state(uint32_t flag) {
  uint32_t status = launder32(UINT32_MAX);
  rom_error_t res = launder32(kErrorOk ^ status);
  hardened_bool_t is_error = kHardenedBoolFalse;
  do {
    // Check for any errors.
    uint32_t intr_state = abs_mmio_read32(kBase + KMAC_INTR_STATE_REG_OFFSET);
    is_error ^= -bitfield_bit32_read(intr_state, KMAC_INTR_STATE_KMAC_ERR_BIT);
    // Read status.
    status = abs_mmio_read32(kBase + KMAC_STATUS_REG_OFFSET);
  } while (!bitfield_bit32_read(launder32(status), flag) &&
           launder32(is_error) == kHardenedBoolFalse);

  res ^= -bitfield_bit32_read(status, flag);

  if (launder32(is_error) == kHardenedBoolFalse) {
    HARDENED_CHECK_EQ(is_error, kHardenedBoolFalse);
    return res;
  }

  return kErrorKmacInternalError;
}

static inline void issue_command(uint32_t cmd_value) {
  uint32_t cmd_reg = bitfield_field32_write(0, KMAC_CMD_CMD_FIELD, cmd_value);
  abs_mmio_write32(kBase + KMAC_CMD_REG_OFFSET, cmd_reg);
}

/**
 * Configure the KMAC block at startup.
 *
 * Sets the KMAC block to use software entropy with an all-zero seed (since we
 * have no secret inputs for SPHINCS+) and sets the mode to SHAKE-256.
 *
 * @return Error code indicating if the operation succeeded.
 */
rom_error_t kmac_shake256_configure(void) {
  HARDENED_RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_IDLE_BIT));

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
  // NOTE: If this driver is ever modified to perform an operation with
  // KMAC_EN=true and use entropy from EDN, then the absorb() function must
  // poll `STATUS.fifo_depth` to avoid a specific EDN-KMAC-Ibex deadlock
  // scenario. See `absorb()` and the KMAC documentation for details.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_KMAC_EN_BIT, 0);
  // Set `CFG.KSTRENGTH` field to 256-bit strength.
  cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_KSTRENGTH_FIELD,
                                   KMAC_CFG_SHADOWED_KSTRENGTH_VALUE_L256);
  // Set `CFG.MODE` field to SHAKE.
  cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_MODE_FIELD,
                                   KMAC_CFG_SHADOWED_MODE_VALUE_SHAKE);
  // Set `CFG.MSG_ENDIANNESS` bit to 0 (little-endian).
  cfg_reg =
      bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_MSG_ENDIANNESS_BIT, 0);
  // Set `CFG.STATE_ENDIANNESS` bit to 0 (little-endian).
  cfg_reg =
      bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_STATE_ENDIANNESS_BIT, 0);
  // Set `CFG.SIDELOAD` bit to 0 (no sideloading).
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_SIDELOAD_BIT, 0);
  // Set `CFG.ENTROPY_MODE` field to use software entropy. SHAKE does not
  // require any entropy, so there is no reason we should wait for entropy
  // availability before we start hashing.
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

  // Read back and double-check the security strength and mode.
  cfg_reg = abs_mmio_read32(kBase + KMAC_CFG_SHADOWED_REG_OFFSET);
  HARDENED_CHECK_EQ(
      bitfield_field32_read(cfg_reg, KMAC_CFG_SHADOWED_KSTRENGTH_FIELD),
      KMAC_CFG_SHADOWED_KSTRENGTH_VALUE_L256);
  HARDENED_CHECK_EQ(
      bitfield_field32_read(cfg_reg, KMAC_CFG_SHADOWED_MODE_FIELD),
      KMAC_CFG_SHADOWED_MODE_VALUE_SHAKE);

  return kErrorOk;
}

rom_error_t kmac_shake256_start(void) {
  // Block until KMAC hardware is idle.
  HARDENED_RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_IDLE_BIT));

  // Issue `CMD.START` to start the operation.
  issue_command(KMAC_CMD_CMD_VALUE_START);

  // Block until KMAC hardware is in the `absorb` state. After `CMD.START`,
  // KMAC should never move out of the `absorb` state until `CMD.PROCESS` is
  // issued, so we get significant performance gains by polling only once here
  // instead of before every `absorb`.
  HARDENED_RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_ABSORB_BIT));

  return kErrorOk;
}

void kmac_shake256_absorb(const uint8_t *in, size_t inlen) {
  // This implementation does not poll `STATUS.fifo_depth` as recommended in
  // the KMAC documentation. Normally, polling is required to prevent a
  // deadlock scenario between Ibex, KMAC, and EDN. However, in this case it is
  // safe to skip because `kmac_shake256_configure()` sets KMAC to use
  // software-only entropy, and sets `kmac_en` to false (so KMAC will not
  // produce entropy requests anyway). Since KMAC will therefore not block on
  // EDN, it is guaranteed to keep processing message blocks. For more details,
  // see the KMAC documentation:
  //   https://docs.opentitan.org/hw/ip/kmac/doc/#fifo-depth-and-empty-status

  // Use byte-wide writes until the input pointer is aligned.
  // Note: writes to the KMAC message FIFO are not required to be aligned.
  ptrdiff_t offset = misalignment32_of((uintptr_t)in);
  size_t idx = 0;
  if (offset != 0) {
    size_t nbytes = alignof(uint32_t) - offset;
    for (; idx < nbytes && idx < inlen; idx++) {
      abs_mmio_write8(kBase + KMAC_MSG_FIFO_REG_OFFSET, in[idx]);
    }
  }

  // Use word writes for all full words.
  for (; idx + sizeof(uint32_t) <= inlen; idx += sizeof(uint32_t)) {
    abs_mmio_write32(kBase + KMAC_MSG_FIFO_REG_OFFSET, read_32(&in[idx]));
  }

  // Use byte-wide writes for anything left over.
  for (; idx < inlen; idx++) {
    abs_mmio_write8(kBase + KMAC_MSG_FIFO_REG_OFFSET, in[idx]);
  }
  HARDENED_CHECK_EQ(idx, inlen);
}

void kmac_shake256_absorb_words(const uint32_t *in, size_t inlen) {
  // This implementation does not poll `STATUS.fifo_depth` as recommended in
  // the KMAC documentation. Normally, polling is required to prevent a
  // deadlock scenario between Ibex, KMAC, and EDN. However, in this case it is
  // safe to skip because `kmac_shake256_configure()` sets KMAC to use
  // software-only entropy, and sets `kmac_en` to false (so KMAC will not
  // produce entropy requests anyway). Since KMAC will therefore not block on
  // EDN, it is guaranteed to keep processing message blocks. For more details,
  // see the KMAC documentation:
  //   https://docs.opentitan.org/hw/ip/kmac/doc/#fifo-depth-and-empty-status

  size_t idx = 0;
  for (idx = 0; idx < inlen; idx++) {
    abs_mmio_write32(kBase + KMAC_MSG_FIFO_REG_OFFSET, in[idx]);
  }
  HARDENED_CHECK_EQ(idx, inlen);
}

void kmac_shake256_squeeze_start(void) {
  // Issue `CMD.PROCESS` to move to the squeezing state.
  issue_command(KMAC_CMD_CMD_VALUE_PROCESS);
}

rom_error_t kmac_shake256_squeeze_end(uint32_t *out, size_t outlen) {
  size_t idx = 0;
  while (launder32(idx) < outlen) {
    // Since we always read in increments of the SHAKE-256 rate, the index at
    // start should always be a multiple of the rate.
    HARDENED_CHECK_EQ(idx % kShake256KeccakRateWords, 0);

    // Poll the status register until in the 'squeeze' state.
    HARDENED_RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_SQUEEZE_BIT));

    // Read words from the state registers (either `outlen` or the maximum
    // number of words available).
    size_t offset = 0;
    for (; launder32(idx) < outlen && offset < kShake256KeccakRateWords;
         ++offset) {
      uint32_t share0 =
          abs_mmio_read32(kAddrStateShare0 + offset * sizeof(uint32_t));
      uint32_t share1 =
          abs_mmio_read32(kAddrStateShare1 + offset * sizeof(uint32_t));
      out[idx] = share0 ^ share1;
      ++idx;
    }

    if (offset == kShake256KeccakRateWords) {
      // If we read all the remaining words, issue `CMD.RUN` to generate more
      // state.
      HARDENED_CHECK_EQ(offset, kShake256KeccakRateWords);
      issue_command(KMAC_CMD_CMD_VALUE_RUN);
    }
  }
  HARDENED_CHECK_EQ(idx, outlen);

  // Poll the status register until in the 'squeeze' state.
  HARDENED_RETURN_IF_ERROR(poll_state(KMAC_STATUS_SHA3_SQUEEZE_BIT));

  // Issue `CMD.DONE` to finish the operation.
  issue_command(KMAC_CMD_CMD_VALUE_DONE);

  return kErrorOk;
}
