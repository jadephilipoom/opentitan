#include "../thash.h"

#include <stdint.h>
#include <string.h>

#include "../context.h"
#include "../fips202.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/crypto/drivers/entropy.h"
#include "sw/device/lib/dif/dif_kmac.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

OTTF_DEFINE_TEST_CONFIG();

static const spx_ctx test_ctx __attribute__((aligned(sizeof(uint32_t)))) = {
    .pub_seed = {0},
    .sk_seed = {0},
};

// Values for chain length 3 (thash simple)
static const size_t chain_len = 3;
static const uint8_t exp_result[SPX_N] = {0x7d, 0x61, 0x27, 0x2f, 0xd8, 0x14,
                                          0x33, 0x7a, 0x62, 0xcd, 0x80, 0x7b,
                                          0x2a, 0x96, 0x4d, 0x10};

// Values for chain length 10 (thash simple)
/*
static const size_t chain_len = 10;
static const uint8_t exp_result[SPX_N] = {
  0x6e, 0x06, 0x99, 0x66, 0x1a, 0x2c, 0xe0, 0x34, 0x16, 0x73, 0x0a,
  0x9a, 0xdc, 0x5c, 0x4b, 0x86
};
*/

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
  return (uint32_t)cycles;
}

static void chain_test(uint8_t *out, uint32_t addr[8]) {
  uint64_t t_start = profile_start();
  for (size_t i = 0; i < chain_len; i++) {
    thash(out, out, 1, &test_ctx, addr);
  }
  uint32_t cycles = profile_end(t_start);
  LOG_INFO("Performed %d thash ops in %u cycles", chain_len, cycles);
  LOG_INFO("Output misalignment: %u", misalignment32_of((uintptr_t)out));
}

static void test_setup(void) {
  // Initialize the CSRNG (using only TRNG, no sw seed material).
  entropy_seed_material_t empty_seed = {
      .len = 0,
      .data = {0},
  };
  entropy_testutils_auto_mode_init();
  status_t status = entropy_csrng_instantiate(kHardenedBoolFalse, &empty_seed);
  CHECK(status_ok(status));

  // Intialize KMAC hardware.
  dif_kmac_t kmac;
  CHECK(dif_kmac_init(mmio_region_from_addr(TOP_EARLGREY_KMAC_BASE_ADDR),
                      &kmac) == kDifOk);

  // Configure KMAC hardware using software entropy.
  dif_kmac_config_t config = (dif_kmac_config_t){
      .entropy_mode = kDifKmacEntropyModeSoftware,
      .entropy_seed = {0},
      .entropy_fast_process = kDifToggleEnabled,
  };
  CHECK(dif_kmac_configure(&kmac, config) == kDifOk);

  // Set the configuration to SHAKE-256.
  shake256_setup();
}

bool test_main() {
  uint8_t out[SPX_N + 1] __attribute__((aligned(sizeof(uint32_t)))) = {0};
  uint32_t addr[8] = {0};

  test_setup();
  LOG_INFO("Setup complete.");

  chain_test(out, addr);
  for (size_t i = 0; i < SPX_N; i++) {
    CHECK(out[i] == exp_result[i]);
  }

  // Second test is just for timing/alignment comparison.
  chain_test(out + 1, addr);

  return true;
}
