// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/wots.h

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/wots.h"

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/drivers/kmac.h"
#include "sw/device/silicon_creator/lib/error.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/thash.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/utils.h"

/**
 * Computes the chaining function.
 *
 * Interprets `in` as the value of the chain at index `start`. `addr` must
 * contain the address of the chain.
 *
 * @param in Input buffer (`kSpxN` bytes).
 * @param start Start index.
 * @param steps Number of steps.
 * @param addr Hypertree address.
 * @param[out] Output buffer (`kSpxNWords` words).
 * @return Error code indicating if the operation succeeded.
 */
OT_WARN_UNUSED_RESULT
static rom_error_t gen_chain(const unsigned char *in, size_t start,
                             size_t steps, const spx_ctx *ctx, uint32_t addr[8],
                             uint32_t *out) {
  // Initialize out with the value at position `start`.
  memcpy(out, in, kSpxN);

  spx_addr_hash_set(addr, start);
  // Iterate `steps` calls to the hash function. This loop is
  // performance-critical.
  for (size_t i = start; i < (start + steps) && i < kSpxWotsW; i++) {
    // This loop body is essentially just `thash`, inlined for performance.
    HARDENED_RETURN_IF_ERROR(kmac_shake256_start());
    kmac_shake256_absorb_words(ctx->pub_seed, kSpxNWords);
    kmac_shake256_absorb_words(addr, 8);
    kmac_shake256_absorb_words(out, kSpxNWords);
    kmac_shake256_squeeze_start();
    // This address change is located here for performance reasons; we update
    // it while the Keccak core is processing.
    spx_addr_hash_set(addr, i + 1);
    HARDENED_RETURN_IF_ERROR(kmac_shake256_squeeze_end(out, kSpxNWords));
  }

  return kErrorOk;
}

/**
 * Interprets an array of bytes as integers in base w.
 *
 * The NIST submission describes this operation in detail (section 2.5):
 *   https://sphincs.org/data/sphincs+-r3.1-specification.pdf
 *
 * The caller is responsible for ensuring that `input` has at least
 * `kSpxWotsLogW * out_len` bits available.
 *
 * This implementation assumes log2(w) is a divisor of 8 (1, 2, 4, or 8).
 *
 * @param input Input buffer.
 * @param out_len Length of output buffer.
 * @param[out] output Resulting array of integers.
 */
static_assert(8 % kSpxWotsLogW == 0, "log2(w) must be a divisor of 8.");
static_assert(sizeof(uint32_t) <= kSpxWotsLogW,
              "Base-w integers must fit in a `uint32_t`.");
static void base_w(const unsigned char *input, const size_t out_len,
                   uint32_t *output) {
  size_t bits = 0;
  size_t in_idx = 0;
  unsigned char total;
  for (size_t out_idx = 0; out_idx < out_len; out_idx++) {
    if (bits == 0) {
      total = input[in_idx];
      in_idx++;
      bits += 8;
    }
    bits -= kSpxWotsLogW;
    output[out_idx] = (total >> bits) & (kSpxWotsW - 1);
  }
}

/**
 * Computes the WOTS+ checksum over a message (in base-w).
 *
 * The length of the checksum is `kSpxWotsLen2` integers in base-w; the caller
 * must ensure that `csum_base_w` has at least this length.
 *
 * This implementation uses a 32-bit integer to store the checksum, which
 * assumes that the maximum checksum value (len1 * (w - 1)) fits in that range.
 *
 * See section 3.1 of the NIST submission for explanation about the WOTS
 * parameters here (e.g. `kSpxWotsLen2`):
 *   https://sphincs.org/data/sphincs+-r3.1-specification.pdf
 *
 * @param msg_base_w Message in base-w.
 * @param[out] csum_base_w Resulting checksum in base-w.
 */
static_assert(kSpxWotsLen1 * (kSpxWotsW - 1) <= UINT32_MAX,
              "WOTS checksum may not fit in a 32-bit integer.");
static void wots_checksum(const unsigned int *msg_base_w,
                          uint32_t *csum_base_w) {
  // Compute checksum.
  uint32_t csum = 0;
  for (size_t i = 0; i < kSpxWotsLen1; i++) {
    csum += kSpxWotsW - 1 - msg_base_w[i];
  }

  // Make sure any expected empty zero bits are the least significant bits by
  // shifting csum left.
  size_t csum_nbits = kSpxWotsLen2 * kSpxWotsLogW;
  csum <<= ((32 - (csum_nbits % 32)) % 32);

  // Convert checksum to big-endian bytes and then to base-w.
  csum = __builtin_bswap32(csum);
  base_w((unsigned char *)&csum, kSpxWotsLen2, csum_base_w);
}

/**
 * Derive the matching chain lengths from a message.
 *
 * The `lengths` buffer should be at least `kSpxWotsLen` words long.
 *
 * @param msg Input message.
 * @param[out] lengths Resulting chain lengths.
 */
static void chain_lengths(const unsigned char *msg, uint32_t *lengths) {
  base_w(msg, kSpxWotsLen1, lengths);
  wots_checksum(lengths, &lengths[kSpxWotsLen1]);
}

rom_error_t wots_pk_from_sig(const unsigned char *sig, const unsigned char *msg,
                             const spx_ctx *ctx, uint32_t addr[8],
                             uint32_t *pk) {
  uint32_t lengths[kSpxWotsLen];
  chain_lengths(msg, lengths);

  for (size_t i = 0; i < kSpxWotsLen; i++) {
    spx_addr_chain_set(addr, i);
    size_t pk_idx = i * kSpxNWords;
    size_t steps = kSpxWotsW - 1 - lengths[i];
    HARDENED_RETURN_IF_ERROR(
        gen_chain(sig + i * kSpxN, lengths[i], steps, ctx, addr, &pk[pk_idx]));
  }

  return kErrorOk;
}
