// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/thash_shake_simple.h

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/drivers/kmac.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/thash.h"

rom_error_t thash(const unsigned char *in, size_t inblocks, const spx_ctx *ctx,
                  uint32_t addr[8], uint32_t *out) {
  // Uses the "simple" thash construction (Construction 7 in the SPHINCS+
  // paper): H(pk_seed, addr, in).
  HARDENED_RETURN_IF_ERROR(kmac_shake256_start());
  kmac_shake256_absorb_words(ctx->pub_seed, kSpxNWords);
  kmac_shake256_absorb_words(addr, 8);
  kmac_shake256_absorb(in, inblocks * kSpxN);
  kmac_shake256_squeeze_start();
  return kmac_shake256_squeeze_end(out, kSpxNWords);
}
