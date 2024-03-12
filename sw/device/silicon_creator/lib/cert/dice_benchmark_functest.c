// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/status.h"
#include "sw/device/lib/crypto/drivers/entropy.h"
#include "sw/device/lib/testing/json/provisioning_data.h"
#include "sw/device/lib/testing/keymgr_testutils.h"
#include "sw/device/lib/testing/otp_ctrl_testutils.h"
#include "sw/device/lib/testing/profile.h"
#include "sw/device/lib/testing/rstmgr_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/silicon_creator/lib/attestation.h"
#include "sw/device/silicon_creator/lib/cert/cdi_0.h"  // Generated.
#include "sw/device/silicon_creator/lib/cert/cdi_1.h"  // Generated.
#include "sw/device/silicon_creator/lib/cert/dice.h"
#include "sw/device/silicon_creator/lib/cert/uds.h"  // Generated.
#include "sw/device/silicon_creator/lib/drivers/flash_ctrl.h"
#include "sw/device/silicon_creator/lib/drivers/kmac.h"
#include "sw/device/silicon_creator/lib/drivers/lifecycle.h"
#include "sw/device/silicon_creator/lib/otbn_boot_services.h"
#include "sw/device/silicon_creator/lib/base/sec_mmio.h"
#include "sw/device/silicon_creator/manuf/lib/flash_info_fields.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

OTTF_DEFINE_TEST_CONFIG();

// Input data for testing. Values shouldn't matter; these values are intended
// to be human-scannable and such that no two bytes are equal.
static manuf_cert_perso_data_in_t kInData = {
    .rom_ext_measurement = {0xf0f1f2f3, 0xe0e1e2d3, 0xd0d1d2e3, 0xc0c1c2c3,
                            0xb0b1b2b3, 0xa0a1a2a3, 0x90919293, 0x80818283},
    .rom_ext_security_version = 0xdeadbeef,
    .owner_manifest_measurement = {0xf4f5f6f7, 0xe4e5e6d7, 0xd4d5d6e7,
                                   0xc4c5c6c7, 0xb4b5b6b7, 0xa4a5a6a7,
                                   0x94959697, 0x84858687},
    .owner_measurement = {0xf8f9fafb, 0xe8e9eadb, 0xd8d9daeb, 0xc8c9cacb,
                          0xb8b9babb, 0xa8a9aaab, 0x98999a9b, 0x88898a8b},
    .owner_security_version = 0x00aa00bb,
    .auth_key_key_id = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
                        0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,
                        0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13}};

// Copied from
// sw/device/silicon_creator/manuf/skus/earlgrey_a0/sival_bringup/ft_personalize_3.c
static const flash_ctrl_perms_t kCertificateFlashInfoPerms = {
    .read = kMultiBitBool4True,
    .write = kMultiBitBool4True,
    .erase = kMultiBitBool4True,
};

// Copied from
// sw/device/silicon_creator/manuf/skus/earlgrey_a0/sival_bringup/ft_personalize_3.c
static const flash_ctrl_cfg_t kCertificateFlashInfoCfg = {
    .scrambling = kMultiBitBool4True,
    .ecc = kMultiBitBool4True,
    .he = kMultiBitBool4False,
};

// Copied from
// sw/device/silicon_creator/manuf/skus/earlgrey_a0/sival_bringup/ft_personalize_3.c
static status_t config_certificate_flash_pages(void) {
  const flash_ctrl_info_page_t *kCertFlashInfoPages[] = {
      &kFlashCtrlInfoPageUdsCertificate,
      &kFlashCtrlInfoPageCdi0Certificate,
      &kFlashCtrlInfoPageCdi1Certificate,
  };
  for (size_t i = 0; i < ARRAYSIZE(kCertFlashInfoPages); ++i) {
    flash_ctrl_info_cfg_set(kCertFlashInfoPages[i], kCertificateFlashInfoCfg);
    flash_ctrl_info_perms_set(kCertFlashInfoPages[i],
                              kCertificateFlashInfoPerms);
  }
  return OK_STATUS();
}

