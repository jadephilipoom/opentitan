// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/crypto/include/datatypes.h"
#include "sw/device/lib/crypto/include/hash.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/profile.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/tests/crypto/testvectors/random_data.h"

/**
 * Two-block test data.
 *
 * Test from:
 * https://csrc.nist.gov/CSRC/media/Projects/Cryptographic-Standards-and-Guidelines/documents/examples/SHA256.pdf
 *
 * SHA256('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq')
 *  = 0x248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1
 */
static const unsigned char kTwoBlockMessage[] =
    "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
static const size_t kTwoBlockMessageLen = sizeof(kTwoBlockMessage) - 1;
static const uint8_t kTwoBlockExpDigest[] = {
    0x24, 0x8d, 0x6a, 0x61, 0xd2, 0x06, 0x38, 0xb8, 0xe5, 0xc0, 0x26,
    0x93, 0x0c, 0x3e, 0x60, 0x39, 0xa3, 0x3c, 0xe4, 0x59, 0x64, 0xff,
    0x21, 0x67, 0xf6, 0xec, 0xed, 0xd4, 0x19, 0xdb, 0x06, 0xc1};

/**
 * Test that is exactly one block in length.
 *
 * SHA256(0x102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f)
 *  = 0xfdeab9acf3710362bd2658cdc9a29e8f9c757fcf9811603a8c447cd1d9151108
 */
static const uint8_t kExactBlockMessage[] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a,
    0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15,
    0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20,
    0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b,
    0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36,
    0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
};
static const size_t kExactBlockMessageLen = sizeof(kExactBlockMessage);
static const uint8_t kExactBlockExpDigest[] = {
    0xfd, 0xea, 0xb9, 0xac, 0xf3, 0x71, 0x03, 0x62, 0xbd, 0x26, 0x58,
    0xcd, 0xc9, 0xa2, 0x9e, 0x8f, 0x9c, 0x75, 0x7f, 0xcf, 0x98, 0x11,
    0x60, 0x3a, 0x8c, 0x44, 0x7c, 0xd1, 0xd9, 0x15, 0x11, 0x08,
};

enum {
  /**
   * Number of 32-bit words in a SHA-256 digest.
   */
  kDigestNumWords = 256 / 32,
};

/**
 * Call the `otcrypto_hash` API and check the resulting digest.
 *
 * @param msg Input message.
 * @param exp_digest Expected digest (256 bits).
 */
static status_t run_test(crypto_const_byte_buf_t msg,
                         const uint32_t *exp_digest) {
  uint32_t act_digest[kDigestNumWords];
  crypto_word32_buf_t digest_buf = {
      .data = act_digest,
      .len = kDigestNumWords,
  };
  uint64_t t_start = profile_start();
  TRY(otcrypto_hash(msg, kHashModeSha256, &digest_buf));
  profile_end_and_print(t_start, "sha256");
  TRY_CHECK_ARRAYS_EQ(act_digest, exp_digest, kDigestNumWords);
  return OK_STATUS();
}

/**
 * Simple test with a short message.
 *
 * SHA256('Test message.')
 *   = 0xb2da997a966ee07c43e1f083807ce5884bc0a4cad13b02cadc72a11820b50917
 */
static status_t simple_test(void) {
  const char plaintext[] = "Test message.";
  crypto_const_byte_buf_t msg_buf = {
      .data = (unsigned char *)plaintext,
      .len = sizeof(plaintext) - 1,
  };
  const uint32_t exp_digest[] = {
      0x7a99dab2, 0x7ce06e96, 0x83f0e143, 0x88e57c80,
      0xcaa4c04b, 0xca023bd1, 0x18a172dc, 0x1709b520,
  };
  return run_test(msg_buf, exp_digest);
}

/**
 * Test with an empty message.
 *
 * SHA256('')
 *   = 0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
 */
static status_t empty_test(void) {
  const uint32_t exp_digest[] = {
      0x42c4b0e3, 0x141cfc98, 0xc8f4fb9a, 0x24b96f99,
      0xe441ae27, 0x4c939b64, 0x1b9995a4, 0x55b85278,
  };
  crypto_const_byte_buf_t msg_buf = {
      .data = NULL,
      .len = 0,
  };
  return run_test(msg_buf, exp_digest);
}

/**
 * Test streaming API with a one-block message in one update.
 */
