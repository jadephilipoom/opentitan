// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/macros.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_kmac.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

OTTF_DEFINE_TEST_CONFIG();

/**
 * Start a cycle-count timing profile.
 */
static uint64_t profile_start() { return ibex_mcycle_read(); }

/**
 * End a cycle-count timing profile.
 *
 * Call `profile_start()` first.
 */
static uint32_t profile_end(uint64_t t_start) {
  uint64_t t_end = ibex_mcycle_read();
  uint64_t cycles = t_end - t_start;
  CHECK(cycles <= UINT32_MAX);
  return (uint32_t)cycles;
}


bool test_main(void) {
  LOG_INFO("Running KMAC DIF cSHAKE test...");

  // Intialize KMAC hardware.
  dif_kmac_t kmac;
  dif_kmac_operation_state_t kmac_operation_state;
  CHECK_DIF_OK(
      dif_kmac_init(mmio_region_from_addr(TOP_EARLGREY_KMAC_BASE_ADDR), &kmac));

  // Configure KMAC hardware using software entropy.
  dif_kmac_config_t config = (dif_kmac_config_t){
      .entropy_mode = kDifKmacEntropyModeSoftware,
      .entropy_seed = {0xaa25b4bf, 0x48ce8fff, 0x5a78282a, 0x48465647,
                       0x70410fef},
      .entropy_fast_process = kDifToggleEnabled,
  };
  CHECK_DIF_OK(dif_kmac_configure(&kmac, config));

  LOG_INFO("Starting 8kiB test...");
  uint64_t t_start = profile_start();

  /* 8kiB test */
  CHECK_DIF_OK(dif_kmac_mode_shake_start(&kmac, &kmac_operation_state,
        kDifKmacModeShakeLen256));

  uint32_t input[128] = {0};
  for (size_t i = 0; i < 64; i++) {
    CHECK_DIF_OK(dif_kmac_absorb(&kmac, &kmac_operation_state, input,
          128, NULL));
  }

  uint32_t out[8];
  CHECK_DIF_OK(dif_kmac_squeeze(&kmac, &kmac_operation_state, out,
        8, NULL));
  CHECK_DIF_OK(dif_kmac_end(&kmac, &kmac_operation_state));

  uint32_t cycles = profile_end(t_start);
  LOG_INFO("Test took %u cycles.", cycles);

  /* 64 * 128B test */

  LOG_INFO("Starting 64*128B test...");
  t_start = profile_start();

  for (size_t i = 0; i < 64; i++) {
    CHECK_DIF_OK(dif_kmac_mode_shake_start(&kmac, &kmac_operation_state,
          kDifKmacModeShakeLen256));
    CHECK_DIF_OK(dif_kmac_absorb(&kmac, &kmac_operation_state, input,
          128, NULL));
    CHECK_DIF_OK(dif_kmac_squeeze(&kmac, &kmac_operation_state, out,
          8, NULL));
    CHECK_DIF_OK(dif_kmac_end(&kmac, &kmac_operation_state));
  }

  cycles = profile_end(t_start);
  LOG_INFO("Test took %u cycles.", cycles);

  return true;
}
