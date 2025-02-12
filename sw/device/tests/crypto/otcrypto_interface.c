// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/tests/crypto/otcrypto_interface.h"

const otcrypto_interface_t otcrypto = {
    // Symmetric key generation.
    .symmetric_keygen = &otcrypto_symmetric_keygen,
    .hw_backed_key = &otcrypto_hw_backed_key,

    // Secret key import/export.
    .import_blinded_key = &otcrypto_import_blinded_key,
    .export_blinded_key = &otcrypto_export_blinded_key,

    // Key wrapping.
    .aes_kwp_wrapped_len = &otcrypto_aes_kwp_wrapped_len,
    .aes_kwp_wrap = &otcrypto_aes_kwp_wrap,
    .aes_kwp_unwrap = &otcrypto_aes_kwp_unwrap,

    // AES
    .aes = &otcrypto_aes,
    .aes_padded_plaintext_length = &otcrypto_aes_padded_plaintext_length,

    // AES-GCM (one-shot).
    .aes_gcm_encrypt = &otcrypto_aes_gcm_encrypt,
    .aes_gcm_decrypt = &otcrypto_aes_gcm_decrypt,

    // AES-GCM (streaming).
    .aes_gcm_encrypt_init = &otcrypto_aes_gcm_encrypt_init,
    .aes_gcm_decrypt_init = &otcrypto_aes_gcm_decrypt_init,
    .aes_gcm_update_aad = &otcrypto_aes_gcm_update_aad,
    .aes_gcm_update_encrypted_data = &otcrypto_aes_gcm_update_encrypted_data,
    .aes_gcm_encrypt_final = &otcrypto_aes_gcm_encrypt_final,
    .aes_gcm_decrypt_final = &otcrypto_aes_gcm_decrypt_final,

    // DRBG
    .drbg_instantiate = &otcrypto_drbg_instantiate,
    .drbg_reseed = &otcrypto_drbg_reseed,
    .drbg_generate = &otcrypto_drbg_generate,
    .drbg_uninstantiate = &otcrypto_drbg_uninstantiate,

    // Manual DRBG (user-supplied entropy, for example for known-answer
    // testing).
    .drbg_manual_instantiate = &otcrypto_drbg_manual_instantiate,
    .drbg_manual_reseed = &otcrypto_drbg_manual_reseed,
    .drbg_manual_generate = &otcrypto_drbg_manual_generate,

    // HKDF
    .kdf_hkdf = &otcrypto_kdf_hkdf,
    .kdf_hkdf_extract = &otcrypto_kdf_hkdf_extract,
    .kdf_hkdf_expand = &otcrypto_kdf_hkdf_expand,

    // HMAC (one-shot).
    .hmac = &otcrypto_hmac,

    // HMAC (streaming).
    .hmac_init = &otcrypto_hmac_init,
    .hmac_update = &otcrypto_hmac_update,
    .hmac_final = &otcrypto_hmac_final,

    // KDF-CTR with HMAC
    .kdf_hmac_ctr = &otcrypto_kdf_hmac_ctr,

    // KMAC
    .kmac = &otcrypto_kmac,

    // KMAC-KDF
    .kdf_kmac = &otcrypto_kdf_kmac,

    // Hash (one-shot).
    .hash = &otcrypto_hash,

    // Hash (streaming).
    .hash_init = &otcrypto_hash_init,
    .hash_update = &otcrypto_hash_update,
    .hash_final = &otcrypto_hash_final,

    // (c)SHAKE
    .xof_shake = &otcrypto_xof_shake,
    .xof_cshake = &otcrypto_xof_cshake,

    // ECDSA (blocking).
    .ecdsa_keygen = &otcrypto_ecdsa_keygen,
    .ecdsa_sign = &otcrypto_ecdsa_sign,
    .ecdsa_verify = &otcrypto_ecdsa_verify,

    // ECDSA (async).
    .ecdsa_keygen_async_start = &otcrypto_ecdsa_keygen_async_start,
    .ecdsa_keygen_async_finalize = &otcrypto_ecdsa_keygen_async_finalize,
    .ecdsa_sign_async_start = &otcrypto_ecdsa_sign_async_start,
    .ecdsa_sign_async_finalize = &otcrypto_ecdsa_sign_async_finalize,
    .ecdsa_verify_async_start = &otcrypto_ecdsa_verify_async_start,
    .ecdsa_verify_async_finalize = &otcrypto_ecdsa_verify_async_finalize,

    // ECDH (blocking).
    .ecdh_keygen = &otcrypto_ecdh_keygen,
    .ecdh = &otcrypto_ecdh,

    // ECDH (async).
    .ecdh_keygen_async_start = &otcrypto_ecdh_keygen_async_start,
    .ecdh_keygen_async_finalize = &otcrypto_ecdh_keygen_async_finalize,
    .ecdh_async_start = &otcrypto_ecdh_async_start,
    .ecdh_async_finalize = &otcrypto_ecdh_async_finalize,

    // Ed25519 (blocking).
    .ed25519_keygen = &otcrypto_ed25519_keygen,
    .ed25519_sign = &otcrypto_ed25519_sign,
    .ed25519_verify = &otcrypto_ed25519_verify,

    // Ed25519 (async).
    .ed25519_keygen_async_start = &otcrypto_ed25519_keygen_async_start,
    .ed25519_keygen_async_finalize = &otcrypto_ed25519_keygen_async_finalize,
    .ed25519_sign_async_start = &otcrypto_ed25519_sign_async_start,
    .ed25519_sign_async_finalize = &otcrypto_ed25519_sign_async_finalize,
    .ed25519_verify_async_start = &otcrypto_ed25519_verify_async_start,
    .ed25519_verify_async_finalize = &otcrypto_ed25519_verify_async_finalize,

    // X25519 (blocking).
    .x25519_keygen = &otcrypto_x25519_keygen,
    .x25519 = &otcrypto_x25519,

    // X25519 (async).
    .x25519_keygen_async_start = &otcrypto_x25519_keygen_async_start,
    .x25519_keygen_async_finalize = &otcrypto_x25519_keygen_async_finalize,
    .x25519_async_start = &otcrypto_x25519_async_start,
    .x25519_async_finalize = &otcrypto_x25519_async_finalize,

    // RSA key construction.
    .rsa_public_key_construct = &otcrypto_rsa_public_key_construct,
    .rsa_private_key_from_exponents = &otcrypto_rsa_private_key_from_exponents,

    // RSA key generation (blocking).
    .rsa_keygen = &otcrypto_rsa_keygen,
    .rsa_keypair_from_cofactor = &otcrypto_rsa_keypair_from_cofactor,

    // RSA key generation (async).
    .rsa_keygen_async_start = &otcrypto_rsa_keygen_async_start,
    .rsa_keygen_async_finalize = &otcrypto_rsa_keygen_async_finalize,
    .rsa_keypair_from_cofactor_async_start =
        &otcrypto_rsa_keypair_from_cofactor_async_start,
    .rsa_keypair_from_cofactor_async_finalize =
        &otcrypto_rsa_keypair_from_cofactor_async_finalize,

    // RSA signatures (blocking).
    .rsa_sign = &otcrypto_rsa_sign,
    .rsa_verify = &otcrypto_rsa_verify,

    // RSA signatures (async).
    .rsa_sign_async_start = &otcrypto_rsa_sign_async_start,
    .rsa_sign_async_finalize = &otcrypto_rsa_sign_async_finalize,
    .rsa_verify_async_start = &otcrypto_rsa_verify_async_start,
    .rsa_verify_async_finalize = &otcrypto_rsa_verify_async_finalize,

    // RSA encryption (blocking).
    .rsa_encrypt = &otcrypto_rsa_encrypt,
    .rsa_decrypt = &otcrypto_rsa_decrypt,

    // RSA encryption (async).
    .rsa_encrypt_async_start = &otcrypto_rsa_encrypt_async_start,
    .rsa_encrypt_async_finalize = &otcrypto_rsa_encrypt_async_finalize,
    .rsa_decrypt_async_start = &otcrypto_rsa_decrypt_async_start,
    .rsa_decrypt_async_finalize = &otcrypto_rsa_decrypt_async_finalize,

};
