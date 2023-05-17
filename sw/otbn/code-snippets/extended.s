/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Standalone binary that tests experimental OTBNsim extensions.
 *
 * This binary is not expected to work for RTL simulations, only the (modified)
 * Python-based OTBN simulator.
 */

/* Index of the Keccak command special register. */
.equ KECCAK_CMD_REG, 0x7dc
/* Command to start a SHAKE-128 operation. */
.equ SHAKE128_START_CMD, 0x1d
/* Command to start a SHAKE-256 operation. */
.equ SHAKE256_START_CMD, 0x5d
/* Command to end an ongoing Keccak operation of any kind. */
.equ KECCAK_DONE_CMD, 0x16
/* Index of the Keccak write-length special register. */
.equ KECCAK_WRITE_LEN_REG, 0x7e0

/**
 * Note: the above constants are the ones relevant to 32-bit special registers
 * (aka CSRs). Similar constants for 256-bit special registers (aka WSRs) will
 * unfortunately not be usable because the OTBN assembler currently doesn't
 * support .equ in big number instructions or pseudoinstructions:
 * https://github.com/lowRISC/opentitan/issues/17727
 */

.section .text.start
start:
  /* Initialize all-zero register. */
  bn.xor    w31, w31, w31

  /* Test vectorized modular arithmetic.
       w20..w25 <= vectorized arithmetic test results */
  jal       x1, vec_arith_test

  /* Test vectorized shifting.
       w26..w29 <= vectorized shifting test results */
  jal       x1, vec_shift_test

  /* Test SHAKE functions. */
  jal       x1, shake_test

  /* Test memory sizes. This step zeroes the memory, so do it last. */
  jal       x1, check_mem_sizes

  /* End the program. */
  ecall

/**
 * Basic tests for vectorized add/sub/mul modulo.
 *
 * This test uses a value x from DMEM and 16-bit vectorized instructions to
 * compute vectors a, b, and c such that:
 *   a[i] = (x[i] + x[i]) % modulus16[i]
 *   b[i] = (- x[i]) % modulus16[i]
 *   c[i] = (x[i] * x[i]) % modulus16[i]
 *
 * This test uses a value y from DMEM and 32-bit vectorized instructions to
 * compute vectors d, e, and f such that:
 *   d[i] = (5 * y[i]) % modulus32[i]
 *   e[i] = (- y[i]) % modulus32[i]
 *   f[i] = (y[i] * y[i]) % modulus32[i]
 *
 * @param[in]           w31: all-zero
 * @param[in] dmem[x..x+32]: x, value for testing
 * @param[in] dmem[y..y+32]: y, value for testing
 * @param[out]          w20: a, 16-bit modular addition result
 * @param[out]          w21: b, 16-bit modular subtraction result
 * @param[out]          w22: c, 16-bit modular multiplication result
 * @param[out]          w23: d, 32-bit modular addition result
 * @param[out]          w24: e, 32-bit modular subtraction result
 * @param[out]          w25: f, 32-bit modular multiplication result
 *
 * clobbered registers: x2, x3, w0, w1, w20 to w25, MOD
 * clobbered flag groups: None
 */
vec_arith_test:
  /* Load the vectorized 16-bit test modulus.
       w0 <= dmem[modulus16..modulus16+32] */
  la       x2, modulus16
  bn.lid   x0, 0(x2)

  /* Copy the modulus into the MOD special register.
       MOD <= w0 */
  bn.wsrw  0, w0

  /* Load the 16-bit vectorized test value x.
       w1 <= dmem[x..x+32] */
  la       x2, x
  li       x3, 1
  bn.lid   x3, 0(x2)

  /* Compute a such that a[i] = (x[i] * 5) % MOD[i].
       w20 <= (x +v x +v x +v x +v x) % MOD */
  bn.v16.addm   w20, w1, w1
  bn.v16.addm   w20, w20, w1
  bn.v16.addm   w20, w20, w1
  bn.v16.addm   w20, w20, w1

  /* Compute b such that b[i] = (- x[i]) % MOD[i].
       w21 <= (0 -v x) % MOD */
  bn.v16.subm   w21, w31, w1

  /* Compute c such that c[i] = (x[i] * x[i]) % MOD[i].
       w22 <= (x *v x) % MOD */
  bn.v16.mulm   w22, w1, w1

  /* Load the vectorized 32-bit test modulus.
       w0 <= dmem[modulus32..modulus32+32] */
  la       x2, modulus32
  bn.lid   x0, 0(x2)

  /* Copy the modulus into the MOD special register.
       MOD <= w0 */
  bn.wsrw  0, w0

  /* Load the 32-bit vectorized test value y.
       w1 <= dmem[y..y+32] */
  la       x2, y
  bn.lid   x3, 0(x2)

  /* Compute d such that d[i] = (y[i] * 5) % MOD[i].
       w23 <= (y +v y +v y +v y +v y) % MOD */
  bn.v32.addm   w23, w1, w1
  bn.v32.addm   w23, w23, w1
  bn.v32.addm   w23, w23, w1
  bn.v32.addm   w23, w23, w1

  /* Compute e such that e[i] = (- y[i]) % MOD[i].
       w24 <= (0 -v y) % MOD */
  bn.v32.subm   w24, w31, w1

  /* Compute f such that f[i] = (y[i] * y[i]) % MOD[i].
       w25 <= (y *v y) % MOD */
  bn.v32.mulm   w25, w1, w1

  ret

