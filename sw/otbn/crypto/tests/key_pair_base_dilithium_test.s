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
  
  /* MOD <= dmem[modulus] = DILITHIUM_Q */
  li      x5, 2
  la      x6, modulus
  bn.lid  x5, 0(x6)
  bn.rshi w2, w31, w2 >> 224
  bn.wsrw 0x0, w2

  /* Loadf stack address */
  la  x2, stack_end
  la  x10, zeta
  la  x11, pk
  la  x12, sk
  jal x1, key_pair_base_dilithium

  ecall

.data
.balign 32
.global stack
stack:
    .zero 40000
stack_end:
pk:
  .zero 1312
sk:
  .zero 2528

.balign 32
zeta:
  .word 0xa035997c /* 0x7c9935a0 */
  .word 0xaa9476b0 /* 0xb07694aa */
  .word 0xe4106d0c /* 0x0c6d10e4 */
  .word 0xdd1a6bdb /* 0xdb6b1add */
  .word 0x251ad82f /* 0x2fd81a25 */
  .word 0x0348b1cc /* 0xccb14803 */
  .word 0x9973cd2d /* 0x2dcd7399 */
  .word 0x2d7f7336 /* 0x36737f2d */
/* Modulus for reduction */
.global modulus
modulus:
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
  .word 0x007fe001
.global modulus_base
modulus_base:
  .word 0x007fe001
  .word 0x0
  .word 0x0
  .word 0x0
  .word 0x0
  .word 0x0
  .word 0x0
  .word 0x0
