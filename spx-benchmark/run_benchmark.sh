#!/bin/bash

# Runs the SPHINCS+ verify test with all parameter headers under the given
# directory. Saves the test logs in the log directory.
#
# The $OT_REPO_TOP environment variable should be set to the root of the
# `opentitan` repo. Likewise, if new test data is needed, the $SPX_REPO_TOP
# environment variable should be set to the root of the `sphincsplus` repo.

set -e;

USAGE="USAGE: $0 PARAMS_HEADER LOG_DIR TEST_DIR";

if [ -z "$OT_REPO_TOP" ]
then
  echo "\$OT_REPO_TOP is not defined! It should be set to the location of the opentitan repo root.";
  exit 1;
fi

if [ -z "$1" ] | [ -z "$2" ] | [ -z "$3" ]
then
  echo $USAGE;
  exit 1;
fi

HEADER=$(realpath $1);
NAME=$(basename $HEADER);
LOG_DIR=$(realpath $2);
TEST_DIR=$(realpath $3);
RSP_FILE=$TEST_DIR/KAT_$NAME.rsp;
KAT_DIR=$OT_REPO_TOP/sw/device/tests/crypto/testvectors/sphincsplus_kat;
LOG_FILE=$LOG_DIR/out_$NAME.log;
ERR_FILE=$LOG_DIR/err_$NAME.log;
BENCHMARK_PARAMS_DST="$OT_REPO_TOP/sw/device/silicon_creator/lib/sigverify/sphincsplus/params/benchmark_params.h";

echo "Reading tests from $TEST_DIR/";
echo "Saving logs to $LOG_DIR/";

cd $OT_REPO_TOP;


# Look for a KAT .rsp file (using the naming scheme from make_test_data.sh)
# and run the test-parsing script. If the .rsp file doesn't exist, create it.
echo "Looking for test data for $NAME...";
if ! [ -f "$RSP_FILE" ]
then
  echo "No matching test data found. Generating new test data...";
  ./make_test_data.sh $HEADER $RSP_FILE;
fi
echo "Got test data. Parsing...";
$KAT_DIR/parse_kat.py --num-tests=5 $RSP_FILE $KAT_DIR/sphincsplus_testvectors_kat.hjson;

echo "Running benchmark for $NAME...";

# Copy the header into the benchmarks and run the test.
cp $HEADER $BENCHMARK_PARAMS_DST;
./bazelisk.sh test --test_output=streamed //sw/device/silicon_creator/lib/sigverify/sphincsplus/test:verify_test_kat0_sim_verilator > $LOG_FILE 2>$ERR_FILE;

# Analyze the results.
./benchmark_stats.py $LOG_FILE;
