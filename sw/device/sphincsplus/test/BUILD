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

opentitan_functest(
    name = "verify_test",
    srcs = ["verify.c"],
    # Add the full parameters as a local define for helpful printouts.
    local_defines = select({
        "//sw/device/sphincsplus:shake_128f_simple": ["TESTNAME=sphincs-shake-128f-simple"],
        "//sw/device/sphincsplus:shake_128s_simple": ["TESTNAME=sphincs-shake-128s-simple"],
        "//sw/device/sphincsplus:shake_192f_simple": ["TESTNAME=sphincs-shake-192f-simple"],
        "//sw/device/sphincsplus:shake_192s_simple": ["TESTNAME=sphincs-shake-192s-simple"],
        "//sw/device/sphincsplus:shake_256f_simple": ["TESTNAME=sphincs-shake-256f-simple"],
        "//sw/device/sphincsplus:shake_256s_simple": ["TESTNAME=sphincs-shake-256s-simple"],
        "//sw/device/sphincsplus:shake_128f_robust": ["TESTNAME=sphincs-shake-128f-robust"],
        "//sw/device/sphincsplus:shake_128s_robust": ["TESTNAME=sphincs-shake-128s-robust"],
        "//sw/device/sphincsplus:shake_192f_robust": ["TESTNAME=sphincs-shake-192f-robust"],
        "//sw/device/sphincsplus:shake_192s_robust": ["TESTNAME=sphincs-shake-192s-robust"],
        "//sw/device/sphincsplus:shake_256f_robust": ["TESTNAME=sphincs-shake-256f-robust"],
        "//sw/device/sphincsplus:shake_256s_robust": ["TESTNAME=sphincs-shake-256s-robust"],
    }),
    verilator = verilator_params(
        timeout = "eternal",
    ),
    deps = [
        ":test_params",
        "//sw/device/sphincsplus:api",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/runtime:ibex",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/lib/testing:entropy_testutils",
    ] + select({
        "//sw/device/sphincsplus:shake_128f_simple": [
            "//sw/device/sphincsplus/test/sphincs-shake-128f-simple:message_keys",
        ],
        "//sw/device/sphincsplus:shake_128s_simple": [
            "//sw/device/sphincsplus/test/sphincs-shake-128s-simple:message_keys",
        ],
        "//sw/device/sphincsplus:shake_192f_simple": [
            "//sw/device/sphincsplus/test/sphincs-shake-192f-simple:message_keys",
        ],
        "//sw/device/sphincsplus:shake_192s_simple": [
            "//sw/device/sphincsplus/test/sphincs-shake-192s-simple:message_keys",
        ],
        "//sw/device/sphincsplus:shake_256f_simple": [
            "//sw/device/sphincsplus/test/sphincs-shake-256f-simple:message_keys",
        ],
        "//sw/device/sphincsplus:shake_256s_simple": [
            "//sw/device/sphincsplus/test/sphincs-shake-256s-simple:message_keys",
        ],
        "//sw/device/sphincsplus:shake_128f_robust": [
            "//sw/device/sphincsplus/test/sphincs-shake-128f-robust:message_keys",
        ],
        "//sw/device/sphincsplus:shake_128s_robust": [
            "//sw/device/sphincsplus/test/sphincs-shake-128s-robust:message_keys",
        ],
        "//sw/device/sphincsplus:shake_192f_robust": [
            "//sw/device/sphincsplus/test/sphincs-shake-192f-robust:message_keys",
        ],
        "//sw/device/sphincsplus:shake_192s_robust": [
            "//sw/device/sphincsplus/test/sphincs-shake-192s-robust:message_keys",
        ],
        "//sw/device/sphincsplus:shake_256f_robust": [
            "//sw/device/sphincsplus/test/sphincs-shake-256f-robust:message_keys",
        ],
        "//sw/device/sphincsplus:shake_256s_robust": [
            "//sw/device/sphincsplus/test/sphincs-shake-256s-robust:message_keys",
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
        "//sw/device/lib/base:macros",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/sphincsplus:fips202",
    ],
)

opentitan_functest(
    name = "thash_test",
    srcs = ["thash_test.c"],
    verilator = verilator_params(
        timeout = "long",
    ),
    deps = [
        "//sw/device/lib/base:memory",
        "//sw/device/lib/crypto/drivers:entropy",
        "//sw/device/lib/runtime:ibex",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing:entropy_testutils",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/sphincsplus:context",
        "//sw/device/sphincsplus:thash",
    ],
)

cc_library(
    name = "test_params",
    hdrs = ["test_params.h"],
)