status_t benchmark(void) {
  // The following code is modelled from
  // sw/device/silicon_creator/manuf/skus/earlgrey_a0/sival_bringup/ft_personalize_3.c,
  // with benchmarks added.
  uint64_t t_start;
  hmac_digest_t uds_pubkey_id;
  hmac_digest_t cdi_0_pubkey_id;
  static manuf_cert_perso_data_out_t out_data = {
      .uds_tbs_certificate = {0},
      .uds_tbs_certificate_size = kUdsMaxTbsSizeBytes,
      .cdi_0_certificate = {0},
      .cdi_0_certificate_size = kCdi0MaxCertSizeBytes,
      .cdi_1_certificate = {0},
      .cdi_1_certificate_size = kCdi1MaxCertSizeBytes,
  };
  // static manuf_endorsed_certs_t endorsed_certs;

  t_start = profile_start();
  // Configure certificate flash info page permissions.
  TRY(config_certificate_flash_pages());
  profile_end_and_print(t_start, "Configure certificate flash");

  // Initialize entropy complex / KMAC for key manager operations.
  t_start = profile_start();
  TRY(entropy_complex_init());
  profile_end_and_print(t_start, "Entropy complex initialization");

  t_start = profile_start();
  TRY(kmac_keymgr_configure());
  profile_end_and_print(t_start, "KMAC/keymgr initialization");

  // Advance keymgr to Initialized state.
  t_start = profile_start();
  TRY(keymgr_state_check(kKeymgrStateReset));
  keymgr_advance_state();
  profile_end_and_print(t_start, "Keymgr advance Reset->Init");
  TRY(keymgr_state_check(kKeymgrStateInit));

  // Load OTBN attestation keygen program.
  t_start = profile_start();
  TRY(otbn_boot_app_load());
  profile_end_and_print(t_start, "Load OTBN boot app");

  // Generate UDS keys and (TBS) cert.
  t_start = profile_start();
  TRY(dice_uds_cert_build(&kInData, &uds_pubkey_id,
                          out_data.uds_tbs_certificate,
                          &out_data.uds_tbs_certificate_size));
  TRY(flash_ctrl_info_erase(&kFlashCtrlInfoPageUdsCertificate,
                            kFlashCtrlEraseTypePage));
  TRY(flash_ctrl_info_write(
      &kFlashCtrlInfoPageUdsCertificate,
      kFlashInfoFieldUdsCertificate.byte_offset,
      out_data.uds_tbs_certificate_size / sizeof(uint32_t),
      out_data.uds_tbs_certificate));
  profile_end_and_print(t_start, "UDS cert generation");

  // Generate CDI_0 keys and cert.
  t_start = profile_start();
  TRY(dice_cdi_0_cert_build(&kInData, &uds_pubkey_id, &cdi_0_pubkey_id,
                            out_data.cdi_0_certificate,
                            &out_data.cdi_0_certificate_size));
  TRY(flash_ctrl_info_erase(&kFlashCtrlInfoPageCdi0Certificate,
                            kFlashCtrlEraseTypePage));
  TRY(flash_ctrl_info_write(&kFlashCtrlInfoPageCdi0Certificate,
                            kFlashInfoFieldCdi0Certificate.byte_offset,
                            out_data.cdi_0_certificate_size / sizeof(uint32_t),
                            out_data.cdi_0_certificate));
  profile_end_and_print(t_start, "CDI_0 cert generation");

  // Generate CDI_1 keys and cert.
  t_start = profile_start();
  TRY(dice_cdi_1_cert_build(&kInData, &cdi_0_pubkey_id,
                            out_data.cdi_1_certificate,
                            &out_data.cdi_1_certificate_size));
  TRY(flash_ctrl_info_erase(&kFlashCtrlInfoPageCdi1Certificate,
                            kFlashCtrlEraseTypePage));
  TRY(flash_ctrl_info_write(&kFlashCtrlInfoPageCdi1Certificate,
                            kFlashInfoFieldCdi1Certificate.byte_offset,
                            out_data.cdi_1_certificate_size / sizeof(uint32_t),
                            out_data.cdi_1_certificate));
  profile_end_and_print(t_start, "CDI_1 cert generation");

  return OK_STATUS();
}

// Initialize flash secrets for keymgr and lock the otp partition.
static void keymgr_flash_otp_init(const dif_otp_ctrl_t *otp) {
  dif_flash_ctrl_state_t flash;

  CHECK_DIF_OK(dif_flash_ctrl_init_state(
      &flash, mmio_region_from_addr(TOP_EARLGREY_FLASH_CTRL_CORE_BASE_ADDR)));

  CHECK_STATUS_OK(
      keymgr_testutils_flash_init(&flash, &kCreatorSecret, &kOwnerSecret));

  bool is_computed;
  CHECK_DIF_OK(dif_otp_ctrl_is_digest_computed(otp, kDifOtpCtrlPartitionSecret2,
                                               &is_computed));
  if (is_computed) {
    uint64_t digest;
    CHECK_DIF_OK(
        dif_otp_ctrl_get_digest(otp, kDifOtpCtrlPartitionSecret2, &digest));
    LOG_INFO("OTP partition locked. Digest: %x-%x", ((uint32_t *)&digest)[0],
             ((uint32_t *)&digest)[1]);
    return;
  }
  CHECK_STATUS_OK(
      otp_ctrl_testutils_lock_partition(otp, kDifOtpCtrlPartitionSecret2, 0));
}

bool test_main(void) {
  status_t result = OK_STATUS();
  dif_rstmgr_t rstmgr;
  dif_rstmgr_reset_info_bitfield_t info;

  lifecycle_state_t lc_state = lifecycle_state_get();
  CHECK(lc_state == kLcStateRma || lc_state == kLcStateDev ||
            lc_state == kLcStateProd || lc_state == kLcStateProdEnd,
        "The test is configured to run in RMA mode.");

  CHECK_DIF_OK(dif_rstmgr_init(
      mmio_region_from_addr(TOP_EARLGREY_RSTMGR_AON_BASE_ADDR), &rstmgr));
  info = rstmgr_testutils_reason_get();

  dif_otp_ctrl_t otp;
  CHECK_DIF_OK(dif_otp_ctrl_init(
      mmio_region_from_addr(TOP_EARLGREY_OTP_CTRL_CORE_BASE_ADDR), &otp));

  if (info & kDifRstmgrResetInfoPor) {
    LOG_INFO("Powered up for the first time, program flash");
    keymgr_flash_otp_init(&otp);

    // Issue and wait for reset.
    rstmgr_testutils_reason_clear();
    CHECK_DIF_OK(dif_rstmgr_software_device_reset(&rstmgr));
    wait_for_interrupt();
  } else if (info == kDifRstmgrResetInfoSw) {
    LOG_INFO("Powered up for the second time, actuate keymgr");

    sec_mmio_init();

    EXECUTE_TEST(result, benchmark);
    return status_ok(result);
  } else {
    LOG_FATAL("Unexpected reset reason unexpected: %08x", info);
  }
  return status_ok(result);
}
