/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Elliptic-curve Diffie-Hellman (ECDH) on curve P-384.
 *
 * This binary has the following modes of operation:
 * 2. MODE_SHARED_KEYGEN: compute shared key
 */

 /**
 * Mode magic values generated with
 * $ ./util/design/sparse-fsm-encode.py -d 6 -m 4 -n 11 \
 *    --avoid-zero -s 3660400884
 *
 * Call the same utility with the same arguments and a higher -m to generate
 * additional value(s) without changing the others or sacrificing mutual HD.
 *
 * TODO(#17727): in some places the OTBN assembler support for .equ directives
 * is lacking, so they cannot be used in bignum instructions or pseudo-ops such
 * as `li`. If support is added, we could use 32-bit values here instead of
 * 11-bit.
 */
.equ MODE_SHARED_KEY, 0x5ec

.section .text.start
start:
  /* Init all-zero register. */
  bn.xor    w31, w31, w31

  /* Read the mode and tail-call the requested operation. */
  la        x2, mode
  lw        x2, 0(x2)

  addi      x3, x0, MODE_SHARED_KEY
  beq       x2, x3, shared_key

  /* Unsupported mode; fail. */
  unimp
  unimp
  unimp

/**
 * Generate a shared key from a secret and public key.
 *
 * Returns the shared key, which is the affine x-coordinate of (d*Q). The
 * shared key is expressed in boolean shares x0, x1 such that the key is (x0 ^
 * x1).
 *
 * This routine runs in constant time.
 *
 * @param[in]       w31: all-zero
 * @param[in]   dmem[0]: dptr_k0, pointer to location in dmem containing
 *                       1st private key share d0/k0
 * @param[in]   dmem[4]: dptr_k1, pointer to location in dmem containing
 *                       2nd private key share d1/k0
 * @param[in]  dmem[20]: dptr_x, pointer to result buffer for x-coordinate
 * @param[in]  dmem[24]: dptr_y, pointer to result buffer for y-coordinate
 * @param[out]  dmem[x]: x0, first share of shared key.
 * @param[out]  dmem[y]: x1, second share of shared key.
 *
 * clobbered registers: x2, x3, x9 to x13, x18 to x21, x26 to x30, w0 to w30
 * clobbered flag groups: FG0
 */
shared_key:
  /* Validate the public key. Halts the program if the key is invalid and jumps
     back here if it's OK. */
  jal       x0, check_public_key_valid

  _pk_valid:

  /* Generate arithmetically masked shared key d*Q.
       dmem[x] <= (d*Q).x - m_x mod p
       dmem[y] <= m_x */
  jal       x1, p384_scalar_mult

  /* Arithmetic-to-boolean conversion*/

  /* w11 <= dmem[x] */
  li        x3, 11
  la        x4, x
  bn.lid    x3, 0(x4)

  /* w19 <= dmem[y] = m_x */
  li        x3, 19
  la        x4, y
  bn.lid    x3, 0(x4)

  jal       x1, p384_arithmetic_to_boolean_mod

  /* dmem[x] <= w20 = x' */
  li        x3, 20
  la        x4, x
  bn.sid    x3, 0(x4)

  ecall

/**
 * Check if a provided public key is valid.
 *
 * For a given public key (x, y), check that:
 * - x and y are both fully reduced mod p
 * - (x, y) is on the P-384 curve.
 *
 * Note that, because the point is in affine form, it is not possible that (x,
 * y) is the point at infinity. In some other forms such as projective
 * coordinates, we would need to check for this also.
 *
 * This routine raises a software error and halts operation if the public key
 * is invalid.
 *
 * @param[in]  dmem[12]: dptr_r, pointer to dmem location where right
 *                               side result r will be stored
 * @param[in]  dmem[16]: dptr_s, pointer to dmem location where left side
 *                               result s will be stored
 * @param[in]  dmem[20]: dptr_x, pointer to dmem location containing affine
 *                               x-coordinate of input point
 * @param[in]  dmem[24]: dptr_y, pointer to dmem location containing affine
 *                               y-coordinate of input point
 *
 * Flags: Flags have no meaning beyond the scope of this subroutine.
 *
 * clobbered registers: x2, x3, x20 to x23, w0 to w17
 * clobbered flag groups: FG0
 */
