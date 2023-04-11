# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:otbn.bzl", "otbn_consttime_test", "otbn_sim_test")

package(default_visibility = ["//visibility:public"])

otbn_sim_test(
    name = "addmv_test",
    srcs = [
        "addmv_test.s",
    ],
    exp = "addmv_test.exp",
    deps = [
        "//sw/otbn/vector:addmv",
    ],
)

otbn_sim_test(
    name = "submv_test",
    srcs = [
        "submv_test.s",
    ],
    exp = "submv_test.exp",
    deps = [
        "//sw/otbn/vector:submv",
    ],
)
