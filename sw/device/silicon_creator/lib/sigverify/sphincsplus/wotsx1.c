// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/wotsx1.c

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/wotsx1.h"

#include <stddef.h>
#include <stdint.h>

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/drivers/kmac.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/context.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/hash.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/thash.h"

rom_error_t wots_gen_leafx1(uint32_t *dest, const spx_ctx_t *ctx,
                            uint32_t leaf_idx, void *v_info) {
  struct leaf_info_x1 *info = v_info;
  spx_addr_t *leaf_addr = &info->leaf_addr;
  spx_addr_t *pk_addr = &info->pk_addr;
  unsigned int i, k;
  uint32_t pk_buffer[kSpxWotsWords];
  uint32_t *buffer;
  uint32_t wots_k_mask;

  if (leaf_idx == info->wots_sign_leaf) {
    // We're traversing the leaf that's signing; generate the WOTS signature.
    wots_k_mask = 0;
  } else {
    // Nope, we're just generating pk's; turn off the signature logic.
    wots_k_mask = (uint32_t)~0;
  }

  spx_addr_keypair_set(leaf_addr, leaf_idx);
  spx_addr_keypair_set(pk_addr, leaf_idx);

  for (i = 0, buffer = pk_buffer; i < kSpxWotsLen; i++, buffer += kSpxNWords) {
    // Set wots_k to the step if we're generating a signature, ~0 if we're not.
    uint32_t wots_k = info->wots_steps[i] | wots_k_mask;

    // Start with the secret seed.
    spx_addr_chain_set(leaf_addr, i);
    spx_addr_hash_set(leaf_addr, 0);
    spx_addr_type_set(leaf_addr, kSpxAddrTypeWotsPrf);

    HARDENED_RETURN_IF_ERROR(prf_addr(buffer, ctx, leaf_addr));

    spx_addr_type_set(leaf_addr, kSpxAddrTypeWots);

    // Iterate down the WOTS chain. This loop is performance-critical (> 80% of
    // runtime for signing).
    spx_addr_hash_set(leaf_addr, 0);
    for (k = 0; k < kSpxWotsW - 1; k++) {
      // Inlined thash (for performance).
      // = thash((unsigned char *)buffer, 1, ctx, leaf_addr, buffer)
      HARDENED_RETURN_IF_ERROR(kmac_shake256_start());
      kmac_shake256_absorb_words(ctx->pub_seed, kSpxNWords);
      kmac_shake256_absorb_words(leaf_addr->addr, ARRAYSIZE(leaf_addr->addr));
      kmac_shake256_absorb_words(buffer, kSpxNWords);
      kmac_shake256_squeeze_start();

      // While KMAC is processing, check if this is the value that needs to be
      // saved as a part of the WOTS signature and copy if needed.
      if (k == wots_k) {
        memcpy(info->wots_sig + i * kSpxN, buffer, kSpxN);
      }

      // Read data back from KMAC and send a DONE command to hardware.
      HARDENED_RETURN_IF_ERROR(kmac_shake256_squeeze_end(buffer, kSpxNWords));

      // While KMAC is cleaning up, prepare address for the next iteration.
      spx_addr_hash_set(leaf_addr, k+1);
    }

    // Special case if the value to be saved is the final value. Outside the
    // loop for performance.
    if (wots_k == kSpxWotsW - 1) {
      memcpy(info->wots_sig + i * kSpxN, buffer, kSpxN);
    }
  }

  // Do the final thash to generate the public keys.
  return thash((unsigned char *)pk_buffer, kSpxWotsLen, ctx, pk_addr, dest);
}