/**
 * Basic tests for vectorized shifts.
 *
 * This test uses a value x from DMEM and 16-bit vectorized instructions to
 * compute vectors g and h such that:
 *   g[i] = (x[i] >> 4)
 *   h[i] = (x[i] << 4)
 *
 * This test uses a value y from DMEM and 32-bit vectorized instructions to
 * compute vectors j and k such that:
 *   j[i] = (y[i] >> 12)
 *   k[i] = (y[i] << 12)
 *
 * @param[in]           w31: all-zero
 * @param[in] dmem[x..x+32]: x, value for testing
 * @param[in] dmem[y..y+32]: y, value for testing
 * @param[out]          w26: g, 16-bit right-shift result
 * @param[out]          w27: h, 16-bit left-shift result
 * @param[out]          w28: j, 32-bit right-shift result
 * @param[out]          w29: k, 32-bit left-shift result
 *
 * clobbered registers: x2, x3, w1, w26 to w29
 * clobbered flag groups: None
 */
vec_shift_test:
  /* Load the 16-bit vectorized test value x.
       w1 <= dmem[x..x+32] */
  la       x2, x
  li       x3, 1
  bn.lid   x3, 0(x2)

  /* Compute g such that g[i] = (x[i] >> 4).
       w26 <= (x >>v 4) */
  bn.v16.rshi   w26, w31, w1 >> 4

  /* Compute h such that h[i] = (x[i] << 4).
       w27 <= (x <<v 4) */
  bn.v16.rshi   w27, w1, w31 >> 12

  /* Load the 32-bit vectorized test value y.
       w1 <= dmem[y..y+32] */
  la       x2, y
  bn.lid   x3, 0(x2)

  /* Compute j such that j[i] = (y[i] >> 12).
       w28 <= (y >>v 12) */
  bn.v32.rshi   w28, w31, w1 >> 12

  /* Compute k such that k[i] = (y[i] << 12).
       w29 <= (y <<v 12) */
  bn.v32.rshi   w29, w1, w31 >> 20

  ret

/**
 * Test SHAKE extensions.
 *
 * Computes long SHAKE outputs for a test message. The length of 1536 bits has
 * been chosen to exceed the Keccak rate for both SHAKE-128 and SHAKE-256, so
 * full XOF functionality gets tested.
 *
 * @param[in]                w31: all-zero
 * @param[in]          dmem[len]: len, byte-length of the message (32 bits)
 * @param[in] dmem[msg..msg+len]: msg, hash input for testing
 * @param[out]           w8..w13: SHAKE128(msg, 1536)
 * @param[out]          w14..w19: SHAKE256(msg, 1536)
 *
 * clobbered registers: TODO
 * clobbered flag groups: None
 */
