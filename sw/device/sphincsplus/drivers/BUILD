# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "kmac",
    srcs = ["kmac.c"],
    hdrs = ["kmac.h"],
    deps = [
      "//hw/top_earlgrey/sw/autogen:top_earlgrey",
      "//hw/ip/kmac/data:kmac_regs",
      "//sw/device/lib/base:abs_mmio",
      "//sw/device/lib/base:memory",
    ],
)
