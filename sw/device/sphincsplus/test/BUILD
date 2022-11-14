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
      "//sw/device/sphincsplus:thash_simple" : ["THASH=simple"],
      "//sw/device/sphincsplus:thash_robust" : ["THASH=robust"],
    }),
    deps = [
        ":test_params",
        "//sw/device/sphincsplus:api",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/runtime:ibex",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/lib/testing:entropy_testutils",
    ] + select({
      "//sw/device/sphincsplus:shake_128f": [
          "//sw/device/sphincsplus/test/sphincs-shake-128f:message_keys"
      ],
    }),
)

opentitan_functest(
    name = "shake_test",
    srcs = ["shake_test.c"],
    verilator = verilator_params(
        timeout = "long",
    ),
    deps = [
        "//sw/device/sphincsplus:fips202",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

cc_library(
    name = "test_params",
    hdrs = ["test_params.h"],
)

