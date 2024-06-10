// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/thash_shake_simple.h

#include "sw/device/lib/base/memory.h"
#include "sw/device/silicon_creator/lib/drivers/hmac.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/sha2.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/thash.h"

void thash(const uint32_t *in, size_t inblocks, const spx_ctx_t *ctx,
           const spx_addr_t *addr, uint32_t *out) {
  // TODO: The reference implementation uses a pre-seeded SHA256 state that has
  // already absorbed `ctx->pub_seed` and padding here. Check if that helps
  // performance enough to justify the code size.
  hmac_sha256_init_endian(/*big_endian=*/true);
  hmac_sha256_update_words(ctx->pub_seed, kSpxNWords);
  uint32_t padding[kSpxSha2BlockNumWords - kSpxNWords];
  memset(padding, 0, sizeof(padding));
  hmac_sha256_update_words(padding, ARRAYSIZE(padding));
  hmac_sha256_update((unsigned char *)addr->addr, kSpxSha256AddrBytes);
  hmac_sha256_update_words(in, inblocks * kSpxNWords);
  hmac_sha256_final_truncated(out, kSpxNWords);
}
