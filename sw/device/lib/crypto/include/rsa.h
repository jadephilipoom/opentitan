// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_CRYPTO_INCLUDE_RSA_H_
#define OPENTITAN_SW_DEVICE_LIB_CRYPTO_INCLUDE_RSA_H_

#include "sw/device/lib/crypto/include/datatypes.h"

/**
 * @file
 * @brief RSA signature operations for the OpenTitan cryptography library.
 */

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

/**
 * Enum to define padding scheme for RSA data.
 *
 * Values are hardened.
 */
typedef enum rsa_padding {
  // Pads input data according to the PKCS#1 (v1.5) scheme.
  kRsaPaddingPkcs = 0x94e,
  // Pads input data according to the PKCS#1-PSS scheme.
  kRsaPaddingPss = 0x6b1,
} rsa_padding_t;

/**
 * Struct to handle the RSA private exponent and modulus.
 */
typedef struct rsa_private_key {
  // Unblinded key struct with RSA modulus.
  crypto_unblinded_key_t n;
  // Blinded key struct with RSA private exponent.
  crypto_blinded_key_t d;
} rsa_private_key_t;

/**
 * Enum to define possible lengths of RSA (public) keys.
 *
 * Values are hardened.
 */
typedef enum rsa_key_size {
  // 2048-bit RSA key.
  kRsaKeySize2048 = 0x5d1,
  // 3072-bit RSA key.
  kRsaKeySize3072 = 0xc35,
  // 4096-bit RSA key.
  kRsaKeySize4096 = 0x8da,
} rsa_key_size_t;

/**
 * Struct to handle the RSA public exponent and modulus.
 */
typedef struct rsa_public_key {
  // Unblinded key struct with RSA modulus.
  crypto_unblinded_key_t n;
  // Blinded key struct with RSA public exponent.
  crypto_unblinded_key_t e;
} rsa_public_key_t;

/**
 * Performs the RSA key generation.
 *
 * Computes RSA private key (d) and RSA public key exponent (e) and
 * modulus (n).
 *
 * The caller should allocate and partially populate all blinded and unblinded
 * key structs underneath `rsa_private_key` and `rsa_public_key`.
 *
 * For unblinded keys, this means setting the key mode, allocating a buffer for
 * the key material, and recording the length of the allocated buffer in
 * `key_length`. If the buffer size does not match expectations, this function
 * will return an error. RSA public key exponents should always have 32 bits (4
 * bytes) allocated for them.
 *
 * For blinded key structs, the caller should fully populate the key
 * configuration and allocate space for the keyblob. As for unblinded keys, the
 * caller should record the allocated buffer length and this function will
 * return an error if the keyblob length does not match expectations. The
 * keyblob should be twice the length of the key.
 *
 * The value in the `checksum` field of key structs is not checked here and
 * will be populated by the key generation function.
 *
 * @param required_key_len Requested key length.
 * @param[out] rsa_public_key Pointer to RSA public exponent struct.
 * @param[out] rsa_private_key Pointer to RSA private exponent struct.
 * @return Result of the RSA key generation.
 */
crypto_status_t otcrypto_rsa_keygen(rsa_key_size_t required_key_len,
                                    rsa_public_key_t *rsa_public_key,
                                    rsa_private_key_t *rsa_private_key);

/**
 * Constructs an RSA private key from the private exponent.
 *
 * The caller should fully populate the blinded key configuration and allocate
 * space for the keyblob, setting `config.key_length` and `keyblob_length`
 * accordingly. Use `otcrypto_rsa_private_key_length` to get the expected
 * lengths.
 *
 * If `check_key_validity` is true, then this routine will infer the two primes
 * p and q and and ensure they are both prime, within the allowed range,
 * relatively prime to the exponent, and not too close together. It will also
 * ensure that d and e meet RSA requirements as per FIPS 186-5.
 *
 * @param size RSA size parameter.
 * @param modulus RSA modulus (n).
 * @param e RSA public exponent.
 * @param d_share0 First share of the private exponent d.
 * @param d_share1 Second share of the private exponent d.
 * @param check_key_validity Whether to check that the key is valid.
 * @param[out] private_key Destination private key struct.
 * @return Result of the RSA key construction.
 */
