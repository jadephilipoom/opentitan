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

#define RETURN_IF_ERROR(_expr)      \
  kmac_error_t _local_err = _expr;  \
  if (_local_err != kKmacErrorOk) { \
    return _local_err;              \
  }

enum {
  kBase = TOP_EARLGREY_KMAC_BASE_ADDR,
};

static kmac_error_t poll_state(uint32_t flag) {
  while (true) {
    uint32_t reg = abs_mmio_read32(kBase + KMAC_STATUS_REG_OFFSET);
    if (bitfield_bit32_read(reg, flag)) {
      break;
    }
    if (bitfield_bit32_read(reg, KMAC_INTR_STATE_KMAC_ERR_BIT)) {
      // An error occurred.
      return kKmacErrorUnknown;
    }
  }
  return kKmacErrorOk;
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
  cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_KSTRENGTH_FIELD, KMAC_CFG_SHADOWED_KSTRENGTH_VALUE_L256);
  // Set `CFG.MODE` field to SHAKE.
  cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_MODE_FIELD, KMAC_CFG_SHADOWED_MODE_VALUE_SHAKE);
  // Set `CFG.MSG_ENDIANNESS` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_MSG_ENDIANNESS_BIT, 0);
  // Set `CFG.STATE_ENDIANNESS` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_STATE_ENDIANNESS_BIT, 0);
  // Set `CFG.SIDELOAD` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_SIDELOAD_BIT, 0);
  // Set `CFG.ENTROPY_MODE` field to use software entropy.
  cfg_reg = bitfield_field32_write(cfg_reg, KMAC_CFG_SHADOWED_ENTROPY_MODE_FIELD, KMAC_CFG_SHADOWED_ENTROPY_MODE_VALUE_SW_MODE);
  // Set `CFG.ENTROPY_FAST_PROCESS` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_ENTROPY_FAST_PROCESS_BIT, 0);
  // Set `CFG.MSG_MASK` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_MSG_MASK_BIT, 0);
  // Set `CFG.ENTROPY_READY` bit to 1.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_ENTROPY_READY_BIT, 1);
  // Set `CFG.ERR_PROCESSED` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_ERR_PROCESSED_BIT, 0);
  // Set `CFG.EN_UNSUPPORTED_MODESTRENGTH` bit to 0.
  cfg_reg = bitfield_bit32_write(cfg_reg, KMAC_CFG_SHADOWED_EN_UNSUPPORTED_MODESTRENGTH_BIT, 0);
  abs_mmio_write32_shadowed(kBase + KMAC_CFG_SHADOWED_REG_OFFSET, cfg_reg);


  // Write entropy seed registers (all-zero).
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_0_REG_OFFSET, 0);
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_1_REG_OFFSET, 0);
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_2_REG_OFFSET, 0);
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_3_REG_OFFSET, 0);
  abs_mmio_write32(kBase + KMAC_ENTROPY_SEED_4_REG_OFFSET, 0);

  return kKmacErrorOk;
}
