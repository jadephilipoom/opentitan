# SPHINCS+ benchmark reproduction instructions

TODO: check in some test data and describe where/what it is

## OpenTitan setup

Check out (TODO: commit) from the OpenTitan repository.
TODO: more intro, link to OT setup
Set env variables

## Run the benchmarks on existing test data

To run tests for existing parameter sets, use `run_benchmark.sh`.
For example:
```console
./run_benchmark.sh spx-benchmark/gen/params/params-sphincs-shake-n16h18d1lgt24k6w16.h logs spx-benchmark/gen/tests
```
This test runs the parameters in the `params-sphincs-shake-n16h18d1lgt24k6w16.h`
header file and writes the output into the `logs/` directory.
It looks for test data in `spx-benchmark/gen/tests/`.
If no matching test data exists, the script will try to generate new data from the reference implementation, which requires a little extra setup (see below).
Then it runs several tests on a Verilator hardware simulation.
At the end, if successful, it will print some statistics, e.g.:
```console
Number of tests: 5
Min cycle count: 1273918
Max cycle count: 1325571
Avg cycle count: 1299814
```

If you are curious for the full output, you can find it under `logs/`.
You can also parse any log file with the `benchmark_stats.py` script to print statistics for previous runs.

Warning: the simulation may take hours to run, depending on the parameter set.
The first run must also compile the hardware design for Verilator, which takes an hour or so on its own.
By changing `sim_verilator` to `fpga_cw310_test_rom` in the benchmark script, it would be possible to run the test on an FPGA instead, which is much faster.
However, the FPGA does not produce accurate cycle counts, which is why for benchmarks Verilator is worth the wait.

## Generate new test data from the SPHINCS+ reference

Set env variable
Lower number of test vectors potentially
TODO




Benchmarking plan (new):
- generate params.h files individually using the python script
- make a script that generates test data for each file in params
- add test data dir to run_benchmarks

Instructions:
- Check out OT and sphincsplus (give commit for SPX)
- Follow OT setup insn, make sure you can run the spx+ test
- Make sure sphincsplus make works
- Run make_ref_header.py for whichever sets you want to benchmark
- Run ./run_benchmark.sh
- (optional) run ./benchmark_stats.py on the log file




# Benchmark Reproduction Instructions

## OpenTitan Setup

Check out (TODO: commit) from the OpenTitan repository.
TODO: more intro, link to OT setup

## Generate New Test Data From the Reference

The test data was created using the following process, which can be repeated to
get fresh data or data for different parameter sets:
1. Checkout the (TODO: link) sphincsplus repository at commit `035b394`, or
   whichever commit you want to create signatures from.
2. Change `Makefile` to point to the parameter set you want, and set `THASH =
   simple` (at time of writing, OpenTitan does not support `robust`). If you
   want to test new parameters, you may need to create a new file under
   `params/`.
3. Run `make && ./PQCgenKAT_sign`. This will create a new `PQCsignKAT_64.rsp`
   file that contains messages and signatures for the chosen parameter set.
4. Change back to the `opentitan` repo and run the following command, replacing
   `path/to/sphincsplus` with the path to your clone of `sphincsplus`:

```console
sw/device/tests/crypto/testvectors/sphincsplus_kat/parse_kat.py \
  --num-tests=5 \
  path/to/sphincsplus/ref/PQCsignKAT_64.rsp \
  sw/device/tests/crypto/testvectors/sphincsplus_kat/sphincsplus_testvectors_kat.hjson
```

This will separate the generated response file into HJSON files with up to 5 test vectors each, which are readable by the OpenTitan SPHINCS+ tests.
See `sw/device/tests/crypto/testvectors/sphincsplus_kat/README.md` for more options and an explanation of the parsing script.

## Generate New Test Data Another Way

To manually insert new test data, simply create an HJSON file named
`sw/device/tests/crypto/testvectors/sphincsplus_kat/sphincsplus_benchmark_testvectors_kat0.hjson` and populate the fields as explained in `parse_kat.py`.
You can use the existing HJSON test vectors as examples.
