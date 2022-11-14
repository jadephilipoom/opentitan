#include <stdint.h>
#include <string.h>

#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/status.h"
#include "sw/device/lib/crypto/drivers/entropy.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "test_params.h"

#include xstr(PARAMS/message_keys.inc)

static const char params[] = xstr(PARAMS);
static const char thash[] = xstr(THASH);

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

bool test_main() {
  unsigned char mout[SPX_SMLEN];
  uint64_t mlen;

  LOG_INFO("Starting SPHINCS+ verify test for parameter set %s-%s...", params, thash);

  // Initialize the CSRNG (using only TRNG, no sw seed material).
  entropy_seed_material_t empty_seed = {
    .len = 0,
    .data = {0},
  };
  entropy_testutils_auto_mode_init();
  status_t status = entropy_csrng_instantiate(kHardenedBoolFalse,
      &empty_seed);
  CHECK(status_ok(status));

  LOG_INFO("CSRNG initialized/instantiated successfully.");

  // Test if signature is valid.
  uint64_t t_start = profile_start();
  int result = crypto_sign_open(mout, &mlen, sm, SPX_SMLEN, pk);
  uint32_t cycles = profile_end(t_start);
  LOG_INFO("Verification took %u cycles.", cycles);
  CHECK(result == 0, "  X verification failed!");
  LOG_INFO("    verification succeeded.");

  // Test if the correct message was recovered.
  CHECK(mlen == SPX_MLEN, "  X mlen incorrect [%u != %u]!\n", mlen, SPX_MLEN);
  LOG_INFO("    mlen as expected [%u].", mlen);
  CHECK(memcmp(m, mout, SPX_MLEN) == 0, "  X output message incorrect!");
  LOG_INFO("    output message as expected.");

  return true;
}
