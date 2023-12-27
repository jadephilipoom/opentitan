#!/bin/bash

# Generates test data for different sets of SPHINCS+ parameters.
#
# Edits the Makefile in the SPHINCS+ reference implementation to point to a
# different parameter set, generates test vectors, and then restores the
# previous state. The parameter set should be a C header file whose format is
# compatible with the reference implementation.
#
# The $SPX_REPO_TOP environment variable should be set to the root of the
# `sphincsplus` repo.

set -e;
USAGE="USAGE: $0 PARAMS_HEADER TEST_DST"

if [ -z "$SPX_REPO_TOP" ]
then
  echo "\$SPX_REPO_TOP is not defined! It should be set to the location of the sphincsplus repo root.";
  exit 1;
fi

if [ -z "$1" ] | [ -z "$2" ]
then
  echo $USAGE;
  exit 1;
fi

HEADER=$(realpath $1);
TEST_DST=$(realpath $2);
PARAMS_DIR=$SPX_REPO_TOP/ref/params;
PARAMS_FILENAME=$(basename $HEADER);
PARAMS_NAME=${PARAMS_FILENAME%.*}
PARAMS_SHORTNAME=${PARAMS_NAME#"params-"}

if [ -f "$TEST_DST" ]
then
  echo "Destination file $TEST_DST already exists!";
  exit 1;
fi

echo "Generating test data for $PARAMS_SHORTNAME, storing in $TEST_DST";

cd $SPX_REPO_TOP/ref;
cp $HEADER $PARAMS_DIR;
sed -i -e "s/PARAMS = .*/PARAMS = $PARAMS_SHORTNAME/" Makefile;
sed -i -e "s/THASH = .*/THASH = simple/" Makefile;
make clean && make && ./PQCgenKAT_sign;
cp PQCsignKAT_64.rsp $TEST_DST;
