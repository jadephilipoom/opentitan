import sys
sys.path.append("/home/amin/Documents/opentitan/sw/otbn/crypto/tests/dilithiumpy_bench_otbn/dilithiumpy")

import os
from multiprocessing import Pool
import sqlite3
import time
import random

from dilithiumpy.dilithium import Dilithium2
from otbn_interface import key_pair_otbn, sign_otbn, verify_otbn
from create_db import create_db

NPROC = 13
ITERATIONS = 13


def bench_key_pair(is_base):
    rand = os.urandom(32)
    # reference computation
    pk, sk = Dilithium2.keygen(rand)
    pk_otbn, sk_otbn, stat_data = key_pair_otbn(rand, is_base=is_base)

    if pk != pk_otbn or sk != sk_otbn:
        print("Error: keys do not match!!!")
        print(pk + sk)
        print(pk_otbn + sk_otbn)
        return -1
    print("Iteration done")
    return stat_data


def bench_sign(is_base):
    rand = os.urandom(32)
    msg = os.urandom(64)
    # reference keys
    _, sk = Dilithium2.keygen(rand)
    # reference computation
    sig = None
    sig_otbn = None

    sig = Dilithium2.sign(sk, msg)
    sig_otbn, _, _, stat_data = sign_otbn(sk, msg, is_base=is_base)

    if sig != sig_otbn:
        print("Error: sigs do not match!!!")
        print(sig)
        print(sig_otbn)
        return -1
    print("Iteration done")
    return stat_data


def bench_verify(is_base):
    rand = os.urandom(32)  # rand = b'\x05\xeb\x11\xd9\x88\xb1\x8b\x1d\xc6\xc1\xfc\xb7\x9aI\xb4\xa2\x8f\xa5\xe0\x93!C\xa7?F\x8dR\xefvS\x983'
    msg = os.urandom(64)   #  msg = b'e\xd26\xd3\xf5\xfaV\x91\xca+\x8co\xf8\xb3\xe7\xddO\xf0\x9f\xa2 #L\xee\x06BF\x15kpY\xb7\xa0\xa1@\xc6\xa8G!\xc9\xdd,\x91\xffA1\xc5\xb6\x99\xbfZ\xfe\xe1\xd8H9\x93a\x12v!\x130\xd4'
    # reference keys
    pk, sk = Dilithium2.keygen(rand)
    # reference signature
    sig = Dilithium2.sign(sk, msg)

    # reference computation
    verify_out = Dilithium2.verify(pk, msg, sig)

    verify_out_otbn, stat_data = verify_otbn(pk, msg, sig, is_base=is_base)

    if verify_out != verify_out_otbn:
        print("Error: verify results do not match!!!")
        print(rand)
        print(msg)
        print(verify_out)
        print(verify_out_otbn)
        return -1
    print("Iteration done")
    return stat_data


def run_bench(operation: str, is_base: bool):
    if __name__ == "sw.otbn.crypto.tests.dilithiumpy_bench_otbn.bench_dilithium":

        con = sqlite3.connect("/home/amin/Documents/dilithium_benchmarks/dilithium_bench.db")
        cur = con.cursor()
        create_db(cur)
        print(f"Benchmark {operation}")

        is_base_str = "_base" if is_base else ""

        # select funciton
        if operation == "key_pair":
            func = bench_key_pair
        elif operation == "sign":
            func = bench_sign
        elif operation == "verify":
            func = bench_verify
        else:
            print("No function detected")
            exit(-1)

        results = []
        start_time = int(time.time())
        for _ in range(ITERATIONS // NPROC):
            with Pool(NPROC) as p:
                results += p.map(func, [is_base] * NPROC)
        end_time = int(time.time())

        if -1 in results:
            print("Error in Computation")
            exit(-1)

        cur.execute(f"INSERT INTO benchmark (start_time, end_time, iterations, operation) VALUES({start_time}, {end_time}, {ITERATIONS}, '{operation + is_base_str}')")
        current_benchmark_id = cur.lastrowid
        for result in results:
            if result == -1:
                continue
            cur.execute(f"INSERT INTO benchmark_iteration (benchmark_id) VALUES({current_benchmark_id})")
            current_benchmark_iteration_id = cur.lastrowid
            cur.execute(f"INSERT INTO cycles (cycles, benchmark_iteration_id) VALUES({result['insn_count'] + result['stall_count']}, {current_benchmark_iteration_id})")
            cur.execute(f"INSERT INTO stalls (stalls, benchmark_iteration_id) VALUES({result['stall_count']}, {current_benchmark_iteration_id})")
            for func_name, per_instr_data in result["func_instrs"].items():
                for instr_name, cyc_stall in per_instr_data.items():
                    cur.execute(f"INSERT INTO func_instrs (func_name, instr_name, instr_count, stall_count, benchmark_iteration_id) VALUES('{func_name}', '{instr_name}', {cyc_stall[0]}, {cyc_stall[1]}, {current_benchmark_iteration_id})")
            for callee_func_name, caller_data in result["func_calls"].items():
                for caller_func_name, call_count in caller_data.items():
                    cur.execute(f"INSERT INTO func_calls (caller_func_name, callee_func_name, call_count, benchmark_iteration_id) VALUES('{caller_func_name}', '{callee_func_name}', {call_count}, {current_benchmark_iteration_id})")
        con.commit()
