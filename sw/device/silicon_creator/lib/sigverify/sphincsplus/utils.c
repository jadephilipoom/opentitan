// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/utils.c
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/utilsx1.c

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/utils.h"

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/drivers/kmac.h"
#include "sw/device/silicon_creator/lib/error.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/thash.h"

uint64_t spx_utils_bytes_to_u64(const uint8_t *in, size_t inlen) {
  uint64_t retval = 0;
  for (size_t i = 0; i < inlen; i++) {
    retval |= ((uint64_t)in[i]) << (8 * (inlen - 1 - i));
  }
  return retval;
}

rom_error_t spx_utils_compute_root(const uint8_t *leaf, uint32_t leaf_idx,
                                   uint32_t idx_offset,
                                   const uint8_t *auth_path,
                                   uint8_t tree_height, const spx_ctx_t *ctx,
                                   spx_addr_t *addr, uint32_t *root) {
  // Initialize working buffer.
  uint32_t buffer[2 * kSpxNWords];
  // Pointer to second half of buffer for convenience.
  uint32_t *buffer_second = &buffer[kSpxNWords];

  // If leaf_idx is odd (last bit = 1), current path element is a right child
  // and auth_path has to go left. Otherwise it is the other way around.
  if (leaf_idx & 1) {
    memcpy(buffer_second, leaf, kSpxN);
    memcpy(buffer, auth_path, kSpxN);
  } else {
    memcpy(buffer, leaf, kSpxN);
    memcpy(buffer_second, auth_path, kSpxN);
  }
  auth_path += kSpxN;

  for (uint8_t i = 0; i < tree_height - 1; i++) {
    leaf_idx >>= 1;
    idx_offset >>= 1;
    // Set the address of the node we're creating.
    spx_addr_tree_height_set(addr, i + 1);
    spx_addr_tree_index_set(addr, leaf_idx + idx_offset);

    // Pick the right or left neighbor, depending on parity of the node.
    uint32_t *hash_dst = (leaf_idx & 1) ? buffer_second : buffer;
    uint32_t *auth_dst = (leaf_idx & 1) ? buffer : buffer_second;

    // This is an inlined `thash` operation.
    HARDENED_RETURN_IF_ERROR(kmac_shake256_start());
    kmac_shake256_absorb_words(ctx->pub_seed, kSpxNWords);
    kmac_shake256_absorb_words(addr->addr, ARRAYSIZE(addr->addr));
    kmac_shake256_absorb_words(buffer, 2 * kSpxNWords);
    kmac_shake256_squeeze_start();

    // Copy the auth path while KMAC is processing for performance reasons.
    memcpy(auth_dst, auth_path, kSpxN);
    auth_path += kSpxN;

    // Get the `thash` output.
    HARDENED_RETURN_IF_ERROR(kmac_shake256_squeeze_end(hash_dst, kSpxNWords));
  }

  // The last iteration is exceptional; we do not copy an auth_path node.
  leaf_idx >>= 1;
  idx_offset >>= 1;
  spx_addr_tree_height_set(addr, tree_height);
  spx_addr_tree_index_set(addr, leaf_idx + idx_offset);
  return thash((unsigned char *)buffer, 2, ctx, addr, root);
}

/*
 * Generate the entire Merkle tree, computing the authentication path for
 * leaf_idx, and the resulting root node using Merkle's TreeHash algorithm.
 * Expects the layer and tree parts of the tree_addr to be set, as well as the
 * tree type (i.e. SPX_ADDR_TYPE_HASHTREE or SPX_ADDR_TYPE_FORSTREE)
 *
 * This expects tree_addr to be initialized to the addr structures for the
 * Merkle tree nodes
 *
 * Applies the offset idx_offset to indices before building addresses, so that
 * it is possible to continue counting indices across trees.
 *
 * This works by using the standard Merkle tree building algorithm,
 */
rom_error_t treehashx1(
    unsigned char *root, unsigned char *auth_path, const spx_ctx_t *ctx,
    uint32_t leaf_idx, uint32_t idx_offset, uint32_t tree_height,
    rom_error_t (*gen_leaf)(uint32_t * /* Where to write the leaves */,
                            const spx_ctx_t * /* ctx */, uint32_t idx,
                            void *info),
    spx_addr_t *tree_addr, void *info) {
  // This is where we keep the intermediate nodes.
  uint32_t stack[tree_height * kSpxNWords];

  uint32_t idx;
  uint32_t max_idx = (uint32_t)((1 << tree_height) - 1);
  for (idx = 0;; idx++) {
    uint32_t current[2 * kSpxNWords];
    // Current logical node is at index[SPX_N]. We do this to minimize the
    // number of copies needed during a thash.
    HARDENED_RETURN_IF_ERROR(
       gen_leaf(&current[kSpxNWords], ctx, idx + idx_offset, info));

    // BM: 2695985 for entire signing if only gen_leaf is commented out and
    // replaced with memset (97% of runtime, includes both FORS and merkle)

    // Now combine the freshly generated right node with previously generated
    // left ones
    uint32_t internal_idx_offset = idx_offset;
    uint32_t internal_idx = idx;
    uint32_t internal_leaf = leaf_idx;
    uint32_t h; // The height we are in the Merkle tree.
    for (h = 0;; h++, internal_idx >>= 1, internal_leaf >>= 1) {
      // Check if we hit the top of the tree.
      if (h == tree_height) {
        // We hit the root; return it.
        memcpy(root, &current[kSpxNWords], kSpxN);
        return kErrorOk;
      }

      // Check if the node we have is a part of the authentication path; if it
      // is, write it out.
      if ((internal_idx ^ internal_leaf) == 0x01) {
        memcpy(&auth_path[h * kSpxN], &current[kSpxNWords],
               kSpxN);
      }

       // Check if we're at a left child; if so, stop going up the stack.
       // Exception: if we've reached the end of the tree, keep on going (so we
       // combine the last 4 nodes into the one root node in two more
       // iterations).
      if ((internal_idx & 1) == 0 && idx < max_idx) {
        break;
      }

      // Ok, we're at a right node.  Now combine the left and right logical
      // nodes together.

      // Set the address of the node we're creating.
      internal_idx_offset >>= 1;
      spx_addr_tree_height_set(tree_addr, h + 1);
      spx_addr_tree_index_set(tree_addr,
                              internal_idx / 2 + internal_idx_offset);

      uint32_t *left = &stack[h * kSpxNWords];
      memcpy(current, left, kSpxN);
      HARDENED_RETURN_IF_ERROR(thash((unsigned char *)current, 2, ctx,
                                     tree_addr, &current[kSpxNWords]));
    }

    // We've hit a left child; save the current for when we get the
    // corresponding right child.
    memcpy(&stack[h * kSpxNWords], &current[kSpxNWords], kSpxN);
  }
  return kErrorOk;
}
