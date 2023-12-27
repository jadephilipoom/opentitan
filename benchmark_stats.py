#!/usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import argparse
import re

VERIFY_CYCLES_PATTERN = re.compile('Verification took ([0-9]+) cycles.')

if __name__ == '__main__':
  parser = argparse.ArgumentParser(
      description='Extract signature verification cycle counts from a log file and print some statistics about them.')
  parser.add_argument('log',
                      metavar='FILE',
                      type=argparse.FileType('r'),
                      help='Log file to read.')
  args = parser.parse_args()

  # Read the log and find the cycle counts.
  with args.log as log:
    log_content = template.read()
  matches = re.findall(VERIFY_CYCLES_PATTERN, log_content)
  if not matches:
    raise ValueError(f'No cycle counts found! Did the benchmark complete successfully?')

  # Interpret the cycle counts as integers.
  cycles = []
  for m in matches:
    cycles_str = m.group(1)
    if not cycles_str.isdecimal():
      raise ValueError(f'Cannot interpret cycle count {cycles_str} from regex match {m.group(0)}.')
    cycles.append(int(cycles_str))

  # Print some helpful statistics.
  print(f'Number of tests: {len(cycles)}')
  print(f'Min cycle count: {min(cycles)}')
  print(f'Max cycle count: {max(cycles)}')
  print(f'Avg cycle count: {sum(cycles) / len(cycles)}')
