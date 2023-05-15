/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Standalone binary that tests experimental OTBNsim extensions.
 *
 * This binary is not expected to work for RTL simulations, only the (modified)
 * Python-based OTBN simulator.
 */
.section .text.start
start:
  /* Initialize all-zero register. */
  bn.xor    w31, w31, w31

  /* Test memory sizes. */
  jal       x1, check_mem_sizes

  /* End the program. */
  ecall

/**
 * Check that scratchpad and DMEM memory are as large as expected.
 *
 * Expects the scratchpad to be 1kB in length and the rest of DMEM to be 7kB.
 *
 * Will throw a BAD_DATA_ADDR area if the sizes are too small. This routine
 * does not check if the DMEM ranges are larger than expected.
 *
 * @param[in]  w31: all-zero
 *
 * clobbered registers: x2, x3
 * clobbered flag groups: None
 */
check_mem_sizes:
  /* Load a pointer to the all-zero register. */
  li        x2, 31

  /* Store 32*32 = 1024 bytes of zeroes to the scratchpad. */
  la        x3, scratchpad_start
  loopi     31, 1
    /* dmem[x3] <= w31 */
    bn.sid    x2, 0(x3++)

  /* Store 32*224 = 7168 bytes of zeroes to the data section. */
  la        x3, data_start
  loopi     224, 1
    /* dmem[x3] <= w31 */
    bn.sid    x2, 0(x3++)

  ret

/**
 * Memory in this section is visible only to OTBN.
 *
 * Size in current RTL: 1024 bytes.
 * Expected size in modified OTBNsim: 1024 bytes.
 */
.section .scratchpad
scratchpad_start:
.zero 1024

/**
 * Memory in this section is readable/writeable by Ibex when OTBN is idle.
 *
 * Size in current RTL: 3072 bytes.
 * Expected size in modified OTBNsim: 7168 bytes.
 */
.data
data_start:
.zero 7168
