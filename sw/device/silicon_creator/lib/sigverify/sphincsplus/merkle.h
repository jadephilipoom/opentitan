// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/merkle.h

#ifndef OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_MERKLE_H_
#define OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_MERKLE_H_

#include "sw/device/lib/base/macros.h"
#include "sw/device/silicon_creator/lib/error.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/context.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * TODO: docstring
 */
OT_WARN_UNUSED_RESULT
rom_error_t merkle_sign(uint8_t *sig, uint32_t *root, const spx_ctx_t *ctx,
                        spx_addr_t *wots_addr, spx_addr_t *tree_addr,
                        uint32_t idx_leaf);

#ifdef __cplusplus
}
#endif

#endif  // OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_MERKLE_H_
