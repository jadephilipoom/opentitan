// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/address.h

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"

static_assert(kSpxTreeHeight * (kSpxD - 1) <= 64,
              "Subtree addressing is currently limited to at most 2^64 trees.");

inline void spx_addr_layer_set(uint32_t addr[8], uint32_t layer) {
  ((unsigned char *)addr)[kSpxOffsetLayer] = (unsigned char)layer;
}

inline void spx_addr_tree_set(uint32_t addr[8], uint64_t tree) {
  // Reverse bytes in the integer so it will appear in big-endian form.
  uint64_t tree_be = __builtin_bswap64(tree);
  memcpy(&((unsigned char *)addr)[kSpxOffsetTree], &tree_be, sizeof(uint64_t));
}

inline void spx_addr_type_set(uint32_t addr[8], spx_addr_type_t type) {
  ((unsigned char *)addr)[kSpxOffsetType] = (unsigned char)type;
}

inline void spx_addr_subtree_copy(uint32_t out[8], const uint32_t in[8]) {
  memcpy(out, in, kSpxOffsetTree + 8);
}

void spx_addr_keypair_set(uint32_t addr[8], uint32_t keypair) {
  if (kSpxFullHeight / kSpxD > 8) {
    // We have > 256 OTS at the bottom of the Merkle tree; to specify which one,
    // we need to express it in two bytes.
    ((unsigned char *)addr)[kSpxOffsetKpAddr2] = (unsigned char)(keypair >> 8);
  }
  ((unsigned char *)addr)[kSpxOffsetKpAddr1] = (unsigned char)keypair;
}

void spx_addr_keypair_copy(uint32_t out[8], const uint32_t in[8]) {
  memcpy(out, in, kSpxOffsetTree + 8);
  if (kSpxFullHeight / kSpxD > 8) {
    ((unsigned char *)out)[kSpxOffsetKpAddr2] =
        ((unsigned char *)in)[kSpxOffsetKpAddr2];
  }
  ((unsigned char *)out)[kSpxOffsetKpAddr1] =
      ((unsigned char *)in)[kSpxOffsetKpAddr1];
}

inline void spx_addr_chain_set(uint32_t addr[8], uint32_t chain) {
  ((unsigned char *)addr)[kSpxOffsetChainAddr] = (unsigned char)chain;
}

inline void spx_addr_hash_set(uint32_t addr[8], uint32_t hash) {
  ((unsigned char *)addr)[kSpxOffsetHashAddr] = (unsigned char)hash;
}

inline void spx_addr_tree_height_set(uint32_t addr[8], uint32_t tree_height) {
  ((unsigned char *)addr)[kSpxOffsetTreeHeight] = (unsigned char)tree_height;
}

inline void spx_addr_tree_index_set(uint32_t addr[8], uint32_t tree_index) {
  // Reverse bytes in the integer so it will appear in big-endian form.
  uint32_t index_be = __builtin_bswap32(tree_index);
  memcpy(&((unsigned char *)addr)[kSpxOffsetTreeIndex], &index_be,
         sizeof(uint32_t));
}
