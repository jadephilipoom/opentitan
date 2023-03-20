// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/merkle.c

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/merkle.h"

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/context.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/utils.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/wots.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/wotsx1.h"

rom_error_t merkle_sign(uint8_t *sig, uint32_t *root, const spx_ctx_t *ctx,
                        spx_addr_t *wots_addr, spx_addr_t *tree_addr,
                        uint32_t idx_leaf) {
  unsigned char *auth_path = sig + kSpxWotsBytes;
  struct leaf_info_x1 info = {0};
  unsigned char steps[kSpxWotsLen];

  info.wots_sig = sig;
  chain_lengths((unsigned char *)root, steps);
  info.wots_steps = steps;

  spx_addr_type_set(tree_addr, kSpxAddrTypeHashTree);
  spx_addr_type_set(&info.pk_addr, kSpxAddrTypeWotsPk);
  spx_addr_subtree_copy(&info.leaf_addr, wots_addr);
  spx_addr_subtree_copy(&info.pk_addr, wots_addr);

  info.wots_sign_leaf = idx_leaf;

  return treehashx1((unsigned char *)root, auth_path, ctx, idx_leaf, 0,
                    kSpxTreeHeight, wots_gen_leafx1, tree_addr, &info);
}
