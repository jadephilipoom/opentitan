// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_TESTS_CRYPTO_OTCRYPTO_INTERFACE_H_
#define OPENTITAN_SW_DEVICE_TESTS_CRYPTO_OTCRYPTO_INTERFACE_H_

#include "sw/device/lib/crypto/include/otcrypto.h"

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

/**
 * Function pointers to the OpenTitan cryptography library.
 */
typedef struct otcrypto_interface_t {
  // Key utilities
  otcrypto_status_t (*symmetric_keygen)(otcrypto_const_byte_buf_t,
                                        otcrypto_blinded_key_t *);
  otcrypto_status_t (*hw_backed_key)(uint32_t, const uint32_t salt[7],
                                     otcrypto_blinded_key_t *);
  otcrypto_status_t (*aes_kwp_wrapped_len)(const otcrypto_key_config_t,
                                           size_t *);
  otcrypto_status_t (*aes_kwp_wrap)(const otcrypto_blinded_key_t *,
                                    const otcrypto_blinded_key_t *,
                                    otcrypto_word32_buf_t);
  otcrypto_status_t (*aes_kwp_unwrap)(otcrypto_const_word32_buf_t,
                                      const otcrypto_blinded_key_t *,
                                      hardened_bool_t *,
                                      otcrypto_blinded_key_t *);
  otcrypto_status_t (*import_blinded_key)(
      const otcrypto_const_word32_buf_t key_share0,
      const otcrypto_const_word32_buf_t key_share1, otcrypto_blinded_key_t *);
  otcrypto_status_t (*export_blinded_key)(const otcrypto_blinded_key_t,
                                          otcrypto_word32_buf_t key_share0,
                                          otcrypto_word32_buf_t key_share1);

  // AES
  otcrypto_status_t (*aes)(const otcrypto_blinded_key_t *,
                           otcrypto_word32_buf_t, otcrypto_aes_mode_t,
                           otcrypto_aes_operation_t, otcrypto_const_byte_buf_t,
                           otcrypto_aes_padding_t, otcrypto_byte_buf_t);
  otcrypto_status_t (*aes_padded_plaintext_length)(size_t,
                                                   otcrypto_aes_padding_t,
                                                   size_t *);

  // AES-GCM
  otcrypto_status_t (*aes_gcm_encrypt)(
      const otcrypto_blinded_key_t *, otcrypto_const_byte_buf_t,
      otcrypto_const_word32_buf_t, otcrypto_const_byte_buf_t,
      otcrypto_aes_gcm_tag_len_t, otcrypto_byte_buf_t, otcrypto_word32_buf_t);
  otcrypto_status_t (*aes_gcm_decrypt)(const otcrypto_blinded_key_t *,
                                       otcrypto_const_byte_buf_t,
                                       otcrypto_const_word32_buf_t,
                                       otcrypto_const_byte_buf_t,
                                       otcrypto_aes_gcm_tag_len_t,
                                       otcrypto_const_word32_buf_t,
                                       otcrypto_byte_buf_t, hardened_bool_t *);
  otcrypto_status_t (*aes_gcm_encrypt_init)(const otcrypto_blinded_key_t *,
                                            otcrypto_const_word32_buf_t,
                                            otcrypto_aes_gcm_context_t *);
  otcrypto_status_t (*aes_gcm_decrypt_init)(const otcrypto_blinded_key_t *,
                                            otcrypto_const_word32_buf_t,
                                            otcrypto_aes_gcm_context_t *);
  otcrypto_status_t (*aes_gcm_update_aad)(otcrypto_aes_gcm_context_t *,
                                          otcrypto_const_byte_buf_t);
  otcrypto_status_t (*aes_gcm_update_encrypted_data)(
      otcrypto_aes_gcm_context_t *, otcrypto_const_byte_buf_t,
      otcrypto_byte_buf_t, size_t *);
  otcrypto_status_t (*aes_gcm_encrypt_final)(otcrypto_aes_gcm_context_t *,
                                             otcrypto_aes_gcm_tag_len_t,
                                             otcrypto_byte_buf_t, size_t *,
                                             otcrypto_word32_buf_t);
  otcrypto_status_t (*aes_gcm_decrypt_final)(otcrypto_aes_gcm_context_t *,
                                             otcrypto_const_word32_buf_t,
                                             otcrypto_aes_gcm_tag_len_t,
                                             otcrypto_byte_buf_t, size_t *,
                                             hardened_bool_t *);

  // DRBG
  otcrypto_status_t (*drbg_instantiate)(otcrypto_const_byte_buf_t);
  otcrypto_status_t (*drbg_reseed)(otcrypto_const_byte_buf_t);
  otcrypto_status_t (*drbg_manual_instantiate)(otcrypto_const_byte_buf_t,
                                               otcrypto_const_byte_buf_t);
  otcrypto_status_t (*drbg_manual_reseed)(otcrypto_const_byte_buf_t,
                                          otcrypto_const_byte_buf_t);
  otcrypto_status_t (*drbg_generate)(otcrypto_const_byte_buf_t,
                                     otcrypto_word32_buf_t);
  otcrypto_status_t (*drbg_manual_generate)(otcrypto_const_byte_buf_t,
                                            otcrypto_word32_buf_t);
  otcrypto_status_t (*drbg_uninstantiate)(void);

  // HKDF
  otcrypto_status_t (*kdf_hkdf)(const otcrypto_blinded_key_t,
                                otcrypto_const_byte_buf_t,
                                otcrypto_const_byte_buf_t,
                                otcrypto_blinded_key_t *);
  otcrypto_status_t (*kdf_hkdf_extract)(const otcrypto_blinded_key_t,
                                        otcrypto_const_byte_buf_t,
                                        otcrypto_blinded_key_t *);
  otcrypto_status_t (*kdf_hkdf_expand)(const otcrypto_blinded_key_t,
                                       otcrypto_const_byte_buf_t,
                                       otcrypto_blinded_key_t *);

  // HMAC
  otcrypto_status_t (*hmac)(const otcrypto_blinded_key_t *,
                            otcrypto_const_byte_buf_t, otcrypto_word32_buf_t);
  otcrypto_status_t (*hmac_init)(otcrypto_hmac_context_t *,
                                 const otcrypto_blinded_key_t *);
  otcrypto_status_t (*hmac_update)(otcrypto_hmac_context_t *const,
                                   otcrypto_const_byte_buf_t);
  otcrypto_status_t (*hmac_final)(otcrypto_hmac_context_t *const,
                                  otcrypto_word32_buf_t);

  // KDF-CTR
  otcrypto_status_t (*kdf_hmac_ctr)(const otcrypto_blinded_key_t,
                                    const otcrypto_const_byte_buf_t,
                                    const otcrypto_const_byte_buf_t, size_t,
                                    otcrypto_blinded_key_t *);

  // KMAC
  otcrypto_status_t (*kmac)(const otcrypto_blinded_key_t *,
                            otcrypto_const_byte_buf_t, otcrypto_kmac_mode_t,
                            otcrypto_const_byte_buf_t, size_t,
                            otcrypto_word32_buf_t);

  // KMAC-KDF
  otcrypto_status_t (*kdf_kmac)(const otcrypto_blinded_key_t,
                                otcrypto_kmac_mode_t,
                                const otcrypto_const_byte_buf_t,
                                const otcrypto_const_byte_buf_t, size_t,
                                otcrypto_blinded_key_t *);

  // Hash functions
  otcrypto_status_t (*hash)(otcrypto_const_byte_buf_t, otcrypto_hash_digest_t);
  otcrypto_status_t (*hash_init)(otcrypto_hash_context_t *,
                                 otcrypto_hash_mode_t);
  otcrypto_status_t (*hash_update)(otcrypto_hash_context_t *,
                                   otcrypto_const_byte_buf_t);
  otcrypto_status_t (*hash_final)(otcrypto_hash_context_t *,
                                  otcrypto_hash_digest_t);

  // Extendable-output functions.
  otcrypto_status_t (*xof_shake)(otcrypto_const_byte_buf_t,
                                 otcrypto_hash_digest_t);
  otcrypto_status_t (*xof_cshake)(otcrypto_const_byte_buf_t,
                                  otcrypto_const_byte_buf_t,
                                  otcrypto_const_byte_buf_t,
                                  otcrypto_hash_digest_t);

  // ED25519
  otcrypto_status_t (*ed25519_keygen)(otcrypto_blinded_key_t *,
                                      otcrypto_unblinded_key_t *);
  otcrypto_status_t (*ed25519_sign)(const otcrypto_blinded_key_t *,
                                    otcrypto_const_byte_buf_t,
                                    otcrypto_eddsa_sign_mode_t,
                                    otcrypto_word32_buf_t);
  otcrypto_status_t (*ed25519_verify)(const otcrypto_unblinded_key_t *,
                                      otcrypto_const_byte_buf_t,
                                      otcrypto_eddsa_sign_mode_t,
                                      otcrypto_const_word32_buf_t,
                                      hardened_bool_t *);
  otcrypto_status_t (*ed25519_keygen_async_start)(
      const otcrypto_blinded_key_t *);
  otcrypto_status_t (*ed25519_keygen_async_finalize)(
      otcrypto_blinded_key_t *, otcrypto_unblinded_key_t *);
  otcrypto_status_t (*ed25519_sign_async_start)(const otcrypto_blinded_key_t *,
                                                otcrypto_const_byte_buf_t,
                                                otcrypto_eddsa_sign_mode_t,
                                                otcrypto_word32_buf_t);
  otcrypto_status_t (*ed25519_sign_async_finalize)(otcrypto_word32_buf_t);
  otcrypto_status_t (*ed25519_verify_async_start)(
      const otcrypto_unblinded_key_t *, otcrypto_const_byte_buf_t,
      otcrypto_eddsa_sign_mode_t, otcrypto_const_word32_buf_t);
  otcrypto_status_t (*ed25519_verify_async_finalize)(hardened_bool_t *);

  // X25519
  otcrypto_status_t (*x25519_keygen)(otcrypto_blinded_key_t *,
                                     otcrypto_unblinded_key_t *);
  otcrypto_status_t (*x25519)(const otcrypto_blinded_key_t *,
                              const otcrypto_unblinded_key_t *,
                              otcrypto_blinded_key_t *);
  otcrypto_status_t (*x25519_keygen_async_start)(
      const otcrypto_blinded_key_t *);
  otcrypto_status_t (*x25519_keygen_async_finalize)(otcrypto_blinded_key_t *,
                                                    otcrypto_unblinded_key_t *);
  otcrypto_status_t (*x25519_async_start)(const otcrypto_blinded_key_t *,
                                          const otcrypto_unblinded_key_t *);
  otcrypto_status_t (*x25519_async_finalize)(otcrypto_blinded_key_t *);

  // RSA
  otcrypto_status_t (*rsa_keygen)(otcrypto_rsa_size_t,
                                  otcrypto_unblinded_key_t *,
                                  otcrypto_blinded_key_t *);
  otcrypto_status_t (*rsa_public_key_construct)(otcrypto_rsa_size_t,
                                                otcrypto_const_word32_buf_t,
                                                uint32_t,
                                                otcrypto_unblinded_key_t *);
  otcrypto_status_t (*rsa_private_key_from_exponents)(
      otcrypto_rsa_size_t, otcrypto_const_word32_buf_t, uint32_t,
      otcrypto_const_word32_buf_t, otcrypto_const_word32_buf_t,
      otcrypto_blinded_key_t *);
  otcrypto_status_t (*rsa_keypair_from_cofactor)(
      otcrypto_rsa_size_t, otcrypto_const_word32_buf_t, uint32_t,
      otcrypto_const_word32_buf_t, otcrypto_const_word32_buf_t,
      otcrypto_unblinded_key_t *, otcrypto_blinded_key_t *);
  otcrypto_status_t (*rsa_sign)(const otcrypto_blinded_key_t *,
                                const otcrypto_hash_digest_t,
                                otcrypto_rsa_padding_t, otcrypto_word32_buf_t);
  otcrypto_status_t (*rsa_verify)(const otcrypto_unblinded_key_t *,
                                  const otcrypto_hash_digest_t,
                                  otcrypto_rsa_padding_t,
                                  otcrypto_const_word32_buf_t,
                                  hardened_bool_t *);
  otcrypto_status_t (*rsa_encrypt)(const otcrypto_unblinded_key_t *,
                                   const otcrypto_hash_mode_t,
                                   otcrypto_const_byte_buf_t,
                                   otcrypto_const_byte_buf_t,
                                   otcrypto_word32_buf_t);
  otcrypto_status_t (*rsa_decrypt)(const otcrypto_blinded_key_t *,
                                   const otcrypto_hash_mode_t,
                                   otcrypto_const_word32_buf_t,
                                   otcrypto_const_byte_buf_t,
                                   otcrypto_byte_buf_t, size_t *);
  otcrypto_status_t (*rsa_keygen_async_start)(otcrypto_rsa_size_t);
  otcrypto_status_t (*rsa_keygen_async_finalize)(otcrypto_unblinded_key_t *,
                                                 otcrypto_blinded_key_t *);
  otcrypto_status_t (*rsa_keypair_from_cofactor_async_start)(
      otcrypto_rsa_size_t, otcrypto_const_word32_buf_t, uint32_t,
      otcrypto_const_word32_buf_t cofactor_share0,
      otcrypto_const_word32_buf_t cofactor_share1);
  otcrypto_status_t (*rsa_keypair_from_cofactor_async_finalize)(
      otcrypto_unblinded_key_t *, otcrypto_blinded_key_t *);
  otcrypto_status_t (*rsa_sign_async_start)(const otcrypto_blinded_key_t *,
                                            const otcrypto_hash_digest_t,
                                            otcrypto_rsa_padding_t);
  otcrypto_status_t (*rsa_sign_async_finalize)(otcrypto_word32_buf_t);
  otcrypto_status_t (*rsa_verify_async_start)(const otcrypto_unblinded_key_t *,
                                              otcrypto_const_word32_buf_t);
  otcrypto_status_t (*rsa_verify_async_finalize)(const otcrypto_hash_digest_t,
                                                 otcrypto_rsa_padding_t,
                                                 hardened_bool_t *);
  otcrypto_status_t (*rsa_encrypt_async_start)(const otcrypto_unblinded_key_t *,
                                               const otcrypto_hash_mode_t,
                                               otcrypto_const_byte_buf_t,
                                               otcrypto_const_byte_buf_t);
  otcrypto_status_t (*rsa_encrypt_async_finalize)(otcrypto_word32_buf_t);
  otcrypto_status_t (*rsa_decrypt_async_start)(const otcrypto_blinded_key_t *,
                                               otcrypto_const_word32_buf_t);
  otcrypto_status_t (*rsa_decrypt_async_finalize)(const otcrypto_hash_mode_t,
                                                  otcrypto_const_byte_buf_t,
                                                  otcrypto_byte_buf_t,
                                                  size_t *);
  // ECC
  otcrypto_status_t (*ecdsa_keygen)(const otcrypto_ecc_curve_t *,
                                    otcrypto_blinded_key_t *,
                                    otcrypto_unblinded_key_t *);
  otcrypto_status_t (*ecdsa_sign)(const otcrypto_blinded_key_t *,
                                  const otcrypto_hash_digest_t,
                                  const otcrypto_ecc_curve_t *,
                                  otcrypto_word32_buf_t);
  otcrypto_status_t (*ecdsa_verify)(const otcrypto_unblinded_key_t *,
                                    const otcrypto_hash_digest_t,
                                    otcrypto_const_word32_buf_t,
                                    const otcrypto_ecc_curve_t *,
                                    hardened_bool_t *);
  otcrypto_status_t (*ecdh_keygen)(const otcrypto_ecc_curve_t *,
                                   otcrypto_blinded_key_t *,
                                   otcrypto_unblinded_key_t *);
  otcrypto_status_t (*ecdh)(const otcrypto_blinded_key_t *,
                            const otcrypto_unblinded_key_t *,
                            const otcrypto_ecc_curve_t *,
                            otcrypto_blinded_key_t *);
  otcrypto_status_t (*ecdsa_keygen_async_start)(const otcrypto_ecc_curve_t *,
                                                const otcrypto_blinded_key_t *);
  otcrypto_status_t (*ecdsa_keygen_async_finalize)(const otcrypto_ecc_curve_t *,
                                                   otcrypto_blinded_key_t *,
                                                   otcrypto_unblinded_key_t *);
  otcrypto_status_t (*ecdsa_sign_async_start)(const otcrypto_blinded_key_t *,
                                              const otcrypto_hash_digest_t,
                                              const otcrypto_ecc_curve_t *);
  otcrypto_status_t (*ecdsa_sign_async_finalize)(const otcrypto_ecc_curve_t *,
                                                 otcrypto_word32_buf_t);
  otcrypto_status_t (*ecdsa_verify_async_start)(
      const otcrypto_unblinded_key_t *, const otcrypto_hash_digest_t,
      otcrypto_const_word32_buf_t, const otcrypto_ecc_curve_t *);
  otcrypto_status_t (*ecdsa_verify_async_finalize)(const otcrypto_ecc_curve_t *,
                                                   otcrypto_const_word32_buf_t,
                                                   hardened_bool_t *);
  otcrypto_status_t (*ecdh_keygen_async_start)(const otcrypto_ecc_curve_t *,
                                               const otcrypto_blinded_key_t *);
  otcrypto_status_t (*ecdh_keygen_async_finalize)(const otcrypto_ecc_curve_t *,
                                                  otcrypto_blinded_key_t *,
                                                  otcrypto_unblinded_key_t *);
  otcrypto_status_t (*ecdh_async_start)(const otcrypto_blinded_key_t *,
                                        const otcrypto_unblinded_key_t *,
                                        const otcrypto_ecc_curve_t *);
  otcrypto_status_t (*ecdh_async_finalize)(const otcrypto_ecc_curve_t *,
                                           otcrypto_blinded_key_t *);

} otcrypto_interface_t;

extern const otcrypto_interface_t otcrypto;

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  // OPENTITAN_SW_DEVICE_TESTS_CRYPTO_OTCRYPTO_INTERFACE_H_
