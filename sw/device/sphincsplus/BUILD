# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

package(default_visibility = ["//visibility:public"])

load("@bazel_skylib//rules:common_settings.bzl", "string_flag")
load("@bazel_skylib//lib:selects.bzl", "selects")
load("//rules:opentitan.bzl", "OPENTITAN_CPU")
load(
    "//rules:opentitan_test.bzl",
    "opentitan_functest",
    "verilator_params",
)

# Custom flag for specifying the SPHINCS+ parameter set.
string_flag(
    name = "spx_params",
    build_setting_default = "shake_128f_simple",
)

config_setting(
    name = "shake_128f_simple",
    flag_values = {":spx_params": "shake_128f_simple"},
)

config_setting(
    name = "shake_128s_simple",
    flag_values = {":spx_params": "shake_128s_simple"},
)

config_setting(
    name = "shake_192f_simple",
    flag_values = {":spx_params": "shake_192f_simple"},
)

config_setting(
    name = "shake_192s_simple",
    flag_values = {":spx_params": "shake_192s_simple"},
)

config_setting(
    name = "shake_256f_simple",
    flag_values = {":spx_params": "shake_256f_simple"},
)

config_setting(
    name = "shake_256s_simple",
    flag_values = {":spx_params": "shake_256s_simple"},
)

config_setting(
    name = "shake_128f_robust",
    flag_values = {":spx_params": "shake_128f_robust"},
)

config_setting(
    name = "shake_128s_robust",
    flag_values = {":spx_params": "shake_128s_robust"},
)

config_setting(
    name = "shake_192f_robust",
    flag_values = {":spx_params": "shake_192f_robust"},
)

config_setting(
    name = "shake_192s_robust",
    flag_values = {":spx_params": "shake_192s_robust"},
)

config_setting(
    name = "shake_256f_robust",
    flag_values = {":spx_params": "shake_256f_robust"},
)

config_setting(
    name = "shake_256s_robust",
    flag_values = {":spx_params": "shake_256s_robust"},
)

# Setting groups for the SPHINCS+ thash setting (simple/robust).
selects.config_setting_group(
    name = "thash_simple",
    match_any = [
        ":shake_128f_simple",
        ":shake_128s_simple",
        ":shake_192f_simple",
        ":shake_192s_simple",
        ":shake_256f_simple",
        ":shake_256s_simple",
    ],
)

selects.config_setting_group(
    name = "thash_robust",
    match_any = [
        ":shake_128f_robust",
        ":shake_128s_robust",
        ":shake_192f_robust",
        ":shake_192s_robust",
        ":shake_256f_robust",
        ":shake_256s_robust",
    ],
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
        ":address",
        ":fors",
        ":hash",
        ":merkle",
        ":params",
        ":randombytes",
        ":thash",
        ":utils",
        ":utils2",
        ":wots",
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
    deps = [
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/dif:kmac",
        "//sw/device/lib/runtime:hart",
        "//sw/device/lib/runtime:log",
        "//sw/device/sphincsplus/drivers:kmac",
    ],
)

cc_library(
    name = "fors",
    srcs = ["fors.c"],
    hdrs = ["fors.h"],
    deps = [
        ":address",
        ":hash",
        ":thash",
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
        ":address",
        ":fips202",
        ":params",
        ":utils",
    ],
)

cc_library(
    name = "merkle",
    srcs = ["merkle.c"],
    hdrs = ["merkle.h"],
    deps = [
        ":address",
        ":params",
        ":utils",
        ":utilsx1",
        ":wots",
        ":wotsx1",
    ],
)

cc_library(
    name = "params",
    hdrs = [
        "params.h",
        ":shake_offsets.h",
        "//sw/device/sphincsplus/params:params-sphincs-shake-128f.h",
        "//sw/device/sphincsplus/params:params-sphincs-shake-128s.h",
        "//sw/device/sphincsplus/params:params-sphincs-shake-192f.h",
        "//sw/device/sphincsplus/params:params-sphincs-shake-192s.h",
        "//sw/device/sphincsplus/params:params-sphincs-shake-256f.h",
        "//sw/device/sphincsplus/params:params-sphincs-shake-256s.h",
    ],
    defines =
        select({
            ":shake_128f_simple": ["PARAMS=sphincs-shake-128f"],
            ":shake_128s_simple": ["PARAMS=sphincs-shake-128s"],
            ":shake_192f_simple": ["PARAMS=sphincs-shake-192f"],
            ":shake_192s_simple": ["PARAMS=sphincs-shake-192s"],
            ":shake_256f_simple": ["PARAMS=sphincs-shake-256f"],
            ":shake_256s_simple": ["PARAMS=sphincs-shake-256s"],
            ":shake_128f_robust": ["PARAMS=sphincs-shake-128f"],
            ":shake_128s_robust": ["PARAMS=sphincs-shake-128s"],
            ":shake_192f_robust": ["PARAMS=sphincs-shake-192f"],
            ":shake_192s_robust": ["PARAMS=sphincs-shake-192s"],
            ":shake_256f_robust": ["PARAMS=sphincs-shake-256f"],
            ":shake_256s_robust": ["PARAMS=sphincs-shake-256s"],
        }),
)

cc_library(
    name = "randombytes",
    srcs = ["randombytes.c"],
    hdrs = ["randombytes.h"],
    deps = [
        "//sw/device/lib/base:hardened",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/crypto/drivers:entropy",
        "//sw/device/lib/runtime:hart",
    ],
)

cc_library(
    name = "shake_offsets",
    srcs = [],
    hdrs = ["shake_offsets.h"],
)

cc_library(
    name = "thash",
    srcs = select({
        "thash_simple": ["thash_shake_simple.c"],
        "thash_robust": ["thash_shake_robust.c"],
    }),
    hdrs = ["thash.h"],
    deps = [
        ":address",
        ":fips202",
        ":params",
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
    ],
)

cc_library(
    name = "utils2",
    srcs = ["utils2.c"],
    hdrs = ["utils2.h"],
    deps = [
        ":address",
        ":hash",
        ":params",
        ":thash",
        ":utils",
        "//sw/device/lib/base:memory",
    ],
)

cc_library(
    name = "utilsx1",
    srcs = ["utilsx1.c"],
    hdrs = ["utilsx1.h"],
    deps = [
        ":address",
        ":context",
        ":params",
        ":thash",
        ":utils",
    ],
)

cc_library(
    name = "wots",
    srcs = ["wots.c"],
    hdrs = ["wots.h"],
    deps = [
        ":address",
        ":context",
        ":hash",
        ":params",
        ":thash",
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
        ":address",
        ":hash",
        ":params",
        ":thash",
        ":utils",
    ],
)