static status_t one_update_streaming_test(void) {
  hash_context_t ctx;
  TRY(otcrypto_hash_init(&ctx, kHashModeSha256));

  crypto_const_byte_buf_t msg_buf = {
      .data = kExactBlockMessage,
      .len = kExactBlockMessageLen,
  };
  TRY(otcrypto_hash_update(&ctx, msg_buf));

  size_t digest_num_words =
      (sizeof(kExactBlockExpDigest) + sizeof(uint32_t) - 1) / sizeof(uint32_t);
  uint32_t act_digest[digest_num_words];
  crypto_word32_buf_t digest_buf = {
      .data = act_digest,
      .len = digest_num_words,
  };
  TRY(otcrypto_hash_final(&ctx, &digest_buf));
  TRY_CHECK_ARRAYS_EQ((unsigned char *)act_digest, kExactBlockExpDigest,
                      sizeof(kExactBlockExpDigest));
  return OK_STATUS();
}

/**
 * Test streaming API with a two-block message in multiple updates.
 */
static status_t multiple_update_streaming_test(void) {
  hash_context_t ctx;
  TRY(otcrypto_hash_init(&ctx, kHashModeSha256));

  // Send 0 bytes, then 1, then 2, etc. until message is done.
  const unsigned char *next = kTwoBlockMessage;
  size_t len = kTwoBlockMessageLen;
  size_t update_size = 0;
  while (len > 0) {
    update_size = len <= update_size ? len : update_size;
    crypto_const_byte_buf_t msg_buf = {
        .data = next,
        .len = update_size,
    };
    next += update_size;
    len -= update_size;
    update_size++;
    TRY(otcrypto_hash_update(&ctx, msg_buf));
  }
  size_t digest_num_words =
      (sizeof(kTwoBlockExpDigest) + sizeof(uint32_t) - 1) / sizeof(uint32_t);
  uint32_t act_digest[digest_num_words];
  crypto_word32_buf_t digest_buf = {
      .data = act_digest,
      .len = digest_num_words,
  };
  TRY(otcrypto_hash_final(&ctx, &digest_buf));
  TRY_CHECK_ARRAYS_EQ((unsigned char *)act_digest, kTwoBlockExpDigest,
                      sizeof(kTwoBlockExpDigest));
  return OK_STATUS();
}

/**
 * Test with a long message.
 *
 * SHA256(kRandomDataOneKilobyte)
 *   = 0x655dd1aaf27aa5f252d767704a873338be66aca295c0bf8c204b7255be9af9cd
 */
static_assert(sizeof(kRandomDataOneKilobyte) == 1000,
              "Data length is unexpected");
static status_t long_test(void) {
  const uint32_t exp_digest[] = {
      0xaad15d65, 0xf2a57af2, 0x7067d752, 0x3833874a,
      0xa2ac66be, 0x8cbfc095, 0x55724b20, 0xcdf99abe,
  };
  crypto_const_byte_buf_t msg_buf = {
      .data = (unsigned char *)kRandomDataOneKilobyte,
      .len = sizeof(kRandomDataOneKilobyte),
  };
  return run_test(msg_buf, exp_digest);
}

/**
 * Test streaming API with a long message.
 *
 * SHA256(kRandomDataOneKilobyte || kRandomDataOneKilobyte || kRandomDataOneKilobyte)
 *   = 0x6a53a80bced7e3928e7f1607176553f9113e15ac54ed06cf82bd865917940282
 */
static status_t long_streaming_test(void) {
  const uint32_t exp_digest[] = {
      0x0ba8536a,
      0x92e3d7ce,
      0x07167f8e,
      0xf9536517,
      0xac153e11,
      0xcf06ed54,
      0x5986bd82,
      0x82029417,
  };
  // Construct message buffer, which will be chained with itself.
  crypto_const_byte_buf_t msg_buf = {
      .data = (unsigned char *)kRandomDataOneKilobyte,
      .len = sizeof(kRandomDataOneKilobyte),
  };

  // Prepare a buffer to store the computed digest.
  uint32_t act_digest[kDigestNumWords];
  crypto_word32_buf_t digest_buf = {
      .data = act_digest,
      .len = kDigestNumWords,
  };

  uint64_t t_start = profile_start();
  hash_context_t ctx;
  TRY(otcrypto_hash_init(&ctx, kHashModeSha256));
  for (size_t i = 0; i < 3; i++) {
    TRY(otcrypto_hash_update(&ctx, msg_buf));
  }
  TRY(otcrypto_hash_final(&ctx, &digest_buf));
  profile_end_and_print(t_start, "sha256 3kB streaming");

  TRY_CHECK_ARRAYS_EQ(act_digest, exp_digest, kDigestNumWords);
  return OK_STATUS();
}

OTTF_DEFINE_TEST_CONFIG();

bool test_main(void) {
  status_t test_result = OK_STATUS();
  EXECUTE_TEST(test_result, simple_test);
  EXECUTE_TEST(test_result, empty_test);
  EXECUTE_TEST(test_result, one_update_streaming_test);
  EXECUTE_TEST(test_result, multiple_update_streaming_test);
  EXECUTE_TEST(test_result, long_test);
  EXECUTE_TEST(test_result, long_streaming_test);
  return status_ok(test_result);
}
