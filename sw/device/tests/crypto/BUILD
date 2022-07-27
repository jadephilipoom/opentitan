# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:opentitan_test.bzl", "opentitan_functest", "verilator_params")
load("//rules:autogen.bzl", "autogen_cryptotest_header", "autogen_cryptotest_hjson_external")

package(default_visibility = ["//visibility:public"])

opentitan_functest(
    name = "ecdsa_p256_functest",
    srcs = ["ecdsa_p256_functest.c"],
    verilator = verilator_params(
        timeout = "long",
    ),
    deps = [
        "//sw/device/lib/crypto:otbn_util",
        "//sw/device/lib/crypto/drivers:hmac",
        "//sw/device/lib/crypto/drivers:otbn",
        "//sw/device/lib/crypto/ecdsa_p256",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing:entropy_testutils",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

cc_library(
    name = "ecdsa_p256_verify_testvectors",
    hdrs = ["ecdsa_p256_verify_testvectors.h"],
)

opentitan_functest(
    name = "ecdsa_p256_verify_functest",
    srcs = ["ecdsa_p256_verify_functest.c"],
    verilator = verilator_params(
        timeout = "long",
    ),
    deps = [
        ":ecdsa_p256_verify_testvectors",
        "//sw/device/lib/crypto:otbn_util",
        "//sw/device/lib/crypto/drivers:hmac",
        "//sw/device/lib/crypto/drivers:otbn",
        "//sw/device/lib/crypto/ecdsa_p256",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

autogen_cryptotest_hjson_external(
    name = "rsa_3072_verify_testvectors_wycheproof",
    deps = [
        "//sw/vendor/wycheproof/testvectors:rsa_signature",
    ],
    parser = "//sw/device/tests/crypto/testvectors/wycheproof:rsa_3072_verify_parse_testvectors",
    parser_input = "rsa_signature_3072_sha256_test.json",
)

autogen_cryptotest_header(
    name = "rsa_3072_verify_testvectors_wycheproof_header",
    template = "rsa_3072_verify_testvectors.h.tpl",
    deps = [
        ":rsa_3072_verify_testvectors_wycheproof",
    ],
    test_setter = "rsa_3072_verify_set_testvectors.py",
)

opentitan_functest(
    name = "rsa_3072_verify_functest_wycheproof",
    srcs = ["rsa_3072_verify_functest.c"],
    verilator = verilator_params(
        timeout = "long",
    ),
    deps = [
        ":rsa_3072_verify_testvectors_wycheproof_header",
        "//sw/device/lib/crypto:otbn_util",
        "//sw/device/lib/crypto/drivers:hmac",
        "//sw/device/lib/crypto/drivers:otbn",
        "//sw/device/lib/crypto/rsa_3072:rsa_3072_verify",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)

autogen_cryptotest_header(
    name = "rsa_3072_verify_testvectors_hardcoded_header",
    template = "rsa_3072_verify_testvectors.h.tpl",
    deps = [
        "//sw/device/tests/crypto/testvectors:rsa_3072_verify_hardcoded.hjson",
    ],
    test_setter = "rsa_3072_verify_set_testvectors.py",
)

opentitan_functest(
    name = "rsa_3072_verify_functest_hardcoded",
    srcs = ["rsa_3072_verify_functest.c"],
    verilator = verilator_params(
        timeout = "long",
    ),
    deps = [
        ":rsa_3072_verify_testvectors_hardcoded_header",
        "//sw/device/lib/crypto:otbn_util",
        "//sw/device/lib/crypto/drivers:hmac",
        "//sw/device/lib/crypto/drivers:otbn",
        "//sw/device/lib/crypto/rsa_3072:rsa_3072_verify",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
    ],
)