crypto_status_t otcrypto_rsa_private_key_from_exponents(
    rsa_size_t size, crypto_const_word32_buf_t modulus, uint32_t e,
    crypto_const_word32_buf_t d_share0, crypto_const_word32_buf_t d_share1,
    hardened_bool_t check_key_validity, crypto_blinded_key_t *private_key);

/**
 * Constructs an RSA private key from two blinded primes.
 *
 * The caller should fully populate the blinded key configuration and allocate
 * space for the keyblob, setting `config.key_length` and `keyblob_length`
 * accordingly. Use `otcrypto_rsa_private_key_length` to get the expected
 * lengths.
 *
 * This routine will divide n by the provided prime factor to get the other
 * prime and derive the RSA private key from there. If `check_key_validity` is
 * true, then this routine will run primality tests on the two primes and also
 * ensure they are both within the allowed range, relatively prime to the
 * exponent, and not too close together.
 *
 * @param size RSA size parameter.
 * @param p_share0 First share of the blinded prime factor p.
 * @param p_share1 Second share of the blinded prime factor p.
 * @param q_share0 First share of the blinded prime factor q.
 * @param q_share1 Second share of the blinded prime factor q.
 * @param check_key_validity Whether to check that the key is valid.
 * @param[out] private_key Destination private key struct.
 * @return Result of the RSA key construction.
 */
crypto_status_t otcrypto_rsa_private_key_from_primes(
    rsa_size_t size, crypto_const_word32_buf_t p_share0,
    crypto_const_word32_buf_t p_share1, crypto_const_word32_buf_t q_share0,
    crypto_const_word32_buf_t q_share1, hardened_bool_t check_key_validity,
    crypto_blinded_key_t *private_key);

/**
 * Constructs an RSA private key from the modulus and one blinded prime.
 *
 * The caller should fully populate the blinded key configuration and allocate
 * space for the keyblob, setting `config.key_length` and `keyblob_length`
 * accordingly. Use `otcrypto_rsa_private_key_length` to get the expected
 * lengths.
 *
 * This routine will divide n by the provided prime factor to get the other
 * prime and derive the RSA private key from there. If `check_key_validity` is
 * true, then this routine will run primality tests on the two primes and also
 * ensure they are both within the allowed range, relatively prime to the
 * exponent, and not too close together.
 *
 * @param size RSA size parameter.
 * @param modulus RSA modulus (n).
 * @param prime_share0 First share of the blinded prime factor (p or q).
 * @param prime_share1 Second share of the blinded prime factor (p or q).
 * @param check_key_validity Whether to check that the key is valid.
 * @param[out] private_key Destination private key struct.
 * @return Result of the RSA key construction.
 */
crypto_status_t otcrypto_rsa_private_key_from_cofactor(
    rsa_size_t size, crypto_const_word32_buf_t modulus,
    crypto_const_word32_buf_t prime_share0,
    crypto_const_word32_buf_t prime_share1, hardened_bool_t check_key_validity,
    crypto_blinded_key_t *private_key);

/**
 * Computes the digital signature on the input message data.
 *
 * The caller should allocate space for the `signature` buffer,
 * (expected length same as modulus length from `rsa_private_key`),
 * and set the length of expected output in the `len` field of
 * `signature`. If the user-set length and the output length does not
 * match, an error message will be returned.
 *
 * @param rsa_private_key Pointer to RSA private exponent struct.
 * @param message_digest Message digest to be signed (pre-hashed).
 * @param padding_mode Padding scheme to be used for the data.
 * @param[out] signature Pointer to the generated signature struct.
 * @return The result of the RSA signature generation.
 */
crypto_status_t otcrypto_rsa_sign(const rsa_private_key_t *rsa_private_key,
                                  const hash_digest_t *message_digest,
                                  rsa_padding_t padding_mode,
                                  crypto_word32_buf_t *signature);

/**
 * Verifies the authenticity of the input signature.
 *
 * The generated signature is compared against the input signature and
 * PASS / FAIL is returned.
 *
 * @param rsa_public_key Pointer to RSA public exponent struct.
 * @param message_digest Message digest to be verified (pre-hashed).
 * @param padding_mode Padding scheme to be used for the data.
 * @param signature Pointer to the input signature to be verified.
 * @param[out] verification_result Result of signature verification
 * (Pass/Fail).
 * @return Result of the RSA verify operation.
 */
