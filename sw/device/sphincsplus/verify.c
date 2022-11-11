#include <stdint.h>
#include <string.h>

#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/status.h"
#include "sw/device/lib/crypto/drivers/entropy.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "test_params.h"

#include "message_keys.inc"

OTTF_DEFINE_TEST_CONFIG();

bool test_main() {
  unsigned char mout[SPX_SMLEN];
  unsigned long long mlen;

  LOG_INFO("Starting SPHICS+ verify test...");

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
  CHECK(crypto_sign_open(mout, &mlen, sm, SPX_SMLEN, pk) == 0, "  X verification failed!");
  LOG_INFO("    verification succeeded.");

  // Test if the correct message was recovered.
  CHECK(mlen == SPX_MLEN, "  X mlen incorrect [%llu != %u]!\n", mlen, SPX_MLEN);
  LOG_INFO("    mlen as expected [%llu].", mlen);
  CHECK(memcmp(m, mout, SPX_MLEN) == 0, "  X output message incorrect!");
  LOG_INFO("    output message as expected.");

  return true;
}
