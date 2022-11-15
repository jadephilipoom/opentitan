#include <stdint.h>
#include <string.h>

#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "../context.h"
#include "../thash.h"

OTTF_DEFINE_TEST_CONFIG();

static const spx_ctx test_ctx  = {
  .pub_seed = {0},
  .sk_seed = {0},
};
static const size_t chain_len = 10;
static const uint8_t exp_result[SPX_N] = {
  0x6e, 0x06, 0x99, 0x66, 0x1a, 0x2c, 0xe0, 0x34, 0x16, 0x73, 0x0a,
  0x9a, 0xdc, 0x5c, 0x4b, 0x86
};

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
  for (size_t i = 0; i < 10; i++) {
    thash(out, out, 1, &test_ctx, addr);
  }
  uint32_t cycles = profile_end(t_start);
  LOG_INFO("Performed %d thash ops in %u cycles", chain_len, cycles);
  LOG_INFO("Output misalignment: %u", misalignment32_of((uintptr_t) out));
}

bool test_main() {
  uint8_t out[SPX_N + 1] = {0};
  uint32_t addr[8] = {0};

  chain_test(out, addr);
  for (size_t i = 0; i < SPX_N; i++) {
    CHECK(out[i] == exp_result[i]);
  }

  // Second test is just for timing/alignment comparison.
  chain_test(out + 1, addr);

  return true;
}