crypto_status_t otcrypto_rsa_verify(const rsa_public_key_t *rsa_public_key,
                                    const hash_digest_t *message_digest,
                                    rsa_padding_t padding_mode,
                                    crypto_const_word32_buf_t signature,
                                    hardened_bool_t *verification_result);

/**
 * Starts the asynchronous RSA key generation function.
 *
 * Initializes OTBN and starts the OTBN routine to compute the RSA
 * private key (d), RSA public key exponent (e) and modulus (n).
 *
 * Returns `kCryptoStatusOK` if the operation was successfully
 * started, or`kCryptoStatusInternalError` if the operation cannot be
 * started.
 *
 * @param required_key_len Requested key length.
 * @return Result of async RSA keygen start operation.
 */
crypto_status_t otcrypto_rsa_keygen_async_start(
    rsa_key_size_t required_key_len);

/**
 * Finalizes the asynchronous RSA key generation function.
 *
 * Returns `kCryptoStatusOK` and copies the RSA private key (d), RSA
 * public key exponent (e) and modulus (n) if the OTBN status is done,
 * or `kCryptoStatusAsyncIncomplete` if the OTBN is busy or
 * `kCryptoStatusInternalError` if there is an error.
 *
 * @param[out] rsa_public_key Pointer to RSA public exponent struct.
 * @param[out] rsa_private_key Pointer to RSA private exponent struct.
 * @return Result of asynchronous RSA keygen finalize operation.
 */
crypto_status_t otcrypto_rsa_keygen_async_finalize(
    rsa_public_key_t *rsa_public_key, rsa_private_key_t *rsa_private_key);

/**
 * Begins an asynchronous RSA private key construction.
 *
 * See `otcrypto_rsa_private_key_from_exponents` for details on the requirements
 * and guarantees of this routine.
 *
 * @param size RSA size parameter.
 * @param modulus RSA modulus (n).
 * @param e RSA public exponent.
 * @param d_share0 First share of the private exponent d.
 * @param d_share1 Second share of the private exponent d.
 * @param check_key_validity Whether to check that the key is valid.
 * @return Result of the RSA key construction start operation.
 */
crypto_status_t otcrypto_rsa_private_key_from_exponents_async_start(
    rsa_size_t size, crypto_const_word32_buf_t modulus, uint32_t e,
    crypto_const_word32_buf_t d_share0, crypto_const_word32_buf_t d_share1,
    hardened_bool_t check_key_validity);

/**
 * Finalizes an asynchronous RSA private key construction.
 *
 * See `otcrypto_rsa_private_key_from_exponents` for details on the requirements
 * and guarantees of this routine.
 *
 * @param[out] private_key Destination private key struct.
 * @return Result of the RSA key construction finalize operation.
 */
crypto_status_t otcrypto_rsa_private_key_from_exponents_async_finalize(
    crypto_blinded_key_t *private_key);

/**
 * Begins an asynchronous RSA private key construction.
 *
 * See `otcrypto_rsa_private_key_from_primes` for details on the requirements
 * and guarantees of this routine.
 *
 * @param size RSA size parameter.
 * @param p_share0 First share of the blinded prime factor p.
 * @param p_share1 Second share of the blinded prime factor p.
 * @param q_share0 First share of the blinded prime factor q.
 * @param q_share1 Second share of the blinded prime factor q.
 * @param check_key_validity Whether to check that the key is valid.
 * @return Result of the RSA key construction.
 */
crypto_status_t otcrypto_rsa_private_key_from_primes_async_start(
    rsa_size_t size, crypto_const_word32_buf_t p_share0,
    crypto_const_word32_buf_t p_share1, crypto_const_word32_buf_t q_share0,
    crypto_const_word32_buf_t q_share1, hardened_bool_t check_key_validity);

/**
 * Finalizes an asynchronous RSA private key construction.
 *
 * See `otcrypto_rsa_private_key_from_primes` for details on the requirements
 * and guarantees of this routine.
 *
 * @param[out] private_key Destination private key struct.
 * @return Result of the RSA key construction finalize operation.
 */
crypto_status_t otcrypto_rsa_private_key_from_primes_async_finalize(
    crypto_blinded_key_t *private_key);

