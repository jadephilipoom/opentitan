#!/usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
import sys
import argparse
import os 

sys.path.append(os.path.realpath(os.path.dirname(os.path.realpath(__file__)) + '../../../../../../'))

from sw.otbn.crypto.tests.dilithiumpy_bench_otbn import bench_dilithium
from hw.ip.otbn.util import otbn_sim_py_shared



def main() -> int:
    otbn_sim_py_shared.init()
    parser = argparse.ArgumentParser()
    parser.add_argument('simulator',
                        help='Path to the standalone OTBN simulator.')
    # parser.add_argument('expected',
    #                     metavar='FILE',
    #                     type=argparse.FileType('r'),
    #                     help=(f'File containing expected register values. '
    #                           f'Registers that are not listed are allowed to '
    #                           f'have any value, except for {ERR_BITS}. If '
    #                           f'{ERR_BITS} is not listed, the test will assume '
    #                           f'there are no errors expected (i.e. {ERR_BITS}'
    #                           f'= 0).'))
    print("SW/OTBN/CRYPTO")
    parser.add_argument('elf',
                        help='Path to the .elf files for the OTBN programs'
                        'prefixed with the name of the test and separated with'
                        ' "#" sign.')
    parser.add_argument('-v', '--verbose', action='store_true')

    args = parser.parse_args()
    print(args)
    print("Start")
    elfs = [item for item in args.elf.split(',')]

    for e in elfs:
        name, path = e.split("#")
        otbn_sim_py_shared.ELF_MAP[name] = path
    is_base = "base" in args.elf
    if "key_pair" in args.elf:
        bench_dilithium.run_bench("key_pair", is_base)
    elif "sign" in args.elf:
        bench_dilithium.run_bench("sign", is_base)
    elif "verify" in args.elf:
        bench_dilithium.run_bench("verify", is_base)

    print("Done")

    return 0


if __name__ == "__main__":
    sys.exit(main())
