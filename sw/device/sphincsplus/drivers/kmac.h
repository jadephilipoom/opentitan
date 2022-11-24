// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_SPHINCSPLUS_DRIVERS_KMAC_H_
#define OPENTITAN_SW_DEVICE_SPHINCSPLUS_DRIVERS_KMAC_H_

/**
 * This driver is specialized to meet the needs of SPHINCS+-SHAKE.
 */

#include <stdint.h>

#include "sw/device/lib/base/macros.h"

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

typedef enum kmac_error {
  kKmacOk = 0,
  kKmacErrorUnknown = 1,
} kmac_error_t;

typedef struct kmac_squeeze_context {
  /**
   * Offset within the current Keccak state, in words.
   */
  size_t state_offset;
} kmac_squeeze_context_t;

/**
 * Configure the KMAC block at startup.
 *
 * Sets the KMAC block to use software entropy (since we have no secret inputs
 * for SPHINCS+) and sets the mode to SHAKE-256.
 *
 * @return Error code indicating if the operation succeeded.
 */
OT_WARN_UNUSED_RESULT
kmac_error_t kmac_shake256_configure(void);

/**
 * Start a SHAKE-256 hashing operation.
 *
 * Must be called after `kmac_shake256_configure()`. Will block until KMAC
 * hardware is idle.
 *
 * This driver supports SHAKE-256 hashing with the following pattern:
 * - Exactly one call to `kmac_shake256_start`
 * - Zero or more calls to `kmac_shake256_absorb`
 * - Exactly one call to `kmac_shake256_squeeze_start`
 * - Zero or more calls to `kmac_shake256_squeeze`
 * - Exactly one call to `kmac_shake256_end`
 *
 * There is no need to append the `1111` padding in the SHAKE-256 specification
 * to the input; this will happen automatically in squeeze_start().
 *
 * @return Error code indicating if the operation succeeded.
 */
OT_WARN_UNUSED_RESULT
kmac_error_t kmac_shake256_start(void);

/**
 * Absorb more input for a SHAKE-256 hashing operation.
 *
 * The caller is responsible for calling `kmac_shake256_start()` first.
 *
 * Blocks until the all input is written.
 *
 * For best performance, `in` should be 32b-aligned, although this function
 * does handle unaligned buffers.
 *
 * @param in Input buffer
 * @param inlen Length of input (bytes)
 * @return Error code indicating if the operation succeeded.
 */
OT_WARN_UNUSED_RESULT
kmac_error_t kmac_shake256_absorb(const uint8_t *in, size_t inlen);

/**
 * Begin the squeezing phase of a SHAKE-256 hashing operation.
 *
 * This function will move from `absorb` to `squeeze` state and append the
 * SHAKE-256 suffix to the message. It will also initialize the internal
 * context object.
 *
 * The caller is responsible for calling `kmac_shake256_start()` first.
 *
 * @param ctx KMAC squeezing context, initialized by this function
 * @return Error code indicating if the operation succeeded.
 */
OT_WARN_UNUSED_RESULT
kmac_error_t kmac_shake256_squeeze_start(kmac_squeeze_context_t *ctx);

/**
 * Squeeze output from a SHAKE-256 hashing operation.
 *
 * The caller is responsible for calling `kmac_shake256_squeeze_start()` first.
 *
 * Blocks until all output is written.
 *
 * @param out Output buffer
 * @param outlen Desired length of output (in words)
 * @param ctx KMAC squeezing context
 * @return Error code indicating if the operation succeeded.
 */
OT_WARN_UNUSED_RESULT
kmac_error_t kmac_shake256_squeeze(uint32_t *out, size_t outlen,
                                   kmac_squeeze_context_t *ctx);

/**
 * Finish a SHAKE-256 hashing operation.
 *
 * The caller is responsible for calling this after every hashing operation is
 * complete.
 *
 * Does not block until KMAC is idle; errors may appear in the next call to
 * `kmac_shake256_start`.
 *
 * @return Error code indicating if the operation succeeded.
 */
kmac_error_t kmac_shake256_end(void);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  // OPENTITAN_SW_DEVICE_SPHINCSPLUS_DRIVERS_KMAC_H_
