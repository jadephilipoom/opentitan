// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/manuf/lib/util.h"

#include <stdint.h>

#include "sw/device/lib/base/status.h"
#include "sw/device/lib/crypto/include/datatypes.h"
#include "sw/device/lib/crypto/include/hash.h"

status_t manuf_util_hash_lc_transition_token(const uint32_t *raw_token,
                                             size_t token_num_words,
                                             uint32_t *hashed_token) {
  crypto_const_byte_buf_t input = {
      .data = (unsigned char *)raw_token,
      .len = token_num_words * sizeof(uint32_t),
  };
  crypto_const_byte_buf_t function_name_string = {
      .data = (unsigned char *)"",
      .len = 0,
  };
  crypto_const_byte_buf_t customization_string = {
      .data = (unsigned char *)"LC_CTRL",
      .len = 7,
  };
  crypto_word32_buf_t output = {
      .data = hashed_token,
      .len = token_num_words,
  };

  TRY(otcrypto_xof(input, kXofModeSha3Cshake128, function_name_string,
                   customization_string, token_num_words * sizeof(uint32_t),
                   &output));

  return OK_STATUS();
}
