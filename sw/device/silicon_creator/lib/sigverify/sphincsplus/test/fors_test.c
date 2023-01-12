// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/fors.h"

#include <stdint.h>

#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/hash.h"

OTTF_DEFINE_TEST_CONFIG();

static void pk_from_sig_test(const unsigned char *sig, const unsigned char *m,
                             const spx_ctx *ctx, const uint32_t fors_addr[8],
                             uint32_t *expected_pk) {
  uint32_t actual_pk[kSpxNWords];
  CHECK(fors_pk_from_sig(sig, m, ctx, fors_addr, actual_pk) == kErrorOk);
  if (expected_pk != NULL) {
    CHECK_ARRAYS_EQ(actual_pk, expected_pk, kSpxNWords);
  }
}

bool test_main() {
  LOG_INFO("Starting FORS test...");

  spx_ctx ctx = {
      .pub_seed = {0xefbeadde},
  };
  CHECK(spx_hash_initialize(&ctx) == kErrorOk);
  LOG_INFO("Setup complete.");

  // Simple test:
  //   sig = {0, 1, 2, 3, ... }
  //   msg = { ..., 3, 2, 1, 0}
  //   addr = {0}
  uint8_t sig[kSpxForsBytes];
  for (size_t i = 0; i < kSpxForsBytes; i++) {
    sig[i] = i & 255;
  }
  uint8_t msg[kSpxForsMsgBytes];
  for (size_t i = 0; i < kSpxForsMsgBytes; i++) {
    msg[i] = kSpxForsMsgBytes - i;
  }
  uint32_t addr[8] = {0};
  // Note: this expected public key is based on the sphincs-shake-128s
  // parameter set and will not work for other parameter sets.
  uint32_t expected_pk[kSpxNWords] = {0xd2c5c792, 0x80d096bd, 0xdb6d692e,
                                      0xf75f2fe8};
  LOG_INFO("Running simple test...");
  pk_from_sig_test(sig, msg, &ctx, addr, expected_pk);

  return true;
}
