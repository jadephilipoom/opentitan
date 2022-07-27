# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

"""Autogeneration rules for OpenTitan.

The rules in this file are for autogenerating various file resources
used by the OpenTitan build, such as register definition files generated
from hjson register descriptions.
"""

def _hjson_header(ctx):
    header = ctx.actions.declare_file("{}.h".format(ctx.label.name))
    ctx.actions.run(
        outputs = [header],
        inputs = ctx.files.srcs + [ctx.executable._regtool],
        arguments = [
            "-D",
            "-q",
            "-o",
            header.path,
        ] + [src.path for src in ctx.files.srcs],
        executable = ctx.executable._regtool,
    )

    tock = ctx.actions.declare_file("{}.rs".format(ctx.label.name))
    ctx.actions.run(
        outputs = [tock],
        inputs = ctx.files.srcs + [ctx.executable._regtool, ctx.file.version_stamp],
        arguments = [
            "--tock",
            "--version-stamp={}".format(ctx.file.version_stamp.path),
            "-q",
            "-o",
            tock.path,
        ] + [src.path for src in ctx.files.srcs],
        executable = ctx.executable._regtool,
    )

    return [
        CcInfo(compilation_context = cc_common.create_compilation_context(
            includes = depset([header.dirname]),
            headers = depset([header]),
        )),
        DefaultInfo(files = depset([header, tock])),
        OutputGroupInfo(
            header = depset([header]),
            tock = depset([tock]),
        ),
    ]

autogen_hjson_header = rule(
    implementation = _hjson_header,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "version_stamp": attr.label(
            default = "//util:full_version_file",
            allow_single_file = True,
        ),
        "_regtool": attr.label(
            default = "//util:regtool",
            executable = True,
            cfg = "exec",
        ),
    },
)

def _chip_info(ctx):
    header = ctx.actions.declare_file("chip_info.h")
    ctx.actions.run(
        outputs = [header],
        inputs = [
            ctx.file.version,
            ctx.executable._tool,
        ],
        arguments = [
            "-o",
            header.dirname,
            "--ot_version_file",
            ctx.file.version.path,
        ],
        executable = ctx.executable._tool,
    )
    return [
        CcInfo(compilation_context = cc_common.create_compilation_context(
            includes = depset([header.dirname]),
            headers = depset([header]),
        )),
        DefaultInfo(files = depset([header])),
    ]

autogen_chip_info = rule(
    implementation = _chip_info,
    attrs = {
        "version": attr.label(
            default = "//util:ot_version_file",
            allow_single_file = True,
        ),
        "_tool": attr.label(
            default = "//util:rom_chip_info",
            executable = True,
            cfg = "exec",
        ),
    },
)

def _otp_image(ctx):
    # TODO(dmcardle) I don't like hardcoding the width in the filename. Maybe we
    # can write it into some metadata in the file instead.
    output = ctx.actions.declare_file(ctx.attr.name + ".24.vmem")
    ctx.actions.run(
        outputs = [output],
        inputs = [
            ctx.file.src,
            ctx.file.lc_state_def,
            ctx.file.mmap_def,
            ctx.executable._tool,
        ],
        arguments = [
            "--quiet",
            "--lc-state-def",
            ctx.file.lc_state_def.path,
            "--mmap-def",
            ctx.file.mmap_def.path,
            "--img-cfg",
            ctx.file.src.path,
            "--out",
            "{}/{}.BITWIDTH.vmem".format(output.dirname, ctx.attr.name),
        ],
        executable = ctx.executable._tool,
    )
    return [DefaultInfo(files = depset([output]), data_runfiles = ctx.runfiles(files = [output]))]

otp_image = rule(
    implementation = _otp_image,
    attrs = {
        "src": attr.label(allow_single_file = True),
        "lc_state_def": attr.label(
            allow_single_file = True,
            default = "//hw/ip/lc_ctrl/data:lc_ctrl_state.hjson",
            doc = "Life-cycle state definition file in Hjson format.",
        ),
        "mmap_def": attr.label(
            allow_single_file = True,
            default = "//hw/ip/otp_ctrl/data:otp_ctrl_mmap.hjson",
            doc = "OTP Controller memory map file in Hjson format.",
        ),
        "_tool": attr.label(
            default = "//util/design:gen-otp-img",
            executable = True,
            cfg = "exec",
        ),
    },
)

