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
    /* Layer 8 - 1 */
    .word 0x000b292a
    .word 0x00399523
    .word 0x0005fe03
    .word 0x002176bf
    .word 0x00171aa8
    .word 0x000872f6
    .word 0x000bc189
    .word 0x0051c998
    .word 0x006fc8f3
    .word 0x003ca555
    .word 0x00533a1b
    .word 0x005be39c
    .word 0x007dbc2d
    .word 0x00781f10
    .word 0x00778da1
    .word 0x0014e995
    .word 0x000bee33
    .word 0x0049fe24
    .word 0x001a324e
    .word 0x005035cf
    .word 0x004b87dd
    .word 0x0010d5f0
    .word 0x007c98a1
    .word 0x00002e67
    .word 0x0062e1ed
    .word 0x00049f9d
    .word 0x002dff14
    .word 0x0021577c
    .word 0x0072c011
    .word 0x00507ceb
    .word 0x004c8d2b
    .word 0x0042ebd2
    .word 0x00336939
    .word 0x006594a4
    .word 0x003d61de
    .word 0x0051f32d
    .word 0x001bfe1e
    .word 0x00154207
    .word 0x0029dc73
    .word 0x001f088f
    .word 0x006e1eb3
    .word 0x0018a6aa
    .word 0x00746ff8
    .word 0x00577847
    .word 0x000b0f44
    .word 0x0059dc44
    .word 0x0077d194
    .word 0x00243b02
    .word 0x0060edfb
    .word 0x0058acce
    .word 0x0040930c
    .word 0x000529f4
    .word 0x0012202d
    .word 0x006172c3
    .word 0x0011ffdd
    .word 0x005fc03b
    .word 0x006676db
    .word 0x004322ca
    .word 0x0027de75
    .word 0x002e4a8e
    .word 0x00781fea
    .word 0x00168979
    .word 0x0076ee00
    .word 0x0018c53a
    /* Layer 7 - 1 */
    .word 0x00654186
    .word 0x001d54cd
    .word 0x0023ec27
    .word 0x000500a8
    .word 0x0007019b
    .word 0x005c957b
    .word 0x002a66a4
    .word 0x002a5acb
    .word 0x00222136
    .word 0x003a4483
    .word 0x007071ea
    .word 0x007a8d75
    .word 0x0009f7db
    .word 0x0034e991
    .word 0x0056ee7b
    .word 0x006b2d61
    .word 0x004c6357
    .word 0x0012b7a5
    .word 0x00766595
    .word 0x005a5136
    .word 0x00240acf
    .word 0x003fd383
    .word 0x00226787
    .word 0x006497da
    .word 0x00533b09
    .word 0x004457e1
    .word 0x00518cb5
    .word 0x00141b2e
    .word 0x0013d630
    .word 0x004abda3
    .word 0x00247c31
    .word 0x00275b35
    /* Layer 6 - 1 */
    .word 0x00638491
    .word 0x004cd1d6
    .word 0x00639693
    .word 0x00535c27
    .word 0x0044d194
    .word 0x007760c9
    .word 0x004f29df
    .word 0x002c35a2
    .word 0x003c45e5
    .word 0x001a32fc
    .word 0x001d89b7
    .word 0x00468d0b
    .word 0x00368ac2
    .word 0x000c7980
    .word 0x0065078e
    .word 0x004bc3e4
    /* Layer 5 - 1 */
    .word 0x005d072c
    .word 0x0054e96a
    .word 0x0036b44a
    .word 0x0009ce44
    .word 0x00699613
    .word 0x005a6e22
    .word 0x0065b78a
    .word 0x003140e4
    /* Layer 8 - 2 */
    .word 0x00213f95
    .word 0x0034fac5
    .word 0x0021d9e3
    .word 0x00598787
    .word 0x00003081
    .word 0x003a920f
    .word 0x003087a8
    .word 0x001a5a70
    .word 0x000c7e49
    .word 0x004239fd
    .word 0x0013fe35
    .word 0x00015cd5
    .word 0x006cbcd3
    .word 0x006cf49a
    .word 0x000418a8
    .word 0x005e69d7
    .word 0x001caf46
    .word 0x001d53ca
    .word 0x0076848b
    .word 0x007db5f6
    .word 0x00578bdd
    .word 0x005cd6de
    .word 0x00371c66
    .word 0x001b0c2c
    .word 0x0060c299
    .word 0x0006fff4
    .word 0x0014ac8c
    .word 0x00522036
    .word 0x004f1ce5
    .word 0x0046b24f
    .word 0x005b71c8
    .word 0x003f4458
    .word 0x00257751
    .word 0x00398274
    .word 0x00395d69
    .word 0x00257281
    .word 0x0038b752
    .word 0x003c817a
    .word 0x00559189
    .word 0x00163712
    .word 0x0003d24e
    .word 0x005701fb
    .word 0x003c60d0
    .word 0x0070792c
    .word 0x00321fb3
    .word 0x00762802
    .word 0x0000e70c
    .word 0x002894c5
    .word 0x00762bcd
    .word 0x00340a88
    .word 0x0067826b
    .word 0x007352f4
    .word 0x00230a4d
    .word 0x007e8b59
    .word 0x001b2a03
    .word 0x001d883c
    .word 0x00362f1e
    .word 0x0019b6a1
    .word 0x001e3469
    .word 0x00006ca4
    .word 0x003c6009
    .word 0x006dd5de
    .word 0x005747c9
    .word 0x007fd928
    /* Layer 7 - 2 */
    .word 0x004e27a8
    .word 0x007c4872
    .word 0x0030c940
    .word 0x00353a7f
    .word 0x0032e0ef
    .word 0x007d4929
    .word 0x002d3358
    .word 0x007882a8
    .word 0x003197ea
    .word 0x00656188
    .word 0x00618b1b
    .word 0x003f9319
    .word 0x005a4d15
    .word 0x0008a163
    .word 0x006e5847
    .word 0x00688eff
    .word 0x00406d79
    .word 0x002d8765
    .word 0x003a392d
    .word 0x0060edab
    .word 0x00042e8c
    .word 0x00312d17
    .word 0x00451912
    .word 0x006c6148
    .word 0x0010ee0c
    .word 0x0054fa66
    .word 0x00624f5f
    .word 0x0059974d
    .word 0x002fa120
    .word 0x00400ab5
    .word 0x002836d1
    .word 0x0050fc10
    /* Layer 6 - 2 */
    .word 0x005ef9ef
    .word 0x004e680d
    .word 0x003d532d
    .word 0x006042ec
    .word 0x003580cc
    .word 0x006f28d5
    .word 0x0071b414
    .word 0x0079dc5d
    .word 0x006e2d3e
    .word 0x0047580a
    .word 0x005fcf5f
    .word 0x002f77a2
    .word 0x0036b98e
    .word 0x00560ec2
    .word 0x004f4ee3
    .word 0x0048e8d7
    /* Layer 5 - 2 */
    .word 0x00146280
    .word 0x00758d13
    .word 0x00069fcd
    .word 0x0035c75a
    .word 0x00198d77
    .word 0x00573c2f
    .word 0x003dff4d
    .word 0x00336d6d
    /* Layer 1--4 */
    .word 0x0012a239
    .word 0x00775e6f
    .word 0x000f56b7
    .word 0x00466d7e
    .word 0x005f601d
    .word 0x0056f251
    .word 0x0049d22c
    .word 0x00092e53
    .word 0x0030d996
    .word 0x002fffce
    .word 0x002c008e
    .word 0x0030d9d6
    .word 0x00467a98
    .word 0x00466a9a
    /* including ninv */
    .word 0x0000b662
    /* ninv */
    .word 0x007f6021

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