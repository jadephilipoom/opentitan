# Benchmark Reproduction Instructions

## OpenTitan Setup

Check out (TODO: commit) from the OpenTitan repository.
This commit contains test data for (TODO: explain).

TODO:
- generate test data for all ssvs
- generate params for all ssvs
- automatically swap in params and also test data for each

Plan:
- Create dir spx-benchmark/params with all .ssv files
- Create a script to parse .ssv to params.h
  - takes template as argument
  - writes params.h files to spx-benchmark/gen/headers
- Create a script `spx_benchmark_gen_test_data`
  - takes path to sphincsplus and header template as argument
  - for everything in gen/headers:
    - copies the params.h to sphincsplus, edits the makefile, and
      generates new test data in spx-benchmark/gen/data
- Create a script `spx_benchmark_run`
  - for each thing in params.h, checks for gen/ file
  - for each thing in params.h, copies the params.h and the test data
  - runs the benchmark in Verilator and finds the speed
  - creates csv with results


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
  --num-tests=10 \
  path/to/sphincsplus/ref/PQCsignKAT_64.rsp \
  sw/device/tests/crypto/testvectors/sphincsplus_kat/sphincsplus_testvectors_kat.hjson
```

This will separate the generated response file into HJSON files with up to 10 test vectors each, which are readable by the OpenTitan SPHINCS+ tests.
See `sw/device/tests/crypto/testvectors/sphincsplus_kat/README.md` for more options and an explanation of the parsing script.

## Generate New Test Data Another Way

To manually insert new test data, simply create an HJSON file named
`sw/device/tests/crypto/testvectors/sphincsplus_kat/sphincsplus_benchmark_testvectors_kat0.hjson` and populate the fields as explained in `parse_kat.py`.
You can use the existing HJSON test vectors as examples.
