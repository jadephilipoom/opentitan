// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/base/hardened.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/crypto/drivers/hmac.h"
#include "sw/device/lib/crypto/drivers/otbn.h"
#include "sw/device/lib/crypto/rsa_3072/rsa_3072_verify.h"
#include "sw/device/lib/crypto/api.h"

/**
 * Call the specialized RSA-3072 implementation.
 *
 * This routine does not check that the modulus is 3072 bits. The only padding
 * mode supported is PKCS, and the only hash mode supported is SHA2-256, so
 * these are not taken as parameters.
 *
 * @param n Public key modulus.
 * @param e Public key exponent.
 * @param input_message Input message to be verified
 * @param signature Signature to be verified
 * @param verification_result Result of signature verification
 * @return crypto_status_t Return status
 */
crypto_status_t specialized_rsa_3072_verify(crypto_unblinded_key_t *n, uint32_t exponent,
                           const crypto_uint8_buf_t input_message,
                           crypto_uint8_buf_t signature,
                           verification_status_t *verification_result) {
  // Copy public key data to specialized struct.
  rsa_3072_public_key_t public_key;
  memcpy(public_key.n.data, n->key, kRsa3072NumBytes);
  public_key.e = exponent;

  // Encode the message.
  rsa_3072_int_t encoded_message;
  hmac_error_t hmac_err = rsa_3072_encode_sha256(input_message.data, input_message.len,
      &encoded_message);
  if (hmac_err != kHmacOk) {
    return kCryptoStatusInternalError;
  }

  // Compute Montgomery constants for this key.
  rsa_3072_constants_t constants;
  otbn_error_t otbn_err = rsa_3072_compute_constants(&public_key, &constants);
  if (otbn_err != kOtbnErrorOk) {
    return kCryptoStatusInternalError;
  }

  // Copy signature into specialized struct.
  rsa_3072_int_t sig;
  memcpy(sig.data, signature.data, kRsa3072NumBytes);

  // Call the specialized verify procedure.
  hardened_bool_t result;
  otbn_err = rsa_3072_verify(&sig, &encoded_message, &public_key, &constants, &result);
  if (otbn_err != kOtbnErrorOk) {
    // TODO: if the signature is too large (> modulus), OTBN will return an
    // InvalidArgument error. In this case, it might make more sense to return
    // kCryptoStatusIncorrectInput; perhaps this check should be separate.
    return kCryptoStatusInternalError;
  }

  if (result == kHardenedBoolTrue) {
    *verification_result = kVerificationStatusPass;
  } else {
    *verification_result = kVerificationStatusFail;
  }

  return kCryptoStatusOK;
}

crypto_status_t rsa_verify(crypto_unblinded_key_t *n, crypto_unblinded_key_t *e,
                           const crypto_uint8_buf_t input_message,
                           rsa_padding_t padding_mode, rsa_hash_t hash_mode,
                           crypto_uint8_buf_t signature,
                           verification_status_t *verification_result) {
  // Initialize result so early errors (e.g. invalid input) always produce
  // verification failure.
  *verification_result = kVerificationStatusFail;

  // TODO: Verify checksum of the input key.
  // TODO: Harden the checks below.

  // Check the key mode.
  if (n->key_mode != kKeyModeRsaSign || e->key_mode != kKeyModeRsaSign) {
    return kCryptoStatusIncorrectInput;
  }

  // Check that the length of the signature matches the length of the modulus.
  // The signature length is in bytes and the key length is in 32-bit words.
  if (signature.len != n->key_length * sizeof(uint32_t)) {
    return kCryptoStatusIncorrectInput;
  }

  // Exponent is expected to fit in a single word.
  if (e->key_length != 1) {
    return kCryptoStatusIncorrectInput;
  }
  uint32_t exponent = e->key[0];

  // Check if the parameters match a specialized implementation.
  if (n->key_length == kRsa3072NumWords
      && exponent == 65537
      && padding_mode == kRsaPaddingPkcs
      && hash_mode == kRsaHashSha256) {
    return specialized_rsa_3072_verify(n, exponent, input_message, signature, verification_result);
  }

  // If no specialized implementation matches, use the generic implementation.
  // TODO: generic implementation does not yet exist.
  return kCryptoStatusIncorrectInput;
}
