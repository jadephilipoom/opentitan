/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for verify_base_dilithium
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

  /* Load stack address */
  la    x2, stack_end
  /* Load parameters */
  la    x10, signature
  li    x11, 2420  /* siglen */
  la    x12, message
  la    x13, messagelen
  lw    x13, 0(x13) /* msglen */
  /* addi  x13, x0, 33   */
  la    x14, pk

  jal x1, verify_base_dilithium

  ecall

.data
.balign 32
.global stack
stack:
    .zero 40000
stack_end:
pk:
  .word 0x11e10e1c
  .word 0x3f00081b
  .word 0x8b5ee628
  .word 0x37b0de3b
  .word 0x1d228fcf
  .word 0x95f5dafc
  .word 0xd538db0e
  .word 0xef5bd806
  .word 0xdee37761
  .word 0xf51e4f0d
  .word 0x94357784
  .word 0x8ed0567b
  .word 0x44b21d84
  .word 0x29b7a24f
  .word 0x1714ebad
  .word 0x42df7aca
  .word 0x5a0c49a1
  .word 0x27007f09
  .word 0x41fcc160
  .word 0x5a32e89b
  .word 0xc59701ad
  .word 0xd380ed2c
  .word 0x77e718df
  .word 0x89b26542
  .word 0xa1ec2c91
  .word 0xd8903abe
  .word 0x5ce6fda4
  .word 0x8610c684
  .word 0xecde474e
  .word 0x44ea3eae
  .word 0x9590b930
  .word 0x118d4059
  .word 0x7ddbaba6
  .word 0xf76d33b9
  .word 0x48ab6ef9
  .word 0x9757a664
  .word 0xa55f2691
  .word 0xb78c346c
  .word 0x0ec9ddd2
  .word 0xc3953a13
  .word 0x0136b1f6
  .word 0x08549f42
  .word 0xa49a99bd
  .word 0x8101c179
  .word 0xc50e5559
  .word 0x493c115a
  .word 0xf448e63b
  .word 0x4fdd36e0
  .word 0x039e808c
  .word 0x91bb4f6b
  .word 0x4a482c8c
  .word 0x7a74e1d8
  .word 0xab8555e0
  .word 0x46df3f43
  .word 0x253cf01a
  .word 0x077073a7
  .word 0xf705aa21
  .word 0xf5e79f37
  .word 0x5d1796ed
  .word 0x6e072140
  .word 0x03b6527f
  .word 0xd4f5ef08
  .word 0x93e0a62b
  .word 0x5e81d0b3
  .word 0x466649b3
  .word 0xa93092e4
  .word 0x418d5cb3
  .word 0xb82b0c90
  .word 0xa246b4d3
  .word 0xe0f72731
  .word 0x1c5ad896
  .word 0xc8d44a79
  .word 0x4f907792
  .word 0x57ecbfc6
  .word 0x0dd8cdb1
  .word 0x305095f9
  .word 0x1a74cafd
  .word 0x27c8dafb
  .word 0x54cd3cb1
  .word 0xf48a5803
  .word 0xc2034064
  .word 0x4dfa5d26
  .word 0xcdbc9d41
  .word 0x23896420
  .word 0xe98b5186
  .word 0x49161cd5
  .word 0xeceb7582
  .word 0xa8c7cdf5
  .word 0x93c2f220
  .word 0x6f4aac14
  .word 0x2a25b208
  .word 0x99b1cfd3
  .word 0x0bfe42aa
  .word 0x9771b54f
  .word 0xd920105c
  .word 0xee94e149
  .word 0x7b93ad1e
  .word 0xb30b55fb
  .word 0x7a358eba
  .word 0xf0299c02
  .word 0x02465577
  .word 0x222fcae1
  .word 0x6991cb89
  .word 0xaf3a1c94
  .word 0xc7588edb
  .word 0x2977acf2
  .word 0x7c14b41f
  .word 0x31b0f665
  .word 0x2fa4ebd3
  .word 0x44d9cf2a
  .word 0x2bc25b8a
  .word 0xcc076e47
  .word 0x0623dace
  .word 0x9bec54c5
  .word 0xf155b67a
  .word 0x2b8c31d7
  .word 0xf6d5677e
  .word 0x60f5ed9b
  .word 0x89a9fd00
  .word 0x1babb586
  .word 0xdfd8223a
  .word 0x971668d6
  .word 0xc9553ab2
  .word 0xf310876e
  .word 0x4f048cf9
  .word 0x63605fb1
  .word 0xc056ee13
  .word 0x0fcaf5f1
  .word 0x48082e51
  .word 0x8e35cb4f
  .word 0xfa8f526e
  .word 0x66a8f889
  .word 0x0c3cffcc
  .word 0x7e141358
  .word 0x47f09ac5
  .word 0x01ad4a0c
  .word 0x104fd341
  .word 0xe1e5a21d
  .word 0xd4d052bd
  .word 0x3e3bb1c9
  .word 0x58d1873d
  .word 0x67790561
  .word 0x8c97e754
  .word 0x7d8ac6a1
  .word 0x2b11df85
  .word 0xb321b97a
  .word 0x3cf0a959
  .word 0xeaa727bd
  .word 0x809a7ac8
  .word 0x4c6bb2b0
  .word 0x85ed5796
  .word 0x61a27fad
  .word 0xeb45b36a
  .word 0x9ff62682
  .word 0x8381f4c0
  .word 0xcd4b57ff
  .word 0x76567b76
  .word 0x12db3a41
  .word 0xa05021ea
  .word 0xee8376e9
  .word 0x253c2454
  .word 0x718aeab7
  .word 0x69f80686
  .word 0xdad0d893
  .word 0xd34e83ce
  .word 0x24b7ee41
  .word 0xf05f3dfe
  .word 0x7b8a8bbc
  .word 0x26ba0481
  .word 0x3a13349d
  .word 0x0a30f84c
  .word 0x9684682d
  .word 0xcb6f9bb5
  .word 0x60e91ac6
  .word 0x8e1dea62
  .word 0x560c415b
  .word 0x4124f471
  .word 0x3293d67e
  .word 0x0083d99c
  .word 0x00d1fc1f
  .word 0x8598d523
  .word 0x5fadb79f
  .word 0x715463d2
  .word 0x90061017
  .word 0x3874cec6
  .word 0xc56c6e95
  .word 0xe55d1b7f
  .word 0x72dcb03b
  .word 0xea6d9bce
  .word 0x598957a8
  .word 0x05f0709a
  .word 0x250e1a1f
  .word 0x8b886de8
  .word 0xbd36df00
  .word 0x72ef93bc
  .word 0xce5ac417
  .word 0x0d79c011
  .word 0x3e95e970
  .word 0xa27b415b
  .word 0xaf4c9afd
  .word 0xe6fcf182
  .word 0xe2535ff4
  .word 0x5e35b815
  .word 0x1d891df6
  .word 0x2394c7f1
  .word 0xd22d161c
  .word 0x34b56441
  .word 0x6784d4a9
  .word 0x6223c3cd
  .word 0xd4952f4c
  .word 0xd6f92f40
  .word 0x1a19b16a
  .word 0x4a142481
  .word 0xe3d435fa
  .word 0xaa6cc81d
  .word 0xf6317c79
  .word 0x4c85858b
  .word 0xfac459d9
  .word 0xb353ecc5
  .word 0x4b376db5
  .word 0x979e8a88
  .word 0xb676659a
  .word 0x52c85e34
  .word 0x9906962c
  .word 0x3ebf8102
  .word 0x5d94c5f7
  .word 0xa221fd10
  .word 0x40e5d2a1
  .word 0x12f25c4c
  .word 0x91136420
  .word 0x82cf8bb9
  .word 0x5b309853
  .word 0x618be556
  .word 0x3225e51f
  .word 0x0ddfe303
  .word 0x736a4622
  .word 0xe4fbf0b3
  .word 0x92629a3b
  .word 0x8b899180
  .word 0x265b0e8a
  .word 0xb086b59d
  .word 0x50efdde4
  .word 0x2da182d6
  .word 0x24e81b2c
  .word 0x54a29a14
  .word 0xb41b38c6
  .word 0x3f7cd712
  .word 0xb602a99a
  .word 0x1517c888
  .word 0x95839ca5
  .word 0x356d5558
  .word 0x3bc84fed
  .word 0x8181b14a
  .word 0xdc730ff4
  .word 0xd86068d7
  .word 0x5294bfd8
  .word 0xacc23702
  .word 0xa03b460e
  .word 0x82973c9e
  .word 0x7fc00d38
  .word 0x34bafce4
  .word 0x3400c20c
  .word 0x1423fd39
  .word 0x07380661
  .word 0xea9e6c0d
  .word 0xe8ba700a
  .word 0x3c5d5d3b
  .word 0x26de3f5d
  .word 0x6c6001dd
  .word 0x5801528c
  .word 0x4010e5e7
  .word 0xce48f220
  .word 0x576466aa
  .word 0xf0eb0ac1
  .word 0xbda3f868
  .word 0x2cb5e75c
  .word 0xd5abf06a
  .word 0xadf14a94
  .word 0x11c95247
  .word 0x3c087639
  .word 0x4ec3b603
  .word 0x69ed471d
  .word 0x78ad4c64
  .word 0x057d2f2c
  .word 0x9648a1f8
  .word 0xa25f961d
  .word 0x8d3a72e1
  .word 0xa922bcde
  .word 0xdd83d70c
  .word 0x8fb34d1f
  .word 0x675aaeb9
  .word 0x46d9b314
  .word 0xd3431678
  .word 0x79ddb717
  .word 0x89f71c38
  .word 0xb38b58a9
  .word 0x2ab993e1
  .word 0xb0d6600b
  .word 0x697f047d
  .word 0x9e60b084
  .word 0xc34375c5
  .word 0x5e8dca94
  .word 0x732acc5b
  .word 0x8b61791a
  .word 0xdae0e2d1
  .word 0x98af0487
  .word 0x8f5f0ff2
  .word 0xf6dd5254
  .word 0x345bb946
  .word 0xd2f0d71d
  .word 0x5ba11fcc
  .word 0xd55c89d9
  .word 0xcba15ab6
  .word 0xe7e2b594
  .word 0x82a9fd88
  .word 0x3966655b
  .word 0x32983d19
  .word 0xf2a45481
  .word 0xa39554c3
  .word 0xd2a06e8b
  .word 0x5da3aaff
  .word 0x3c202cf9
  .word 0xbccb317f
  .word 0xc303bda7
  .word 0x902130c2
  .word 0x1f16cdce
  .word 0xe43792d4
  .word 0xf3e339f8