.global twiddles_fwd
twiddles_fwd:
  /* Layers 1-4 */
    .word 0x00495e02, 0x00000000
    .word 0x00397567, 0x00000000
    .word 0x00396569, 0x00000000
    .word 0x004f062b, 0x00000000
    .word 0x0053df73, 0x00000000
    .word 0x004fe033, 0x00000000
    .word 0x004f066b, 0x00000000
    .word 0x0076b1ae, 0x00000000
    .word 0x00360dd5, 0x00000000
    .word 0x0028edb0, 0x00000000
    .word 0x00207fe4, 0x00000000
    .word 0x00397283, 0x00000000
    .word 0x0070894a, 0x00000000
    .word 0x00088192, 0x00000000
    .word 0x006d3dc8, 0x00000000
    /* Padding */
    .word 0x00000000
    .word 0 /* Padding */
    /* Layer 5 - 1 */
    .word 0x004c7294, 0x00000000
    /* Layer 6 - 1 */
    .word 0x0036f72a, 0x00000000
    .word 0x0030911e, 0x00000000
    /* Layer 7 - 1 */
    .word 0x002ee3f1, 0x00000000
    .word 0x00137eb9, 0x00000000
    .word 0x0057a930, 0x00000000
    .word 0x003ac6ef, 0x00000000
    /* Layer 8 - 1 */
    .word 0x000006d9, 0x00000000
    .word 0x006257c5, 0x00000000
    .word 0x00574b3c, 0x00000000
    .word 0x0069a8ef, 0x00000000
    .word 0x00289838, 0x00000000
    .word 0x0064b5fe, 0x00000000
    .word 0x007ef8f5, 0x00000000
    .word 0x002a4e78, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 2 */
    .word 0x0041e0b4, 0x00000000
    /* Layer 6 - 2 */
    .word 0x0029d13f, 0x00000000
    .word 0x00492673, 0x00000000
    /* Layer 7 - 2 */
    .word 0x003fd54c, 0x00000000
    .word 0x004eb2ea, 0x00000000
    .word 0x00503ee1, 0x00000000
    .word 0x007bb175, 0x00000000
    /* Layer 8 - 2 */
    .word 0x00120a23, 0x00000000
    .word 0x000154a8, 0x00000000
    .word 0x0009b7ff, 0x00000000
    .word 0x00435e87, 0x00000000
    .word 0x00437ff8, 0x00000000
    .word 0x005cd5b4, 0x00000000
    .word 0x004dc04e, 0x00000000
    .word 0x004728af, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 3 */
    .word 0x0028a3d2, 0x00000000
    /* Layer 6 - 3 */
    .word 0x0050685f, 0x00000000
    .word 0x002010a2, 0x00000000
    /* Layer 7 - 3 */
    .word 0x002648b4, 0x00000000
    .word 0x001ef256, 0x00000000
    .word 0x001d90a2, 0x00000000
    .word 0x0045a6d4, 0x00000000
    /* Layer 8 - 3 */
    .word 0x007f735d, 0x00000000
    .word 0x000c8d0d, 0x00000000
    .word 0x000f66d5, 0x00000000
    .word 0x005a6d80, 0x00000000
    .word 0x0061ab98, 0x00000000
    .word 0x00185d96, 0x00000000
    .word 0x00437f31, 0x00000000
    .word 0x00468298, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 4 */
    .word 0x0066528a, 0x00000000
    /* Layer 6 - 4 */
    .word 0x003887f7, 0x00000000
    .word 0x0011b2c3, 0x00000000
    /* Layer 7 - 4 */
    .word 0x002ae59b, 0x00000000
    .word 0x0052589c, 0x00000000
    .word 0x006ef1f5, 0x00000000
    .word 0x003f7288, 0x00000000
    /* Layer 8 - 4 */
    .word 0x00662960, 0x00000000
    .word 0x004bd579, 0x00000000
    .word 0x0028de06, 0x00000000
    .word 0x00465d8d, 0x00000000
    .word 0x0049b0e3, 0x00000000
    .word 0x0009b434, 0x00000000
    .word 0x007c0db3, 0x00000000
    .word 0x005a68b0, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 5 */
    .word 0x004a18a7, 0x00000000
    /* Layer 6 - 5 */
    .word 0x000603a4, 0x00000000
    .word 0x000e2bed, 0x00000000
    /* Layer 7 - 5 */
    .word 0x00175102, 0x00000000
    .word 0x00075d59, 0x00000000
    .word 0x001187ba, 0x00000000
    .word 0x0052aca9, 0x00000000
    /* Layer 8 - 5 */
    .word 0x00409ba9, 0x00000000
    .word 0x0064d3d5, 0x00000000
    .word 0x0021762a, 0x00000000
    .word 0x00658591, 0x00000000
    .word 0x00246e39, 0x00000000
    .word 0x0048c39b, 0x00000000
    .word 0x007bc759, 0x00000000
    .word 0x004f5859, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 6 */
    .word 0x00794034, 0x00000000
    /* Layer 6 - 6 */
    .word 0x0010b72c, 0x00000000
    .word 0x004a5f35, 0x00000000
    /* Layer 7 - 6 */
    .word 0x00773e9e, 0x00000000
    .word 0x000296d8, 0x00000000
    .word 0x002592ec, 0x00000000
    .word 0x004cff12, 0x00000000
    /* Layer 8 - 6 */
    .word 0x00392db2, 0x00000000
    .word 0x00230923, 0x00000000
    .word 0x0012eb67, 0x00000000
    .word 0x00454df2, 0x00000000
    .word 0x0030c31c, 0x00000000
    .word 0x00285424, 0x00000000
    .word 0x0013232e, 0x00000000
    .word 0x007faf80, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 7 */
    .word 0x000a52ee, 0x00000000
    /* Layer 6 - 7 */
    .word 0x001f9d15, 0x00000000
    .word 0x00428cd4, 0x00000000
    /* Layer 7 - 7 */
    .word 0x00404ce8, 0x00000000
    .word 0x004aa582, 0x00000000
    .word 0x001e54e6, 0x00000000
    .word 0x004f16c1, 0x00000000
    /* Layer 8 - 7 */
    .word 0x002dbfcb, 0x00000000
    .word 0x00022a0b, 0x00000000
    .word 0x007e832c, 0x00000000
    .word 0x0026587a, 0x00000000
    .word 0x006b3375, 0x00000000
    .word 0x00095b76, 0x00000000
    .word 0x006be1cc, 0x00000000
    .word 0x005e061e, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 8 */
    .word 0x006b7d81, 0x00000000
    /* Layer 6 - 8 */
    .word 0x003177f4, 0x00000000
    .word 0x0020e612, 0x00000000
    /* Layer 7 - 8 */
    .word 0x001a7e79, 0x00000000
    .word 0x0003978f, 0x00000000
    .word 0x004e4817, 0x00000000
    .word 0x0031b859, 0x00000000
    /* Layer 8 - 8 */
    .word 0x0078e00d, 0x00000000
    .word 0x00628c37, 0x00000000
    .word 0x003da604, 0x00000000
    .word 0x004ae53c, 0x00000000
    .word 0x001f1d68, 0x00000000
    .word 0x006330bb, 0x00000000
    .word 0x007361b8, 0x00000000
    .word 0x005ea06c, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 9 */
    .word 0x004e9f1d, 0x00000000
    /* Layer 6 - 9 */
    .word 0x00341c1d, 0x00000000
    .word 0x001ad873, 0x00000000
    /* Layer 7 - 9 */
    .word 0x005884cc, 0x00000000
    .word 0x001b4827, 0x00000000
    .word 0x005b63d0, 0x00000000
    .word 0x005d787a, 0x00000000
    /* Layer 8 - 9 */
    .word 0x00671ac7, 0x00000000
    .word 0x00201fc6, 0x00000000
    .word 0x005ba4ff, 0x00000000
    .word 0x0060d772, 0x00000000
    .word 0x0008f201, 0x00000000
    .word 0x006de024, 0x00000000
    .word 0x00080e6d, 0x00000000
    .word 0x0056038e, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 10 */
    .word 0x001a2877, 0x00000000
    /* Layer 6 - 10 */
    .word 0x00736681, 0x00000000
    .word 0x0049553f, 0x00000000
    /* Layer 7 - 10 */
    .word 0x0035225e, 0x00000000
    .word 0x00400c7e, 0x00000000
    .word 0x006c09d1, 0x00000000
    .word 0x005bd532, 0x00000000
    /* Layer 8 - 10 */
    .word 0x00695688, 0x00000000
    .word 0x001e6d3e, 0x00000000
    .word 0x002603bd, 0x00000000
    .word 0x006a9dfa, 0x00000000
    .word 0x0007c017, 0x00000000
    .word 0x006dbfd4, 0x00000000
    .word 0x0074d0bd, 0x00000000
    .word 0x0063e1e3, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 11 */
    .word 0x002571df, 0x00000000
    /* Layer 6 - 11 */
    .word 0x003952f6, 0x00000000
    .word 0x0062564a, 0x00000000
    /* Layer 7 - 11 */
    .word 0x006bc4d3, 0x00000000
    .word 0x00258ecb, 0x00000000
    .word 0x002e534c, 0x00000000
    .word 0x00097a6c, 0x00000000
    /* Layer 8 - 11 */
    .word 0x00519573, 0x00000000
    .word 0x007ab60d, 0x00000000
    .word 0x002867ba, 0x00000000
    .word 0x002decd4, 0x00000000
    .word 0x0058018c, 0x00000000
    .word 0x003f4cf5, 0x00000000
    .word 0x000b7009, 0x00000000
    .word 0x00427e23, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 12 */
    .word 0x001649ee, 0x00000000
    /* Layer 6 - 12 */
    .word 0x0065ad05, 0x00000000
    .word 0x00439a1c, 0x00000000
    /* Layer 7 - 12 */
    .word 0x003b8820, 0x00000000
    .word 0x006d285c, 0x00000000
    .word 0x002ca4f8, 0x00000000
    .word 0x00337caa, 0x00000000
    /* Layer 8 - 12 */
    .word 0x003cbd37, 0x00000000
    .word 0x00273333, 0x00000000
    .word 0x00673957, 0x00000000
    .word 0x001a4b5d, 0x00000000
    .word 0x00196926, 0x00000000
    .word 0x001ef206, 0x00000000
    .word 0x0011c14e, 0x00000000
    .word 0x004c76c8, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 13 */
    .word 0x007611bd, 0x00000000
    /* Layer 6 - 13 */
    .word 0x0053aa5f, 0x00000000
    .word 0x0030b622, 0x00000000
    /* Layer 7 - 13 */
    .word 0x0014b2a0, 0x00000000
    .word 0x00558536, 0x00000000
    .word 0x0028f186, 0x00000000
    .word 0x0055795d, 0x00000000
    /* Layer 8 - 13 */
    .word 0x003cf42f, 0x00000000
    .word 0x007fb19a, 0x00000000
    .word 0x006af66c, 0x00000000
    .word 0x002e1669, 0x00000000
    .word 0x003352d6, 0x00000000
    .word 0x00034760, 0x00000000
    .word 0x00085260, 0x00000000
    .word 0x00741e78, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 14 */
    .word 0x00492bb7, 0x00000000
    /* Layer 6 - 14 */
    .word 0x00087f38, 0x00000000
    .word 0x003b0e6d, 0x00000000
    /* Layer 7 - 14 */
    .word 0x004af670, 0x00000000
    .word 0x00234a86, 0x00000000
    .word 0x0075e826, 0x00000000
    .word 0x0078de66, 0x00000000
    /* Layer 8 - 14 */
    .word 0x002f6316, 0x00000000
    .word 0x006f0a11, 0x00000000
    .word 0x0007c0f1, 0x00000000
    .word 0x00776d0b, 0x00000000
    .word 0x000d1ff0, 0x00000000
    .word 0x00345824, 0x00000000
    .word 0x000223d4, 0x00000000
    .word 0x0068c559, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 15 */
    .word 0x002af697, 0x00000000
    /* Layer 6 - 15 */
    .word 0x002c83da, 0x00000000
    .word 0x001c496e, 0x00000000
    /* Layer 7 - 15 */
    .word 0x0005528c, 0x00000000
    .word 0x007adf59, 0x00000000
    .word 0x000f6e17, 0x00000000
    .word 0x005bf3da, 0x00000000
    /* Layer 8 - 15 */
    .word 0x005e8885, 0x00000000
    .word 0x002faa32, 0x00000000
    .word 0x0023fc65, 0x00000000
    .word 0x005e6942, 0x00000000
    .word 0x0051e0ed, 0x00000000
    .word 0x0065adb3, 0x00000000
    .word 0x002ca5e6, 0x00000000
    .word 0x0079e1fe, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 16 */
    .word 0x0022d8d5, 0x00000000
    /* Layer 6 - 16 */
    .word 0x00330e2b, 0x00000000
    .word 0x001c5b70, 0x00000000
    /* Layer 7 - 16 */
    .word 0x00459b7e, 0x00000000
    .word 0x00628b34, 0x00000000
    .word 0x005dbecb, 0x00000000
    .word 0x001a9e7b, 0x00000000
    /* Layer 8 - 16 */
    .word 0x007b4064, 0x00000000
    .word 0x0035e1dd, 0x00000000
    .word 0x00433aac, 0x00000000
    .word 0x00464ade, 0x00000000
    .word 0x001cfe14, 0x00000000
    .word 0x0073f1ce, 0x00000000
    .word 0x0010170e, 0x00000000
    .word 0x0074b6d7, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    .global twiddles_inv
    twiddles_inv:
        /* Inv Layer 8 - 1 */
    .word 0x000b292a, 0x00000000
    .word 0x006fc8f3, 0x00000000
    .word 0x000bee33, 0x00000000
    .word 0x0062e1ed, 0x00000000
    .word 0x00399523, 0x00000000
    .word 0x003ca555, 0x00000000
    .word 0x0049fe24, 0x00000000
    .word 0x00049f9d, 0x00000000
    /* Inv Layer 7 - 1 */
    .word 0x00654186, 0x00000000
    .word 0x00222136, 0x00000000
    .word 0x001d54cd, 0x00000000
    .word 0x003a4483, 0x00000000
    /* Inv Layer 6 - 1 */
    .word 0x00638491, 0x00000000
    .word 0x004cd1d6, 0x00000000
    /* Inv Layer 5 - 1 */
    .word 0x005d072c, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 2 */
    .word 0x0005fe03, 0x00000000
    .word 0x00533a1b, 0x00000000
    .word 0x001a324e, 0x00000000
    .word 0x002dff14, 0x00000000
    .word 0x002176bf, 0x00000000
    .word 0x005be39c, 0x00000000
    .word 0x005035cf, 0x00000000
    .word 0x0021577c, 0x00000000
    /* Inv Layer 7 - 2 */
    .word 0x0023ec27, 0x00000000
    .word 0x007071ea, 0x00000000
    .word 0x000500a8, 0x00000000
    .word 0x007a8d75, 0x00000000
    /* Inv Layer 6 - 2 */
    .word 0x00639693, 0x00000000
    .word 0x00535c27, 0x00000000
    /* Inv Layer 5 - 2 */
    .word 0x0054e96a, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 3 */
    .word 0x00171aa8, 0x00000000
    .word 0x007dbc2d, 0x00000000
    .word 0x004b87dd, 0x00000000
    .word 0x0072c011, 0x00000000
    .word 0x000872f6, 0x00000000
    .word 0x00781f10, 0x00000000
    .word 0x0010d5f0, 0x00000000
    .word 0x00507ceb, 0x00000000
    /* Inv Layer 7 - 3 */
    .word 0x0007019b, 0x00000000
    .word 0x0009f7db, 0x00000000
    .word 0x005c957b, 0x00000000
    .word 0x0034e991, 0x00000000
    /* Inv Layer 6 - 3 */
    .word 0x0044d194, 0x00000000
    .word 0x007760c9, 0x00000000
    /* Inv Layer 5 - 3 */
    .word 0x0036b44a, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 4 */
    .word 0x000bc189, 0x00000000
    .word 0x00778da1, 0x00000000
    .word 0x007c98a1, 0x00000000
    .word 0x004c8d2b, 0x00000000
    .word 0x0051c998, 0x00000000
    .word 0x0014e995, 0x00000000
    .word 0x00002e67, 0x00000000
    .word 0x0042ebd2, 0x00000000
    /* Inv Layer 7 - 4 */
    .word 0x002a66a4, 0x00000000
    .word 0x0056ee7b, 0x00000000
    .word 0x002a5acb, 0x00000000
    .word 0x006b2d61, 0x00000000
    /* Inv Layer 6 - 4 */
    .word 0x004f29df, 0x00000000
    .word 0x002c35a2, 0x00000000
    /* Inv Layer 5 - 4 */
    .word 0x0009ce44, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 5 */
    .word 0x00336939, 0x00000000
    .word 0x006e1eb3, 0x00000000
    .word 0x0060edfb, 0x00000000
    .word 0x006676db, 0x00000000
    .word 0x006594a4, 0x00000000
    .word 0x0018a6aa, 0x00000000
    .word 0x0058acce, 0x00000000
    .word 0x004322ca, 0x00000000
    /* Inv Layer 7 - 5 */
    .word 0x004c6357, 0x00000000
    .word 0x00533b09, 0x00000000
    .word 0x0012b7a5, 0x00000000
    .word 0x004457e1, 0x00000000
    /* Inv Layer 6 - 5 */
    .word 0x003c45e5, 0x00000000
    .word 0x001a32fc, 0x00000000
    /* Inv Layer 5 - 5 */
    .word 0x00699613, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 6 */
    .word 0x003d61de, 0x00000000
    .word 0x00746ff8, 0x00000000
    .word 0x0040930c, 0x00000000
    .word 0x0027de75, 0x00000000
    .word 0x0051f32d, 0x00000000
    .word 0x00577847, 0x00000000
    .word 0x000529f4, 0x00000000
    .word 0x002e4a8e, 0x00000000
    /* Inv Layer 7 - 6 */
    .word 0x00766595, 0x00000000
    .word 0x00518cb5, 0x00000000
    .word 0x005a5136, 0x00000000
    .word 0x00141b2e, 0x00000000
    /* Inv Layer 6 - 6 */
    .word 0x001d89b7, 0x00000000
    .word 0x00468d0b, 0x00000000
    /* Inv Layer 5 - 6 */
    .word 0x005a6e22, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 7 */
    .word 0x001bfe1e, 0x00000000
    .word 0x000b0f44, 0x00000000
    .word 0x0012202d, 0x00000000
    .word 0x00781fea, 0x00000000
    .word 0x00154207, 0x00000000
    .word 0x0059dc44, 0x00000000
    .word 0x006172c3, 0x00000000
    .word 0x00168979, 0x00000000
    /* Inv Layer 7 - 7 */
    .word 0x00240acf, 0x00000000
    .word 0x0013d630, 0x00000000
    .word 0x003fd383, 0x00000000
    .word 0x004abda3, 0x00000000
    /* Inv Layer 6 - 7 */
    .word 0x00368ac2, 0x00000000
    .word 0x000c7980, 0x00000000
    /* Inv Layer 5 - 7 */
    .word 0x0065b78a, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 8 */
    .word 0x0029dc73, 0x00000000
    .word 0x0077d194, 0x00000000
    .word 0x0011ffdd, 0x00000000
    .word 0x0076ee00, 0x00000000
    .word 0x001f088f, 0x00000000
    .word 0x00243b02, 0x00000000
    .word 0x005fc03b, 0x00000000
    .word 0x0018c53a, 0x00000000
    /* Inv Layer 7 - 8 */
    .word 0x00226787, 0x00000000
    .word 0x00247c31, 0x00000000
    .word 0x006497da, 0x00000000
    .word 0x00275b35, 0x00000000
    /* Inv Layer 6 - 8 */
    .word 0x0065078e, 0x00000000
    .word 0x004bc3e4, 0x00000000
    /* Inv Layer 5 - 8 */
    .word 0x003140e4, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 9 */
    .word 0x00213f95, 0x00000000
    .word 0x000c7e49, 0x00000000
    .word 0x001caf46, 0x00000000
    .word 0x0060c299, 0x00000000
    .word 0x0034fac5, 0x00000000
    .word 0x004239fd, 0x00000000
    .word 0x001d53ca, 0x00000000
    .word 0x0006fff4, 0x00000000
    /* Inv Layer 7 - 9 */
    .word 0x004e27a8, 0x00000000
    .word 0x003197ea, 0x00000000
    .word 0x007c4872, 0x00000000
    .word 0x00656188, 0x00000000
    /* Inv Layer 6 - 9 */
    .word 0x005ef9ef, 0x00000000
    .word 0x004e680d, 0x00000000
    /* Inv Layer 5 - 9 */
    .word 0x00146280, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 10 */
    .word 0x0021d9e3, 0x00000000
    .word 0x0013fe35, 0x00000000
    .word 0x0076848b, 0x00000000
    .word 0x0014ac8c, 0x00000000
    .word 0x00598787, 0x00000000
    .word 0x00015cd5, 0x00000000
    .word 0x007db5f6, 0x00000000
    .word 0x00522036, 0x00000000
    /* Inv Layer 7 - 10 */
    .word 0x0030c940, 0x00000000
    .word 0x00618b1b, 0x00000000
    .word 0x00353a7f, 0x00000000
    .word 0x003f9319, 0x00000000
    /* Inv Layer 6 - 10 */
    .word 0x003d532d, 0x00000000
    .word 0x006042ec, 0x00000000
    /* Inv Layer 5 - 10 */
    .word 0x00758d13, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 11 */
    .word 0x00003081, 0x00000000
    .word 0x006cbcd3, 0x00000000
    .word 0x00578bdd, 0x00000000
    .word 0x004f1ce5, 0x00000000
    .word 0x003a920f, 0x00000000
    .word 0x006cf49a, 0x00000000
    .word 0x005cd6de, 0x00000000
    .word 0x0046b24f, 0x00000000
    /* Inv Layer 7 - 11 */
    .word 0x0032e0ef, 0x00000000
    .word 0x005a4d15, 0x00000000
    .word 0x007d4929, 0x00000000
    .word 0x0008a163, 0x00000000
    /* Inv Layer 6 - 11 */
    .word 0x003580cc, 0x00000000
    .word 0x006f28d5, 0x00000000
    /* Inv Layer 5 - 11 */
    .word 0x00069fcd, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 12 */
    .word 0x003087a8, 0x00000000
    .word 0x000418a8, 0x00000000
    .word 0x00371c66, 0x00000000
    .word 0x005b71c8, 0x00000000
    .word 0x001a5a70, 0x00000000
    .word 0x005e69d7, 0x00000000
    .word 0x001b0c2c, 0x00000000
    .word 0x003f4458, 0x00000000
    /* Inv Layer 7 - 12 */
    .word 0x002d3358, 0x00000000
    .word 0x006e5847, 0x00000000
    .word 0x007882a8, 0x00000000
    .word 0x00688eff, 0x00000000
    /* Inv Layer 6 - 12 */
    .word 0x0071b414, 0x00000000
    .word 0x0079dc5d, 0x00000000
    /* Inv Layer 5 - 12 */
    .word 0x0035c75a, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 13 */
    .word 0x00257751, 0x00000000
    .word 0x0003d24e, 0x00000000
    .word 0x00762bcd, 0x00000000
    .word 0x00362f1e, 0x00000000
    .word 0x00398274, 0x00000000
    .word 0x005701fb, 0x00000000
    .word 0x00340a88, 0x00000000
    .word 0x0019b6a1, 0x00000000
    /* Inv Layer 7 - 13 */
    .word 0x00406d79, 0x00000000
    .word 0x0010ee0c, 0x00000000
    .word 0x002d8765, 0x00000000
    .word 0x0054fa66, 0x00000000
    /* Inv Layer 6 - 13 */
    .word 0x006e2d3e, 0x00000000
    .word 0x0047580a, 0x00000000
    /* Inv Layer 5 - 13 */
    .word 0x00198d77, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 14 */
    .word 0x00395d69, 0x00000000
    .word 0x003c60d0, 0x00000000
    .word 0x0067826b, 0x00000000
    .word 0x001e3469, 0x00000000
    .word 0x00257281, 0x00000000
    .word 0x0070792c, 0x00000000
    .word 0x007352f4, 0x00000000
    .word 0x00006ca4, 0x00000000
    /* Inv Layer 7 - 14 */
    .word 0x003a392d, 0x00000000
    .word 0x00624f5f, 0x00000000
    .word 0x0060edab, 0x00000000
    .word 0x0059974d, 0x00000000
    /* Inv Layer 6 - 14 */
    .word 0x005fcf5f, 0x00000000
    .word 0x002f77a2, 0x00000000
    /* Inv Layer 5 - 14 */
    .word 0x00573c2f, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 15 */
    .word 0x0038b752, 0x00000000
    .word 0x00321fb3, 0x00000000
    .word 0x00230a4d, 0x00000000
    .word 0x003c6009, 0x00000000
    .word 0x003c817a, 0x00000000
    .word 0x00762802, 0x00000000
    .word 0x007e8b59, 0x00000000
    .word 0x006dd5de, 0x00000000
    /* Inv Layer 7 - 15 */
    .word 0x00042e8c, 0x00000000
    .word 0x002fa120, 0x00000000
    .word 0x00312d17, 0x00000000
    .word 0x00400ab5, 0x00000000
    /* Inv Layer 6 - 15 */
    .word 0x0036b98e, 0x00000000
    .word 0x00560ec2, 0x00000000
    /* Inv Layer 5 - 15 */
    .word 0x003dff4d, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 16 */
    .word 0x00559189, 0x00000000
    .word 0x0000e70c, 0x00000000
    .word 0x001b2a03, 0x00000000
    .word 0x005747c9, 0x00000000
    .word 0x00163712, 0x00000000
    .word 0x002894c5, 0x00000000
    .word 0x001d883c, 0x00000000
    .word 0x007fd928, 0x00000000
    /* Inv Layer 7 - 16 */
    .word 0x00451912, 0x00000000
    .word 0x002836d1, 0x00000000
    .word 0x006c6148, 0x00000000
    .word 0x0050fc10, 0x00000000
    /* Inv Layer 6 - 16 */
    .word 0x004f4ee3, 0x00000000
    .word 0x0048e8d7, 0x00000000
    /* Inv Layer 5 - 16 */
    .word 0x00336d6d, 0x00000000
    /* Padding */
    .word 0x00000000, 0x00000000
    /* ---------------- */
    /* Inv Layer 4 */
    .word 0x0012a239, 0x00000000
    .word 0x00775e6f, 0x00000000
    .word 0x000f56b7, 0x00000000
    .word 0x00466d7e, 0x00000000
    .word 0x005f601d, 0x00000000
    .word 0x0056f251, 0x00000000
    .word 0x0049d22c, 0x00000000
    .word 0x00092e53, 0x00000000
    /* Inv Layer 3 */
    .word 0x0030d996, 0x00000000
    .word 0x002fffce, 0x00000000
    .word 0x002c008e, 0x00000000
    .word 0x0030d9d6, 0x00000000
    /* Inv Layer 2 */
    .word 0x00467a98, 0x00000000
    .word 0x00466a9a, 0x00000000
    /* Inv Layer 1 */
    .word 0x0000b662, 0x00000000
    /* ninv */
    .word 0x007f6021, 0x00000000

