#! /usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import argparse

# Maps clock rate units to cycles per second.
CLOCK_RATES = {'MHz' : 1_000_000, 'GHz' : 1_000_000_000,}

def interpret_clock_rate(clock):
    '''Reads the clock rate argument string and returns cycles/second.'''
    for unit in CLOCK_RATES:
        if clock.endswith(unit):
            clock = clock[:-len(unit)]
            return int(clock) * CLOCK_RATES[unit]
    raise ValueError(f'Could not interpret clock rate units for "{clock}". Possible units are {", ".join(CLOCK_RATES.keys())}')

def main():
    parser = argparse.ArgumentParser(
            description='Compute throughput from clock rate, data size, and cycles.')
    parser.add_argument(
            "--clock", "-r",
            type=str,
            required=False,
            default='100MHz',
            help='Clock rate as a string (e.g. "100MHz" or "1GHz").')
    parser.add_argument(
            "--bytes", "-b",
            type=int,
            required=True,
            help='Number of bytes processed.')
    parser.add_argument(
            "--cycles", "-c",
            type=int,
            required=True,
            help='Number of cycles it took to process the bytes.')
    args = parser.parse_args()

    cycles_per_second = interpret_clock_rate(args.clock)
    bytes_per_second = (cycles_per_second * args.bytes)  // args.cycles
    kilobytes_per_second = bytes_per_second / 1000
    megabytes_per_second = kilobytes_per_second / 1000
    megabits_per_second = (kilobytes_per_second * 8) / 1000
    print(f'{bytes_per_second} bytes per second @{args.clock}.')
    print(f'{kilobytes_per_second:.2f} kilobytes per second @{args.clock}.')
    print(f'{megabytes_per_second:.2f} megabytes per second @{args.clock}.')
    print(f'{megabits_per_second:.2f} megabits per second @{args.clock}.')

if __name__ == '__main__':
    main()
