#!/bin/bash

# To be run from the repository top-level directory, i.e. opentitan/

set -e

# Call the assembler and linker
hw/ip/otbn/util/otbn_as.py -o arithmetic_if.o arithmetic_if.s
hw/ip/otbn/util/otbn_ld.py -o arithmetic_if.elf arithmetic_if.o

# Call the constant-time checker
hw/ip/otbn/util/check_const_time.py arithmetic_if.elf --secrets w3 --subroutine func