.global reduce32_const
reduce32_const:
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1

.global power2round_D
power2round_D:
    .word 0xd
    .word 0xd
    .word 0xd
    .word 0xd
    .word 0xd
    .word 0xd
    .word 0xd
    .word 0xd
.global power2round_D_preprocessed
power2round_D_preprocessed:
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
    .word 0xfff
.global power2round_D_preprocessed_base
power2round_D_preprocessed_base:
    .word 0xfff
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
.global eta
eta:
    .word 0x2
    .word 0x2
    .word 0x2
    .word 0x2
    .word 0x2
    .word 0x2
    .word 0x2
    .word 0x2
.global eta_vec_base_const
eta_vec_base_const:
    .word 0x2
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
.global polyt0_pack_const
polyt0_pack_const:
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
    .word 0x1000
.global polyt0_pack_base_const
polyt0_pack_base_const:
    .word 0x1000
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
.global decompose_const
decompose_const:
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
    .word 0x00002c0b
.global decompose_const_base
decompose_const_base:
    .word 0x00002c0b
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
.global gamma1_vec_const
gamma1_vec_const:
    .word 0x00020000
    .word 0x00020000
    .word 0x00020000
    .word 0x00020000
    .word 0x00020000
    .word 0x00020000
    .word 0x00020000
    .word 0x00020000
