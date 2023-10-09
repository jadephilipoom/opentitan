/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for intt_base_dilithium
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

  /* Load stack pointer */
  la x2, stack_end

  /* dmem[data] <= INTT(dmem[input]) */
  la  x10, input
  la  x11, twiddles
  jal  x1, intt_base_dilithium

  ecall

.data
.balign 32
/* First input */
input:
    .word 0x005d48ec
    .word 0x0021a486
    .word 0x007fd956
    .word 0x00513803
    .word 0x0020d597
    .word 0x000b753a
    .word 0x0051e05a
    .word 0x000eba0b
    .word 0x0070ab95
    .word 0x006a124d
    .word 0x003aa1cf
    .word 0x00509b8c
    .word 0x005d6ef6
    .word 0x00581b11
    .word 0x00416724
    .word 0x002928ca
    .word 0x0067fd57
    .word 0x00612635
    .word 0x001f0f39
    .word 0x0069694c
    .word 0x004f6e0f
    .word 0x00494bfe
    .word 0x0053dab9
    .word 0x0046eb19
    .word 0x001966c5
    .word 0x0026bb1d
    .word 0x000e0ae2
    .word 0x004f5513
    .word 0x0041e2be
    .word 0x00212792
    .word 0x000d3cd0
    .word 0x007ec2f2
    .word 0x005fa78b
    .word 0x00485194
    .word 0x0074f732
    .word 0x002e3b91
    .word 0x001c4ea8
    .word 0x0073e91f
    .word 0x002c1d03
    .word 0x0003733e
    .word 0x001f21a0
    .word 0x000f6d7c
    .word 0x0077587a
    .word 0x003eab0c
    .word 0x0008059b
    .word 0x0017bd4c
    .word 0x007bc5c1
    .word 0x001f8091
    .word 0x007a067b
    .word 0x0013d4ae
    .word 0x006e2d11
    .word 0x00265723
    .word 0x002213e5
    .word 0x004ee844
    .word 0x0004af11
    .word 0x000773d5
    .word 0x0063c820
    .word 0x0073929d
    .word 0x0023cadd
    .word 0x004dd2a3
    .word 0x005ce3e1
    .word 0x00214b4b
    .word 0x003cecc9
    .word 0x00704e4c
    .word 0x007c621f
    .word 0x003f51e8
    .word 0x005847e5
    .word 0x005fe291
    .word 0x006afdba
    .word 0x002bbb42
    .word 0x006007fe
    .word 0x003a24b5
    .word 0x003370d5
    .word 0x002382e5
    .word 0x005ad74f
    .word 0x007f60d5
    .word 0x006dcb02
    .word 0x0053a1ec
    .word 0x0005d6de
    .word 0x0000da27
    .word 0x00596dd6
    .word 0x007371e0
    .word 0x000bb138
    .word 0x0064e269
    .word 0x00621ec6
    .word 0x007fb198
    .word 0x0035b40c
    .word 0x00688879
    .word 0x004c1445
    .word 0x001535a1
    .word 0x0079aad2
    .word 0x005ff0ca
    .word 0x0063f79d
    .word 0x00449161
    .word 0x000018d1
    .word 0x007b2af4
    .word 0x007264b1
    .word 0x003594f9
    .word 0x001b8372
    .word 0x005edffc
    .word 0x001a7e2f
    .word 0x00445a3f
    .word 0x003d61c7
    .word 0x002f6231
    .word 0x00658b45
    .word 0x001d9560
    .word 0x001f9db8
    .word 0x00237f25
    .word 0x0061b8c8
    .word 0x0050a704
    .word 0x00052369
    .word 0x00399e7f
    .word 0x007950b6
    .word 0x00053f15
    .word 0x000c980c
    .word 0x007b7d0f
    .word 0x002451b1
    .word 0x003d8d33
    .word 0x00632a03
    .word 0x005e8ac4
    .word 0x0012ac7f
    .word 0x00686a84
    .word 0x00210f63
    .word 0x002fb7dd
    .word 0x00787387
    .word 0x0038fec8
    .word 0x00506c1a
    .word 0x007007d4
    .word 0x0064055d
    .word 0x004be313
    .word 0x00517c33
    .word 0x0041493e
    .word 0x004b56a9
    .word 0x00224b4e
    .word 0x005de278
    .word 0x007acb3a
    .word 0x002c6d1b
    .word 0x00407c70
    .word 0x00012caa
    .word 0x003a6c07
    .word 0x0006ad43
    .word 0x000da6e6
    .word 0x0038a26a
    .word 0x0039c794
    .word 0x00670aa4
    .word 0x0051be16
    .word 0x00169deb
    .word 0x007dee58
    .word 0x00731ed6
    .word 0x00268e06
    .word 0x0054eb97
    .word 0x004d54a4
    .word 0x004f1ab6
    .word 0x005da4b3
    .word 0x00189581
    .word 0x0057aa0f
    .word 0x003df4bb
    .word 0x00057dbf
    .word 0x001981fe
    .word 0x00014e3d
    .word 0x0050f1f0
    .word 0x0052eb8c
    .word 0x0032fe6f
    .word 0x0055391c
    .word 0x005767a2
    .word 0x0005cc0b
    .word 0x007fc8b2
    .word 0x00361987
    .word 0x00055595
    .word 0x006f261a
    .word 0x002eb8e3
    .word 0x00061ed4
    .word 0x0024f7dd
    .word 0x006a749e
    .word 0x004a0230
    .word 0x00593b36
    .word 0x0058d9bb
    .word 0x0047480a
    .word 0x00288503
    .word 0x0015a3af
    .word 0x00329308
    .word 0x004a242c
    .word 0x005a80aa
    .word 0x00180e0f
    .word 0x00683d44
    .word 0x003fbced
    .word 0x0039b459
    .word 0x001a66ab
    .word 0x0002d6f3
    .word 0x007d8b9d
    .word 0x00290e47
    .word 0x006699a0
    .word 0x0041415a
    .word 0x00514709
    .word 0x000c9ca3
    .word 0x0025287e
    .word 0x00780b0e
    .word 0x006a2ba9
    .word 0x007baad1
    .word 0x00346a9a
    .word 0x002d5ede
    .word 0x007ea727
    .word 0x000ae53d
    .word 0x001912cf
    .word 0x0036b4c7
    .word 0x001b31d4
    .word 0x005332eb
    .word 0x00118338
    .word 0x0002da94
    .word 0x00030772
    .word 0x0064ee68
    .word 0x0037ef2b
    .word 0x00054aca
    .word 0x0036f311
    .word 0x00416fe8
    .word 0x0010b58a
    .word 0x000cfc47
    .word 0x00055418
    .word 0x005e3fb4
    .word 0x007a8656
    .word 0x003eb1e1
    .word 0x00090563
    .word 0x005965c3
    .word 0x001a8f47
    .word 0x0022ca59
    .word 0x00468c90
    .word 0x00175e1e
    .word 0x000fd95a
    .word 0x003ffdff
    .word 0x000c9ea7
    .word 0x00517eb8
    .word 0x004d75a8
    .word 0x002b7935
    .word 0x0006c396
    .word 0x0011731c
    .word 0x0026ca35
    .word 0x000d66e2
    .word 0x00691ae6
    .word 0x00399ac0
    .word 0x0069925b
    .word 0x007fa251
    .word 0x0051cc4d
    .word 0x00648959
    .word 0x00170675
    .word 0x0011fc7f
    .word 0x00577336
    .word 0x0068c888
    .word 0x00658613
    .word 0x0079b4b4
    .word 0x006cfeb6
    .word 0x007f9072
    .word 0x004e234b
    .word 0x002aa3d6
    .word 0x00353929
    .word 0x0020c26a
    .word 0x005478ce

