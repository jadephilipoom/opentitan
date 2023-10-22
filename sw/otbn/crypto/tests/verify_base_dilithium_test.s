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
    .word 0x00ca2087, 0x92e0bb09
    .word 0xb04e1826, 0x73078efd
    .word 0xf0260fa4, 0x72e78afc
    .word 0x073e5788, 0x9e33e1bc
    .word 0xe83c3f40, 0xa7e8dee7
    .word 0xe53b9f1e, 0x9fe85ed7
    .word 0x0e3fd7da, 0x9e3461dc
    .word 0x37ca4823, 0xed9ec1d5
    .word 0x47e44e84, 0x6c36b6d5
    .word 0xf5069bbd, 0x51efdb52
    .word 0xc01904c1, 0x41100b80
    .word 0x5f4cbc71, 0x7301c58b
    .word 0xa7e00ab3, 0xe14ae4f6
    .word 0x5f0c5457, 0x110765b7
    .word 0x51dec50e, 0xdab23ad9
    /* Padding */
    .word 0x00000000
    .word 0 /* Padding */
    /* Layer 5 - 1 */
    .word 0x53417fba, 0x990b69a8
    /* Layer 6 - 1 */
    .word 0x52a977b9, 0x6e09d599
    .word 0x02ecfb39, 0x613a89e0
    /* Layer 7 - 1 */
    .word 0x87efc6e2, 0x5ddf591a
    .word 0xd14d55b3, 0x2707337e
    .word 0x8fa788c3, 0xaf7e3e30
    .word 0xa318f8f9, 0x75ab47e6
    /* Layer 8 - 1 */
    .word 0x3fe51ec8, 0x000db56d
    .word 0x6818b95f, 0xc4e0c0a6
    .word 0x46c35849, 0xaec2272c
    .word 0x74a1175d, 0xd386be08
    .word 0x99e55e24, 0x5144c08d
    .word 0x448d18be, 0xc99e6205
    .word 0xb5448fba, 0xfe317460
    .word 0x932d101e, 0x54b21bdd
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 2 */
    .word 0x1f48b1ee, 0x83e25f90
    /* Layer 6 - 2 */
    .word 0x5e01198b, 0x53b76b33
    .word 0x6bd87f49, 0x9271813b
    /* Layer 7 - 2 */
    .word 0xd3a1a2c2, 0x7fca89a2
    .word 0x6a2e66c6, 0x9d8d3612
    .word 0x427c2c87, 0xa0a5ea39
    .word 0xcf935b38, 0xf7a0d044
    /* Layer 8 - 2 */
    .word 0x0827f3ed, 0x241d4d0b
    .word 0x4a5da4d5, 0x02a9fa79
    .word 0xda407068, 0x1374db0f
    .word 0x6b518d8d, 0x86dec4a3
    .word 0x94765e6f, 0x8721b75f
    .word 0x8d294337, 0xb9d9dd03
    .word 0xdb6d87ac, 0x9ba784a9
    .word 0x9e73599a, 0x8e74fa21
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 3 */
    .word 0xdf030905, 0x515bfa5b
    /* Layer 6 - 3 */
    .word 0xcd3d55bb, 0xa0f8fafc
    .word 0x9244ea16, 0x40314fd3
    /* Layer 7 - 3 */
    .word 0xd9954fa1, 0x4ca4908a
    .word 0x3b3db2f7, 0x3df4288e
    .word 0x8341b567, 0x3b300f8d
    .word 0xe17248d0, 0x8b708309
    /* Layer 8 - 3 */
    .word 0x1b839cb1, 0xff2681a2
    .word 0x38ca6628, 0x192061e6
    .word 0x1bc8bdf8, 0x1ed55f1a
    .word 0x1904f50c, 0xb50840a6
    .word 0x0f22ce96, 0xc388107d
    .word 0xceb8c294, 0x30c75d75
    .word 0xfeadb370, 0x872028fb
    .word 0xf009fa9f, 0x8d287903
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 4 */
    .word 0x6d8a71c2, 0xccd84878
    /* Layer 6 - 4 */
    .word 0xb27c47ad, 0x712c382b
    .word 0x779b43e2, 0x236e6151
    /* Layer 7 - 4 */
    .word 0x9e8ca3ec, 0x55e0ad7f
    .word 0x9f8d4011, 0xa4da6d51
    .word 0x9106025f, 0xde1b6f1f
    .word 0x03e08c1c, 0x7f04d036
    /* Layer 8 - 4 */
    .word 0xebfb40f9, 0xcc85dfde
    .word 0xa09e1444, 0x97d0e509
    .word 0x3e108ba7, 0x51d07f7c
    .word 0x61f7891f, 0x8cde507a
    .word 0x9357d0ce, 0x9386a682
    .word 0xeff5a98b, 0x136d4329
    .word 0xe8854581, 0xf8597a6d
    .word 0x92280ee0, 0xb4fe9e3d
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 5 */
    .word 0xef36edde, 0x9456626f
    /* Layer 6 - 5 */
    .word 0x8a0d8e50, 0x0c0a4a7a
    .word 0xa305ba29, 0x1c5ef183
    /* Layer 7 - 5 */
    .word 0x683bf22d, 0x2eadaf0e
    .word 0xe1f5879e, 0x0ebe617a
    .word 0x419cd6b3, 0x231839c8
    .word 0x52f1f9d9, 0xa582b161
    /* Layer 8 - 5 */
    .word 0x0a74cf1f, 0x8157a6e7
    .word 0x08c44901, 0xc9da1ef4
    .word 0xb587e48f, 0x42fd12be
    .word 0x7d7f94eb, 0xcb3defe5
    .word 0x69000d32, 0x48eead19
    .word 0x99e6f089, 0x91ab9fc4
    .word 0x3506cf4a, 0xf7cca339
    .word 0x0633d4e9, 0x9ed866dc
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 6 */
    .word 0xddccb372, 0xf2bd155f
    /* Layer 6 - 6 */
    .word 0x6d307744, 0x2176b56a
    .word 0xa8669c57, 0x94e3a1be
    /* Layer 7 - 6 */
    .word 0xa5589cdd, 0xeeb8e85c
    .word 0x8f2c61fb, 0x052efbb4
    .word 0xf371b687, 0x4b38a592
    .word 0xb45527e2, 0x9a24abf6
    /* Layer 8 - 6 */
    .word 0x56d37e32, 0x7278011b
    .word 0x5237bf4c, 0x4623ce67
    .word 0xb0e0acca, 0x25e045c5
    .word 0x26a48ad6, 0x8abe928f
    .word 0x7be12f55, 0x619e9ee4
    .word 0x261c8ed8, 0x50bc767c
    .word 0x4bf39e50, 0x264fefaf
    .word 0x30c0bbce, 0xff9ee5ba
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 7 */
    .word 0x5006d115, 0x14ab0698
    /* Layer 6 - 7 */
    .word 0x6c2307ea, 0x3f49fc00
    .word 0xf6d24ea7, 0x853af5b2
    /* Layer 7 - 7 */
    .word 0xeb7fe423, 0x80b9fd7d
    .word 0xda78c47d, 0x95705eec
    .word 0xff4c4914, 0x3cb8f9c4
    .word 0xd809f0cd, 0x9e551608
    /* Layer 8 - 7 */
    .word 0x8ced6c42, 0x5b967ae7
    .word 0x26330876, 0x04552b42
    .word 0x508542b0, 0xfd45a76f
    .word 0x939c07db, 0x4cc4246f
    .word 0xa48a3545, 0xd69c8f76
    .word 0x3918c3bf, 0x12bb9ac1
    .word 0x3a251ed4, 0xd7f994b5
    .word 0xdfe54592, 0xbc3b4959
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 8 */
    .word 0xbf96dc38, 0xd730cc84
    /* Layer 6 - 8 */
    .word 0x47bf273b, 0x6308a964
    .word 0xef869bc8, 0x41dc9aa2
    /* Layer 7 - 8 */
    .word 0xf454cf4c, 0x350a3422
    .word 0x2935f52b, 0x0730ea2c
    .word 0x3898ebca, 0x9cb75a9d
    .word 0xd44dd7ce, 0x6389939d
    /* Layer 8 - 8 */
    .word 0xd7474e25, 0xf1fc9741
    .word 0x25cba89f, 0xc549bee5
    .word 0x9aa32595, 0x7b6ae1c1
    .word 0xd44f7234, 0x95eff2d0
    .word 0xf2385632, 0x3e4a621b
    .word 0x28179395, 0xc6931939
    .word 0x64fe44c8, 0xe6fd2d7d
    .word 0xc40bdf70, 0xbd703291
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 9 */
    .word 0xbf4b7f62, 0x9d659229
    /* Layer 6 - 9 */
    .word 0xcc178048, 0x68524dc2
    .word 0xcdc91ead, 0x35be5529
    /* Layer 7 - 9 */
    .word 0x99de4a5f, 0xb135e416
    .word 0x0817e5ea, 0x369df510
    .word 0x0f8c10e6, 0xb6f55be9
    .word 0x5ea2b7f1, 0xbb1fba78
    /* Layer 8 - 9 */
    .word 0xd8e8e087, 0xce6926ac
    .word 0x3a8fd581, 0x404f9f67
    .word 0xb2377e7c, 0xb777da87
    .word 0xd600da8b, 0xc1df5a52
    .word 0x2dd37e84, 0x11e87bfb
    .word 0x17bdbd40, 0xdbf74419
    .word 0x444ce2b1, 0x1020e218
    .word 0x680ba018, 0xac322731
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 10 */
    .word 0x8a185502, 0x345e0518
    /* Layer 6 - 10 */
    .word 0x6b1700eb, 0xe706c1e2
    .word 0x8b41834b, 0x92cf30a6
    /* Layer 7 - 10 */
    .word 0x015a5693, 0x6a5f5300
    .word 0xde651589, 0x80390941
    .word 0x1ba17025, 0xd849b2bc
    .word 0x78ecee4a, 0xb7d858a6
    /* Layer 8 - 10 */
    .word 0xef6e43b3, 0xd2e1c6cb
    .word 0xa97e784c, 0x3ce9b5f3
    .word 0xccf32d32, 0x4c1a8007
    .word 0xc7949396, 0xd5714ea8
    .word 0xb10e7a3d, 0x0f840ee4
    .word 0x8e3bb3d1, 0xdbb693ed
    .word 0x1226396b, 0xe9dbef28
    .word 0x8c9f66c1, 0xc7f5c1e0
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 11 */
    .word 0xd53f3e26, 0x4af67b08
    /* Layer 6 - 11 */
    .word 0x6b2345fc, 0x72c29bc1
    .word 0xbe9bd579, 0xc4ddc9e8
    /* Layer 7 - 11 */
    .word 0x8e3b23ad, 0xd7bf9435
    .word 0xffbceb3c, 0x4b306181
    .word 0x327f2f67, 0x5cbdc6b8
    .word 0x9cbaaf73, 0x12f9963f
    /* Layer 8 - 11 */
    .word 0xc27d4fcf, 0xa353b9a7
    .word 0x4a4da8d6, 0xf5a98275
    .word 0x4afa2bf6, 0x50e3ac49
    .word 0xfaf7dc02, 0x5bf0a370
    .word 0x3bca2211, 0xb02f2268
    .word 0x66eae9ed, 0x7eb99768
    .word 0x05aae0ad, 0x16e5cb45
    .word 0xdb1e15d0, 0x851d8c58
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 12 */
    .word 0x9be028d3, 0x2c9f0367
    /* Layer 6 - 12 */
    .word 0xcf1c7f82, 0xcb8ceba3
    .word 0x710357f4, 0x87560c74
    /* Layer 7 - 12 */
    .word 0x48fd16b4, 0x772e0a94
    .word 0xf98e2196, 0xda875820
    .word 0x17370f96, 0x5960475f
    .word 0xd7c601d1, 0x671317f7
    /* Layer 8 - 12 */
    .word 0x9ec12d0e, 0x7998d341
    .word 0x04f97654, 0x4e7a03e4
    .word 0x316067b8, 0xcea655f8
    .word 0x5c11e5c2, 0x34a3e28f
    .word 0x18bf79ad, 0x32df035b
    .word 0x327bd290, 0x3df38866
    .word 0x8f269888, 0x238b7e98
    .word 0xc90abd1e, 0x9913d3c2
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 13 */
    .word 0x35add50a, 0xec5e8fcb
    /* Layer 6 - 13 */
    .word 0x18cd8330, 0xa77e9c58
    .word 0x103b42b1, 0x6184a466
    /* Layer 7 - 13 */
    .word 0x05ca4a88, 0x296f9b94
    .word 0x9374ee15, 0xab3537f7
    .word 0x6085a4a9, 0x51f7893e
    .word 0xc771c8e4, 0xab1d8009
    /* Layer 8 - 13 */
    .word 0xa32b438b, 0x7a06dec3
    .word 0x6ba55a80, 0xffa31ac7
    .word 0x761fb101, 0xd6225eeb
    .word 0x083d8f54, 0x5c43e240
    .word 0x439ad42e, 0x66bf5b09
    .word 0xe2307459, 0x0690640b
    .word 0x3478ebd3, 0x10a8ea19
    .word 0x0e6bb6d1, 0xe8770bf2
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 14 */
    .word 0xff681e09, 0x927c0bdd
    /* Layer 6 - 14 */
    .word 0x1d263554, 0x1102b08a
    .word 0x768e48a6, 0x763a67ad
    /* Layer 7 - 14 */
    .word 0xb666c044, 0x9612636c
    .word 0xfa946525, 0x46a6b51f
    .word 0x283015b6, 0xec0b4cfb
    .word 0x28f96207, 0xf1f9486e
    /* Layer 8 - 14 */
    .word 0xf2f747ed, 0x5edde2ba
    .word 0x34a6c94a, 0xde4bb330
    .word 0xc8eb9754, 0x0f85c351
    .word 0x3a5b6665, 0xef15d998
    .word 0xcd107483, 0x1a467167
    .word 0xde43f742, 0x68ca79cc
    .word 0xf809b67e, 0x0448ba25
    .word 0x8ae26f87, 0xd1bf2024
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 15 */
    .word 0x7a82a1b4, 0x5602adff
    /* Layer 6 - 15 */
    .word 0x7728311e, 0x591dfacc
    .word 0xb1e4d9d3, 0x38a103cf
    /* Layer 7 - 15 */
    .word 0x27461b39, 0x0aa7c1db
    .word 0xcf95a5cb, 0xf5fc2f1f
    .word 0xe72c5347, 0x1ee3e6bb
    .word 0xd405059a, 0xb815b7fd
    /* Layer 8 - 15 */
    .word 0xa63856ca, 0xbd40589b
    .word 0xbbb24b1c, 0x5f6c3e50
    .word 0xf324833b, 0x480acc22
    .word 0xba289cb3, 0xbd01c2f6
    .word 0x059a8c98, 0xa3ead36d
    .word 0xe2289461, 0xcb8e47fa
    .word 0x3144a4c7, 0x596223d6
    .word 0x93b03ee9, 0xf400fa56
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 16 */
    .word 0x088dad5b, 0x45c31a3b
    /* Layer 6 - 16 */
    .word 0x3f4a7a20, 0x6635e2ac
    .word 0xaa88fceb, 0x38c510d2
    /* Layer 7 - 16 */
    .word 0xa3c63647, 0x8b59d15d
    .word 0x89719553, 0xc547b863
    .word 0x9124f81c, 0xbbac7fa8
    .word 0x754d0457, 0x354a4827
    /* Layer 8 - 16 */
    .word 0xef10643b, 0xf6be75af
    .word 0x77bc4623, 0x6bdeb0d4
    .word 0xfe863d93, 0x8696fcb1
    .word 0xd663572a, 0x8cb8e920
    .word 0x7849a579, 0x3a0aaa36
    .word 0x2ac7818b, 0xe81da198
    .word 0xe626f5f2, 0x20362949
    .word 0x3c62b435, 0xe9a81632
    /* Padding */
    .word 0x00000000, 0x00000000
