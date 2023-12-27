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
