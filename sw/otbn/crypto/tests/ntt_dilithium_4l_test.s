/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for ntt_dilithium_4l_test
*/

.section .text.start

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31

  /* MOD <= dmem[modulus] = DILITHIUM_Q */
  li      x2, 2
  la      x3, modulus
  bn.lid  x2, 0(x3)
  bn.wsrw 0x0, w2

  /* dmem[data] <= NTT_4(dmem[input]) */
  la  x30, input
  la  x31, twiddles
  jal  x1, ntt_dilithium_4l

  ecall

.data
.balign 32
/* First input */
input:
    .word 0x00000000
    .word 0x00000001
    .word 0x00000010
    .word 0x00000051
    .word 0x00000100
    .word 0x00000271
    .word 0x00000510
    .word 0x00000961
    .word 0x00001000
    .word 0x000019a1
    .word 0x00002710
    .word 0x00003931
    .word 0x00005100
    .word 0x00006f91
    .word 0x00009610
    .word 0x0000c5c1
    .word 0x00010000
    .word 0x00014641
    .word 0x00019a10
    .word 0x0001fd11
    .word 0x00027100
    .word 0x0002f7b1
    .word 0x00039310
    .word 0x00044521
    .word 0x00051000
    .word 0x0005f5e1
    .word 0x0006f910
    .word 0x00081bf1
    .word 0x00096100
    .word 0x000acad1
    .word 0x000c5c10
    .word 0x000e1781
    .word 0x00100000
    .word 0x00121881
    .word 0x00146410
    .word 0x0016e5d1
    .word 0x0019a100
    .word 0x001c98f1
    .word 0x001fd110
    .word 0x00234ce1
    .word 0x00271000
    .word 0x002b1e21
    .word 0x002f7b10
    .word 0x00342ab1
    .word 0x00393100
    .word 0x003e9211
    .word 0x00445210
    .word 0x004a7541
    .word 0x00510000
    .word 0x0057f6c1
    .word 0x005f5e10
    .word 0x00673a91
    .word 0x006f9100
    .word 0x00786631
    .word 0x0001df0f
    .word 0x000bc0a0
    .word 0x00162fff
    .word 0x00213260
    .word 0x002ccd0f
    .word 0x00390570
    .word 0x0045e0ff
    .word 0x00536550
    .word 0x0061980f
    .word 0x00707f00
    .word 0x00003ffe
    .word 0x0010a0ff
    .word 0x0021c80e
    .word 0x0033bb4f
    .word 0x004680fe
    .word 0x005a1f6f
    .word 0x006e9d0e
    .word 0x0004205e
    .word 0x001a6ffd
    .word 0x0031b29e
    .word 0x0049ef0d
    .word 0x00632c2e
    .word 0x007d70fd
    .word 0x0018e48d
    .word 0x00354e0c
    .word 0x0052d4bd
    .word 0x00717ffc
    .word 0x0011773c
    .word 0x0032820b
    .word 0x0054c80c
    .word 0x007850fb
    .word 0x001d44ab
    .word 0x00436b0a
    .word 0x006aec1b
    .word 0x0013eff9
    .word 0x003e3eda
    .word 0x006a0109
    .word 0x00175ee9
    .word 0x004620f8
    .word 0x00766fc9
    .word 0x00287407
    .word 0x005bf678
    .word 0x00113ff6
    .word 0x00481977
    .word 0x0000cc05
    .word 0x003b20c6
    .word 0x007740f5
    .word 0x003555e5
    .word 0x00752904
    .word 0x003703d4
    .word 0x007aaff3
    .word 0x00407713
    .word 0x00084301
    .word 0x0051fda2
    .word 0x001df0f0
    .word 0x006be701
    .word 0x003c29ff
    .word 0x000ea42f
    .word 0x00633fee
    .word 0x003a47ae
    .word 0x0013a5fc
    .word 0x006f457d
    .word 0x004d70eb
    .word 0x002e131b
    .word 0x001136f9
    .word 0x0076c78a
    .word 0x005f0fe8
    .word 0x0049fb48
    .word 0x003794f6
    .word 0x0027e856
    .word 0x001b00e4
    .word 0x0010ea34
    .word 0x0009aff2
    .word 0x00055de2
    .word 0x0003ffe0
    .word 0x0005a1e0
    .word 0x000a4fee
    .word 0x0012162e
    .word 0x001d00dc
    .word 0x002b1c4c
    .word 0x003c74ea
    .word 0x0051173a
    .word 0x00690fd8
    .word 0x00048b77
    .word 0x002356e5
    .word 0x00459f05
    .word 0x006b70d3
    .word 0x0014f962
    .word 0x004205e0
    .word 0x0072c390
    .word 0x00275fcd
    .word 0x005fa80d
    .word 0x001be9da
    .word 0x005bf2da
    .word 0x002010c7
    .word 0x00681177
    .word 0x003442d4
    .word 0x000492e3
    .word 0x0058efc1
    .word 0x0031a7a0
    .word 0x000ea8cd
    .word 0x006fe1ad
    .word 0x0055a0ba
    .word 0x003fd489
    .word 0x002e8bc6
    .word 0x0021d535
    .word 0x0019bfb2
    .word 0x00165a31
    .word 0x0017b3be
    .word 0x001ddb7d
    .word 0x0028e0aa
    .word 0x0038d299
    .word 0x004dc0b6
    .word 0x0067ba85
    .word 0x0006efa1
    .word 0x002b2fc0
    .word 0x0054aaad
    .word 0x0003904b
    .word 0x0037b098
    .word 0x00713ba7
    .word 0x003061a3
    .word 0x0074f2d2
    .word 0x003f3f8e
    .word 0x000f384c
    .word 0x0064cd99
    .word 0x00405017
    .word 0x0021b083
    .word 0x0008ffb1
    .word 0x00762e8e
    .word 0x00698e1c
    .word 0x00630f78
    .word 0x0062c3d6
    .word 0x0068bc82
    .word 0x00750ae0
    .word 0x0007e06b
    .word 0x00210eb9
    .word 0x0040c775
    .word 0x00671c63
    .word 0x00143f5e
    .word 0x0048025c
    .word 0x0002b767
    .word 0x004430a5
    .word 0x000cc050
    .word 0x005c38be
    .word 0x0032ec59
    .word 0x0010cda6
    .word 0x0075cf42
    .word 0x006243df
    .word 0x00561e4a
    .word 0x00517167
    .word 0x00545032
    .word 0x005ecdbf
    .word 0x0070fd3a
    .word 0x000b11e6
    .word 0x002cdf21
    .word 0x0056985e
    .word 0x00087128
    .word 0x00423d25
    .word 0x0004500f
    .word 0x004e7dbc
    .word 0x00211a16
    .word 0x007bf923
    .word 0x005f6efd
    .word 0x004b6fd9
    .word 0x00401003
    .word 0x003d63df
    .word 0x00437fe9
    .word 0x005278b5
    .word 0x006a62ef
    .word 0x000b735a
    .word 0x00357ed4
    .word 0x0068ba50
    .word 0x00255ad9
    .word 0x006b3595
    .word 0x003a9fbe
    .word 0x00138ea9
    .word 0x0075f7c3
    .word 0x0062308e
    .word 0x00582ea7
    .word 0x005807c2
    .word 0x0061d1ab
    .word 0x0075a246
    .word 0x0013af8e
    .word 0x003bcf99
    .word 0x006e3892
    .word 0x002b20bc
    .word 0x00725e75
    .word 0x0044482f
    .word 0x0020d477
    .word 0x000819f1
    .word 0x007a0f5a
    .word 0x00770b84
    .word 0x007f055c
    .word 0x001233e5
    .word 0x00306e3d
    .word 0x0059eb97
    .word 0x000ee33e
    .word 0x004f2c98
    .word 0x001b1f1f
    .word 0x00729269
    .word 0x0055de20
    .word 0x0044fa09

/* Modulus for reduction */
modulus:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/* Second input */
twiddles:
    .word 0x00495e02
    .word 0x00397567
    .word 0x00396569
    .word 0x004f062b
    .word 0x0053df73
    .word 0x004fe033
    .word 0x004f066b
    .word 0x0076b1ae
    .word 0x00360dd5
    .word 0x0028edb0
    .word 0x00207fe4
    .word 0x00397283
    .word 0x0070894a
    .word 0x00088192
    .word 0x006d3dc8
    .word 0x00000000