## Benchmarks

| Parameters        | Commit | Cycles     |
| ----------------- | ------ | ---------- |
| shake-128s-simple | 26861b |  4 179 463 |
| shake-128s-simple | ec56fa |  3 737 997 |
| shake-128s-simple | 1116e1 |  3 010 390 |
| shake-128s-simple | a4b000 |  2 639 232 |
| shake-128s-simple | 6381ad |  2 611 144 |
| shake-128s-simple | 47c9f1 |  1 612 383 |
| shake-128s-simple | 7aa10f |  1 447 174 |
| shake-128s-simple | 0694b7 |  1 372 591 |
| shake-128s-robust | 26861b |  6 681 864 |
| shake-128s-robust | ba2abf |  4 817 560 |
| shake-128s-simple | 0694b7 |  3 102 582 |
| shake-128f-simple | 611485 | 10 330 971 |
| shake-128f-robust | 75b246 | 17 612 392 |
| shake-192s-simple | 75b246 |  6 253 183 |
| shake-192s-robust | 75b246 | 10 275 095 |

### Bazel command for benchmarks

To run the verification benchmark on Verilator, write the following and replace `shake_128s_simple` with the desired parameter set.
To run on FPGA, replace `verify_test_sim_verilator` with `verify_test_fpga_cw310_test_rom`.
Note that cycle counts on FPGA may be slightly different (currently under investigation).

```
bazel test \
 --test_output=streamed \
 --test_timeout=100000 \
 --disk_cache=~/bazel_cache \
 --//hw:verilator_options=--threads,8 \
 --//sw/device/sphincsplus:spx_params=shake_128s_simple \
 //sw/device/sphincsplus/test:verify_test_sim_verilator
```

This should result in a printout like:
```
I00000 test_rom.c:133] Version: earlgrey_silver_release_v5-8470-ga09d5ca30, Build Date: 2022-11-08 10:36:31
I00001 test_rom.c:235] Test ROM complete, jumping to flash (addr: 20000480)!
I00000 ottf_main.c:126] Running sw/device/sphincsplus/test/verify.c
I00001 verify.c:47] Starting SPHINCS+ verify test for parameter set sphincs-shake-128s-simple...
I00002 verify.c:58] CSRNG initialized/instantiated successfully.
I00003 verify.c:84] KMAC initialized/instantiated successfully.
I00004 verify.c:90] Verification took 1447174 cycles.
I00005 verify.c:92]     verification succeeded.
I00006 verify.c:96]     mlen as expected [32].
I00007 verify.c:98]     output message as expected.
I00008 ottf_main.c:100] Finished sw/device/sphincsplus/test/verify.c
I00008 status.c:28] PASS!
```

The smallest tests take around ten minutes on Verilator on a laptop.
Larger tests will take significantly longer, approximately in proportion to the cycle counts.
