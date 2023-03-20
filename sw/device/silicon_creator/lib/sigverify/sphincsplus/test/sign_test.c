// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/sign.h"

#include <stdint.h>

#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/status.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/verify.h"
#include "sw/device/silicon_creator/lib/test_main.h"

// The autogen rule that creates this header creates it in a directory named
// after the rule, then manipulates the include path in the
// cc_compilation_context to include that directory, so the compiler will find
// the version of this file matching the Bazel rule under test.
#include "sphincsplus_shake_128s_simple_testvectors.h"

// Index of the test vector currently under test
static uint32_t test_index = 0;

OTTF_DEFINE_TEST_CONFIG();

enum {
  /**
   * Number of negative tests to run (manipulating the message and checking
   * that the signature fails).
   */
  kNumNegativeTests = 1,
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
  CHECK(cycles <= UINT32_MAX);
  return (uint32_t)cycles;
}

/**
 * Run the SPHINCS+ signing procedure on the given test vector.
 *
 * @param test Test vector to run.
 * @param[out] sig Output signature.
 */
static rom_error_t run_sign(const spx_test_vector_t *test, uint32_t *sig) {
  // Run signing and print the cycle count.
  uint64_t t_start = profile_start();
  rom_error_t err = spx_sign(sig, test->msg, test->msg_len, test->sk);
  uint32_t cycles = profile_end(t_start);
  LOG_INFO("Signing took %u cycles.", cycles);

  return err;
}

/**
 * Run the current test.
 */
static rom_error_t spx_sign_test(void) {
  spx_test_vector_t test = spx_tests[test_index];

  uint32_t sig[kSpxVerifySigBytes / sizeof(uint32_t)];
  RETURN_IF_ERROR(run_sign(&test, sig));

  // Ensure that the signatures match.
  CHECK_ARRAYS_EQ(test.sig, (unsigned char *)sig, kSpxVerifySigBytes);
  return kErrorOk;
}

bool test_main() {
  rom_error_t result = kErrorOk;

  for (size_t i = 0; i < kSpxNumTests; i++) {
    EXECUTE_TEST(result, spx_sign_test);
    test_index++;
    LOG_INFO("Finished test %d of %d.", test_index, kSpxNumTests);
  }

  return result == kErrorOk;
}
