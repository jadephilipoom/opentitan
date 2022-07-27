#!/usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# This is a convenience script that sets a particular test set (for instance:
# hardcoded tests, random tests, wycheproof tests) for the entire repository,
# including both the crypto library tests under sw/device/tests/crypto and also
# sigverify tests under sw/device/silicon_creator/lib/sigverify.

import argparse
import subprocess
import sys

from pathlib import Path
from typing import Optional

# Top of the opentitan repository, detected relative to this file
REPO_TOP = Path(__file__).parent.parent.absolute()

# Directory for crypto library test scripts
CRYPTOLIB_TEST_DIR = REPO_TOP / 'sw' / 'device' / 'tests' / 'crypto'

# Directory for crypto library test vectors
CRYPTOLIB_TESTVECTORS_DIR = CRYPTOLIB_TEST_DIR / 'testvectors'

# Directory for sigverify test scripts and testvectors
SIGVERIFY_TEST_DIR = REPO_TOP / 'sw' / 'device' / 'silicon_creator' / 'lib' / 'sigverify' / 'sigverify_tests'

# Directory for Wycheproof test vectors
WYCHEPROOF_DIR = REPO_TOP / 'sw' / 'vendor' / 'wycheproof' / 'testvectors'

# Algorithm whose test sets should be used for sigverify tests.
SIGVERIFY_ALGORITHM = 'rsa_3072_verify'

# Default number of random tests per algorithm
DEFAULT_RANDOM_TESTS = 20

# Names of Wycheproof test files for each algorithm that uses Wycheproof tests.
WYCHEPROOF_FILE_NAMES = {
        'rsa_3072_verify' : 'rsa_signature_3072_sha256_test.json',
        }

def run_set_testvectors(set_script: Path, testvec_file: Path) -> None:
    '''Run the set_testvectors script provided to set the test vectors.

    Assumes the script takes a single argument which is the test vector file.
    '''
    if not set_script.exists():
        raise RuntimeError(f'Could not locate script: {set_testvec_script}')
    if not testvec_file.exists():
        raise RuntimeError(f'Could not locate test vector file: {testvec_file}')
    # Run the set_testvectors script on the test vector file.
    subprocess.run([set_script.absolute(), testvec_file.absolute()])

def set_testvectors(suffix: str, alg: Optional[str]) -> None:
    '''Set the specified test set for the given algorithm (or all algorithms).

    Assumes all crypto algorithms will have the following files:
      CRYPTOLIB_TEST_DIR/{algorithm}_set_testvectors.py
      CRYPTOLIB_TESTVECTORS_DIR/{algorithm}_{suffix}.hjson
    '''
    # Find the test vector HJSON files.
    pattern = "*" if alg is None else alg
    testvec_files = list(CRYPTOLIB_TESTVECTORS_DIR.glob(f'{pattern}_{suffix}.hjson'))
    if len(testvec_files) == 0:
        raise RuntimeError(f'No tests found for algorithm: {"all" if alg is None else alg}.')

    # Find the set_testvectors script for each algorithm in the cryptolib.
    for testvec_file in testvec_files:
        algorithm = testvec_file.name.removesuffix(f'_{suffix}.hjson')
        set_script = CRYPTOLIB_TEST_DIR / (algorithm + '_set_testvectors.py')
        run_set_testvectors(set_script, testvec_file)

    # Find the set_testvectors script for sigverify.
    if alg is None or alg == SIGVERIFY_ALGORITHM:
        set_script = SIGVERIFY_TEST_DIR / 'sigverify_set_testvectors.py'
        testvec_file = CRYPTOLIB_TESTVECTORS_DIR / f'{SIGVERIFY_ALGORITHM}_{suffix}.hjson'
        run_set_testvectors(set_script, testvec_file)


def set_hardcoded_testset(alg: Optional[str]) -> None:
    '''Set hardcoded test vectors for all crypto algorithms.

    Assumes all crypto algorithms will have the following files:
      CRYPTOLIB_TEST_DIR/{algorithm}_set_testvectors.py
      CRYPTOLIB_TESTVECTORS_DIR/{algorithm}_hardcoded.hjson
    '''
    # Since the hardcoded tests are already in checked-in HJSON files, there's
    # not much to do here other than set test vectors using those files.
    set_testvectors('hardcoded', alg)


