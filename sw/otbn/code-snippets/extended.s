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

  /* Test vectorized modular arithmetic.
       w20..w25 <= vectorized arithmetic test results */
  jal       x1, vec_arith_test

  /* Test memory sizes. This step zeroes the memory, so do it last. */
  jal       x1, check_mem_sizes

  /* End the program. */
  ecall

/**
 * Basic tests for vectorized add/sub/mul modulo.
 *
 * This test uses a value x from DMEM and 16-bit vectorized instructions to
 * compute vectors a, b, and c such that:
 *   a[i] = (x[i] + x[i]) % modulus16[i]
 *   b[i] = (- x[i]) % modulus16[i]
 *   c[i] = (x[i] * x[i]) % modulus16[i]
 *
 * This test uses a value y from DMEM and 32-bit vectorized instructions to
 * compute vectors d, e, and f such that:
 *   d[i] = (5 * y[i]) % modulus32[i]
 *   e[i] = (- y[i]) % modulus32[i]
 *   f[i] = (y[i] * y[i]) % modulus32[i]
 *
 * @param[in]           w31: all-zero
 * @param[in] dmem[x..x+32]: x, value for testing
 * @param[in] dmem[y..y+32]: y, value for testing
 * @param[out]          w20: a, 16-bit modular addition result
 * @param[out]          w21: b, 16-bit modular subtraction result
 * @param[out]          w22: c, 16-bit modular multiplication result
 * @param[out]          w23: d, 32-bit modular addition result
 * @param[out]          w24: e, 32-bit modular subtraction result
 * @param[out]          w25: f, 32-bit modular multiplication result
 *
 * clobbered registers: x2, x3, w0, w1, w20 to w25, MOD
 * clobbered flag groups: None
 */
vec_arith_test:
  /* Load the vectorized 16-bit test modulus.
       w0 <= dmem[modulus16..modulus16+32] */
  la       x2, modulus16
  bn.lid   x0, 0(x2)

  /* Copy the modulus into the MOD special register.
       MOD <= w0 */
  bn.wsrw  0, w0

  /* Load the 16-bit vectorized test value x.
       w1 <= dmem[x..x+32] */
  la       x2, x
  li       x3, 1
  bn.lid   x3, 0(x2)

  /* Compute a such that a[i] = (x[i] * 5) % MOD[i].
       w20 <= (x +v x +v x +v x +v x) % MOD */
  bn.v16.addm   w20, w1, w1
  bn.v16.addm   w20, w20, w1
  bn.v16.addm   w20, w20, w1
  bn.v16.addm   w20, w20, w1

  /* Compute b such that b[i] = (- x[i]) % MOD[i].
       w21 <= (0 -v x) % MOD */
  bn.v16.subm   w21, w31, w1

  /* Compute c such that c[i] = (x[i] * x[i]) % MOD[i].
       w22 <= (x *v x) % MOD */
  bn.v16.mulm   w22, w1, w1

  /* Load the vectorized 32-bit test modulus.
       w0 <= dmem[modulus32..modulus32+32] */
  la       x2, modulus32
  bn.lid   x0, 0(x2)

  /* Copy the modulus into the MOD special register.
       MOD <= w0 */
  bn.wsrw  0, w0

  /* Load the 32-bit vectorized test value y.
       w1 <= dmem[y..y+32] */
  la       x2, y
  li       x3, 1
  bn.lid   x3, 0(x2)

  /* Compute d such that d[i] = (y[i] * 5) % MOD[i].
       w23 <= (y +v y +v y +v y +v y) % MOD */
  bn.v32.addm   w23, w1, w1
  bn.v32.addm   w23, w23, w1
  bn.v32.addm   w23, w23, w1
  bn.v32.addm   w23, w23, w1

  /* Compute e such that e[i] = (- y[i]) % MOD[i].
       w24 <= (0 -v y) % MOD */
  bn.v32.subm   w24, w31, w1

  /* Compute f such that f[i] = (y[i] * y[i]) % MOD[i].
       w25 <= (y *v y) % MOD */
  bn.v32.mulm   w25, w1, w1

  ret

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

/* Label for `check_mem_sizes` marking the start of the scratchpad. */
scratchpad_start:

/* Fill the entire scratchpad with zeroes. */
.zero 1024

/**
 * Memory in this section is readable/writeable by Ibex when OTBN is idle.
 *
 * Size in current RTL: 3072 bytes.
 * Expected size in modified OTBNsim: 7168 bytes.
 */
.data

/* Label for `check_mem_sizes` marking the start of the data section. */
data_start:

/**
 * Test modulus for 16-bit vectorized instructions.
 *
 * This is the 13-bit Kyber modulus (0x0d01), vectorized.
 */
modulus16:
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01

/**
 * Test modulus for 32-bit vectorized instructions.
 *
 * This is the 23-bit Dilithium modulus (0x7fe001), vectorized.
 */
modulus32:
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001

/**
 * Test value x for 16-bit vectorized instructions.
 *
 * This value has been chosen to be somewhat human-friendly visually and also
 * to have all 16-bit sections less than `modulus16`.
 *
 * Full hex value in big-endian form:
 * x = 0x00000111022203330444055506660777088809990aaa0bbb0ccc01dd01ee01ff
 */
x:
.word 0x01ee01ff
.word 0x0ccc01dd
.word 0x0aaa0bbb
.word 0x08880999
.word 0x06660777
.word 0x04440555
.word 0x02220333
.word 0x00000111

/**
 * Test value y for 32-bit vectorized instructions.
 *
 * This value has been chosen to be somewhat human-friendly visually and also
 * to have all 32-bit sections less than `modulus32`.
 *
 * Full hex value in big-endian form:
 * y = 0x00008801001199020022aa030033bb040044cc050055dd060066ee070077ff08
 */
y:
.word 0x0077ff08
.word 0x0066ee07
.word 0x0055dd06
.word 0x0044cc05
.word 0x0033bb04
.word 0x0022aa03
.word 0x00119902
.word 0x00008801
