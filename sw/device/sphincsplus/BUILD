load("//rules:opentitan.bzl", "OPENTITAN_CPU")
load(
    "//rules:opentitan_test.bzl",
    "opentitan_functest",
    "verilator_params",
)

opentitan_functest(
    name = "verify_test",
    srcs = ["verify.c"],
    verilator = verilator_params(
        timeout = "eternal",
    ),
    deps = [
        ":api",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:mmio",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
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
      ":params",
      ":wots",
      ":fors",
      ":hash",
      ":thash",
      ":address",
      ":randombytes",
      ":utils",
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
    ],
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
      ":utilsx1",
    ],
)

cc_library(
    name = "hash",
    srcs = ["hash_shake.c"],
    hdrs = ["hash.h"],
    deps = [
      ":params",
      ":hash",
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
    hdrs = ["params.h"],
)

cc_library(
    name = "randombytes",
    srcs = ["randombytes.c"],
    hdrs = ["randombytes.h"],
    deps = [
      "//sw/device/lib/base:hardened",
      "//sw/device/lib/base:memory",
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
      ":utils",
      ":fips202",
    ],
)


cc_library(
    name = "utils",
    srcs = ["utils.c"],
    hdrs = ["utils.h"],
    deps = [
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
      ":wots",
      ":hash",
      ":thash",
      ":address",
      ":utils",
    ],
)
