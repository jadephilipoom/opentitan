/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for key_pair_dilithium
*/

.section .text.start

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31
  
  /* Loadf stack address */
  la  x2, stack
  la  x10, zeta
  jal x1, key_pair_dilithium

  ecall

.data
.balign 32
.global stack
stack:
    .zero 49412
zeta:
    .word 0xa035997c /* 0x7c9935a0 */
    .word 0xaa9476b0 /* 0xb07694aa */
    .word 0xe4106d0c /* 0x0c6d10e4 */
    .word 0xdd1a6bdb /* 0xdb6b1add */
    .word 0x251ad82f /* 0x2fd81a25 */
    .word 0x0348b1cc /* 0xccb14803 */
    .word 0x9973cd2d /* 0x2dcd7399 */
    .word 0x2d7f7336 /* 0x36737f2d */