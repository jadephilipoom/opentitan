// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/crypto/ecdsa_p256/ecdsa_p256.h"

#include "sw/device/lib/base/hardened.h"
#include "sw/device/lib/runtime/otbn.h"

OTBN_DECLARE_APP_SYMBOLS(p256_ecdsa);       // The OTBN ECDSA/P-256 app.
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, mode);  // ECDSA mode (sign or verify).
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, msg);   // Message digest.
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, r);     // The signature scalar R.
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, s);     // The signature scalar S.
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, x);     // The public key x-coordinate.
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, y);     // The public key y-coordinate.
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, d);     // The private key scalar d.
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, x_r);   // Verification result.

/* Declare symbols for DMEM pointers */
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, dptr_msg);
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, dptr_r);
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, dptr_s);
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, dptr_x);
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, dptr_y);
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, dptr_d);
OTBN_DECLARE_PTR_SYMBOL(p256_ecdsa, dptr_x_r);

static const otbn_app_t kOtbnAppEcdsa = OTBN_APP_T_INIT(p256_ecdsa);
static const otbn_ptr_t kOtbnVarEcdsaMode = OTBN_PTR_T_INIT(p256_ecdsa, mode);
static const otbn_ptr_t kOtbnVarEcdsaMsg = OTBN_PTR_T_INIT(p256_ecdsa, msg);
static const otbn_ptr_t kOtbnVarEcdsaR = OTBN_PTR_T_INIT(p256_ecdsa, r);
static const otbn_ptr_t kOtbnVarEcdsaS = OTBN_PTR_T_INIT(p256_ecdsa, s);
static const otbn_ptr_t kOtbnVarEcdsaX = OTBN_PTR_T_INIT(p256_ecdsa, x);
static const otbn_ptr_t kOtbnVarEcdsaY = OTBN_PTR_T_INIT(p256_ecdsa, y);
static const otbn_ptr_t kOtbnVarEcdsaD = OTBN_PTR_T_INIT(p256_ecdsa, d);
static const otbn_ptr_t kOtbnVarEcdsaXr = OTBN_PTR_T_INIT(p256_ecdsa, x_r);
static const otbn_ptr_t kOtbnVarEcdsaDptrMsg =
    OTBN_PTR_T_INIT(p256_ecdsa, dptr_msg);
static const otbn_ptr_t kOtbnVarEcdsaDptrR =
    OTBN_PTR_T_INIT(p256_ecdsa, dptr_r);
static const otbn_ptr_t kOtbnVarEcdsaDptrS =
    OTBN_PTR_T_INIT(p256_ecdsa, dptr_s);
static const otbn_ptr_t kOtbnVarEcdsaDptrX =
    OTBN_PTR_T_INIT(p256_ecdsa, dptr_x);
static const otbn_ptr_t kOtbnVarEcdsaDptrY =
    OTBN_PTR_T_INIT(p256_ecdsa, dptr_y);
static const otbn_ptr_t kOtbnVarEcdsaDptrD =
    OTBN_PTR_T_INIT(p256_ecdsa, dptr_d);
static const otbn_ptr_t kOtbnVarEcdsaDptrXr =
    OTBN_PTR_T_INIT(p256_ecdsa, dptr_x_r);

/* Mode is represented by a single word, 1 for sign and 2 for verify */
static const uint32_t kOtbnEcdsaModeNumBytes = sizeof(uint32_t);
static const uint32_t kOtbnEcdsaModeSign = 1;
// static const uint32_t kOtbnEcdsaModeVerify = 2;

/**
 * Makes a single dptr in the P256 library point to where its value is stored.
 */
static otbn_result_t setup_data_pointer(otbn_t *otbn, const otbn_ptr_t dptr,
                                        const otbn_ptr_t value) {
  uint32_t value_dmem_addr;
  OTBN_RETURN_IF_ERROR(
      otbn_data_ptr_to_dmem_addr(otbn, value, &value_dmem_addr));
  OTBN_RETURN_IF_ERROR(
      otbn_copy_data_to_otbn(otbn, sizeof(uint32_t), &value_dmem_addr, dptr));
  return kOtbnOk;
}