check_public_key_valid:
  /* Init all-zero register. */
  bn.xor    w31, w31, w31

  /* load domain parameter p (modulus)
     [w13, w12] = p = dmem[p384_p] */
  li        x2, 12
  la        x3, p384_p
  bn.lid    x2++, 0(x3)
  bn.lid    x2++, 32(x3)

  /* Load public key x-coordinate.
     [w11, w10] <= dmem[x] = x */
  la        x20, dptr_x
  lw        x20, 0(x20)
  li        x2, 10
  bn.lid    x2++, 0(x20)
  bn.lid    x2, 32(x20)

  /* Compare x to p.
       FG0.C <= (x < p) */
  bn.sub    w0, w10, w12
  bn.subb   w0, w11, w13

  /* Trigger a fault if FG0.C is false. */
  csrrs     x2, 0x7c0, x0
  andi      x2, x2, 1
  bne       x2, x0, _x_valid
  unimp

  _x_valid:

  /* Load public key y-coordinate.
       w2 <= dmem[y] = y */
  la        x21, dptr_y
  lw        x21, 0(x21)
  li        x2, 8
  bn.lid    x2++, 0(x21)
  bn.lid    x2, 32(x21)

  /* Compare y to p.
       FG0.C <= (y < p) */
  bn.sub    w0, w8, w12
  bn.subb   w0, w9, w13

  /* Trigger a fault if FG0.C is false. */
  csrrs     x2, 0x7c0, x0
  andi      x2, x2, 1
  bne       x2, x0, _y_valid
  unimp

  _y_valid:

  /* Compute both sides of the Weierstrauss equation.
       dmem[r] <= (x^3 + ax + b) mod p
       dmem[s] <= (y^2) mod p */
  jal       x1, p384_isoncurve

  /* Load both sides of the equation.
       [w7, w6] <= dmem[r]
       [w5, w4] <= dmem[s] */
  la        x22, dptr_r
  lw        x22, 0(x22)
  li        x2, 6
  bn.lid    x2++, 0(x22)
  bn.lid    x2, 32(x22)
  la        x23, dptr_s
  lw        x23, 0(x23)
  li        x2, 4
  bn.lid    x2++, 0(x23)
  bn.lid    x2, 32(x23)

  /* Compare the two sides of the equation.
       FG0.Z <= (y^2) mod p == (x^2 + ax + b) mod p */
  bn.sub    w0, w4, w6
  bn.subb   w1, w5, w7

  bn.cmp    w0, w31

  /* Trigger a fault if FG0.Z is false. */
  csrrs     x2, 0x7c0, x0
  srli      x2, x2, 3
  andi      x2, x2, 1
  bne       x2, x0, _pk_1st_reg_valid
  unimp

  _pk_1st_reg_valid:

  bn.cmp    w1, w31

  /* Trigger a fault if FG0.Z is false. */
  csrrs     x2, 0x7c0, x0
  srli      x2, x2, 3
  andi      x2, x2, 1
  bne       x2, x0, _pk_valid
  unimp


.data

/* Operational mode. */
.globl mode
.balign 4
mode:
  .zero 4

/* pointer to x-coordinate (dptr_x) */
.globl dptr_x
.balign 4
dptr_x:
  .zero 4

/* pointer to y-coordinate (dptr_y) */
.globl dptr_y
.balign 4
dptr_y:
  .zero 4

/* Public key x-coordinate. */
.globl x
.balign 32
x:
  .zero 64

/* Public key y-coordinate. */
.globl y
.balign 32
y:
  .zero 64

/* Secret key (d) in two shares: d = (d0 + d1) mod n.

   Note: This is also labeled k0, k1 because the `p384_scalar_mult` algorithm
   is also used for ECDSA signing and reads from those labels; in the case of
   ECDH, the scalar in `p384_scalar_mult` is always the private key (d). */

/* pointer to d0 (dptr_d0) */
.globl dptr_k0
.globl dptr_d0
.balign 4
dptr_d0:
  .zero 4

/* pointer to d1 (dptr_d1) */
.globl dptr_k1
.globl dptr_d1
.balign 4
dptr_d1:
  .zero 4

.globl d0
.globl k0
.balign 32
d0:
k0:
  .zero 64

.globl d1
.globl k1
.balign 32
d1:
k1:
  .zero 64

.balign 32
