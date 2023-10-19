/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for verify_dilithium
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
  la x2, stack_end
  /* Load parameters */
  la x10, signature
  la x11, message
  la x12, messagelen
  lw x12, 0(x12) /* msglen */
  la x13, sk

  jal x1, sign_base_dilithium

  ecall

.data
.balign 32
.global stack
stack:
    .zero 52800
stack_end:
sk:
  .word 0x11e10e1c
  .word 0x3f00081b
  .word 0x8b5ee628
  .word 0x37b0de3b
  .word 0x1d228fcf
  .word 0x95f5dafc
  .word 0xd538db0e
  .word 0xef5bd806
  .word 0x95164d39
  .word 0x40ff9d05
  .word 0x5d6c25ae
  .word 0xb6bfda5e
  .word 0xf3405f9f
  .word 0x508f587a
  .word 0x08a42c53
  .word 0xb18a16a8
  .word 0x11add087
  .word 0x93102152
  .word 0x2cbf9414
  .word 0x9736aeae
  .word 0x58bc1197
  .word 0x8cf0325b
  .word 0x376f4978
  .word 0x534d609d
  .word 0x1a71a6c0
  .word 0x31116c96
  .word 0x21a8d92a
  .word 0x426508d8
  .word 0xb4a400a6
  .word 0x7240192c
  .word 0x81624202
  .word 0x430a2106
  .word 0x70312385
  .word 0x8b100893
  .word 0x24028c18
  .word 0x84b2c192
  .word 0x8b21c412
  .word 0xc8812104
  .word 0x05480261
  .word 0xc001929c
  .word 0x32198834
  .word 0x4620586c
  .word 0xa2681889
  .word 0x34828dc2
  .word 0x42091c6a
  .word 0xe38ca200
  .word 0x111c49a6
  .word 0x1248c22c
  .word 0x912190e0
  .word 0xc0625098
  .word 0x51246284
  .word 0x642c06ca
  .word 0xb31b0e24
  .word 0x85962431
  .word 0xdb06464b
  .word 0x82c36826
  .word 0x46104468
  .word 0x1421b6c9
  .word 0x45148104
  .word 0x08422450
  .word 0x0b712244
  .word 0xa09a4592
  .word 0x70911a81
  .word 0x0310249c
  .word 0xc5047095
  .word 0x9226c804
  .word 0xc00092d2
  .word 0xa2c060b2
  .word 0x0a190968
  .word 0x180e30a2
  .word 0x00e06989
  .word 0x6248d88d
  .word 0x207114da
  .word 0x07190518
  .word 0x40120444
  .word 0x1140129b
  .word 0x42d11080
  .word 0x50289981
  .word 0x0291108b
  .word 0x20a06424
  .word 0x2146126d
  .word 0x1b8c831c
  .word 0x06016947
  .word 0x2406cc90
  .word 0x20698481
  .word 0x12242c98
  .word 0x50b12105
  .word 0x98023641
  .word 0xa6d16e44
  .word 0x6a051131
  .word 0xca40a8d3
  .word 0xb0624ca8
  .word 0x4a130300
  .word 0x14463453
  .word 0xc5044019
  .word 0x6906e34c
  .word 0x6189b05a
  .word 0x10cb8e16
  .word 0x8e168b80
  .word 0x0b6490d9
  .word 0x83246094
  .word 0x04b31a85
  .word 0x51222654
  .word 0x421c25b8
  .word 0x48810b4a
  .word 0x5a44c442
  .word 0x80232010
  .word 0x25b70984
  .word 0x1448c64c
  .word 0x38194d85
  .word 0x5116600e
  .word 0x0a6a32d8
  .word 0xc1088991
  .word 0x4d96e070
  .word 0x018c4618
  .word 0xc4918d32
  .word 0x61004a05
  .word 0xa2680823
  .word 0xa8104210
  .word 0x21061361
  .word 0x628e248a
  .word 0xb2c98906
  .word 0x84270845
  .word 0x980d2051
  .word 0x42dc6604
  .word 0x85244405
  .word 0x22282624
  .word 0x16206121
  .word 0x2ca60b09
  .word 0xe044110a
  .word 0x48588192
  .word 0x1022420d
  .word 0x8b0906a0
  .word 0x28816e24
  .word 0x8024c08c
  .word 0x848d3090
  .word 0xa64c4036
  .word 0x24045084
  .word 0xa28db694
  .word 0xb3186d92
  .word 0x8500a044
  .word 0x1405b8e3
  .word 0xc2a40405
  .word 0x81228490
  .word 0x0b2d26c3
  .word 0x90cc6620
  .word 0x28389831
  .word 0xc16c1610
  .word 0x10c04534
  .word 0x88c62422
  .word 0xd8324603
  .word 0x201c9040
  .word 0x28150468
  .word 0x4481189a
  .word 0x209c8d98
  .word 0x2c309c6e
  .word 0x6120b8c1
  .word 0x03082142
  .word 0x8cc2a010
  .word 0x53851258
  .word 0x30034c20
  .word 0x8da44c81
  .word 0x518dc044
  .word 0xa71c4c40
  .word 0x6508442c
  .word 0xda4038a0
  .word 0x06818020
  .word 0x0d268c85
  .word 0x9c8ca8e2
  .word 0x42591144
  .word 0x0426c428
  .word 0xa1261444
  .word 0xc0086442
  .word 0x86011185
  .word 0x9931489b
  .word 0x46800cb2
  .word 0x8ca85944
  .word 0x98084200
  .word 0xb50a9082
  .word 0x48246245
  .word 0x44059612
  .word 0xc8004612
  .word 0x61a01388
  .word 0x0a4d28e1
  .word 0x964b91b9
  .word 0x44b89920
  .word 0x984e3100
  .word 0xb6008512
  .word 0x0da08301
  .word 0x180e1514
  .word 0x01191081
  .word 0x68064a22
  .word 0xe18d491a
  .word 0xc61184a2
  .word 0x25262131
  .word 0x036da091
  .word 0xb6a12405
  .word 0x72449408
  .word 0x5b123443
  .word 0xb64120b4
  .word 0x8d88d050
  .word 0x1c4d070b
  .word 0x204c6494
  .word 0x08888b8e
  .word 0x440930e0
  .word 0x86490520
  .word 0x4e13034d
  .word 0x0984c919
  .word 0x431a6137
  .word 0x90804a68
  .word 0x1c310402
  .word 0x40184217
  .word 0x8e30c880
  .word 0xc341a2e1
  .word 0x28a30434
  .word 0x71245122
  .word 0xf4fed688
  .word 0x18ca1267
  .word 0x29ab7228
  .word 0xff8a6719
  .word 0x43e7949d
  .word 0x9ea363e0
  .word 0xf7ca350c
  .word 0xda2e7f2a
  .word 0x5858e628
  .word 0x845d0d52
  .word 0x7c74de67
  .word 0x3b6540f3
  .word 0xf568c252
  .word 0xadf51354
  .word 0x01497ddc
  .word 0xdd3ec31e
  .word 0xa8237453
  .word 0x93868842
  .word 0x78a0ae37
  .word 0x6942121a
  .word 0x72511407
  .word 0x8fbbb32d
  .word 0x55b1e52c
  .word 0xafd2832f
  .word 0x1356f207
  .word 0x4e9f8a91
  .word 0x6057126f
  .word 0x89e58838
  .word 0xf9a58c30
  .word 0x3d14075f
  .word 0x17aeba23
  .word 0xb6360b52
  .word 0xaf4fe9e0
  .word 0x21eb4568
  .word 0x83c3ae31
  .word 0x64c83be6
  .word 0xacf1e54e
  .word 0x922fa8cb
  .word 0xfc7ae511
  .word 0x119c50bf
  .word 0x6674a331
  .word 0x57b391bc
  .word 0x14bcbbdc
  .word 0xc419c3cc
  .word 0x5fc76acc
  .word 0x652cc8cd
  .word 0x7077d096
  .word 0xd37a27c8
  .word 0xa092b170
  .word 0x815fe0b4
  .word 0x5d260e2e
  .word 0x29aa1229
  .word 0xf7c93ff0
  .word 0xc969fa2d
  .word 0x3f1a29b1
  .word 0x2b6483c5
  .word 0x91695f23
  .word 0x837854a9
  .word 0x030af647
  .word 0xce8ec428
  .word 0x2da01be5
  .word 0xbd3a32ff
  .word 0xcb671691
  .word 0x619b5414
  .word 0x255d1c8f
  .word 0x359eac0c
  .word 0x196071e0
  .word 0x0becfb92
  .word 0x21746fae
  .word 0x47408130
  .word 0x2a2fd144
  .word 0xb2bd040e
  .word 0x4c92e065
  .word 0x1f0da4ad
  .word 0xca8af3a1
  .word 0xd4bf0646
  .word 0xb8125757
  .word 0x6f450a26
  .word 0xe7efeedd
  .word 0xcd9b25ca
  .word 0x939b7ba9
  .word 0x88d25f9a
  .word 0xfb499b9c
  .word 0x53354e7d
  .word 0x331ba6de
  .word 0x6b0ebd39
  .word 0xb23bbf16
  .word 0xf93b1027
  .word 0xdc722e20
  .word 0xf7282e50
  .word 0xa45915ce
  .word 0x25371f63
  .word 0x4e4e3220
  .word 0x5f5407ba
  .word 0x944dbf78
  .word 0xbfb8e5b0
  .word 0x76f1b851
  .word 0xfe5c3d53
  .word 0x282f23a5
  .word 0x5f60473a
  .word 0x17db5da6
  .word 0x51c291c8
  .word 0x984e1c01
  .word 0x00ebb6ee
  .word 0x31ba65cb
  .word 0xc825f0c8
  .word 0x2de09f7a
  .word 0xd8c510bc
  .word 0xba5e063a
  .word 0x192a7b5d
  .word 0x2ccba1d5
  .word 0x66e10a16
  .word 0xaff267e8
  .word 0xd6497d8c
  .word 0x613ab83f
  .word 0x0afc5749
  .word 0x745c5a3b
  .word 0x2b9a0e99
  .word 0x7e0c1202
  .word 0x157ee36d
  .word 0xf572b45f
  .word 0xe4450a0f
  .word 0xd7f9f57c
  .word 0x8229c8a4
  .word 0xae86dcc9
  .word 0xd13f7c87
  .word 0xe4435988
  .word 0x3c00fb39
  .word 0xf7429a7a
  .word 0xf0f64f1b
  .word 0x0c148ba2
  .word 0x716ebabd
  .word 0x1bc33ab1
  .word 0xab9ede23
  .word 0x5ae13778
  .word 0xeb33f869
  .word 0x1da7567b
  .word 0xf1cac28b
  .word 0x341ca3f2
  .word 0x6ef4d55b
  .word 0xc6a713e0
  .word 0x37233789
  .word 0x80aa1d19
  .word 0xc4c60a0c
  .word 0x88f69f6c
  .word 0x4713a0b1
  .word 0x74c457f2
  .word 0xc1973daa
  .word 0x008c3ad6
  .word 0x687ba3e0
  .word 0x7cf57316
  .word 0xcc8f9c1c
  .word 0x4c176fd4
  .word 0x849da274
  .word 0x7e1fb7ce
  .word 0xd28c2f6b
  .word 0x43ed89b0
  .word 0xae6dc9f7
  .word 0x4123a281
  .word 0x6fb1208c
  .word 0xa9d1f31d
  .word 0xf628ae78
  .word 0x55ec35df
  .word 0x0ed2049d
  .word 0x4a224bc7
  .word 0x89a231ea
  .word 0x69b015b0
  .word 0xf7bbcbe9
  .word 0x4ce96dcf
  .word 0xe4962afb
  .word 0xc96234ae
  .word 0xdacd0360
  .word 0x1a56db87
  .word 0x0b3ccef2
  .word 0x1304d9a1
  .word 0xcf3ccefd
  .word 0x2cc09043
  .word 0x54f6b91c
  .word 0xc30e82f4
  .word 0x7d451530
  .word 0xbf9f624a
  .word 0xab9c4139
  .word 0x88d64276
  .word 0xce3f105e
  .word 0xcc06420d
  .word 0x6f2cc1e7
  .word 0x3aa34fc4
  .word 0x334c86d0
  .word 0xe8cba771
  .word 0x71b3e320
  .word 0x8fa356b6
  .word 0x8ff17f2e
  .word 0x8a0ca5e4
  .word 0x785df8b3
  .word 0x3578b53f
  .word 0x0b49d8ce
  .word 0x990dee84
  .word 0xc4640daf
  .word 0x36b6ce83
  .word 0x8a4ff56f
  .word 0xb10da4c8
  .word 0xa473a5af
  .word 0x746c32fb
  .word 0xce6e23f0
  .word 0x2071daf3
  .word 0x05ce5c66
  .word 0x504b65dd
  .word 0x833a7271
  .word 0x77cde748
  .word 0x19385193
  .word 0x4eb61cb6
  .word 0xb2e82813
  .word 0xbd64762e
  .word 0x71b5416b
  .word 0x88ea190d
  .word 0x0845d409
  .word 0xdf07e950
  .word 0x5fb7d0c4
  .word 0xe9ec8c58
  .word 0x93e0e962
  .word 0x2440e17c
  .word 0x89d2a446
  .word 0x61e6461a
  .word 0x4f9db27f
  .word 0x062671cd
  .word 0xca9e81f7
  .word 0xd5e0f760
  .word 0xfb7f9eb1
  .word 0x163cc757
  .word 0x00b9eeff
  .word 0xb90c4138
  .word 0x9d5ebbfc
  .word 0xb63eeb51
  .word 0xf69f7e29
  .word 0xfe8870ab
  .word 0x7b239b2d
  .word 0xf8f74cc2
  .word 0xa5180129
  .word 0x0b0ae0e0
  .word 0x37b63f90
  .word 0x7681845c
  .word 0x888c0acd
  .word 0x1959cc75
  .word 0xa811da9c
  .word 0x5cf6787a
  .word 0x0b3304c4
  .word 0xfd717508
  .word 0x71e23306
  .word 0x5aabfd29
  .word 0x3e791f8a
  .word 0x002b4152
  .word 0x745cfd83
  .word 0x0cf63cdb
  .word 0x7cce4325
  .word 0x0e80b291
  .word 0x8d3f2040
  .word 0xde5ffe99
  .word 0x7e8e105b
  .word 0xb9eb80dc
  .word 0x6e9834bb
  .word 0xf5a8c5c5
  .word 0x5257e780
  .word 0xf2f07f90
  .word 0xc266c894
  .word 0x2e361fcf
  .word 0x81680b84
  .word 0x922143bd
  .word 0x631c7801
  .word 0x959a03b0
  .word 0x0f4afbbc
  .word 0xdf69e5ec
  .word 0xe93c5200
  .word 0x22b084c0
  .word 0x2422b0b3
  .word 0x9741282e
  .word 0xa0f0ac96
  .word 0x48f995c9
  .word 0x30fdffdb
  .word 0x05d17ed7
  .word 0x3c94c9a3
  .word 0x5b306b40
  .word 0x246a1ac8
  .word 0x4815298a
  .word 0x437fa6f2
  .word 0x576a968d
  .word 0x7b4b3fd5
  .word 0xe55453e1
  .word 0xf716be81
  .word 0x64d164ad
  .word 0xdf8757e8
  .word 0x10c84958
  .word 0x068dc2af
  .word 0x1b442f48
  .word 0xb23dde5f
  .word 0x25dd36ed
  .word 0xd46466aa
  .word 0x32fa3fd4
  .word 0x8956a2ed
  .word 0xd5a5f4c9
  .word 0x2366fc14
  .word 0x5201541c
  .word 0x44522209
  .word 0xc71def38
  .word 0x973c698d
  .word 0xd2bbde18
  .word 0x74263143
  .word 0x89f199c8
  .word 0xc889e310
  .word 0x8205e5eb
  .word 0xcd42cc4b
  .word 0x19ce9a4a
  .word 0x02226837
  .word 0x3b1f0119
  .word 0x2754331f
  .word 0xbde8f9bf
  .word 0x71085ced
  .word 0xb7c2091a
  .word 0xc564b91c
  .word 0xbf93836a
  .word 0x9b6eb5d2
  .word 0x3e512f6b
  .word 0xdc872568
  .word 0x96d18e1b
  .word 0x87266306
  .word 0x80622510
  .word 0x63007036
  .word 0x5d346d17
  .word 0x82e184e3
  .word 0xa317c4d6
  .word 0x9510b12a
  .word 0x4dbb59ef
  .word 0xf89c1b17
  .word 0x42ac171d
  .word 0x93ed4d66
  .word 0x2c72cb3c
  .word 0xfc7f8569
  .word 0xf2e7c853
  .word 0xb20c4b47
  .word 0xc8ddf2df
  .word 0xc801c6a5
  .word 0x8119704a
  .word 0xf7cc9b19
  .word 0xeca61241
  .word 0xeb4f2c06
  .word 0x8a021a60
  .word 0xad3210f0
  .word 0xd415bdb6
  .word 0x0a55b9c2
  .word 0x62ad50a8
  .word 0x66a3c3cc
  .word 0xb112525d
  .word 0xc5d50f2e
  .word 0x5e1e6a32
  .word 0x550df1b1
  .word 0x5e60947d
  .word 0x6e353f8e
  .word 0xd87fff08
  .word 0x423ced84
  .word 0x94354605
  .word 0x392fafc9
  .word 0x4627b1e4
  .word 0x544b2395
  .word 0x3fd9ceee
  .word 0x1adf0e46
  .word 0x4bcbc213
  .word 0xf622d317
  .word 0x6fe19ff7
  .word 0xc4c15703
  .word 0xe7639873
  .word 0x861f7996
  .word 0x73bffa47
  .word 0x0d0eb00a
  .word 0x6d7009a5
  .word 0x40175794
  .word 0xaf7b1ff6
  .word 0x74276d36
  .word 0xc6b8b5c9
  .word 0x98bed61d
  .word 0x8b02a619
  .word 0xe4b24b26
  .word 0x564ba5ae
  .word 0x5babecd4
  .word 0xc0e08c52
  .word 0x73dbccc0
  .word 0xcb523302
  .word 0xab5b4400
  .word 0xb467746f
  .word 0x61434d64
  .word 0xc6fa64c4
  .word 0xd337b1b5
  .word 0x1b029123
  .word 0x5fcb5f47
  .word 0xd84f7731
  .word 0x65dfabec
  .word 0x57255f47
  .word 0x9c55654c
  .word 0x1cf431b3
  .word 0x748b490f
  .word 0x341c94dd
  .word 0xe6d8504c
  .word 0x7178954f
  .word 0x1f56324a
  .word 0x78afceaa
  .word 0xa46d8e14
  .word 0x698266b5
  .word 0x174b7125
  .word 0xd5fd8a10
  .word 0x3c5a3846
  .word 0xcad554d4
  .word 0x916069a1
  .word 0x7ca48262
  .word 0x23ce1543
  .word 0x25e3d96b
  .word 0xbd4e605c
  .word 0xdb7297c3
  .word 0x36b2e05c

.balign 32
signature:
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

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
.balign 32
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
    /* Inv Layer 1 */
    .word 0xf6ff35e0, 0x016d1f44
    /* ninv * plant (-> normal domain) */
    .word 0x00801c07, 0xff000002

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