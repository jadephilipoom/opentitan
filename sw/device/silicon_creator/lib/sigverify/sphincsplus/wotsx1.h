// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Derived from code in the SPHINCS+ reference implementation (CC0 license):
// https://github.com/sphincs/sphincsplus/blob/ed15dd78658f63288c7492c00260d86154b84637/ref/wotsx1.h

#ifndef OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_WOTSX1_H_
#define OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_WOTSX1_H_

#include "sw/device/lib/base/macros.h"
#include "sw/device/silicon_creator/lib/error.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/address.h"
#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/context.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * This is here to provide an interface to the internal wots_gen_leafx1
 * routine.  While this routine is not referenced in the package outside of
 * wots.c, it is called from the stand-alone benchmark code to characterize
 * the performance
 */
struct leaf_info_x1 {
  unsigned char *wots_sig;
  uint32_t wots_sign_leaf; /* The index of the WOTS we're using to sign */
  uint8_t *wots_steps;
  spx_addr_t leaf_addr;
  spx_addr_t pk_addr;
};

/*
 * This generates a WOTS public key
 * It also generates the WOTS signature if leaf_info indicates
 * that we're signing with this WOTS key
 */
OT_WARN_UNUSED_RESULT
rom_error_t wots_gen_leafx1(uint32_t *dest, const spx_ctx_t *ctx,
                            uint32_t leaf_idx, void *v_info);

#ifdef __cplusplus
}
#endif

#endif  // OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_WOTSX1_H_
