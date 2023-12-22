#!/bin/bash

# Runs the SPHINCS+ verify test with all parameter headers under the given
# directory. Saves the test logs in the log directory.
#
# The $OT_REPO_TOP environment variable should be set to the root of the
# `opentitan` repo. Likewise, the $SPX_REPO_TOP environment variable should be
# set to the root of the `sphincsplus` repo.

set -e;

USAGE="USAGE: $0 PARAMS_DIR LOG_DIR TEST_DIR";

if [ -z "$OT_REPO_TOP" ]
then
  echo "\$OT_REPO_TOP is not defined! It should be set to the location of the opentitan repo root.";
  exit 1;
fi

if [ -z "$SPX_REPO_TOP" ]
then
  echo "\$SPX_REPO_TOP is not defined! It should be set to the location of the sphincsplus repo root.";
  exit 1;
fi

if [ -z "$1" ] | [ -z "$2" ] | [ -z "$3" ]
then
  echo $USAGE;
  exit 1;
fi

HEADER_DIR=$(realpath $1);
LOG_DIR=$(realpath $2);
TEST_DIR=$(realpath $3);
KAT_DIR=$OT_REPO_TOP/sw/device/tests/crypto/testvectors/sphincsplus_kat;
BENCHMARK_PARAMS_DST="$OT_REPO_TOP/sw/device/silicon_creator/lib/sigverify/sphincsplus/params/benchmark_params.h";


echo "Reading headers from $HEADER_DIR/ and tests from $TEST_DIR/";
echo "Saving logs to $LOG_DIR/";

cd $OT_REPO_TOP;
for header in "$HEADER_DIR/*"
do
  NAME=$(basename $header);
  echo "Running benchmark for $NAME...";

  # Look for a KAT .rsp file (using the naming scheme from make_test_data.sh)
  # and run the test-parsing script. If the .rsp file doesn't exist, create it.
  RSP=$TEST_DIR/KAT_$NAME.rsp;
  if ! [ -f "$RSP" ]
  then
    ./make_test_data.sh $header $RSP;
  fi
  $KAT_DIR/parse_kat.py --num-tests=10 $RSP $KAT_DIR/sphincsplus_testvectors_kat.hjson;

  # Copy the header into the benchmarks and run the test.
  cp $header $BENCHMARK_PARAMS_DST;
  ./bazelisk.sh test --test_output=streamed //sw/device/silicon_creator/lib/sigverify/sphincsplus/test:verify_test_kat0_sim_verilator > $LOG_DIR/out_$name.log 2>$LOG_DIR/err_$name.log;
done
