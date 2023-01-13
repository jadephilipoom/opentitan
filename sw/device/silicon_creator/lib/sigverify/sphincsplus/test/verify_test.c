// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/verify.h"

#include <stdint.h>

#include "message_keys.inc"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/status.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

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
  LOG_INFO("Starting SPHINCS+ verify test...");

  unsigned char *sig = sm;
  uint32_t root[kSpxVerifyRootNumWords];

  // Compute root (verification minus the final comparison).
  uint64_t t_start = profile_start();
  CHECK(spx_verify(sig, m, sizeof(m), pk, root) == kErrorOk);
  uint32_t cycles = profile_end(t_start);
  LOG_INFO("Verification took %u cycles.", cycles);

  // Check if signature passed verification by comparing to public key root.
  uint32_t pub_root[kSpxVerifyRootNumWords];
  spx_public_key_root(pk, pub_root);
  CHECK_ARRAYS_EQ(root, pub_root, kSpxVerifyRootNumWords);

  return true;
}
