#!/bin/bash

# Runs the SPHINCS+ verify test with all parameter headers under the given
# directory. Saves the test logs in the log directory.
#
# The $OT_REPO_TOP environment variable should be set to the root of the
# `opentitan` repo.
#
# USAGE: ./run_benchmark.sh <params directory> <log directory>

set -e;

HEADER_DIR=$PWD/$1;
LOG_DIR=$PWD/$2;
BENCHMARK_PARAMS_DST="$OT_REPO_TOP/sw/device/silicon_creator/lib/sigverify/sphincsplus/params/benchmark_params.h";

if [ -z "$OT_REPO_TOP" ]
then
  echo "\$OT_REPO_TOP is not defined! It should be set to the location of the opentitan repo root.";
  exit 1;
fi

echo "Reading headers from $HEADER_DIR/ and saving logs to $LOG_DIR/";

cd $OT_REPO_TOP;
for header in "$HEADER_DIR/*"
do
  name=$(basename $header);
  echo "Running benchmark for $name...";
  cp $header $BENCHMARK_PARAMS_DST;
  ./bazelisk.sh test --test_output=streamed //sw/device/silicon_creator/lib/sigverify/sphincsplus/test:verify_test_hardcoded_sim_verilator > $LOG_DIR/out_$name.log 2>$LOG_DIR/err_$name.log;
done
