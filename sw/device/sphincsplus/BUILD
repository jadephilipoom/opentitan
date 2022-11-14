# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

package(default_visibility = ["//visibility:public"])

load("@bazel_skylib//rules:common_settings.bzl", "string_flag")
load("//rules:opentitan.bzl", "OPENTITAN_CPU")
load(
    "//rules:opentitan_test.bzl",
    "opentitan_functest",
    "verilator_params",
)

# Custom flag for specifying the SPHINCS+ parameter set.
string_flag(
  name = "spx_params",
  build_setting_default = "shake_128f")
config_setting(
  name = "shake_128f",
  flag_values = { ":spx_params" : "shake_128f" },
)
config_setting(
  name = "shake_128s",
  flag_values = { ":spx_params" : "shake_128s" },
)
config_setting(
  name = "shake_192f",
  flag_values = { ":spx_params" : "shake_192f" },
)
config_setting(
  name = "shake_192s",
  flag_values = { ":spx_params" : "shake_192s" },
)
config_setting(
  name = "shake_256f",
  flag_values = { ":spx_params" : "shake_256f" },
)
config_setting(
  name = "shake_256s",
  flag_values = { ":spx_params" : "shake_256s" },
)

# Custom flag for the SPHINCS+ thash setting (simple/robust).
string_flag(name = "spx_thash", build_setting_default = "simple")
config_setting(
  name = "thash_simple",
  flag_values = { ":spx_thash" : "simple" },
)
config_setting(
  name = "thash_robust",
  flag_values = { ":spx_thash" : "robust" },
)

opentitan_functest(
    name = "verify_test",
    srcs = ["verify.c"],
    verilator = verilator_params(
        timeout = "eternal",
    ),
    # Add the THASH setting as a local define for helpful printouts.
    local_defines = select({
      ":thash_simple" : ["THASH=simple"],
      ":thash_robust" : ["THASH=robust"],
    }),
    deps = [
        ":api",
        ":message_keys",
        ":test_params",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/runtime:ibex",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/lib/testing:entropy_testutils",
    ],
)

opentitan_functest(
    name = "shake_test",
    srcs = ["shake_test.c"],
    verilator = verilator_params(
        timeout = "long",
    ),
    deps = [
        ":fips202",
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
    deps = [
      "//sw/device/lib/base:memory",
      "//sw/device/lib/base:mmio",
      "//sw/device/lib/dif:kmac",
      "//sw/device/lib/runtime:hart",
      "//sw/device/lib/runtime:log",
      "//hw/top_earlgrey/sw/autogen:top_earlgrey",
    ]
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
    defines =
      select({
        ":shake_128f":["PARAMS=sphincs-shake-128f"],
        ":shake_128s":["PARAMS=sphincs-shake-128s"],
        ":shake_192f":["PARAMS=sphincs-shake-192f"],
        ":shake_192s":["PARAMS=sphincs-shake-192s"],
        ":shake_256f":["PARAMS=sphincs-shake-256f"],
        ":shake_256s":["PARAMS=sphincs-shake-256s"],
      }),
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
    srcs = select({
      "thash_simple": ["thash_shake_simple.c"],
      "thash_robust": ["thash_shake_robust.c"],
    }),
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
