// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/hardened.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/check.h"
#include "sw/device/lib/testing/test_framework/ottf.h"
#include "sw/device/lib/crypto/rsa_3072/rsa_3072_verify.h"
#include "sw/device/lib/crypto/api.h"
#include "sw/device/tests/crypto/rsa_3072_verify_testvectors.h"

/**
 * Run one of the RSA-3072 signature verification test vectors.
 *
 * @param testvec Test vector to check.
 * @param result Result of the signature verification (pass or fail).
 * @return Crypto library status (OK or error).
 */
crypto_status_t rsa_3072_verify_test(const rsa_3072_verify_test_vector_t *testvec, verification_status_t *result) {
  // Set up public key modulus.
  uint32_t n_data[kRsa3072NumWords];
  memcpy(n_data, testvec->publicKey.n.data, kRsa3072NumBytes);
  crypto_unblinded_key_t n = {
    .key_mode = kKeyModeRsaSign,
    .key_length = kRsa3072NumWords,
    .key = n_data,
    .checksum = 0, // TODO: Put a real checksum; currently not checked.
  };

  // Set up public key exponent.
  uint32_t exponent = testvec->publicKey.e;
  crypto_unblinded_key_t e = {
    .key_mode = kKeyModeRsaSign,
    .key_length = 1,
    .key = &exponent,
    .checksum = 0, // TODO: Put a real checksum; currently not checked.
  };

  // Set up the input message.
  uint8_t msg[testvec->msgLen];
  memcpy(msg, testvec->msg, testvec->msgLen);
  crypto_uint8_buf_t input_message = {
    .data = msg,
    .len = testvec->msgLen,
  };

  // Set up signature.
  uint8_t sig[kRsa3072NumBytes];
  memcpy(sig, testvec->signature.data, kRsa3072NumBytes);
  crypto_uint8_buf_t signature = {
    .data = sig,
    .len = kRsa3072NumBytes
  };

  // Attempt to verify the signature.
  return rsa_verify(&n, &e, input_message, kRsaPaddingPkcs, kRsaHashSha256, signature, result);
}

const test_config_t kTestConfig;

bool test_main(void) {
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
    verification_status_t result;
    crypto_status_t status = rsa_3072_verify_test(&testvec, &result);
    if (testvec.valid) {
      CHECK(status == kCryptoStatusOK, "Error while checking a valid signature: 0x%08x. Test notes: %s", status, testvec.comment);
      CHECK(result == kVerificationStatusPass, "Valid signature failed verification. Test notes: %s", testvec.comment);
    } else {
      CHECK(result == kVerificationStatusFail, "Invalid signature passed verification. Test notes: %s", testvec.comment);
    }

    LOG_INFO("Passed rsa_3072_verify_test on test vector %d of %d.", i + 1,
             RSA_3072_VERIFY_NUM_TESTS);
  }

  return true;
}