shake_test:
  /* Read the test message length.
       x10 <= dmem[msg_len] */
  la        x10, msg_len
  lw        x10, 0(x10)

  /* Initialize a SHAKE128 operation. */
  addi      x2, x0, SHAKE128_START_CMD
  csrrw     x0, KECCAK_CMD_REG, x2

  /* Send the message to the Keccak core. */
  la        x11, msg
  jal       x1, keccak_send_message

  /* Read the digest from the KECCAK_DIGEST special register (index 8).
       w8..w13 <= SHAKE128(msg, 1536) */
  bn.wsrr  w8, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w9, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w10, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w11, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w12, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w13, 0x9 /* KECCAK_DIGEST */

  /* Finish the SHAKE-128 operation. */
  addi      x2, x0, KECCAK_DONE_CMD
  csrrw     x0, KECCAK_CMD_REG, x2

  /* Initialize a SHAKE-256 operation. */
  addi      x2, x0, SHAKE256_START_CMD
  csrrw     x0, KECCAK_CMD_REG, x2

  /* Send the message to the Keccak core. */
  la        x11, msg
  jal       x1, keccak_send_message

  /* Read the digest from the KECCAK_DIGEST special register (index 9).
       w14..w19 <= SHAKE256(msg, 1536) */
  bn.wsrr  w14, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w15, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w16, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w17, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w18, 0x9 /* KECCAK_DIGEST */
  bn.wsrr  w19, 0x9 /* KECCAK_DIGEST */


  /* Finish the SHAKE-256 operation. */
  addi      x2, x0, KECCAK_DONE_CMD
  csrrw     x0, KECCAK_CMD_REG, x2

  ret

/**
 * Send a variable-length message to the Keccak core.
 *
 * Expects the Keccak core to have already received a `start` command matching
 * the desired hash function. After calling this routine, reading from the
 * KECCAK_DIGEST special register will return the hash digest.
 *
 * @param[in]   x10: len, byte-length of the message
 * @param[in]   x11: dptr_msg, pointer to message in DMEM
 * @param[in]   w31: all-zero
 * @param[in] dmem[dptr_msg..dptr_msg+len]: msg, hash function input
 *
 * clobbered registers: x3, x11, w0
 * clobbered flag groups: None
 */
keccak_send_message:
  /* Compute the number of full 256-bit message chunks.
       x3 <= x10 >> 5 = floor(len / 32) */
  srli     x3, x10, 5

  /* Write all full 256-bit sections of the test message. */
  loop     x3, 2
    /* w0 <= dmem[x11..x11+32] = msg[32*i..32*i-1]
       x11 <= x11 + 32 */
    bn.lid   x0, 0(x11++)
    /* Write to the KECCAK_MSG wide special register (index 8).
         KECCAK_MSG <= w0 */
    bn.wsrw  0x8, w0

  /* Compute the remaining message length.
       x3 <= x10 & 31 = len mod 32 */
  andi     x3, x10, 31

  /* If the remaining length is zero, return early. */
  beq      x3, x0, _keccak_send_message_end

  /* Partial write: set KECCAK_WRITE_LEN special register before sending. */
  csrrw    x0, KECCAK_WRITE_LEN_REG, x3
  bn.lid   x0, 0(x11)
  bn.wsrw  0x8, w0

  _keccak_send_message_end:
  ret

/**
 * Check that scratchpad and DMEM memory are as large as expected.
 *
 * Expects the scratchpad to be 1kB in length and the rest of DMEM to be 7kB.
 *
 * Will throw a BAD_DATA_ADDR area if the sizes are too small. This routine
 * does not check if the DMEM ranges are larger than expected.
 *
 * @param[in]  w31: all-zero
 *
 * clobbered registers: x2, x3
 * clobbered flag groups: None
 */
check_mem_sizes:
  /* Load a pointer to the all-zero register. */
  li        x2, 31

  /* Store 32*32 = 1024 bytes of zeroes to the scratchpad. */
  la        x3, scratchpad_start
  loopi     31, 1
    /* dmem[x3] <= w31 */
    bn.sid    x2, 0(x3++)

  /* Store 32*224 = 7168 bytes of zeroes to the data section. */
  la        x3, data_start
  loopi     224, 1
    /* dmem[x3] <= w31 */
    bn.sid    x2, 0(x3++)

  ret

/**
 * Memory in this section is visible only to OTBN.
 *
 * Size in current RTL: 1024 bytes.
 * Expected size in modified OTBNsim: 1024 bytes.
 */
.section .scratchpad

/* Label for `check_mem_sizes` marking the start of the scratchpad. */
scratchpad_start:

/* Fill the entire scratchpad with zeroes. */
.zero 1024

/**
 * Memory in this section is readable/writeable by Ibex when OTBN is idle.
 *
 * Size in current RTL: 3072 bytes.
 * Expected size in modified OTBNsim: 7168 bytes.
 */