/**
 * Sets up all data pointers used by the P256 library to point to DMEM.
 *
 * The ECDSA P256 OTBN library makes use of "named" data pointers as part of
 * its calling convention, which are exposed as symbol starting with `dptr_`.
 * The DMEM locations these pointers refer to is not mandated by the P256
 * calling convention; the values can be placed anywhere in OTBN DMEM.
 *
 * For convenience, `p256_ecdsa.s` pre-allocates space for the data values.
 *
 * This function makes the data pointers refer to the pre-allocated DMEM
 * regions to store the actual values.
 */
static otbn_result_t setup_data_pointers(otbn_t *otbn) {
  OTBN_RETURN_IF_ERROR(
      setup_data_pointer(otbn, kOtbnVarEcdsaDptrMsg, kOtbnVarEcdsaMsg));
  OTBN_RETURN_IF_ERROR(
      setup_data_pointer(otbn, kOtbnVarEcdsaDptrR, kOtbnVarEcdsaR));
  OTBN_RETURN_IF_ERROR(
      setup_data_pointer(otbn, kOtbnVarEcdsaDptrS, kOtbnVarEcdsaS));
  OTBN_RETURN_IF_ERROR(
      setup_data_pointer(otbn, kOtbnVarEcdsaDptrX, kOtbnVarEcdsaX));
  OTBN_RETURN_IF_ERROR(
      setup_data_pointer(otbn, kOtbnVarEcdsaDptrY, kOtbnVarEcdsaY));
  OTBN_RETURN_IF_ERROR(
      setup_data_pointer(otbn, kOtbnVarEcdsaDptrD, kOtbnVarEcdsaD));
  OTBN_RETURN_IF_ERROR(
      setup_data_pointer(otbn, kOtbnVarEcdsaDptrXr, kOtbnVarEcdsaXr));
  return kOtbnOk;
}

// TODO: This implementation waits while OTBN is processing; it should be
// modified to be non-blocking.
otbn_result_t ecdsa_p256_sign(otbn_t *otbn,
                              const ecdsa_p256_message_digest_t *digest,
                              const ecdsa_p256_private_key_t *private_key,
                              ecdsa_p256_signature_t *result) {
  // Load the ECDSA/P-256 app and set up data pointers
  OTBN_RETURN_IF_ERROR(otbn_load_app(otbn, kOtbnAppEcdsa));
  OTBN_RETURN_IF_ERROR(setup_data_pointers(otbn));

  // Set mode so start() will jump into p256_ecdsa_sign().
  OTBN_RETURN_IF_ERROR(otbn_copy_data_to_otbn(
      otbn, kOtbnEcdsaModeNumBytes, &kOtbnEcdsaModeSign, kOtbnVarEcdsaMode));

  // Set the message digest.
  OTBN_RETURN_IF_ERROR(otbn_copy_data_to_otbn(otbn, kP256ScalarNumBytes,
                                              digest->h, kOtbnVarEcdsaMsg));

  // Set the private key.
  OTBN_RETURN_IF_ERROR(otbn_copy_data_to_otbn(otbn, kP256ScalarNumBytes,
                                              private_key->d, kOtbnVarEcdsaD));

  // Start the OTBN routine.
  OTBN_RETURN_IF_ERROR(otbn_execute(otbn));

  // Spin here waiting for OTBN to complete.
  OTBN_RETURN_IF_ERROR(otbn_busy_wait_for_done(otbn));

  // Read signature R out of OTBN dmem.
  OTBN_RETURN_IF_ERROR(otbn_copy_data_from_otbn(otbn, kP256ScalarNumBytes,
                                                kOtbnVarEcdsaR, result->R));

  // Read signature S out of OTBN dmem.
  OTBN_RETURN_IF_ERROR(otbn_copy_data_from_otbn(otbn, kP256ScalarNumBytes,
                                                kOtbnVarEcdsaS, result->S));

  // TODO: try to verify the signature, and return an error if verification
  // fails.

  return kOtbnOk;
}

// TODO: This implementation waits while OTBN is processing; it should be
// modified to be non-blocking.
otbn_result_t ecdsa_p256_verify(otbn_t *otbn,
                                const ecdsa_p256_signature_t *signature,
                                const ecdsa_p256_message_digest_t *digest,
                                const ecdsa_p256_public_key_t *public_key,
                                hardened_bool_t *result) {
  // TODO: unimplemented
  *result = kHardenedBoolTrue;
  return kOtbnOk;
}
