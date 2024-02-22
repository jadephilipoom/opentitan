// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/status.h"
#include "sw/device/lib/testing/json/provisioning_data.h"
#include "sw/device/lib/testing/profile.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/silicon_creator/lib/attestation.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "otp_ctrl_regs.h"  // Generated.

OTTF_DEFINE_TEST_CONFIG();

// Test PK taken from sw/otbn/crypto/tests/p256_ecdsa_verify_test.s
static const ecc_p256_public_key_t kTestEccP256PublicKey = {
        .x =
            {
                0xbfa8c334,
                0x9773b7b3,
                0xf36b0689,
                0x6ec0c0b2,
                0xdb6c8bf3,
                0x1628ce58,
                0xfacdc546,
                0xb5511a6a
            },
        .y =
            {
                0x9e008c2e,
                0xa8707058,
                0xab9c6924,
                0x7f7a11d0,
                0xb53a17fa,
                0x43dd09ea,
                0x1f31c143,
                0x42a1c697
            },
};

status_t benchmark_generate_flash_addr_scrambling_key(void) {
  uint64_t t_start = profile_start();
  TRY(manuf_personalize_device_secret1(&lc_ctrl, &otp_ctrl));
  profile_end_and_print(t_start, "SECRET1 personalization");
  return OK_STATUS();
}

bool test_main(void) {
  status_t result = OK_STATUS();
  CHECK_STATUS_OK(peripheral_handles_init());
  EXECUTE_TEST(result, benchmark_personalize_device_secret1);
  EXECUTE_TEST(result, benchmark_personalize_device_secrets);
  return status_ok(result);
}
