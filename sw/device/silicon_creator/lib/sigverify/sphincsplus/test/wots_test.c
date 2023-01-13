// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/wots.h"

#include <stdint.h>

#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/hash.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"

OTTF_DEFINE_TEST_CONFIG();

#define kSpxWotsMsgBytes ((kSpxWotsLen1 * kSpxWotsLogW + 7) / 8)

static void pk_from_sig_test(const unsigned char *sig, const unsigned char *msg,
                             const spx_ctx *ctx, uint32_t addr[8],
                             uint32_t *expected_pk) {
  uint32_t actual_pk[kSpxWotsPkWords];
  CHECK(wots_pk_from_sig(sig, msg, ctx, addr, actual_pk) == kErrorOk);
  if (expected_pk != NULL) {
    CHECK_ARRAYS_EQ(actual_pk, expected_pk, kSpxWotsPkWords);
  }
}

bool test_main() {
  LOG_INFO("Starting WOTS test...");

  spx_ctx ctx = {
      .pub_seed = {0xefbeadde},
  };
  CHECK(spx_hash_initialize(&ctx) == kErrorOk);
  LOG_INFO("Setup complete.");

  // Simple test:
  //   sig = {0, 1, 2, 3, ... }
  //   msg = { ..., 3, 2, 1, 0}
  //   addr = {0}
  uint8_t sig[kSpxWotsBytes];
  for (size_t i = 0; i < kSpxWotsBytes; i++) {
    sig[i] = i & 255;
  }
  uint8_t msg[kSpxWotsMsgBytes];
  for (size_t i = 0; i < kSpxWotsMsgBytes; i++) {
    msg[i] = (kSpxWotsMsgBytes - i) & 255;
  }
  uint32_t addr[8] = {0xdeadbeef};
  // Note: this public key is based on the sphincs-shake-128s parameter set and
  // will not work for other parameter sets.
  uint32_t expected_pk[kSpxWotsPkWords] = {
      0x2664c607, 0x0876f157, 0x07fca058, 0x1edd1978, 0xd34ea8b2, 0xc635e08a,
      0x2ad601bc, 0x430f5e4e, 0xc1cdf74a, 0x07e2186b, 0xd37b8f28, 0x27d2e280,
      0x33323130, 0x37363534, 0x3b3a3938, 0x3f3e3d3c, 0x5dbc5771, 0xdf3fb927,
      0x785e5aec, 0xcc6e1dae, 0x86b2f0d0, 0xa2b45f3a, 0x9778f47b, 0x6f5fe9a9,
      0xce0cbe16, 0x8d29f3cc, 0x218035e4, 0x82fe66ca, 0xd44fc3e2, 0xd6e2eb92,
      0xc84c5020, 0xe67a8ad9, 0xdee8a9e1, 0x35520ee2, 0xe43c747a, 0x1a9520db,
      0x5a582887, 0x27e4abcc, 0x6a9e2dcd, 0x4150bbb2, 0xe9ca7143, 0xde01a332,
      0x92824132, 0x75b6dbbb, 0xa820737c, 0x403fabff, 0xebdc9b14, 0xb0e8d941,
      0x8cdc02ef, 0xcb00b6ad, 0x06a98cf7, 0xe5d16eea, 0x7eccf7a8, 0x1f036a59,
      0x663cb396, 0xa4768d91, 0x6d1ca9b5, 0xe5ea1254, 0x6a585c9f, 0x3fff5c4c,
      0xb2ac73f7, 0x498b2717, 0xa6352ba5, 0x110d3b1f, 0x25acdf7e, 0xc49b07e2,
      0x4580c93c, 0x6c0d5125, 0xb51ea2de, 0xe90ea294, 0xf2b1f7e7, 0xb98d2ca7,
      0x67507c3f, 0x4278d9df, 0x459e0d22, 0x6d808a83, 0x50b29e70, 0xbeb49d1a,
      0xe5d50a2f, 0xe18caf8f, 0xb9670acb, 0xc02fb41c, 0x02b64bb2, 0x3e1ed1b6,
      0xf82d3afc, 0x1936bc72, 0xad75f064, 0xfc89d191, 0xea091797, 0xbd7a778a,
      0x1aafd227, 0xbe35349e, 0x8e5aa563, 0xaf19f168, 0x9fc76c94, 0xfb0ab2ed,
      0x72c5dacd, 0x023d3a50, 0x49a90a2e, 0x38d6eaae, 0x4e37cfcf, 0xf96a6d87,
      0xb50a84c1, 0x2a409f21, 0xf94235b1, 0x136ef5ea, 0x0fd2c77e, 0x95b2f59a,
      0x7acddc7f, 0x6154fdba, 0x43b556dc, 0x44ad8f0c, 0xeab603d5, 0x5888600b,
      0x6c5c4b67, 0x4cf25965, 0xbafafd38, 0x974ff50b, 0x34239d92, 0xa4884b71,
      0x4f7469f5, 0xd5f10fc0, 0xacce2fac, 0x2b774cb6, 0x5d88c301, 0x11f0575d,
      0x984a4fdd, 0x5f44b01d, 0x77ed6afa, 0x272edd0c, 0xa5a9ded1, 0x34a55aba,
      0x460bec28, 0x3724f477, 0x46f9003f, 0x6357d6ec, 0x7a39121d, 0x511b498f,
      0x2bca40d1, 0x24b829a1};

  LOG_INFO("Running test...");
  pk_from_sig_test(sig, msg, &ctx, addr, expected_pk);

  return true;
}
