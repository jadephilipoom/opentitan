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

  /* re-load second share of secret scalar k from dmem: w2,w3 = dmem[k1] */
  la        x16, k1
  li        x2, 2
  bn.lid    x2, 0(x16++)
  li        x2, 3
  bn.lid    x2, 0(x16)

  /* Generate a random 127-bit number.
       w4 <= URND()[255:129] */
  bn.wsrr  w4, 0x2 /* URND */
  bn.rshi  w4, w31, w4 >> 129

  /* Add 1 to get a 128-bit nonzero scalar for masking.
       w4 <= w4 + 1 = alpha */
  bn.addi  w4, w4, 1

  /* w0 <= ([w0,w1] * w4) mod n = (k0 * alpha) mod n */
  bn.mov    w24, w0
  bn.mov    w25, w1
  bn.mov    w26, w4
  jal       x1, mod_mul_320x128
  bn.mov    w0, w19

  /* w19 <= ([w2,w3] * w26) mod n = (k1 * alpha) mod n */
  bn.mov    w24, w2
  bn.mov    w25, w3
  jal       x1, mod_mul_320x128

  /* w0 <= (w0+w19) mod n = (k * alpha) mod n */
  bn.addm   w0, w0, w19

  /* w1 <= w0^-1 mod n = (k * alpha)^-1 mod n */
  jal       x1, mod_inv

  /* Load masking parameter alpha (128 bits). This is written to mimic the
     masking in `p256_sign` from p256.s; see the documentation of that function
     for details. */

  /* Compute inverse.
       w1 <= x^-1 mod p */
  jal       x1, mod_inv

  /* Store result. */
  li        x2, 1
  la        x3, output
  bn.sid    x2, 0(x3)

.data

/*
Default data for simulator-based testing:
Unmasked value: 0x2648d0d248b70944dfd84c2f85ea5793729112e7cafa50abdf7ef8b7594fa2a1
Masked share 0: 0x7e8bb020f9bb74012c8d5cd1c0fe2d66bead5ed1210904c73a27d1b2cdf7c706d47c4a892130fb63
Masked share 1: 0x81744fde06448bfff9bb740087b8dbddde11e80c0bf8f1512c230bf7f965aef60b02ae2e381ea73e 
Expected result: 0x9c5ea399da412d5ac056cbd879c4915fc9d78acc4ff4b855b1a17c9695b118c4

Note: the shares are 320 bits, and set so that (share0 + share1) mod n = x.
*/

.balign 32
.input0
.word 0x2130fb63
.word 0xd47c4a89
.word 0xcdf7c706
.word 0x3a27d1b2
.word 0x210904c7
.word 0xbead5ed1
.word 0xc0fe2d66
.word 0x2c8d5cd1
.word 0xf9bb7401
.word 0x7e8bb020

.balign 32
.input1
.word 0x381ea73e
.word 0x0b02ae2e
.word 0xf965aef6
.word 0x2c230bf7
.word 0x0bf8f151
.word 0xde11e80c
.word 0x87b8dbdd
.word 0xf9bb7400
.word 0x06448bff
.word 0x81744fde

/* Output, x^-1 mod p (256 bits). */
.balign 32
output:
.zero 32
