/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start

/**
 * Standalone test for the Montgomery constant code snippet.
 */
main:
  /* Load the pointer to m */
  la       x10, in_mod

  /* load the number of limbs (12 for RSA-3072) */
  li       x11, 12

  /* Load the pointer to the output buffer */
  la       x12, rr

  /* Call R^2 computation. */
  jal      x1, compute_rr_sample_fast

  /* copy all limbs of R^2 to wide reg file */
  li       x8, 0
  la       x21, rr
  loopi    12, 2
    bn.lid   x8, 0(x21++)
    addi     x8, x8, 1

  ecall

.data

/* Modulus of test key */
.globl in_mod
in_mod:
  .word 0x6a6a75e1
  .word 0xa018ddc5
  .word 0x687bb168
  .word 0x8e8205a5
  .word 0x7dbfffa7
  .word 0xc8722ac5
  .word 0xf84d21cf
  .word 0xe1312531
  .word 0x0ce3f8a3
  .word 0xa825f988
  .word 0x57f51964
  .word 0xb27e206a
  .word 0x8e1dd008
  .word 0x1c4fb8d7
  .word 0x824fb142
  .word 0x1c8be7b3
  .word 0x7b9d6366
  .word 0xc56ad0f2
  .word 0xef762d5b
  .word 0x4b1431e3
  .word 0x8ae28eb9
  .word 0xd41db7aa
  .word 0x43cccdf7
  .word 0x91b74a84
  .word 0x80183850
  .word 0x30e74d0d
  .word 0xb62ed015
  .word 0x235574d2
  .word 0x8c28f251
  .word 0x4f40def2
  .word 0x24e2efdb
  .word 0x9ebd1ff2
  .word 0xfa7b49ee
  .word 0x2819a938
  .word 0x6e66b8c8
  .word 0x24e41546
  .word 0x4d783a7c
  .word 0xd2947d3d
  .word 0x1ab269e9
  .word 0xfad39f16
  .word 0xaab78f7b
  .word 0x49d8b510
  .word 0x35bf0dfb
  .word 0xeb274754
  .word 0x069eccc9
  .word 0xc13c437e
  .word 0xe3bc0f60
  .word 0xc9e0e12f
  .word 0xc253ac43
  .word 0x89c240e0
  .word 0xc4aba4e5
  .word 0xedf34bc0
  .word 0x5402c462
  .word 0x4021b0bd
  .word 0x996b6241
  .word 0xc3d9945f
  .word 0xa137ac60
  .word 0xf0250bf5
  .word 0xc8c7100f
  .word 0xb70d6b88
  .word 0x78916a8c
  .word 0x33370e5d
  .word 0x3970dcb9
  .word 0xaf4c58b4
  .word 0x5f78cb0d
  .word 0xb02d90b7
  .word 0xeb6c3d05
  .word 0x04afc71a
  .word 0x45185f0f
  .word 0x987caa5b
  .word 0x33976249
  .word 0x565afdbc
  .word 0x80a85056
  .word 0x59e07655
  .word 0x9a29e77d
  .word 0x7a8dfb7f
  .word 0x782e0204
  .word 0x4d6713ff
  .word 0x131000ea
  .word 0xe18e1206
  .word 0x21f57f30
  .word 0xf24f038b
  .word 0x59cf874d
  .word 0x24c50525
  .word 0xb52f170d
  .word 0x46c9adde
  .word 0x90e82c73
  .word 0x1344ceaf
  .word 0x663209f2
  .word 0x24bd4fbf
  .word 0x5e4ed04d
  .word 0x0fce770a
  .word 0x81f78793
  .word 0xa792e13e
  .word 0xa6c7bf58
  .word 0xe1df9be8

/* Output: squared Mongomery Radix RR = (2^3072)^2 mod N */
.globl rr
rr:
.zero 384