.data

/* Label for `check_mem_sizes` marking the start of the data section. */
data_start:

/**
 * Test modulus for 16-bit vectorized instructions.
 *
 * This is the 13-bit Kyber modulus (0x0d01), vectorized.
 */
.balign 32
modulus16:
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01
.word 0x0d010d01

/**
 * Test modulus for 32-bit vectorized instructions.
 *
 * This is the 23-bit Dilithium modulus (0x7fe001), vectorized.
 */
.balign 32
modulus32:
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001
.word 0x007fe001

/**
 * Test value x for 16-bit vectorized instructions.
 *
 * This value has been chosen to be somewhat human-friendly visually and also
 * to have all 16-bit sections less than `modulus16`.
 *
 * Full hex value in big-endian form:
 * x = 0x00000111022203330444055506660777088809990aaa0bbb0ccc01dd01ee01ff
 */
.balign 32
x:
.word 0x01ee01ff
.word 0x0ccc01dd
.word 0x0aaa0bbb
.word 0x08880999
.word 0x06660777
.word 0x04440555
.word 0x02220333
.word 0x00000111

/**
 * Test value y for 32-bit vectorized instructions.
 *
 * This value has been chosen to be somewhat human-friendly visually and also
 * to have all 32-bit sections less than `modulus32`.
 *
 * Full hex value in big-endian form:
 * y = 0x00008801001199020022aa030033bb040044cc050055dd060066ee070077ff08
 */
.balign 32
y:
.word 0x0077ff08
.word 0x0066ee07
.word 0x0055dd06
.word 0x0044cc05
.word 0x0033bb04
.word 0x0022aa03
.word 0x00119902
.word 0x00008801

/**
 * Byte-length of hashing test message = 703 bytes.
 */
.balign 4
msg_len:
.word 0x000002bf

/**
 * Test message for hashing.
 *
 * OTBN uses little-endian representation, so the order of bytes within each
 * 32-bit word will look reversed here.
 *
 * This is the ASCII encoding of the intro crawl for Star Wars Episode IV:
 * b'It is a period of civil wars in the galaxy. A brave alliance of underground freedom fighters has challenged the tyranny and oppression of the awesome GALACTIC EMPIRE.\n\nStriking from a fortress hidden among the billion stars of the galaxy, rebel spaceships have won their first victory in a battle with the powerful Imperial Starfleet. The EMPIRE fears that another defeat could bring a thousand more solar systems into the rebellion, and Imperial control over the galaxy would be lost forever.\n\nTo crush the rebellion once and for all, the EMPIRE is constructing a sinister new battle station. Powerful enough to destroy an entire planet, its completion spells certain doom for the champions of freedom.'
 *
 * Hexadecimal:
 * 4974206973206120706572696f64206f6620636976696c207761727320696e207468652067616c6178792e204120627261766520616c6c69616e6365206f6620756e64657267726f756e642066726565646f6d20666967687465727320686173206368616c6c656e6765642074686520747972616e6e7920616e64206f707072657373696f6e206f662074686520617765736f6d652047414c414354494320454d504952452e0a0a537472696b696e672066726f6d206120666f7274726573732068696464656e20616d6f6e67207468652062696c6c696f6e207374617273206f66207468652067616c6178792c20726562656c2073706163657368697073206861766520776f6e20746865697220666972737420766963746f727920696e206120626174746c6520776974682074686520706f77657266756c20496d70657269616c2053746172666c6565742e2054686520454d50495245206665617273207468617420616e6f746865722064656665617420636f756c64206272696e6720612074686f7573616e64206d6f726520736f6c61722073797374656d7320696e746f2074686520726562656c6c696f6e2c20616e6420496d70657269616c20636f6e74726f6c206f766572207468652067616c61787920776f756c64206265206c6f737420666f72657665722e0a0a546f2063727573682074686520726562656c6c696f6e206f6e636520616e6420666f7220616c6c2c2074686520454d5049524520697320636f6e737472756374696e6720612073696e6973746572206e657720626174746c652073746174696f6e2e20506f77657266756c20656e6f75676820746f2064657374726f7920616e20656e7469726520706c616e65742c2069747320636f6d706c6574696f6e207370656c6c73206365727461696e20646f6f6d20666f7220746865206368616d70696f6e73206f662066726565646f6d2e
 */
