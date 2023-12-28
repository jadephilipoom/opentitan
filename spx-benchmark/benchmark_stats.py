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
  # Note: encoding errors are ignored when reading from the log file because
  # Verilator prints out carriage returns that cause issues if not ignored.
  parser.add_argument('log',
                      metavar='FILE',
                      type=argparse.FileType('r', errors='ignore'),
                      help='Log file to read.')
  args = parser.parse_args()

  # Read the log and find the cycle counts.
  with args.log as log:
    matches = re.findall(VERIFY_CYCLES_PATTERN, log.read())
  if not matches:
    raise ValueError(f'No cycle counts found! Did the benchmark complete successfully?')

  # Interpret the cycle counts as integers.
  cycles = [int(m) for m in matches]

  # Print some helpful statistics.
  print(f'Number of tests: {len(cycles)}')
  print(f'Min cycle count: {min(cycles)}')
  print(f'Max cycle count: {max(cycles)}')
  print(f'Avg cycle count: {round(sum(cycles) / len(cycles))}')