signature:
  .word 0x772059af
  .word 0x0ed20346
  .word 0xa39aa798
  .word 0xb632faab
  .word 0xe61925e2
  .word 0xc47ae373
  .word 0x85fe73ac
  .word 0x292c1e34
  .word 0x2e99c123
  .word 0x38be0b1b
  .word 0xfcc8d773
  .word 0x07f26256
  .word 0x38ea58bf
  .word 0xa0a3d41c
  .word 0xc4de62c0
  .word 0xbaf8da5b
  .word 0xef2ba50a
  .word 0x3f4fa16f
  .word 0x768ff26c
  .word 0xa994bf20
  .word 0x047dc22c
  .word 0x4da61454
  .word 0x9614c065
  .word 0x24805230
  .word 0x8739bf28
  .word 0x1675d4a2
  .word 0xaa785cca
  .word 0xe17b6bb9
  .word 0x2c5fca1b
  .word 0xfcf3265a
  .word 0x8e6ea2e3
  .word 0x8f73a209
  .word 0xd4756f38
  .word 0xef37f948
  .word 0xbd46a819
  .word 0xca49d94d
  .word 0x56db36af
  .word 0xf54a8829
  .word 0x3f3e023a
  .word 0xc0e40f18
  .word 0xe57bfffa
  .word 0x9ae8e4df
  .word 0xa69530de
  .word 0x14420056
  .word 0xc108ad61
  .word 0xa8ced629
  .word 0xc039bb51
  .word 0x51d1a7d7
  .word 0xa0895640
  .word 0xeb4dfa91
  .word 0xf53c37ac
  .word 0xf078e04a
  .word 0xbb5775af
  .word 0x536af0c6
  .word 0x9e94e85a
  .word 0x8a30650c
  .word 0x72008459
  .word 0x80955237
  .word 0xe92c0e2d
  .word 0x4298daa3
  .word 0x03ff006a
  .word 0x8c2180fe
  .word 0xfe8eec0e
  .word 0xccb91c58
  .word 0xb2667d9a
  .word 0xcda84506
  .word 0xced39004
  .word 0xea6f7e4f
  .word 0x7aebc9e9
  .word 0xd064f957
  .word 0x0bc9c7eb
  .word 0x30869f7a
  .word 0x95803e0b
  .word 0x94124de6
  .word 0xd9b4c4cf
  .word 0xfae872e2
  .word 0x7d70b58d
  .word 0x22af0470
  .word 0xfd9cffdb
  .word 0x57df6348
  .word 0x3404e03f
  .word 0x4acda31d
  .word 0x2c538230
  .word 0x5f452026
  .word 0x2b567ca3
  .word 0x4e68d5af
  .word 0xc7af28a1
  .word 0x9bfc019e
  .word 0x3b43e831
  .word 0x9f027cad
  .word 0x10cc132f
  .word 0x32232d59
  .word 0x808be0e3
  .word 0x3d4650d3
  .word 0xb15027e7
  .word 0x93f406f8
  .word 0x5fbd43e1
  .word 0x98167dca
  .word 0xbf311b08
  .word 0x1b2a6b87
  .word 0x9550dfc9
  .word 0xc1b6132d
  .word 0x11111b32
  .word 0xa6452117
  .word 0x440bae27
  .word 0x7589b927
  .word 0xd6f7ffcb
  .word 0x4b757582
  .word 0xd782b645
  .word 0x5268e109
  .word 0xa7fe842e
  .word 0xf4b03bdd
  .word 0x71ff0515
  .word 0xd1316492
  .word 0xbf4c0da9
  .word 0xd47a529a
  .word 0x6f9784e2
  .word 0xd6d98bff
  .word 0x264f4a22
  .word 0x87a99103
  .word 0xeea66dfb
  .word 0x90a4c242
  .word 0xe17c400f
  .word 0x24322ef0
  .word 0xfb13d375
  .word 0x2e8cb6eb
  .word 0x09087305
  .word 0x28748a44
  .word 0x390194a5
  .word 0x551bdfeb
  .word 0xd4c5fc56
  .word 0xf3131a2e
  .word 0x6fcb3022
  .word 0x1d832407
  .word 0xba1b070d
  .word 0x8004675a
  .word 0x745b476f
  .word 0xe3b691ba
  .word 0x2086d485
  .word 0xb10a8d95
  .word 0x4e182bbf
  .word 0x53e7f310
  .word 0xbe3713b7
  .word 0x7853b69e
  .word 0x3ab48567
  .word 0x94c4e5c7
  .word 0x04cb1bac
  .word 0x2514463d
  .word 0xac9860b3
  .word 0x015a0593
  .word 0x2385ab05
  .word 0x4a021db6
  .word 0xa4569b6e
  .word 0x72043c2d
  .word 0x4cae1265
  .word 0x047105fe
  .word 0x696fb046
  .word 0x4fee3442
  .word 0xddedfea8
  .word 0x658af2c5
  .word 0x58ebe2ed
  .word 0x36fe65e9
  .word 0xbc71a527
  .word 0xed97b345
  .word 0xbeb42a09
  .word 0x29170400
  .word 0xfe92d1c4
  .word 0x79826730
  .word 0x48a823d2
  .word 0xe96643cf
  .word 0xde683f2b
  .word 0x4a9b7ce9
  .word 0x932ff27f
  .word 0x66c5e67b
  .word 0xb21d9639
  .word 0xeccfa39f
  .word 0x1493f2ff
  .word 0xb9ff8608
  .word 0xda79bc2e
  .word 0xf8ea9cb5
  .word 0x8e4fc669
  .word 0xe95c58af
  .word 0x8fb7d67d
  .word 0xdb722789
  .word 0xcf58a988
  .word 0xa757b50a
  .word 0xe63fa8fa
  .word 0x2b7e4721
  .word 0xb57a4984
  .word 0xa7f4eca8
  .word 0xb9df32bd
  .word 0x2c5df002
  .word 0xd04710a3
  .word 0xdd9a91f1
  .word 0xfd6deee1
  .word 0xc49be558
  .word 0xbbccb3da
  .word 0xf6aa6aa3
  .word 0xb0c7ccaf
  .word 0xa194ca95
  .word 0x289abe95
  .word 0x88b52695
  .word 0x68c5a9c3
  .word 0x5d41fc76
  .word 0x2b441d52
  .word 0xd39802ac
  .word 0xd59a4102
  .word 0x9c24da27
  .word 0xd00c662a
  .word 0xfa3f2164
  .word 0x3f1863d5
  .word 0x78259737
  .word 0x0af7b9ee
  .word 0x6cee7ac6
  .word 0x281fb7c2
  .word 0x0b93953a
  .word 0x55384755
  .word 0x5ec29157
  .word 0x689e397a
  .word 0x8dd53656
  .word 0xe76bcb69
  .word 0x195cb493
  .word 0x61d5e769
  .word 0xc3eb2756
  .word 0x4445ed2e
  .word 0x0d88870f
  .word 0x4ffa2928
  .word 0x618671c8
  .word 0xed59d264
  .word 0x1873d295
  .word 0xf57f0171
  .word 0x6f069418
  .word 0x6ffa1fae
  .word 0x846f4a4b
  .word 0x09dafffc
  .word 0x17fa18e7
  .word 0x3fdb5e13
  .word 0x5b8d5548
  .word 0x6f9e7fa6
  .word 0x0b340009
  .word 0x59fe4dd0
  .word 0x7467bdb7
  .word 0x84fb8458
  .word 0xe78e3fae
  .word 0x7402d263
  .word 0xf7d45236
  .word 0x58503433
  .word 0xc7b99004
  .word 0x195b9344
  .word 0x0dfbd5c1
  .word 0x61b4fbb5
  .word 0x83621341
  .word 0x7eeb3780
  .word 0x263ff6c3
  .word 0xcce793c8
  .word 0x473f3b1c
  .word 0x00aeab67
  .word 0x99bbb7fe
  .word 0xb20b42b1
  .word 0x7414a69e
  .word 0xedd99678
  .word 0xfe0781cf
  .word 0x309c4c50
  .word 0xda64828a
  .word 0x878d31ce
  .word 0x1876e4cf
  .word 0x0da6e903
  .word 0x4a14a6ef
  .word 0x0af1c1ab
  .word 0xde40b145
  .word 0x35e754d7
  .word 0xbb67c486
  .word 0xde9ef17b
  .word 0xc6e05bf2
  .word 0xe5c5935e
  .word 0x0c888feb
  .word 0x87854ace
  .word 0x56fff857
  .word 0x67102b06
  .word 0x766f10f4
  .word 0x6e7f00b7
  .word 0x0445f9a6
  .word 0x0fbd857e
  .word 0x99269dad
  .word 0x068a674f
  .word 0xcf7cb812
  .word 0xa4f90c9c
  .word 0xc989d833
  .word 0xbe124c6e
  .word 0x00772237
  .word 0x12ad065b
  .word 0x6dd10571
  .word 0xae42b18f
  .word 0xab7353ae
  .word 0xdc9a1dd6
  .word 0xd65055fc
  .word 0x883bca23
  .word 0xe0e2b024
  .word 0xe2f42b8c
  .word 0x4cac1e84
  .word 0xf86cc55d
  .word 0x07f24c95
  .word 0x7cf263c2
  .word 0x109f309f
  .word 0x840d7c30
  .word 0x427858a6
  .word 0x5d373150
  .word 0xd7d210d8
  .word 0xa39810e5
  .word 0x79504381
  .word 0x7f074a5c
  .word 0x4fd40da4
  .word 0x0f51a70f
  .word 0x14633f7c
  .word 0xf634cf07
  .word 0x35b3c704
  .word 0xd2202a63
  .word 0xd79b41ad
  .word 0x42426dcc
  .word 0x356cc6b1
  .word 0xcceda5e5
  .word 0x7da33cb1
  .word 0x5f46503b
  .word 0xf7af4a3b
  .word 0x791e16e3
  .word 0xe08a0836
  .word 0x2cfd0184
  .word 0x2f7ad637
  .word 0x6f3e1df9
  .word 0x646d6808
  .word 0xc5c62fbc
  .word 0x9fe40671
  .word 0x22ac84a3
  .word 0xee079f21
  .word 0x3dca9689
  .word 0xc5dc59ff
  .word 0xad4b2a09
  .word 0xdeae87be
  .word 0x4ca0697f
  .word 0xdf3bb379
  .word 0xe4a0d435
  .word 0x01554bcb
  .word 0x27bfb09c
  .word 0x3bb99552
  .word 0x16a5beda
  .word 0x6a612bca
  .word 0x00869156
  .word 0x7abe24b7
  .word 0xf54eec01
  .word 0x0db31243
  .word 0x8107f566
  .word 0xff80275f
  .word 0xf8307cee
  .word 0x25925a42
  .word 0xfa50e52c
  .word 0xe702e9b4
  .word 0x6dd482b3
  .word 0xe1ef20bd
  .word 0xa4f80ebb
  .word 0x093c8796
  .word 0x30b0cec4
  .word 0xab1d7f3c
  .word 0xe92d10a0
  .word 0xacb69041
  .word 0xf710c86d
  .word 0xa23aca2b
  .word 0xbd38ff92
  .word 0xb8faa751
  .word 0xfbc49e50
  .word 0xc9a3eae0
  .word 0x676a1686
  .word 0x1571784b
  .word 0x478c345c
  .word 0xdccef87e
  .word 0xbe5a2b83
  .word 0x188d1ae7
  .word 0xf5d06dd0
  .word 0xab601122
  .word 0xe8e671eb
  .word 0x73bffa2c
  .word 0x5a51a31e
  .word 0xb207ef76
  .word 0xb3636cc1
  .word 0x3bb77a7f
  .word 0x9205f067
  .word 0x453e759a
  .word 0x0a0c933b
  .word 0x7f2732f4
  .word 0x1e8a7dd7
  .word 0xde2c02b8
  .word 0x3b766596
  .word 0x670a4f01
  .word 0x0b16042a
  .word 0x54f5060a
  .word 0x4b264c0f
  .word 0x0674227f
  .word 0x2d35a290
  .word 0x88b563c8
  .word 0x1fd53a30
  .word 0xbf62e10a
  .word 0x077f7979
  .word 0x1c5034b5
  .word 0x13b7fdbb
  .word 0x98aa24a7
  .word 0x183295e1
  .word 0xfacc8071
  .word 0x31be6edc
  .word 0xb67dfa42
  .word 0x7bded46c
  .word 0x824cbd9f
  .word 0xb66d6835
  .word 0x9a48af8c
  .word 0x871e4efa
  .word 0xfdcef0ae
  .word 0xa5e33780
  .word 0xeb62ee78
  .word 0x5bed947f
  .word 0xea8eb5c0
  .word 0xfc454c4b
  .word 0x291dd356
  .word 0x5a094d94
  .word 0x08296cc9
  .word 0x71c7a23d
  .word 0x557ad981
  .word 0x3a906efe
  .word 0xde83272f
  .word 0x475faa0b
  .word 0x5c7804d7
  .word 0xc8d5e833
  .word 0x651ed67e
  .word 0x31679145
  .word 0x95a9b70e
  .word 0x9a81ef74
  .word 0x3b1a16e9
  .word 0x803496d0
  .word 0x4e1e9e3d
  .word 0x796d38c7
  .word 0x17459846
  .word 0xcfb93a21
  .word 0x51a5ae66
  .word 0x397c45cc
  .word 0x94f26af8
  .word 0x3f077bcf
  .word 0xdad43e56
  .word 0xdf9b41b9
  .word 0x5cd04b00
  .word 0x0ee8b492
  .word 0xc9eacfc3
  .word 0x55da1d7e
  .word 0x5c62da4f
  .word 0x9b039b4b
  .word 0x2f5a7caa
  .word 0x7705976f
  .word 0xf53c4892
  .word 0xc3d452f8
  .word 0x50ad71ac
  .word 0x3d9579f7
  .word 0x3ef6e2cf
  .word 0xe1d835d2
  .word 0x6c5d34d5
  .word 0x5c55f06d
  .word 0xea1d63c2
  .word 0xbc14b7d9
  .word 0x1e50164c
  .word 0x81132601
  .word 0x159767f3
  .word 0x38235134
  .word 0x572d858c
  .word 0x1d94f1dc
  .word 0x9fd41109
  .word 0xfd4371ea
  .word 0xa543c32f
  .word 0xcc645b07
  .word 0xdc9182a4
  .word 0x763fb828
  .word 0xea894507
  .word 0x84c717b2
  .word 0x2c654078
  .word 0x78e23a0e
  .word 0x0dfbb6b3
  .word 0x7d5e0c80
  .word 0xb95c9db7
  .word 0x45871acc
  .word 0x67b7000c
  .word 0x2ed21278
  .word 0x8cde0fe2
  .word 0xfba75317
  .word 0xbb8bba93
  .word 0x39a69585
  .word 0xa94af53d
  .word 0x87e0b6cd
  .word 0x9be4269a
  .word 0x1315b0d3
  .word 0x073a05c6
  .word 0x6c59c846
  .word 0x25b2e5e5
  .word 0xab26cacf
  .word 0x1f2ff18b
  .word 0xa947a6e0
  .word 0x393045e4
  .word 0x946122a1
  .word 0x988b6ec4
  .word 0xf110d7ac
  .word 0x05ecb78f
  .word 0xd81c6c47
  .word 0xcc1231fc
  .word 0x2b58b1dd
  .word 0x8fc11788
  .word 0x3e3515e3
  .word 0x21c8477a
  .word 0x433aeee9
  .word 0x801bdeca
  .word 0xe80a2ad9
  .word 0xff4debdc
  .word 0xdf546a76
  .word 0xfefe6536
  .word 0x722b253c
  .word 0xe3b1d7da
  .word 0xa27f9e35
  .word 0xe3c36255
  .word 0xce21b59d
  .word 0x1f117418
  .word 0xd3db90b0
  .word 0xad80318b
  .word 0xb0574b03
  .word 0xd64ddc31
  .word 0x8a1a7caf
  .word 0x7ecef6f3
  .word 0x4b9e1adb
  .word 0x20594a6d
  .word 0x180862e3
  .word 0x76590682
  .word 0x24a4f72e
  .word 0x2ddf513f
  .word 0x3707908a
  .word 0x690581d5
  .word 0xcb104e9b
  .word 0x7f9c35cb
  .word 0x6907403a
  .word 0x5020487c
  .word 0x80cf33ec
  .word 0x3b6a9141
  .word 0xd9509a91
  .word 0x89f5f06e
  .word 0xf35645fd
  .word 0x42d9bd0d
  .word 0xfa9db7ea
  .word 0x307ec097
  .word 0x35747024
  .word 0x8ef91b2e
  .word 0xefc79c34
  .word 0xfcb8a1a5
  .word 0x1f8ff1e4
  .word 0xc9076faf
  .word 0x4814329c
  .word 0x8a5c39b0
  .word 0x6446bc9c
  .word 0x1a9cf812
  .word 0x1557bf98
  .word 0xf0442884
  .word 0xa46f23e8
  .word 0x58466c69
  .word 0x42e4fdb8
  .word 0x7ad6095d
  .word 0x5872ac38
  .word 0x6f96d5e5
  .word 0x6af63f2d
  .word 0x6ee70c0c
  .word 0xa1816b7f
  .word 0xfd47d0bc
  .word 0xf05b203a
  .word 0xb1a3aecc
  .word 0x9c907910
  .word 0x8f69e56c
  .word 0x40f3e132
  .word 0xa0ff5896
  .word 0x4acbae1e
  .word 0xb792b0e2
  .word 0xadda8989
  .word 0x11bb2366
  .word 0x8f0f9ff4
  .word 0x05ec9986
  .word 0xff021566
  .word 0xf43cd0ca
  .word 0x221a1915
  .word 0x7b4c3c2d
  .word 0xb9b5b08a
  .word 0xdcd9c2bb
  .word 0x2d20f7ef
  .word 0x4944423f
  .word 0x6453524f
  .word 0xc4746966
  .word 0xfaf5e6d9
  .word 0x19040100
  .word 0x5a3d3727
  .word 0xc1b88076
  .word 0x2920fec9
  .word 0x483c3b38
  .word 0x655f564d
  .word 0xa69e9d79
  .word 0xded2ada9
  .word 0xf9f7e7e5
  .word 0x00000000
  .word 0x00000000
  .word 0x48322412
.balign 32
message:
  .word 0x8d4d1cd8
  .word 0xfbcb4f73
  .word 0x3f3ddeea
  .word 0xaa9f038a
  .word 0x57992c2a
  .word 0x55ad35e8
  .word 0xbf752eb2
  .word 0x6a55bb57
  .word 0x000000c8
/* account for longer messages in the tests */
.zero 3300
messagelen:
  .word 0x00000021
.balign 32/* Modulus for reduction */
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