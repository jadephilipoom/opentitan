/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Wrapper specifically for SCA/formal analysis of p256 modular inversion.
 *
 * This routine would never normally be exposed, but it's helpful for SCA to
 * analyze it in isolation. 
 */

.section .text.start

main:
  /* Initialize all-zero register. */
  bn.xor    w31, w31, w31

  /* Load modulus and Barrett constant.
       w28 <= u, Barrett constant for p
       w29 <= p, modulus for p256 underlying prime field
       MOD <= p */
  li        x2, 28
  la        x3, p256_u_p
  bn.lid    x2, 0(x3)
  li        x2, 29
  la        x3, p256_p
  bn.lid    x2, 0(x3)
  bn.wsrw   0, w29


  /* Load input.
       w0 <= dmem[input] = x */
  la        x3, input
  bn.lid    x0, 0(x3)

  /* Compute inverse.
       w1 <= x^-1 mod p */
  jal       x1, mod_inv

  /* Store result. */
  li        x2, 1
  la        x3, output
  bn.sid    x2, 0(x3)

.data

/*
Input x, base for exponentiation (256 bits).

Default value: 0x2648d0d248b70944dfd84c2f85ea5793729112e7cafa50abdf7ef8b7594fa2a1
Expected result: 0x9c5ea399da412d5ac056cbd879c4915fc9d78acc4ff4b855b1a17c9695b118c4
 */
.balign 32
input:
.word 0x594fa2a1
.word 0xdf7ef8b7
.word 0xcafa50ab
.word 0x729112e7
.word 0x85ea5793
.word 0xdfd84c2f
.word 0x48b70944
.word 0x2648d0d2

/* Output, x^-1 mod p (256 bits). */
.balign 32
output:
.zero 32