/**
 * Begins an asynchronous RSA private key construction.
 *
 * See `otcrypto_rsa_private_key_from_cofactor` for details on the requirements
 * and guarantees of this routine.
 *
 * @param size RSA size parameter.
 * @param modulus RSA modulus (n).
 * @param prime_share0 First share of the blinded prime factor (p or q).
 * @param prime_share1 Second share of the blinded prime factor (p or q).
 * @param check_key_validity Whether to check that the key is valid.
 * @return Result of the RSA key construction start operation.
 */
crypto_status_t otcrypto_rsa_private_key_from_cofactor_async_start(
    rsa_size_t size, crypto_const_word32_buf_t modulus,
    crypto_const_word32_buf_t prime_share0,
    crypto_const_word32_buf_t prime_share1, hardened_bool_t check_key_validity);

/**
 * Finalizes an asynchronous RSA private key construction.
 *
 * See `otcrypto_rsa_private_key_from_cofactor` for details on the requirements
 * and guarantees of this routine.
 *
 * @param[out] private_key Destination private key struct.
 * @return Result of the RSA key construction finalize operation.
 */
crypto_status_t otcrypto_rsa_private_key_from_cofactor_async_finalize(
    crypto_blinded_key_t *private_key);

/**
 * Starts the asynchronous digital signature generation function.
 *
 * Initializes OTBN and starts the OTBN routine to compute the digital
 * signature on the input message.
 *
 * Returns `kCryptoStatusOK` if the operation was successfully
 * started, or`kCryptoStatusInternalError` if the operation cannot be
 * started.
 *
 * @param rsa_private_key Pointer to RSA private exponent struct.
 * @param message_digest Message digest to be signed (pre-hashed).
 * @param padding_mode Padding scheme to be used for the data.
 * @return Result of async RSA sign start operation.
 */
crypto_status_t otcrypto_rsa_sign_async_start(
    const rsa_private_key_t *rsa_private_key,
    const hash_digest_t *message_digest, rsa_padding_t padding_mode);

/**
 * Finalizes the asynchronous digital signature generation function.
 *
 * Returns `kCryptoStatusOK` and copies the signature if the OTBN
 * status is done, or `kCryptoStatusAsyncIncomplete` if the OTBN is
 * busy or `kCryptoStatusInternalError` if there is an error.
 *
 * The caller should allocate space for the `signature` buffer,
 * (expected length same as modulus length from `rsa_private_key`),
 * and set the length of expected output in the `len` field of
 * `signature`. If the user-set length and the output length does not
 * match, an error message will be returned.
 *
 * @param[out] signature Pointer to generated signature struct.
 * @return Result of async RSA sign finalize operation.
 */
crypto_status_t otcrypto_rsa_sign_async_finalize(
    crypto_word32_buf_t *signature);

/**
 * Starts the asynchronous signature verification function.
 *
 * Initializes OTBN and starts the OTBN routine to recover the message
 * from the input signature.
 *
 * @param rsa_public_key Pointer to RSA public exponent struct.
 * @param signature Pointer to the input signature to be verified.
 * @return Result of async RSA verify start operation.
 */
crypto_status_t otcrypto_rsa_verify_async_start(
    const rsa_public_key_t *rsa_public_key,
    crypto_const_word32_buf_t signature);

/**
 * Finalizes the asynchronous signature verification function.
 *
 * Returns `kCryptoStatusOK` and populates the `verification result`
 * if the OTBN status is done, or `kCryptoStatusAsyncIncomplete` if
 * OTBN is busy or `kCryptoStatusInternalError` if there is an error.
 * The (hash of) recovered message is compared against the input
 * message and a PASS or FAIL is returned.
 *
 * @param message_digest Message digest to be verified (pre-hashed).
 * @param padding_mode Padding scheme to be used for the data.
 * @param[out] verification_result Result of signature verification
 * (Pass/Fail).
 * @return Result of async RSA verify finalize operation.
 */
crypto_status_t otcrypto_rsa_verify_async_finalize(
    const hash_digest_t *message_digest, rsa_padding_t padding_mode,
    hardened_bool_t *verification_result);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  // OPENTITAN_SW_DEVICE_LIB_CRYPTO_INCLUDE_RSA_H_
