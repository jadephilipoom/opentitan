// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/sign.c

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/sign.h"

#include <stddef.h>
#include <stdint.h>

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/context.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/fors.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/hash.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/merkle.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/thash.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/utils.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/wots.h"

rom_error_t spx_sign(uint32_t *sig, const uint8_t *m, size_t mlen,
                     const uint8_t *sk) {
  spx_ctx_t ctx;

  const unsigned char *sk_prf = sk + kSpxN;
  const unsigned char *pk = sk + 2 * kSpxN;

  unsigned char optrand[kSpxN];
  unsigned char mhash[kSpxForsMsgBytes];
  uint32_t root[kSpxNWords];
  uint32_t i;
  uint64_t tree;
  uint32_t idx_leaf;
  spx_addr_t wots_addr = {.addr = {0}};
  spx_addr_t tree_addr = {.addr = {0}};

  // TODO: harden this copy.
  memcpy(ctx.sk_seed, sk, kSpxN);
  memcpy(ctx.pub_seed, pk, kSpxN);

  /* This hook allows the hash function instantiation to do whatever
     preparation or computation it needs, based on the public seed. */
  HARDENED_RETURN_IF_ERROR(spx_hash_initialize(&ctx));

  spx_addr_type_set(&wots_addr, kSpxAddrTypeWots);
  spx_addr_type_set(&tree_addr, kSpxAddrTypeHashTree);

  /* Optionally, signing can be made non-deterministic using optrand.
     This can help counter side-channel attacks that would benefit from
     getting a large number of traces when the signer uses the same nodes. */
  // randombytes(optrand, kSpxN);
  memcpy(optrand, ctx.pub_seed, kSpxN);
  /* Compute the digest randomization value. */
  HARDENED_RETURN_IF_ERROR(gen_message_random(sig, sk_prf, optrand, m, mlen));

  /* Derive the message digest and leaf index from R, PK and M. */
  HARDENED_RETURN_IF_ERROR(spx_hash_message((unsigned char *)sig, pk, m, mlen,
                                            mhash, &tree, &idx_leaf));
  sig += kSpxNWords;

  spx_addr_tree_set(&wots_addr, tree);
  spx_addr_keypair_set(&wots_addr, idx_leaf);

  /* Sign the message hash using FORS. */
  HARDENED_RETURN_IF_ERROR(fors_sign(sig, root, mhash, &ctx, &wots_addr));
  sig += kSpxForsWords;

  for (i = 0; i < kSpxD; i++) {
    spx_addr_layer_set(&tree_addr, i);
    spx_addr_tree_set(&tree_addr, tree);

    spx_addr_subtree_copy(&wots_addr, &tree_addr);
    spx_addr_keypair_set(&wots_addr, idx_leaf);

    HARDENED_RETURN_IF_ERROR(merkle_sign((unsigned char *)sig, root, &ctx,
                                         &wots_addr, &tree_addr, idx_leaf));
    sig += kSpxWotsWords + kSpxTreeHeight * kSpxNWords;

    /* Update the indices for the next layer. */
    idx_leaf = (tree & ((1 << kSpxTreeHeight) - 1));
    tree = tree >> kSpxTreeHeight;
  }

  return kErrorOk;
}
