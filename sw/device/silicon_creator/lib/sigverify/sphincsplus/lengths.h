// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_LENGTHS_H_
#define OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_LENGTHS_H_

#include <stddef.h>
#include <stdint.h>

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params.h"

#ifdef __cplusplus
extern "C" {
#endif

enum {
  /**
   * Size of SPHINCS+ signature.
   */
  kSpxLenSigBytes = kSpxBytes,
  /**
   * Size of SPHINCS+ signature in words.
   */
  kSpxLenSigWords = kSpxLenSigBytes / sizeof(uint32_t),
  /**
   * Size of SPHINCS+ public key.
   */
  kSpxLenPkBytes = kSpxPkBytes,
  /**
   * Size of SPHINCS+ secret key.
   */
  kSpxLenSkBytes = kSpxSkBytes,
  /**
   * Size of SPHINCS+ secret key in words.
   */
  kSpxLenSkWords = kSpxLenSkBytes / sizeof(uint32_t),
  /**
   * Size of SPHINCS+ root node in words.
   */
  kSpxLenRootWords = kSpxNWords,
};

static_assert(kSpxLenSkWords * sizeof(uint32_t) == kSpxLenSkBytes, "Word size must divide secret key size.");
static_assert(kSpxLenSigWords * sizeof(uint32_t) == kSpxLenSigBytes, "Word size must divide signature size.");

#ifdef __cplusplus
}
#endif

#endif  // OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_LENGTHS_H_
