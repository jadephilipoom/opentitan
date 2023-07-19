#!/usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

'''Create a SPHINCS+ parameters header file.

These files are intended to match the format from the SPHINCS+ reference
implementation, i.e. from this directory:
https://github.com/sphincs/sphincsplus/tree/035b39429d96ca554402b78f296f0de181674abd/ref/params
'''

import argparse
import re

from pathlib import Path

# Names of defines from the template header file.
SPX_N = 'SPX_N'
SPX_FULL_HEIGHT = 'SPX_FULL_HEIGHT'
SPX_D = 'SPX_D'
SPX_FORS_HEIGHT = 'SPX_FORS_HEIGHT'
SPX_FORS_TREES = 'SPX_FORS_TREES'
SPX_WOTS_W = 'SPX_WOTS_W'


def replace_define(template, name, new_value):
  pattern = re.compile(f'^#define {name} ([0-9]+)$', flags=re.MULTILINE)
  new_str, num_subs = re.subn(pattern, f'#define {name} {new_value}', template)
  if num_subs != 1:
    raise ValueError(f'Found {num_subs} occurrences of {pattern}, but '
                     'expected exactly 1.')
  return new_str


if __name__ == '__main__':
  parser = argparse.ArgumentParser(
      description='Create a SPHINCS+ parameters header file.')
  parser.add_argument('template',
                      metavar='FILE',
                      type=argparse.FileType('r'),
                      help='Header file to use as a template.')
  parser.add_argument('dst',
                      type=str,
                      help='Write result to this directory.')
  parser.add_argument('-n', '--security-bytes',
                      type=int,
                      required=True,
                      help=('Security parameter in bytes (called n in the '
                            f'spec and {SPX_N} in the headers).'))
  parser.add_argument('-hgt', '--height',
                      type=int,
                      required=True,
                      help=('Full height of the hypertree (called '
                            f'{SPX_FULL_HEIGHT} in the headers).'))
  parser.add_argument('-d', '--layers',
                      type=int,
                      required=True,
                      help=('Number of layers in the hypertree (called d in '
                            f'the spec and {SPX_D} in the headers.'))
  parser.add_argument('-lgt', '--fors-height',
                      type=int,
                      required=True,
                      help=('Height of the FORS tree (called log2(t) in the '
                            f'spec and {SPX_FORS_HEIGHT} in the headers).'))
  parser.add_argument('-k', '--fors-trees',
                      type=int,
                      required=True,
                      help=('Number of FORS trees (called k in the spec and '
                            f'{SPX_FORS_TREES} in the headers).'))
  parser.add_argument('-w', '--winternitz',
                      type=int,
                      required=True,
                      help=('Winternitz parameter (called w in the spec and '
                            f'{SPX_WOTS_W} in the headers).'))
  args = parser.parse_args()

  # Check that the destination directory exists.
  dst_dir = Path(args.dst)
  if not dst_dir.is_dir():
    raise ValueError(f'Destination directory {args.dst} does not exist.')

  # Read the template and replace the defines.
  with args.template as template:
    header = template.read()
  header = replace_define(header, SPX_N, args.security_bytes)
  header = replace_define(header, SPX_FULL_HEIGHT, args.height)
  header = replace_define(header, SPX_D, args.layers)
  header = replace_define(header, SPX_FORS_HEIGHT, args.fors_height)
  header = replace_define(header, SPX_FORS_TREES, args.fors_trees)
  header = replace_define(header, SPX_WOTS_W, args.winternitz)

  # Write result file.
  params_str = f'n{args.security_bytes}h{args.height}d{args.layers}lgt{args.fors_height}k{args.fors_trees}w{args.winternitz}'
  outfile = dst_dir / f'params-sphincs-{params_str}.h'
  with open(outfile, 'w') as out:
    out.write(header)
