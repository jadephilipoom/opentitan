# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load(
    "//rules:certificates.bzl",
    "certificate_template",
)
load(
    "//rules/opentitan:defs.bzl",
    "EARLGREY_TEST_ENVS",
    "OPENTITAN_CPU",
    "opentitan_test",
)

package(default_visibility = ["//visibility:public"])

certificate_template(
    name = "generic_template",
    template = "generic.hjson",
)

certificate_template(
    name = "example_template",
    template = "example.hjson",
)

certificate_template(
    name = "uds_template",
    template = "uds.hjson",
)

certificate_template(
    name = "cdi_0_template",
    template = "cdi_0.hjson",
)

certificate_template(
    name = "cdi_1_template",
    template = "cdi_1.hjson",
)

cc_library(
    name = "asn1",
    srcs = ["asn1.c"],
    hdrs = ["asn1.h"],
    deps = [
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:status",
    ],
)

cc_test(
    name = "asn1_unittest",
    srcs = ["asn1_unittest.cc"],
    deps = [
        ":asn1",
        "@googletest//:gtest_main",
    ],
)

cc_library(
    name = "dice",
    srcs = ["dice.c"],
    hdrs = ["dice.h"],
    target_compatible_with = [OPENTITAN_CPU],
    deps = [
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:status",
        "//sw/device/lib/testing/json:provisioning_data",
        "//sw/device/silicon_creator/lib:attestation",
        "//sw/device/silicon_creator/lib:attestation_key_diversifiers",
        "//sw/device/silicon_creator/lib:otbn_boot_services",
        "//sw/device/silicon_creator/lib/cert:cdi_0_template_library",
        "//sw/device/silicon_creator/lib/cert:cdi_1_template_library",
        "//sw/device/silicon_creator/lib/cert:uds_template_library",
        "//sw/device/silicon_creator/lib/drivers:hmac",
        "//sw/device/silicon_creator/lib/drivers:keymgr",
        "//sw/device/silicon_creator/lib/drivers:lifecycle",
        "//sw/otbn/crypto:boot",
    ],
)

opentitan_test(
    name = "dice_benchmark_functest",
    srcs = ["dice_benchmark_functest.c"],
    exec_env = EARLGREY_TEST_ENVS,
    deps = [
        ":dice",
        "//sw/device/lib/base:status",
        "//sw/device/lib/crypto/drivers:entropy",
        "//sw/device/lib/testing:keymgr_testutils",
        "//sw/device/lib/testing:otp_ctrl_testutils",
        "//sw/device/lib/testing:profile",
        "//sw/device/lib/testing:rstmgr_testutils",
        "//sw/device/lib/testing/json:provisioning_data",
        "//sw/device/lib/testing/test_framework:check",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/silicon_creator/lib:otbn_boot_services",
        "//sw/device/silicon_creator/lib/drivers:kmac",
        "//sw/device/silicon_creator/manuf/lib:flash_info_fields",
        "//sw/otbn/crypto:boot",
    ],
)
