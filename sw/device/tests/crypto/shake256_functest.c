// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/crypto/drivers/entropy.h"
#include "sw/device/lib/crypto/include/datatypes.h"
#include "sw/device/lib/crypto/include/hash.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/profile.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

/**
 * Test vectors in this file were generated with openssl, e.g. to compute
 * SHAKE256('Test message.') with output lenth of 32 bytes:
 
 * $ echo -n "Test message." | openssl shake256 -xoflen 32
 * SHAKE256(stdin)= 5df931a18b0824a30f5c6721397fc915097399f7ff81037f930495fce6443441
 */

/**
 * Call the `otcrypto_xof_shake` API and check the resulting digest.
 *
 * @param msg Input message.
 * @param digest_wordlen Requested length in 32-bit words.
 * @param exp_digest Expected digest.
 */
static status_t run_test(otcrypto_const_byte_buf_t msg, const size_t digest_wordlen,
                         const uint32_t *exp_digest) {
  uint32_t act_digest[digest_wordlen];
  otcrypto_hash_digest_t digest_buf = {
      .data = act_digest,
      .len = digest_wordlen,
      .mode = kOtcryptoHashXofModeShake256,
  };
  uint64_t t_start = profile_start();
  TRY(otcrypto_xof_shake(msg, digest_buf));
  profile_end_and_print(t_start, "SHAKE256");
  TRY_CHECK_ARRAYS_EQ(act_digest, exp_digest, digest_wordlen);
  return OK_STATUS();
}

/**
 * Empty message test.
 *
 * SHAKE256('') = 46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762f
 */
static status_t empty_test(void) {
  const uint32_t exp_digest[] = {
	  0x2bddb946,
	  0x138da80b,
	  0xeb3f3b23,
	  0x24eb3e74,
	  0xea52cd3f,
	  0x821bb862,
	  0x64270cb5,
	  0x2f76d56e
  };
  otcrypto_const_byte_buf_t msg_buf = {
      .data = NULL,
      .len = 0,
  };
  return run_test(msg_buf, 8, exp_digest);
}

/**
 * Simple test with a short message.
 *
 * SHAKE256('Test message.') = 5df931a18b0824a30f5c6721397fc915097399f7ff81037f930495fce6443441
 */
static status_t simple_test(void) {
  const char plaintext[] = "Test message.";
  otcrypto_const_byte_buf_t msg_buf = {
      .data = (unsigned char *)plaintext,
      .len = sizeof(plaintext) - 1,
  };
  const uint32_t exp_digest[] = {
	  0xa131f95d,
	  0xa324088b,
	  0x21675c0f,
	  0x15c97f39,
	  0xf7997309,
	  0x7f0381ff,
	  0xfc950493,
	  0x413444e6
  };
  return run_test(msg_buf, 8, exp_digest);
}
/**
 * Test with a long message.
 *
 * SHAKE256(<4kB of the byte 0xaa>)
 *   = 0x3a783520265006bb3ab28f75f0c438b1196f94d308f23534ae204d4668ece2db
 */
static status_t long_test(void) {
  unsigned char msg_data[4000];
  memset(msg_data, 0xaa, sizeof(msg_data));
  otcrypto_const_byte_buf_t msg_buf = {
      .data = msg_data,
      .len = sizeof(msg_data),
  };
  const uint32_t exp_digest[] = {
	0x2035783a,
	0xbb065026,
	0x758fb23a,
	0xb138c4f0,
	0xd3946f19,
	0x3435f208,
	0x464d20ae,
	0xdbe2ec68
  };
  return run_test(msg_buf, 8, exp_digest);
}

OTTF_DEFINE_TEST_CONFIG();

bool test_main(void) {
  status_t test_result = OK_STATUS();
  CHECK_STATUS_OK(entropy_complex_init());
  EXECUTE_TEST(test_result, simple_test);
  EXECUTE_TEST(test_result, empty_test);
  EXECUTE_TEST(test_result, long_test);
  return status_ok(test_result);
}
