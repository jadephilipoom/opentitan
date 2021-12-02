// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// AUTOGENERATED. Do not edit this file by hand.
// See the crypto/tests README for details.

#ifndef OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_CRYPTO_TESTS_RSA_3072_VERIFY_TESTVECTORS_H_
#define OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_CRYPTO_TESTS_RSA_3072_VERIFY_TESTVECTORS_H_

#include "sw/device/lib/crypto/rsa_3072/rsa_3072_verify.h"

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

// A test vector for RSA-3072 verify (message hashed with SHA-256)
typedef struct rsa_3072_verify_test_vector_t {
  rsa_3072_public_key_t publicKey;  // The public key
  rsa_3072_int_t signature;         // The signature to verify
  bool valid;                       // Expected result (true if signature valid)
  char *comment;                    // Any notes about the test vector
  size_t msgLen;                    // Length (in bytes) of the message
  uint8_t *msg;                     // Message bytes
} rsa_3072_verify_test_vector_t;

static const size_t RSA_3072_VERIFY_NUM_TESTS = 2;

// Static message arrays.
static uint8_t msg0[12] = {0x74, 0x65, 0x73, 0x74, 0x20, 0x6d,
                           0x65, 0x73, 0x73, 0x61, 0x67, 0x65};
static uint8_t msg1[12] = {0x74, 0x65, 0x73, 0x74, 0x20, 0x6d,
                           0x65, 0x73, 0x73, 0x61, 0x67, 0x65};