.global twiddles_inv
twiddles_inv:
    /* Inv Layer 8 - 1 */
    .word 0xc39d4bcc, 0x1657e9cd
    .word 0x19d90a0f, 0xdfc9d6b6
    .word 0xd5387e76, 0x17e25e67
    .word 0x87b65a88, 0xc5f555c9
    .word 0x299ca8d7, 0x734716df
    .word 0x0179c26e, 0x7969034e
    .word 0x8843b9de, 0x94214f2b
    .word 0x10ef9bc6, 0x09418a50
    /* Inv Layer 7 - 1 */
    .word 0x8ab2fbaa, 0xcab5b7d8
    .word 0x6edb07e5, 0x44538057
    .word 0x768e6aae, 0x3ab8479c
    .word 0x5c39c9ba, 0x74a62ea2
    /* Inv Layer 6 - 1 */
    .word 0x55770316, 0xc73aef2d
    .word 0xc0b585e1, 0x99ca1d53
    /* Inv Layer 5 - 1 */
    .word 0xf77252a6, 0xba3ce5c4
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 2 */
    .word 0x6c4fc118, 0x0bff05a9
    .word 0xcebb5b3a, 0xa69ddc29
    .word 0x1dd76ba0, 0x3471b805
    .word 0xfa657369, 0x5c152c92
    .word 0x45d7634e, 0x42fe3d09
    .word 0x0cdb7cc6, 0xb7f533dd
    .word 0x444db4e5, 0xa093c1af
    .word 0x59c7a937, 0x42bfa764
    /* Inv Layer 7 - 2 */
    .word 0x2bfafa67, 0x47ea4802
    .word 0x18d3acba, 0xe11c1944
    .word 0x306a5a36, 0x0a03d0e0
    .word 0xd8b9e4c8, 0xf5583e24
    /* Inv Layer 6 - 2 */
    .word 0x4e1b262e, 0xc75efc30
    .word 0x88d7cee3, 0xa6e20533
    /* Inv Layer 5 - 2 */
    .word 0x857d5e4d, 0xa9fd5200
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 3 */
    .word 0x751d907a, 0x2e40dfdb
    .word 0x07f64983, 0xfbb745da
    .word 0x21bc08bf, 0x97358633
    .word 0x32ef8b7e, 0xe5b98e98
    .word 0xc5a4999c, 0x10ea2667
    .word 0x371468ad, 0xf07a3cae
    .word 0xcb5936b7, 0x21b44ccf
    .word 0x0d08b814, 0xa1221d45
    /* Inv Layer 7 - 3 */
    .word 0xd7069dfa, 0x0e06b791
    .word 0xd7cfea4b, 0x13f4b304
    .word 0x056b9adc, 0xb9594ae0
    .word 0x49993fbd, 0x69ed9c93
    /* Inv Layer 6 - 3 */
    .word 0x8971b75b, 0x89c59852
    .word 0xe2d9caad, 0xeefd4f75
    /* Inv Layer 5 - 3 */
    .word 0x0097e1f8, 0x6d83f422
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 4 */
    .word 0xf1944930, 0x1788f40d
    .word 0xcb87142e, 0xef5715e6
    .word 0x1dcf8ba8, 0xf96f9bf4
    .word 0xbc652bd3, 0x9940a4f6
    .word 0xf7c270ad, 0xa3bc1dbf
    .word 0x89e04f00, 0x29dda114
    .word 0x945aa581, 0x005ce538
    .word 0x5cd4bc76, 0x85f9213c
    /* Inv Layer 7 - 4 */
    .word 0x388e371d, 0x54e27ff6
    .word 0x9f7a5b58, 0xae0876c1
    .word 0x6c8b11ec, 0x54cac808
    .word 0xfa35b579, 0xd690646b
    /* Inv Layer 6 - 4 */
    .word 0xefc4bd50, 0x9e7b5b99
    .word 0xe7327cd1, 0x588163a7
    /* Inv Layer 5 - 4 */
    .word 0xca522af7, 0x13a17034
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 5 */
    .word 0x36f542e3, 0x66ec2c3d
    .word 0x70d96779, 0xdc748167
    .word 0xcd842d71, 0xc20c7799
    .word 0xe7408654, 0xcd20fca4
    .word 0xa3ee1a3f, 0xcb5c1d70
    .word 0xce9f9849, 0x3159aa07
    .word 0xfb0689ad, 0xb185fc1b
    .word 0x613ed2f3, 0x86672cbe
    /* Inv Layer 7 - 5 */
    .word 0x2839fe30, 0x98ece808
    .word 0xe8c8f06b, 0xa69fb8a0
    .word 0x0671de6b, 0x2578a7df
    .word 0xb702e94d, 0x88d1f56b
    /* Inv Layer 6 - 5 */
    .word 0x8efca80d, 0x78a9f38b
    .word 0x30e3807f, 0x3473145c
    /* Inv Layer 5 - 5 */
    .word 0x641fd72e, 0xd360fc98
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 6 */
    .word 0x24e1ea31, 0x7ae273a7
    .word 0xfa551f54, 0xe91a34ba
    .word 0x99151614, 0x81466897
    .word 0xc435ddf0, 0x4fd0dd97
    .word 0x050823ff, 0xa40f5c8f
    .word 0xb505d40b, 0xaf1c53b6
    .word 0xb5b2572b, 0x0a567d8a
    .word 0x3d82b032, 0x5cac4658
    /* Inv Layer 7 - 6 */
    .word 0x6345508e, 0xed0669c0
    .word 0xcd80d09a, 0xa3423947
    .word 0x004314c5, 0xb4cf9e7e
    .word 0x71c4dc54, 0x28406bca
    /* Inv Layer 6 - 6 */
    .word 0x41642a88, 0x3b223617
    .word 0x94dcba05, 0x8d3d643e
    /* Inv Layer 5 - 6 */
    .word 0x2ac0c1db, 0xb50984f7
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 7 */
    .word 0x73609940, 0x380a3e1f
    .word 0xedd9c696, 0x162410d7
    .word 0x71c44c30, 0x24496c12
    .word 0x4ef185c4, 0xf07bf11b
    .word 0x386b6c6b, 0x2a8eb157
    .word 0x330cd2cf, 0xb3e57ff8
    .word 0x568187b5, 0xc3164a0c
    .word 0x1091bc4e, 0x2d1e3934
    /* Inv Layer 7 - 7 */
    .word 0x871311b7, 0x4827a759
    .word 0xe45e8fdc, 0x27b64d43
    .word 0x219aea78, 0x7fc6f6be
    .word 0xfea5a96e, 0x95a0acff
    /* Inv Layer 6 - 7 */
    .word 0x74be7cb6, 0x6d30cf59
    .word 0x94e8ff16, 0x18f93e1d
    /* Inv Layer 5 - 7 */
    .word 0x75e7aaff, 0xcba1fae7
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 8 */
    .word 0x97f45fe9, 0x53cdd8ce
    .word 0xbbb31d50, 0xefdf1de7
    .word 0xe84242c1, 0x2408bbe6
    .word 0xd22c817d, 0xee178404
    .word 0x29ff2576, 0x3e20a5ad
    .word 0x4dc88185, 0x48882578
    .word 0xc5702a80, 0xbfb06098
    .word 0x27171f7a, 0x3196d953
    /* Inv Layer 7 - 8 */
    .word 0xa15d4810, 0x44e04587
    .word 0xf073ef1b, 0x490aa416
    .word 0xf7e81a17, 0xc9620aef
    .word 0x6621b5a2, 0x4eca1be9
    /* Inv Layer 6 - 8 */
    .word 0x3236e154, 0xca41aad6
    .word 0x33e87fb9, 0x97adb23d
    /* Inv Layer 5 - 8 */
    .word 0x40b4809f, 0x629a6dd6
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 9 */
    .word 0x3bf42091, 0x428fcd6e
    .word 0x9b01bb39, 0x1902d282
    .word 0xd7e86c6c, 0x396ce6c6
    .word 0x0dc7a9cf, 0xc1b59de4
    .word 0x2bb08dcd, 0x6a100d2f
    .word 0x655cda6c, 0x84951e3e
    .word 0xda345762, 0x3ab6411a
    .word 0x28b8b1dc, 0x0e0368be
    /* Inv Layer 7 - 9 */
    .word 0x2bb22833, 0x9c766c62
    .word 0xc7671437, 0x6348a562
    .word 0xd6ca0ad6, 0xf8cf15d3
    .word 0x0bab30b5, 0xcaf5cbdd
    /* Inv Layer 6 - 9 */
    .word 0x10796439, 0xbe23655d
    .word 0xb840d8c6, 0x9cf7569b
    /* Inv Layer 5 - 9 */
    .word 0x406923c9, 0x28cf337b
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 10 */
    .word 0x201aba6f, 0x43c4b6a6
    .word 0xc5dae12d, 0x28066b4a
    .word 0xc6e73c42, 0xed44653e
    .word 0x5b75cabc, 0x29637089
    .word 0x6c63f826, 0xb33bdb90
    .word 0xaf7abd51, 0x02ba5890
    .word 0xd9ccf78b, 0xfbaad4bd
    .word 0x731293bf, 0xa4698518
    /* Inv Layer 7 - 10 */
    .word 0x27f60f34, 0x61aae9f7
    .word 0x00b3b6ed, 0xc347063b
    .word 0x25873b84, 0x6a8fa113
    .word 0x14801bde, 0x7f460282
    /* Inv Layer 6 - 10 */
    .word 0x092db15a, 0x7ac50a4d
    .word 0x93dcf817, 0xc0b603ff
    /* Inv Layer 5 - 10 */
    .word 0xaff92eec, 0xeb54f967
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 11 */
    .word 0xcf3f4433, 0x00611a45
    .word 0xb40c61b1, 0xd9b01050
    .word 0xd9e37129, 0xaf438983
    .word 0x841ed0ac, 0x9e61611b
    .word 0xd95b752b, 0x75416d70
    .word 0x4f1f5337, 0xda1fba3a
    .word 0xadc840b5, 0xb9dc3198
    .word 0xa92c81cf, 0x8d87fee4
    /* Inv Layer 7 - 11 */
    .word 0x4baad81f, 0x65db5409
    .word 0x0c8e497a, 0xb4c75a6d
    .word 0x70d39e06, 0xfad1044b
    .word 0x5aa76324, 0x114717a3
    /* Inv Layer 6 - 11 */
    .word 0x579963aa, 0x6b1c5e41
    .word 0x92cf88bd, 0xde894a95
    /* Inv Layer 5 - 11 */
    .word 0x22334c8f, 0x0d42eaa0
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 12 */
    .word 0xf9cc2b18, 0x61279923
    .word 0xcaf930b7, 0x08335cc6
    .word 0x66190f78, 0x6e54603b
    .word 0x96fff2cf, 0xb71152e6
    .word 0x82806b16, 0x34c2101a
    .word 0x4a781b72, 0xbd02ed41
    .word 0xf73bb700, 0x3625e10b
    .word 0xf58b30e2, 0x7ea85918
    /* Inv Layer 7 - 12 */
    .word 0xad0e0628, 0x5a7d4e9e
    .word 0xbe63294e, 0xdce7c637
    .word 0x1e0a7863, 0xf1419e85
    .word 0x97c40dd4, 0xd15250f1
    /* Inv Layer 6 - 12 */
    .word 0x5cfa45d8, 0xe3a10e7c
    .word 0x75f271b1, 0xf3f5b585
    /* Inv Layer 5 - 12 */
    .word 0x10c91223, 0x6ba99d90
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 13 */
    .word 0x6dd7f121, 0x4b0161c2
    .word 0x177aba80, 0x07a68592
    .word 0x100a5676, 0xec92bcd6
    .word 0x6ca82f33, 0x6c79597d
    .word 0x9e0876e2, 0x7321af85
    .word 0xc1ef745a, 0xae2f8083
    .word 0x5f61ebbd, 0x682f1af6
    .word 0x1404bf08, 0x337a2021
    /* Inv Layer 7 - 13 */
    .word 0xfc1f73e5, 0x80fb2fc9
    .word 0x6ef9fda2, 0x21e490e0
    .word 0x6072bff0, 0x5b2592ae
    .word 0x61735c15, 0xaa1f5280
    /* Inv Layer 6 - 13 */
    .word 0x8864bc1f, 0xdc919eae
    .word 0x4d83b854, 0x8ed3c7d4
    /* Inv Layer 5 - 13 */
    .word 0x92758e3f, 0x3327b787
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 14 */
    .word 0x0ff60562, 0x72d786fc
    .word 0x01524c91, 0x78dfd704
    .word 0x31473d6d, 0xcf38a28a
    .word 0xf0dd316b, 0x3c77ef82
    .word 0xe6fb0af5, 0x4af7bf59
    .word 0xe4374209, 0xe12aa0e5
    .word 0xc73599d9, 0xe6df9e19
    .word 0xe47c6350, 0x00d97e5d
    /* Inv Layer 7 - 14 */
    .word 0x1e8db731, 0x748f7cf6
    .word 0x7cbe4a9a, 0xc4cff072
    .word 0xc4c24d0a, 0xc20bd771
    .word 0x266ab060, 0xb35b6f75
    /* Inv Layer 6 - 14 */
    .word 0x6dbb15eb, 0xbfceb02c
    .word 0x32c2aa46, 0x5f070503
    /* Inv Layer 5 - 14 */
    .word 0x20fcf6fc, 0xaea405a4
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 15 */
    .word 0x618ca667, 0x718b05de
    .word 0x24927855, 0x64587b56
    .word 0x72d6bcca, 0x462622fc
    .word 0x6b89a192, 0x78de48a0
    .word 0x94ae7274, 0x79213b5c
    .word 0x25bf8f99, 0xec8b24f0
    .word 0xb5a25b2c, 0xfd560586
    .word 0xf7d80c14, 0xdbe2b2f4
    /* Inv Layer 7 - 15 */
    .word 0x306ca4c9, 0x085f2fbb
    .word 0xbd83d37a, 0x5f5a15c6
    .word 0x95d1993b, 0x6272c9ed
    .word 0x2c5e5d3f, 0x8035765d
    /* Inv Layer 6 - 15 */
    .word 0x942780b8, 0x6d8e7ec4
    .word 0xa1fee676, 0xac4894cc
    /* Inv Layer 5 - 15 */
    .word 0xe0b74e13, 0x7c1da06f
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 16 */
    .word 0x6cd2efe3, 0xab4de422
    .word 0x4abb7047, 0x01ce8b9f
    .word 0xbb72e743, 0x36619dfa
    .word 0x661aa1dd, 0xaebb3f72
    .word 0x8b5ee8a4, 0x2c7941f7
    .word 0xb93ca7b8, 0x513dd8d3
    .word 0x97e746a2, 0x3b1f3f59
    .word 0xc01ae139, 0xfff24a92
    /* Inv Layer 7 - 16 */
    .word 0x5ce70708, 0x8a54b819
    .word 0x7058773e, 0x5081c1cf
    .word 0x2eb2aa4e, 0xd8f8cc81
    .word 0x7810391f, 0xa220a6e5
    /* Inv Layer 6 - 16 */
    .word 0xfd1304c8, 0x9ec5761f
    .word 0xad568848, 0x91f62a66
    /* Inv Layer 5 - 16 */
    .word 0xacbe8047, 0x66f49657
    /* Padding */
    .word 0x00000000, 0x00000000
    /* ---------------- */
    /* Inv Layer 4 */
    .word 0xae213af3, 0x254dc526
    .word 0xa0f3abaa, 0xeef89a48
    .word 0x581ff54e, 0x1eb51b09
    .word 0xa0b34390, 0x8cfe3a74
    .word 0x3fe6fb40, 0xbeeff47f
    .word 0x0af96444, 0xae1024ad
    .word 0xb81bb17d, 0x93c9492a
    .word 0xc835b7de, 0x12613e2a
    /* Inv Layer 3 */
    .word 0xf1c02827, 0x61cb9e23
    .word 0x1ac460e3, 0x6017a128
    .word 0x17c3c0c1, 0x58172118
    .word 0xf8c1a879, 0x61cc1e43
    /* Inv Layer 2 */
    .word 0x0fd9f05d, 0x8d187503
    .word 0x4fb1e7db, 0x8cf87102
    /* Inv Layer 1 (Including ninv and plant for conversion to normal domain) */
    .word 0x78196f6c, 0x868d624b
    /* ninv * plant**2 * qprime */
    .word 0x0ccf51bb, 0xfeb7b9f1

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