// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/crypto/drivers/otbn.h"
#include "sw/device/lib/crypto/rsa_3072/rsa_3072_verify.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

// TODO(jadep): Understand why you can use this as a bare include.  Delete or
// rearrange this comment when you understand :)
//
// Since the autogen rule places the generated file `rsa_3072_verify_testvectors.h` in
// its own subdirectory (subdir named after the rule name) and manipulates the include
// path in the cc_compilation_context to include that directory, the compiler will find
// this file.
//
// There is an assumtion: that you do not need to generate multiple `*_testvectors.h`
// for a single test.  That seemed like an obvious assumption to me based on the
// structure of the rules: each test uses the same `.c` file to define the test
// itself, but includes separate instances of the `.h` files to define exactly what
// the test will be doing.
#include "rsa_3072_verify_testvectors.h"

bool rsa_3072_verify_test(const rsa_3072_verify_test_vector_t *testvec) {
  // Encode message
  rsa_3072_int_t encodedMessage;
  hmac_error_t encode_err =
      rsa_3072_encode_sha256(testvec->msg, testvec->msgLen, &encodedMessage);
  if (encode_err != kHmacOk) {
    LOG_ERROR("Error from HMAC during message encoding: 0x%08x.", encode_err);
    return false;
  }

  // Precompute Montgomery constants
  rsa_3072_constants_t constants;
  otbn_error_t err =
      rsa_3072_compute_constants(&testvec->publicKey, &constants);
  if (err != kOtbnErrorOk) {
    LOG_ERROR("Error from OTBN while computing constants: 0x%08x.", err);
    return false;
  }

  // Attempt to verify signature
  hardened_bool_t result;
  err = rsa_3072_verify(&testvec->signature, &encodedMessage,
                        &testvec->publicKey, &constants, &result);

  if (testvec->valid) {
    CHECK(err == kOtbnErrorOk);
    CHECK(result == kHardenedBoolTrue);
  } else {
    CHECK(err == kOtbnErrorOk || err == kOtbnErrorInvalidArgument);
    CHECK(result == kHardenedBoolFalse);
  }

  return true;
}

OTTF_DEFINE_TEST_CONFIG();

bool test_main(void) {
  // Stays true only if all tests pass.
  bool result = true;

  // TODO(jadep): more hints:
  // The definition of `RULE_NAME` also comes from the autogen rule.  Similarly
  // to manipulating the include path, we also manipulate the defines which
  // are then available to dependent rules.  You don't really _need_ (nor the
  // `defines=<stuff>` in the rule definition), but I thought it might be
  // helpful to make it obvious in the test output exactly what was executing.
  LOG_INFO("Starting rsa_3072_verify_test:%s", RULE_NAME);
  for (uint32_t i = 0; i < RSA_3072_VERIFY_NUM_TESTS; i++) {
    LOG_INFO("Starting rsa_3072_verify_test on test vector %d of %d...", i + 1,
             RSA_3072_VERIFY_NUM_TESTS);

    // Extract test vector and check for unsupported exponents (e.g. 3); these
    // signatures are expected to fail verification, so mark them invalid.
    rsa_3072_verify_test_vector_t testvec = rsa_3072_verify_tests[i];
    if (testvec.publicKey.e != 65537) {
      testvec.valid = false;
    }

    // Run test and print out result.
    bool local_result = rsa_3072_verify_test(&testvec);
    if (local_result) {
      LOG_INFO("Finished rsa_3072_verify_test on test vector %d : ok", i + 1);
    } else {
      LOG_ERROR("Finished rsa_3072_verify_test on test vector %d : error",
                i + 1);
      LOG_INFO("Test notes: %s", testvec.comment);
    }
    result &= local_result;
  }
  LOG_INFO("Finished rsa_3072_verify_test:%s", RULE_NAME);

  return result;
}