def _cryptotest_header(ctx):
    '''
    Implementation of the Bazel rule for generating crypto test vectors.

    Test vectors can come in three sources:
      1. Hard-coded HJSON files
      2. Random test generation scripts
      3. External data sources (e.g. wycheproof)

    In cases (2) and (3), we need to do an initial preprocessing step in order
    to get the standard HJSON format of test vectors (to generate the random
    tests and to parse the external data, respectively). In all cases, we then
    run an algorithm-specific script to translate the HJSON file into a C
    header based on a template.

    Case (1) requires the source HJSON file to be listed in `srcs` as the only
    .hjson source.

    Case (2) requires the test-generation script to be included as the `parser`
    attribute.

    Case (3) requires a data-parsing script to be included as the `parser`
    attribute and the external data source to be included as the
    `parser_input`.

    Assumes test-parsing scripts (which translate externally-sourced test
    vectors into HJSON) accept the following syntax:
      <script> --template <header template> <input file> dst.hjson

    ...where <input file> is the unparsed test data and dst.hjson is the HJSON
    file to which the script writes the test vectors.

    ALL CASES must have the script to translate from HJSON to header file
    included as `test_setter`, and the header template included in `srcs` as
    the only file with a `.tpl` extension.

    Assumes that `test_setter` scripts accept the following syntax:
      <script> tests.hjson dst.h

    ...where tests.hjson is the file containing the HJSON test vectors and
    dst.h is the header file to which the output will be written.
    '''

    # Create HJSON file for test vectors (in the hardcoded case, it will already exist)
    if ctx.attr.testset == 'random':
      hjson = ctx.actions.declare_file(ctx.attr.algorithm + "_" + ctx.attr.testset + ".hjson")
      ctx.actions.run(
          outputs = [hjson],
          inputs = ctx.files.srcs + ctx.files.deps + [ctx.executable.parser, ctx.file.template],
          arguments = ['20', hjson.path],
          executable = ctx.executable.parser,
      )
    elif ctx.attr.testset == 'wycheproof':
      hjson = ctx.actions.declare_file(ctx.attr.algorithm + "_" + ctx.attr.testset + ".hjson")
      infiles = [f for f in ctx.files.data if f.basename == ctx.attr.parser_input]
      if len(infiles) != 1:
        fail("Expected 1 dependency file to match `parser_input`, got: " + str(infiles))
      parser_input = infiles[0]
      ctx.actions.run(
          outputs = [hjson],
          inputs = ctx.files.srcs + ctx.files.deps + [ctx.executable.parser, ctx.file.template, parser_input],
          arguments = ["--template",
                       ctx.file.template.path,
                       parser_input.path,
                       hjson.path],
          executable = ctx.executable.parser,
      )
    elif ctx.attr.testset == 'hardcoded':
      hjsonfiles = [f for f in ctx.files.srcs if f.extension == "hjson"]
      if len(hjsonfiles) != 1:
        fail("For hardcoded test vectors, the cryptotest rule expects a single source HJSON file. Instead, got " + str([f.path for f in ctx.files.srcs]))
      hjson = hjsonfiles[0]
    else:
      fail("Unrecognized test set: " + ctx.attr.testset + " Options are: random, wycheproof, hardcoded")

    header = ctx.actions.declare_file(ctx.attr.algorithm + "_testvectors.h")

    ctx.actions.run(
        outputs = [header],
        inputs = ctx.files.srcs + ctx.files.deps + [ctx.executable.test_setter, hjson],
        arguments = [hjson.path, header.path],
        executable = ctx.executable.test_setter,
    )

    outs = [header] if ctx.attr.testset == 'hardcoded' else [header, hjson]
    return [
        CcInfo(compilation_context = cc_common.create_compilation_context(
            includes = depset([header.dirname]),
            headers = depset([header]),
        )),
        DefaultInfo(files = depset(outs)),
        OutputGroupInfo(
            header = depset([header]),
            hjson = depset([hjson]),
        ),
    ]

autogen_cryptotest_header = rule(
    implementation = _cryptotest_header,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),
        "data": attr.label_list(allow_files = True),
        "testset": attr.string(default='hardcoded', values=['hardcoded','random','wycheproof']),
        "algorithm": attr.string(),
        "template" : attr.label(
            allow_single_file = [".tpl"],
            mandatory = True),
        "test_setter": attr.label(
            executable = True,
            mandatory = True,
            cfg = "exec",
        ),
        "parser": attr.label(
            executable = True,
            cfg = "exec",
        ),
        "parser_input": attr.string(),
    },
)
