// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/status.h"
#include "sw/device/lib/crypto/drivers/entropy.h"
#include "sw/device/lib/testing/json/provisioning_data.h"
#include "sw/device/lib/testing/profile.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/silicon_creator/lib/attestation.h"

// We directly include `personalize.c` so we have access to static functions
// and constants.
#include "sw/device/silicon_creator/manuf/lib/personalize.c"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "otp_ctrl_regs.h"  // Generated.

OTTF_DEFINE_TEST_CONFIG();

// Test P256 public key taken from
// sw/otbn/crypto/tests/p256_ecdsa_verify_test.s
static ecc_p256_public_key_t host_pk = {
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

/**
 * DIF Handles.
 *
 * Keep this list sorted in alphabetical order.
 */
static dif_flash_ctrl_state_t flash_state;
static dif_lc_ctrl_t lc_ctrl;
static dif_otp_ctrl_t otp_ctrl;

/**
 * Initializes all DIF handles used in this module.
 */
static status_t peripheral_handles_init(void) {
  TRY(dif_flash_ctrl_init_state(
      &flash_state,
      mmio_region_from_addr(TOP_EARLGREY_FLASH_CTRL_CORE_BASE_ADDR)));
  TRY(dif_lc_ctrl_init(mmio_region_from_addr(TOP_EARLGREY_LC_CTRL_BASE_ADDR),
                       &lc_ctrl));
  TRY(dif_otp_ctrl_init(
      mmio_region_from_addr(TOP_EARLGREY_OTP_CTRL_CORE_BASE_ADDR), &otp_ctrl));
  return OK_STATUS();
}

status_t benchmark_personalize_device_secret1(void) {
  uint64_t t_start = profile_start();
  // For this test, we can directly call the function from the `personalize` lib.
  TRY(manuf_personalize_device_secret1(&lc_ctrl, &otp_ctrl));
  profile_end_and_print(t_start, "SECRET1 personalization");
  return OK_STATUS();
}

status_t benchmark_personalize_device_secrets(void) {
  wrapped_rma_unlock_token_t wrapped_token;

  // The following code is copied from `personalize_device_secrets` in
  // personalize.c, minus checks on the lifecycle state and reads/writes to
  // OTP, and plus some benchmark start/end points.

  uint64_t t_start = profile_start();
  // Generate AES encryption key and IV for exporting the RMA unlock token.
  // AES key (i.e., ECDH shared secret).
  uint32_t aes_key_buf[keyblob_num_words(kRmaUnlockTokenAesKeyConfig)];
  otcrypto_blinded_key_t token_aes_key = {
      .config = kRmaUnlockTokenAesKeyConfig,
      .keyblob_length = sizeof(aes_key_buf),
      .keyblob = aes_key_buf,
  };

  // Re-initialize the entropy complex in continous mode. This also configures
  // the entropy_src health checks in FIPS mode.
  TRY(entropy_complex_init());
  
  otcrypto_unblinded_key_t pk_host = {
      .key_mode = kOtcryptoKeyModeEcdh,
      .key_length = sizeof(host_pk),
      .key = (uint32_t *)&host_pk,
      .checksum = 0,
  };
  profile_end_and_print(t_start, "Initialization");


  t_start = profile_start();
  // ECDH device private key.
  uint32_t sk_device_keyblob[keyblob_num_words(kEcdhPrivateKeyConfig)];
  otcrypto_blinded_key_t sk_device = {
      .config = kEcdhPrivateKeyConfig,
      .keyblob_length = sizeof(sk_device_keyblob),
      .keyblob = sk_device_keyblob,
      .checksum = 0,
  };

  // ECDH device public key.
  otcrypto_unblinded_key_t pk_device = {
      .key_mode = kOtcryptoKeyModeEcdh,
      .key_length = sizeof(wrapped_token.device_pk),
      .key = (uint32_t *)&wrapped_token.device_pk,
      .checksum = 0,
  };
  TRY(otcrypto_ecdh_keygen(&kCurveP256, &sk_device, &pk_device));
  profile_end_and_print(t_start, "ECDH key generation");

  t_start = profile_start();
  TRY(otcrypto_ecdh(&sk_device, &pk_host, &kCurveP256, &token_aes_key));
  profile_end_and_print(t_start, "ECDH key exchange");

  t_start = profile_start();
  // Provision secret Creator / Owner key seeds in flash.
  // Provision CreatorSeed into target flash info page.
  TRY(flash_keymgr_secret_seed_write(&flash_state, kFlashInfoFieldCreatorSeed,
                                     kFlashInfoKeySeedSizeIn32BitWords));
  // Provision preliminary OwnerSeed into target flash info page (with
  // expectation that SiliconOwner will rotate this value during ownership
  // transfer).
  TRY(flash_keymgr_secret_seed_write(&flash_state, kFlashInfoFieldOwnerSeed,
                                     kFlashInfoKeySeedSizeIn32BitWords));

  // Provision attestation key seeds.
  TRY(flash_attestation_key_seed_write(&flash_state,
                                       kFlashInfoFieldUdsAttestationKeySeed,
                                       kAttestationSeedWords));
  TRY(flash_attestation_key_seed_write(&flash_state,
                                       kFlashInfoFieldCdi0AttestationKeySeed,
                                       kAttestationSeedWords));
  TRY(flash_attestation_key_seed_write(&flash_state,
                                       kFlashInfoFieldCdi1AttestationKeySeed,
                                       kAttestationSeedWords));
  profile_end_and_print(t_start, "Creator/Owner/attestation seed generation");

  t_start = profile_start();
  // Provision the OTP SECRET2 partition.
  // Code below is expanded from otp_partition_secret2_configure, minus the
  // final writes to OTP.
  TRY(entropy_csrng_instantiate(/*disable_trng_input=*/kHardenedBoolFalse,
                                /*seed_material=*/NULL));

  // Generate and hash RMA unlock token.
  TRY(entropy_csrng_generate(/*seed_material=*/NULL, wrapped_token.data,
                             kRmaUnlockTokenSizeIn32BitWords,
                             /*fips_check*/ kHardenedBoolTrue));
  TRY(entropy_csrng_reseed(/*disable_trng_input=*/kHardenedBoolFalse,
                           /*seed_material=*/NULL));
  uint64_t hashed_wrapped_token[kRmaUnlockTokenSizeIn64BitWords];
  TRY(manuf_util_hash_lc_transition_token(wrapped_token.data,
                                          kRmaUnlockTokenSizeInBytes,
                                          hashed_wrapped_token));
  profile_end_and_print(t_start, "Generate RMA token");

  t_start = profile_start();
  // Generate RootKey shares.
  uint64_t share0[kRootKeyShareSizeIn64BitWords];
  TRY(entropy_csrng_generate(/*seed_material=*/NULL, (uint32_t *)share0,
                             kRootKeyShareSizeIn32BitWords,
                             /*fips_check*/ kHardenedBoolTrue));
  TRY(entropy_csrng_reseed(/*disable_trng_input=*/kHardenedBoolFalse,
                           /*seed_material=*/NULL));

  uint64_t share1[kRootKeyShareSizeIn64BitWords];
  TRY(entropy_csrng_generate(/*seed_material=*/NULL, (uint32_t *)share1,
                             kRootKeyShareSizeIn32BitWords,
                             /*fips_check*/ kHardenedBoolTrue));
  TRY(entropy_csrng_uninstantiate());

  TRY(shares_check(share0, share1, kRootKeyShareSizeIn64BitWords));
  profile_end_and_print(t_start, "Generate RootKey");

  t_start = profile_start();
  // Encrypt the RMA unlock token with AES.
  TRY(encrypt_rma_unlock_token(&token_aes_key,
                               &wrapped_token));
  profile_end_and_print(t_start, "Encrypt RMA token");

  return OK_STATUS();
}

bool test_main(void) {
  status_t result = OK_STATUS();
  CHECK_STATUS_OK(peripheral_handles_init());
  EXECUTE_TEST(result, benchmark_personalize_device_secret1);
  EXECUTE_TEST(result, benchmark_personalize_device_secrets);
  return status_ok(result);
}