.balign 32
msg:
.word 0x69207449
.word 0x20612073
.word 0x69726570
.word 0x6f20646f
.word 0x69632066
.word 0x206c6976
.word 0x73726177
.word 0x206e6920
.word 0x20656874
.word 0x616c6167
.word 0x202e7978
.word 0x72622041
.word 0x20657661
.word 0x696c6c61
.word 0x65636e61
.word 0x20666f20
.word 0x65646e75
.word 0x6f726772
.word 0x20646e75
.word 0x65657266
.word 0x206d6f64
.word 0x68676966
.word 0x73726574
.word 0x73616820
.word 0x61686320
.word 0x6e656c6c
.word 0x20646567
.word 0x20656874
.word 0x61727974
.word 0x20796e6e
.word 0x20646e61
.word 0x7270706f
.word 0x69737365
.word 0x6f206e6f
.word 0x68742066
.word 0x77612065
.word 0x6d6f7365
.word 0x41472065
.word 0x5443414c
.word 0x45204349
.word 0x5249504d
.word 0x0a0a2e45
.word 0x69727453
.word 0x676e696b
.word 0x6f726620
.word 0x2061206d
.word 0x74726f66
.word 0x73736572
.word 0x64696820
.word 0x206e6564
.word 0x6e6f6d61
.word 0x68742067
.word 0x69622065
.word 0x6f696c6c
.word 0x7473206e
.word 0x20737261
.word 0x7420666f
.word 0x67206568
.word 0x78616c61
.word 0x72202c79
.word 0x6c656265
.word 0x61707320
.word 0x68736563
.word 0x20737069
.word 0x65766168
.word 0x6e6f7720
.word 0x65687420
.word 0x66207269
.word 0x74737269
.word 0x63697620
.word 0x79726f74
.word 0x206e6920
.word 0x61622061
.word 0x656c7474
.word 0x74697720
.word 0x68742068
.word 0x6f702065
.word 0x66726577
.word 0x49206c75
.word 0x7265706d
.word 0x206c6169
.word 0x72617453
.word 0x65656c66
.word 0x54202e74
.word 0x45206568
.word 0x5249504d
.word 0x65662045
.word 0x20737261
.word 0x74616874
.word 0x6f6e6120
.word 0x72656874
.word 0x66656420
.word 0x20746165
.word 0x6c756f63
.word 0x72622064
.word 0x20676e69
.word 0x68742061
.word 0x6173756f
.word 0x6d20646e
.word 0x2065726f
.word 0x616c6f73
.word 0x79732072
.word 0x6d657473
.word 0x6e692073
.word 0x74206f74
.word 0x72206568
.word 0x6c656265
.word 0x6e6f696c
.word 0x6e61202c
.word 0x6d492064
.word 0x69726570
.word 0x63206c61
.word 0x72746e6f
.word 0x6f206c6f
.word 0x20726576
.word 0x20656874
.word 0x616c6167
.word 0x77207978
.word 0x646c756f
.word 0x20656220
.word 0x74736f6c
.word 0x726f6620
.word 0x72657665
.word 0x540a0a2e
.word 0x7263206f
.word 0x20687375
.word 0x20656874
.word 0x65626572
.word 0x6f696c6c
.word 0x6e6f206e
.word 0x61206563
.word 0x6620646e
.word 0x6120726f
.word 0x202c6c6c
.word 0x20656874
.word 0x49504d45
.word 0x69204552
.word 0x6f632073
.word 0x7274736e
.word 0x69746375
.word 0x6120676e
.word 0x6e697320
.word 0x65747369
.word 0x656e2072
.word 0x61622077
.word 0x656c7474
.word 0x61747320
.word 0x6e6f6974
.word 0x6f50202e
.word 0x66726577
.word 0x65206c75
.word 0x67756f6e
.word 0x6f742068
.word 0x73656420
.word 0x796f7274
.word 0x206e6120
.word 0x69746e65
.word 0x70206572
.word 0x656e616c
.word 0x69202c74
.word 0x63207374
.word 0x6c706d6f
.word 0x6f697465
.word 0x7073206e
.word 0x736c6c65
.word 0x72656320
.word 0x6e696174
.word 0x6f6f6420
.word 0x6f66206d
.word 0x68742072
.word 0x68632065
.word 0x69706d61
.word 0x20736e6f
.word 0x6620666f
.word 0x64656572
.word 0x002e6d6f