static const rsa_3072_verify_test_vector_t rsa_3072_verify_tests[2] = {
    {
        .publicKey =
            {
                .n = {.data =
                          {
                              0xacc72b4f, 0x3ee83a81, 0x9c476ca4, 0x945bdc9e,
                              0x69140f45, 0x47c22053, 0x963b4d81, 0x7b9f34b9,
                              0xe68c0247, 0x68044735, 0x5eeb079d, 0x752280cb,
                              0xd8a142d3, 0x4a82fea2, 0x8e5001b8, 0xc40fd406,
                              0xd69db99a, 0xfb7160e8, 0xd191b4e4, 0xa100f64c,
                              0x73144186, 0xfb0ff5a3, 0x2b638154, 0x535dd161,
                              0x3f7122fd, 0xd186e517, 0x643d139a, 0xc8c2b5bb,
                              0x68a1ac08, 0x5a4d1cd6, 0x03532124, 0xb6ef33a2,
                              0x11259194, 0x4321e272, 0x009fee9a, 0x869967ca,
                              0x054a0a04, 0x081bbe2c, 0x438a08b5, 0xacb2cdfa,
                              0xa73287ac, 0x44ea7640, 0x9a7a4691, 0x96b62e21,
                              0x5efba03b, 0x5abf65fd, 0xd24abf10, 0x3106ff1c,
                              0x734ee2b4, 0xf1e03dc7, 0xca896499, 0x8a2802f7,
                              0x2268fa91, 0x2289e434, 0xdbb333bd, 0x9852e8b0,
                              0xb62041db, 0x81f0f2c3, 0xa3303e2d, 0xdcfb09bf,
                              0x8ac5833f, 0x5ef33b58, 0xab7b4052, 0x0f8ed557,
                              0x8aa34346, 0x9ced6e07, 0x8a2d0860, 0x2a25a93c,
                              0x3ad5b178, 0xe6b22d85, 0x62a14dcc, 0x86e797d3,
                              0xe5b87a04, 0x5fb5ea60, 0x3c15b76f, 0xb18d544b,
                              0x66510577, 0x6fbd4e54, 0x4d9874b7, 0xbbf4be88,
                              0x7bcc1314, 0x52f1e34b, 0x35182a57, 0xd5284087,
                              0x5462b6c4, 0xd4caa1a9, 0x5d624287, 0x1e415896,
                              0xde34442e, 0xd6f30489, 0xc3928989, 0x0c979767,
                              0x6beccd26, 0xa4c32ebd, 0xd5f186a5, 0xacb29b56,
                          }},
                .e = 0x10001,
            },
        .signature =
            {.data =
                 {
                     0x38370d2b, 0x3bc29a2f, 0x39b8681c, 0x6e68f66e, 0xc401c15b,
                     0x57685a57, 0x2ea02c83, 0x22646948, 0xc3f02d4e, 0x8ef87811,
                     0x007bd96c, 0xb69959c8, 0x68604177, 0xd3e97992, 0x4dfb1cc3,
                     0x4a80a9de, 0x2f63213d, 0x429856a2, 0x1edab56f, 0x0d98a170,
                     0xfe5f1b11, 0x0e4fab23, 0x848d846e, 0x0494ebc0, 0x470cf726,
                     0x861990f5, 0x63237557, 0x046026c6, 0xdfe229ee, 0x6cbd8fe5,
                     0xb577c3c5, 0x13e6aecb, 0x4149af65, 0x3830aac0, 0x41f9cca4,
                     0x752135be, 0x681ac9b0, 0x28eff527, 0xfe5548e1, 0x185320c1,
                     0xab6bc604, 0x5218c04b, 0xccd24526, 0x2a207b20, 0xa71fd3a5,
                     0x84466c91, 0xf1323dd5, 0x62cb1217, 0xeff14152, 0x4da52c1d,
                     0xa7e8b3c8, 0x5fbd6deb, 0x57d00506, 0xa9894b64, 0x240321ca,
                     0xe1655cc6, 0x8d931866, 0xfeb714a7, 0xc984e6ca, 0xd7b077dc,
                     0x2ae47b38, 0x95e13568, 0x94e986e2, 0xfb3fc3bc, 0x6f3f599e,
                     0x8b446595, 0xf8bd2c12, 0x5630a5de, 0x58235a55, 0xd1a69134,
                     0xea9db8e4, 0xe5b32713, 0x3a5b9181, 0xac2098c9, 0xe6afcf84,
                     0xb0bd19f6, 0xabea423d, 0xfd8c6c78, 0xe77b9826, 0x030c600d,
                     0xd9c9aab7, 0x7fb878b0, 0xe183e1bb, 0x8cb78308, 0xae0c5aee,
                     0xe7aad9d5, 0x417ca6b7, 0xf39bdb5f, 0x0ae09a59, 0x8f849c39,
                     0x38a6c62b, 0x811f1473, 0x8b12fc5f, 0x7932623e, 0xb6389fc8,
                     0x9801d012,
                 }},
        .msg = msg0,
        .msgLen = 12,
        .valid = true,
        .comment = "Hardcoded test with valid signature",
    },
    {
        .publicKey =
            {
                .n = {.data =
                          {
                              0xacc72b4f, 0x3ee83a81, 0x9c476ca4, 0x945bdc9e,
                              0x69140f45, 0x47c22053, 0x963b4d81, 0x7b9f34b9,
                              0xe68c0247, 0x68044735, 0x5eeb079d, 0x752280cb,
                              0xd8a142d3, 0x4a82fea2, 0x8e5001b8, 0xc40fd406,
                              0xd69db99a, 0xfb7160e8, 0xd191b4e4, 0xa100f64c,
                              0x73144186, 0xfb0ff5a3, 0x2b638154, 0x535dd161,
                              0x3f7122fd, 0xd186e517, 0x643d139a, 0xc8c2b5bb,
                              0x68a1ac08, 0x5a4d1cd6, 0x03532124, 0xb6ef33a2,
                              0x11259194, 0x4321e272, 0x009fee9a, 0x869967ca,
                              0x054a0a04, 0x081bbe2c, 0x438a08b5, 0xacb2cdfa,
                              0xa73287ac, 0x44ea7640, 0x9a7a4691, 0x96b62e21,
                              0x5efba03b, 0x5abf65fd, 0xd24abf10, 0x3106ff1c,
                              0x734ee2b4, 0xf1e03dc7, 0xca896499, 0x8a2802f7,
                              0x2268fa91, 0x2289e434, 0xdbb333bd, 0x9852e8b0,
                              0xb62041db, 0x81f0f2c3, 0xa3303e2d, 0xdcfb09bf,
                              0x8ac5833f, 0x5ef33b58, 0xab7b4052, 0x0f8ed557,
                              0x8aa34346, 0x9ced6e07, 0x8a2d0860, 0x2a25a93c,
                              0x3ad5b178, 0xe6b22d85, 0x62a14dcc, 0x86e797d3,
                              0xe5b87a04, 0x5fb5ea60, 0x3c15b76f, 0xb18d544b,
                              0x66510577, 0x6fbd4e54, 0x4d9874b7, 0xbbf4be88,
                              0x7bcc1314, 0x52f1e34b, 0x35182a57, 0xd5284087,
                              0x5462b6c4, 0xd4caa1a9, 0x5d624287, 0x1e415896,
                              0xde34442e, 0xd6f30489, 0xc3928989, 0x0c979767,
                              0x6beccd26, 0xa4c32ebd, 0xd5f186a5, 0xacb29b56,
                          }},
                .e = 0x10001,
            },
        .signature =
            {.data =
                 {
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
                     0x00000000,
                 }},
        .msg = msg1,
        .msgLen = 12,
        .valid = false,
        .comment = "Hardcoded test with invalid signature",
    },
};

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  // OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_CRYPTO_TESTS_RSA_3072_VERIFY_TESTVECTORS_H_
