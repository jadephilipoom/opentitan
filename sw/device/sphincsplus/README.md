## Benchmarks

| Parameters        | Commit | Cycles     |
| ----------------- | ------ | ---------- |
| shake-128f-simple | 611485 | 10 330 971 |
| shake-128s-simple | 26861b |  4 179 463 |


### Bazel command for benchmarks

To run the verification benchmark on Verilator, write the following and replace
`shake_128s` and `robust` with the desired parameter set. The defaults are
`shake_128f` and `simple`.

```
bazel test \
 --test_output=streamed \
 --disk_cache=~/bazel_cache \
 --//hw:verilator_options=--threads,8 \
 --//sw/device/sphincsplus:spx_params=shake_128s \
 --//sw/device/sphincsplus:spx_thash=robust \
 //sw/device/sphincsplus/test:verify_test_sim_verilator
```

This should result in a printout like:
```
I00000 test_rom.c:133] Version: earlgrey_silver_release_v5-8470-ga09d5ca30, Build Date: 2022-11-08 10:36:31
I00001 test_rom.c:235] Test ROM complete, jumping to flash (addr: 20000480)!
I00000 ottf_main.c:126] Running sw/device/sphincsplus/test/verify.c
I00001 verify.c:44] Starting SPHINCS+ verify test for parameter set sphincs-shake-128s-simple...
I00002 verify.c:56] CSRNG initialized/instantiated successfully.
I00003 verify.c:62] Verification took 4179463 cycles.
I00004 verify.c:64]     verification succeeded.
I00005 verify.c:68]     mlen as expected [536887376].
I00006 verify.c:70]     output message as expected.
I00007 ottf_main.c:100] Finished sw/device/sphincsplus/test/verify.c
I00008 status.c:28] PASS!
```

Small tests take around half an hour on Verilator on a laptop; larger tests
will take significantly longer.
