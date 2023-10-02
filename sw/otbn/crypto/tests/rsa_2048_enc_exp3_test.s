/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


.section .text.start

/**
 * Standalone RSA-2048 modexp with e=3 (encryption/verification).
 */
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31

  /* Load number of limbs. */
  li    x30, 8

  /* Load pointers to modulus and Montgomery constant buffers. */
  la    x16, modulus
  la    x17, m0inv
  la    x18, RR

  /* Compute Montgomery constants. */
  jal      x1, modload

  /* Run exponentiation.
       dmem[result] = dmem[base]^dmem[exp] mod dmem[modulus] */
  la       x14, base
  la       x2, result
  jal      x1, modexp_3

  /* copy all limbs of result to wide reg file */
  la       x21, result
  li       x8, 0
  loop     x30, 2
    bn.lid   x8, 0(x21++)
    addi     x8, x8, 1

  ecall

.data

/* Modulus n =
0xdce6e38b92b274343894bc6f4e5d51cd9ee0d11dd7d5dd122d39e47379b44eb4dcfb7d89783fdc7d2f958a84012fe73eccf2b8f2184a38453581284825394c783c74334408cc9236169210c5519201b8e9f9b8ce41e5820573e7e5ce2ef4709ba678269dd123b11c05bd4b031c6b6f4d1da0333439c69f4334dc2f937dacffc3ba68321af91e9121fab93a67af3d8b3998256fddca358e5459ad2aac65149e71743c3b6684d53fcd1d6f6010e79210b8fc55443c466c79e1834183aaa8d2fc2c01f7c931a4d72ca351fb1b20048609cd21d88fa287d511a2a8ea2a5b5859a4aa9f56f7b70e8ffc24359cdb28be9db4087cb39876cb4efb652565788c4961d3b7
 */
.balign 32
modulus:
  .word 0x4961d3b7
  .word 0x2565788c
  .word 0xcb4efb65
  .word 0x7cb39876
  .word 0xbe9db408
  .word 0x359cdb28
  .word 0x0e8ffc24
  .word 0x9f56f7b7
  .word 0x5859a4aa
  .word 0xa8ea2a5b
  .word 0x87d511a2
  .word 0x21d88fa2
  .word 0x048609cd
  .word 0x51fb1b20
  .word 0xa4d72ca3
  .word 0x01f7c931
  .word 0xa8d2fc2c
  .word 0x834183aa
  .word 0x466c79e1
  .word 0xfc55443c
  .word 0xe79210b8
  .word 0x1d6f6010
  .word 0x84d53fcd
  .word 0x743c3b66
  .word 0x65149e71
  .word 0x59ad2aac
  .word 0xca358e54
  .word 0x98256fdd
  .word 0xaf3d8b39
  .word 0xfab93a67
  .word 0xf91e9121
  .word 0xba68321a
  .word 0x7dacffc3
  .word 0x34dc2f93
  .word 0x39c69f43
  .word 0x1da03334
  .word 0x1c6b6f4d
  .word 0x05bd4b03
  .word 0xd123b11c
  .word 0xa678269d
  .word 0x2ef4709b
  .word 0x73e7e5ce
  .word 0x41e58205
  .word 0xe9f9b8ce
  .word 0x519201b8
  .word 0x169210c5
  .word 0x08cc9236
  .word 0x3c743344
  .word 0x25394c78
  .word 0x35812848
  .word 0x184a3845
  .word 0xccf2b8f2
  .word 0x012fe73e
  .word 0x2f958a84
  .word 0x783fdc7d
  .word 0xdcfb7d89
  .word 0x79b44eb4
  .word 0x2d39e473
  .word 0xd7d5dd12
  .word 0x9ee0d11d
  .word 0x4e5d51cd
  .word 0x3894bc6f
  .word 0x92b27434
  .word 0xdce6e38b

/* Base for exponentiation (corresponds to plaintext for encryption or
   signature for verification).

   Raw hex value (signature for 'Test message.' with SHA-256) =
0xd38f0a3a8ca3c275ca43ad21ce1d734e6cbbf6bc3c731a31f82478b7ad450c8b1054438a4244f9f008f23de7b90d469fe3b16c9df1b76161c1b212d0bb503bc8bdc68dc6f9b65922c163a9eac9e0913d325a9da29c09a9dcca6da86a4c0b7cde88a45b5c2498ced99d9cd948130a021a43da7b0d0bc94fe6369a27fc4fd6f75fb20aa6a53a145aba06d9d4cc974d0844e37dcca1dc0b5b580741fba8d56026c8c2b912a0b92cc0e5d666bf3411f77a55a4caa3c63e7b08c743eb6c93a6cc1b25df0066e0cc9b8cc7e2a15947c0889c751a8bad4cca0253fa5b438615266e95f95facd8a250fafb7c93f5debb3dca60c36726fcab891e8e43df1439fbd5a70bc8
 */
.balign 32
base:
  .word 0xd5a70bc8
  .word 0xdf1439fb
  .word 0x891e8e43
  .word 0x6726fcab
  .word 0x3dca60c3
  .word 0x93f5debb
  .word 0x50fafb7c
  .word 0x5facd8a2
  .word 0x266e95f9
  .word 0x5b438615
  .word 0xca0253fa
  .word 0x1a8bad4c
  .word 0xc0889c75
  .word 0xe2a15947
  .word 0xcc9b8cc7
  .word 0xdf0066e0
  .word 0xa6cc1b25
  .word 0x43eb6c93
  .word 0x3e7b08c7
  .word 0xa4caa3c6
  .word 0x11f77a55
  .word 0xd666bf34
  .word 0xb92cc0e5
  .word 0xc2b912a0
  .word 0xd56026c8
  .word 0x0741fba8
  .word 0xdc0b5b58
  .word 0xe37dcca1
  .word 0x974d0844
  .word 0x06d9d4cc
  .word 0x3a145aba
  .word 0xb20aa6a5
  .word 0x4fd6f75f
  .word 0x369a27fc
  .word 0x0bc94fe6
  .word 0x43da7b0d
  .word 0x130a021a
  .word 0x9d9cd948
  .word 0x2498ced9
  .word 0x88a45b5c
  .word 0x4c0b7cde
  .word 0xca6da86a
  .word 0x9c09a9dc
  .word 0x325a9da2
  .word 0xc9e0913d
  .word 0xc163a9ea
  .word 0xf9b65922
  .word 0xbdc68dc6
  .word 0xbb503bc8
  .word 0xc1b212d0
  .word 0xf1b76161
  .word 0xe3b16c9d
  .word 0xb90d469f
  .word 0x08f23de7
  .word 0x4244f9f0
  .word 0x1054438a
  .word 0xad450c8b
  .word 0xf82478b7
  .word 0x3c731a31
  .word 0x6cbbf6bc
  .word 0xce1d734e
  .word 0xca43ad21
  .word 0x8ca3c275
  .word 0xd38f0a3a

/* output buffer */
.balign 32
result:
.zero 256

/* buffer for Montgomery constant RR */
.balign 32
RR:
.zero 256

/* buffer for Montgomery constant m0inv */
.balign 32
m0inv:
.zero 32
