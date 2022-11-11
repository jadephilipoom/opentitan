# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

package(default_visibility = ["//visibility:public"])

load("//rules:opentitan.bzl", "OPENTITAN_CPU")
load(
    "//rules:opentitan_test.bzl",
    "opentitan_functest",
    "verilator_params",
)

opentitan_functest(
    name = "verify_test",
    srcs = ["verify.c"],
    targets = ["verilator", "cw310_test_rom"],
    verilator = verilator_params(
        timeout = "eternal",
    ),
    deps = [
        ":api",
        ":message_keys",
        ":test_params",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

cc_library(
    name = "message_keys",
    srcs = [],
    hdrs = ["message_keys.inc"],
)

cc_library(
    name = "address",
    srcs = ["address.c"],
    hdrs = ["address.h"],
    deps = [
      ":params",
      ":utils",
    ],
)

cc_library(
    name = "api",
    srcs = ["sign.c"],
    hdrs = ["api.h"],
    deps = [
      ":params",
      ":wots",
      ":fors",
      ":hash",
      ":thash",
      ":address",
      ":randombytes",
      ":utils",
      ":utils2",
      ":merkle",
    ],
)

cc_library(
    name = "context",
    srcs = [],
    hdrs = ["context.h"],
)

cc_library(
    name = "fips202",
    srcs = ["fips202.c"],
    hdrs = ["fips202.h"],
)

cc_library(
    name = "fors",
    srcs = ["fors.c"],
    hdrs = ["fors.h"],
    deps = [
      ":hash",
      ":thash",
      ":address",
      ":utils",
      ":utils2",
      ":utilsx1",
    ],
)

cc_library(
    name = "hash",
    srcs = ["hash_shake.c"],
    hdrs = ["hash.h"],
    deps = [
      ":params",
      ":address",
      ":utils",
      ":fips202",
    ],
)

cc_library(
    name = "merkle",
    srcs = ["merkle.c"],
    hdrs = ["merkle.h"],
    deps = [
      ":params",
      ":wots",
      ":wotsx1",
      ":address",
      ":utils",
      ":utilsx1",
    ],
)

cc_library(
    name = "params",
    srcs = [],
    hdrs = ["params.h",
      ":shake_offsets.h",
      "//sw/device/sphincsplus/params:params-sphincs-shake-128f.h",
    ],

)

cc_library(
    name = "randombytes",
    srcs = ["randombytes.c"],
    hdrs = ["randombytes.h"],
    deps = [
      "//sw/device/lib/base:hardened",
      "//sw/device/lib/base:memory",
      "//sw/device/lib/runtime:hart",
      "//sw/device/lib/crypto/drivers:entropy",
    ],
)

cc_library(
    name = "shake_offsets",
    srcs = [],
    hdrs = ["shake_offsets.h"],
)

cc_library(
    name = "test_params",
    srcs = [],
    hdrs = ["test_params.h"],
)

cc_library(
    name = "thash",
    # Change source file below to switch between robust/simple thash
    # implementation.
    srcs = ["thash_shake_simple.c"],
    hdrs = ["thash.h"],
    deps = [
      ":params",
      ":address",
      ":fips202",
      ":utils",
    ],
)

cc_library(
    name = "utils",
    srcs = ["utils.c"],
    hdrs = ["utils.h"],
    deps = [
      ":context",
      ":params",
    ]
)

cc_library(
    name = "utils2",
    srcs = ["utils2.c"],
    hdrs = ["utils2.h"],
    deps = [
      "//sw/device/lib/base:memory",
      ":utils",
      ":params",
      ":hash",
      ":thash",
      ":address",
    ],
)

cc_library(
    name = "utilsx1",
    srcs = ["utilsx1.c"],
    hdrs = ["utilsx1.h"],
    deps = [
      ":context",
      ":params",
      ":thash",
      ":address",
      ":utils",
    ],
)

cc_library(
    name = "wots",
    srcs = ["wots.c"],
    hdrs = ["wots.h"],
    deps = [
      ":context",
      ":params",
      ":hash",
      ":thash",
      ":address",
      ":utils",
      ":utilsx1",
      ":wotsx1",
    ],
)

cc_library(
    name = "wotsx1",
    srcs = ["wotsx1.c"],
    hdrs = ["wotsx1.h"],
    deps = [
      ":params",
      ":hash",
      ":thash",
      ":address",
      ":utils",
    ],
)