def set_random_testset(ntests : int, alg: Optional[str]) -> None:
    '''Set random test vectors for all crypto algorithms.

    Assumes all crypto algorithms will have the following files:
      CRYPTOLIB_TEST_DIR/{algorithm}_set_testvectors.py
      CRYPTOLIB_TEST_DIR/{algorithm}_gen_random_testvectors.py

    If the _gen_random_testvectors.py script is missing, then the algorithm
    will be skipped except for the sigverify algorithm, for which it must
    exist.

    The gen_random_testvectors script is expected to accept the following syntax:
      {algorithm}_gen_random_testvectors.py n FILE

    ...where n is the number of test vectors and FILE is the HJSON file to
    which the test vectors are written.
    '''

    # First, generate random test vectors for every algorithm in the cryptolib
    # that has a gen_random_testvectors script (or for the specific algorithm
    # selected, if there is one).
    pattern = "*" if alg is None else alg
    genscripts = CRYPTOLIB_TEST_DIR.glob(f'{pattern}_gen_random_testvectors.py')
    for genscript in genscripts:
        algorithm = genscript.name.removesuffix(f'_gen_random_testvectors.py')
        hjson_file = CRYPTOLIB_TESTVECTORS_DIR / (algorithm + '_random.hjson')
        # Generate new vectors and write then to an HJSON file in the
        # testvector directory.
        cmd = [genscript.absolute(), str(ntests), hjson_file.absolute()]
        subprocess.run(cmd, check=True)

    # Set tests to use the newly-generated random vectors.
    set_testvectors('random', alg)


def set_wycheproof_testset(alg: Optional[str]) -> None:
    '''Set wycheproof test vectors for all crypto algorithms.

    Assumes all crypto algorithms will have the following files:
      CRYPTOLIB_TEST_DIR/{algorithm}_set_testvectors.py
      CRYPTOLIB_TESTVECTORS_DIR/wycheproof/{algorithm}_parse_testvectors.py

    If the wycheproof/{algorithm}_parse_testvectors.py script is missing, then
    the algorithm will be skipped except for the sigverify algorithm, for which
    it must exist.

    The parse_testvectors script is expected to accept the following syntax:
      {algorithm}_parse_testvectors.py src.json dst.hjson

    ...where src.json is the Wycheproof source file and dst.hjson is the HJSON
    file to which test vectors will be written.
    '''
    # First, parse test vectors for every algorithm in the cryptolib that has a
    # Wycheproof parse_testvectors script (or for the specific algorithm
    # selected, if there is one).
    parse_script_dir = (CRYPTOLIB_TESTVECTORS_DIR / 'wycheproof')
    pattern = "*" if alg is None else alg
    parse_scripts = parse_script_dir.glob(f'{pattern}_parse_testvectors.py')
    print([s.name for s in parse_script_dir.glob(f'{pattern}_parse_testvectors.py')])
    for parse_script in parse_scripts:
        algorithm = parse_script.name.removesuffix(f'_parse_testvectors.py')
        if algorithm not in WYCHEPROOF_FILE_NAMES:
            raise ValueError(
                    f'Could not find Wycheproof file name for algorithm '
                    '{algorithm}. Please update the WYCHEPROOF_FILE_NAMES '
                    'dictionary in {Path(__file__).name}')
        wycheproof_file = WYCHEPROOF_DIR / WYCHEPROOF_FILE_NAMES[algorithm]
        if not wycheproof_file.exists():
            raise ValueError(
                    f'File {wycheproof_file.absolute()} does not exist. Please '
                    'update the WYCHEPROOF_FILE_NAMES ' 'dictionary in '
                    '{Path(__file__).name}')
        hjson_file = CRYPTOLIB_TESTVECTORS_DIR / (algorithm + '_wycheproof.hjson')
        # Parse test vectors and write then to an HJSON file in the testvector
        # directory.
        cmd = [parse_script.absolute(), wycheproof_file.absolute(), hjson_file.absolute()]
        subprocess.run(cmd, check=True)

    # Set tests to use the newly-generated random vectors.
    set_testvectors('wycheproof', alg)

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('testset', type=str,
            help=('Test set to select. Options are:'
                   'hardcoded (small handwritten tests), '
                   'random (randomly generated tests), '
                   'wycheproof (large set of adversarial tests from the wycheproof project)'))
    parser.add_argument('-a', type=str, required=False,
            help='Specific algorithm to set tests for. By default, tests will '
                 'be set for all algorithms.')
    parser.add_argument('-n', type=int, required=False,
            default=DEFAULT_RANDOM_TESTS,
            help='Number of random tests per algorithm if testset=random')
    args = parser.parse_args()

    if args.testset == 'random':
        set_random_testset(args.n, args.a)
    elif args.testset == 'hardcoded':
        set_hardcoded_testset(args.a)
    elif args.testset == 'wycheproof':
        set_wycheproof_testset(args.a)
    else:
        raise ValueError(f'Unrecognized test set {args.testset}. Options are: '
                'random, hardcoded, and wycheproof.')

if __name__ == "__main__":
     sys.exit(main())
