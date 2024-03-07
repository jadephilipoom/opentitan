// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/status.h"
#include "sw/device/lib/crypto/drivers/entropy.h"
#include "sw/device/lib/testing/json/provisioning_data.h"
#include "sw/device/lib/testing/profile.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/silicon_creator/lib/drivers/flash_ctrl.h"
#include "sw/device/silicon_creator/lib/attestation.h"
#include "sw/device/silicon_creator/lib/otbn_boot_services.h"

OTTF_DEFINE_TEST_CONFIG();

// Copied from sw/device/silicon_creator/manuf/skus/earlgrey_a0/sival_bringup/ft_personalize_3.c
static const flash_ctrl_perms_t kCertificateFlashInfoPerms = {
    .read = kMultiBitBool4True,
    .write = kMultiBitBool4True,
    .erase = kMultiBitBool4True,
};

// Copied from sw/device/silicon_creator/manuf/skus/earlgrey_a0/sival_bringup/ft_personalize_3.c
static const flash_ctrl_cfg_t kCertificateFlashInfoCfg = {
    .scrambling = kMultiBitBool4True,
    .ecc = kMultiBitBool4True,
    .he = kMultiBitBool4False,
};

// Copied from sw/device/silicon_creator/manuf/skus/earlgrey_a0/sival_bringup/ft_personalize_3.c
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
  // The following code is modelled from sw/device/silicon_creator/manuf/skus/earlgrey_a0/sival_bringup/ft_personalize_3.c, with benchmarks added.
  uint64_t t_start;

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

  // Load OTBN attestation keygen program.
  t_start = profile_start();
  TRY(otbn_boot_app_load());
  profile_end_and_print(t_start, "Load OTBN boot app");

  // Generate UDS keys and (TBS) cert.
  t_start = profile_start();
  TRY(dice_uds_cert_build(&in_data, &uds_pubkey_id,
                          out_data.uds_tbs_certificate,
                          &out_data.uds_tbs_certificate_size));
  profile_end_and_print(t_start, "UDS cert build");
  t_start = profile_start();
  TRY(flash_ctrl_info_erase(&kFlashCtrlInfoPageUdsCertificate,
                            kFlashCtrlEraseTypePage));
  TRY(flash_ctrl_info_write(
      &kFlashCtrlInfoPageUdsCertificate,
      kFlashInfoFieldUdsCertificate.byte_offset,
      out_data.uds_tbs_certificate_size / sizeof(uint32_t),
      out_data.uds_tbs_certificate));
  profile_end_and_print(t_start, "UDS cert write");
  return OK_STATUS();
}

bool test_main(void) {
  status_t result = OK_STATUS();
  CHECK_STATUS_OK(peripheral_handles_init());
  EXECUTE_TEST(result, benchmark);
  return status_ok(result);
}