.global gamma1_vec_base_const
gamma1_vec_base_const:
    .word 0x00020000
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
.global gamma2_vec_const
gamma2_vec_const:
    .word 0x00017400
    .word 0x00017400
    .word 0x00017400
    .word 0x00017400
    .word 0x00017400
    .word 0x00017400
    .word 0x00017400
    .word 0x00017400
.global gamma2x2_vec_base_const
gamma2x2_vec_base_const:
    .word 0x0002e800
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
.global qm1half_const
qm1half_const:
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
    .word 0x003ff000
.global qm1half_base_const
qm1half_base_const:
    .word 0x003ff000
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
.global decompose_127_const
decompose_127_const:
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
    .word 0x0000007f
.global decompose_43_const
decompose_43_const:
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
    .word 0x0000002b
.global polyeta_unpack_mask
polyeta_unpack_mask:
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
    .word 0x07
.global polyt1_unpack_dilithium_mask
polyt1_unpack_dilithium_mask:
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
    .word 0x3ff
.global polyt0_unpack_dilithium_mask
polyt0_unpack_dilithium_mask:
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
    .word 0x1fff
.global polyz_unpack_dilithium_mask
polyz_unpack_dilithium_mask:
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
    .word 0x3ffff
.global polyz_unpack_base_dilithium_mask
polyz_unpack_base_dilithium_mask:
    .word 0x3ffff
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
    .word 0x0
.global poly_uniform_eta_205
poly_uniform_eta_205:
    .word 205
    .word 205
    .word 205
    .word 205
    .word 205
    .word 205
    .word 205
    .word 205
.global poly_uniform_eta_2
poly_uniform_eta_2:
    .word 2
    .word 2
    .word 2
    .word 2
    .word 2
    .word 2
    .word 2
    .word 2
.global poly_uniform_eta_5
poly_uniform_eta_5:
    .word 5
    .word 5
    .word 5
    .word 5
    .word 5
    .word 5
    .word 5
    .word 5