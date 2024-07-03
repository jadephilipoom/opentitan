#! /usr/bin/env python3

import argparse
import re
import matplotlib.pyplot as plt

PROCESS = re.compile(r'process with input length (\d+) took (\d+) cycles.')

def analyze_process_benchmarks(process):
    x = []
    y = []
    for input_len in process:
        x.append(input_len)
        y.append(process[input_len])

    plt.subplots(figsize=(20,10))
    plt.stem(x, y)
    plt.savefig('kmac_padding.png')
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Analyze a test log from KMAC padding profiling.')
    parser.add_argument('log', type=argparse.FileType('r'), help='File containing the test log.')
    args = parser.parse_args()

    lines = args.log.readlines()
    process = {}
    for line in lines:
        result = PROCESS.search(line)
        if result is not None:
            input_len = int(result.group(1))
            cycles = int(result.group(2))
            if input_len in process:
               raise ValueError(f'More than one `process` line for input length {input_len}.')
            process[input_len] = cycles

    if not process:
        raise ValueError('No lines matched the regular expression for `process` benchmarks.')

    analyze_process_benchmarks(process)
