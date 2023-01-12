// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/hash_shake.c

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/drivers/kmac.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/hash.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/utils.h"

enum {
  /**
   * Number of bits needed to represent the `tree` field.
   */
  kSpxTreeBits = kSpxTreeHeight * (kSpxD - 1),
  /**
   * Number of bytes needed to represent the `tree` field.
   */
  kSpxTreeBytes = (kSpxTreeBits + 7) / 8,
  /**
   * Number of bits needed to represent a leaf index.
   */
  kSpxLeafBits = kSpxTreeHeight,
  /**
   * Number of bytes needed to represent a leaf index.
   */
  kSpxLeafBytes = (kSpxLeafBits + 7) / 8,
  /**
   * Number of bytes needed for the message digest.
   */
  kSpxDigestBytes = kSpxForsMsgBytes + kSpxTreeBytes + kSpxLeafBytes,
  /**
   * Number of 32-bit words needed for the message digest.
   *
   * Rounded up if necessary.
   */
  kSpxDigestWords = (kSpxDigestBytes + sizeof(uint32_t) - 1) / sizeof(uint32_t),
};

static_assert(
    kSpxTreeBits <= 64,
    "For given height and depth, 64 bits cannot represent all subtrees.");

rom_error_t spx_hash_initialize(spx_ctx *ctx) {
  return kmac_shake256_configure();
}

rom_error_t spx_hash_message(const unsigned char *R, const unsigned char *pk,
                             const unsigned char *m, unsigned long long mlen,
                             const spx_ctx *ctx, unsigned char *digest,
                             uint64_t *tree, uint32_t *leaf_idx) {
  // Suppress a warning about this variable being unused. For SHAKE it's
  // unnecessary, but it is included in the interface because other SPHINCS+
  // hash functions may need it.
  (void)ctx;

  uint32_t buf[kSpxDigestWords] = {0};
  unsigned char *bufp = (unsigned char *)buf;

  HARDENED_RETURN_IF_ERROR(kmac_shake256_start());
  kmac_shake256_absorb(R, kSpxN);
  kmac_shake256_absorb(pk, kSpxPkBytes);
  kmac_shake256_absorb(m, mlen);
  kmac_shake256_squeeze_start();
  // TODO: add a non-end `squeeze` to remove `buf` and get digest/tree/idx
  // separately
  HARDENED_RETURN_IF_ERROR(kmac_shake256_squeeze_end(buf, kSpxDigestWords));

  memcpy(digest, bufp, kSpxForsMsgBytes);
  bufp += kSpxForsMsgBytes;

  if (kSpxTreeBits == 0) {
    *tree = 0;
  } else {
    *tree = spx_utils_bytes_to_u64(bufp, kSpxTreeBytes);
    *tree &= (~(uint64_t)0) >> (64 - kSpxTreeBits);
    bufp += kSpxTreeBytes;
  }

  *leaf_idx = (uint32_t)spx_utils_bytes_to_u64(bufp, kSpxLeafBytes);
  *leaf_idx &= (~(uint32_t)0) >> (32 - kSpxLeafBits);

  return kErrorOk;
}