/* Modulus for reduction */
.global modulus
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
    /* Inv Layer 8 - 1 */
    .word 0x00ca2087, 0x92e0bb09
    .word 0xb04e1826, 0x73078efd
    .word 0xf0260fa4, 0x72e78afc
    .word 0x073e5788, 0x9e33e1bc
    .word 0xe83c3f40, 0xa7e8dee7
    .word 0xe53b9f1e, 0x9fe85ed7
    .word 0x0e3fd7da, 0x9e3461dc
    .word 0x37ca4823, 0xed9ec1d5
    /* Inv Layer 7 - 1 */
    .word 0x6818b95f, 0xc4e0c0a6
    .word 0x46c35849, 0xaec2272c
    .word 0x74a1175d, 0xd386be08
    .word 0x99e55e24, 0x5144c08d
    /* Inv Layer 6 - 1 */
    .word 0x3a8fd581, 0x404f9f67
    .word 0xb2377e7c, 0xb777da87
    /* Inv Layer 5 - 1 */
    .word 0x6ba55a80, 0xffa31ac7
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 2 */
    .word 0x47e44e84, 0x6c36b6d5
    .word 0xf5069bbd, 0x51efdb52
    .word 0xc01904c1, 0x41100b80
    .word 0x5f4cbc71, 0x7301c58b
    .word 0xa7e00ab3, 0xe14ae4f6
    .word 0x5f0c5457, 0x110765b7
    .word 0x51dec50e, 0xdab23ad9
    .word 0x53417fba, 0x990b69a8
    /* Inv Layer 7 - 2 */
    .word 0x448d18be, 0xc99e6205
    .word 0xb5448fba, 0xfe317460
    .word 0x932d101e, 0x54b21bdd
    .word 0x0827f3ed, 0x241d4d0b
    /* Inv Layer 6 - 2 */
    .word 0xd600da8b, 0xc1df5a52
    .word 0x2dd37e84, 0x11e87bfb
    /* Inv Layer 5 - 2 */
    .word 0x761fb101, 0xd6225eeb
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 3 */
    .word 0x1f48b1ee, 0x83e25f90
    .word 0xdf030905, 0x515bfa5b
    .word 0x6d8a71c2, 0xccd84878
    .word 0xef36edde, 0x9456626f
    .word 0xddccb372, 0xf2bd155f
    .word 0x5006d115, 0x14ab0698
    .word 0xbf96dc38, 0xd730cc84
    .word 0xbf4b7f62, 0x9d659229
    /* Inv Layer 7 - 3 */
    .word 0x4a5da4d5, 0x02a9fa79
    .word 0xda407068, 0x1374db0f
    .word 0x6b518d8d, 0x86dec4a3
    .word 0x94765e6f, 0x8721b75f
    /* Inv Layer 6 - 3 */
    .word 0x17bdbd40, 0xdbf74419
    .word 0x444ce2b1, 0x1020e218
    /* Inv Layer 5 - 3 */
    .word 0x083d8f54, 0x5c43e240
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 4 */
    .word 0x8a185502, 0x345e0518
    .word 0xd53f3e26, 0x4af67b08
    .word 0x9be028d3, 0x2c9f0367
    .word 0x35add50a, 0xec5e8fcb
    .word 0xff681e09, 0x927c0bdd
    .word 0x7a82a1b4, 0x5602adff
    .word 0x088dad5b, 0x45c31a3b
    .word 0x52a977b9, 0x6e09d599
    /* Inv Layer 7 - 4 */
    .word 0x8d294337, 0xb9d9dd03
    .word 0xdb6d87ac, 0x9ba784a9
    .word 0x9e73599a, 0x8e74fa21
    .word 0x1b839cb1, 0xff2681a2
    /* Inv Layer 6 - 4 */
    .word 0x680ba018, 0xac322731
    .word 0xef6e43b3, 0xd2e1c6cb
    /* Inv Layer 5 - 4 */
    .word 0x439ad42e, 0x66bf5b09
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 5 */
    .word 0x02ecfb39, 0x613a89e0
    .word 0x5e01198b, 0x53b76b33
    .word 0x6bd87f49, 0x9271813b
    .word 0xcd3d55bb, 0xa0f8fafc
    .word 0x9244ea16, 0x40314fd3
    .word 0xb27c47ad, 0x712c382b
    .word 0x779b43e2, 0x236e6151
    .word 0x8a0d8e50, 0x0c0a4a7a
    /* Inv Layer 7 - 5 */
    .word 0x38ca6628, 0x192061e6
    .word 0x1bc8bdf8, 0x1ed55f1a
    .word 0x1904f50c, 0xb50840a6
    .word 0x0f22ce96, 0xc388107d
    /* Inv Layer 6 - 5 */
    .word 0xa97e784c, 0x3ce9b5f3
    .word 0xccf32d32, 0x4c1a8007
    /* Inv Layer 5 - 5 */
    .word 0xe2307459, 0x0690640b
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 6 */
    .word 0xa305ba29, 0x1c5ef183
    .word 0x6d307744, 0x2176b56a
    .word 0xa8669c57, 0x94e3a1be
    .word 0x6c2307ea, 0x3f49fc00
    .word 0xf6d24ea7, 0x853af5b2
    .word 0x47bf273b, 0x6308a964
    .word 0xef869bc8, 0x41dc9aa2
    .word 0xcc178048, 0x68524dc2
    /* Inv Layer 7 - 6 */
    .word 0xceb8c294, 0x30c75d75
    .word 0xfeadb370, 0x872028fb
    .word 0xf009fa9f, 0x8d287903
    .word 0xebfb40f9, 0xcc85dfde
    /* Inv Layer 6 - 6 */
    .word 0xc7949396, 0xd5714ea8
    .word 0xb10e7a3d, 0x0f840ee4
    /* Inv Layer 5 - 6 */
    .word 0x3478ebd3, 0x10a8ea19
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 7 */
    .word 0xcdc91ead, 0x35be5529
    .word 0x6b1700eb, 0xe706c1e2
    .word 0x8b41834b, 0x92cf30a6
    .word 0x6b2345fc, 0x72c29bc1
    .word 0xbe9bd579, 0xc4ddc9e8
    .word 0xcf1c7f82, 0xcb8ceba3
    .word 0x710357f4, 0x87560c74
    .word 0x18cd8330, 0xa77e9c58
    /* Inv Layer 7 - 7 */
    .word 0xa09e1444, 0x97d0e509
    .word 0x3e108ba7, 0x51d07f7c
    .word 0x61f7891f, 0x8cde507a
    .word 0x9357d0ce, 0x9386a682
    /* Inv Layer 6 - 7 */
    .word 0x8e3bb3d1, 0xdbb693ed
    .word 0x1226396b, 0xe9dbef28
    /* Inv Layer 5 - 7 */
    .word 0x0e6bb6d1, 0xe8770bf2
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 8 */
    .word 0x103b42b1, 0x6184a466
    .word 0x1d263554, 0x1102b08a
    .word 0x768e48a6, 0x763a67ad
    .word 0x7728311e, 0x591dfacc
    .word 0xb1e4d9d3, 0x38a103cf
    .word 0x3f4a7a20, 0x6635e2ac
    .word 0xaa88fceb, 0x38c510d2
    .word 0x87efc6e2, 0x5ddf591a
    /* Inv Layer 7 - 8 */
    .word 0xeff5a98b, 0x136d4329
    .word 0xe8854581, 0xf8597a6d
    .word 0x92280ee0, 0xb4fe9e3d
    .word 0x0a74cf1f, 0x8157a6e7
    /* Inv Layer 6 - 8 */
    .word 0x8c9f66c1, 0xc7f5c1e0
    .word 0xc27d4fcf, 0xa353b9a7
    /* Inv Layer 5 - 8 */
    .word 0xf2f747ed, 0x5edde2ba
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 9 */
    .word 0xd14d55b3, 0x2707337e
    .word 0x8fa788c3, 0xaf7e3e30
    .word 0xa318f8f9, 0x75ab47e6
    .word 0xd3a1a2c2, 0x7fca89a2
    .word 0x6a2e66c6, 0x9d8d3612
    .word 0x427c2c87, 0xa0a5ea39
    .word 0xcf935b38, 0xf7a0d044
    .word 0xd9954fa1, 0x4ca4908a
    /* Inv Layer 7 - 9 */
    .word 0x08c44901, 0xc9da1ef4
    .word 0xb587e48f, 0x42fd12be
    .word 0x7d7f94eb, 0xcb3defe5
    .word 0x69000d32, 0x48eead19
    /* Inv Layer 6 - 9 */
    .word 0x4a4da8d6, 0xf5a98275
    .word 0x4afa2bf6, 0x50e3ac49
    /* Inv Layer 5 - 9 */
    .word 0x34a6c94a, 0xde4bb330
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 10 */
    .word 0x3b3db2f7, 0x3df4288e
    .word 0x8341b567, 0x3b300f8d
    .word 0xe17248d0, 0x8b708309
    .word 0x9e8ca3ec, 0x55e0ad7f
    .word 0x9f8d4011, 0xa4da6d51
    .word 0x9106025f, 0xde1b6f1f
    .word 0x03e08c1c, 0x7f04d036
    .word 0x683bf22d, 0x2eadaf0e
    /* Inv Layer 7 - 10 */
    .word 0x99e6f089, 0x91ab9fc4
    .word 0x3506cf4a, 0xf7cca339
    .word 0x0633d4e9, 0x9ed866dc
    .word 0x56d37e32, 0x7278011b
    /* Inv Layer 6 - 10 */
    .word 0xfaf7dc02, 0x5bf0a370
    .word 0x3bca2211, 0xb02f2268
    /* Inv Layer 5 - 10 */
    .word 0xc8eb9754, 0x0f85c351
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 11 */
    .word 0xe1f5879e, 0x0ebe617a
    .word 0x419cd6b3, 0x231839c8
    .word 0x52f1f9d9, 0xa582b161
    .word 0xa5589cdd, 0xeeb8e85c
    .word 0x8f2c61fb, 0x052efbb4
    .word 0xf371b687, 0x4b38a592
    .word 0xb45527e2, 0x9a24abf6
    .word 0xeb7fe423, 0x80b9fd7d
    /* Inv Layer 7 - 11 */
    .word 0x5237bf4c, 0x4623ce67
    .word 0xb0e0acca, 0x25e045c5
    .word 0x26a48ad6, 0x8abe928f
    .word 0x7be12f55, 0x619e9ee4
    /* Inv Layer 6 - 11 */
    .word 0x66eae9ed, 0x7eb99768
    .word 0x05aae0ad, 0x16e5cb45
    /* Inv Layer 5 - 11 */
    .word 0x3a5b6665, 0xef15d998
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 12 */
    .word 0xda78c47d, 0x95705eec
    .word 0xff4c4914, 0x3cb8f9c4
    .word 0xd809f0cd, 0x9e551608
    .word 0xf454cf4c, 0x350a3422
    .word 0x2935f52b, 0x0730ea2c
    .word 0x3898ebca, 0x9cb75a9d
    .word 0xd44dd7ce, 0x6389939d
    .word 0x99de4a5f, 0xb135e416
    /* Inv Layer 7 - 12 */
    .word 0x261c8ed8, 0x50bc767c
    .word 0x4bf39e50, 0x264fefaf
    .word 0x30c0bbce, 0xff9ee5ba
    .word 0x8ced6c42, 0x5b967ae7
    /* Inv Layer 6 - 12 */
    .word 0xdb1e15d0, 0x851d8c58
    .word 0x9ec12d0e, 0x7998d341
    /* Inv Layer 5 - 12 */
    .word 0xcd107483, 0x1a467167
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 13 */
    .word 0x0817e5ea, 0x369df510
    .word 0x0f8c10e6, 0xb6f55be9
    .word 0x5ea2b7f1, 0xbb1fba78
    .word 0x015a5693, 0x6a5f5300
    .word 0xde651589, 0x80390941
    .word 0x1ba17025, 0xd849b2bc
    .word 0x78ecee4a, 0xb7d858a6
    .word 0x8e3b23ad, 0xd7bf9435
    /* Inv Layer 7 - 13 */
    .word 0x26330876, 0x04552b42
    .word 0x508542b0, 0xfd45a76f
    .word 0x939c07db, 0x4cc4246f
    .word 0xa48a3545, 0xd69c8f76
    /* Inv Layer 6 - 13 */
    .word 0x04f97654, 0x4e7a03e4
    .word 0x316067b8, 0xcea655f8
    /* Inv Layer 5 - 13 */
    .word 0xde43f742, 0x68ca79cc
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 14 */
    .word 0xffbceb3c, 0x4b306181
    .word 0x327f2f67, 0x5cbdc6b8
    .word 0x9cbaaf73, 0x12f9963f
    .word 0x48fd16b4, 0x772e0a94
    .word 0xf98e2196, 0xda875820
    .word 0x17370f96, 0x5960475f
    .word 0xd7c601d1, 0x671317f7
    .word 0x05ca4a88, 0x296f9b94
    /* Inv Layer 7 - 14 */
    .word 0x3918c3bf, 0x12bb9ac1
    .word 0x3a251ed4, 0xd7f994b5
    .word 0xdfe54592, 0xbc3b4959
    .word 0xd7474e25, 0xf1fc9741
    /* Inv Layer 6 - 14 */
    .word 0x5c11e5c2, 0x34a3e28f
    .word 0x18bf79ad, 0x32df035b
    /* Inv Layer 5 - 14 */
    .word 0xf809b67e, 0x0448ba25
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 15 */
    .word 0x9374ee15, 0xab3537f7
    .word 0x6085a4a9, 0x51f7893e
    .word 0xc771c8e4, 0xab1d8009
    .word 0xb666c044, 0x9612636c
    .word 0xfa946525, 0x46a6b51f
    .word 0x283015b6, 0xec0b4cfb
    .word 0x28f96207, 0xf1f9486e
    .word 0x27461b39, 0x0aa7c1db
    /* Inv Layer 7 - 15 */
    .word 0x25cba89f, 0xc549bee5
    .word 0x9aa32595, 0x7b6ae1c1
    .word 0xd44f7234, 0x95eff2d0
    .word 0xf2385632, 0x3e4a621b
    /* Inv Layer 6 - 15 */
    .word 0x327bd290, 0x3df38866
    .word 0x8f269888, 0x238b7e98
    /* Inv Layer 5 - 15 */
    .word 0x8ae26f87, 0xd1bf2024
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Inv Layer 8 - 16 */
    .word 0xcf95a5cb, 0xf5fc2f1f
    .word 0xe72c5347, 0x1ee3e6bb
    .word 0xd405059a, 0xb815b7fd
    .word 0xa3c63647, 0x8b59d15d
    .word 0x89719553, 0xc547b863
    .word 0x9124f81c, 0xbbac7fa8
    .word 0x754d0457, 0x354a4827
    .word 0x3fe51ec8, 0x000db56d
    /* Inv Layer 7 - 16 */
    .word 0x28179395, 0xc6931939
    .word 0x64fe44c8, 0xe6fd2d7d
    .word 0xc40bdf70, 0xbd703291
    .word 0xd8e8e087, 0xce6926ac
    /* Inv Layer 6 - 16 */
    .word 0xc90abd1e, 0x9913d3c2
    .word 0xa32b438b, 0x7a06dec3
    /* Inv Layer 5 - 16 */
    .word 0xa63856ca, 0xbd40589b
    /* Padding */
    .word 0x00000000, 0x00000000
    /* ---------------- */
    /* Inv Layer 4 */
    .word 0xbbb24b1c, 0x5f6c3e50
    .word 0xf324833b, 0x480acc22
    .word 0xba289cb3, 0xbd01c2f6
    .word 0x059a8c98, 0xa3ead36d
    .word 0xe2289461, 0xcb8e47fa
    .word 0x3144a4c7, 0x596223d6
    .word 0x93b03ee9, 0xf400fa56
    .word 0xef10643b, 0xf6be75af
    /* Inv Layer 3 */
    .word 0x77bc4623, 0x6bdeb0d4
    .word 0xfe863d93, 0x8696fcb1
    .word 0xd663572a, 0x8cb8e920
    .word 0x7849a579, 0x3a0aaa36
    /* Inv Layer 2 */
    .word 0x2ac7818b, 0xe81da198
    .word 0xe626f5f2, 0x20362949
    /* Inv Layer 1 */
    .word 0x3c62b435, 0xe9a81632
.balign 32
.global ninv
ninv:
    /* ninv */
    .word 0x007f6021
    .word 0x007f6021
    .word 0x007f6021
    .word 0x007f6021
    .word 0x007f6021
    .word 0x007f6021
    .word 0x007f6021
    .word 0x007f6021
/* Padding */
.word 0x00000000
.zero 512
stack_end:
.zero 1