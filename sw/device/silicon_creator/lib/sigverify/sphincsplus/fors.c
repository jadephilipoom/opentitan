// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/fors.h

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/fors.h"

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/hash.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/thash.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/utils.h"

/**
 * Get the leaf value from the FORS secret key.
 *
 * @param sk Input secret key (`kSpxN` bytes).
 * @param ctx Context object.
 * @param fors_leaf_addr Leaf address.
 * @param[out] leaf Resulting leaf (`kSpxNWords` words).
 * @return Error code indicating if the operation succeeded.
 */
OT_WARN_UNUSED_RESULT
static rom_error_t fors_sk_to_leaf(const unsigned char *sk, const spx_ctx *ctx,
                                   uint32_t fors_leaf_addr[8], uint32_t *leaf) {
  return thash(sk, 1, ctx, fors_leaf_addr, leaf);
}

/**
 * Interprets m as `kSpxForsHeight`-bit unsigned integers.
 *
 * Assumes m contains at least kSpxForsHeight * kSpxForsTrees bits.
 * Assumes indices has space for kSpxForsTrees integers.
 *
 * @param m Input message.
 * @param[out] indices Buffer for indices.
 */
static void message_to_indices(const unsigned char *m, uint32_t *indices) {
  size_t offset = 0;
  for (size_t i = 0; i < kSpxForsTrees; i++) {
    indices[i] = 0;
    for (size_t j = 0; j < kSpxForsHeight; j++) {
      indices[i] ^= ((m[offset >> 3] >> (offset & 0x7)) & 0x1) << j;
      offset++;
    }
  }
}

rom_error_t fors_pk_from_sig(const unsigned char *sig, const unsigned char *m,
                             const spx_ctx *ctx, const uint32_t fors_addr[8],
                             uint32_t *pk) {
  // Initialize the FORS tree address.
  uint32_t fors_tree_addr[8] = {0};
  spx_addr_keypair_copy(fors_tree_addr, fors_addr);
  spx_addr_type_set(fors_tree_addr, kSpxAddrTypeForsTree);

  // Initialize the FORS public key address.
  uint32_t fors_pk_addr[8] = {0};
  spx_addr_keypair_copy(fors_pk_addr, fors_addr);
  spx_addr_type_set(fors_pk_addr, kSpxAddrTypeForsPk);

  uint32_t indices[kSpxForsTrees];
  message_to_indices(m, indices);

  uint32_t roots[kSpxForsTrees * kSpxNWords];
  for (size_t i = 0; i < kSpxForsTrees; i++) {
    uint32_t idx_offset = i * (1 << kSpxForsHeight);

    spx_addr_tree_height_set(fors_tree_addr, 0);
    spx_addr_tree_index_set(fors_tree_addr, indices[i] + idx_offset);

    // Derive the leaf from the included secret key part.
    uint32_t leaf[kSpxNWords];
    HARDENED_RETURN_IF_ERROR(fors_sk_to_leaf(sig, ctx, fors_tree_addr, leaf));
    sig += kSpxN;

    // Derive the corresponding root node of this tree.
    uint32_t *root = &roots[i * kSpxNWords];
    HARDENED_RETURN_IF_ERROR(
        spx_utils_compute_root((unsigned char *)leaf, indices[i], idx_offset,
                               sig, kSpxForsHeight, ctx, fors_tree_addr, root));
    sig += kSpxN * kSpxForsHeight;
  }

  // Hash horizontally across all tree roots to derive the public key.
  return thash((unsigned char *)roots, kSpxForsTrees, ctx, fors_pk_addr, pk);
}
