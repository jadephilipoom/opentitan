.text

/**
 * Constant Time Dilithium inverse NTT
 *
 * Returns: INTT(input)
 *
 * This implements the in-place INTT for Dilithium, where n=256, q=8380417.
 *
 * Flags: Flags have no meaning beyond the scope of this subroutine.
 *
 * @param[in]  x30: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x31: dptr_tw, dmem pointer to array of twiddle factors,
                    last element is n^{-1} mod q
 * @param[in]  w31: all-zero
 * @param[out] x30: dmem pointer to result
 *
 * clobbered registers: x2 to x25, x28 to x29
 *                      w2 to w25, w30
 */
.globl intt_dilithium
intt_dilithium:
    /* Set up constants for input/state */
    li x2, 2
    li x3, 3
    li x4, 4
    li x5, 5
    li x6, 6
    li x7, 7
    li x8, 8
    li x9, 9
    li x10, 10
    li x11, 11
    li x12, 12
    li x13, 13
    li x14, 14
    li x15, 15
    li x16, 16
    li x17, 17

    /* Copy input pointers */
    addi x28, x30, 0
    addi x29, x31, 0

    /* Set up constants for input/twiddle factors */
    li x18, 18
    li x19, 19
    li x20, 20
    li x21, 21
    li x22, 22
    li x23, 23
    li x24, 24
    li x25, 25

    LOOPI 2, 149
        /* Load input data */
        bn.lid x2, 0(x28)
        bn.lid x3, 32(x28)
        bn.lid x4, 64(x28)
        bn.lid x5, 96(x28)
        bn.lid x6, 128(x28)
        bn.lid x7, 160(x28)
        bn.lid x8, 192(x28)
        bn.lid x9, 224(x28)
        bn.lid x10, 256(x28)
        bn.lid x11, 288(x28)
        bn.lid x12, 320(x28)
        bn.lid x13, 352(x28)
        bn.lid x14, 384(x28)
        bn.lid x15, 416(x28)
        bn.lid x16, 448(x28)
        bn.lid x17, 480(x28)

        /* Transpose */
        bn.trans8 w2, w2
        bn.trans8 w10, w10

        /* Reverse Layer 8, stride 1 */

        /* Load twiddle factors */
        bn.lid x18, 0(x29)
        bn.lid x19, 32(x29)
        bn.lid x20, 64(x29)
        bn.lid x21, 96(x29)
        bn.lid x22, 128(x29)
        bn.lid x23, 160(x29)
        bn.lid x24, 192(x29)
        bn.lid x25, 224(x29)

        /* Butterflies */
        bn.submv.8S w30, w2, w3
        bn.addmv.8S w2, w2, w3
        bn.mulmv.8S w3, w30, w18, 0
        bn.submv.8S w30, w4, w5
        bn.addmv.8S w4, w4, w5
        bn.mulmv.8S w5, w30, w19, 0
        bn.submv.8S w30, w6, w7
        bn.addmv.8S w6, w6, w7
        bn.mulmv.8S w7, w30, w20, 0
        bn.submv.8S w30, w8, w9
        bn.addmv.8S w8, w8, w9
        bn.mulmv.8S w9, w30, w21, 0
        bn.submv.8S w30, w10, w11
        bn.addmv.8S w10, w10, w11
        bn.mulmv.8S w11, w30, w22, 0
        bn.submv.8S w30, w12, w13
        bn.addmv.8S w12, w12, w13
        bn.mulmv.8S w13, w30, w23, 0
        bn.submv.8S w30, w14, w15
        bn.addmv.8S w14, w14, w15
        bn.mulmv.8S w15, w30, w24, 0
        bn.submv.8S w30, w16, w17
        bn.addmv.8S w16, w16, w17
        bn.mulmv.8S w17, w30, w25, 0

        /* Reverse Layer 7, stride 2 */

        /* Load twiddle factors */
        bn.lid x18, 256(x29)
        bn.lid x19, 288(x29)
        bn.lid x20, 320(x29)
        bn.lid x21, 352(x29)

        /* Butterflies */
        bn.submv.8S w30, w2, w4
        bn.addmv.8S w2, w2, w4
        bn.mulmv.8S w4, w30, w18, 0
        bn.submv.8S w30, w3, w5
        bn.addmv.8S w3, w3, w5
        bn.mulmv.8S w5, w30, w18, 0
        bn.submv.8S w30, w6, w8
        bn.addmv.8S w6, w6, w8
        bn.mulmv.8S w8, w30, w19, 0
        bn.submv.8S w30, w7, w9
        bn.addmv.8S w7, w7, w9
        bn.mulmv.8S w9, w30, w19, 0
        bn.submv.8S w30, w10, w12
        bn.addmv.8S w10, w10, w12
        bn.mulmv.8S w12, w30, w20, 0
        bn.submv.8S w30, w11, w13
        bn.addmv.8S w11, w11, w13
        bn.mulmv.8S w13, w30, w20, 0
        bn.submv.8S w30, w14, w16
        bn.addmv.8S w14, w14, w16
        bn.mulmv.8S w16, w30, w21, 0
        bn.submv.8S w30, w15, w17
        bn.addmv.8S w15, w15, w17
        bn.mulmv.8S w17, w30, w21, 0

        /* Reverse Layer 6, stride 4 */

        /* Load twiddle factors */
        bn.lid x18, 384(x29)
        bn.lid x19, 416(x29)

        /* Butterflies */
        bn.submv.8S w30, w2, w6
        bn.addmv.8S w2, w2, w6
        bn.mulmv.8S w6, w30, w18, 0
        bn.submv.8S w30, w3, w7
        bn.addmv.8S w3, w3, w7
        bn.mulmv.8S w7, w30, w18, 0
        bn.submv.8S w30, w4, w8
        bn.addmv.8S w4, w4, w8
        bn.mulmv.8S w8, w30, w18, 0
        bn.submv.8S w30, w5, w9
        bn.addmv.8S w5, w5, w9
        bn.mulmv.8S w9, w30, w18, 0
        bn.submv.8S w30, w10, w14
        bn.addmv.8S w10, w10, w14
        bn.mulmv.8S w14, w30, w19, 0
        bn.submv.8S w30, w11, w15
        bn.addmv.8S w11, w11, w15
        bn.mulmv.8S w15, w30, w19, 0
        bn.submv.8S w30, w12, w16
        bn.addmv.8S w12, w12, w16
        bn.mulmv.8S w16, w30, w19, 0
        bn.submv.8S w30, w13, w17
        bn.addmv.8S w13, w13, w17
        bn.mulmv.8S w17, w30, w19, 0

        /* Transpose */
        bn.trans8 w2, w2
        bn.trans8 w10, w10

        /* Reverse Layer 5, stride 8 */

        /* Load twiddle factors */
        bn.lid x18, 448(x29)
        
        /* Butterflies */
        bn.submv.8S   w30, w2, w3
        bn.addmv.8S   w2, w2, w3
        bn.mulmv.l.8S w3, w30, w18, 0
        bn.submv.8S   w30, w4, w5
        bn.addmv.8S   w4, w4, w5
        bn.mulmv.l.8S w5, w30, w18, 1
        bn.submv.8S   w30, w6, w7
        bn.addmv.8S   w6, w6, w7
        bn.mulmv.l.8S w7, w30, w18, 2
        bn.submv.8S   w30, w8, w9
        bn.addmv.8S   w8, w8, w9
        bn.mulmv.l.8S w9, w30, w18, 3
        bn.submv.8S   w30, w10, w11
        bn.addmv.8S   w10, w10, w11
        bn.mulmv.l.8S w11, w30, w18, 4
        bn.submv.8S   w30, w12, w13
        bn.addmv.8S   w12, w12, w13
        bn.mulmv.l.8S w13, w30, w18, 5
        bn.submv.8S   w30, w14, w15
        bn.addmv.8S   w14, w14, w15
        bn.mulmv.l.8S w15, w30, w18, 6
        bn.submv.8S   w30, w16, w17
        bn.addmv.8S   w16, w16, w17
        bn.mulmv.l.8S w17, w30, w18, 7

        bn.sid x2, 0(x28)
        bn.sid x3, 32(x28)
        bn.sid x4, 64(x28)
        bn.sid x5, 96(x28)
        bn.sid x6, 128(x28)
        bn.sid x7, 160(x28)
        bn.sid x8, 192(x28)
        bn.sid x9, 224(x28)
        bn.sid x10, 256(x28)
        bn.sid x11, 288(x28)
        bn.sid x12, 320(x28)
        bn.sid x13, 352(x28)
        bn.sid x14, 384(x28)
        bn.sid x15, 416(x28)
        bn.sid x16, 448(x28)
        bn.sid x17, 480(x28)

        addi x29, x29, 480
        addi x28, x28, 512

    /* Restore input pointer */
    addi x28, x30, 0

    /* Load twiddle factors for layers 1--4 */
    bn.lid x18, 0(x29)
    bn.lid x19, 32(x29)

    LOOPI 2, 137
        /* Load input data */
        bn.lid x2, 0(x28)
        bn.lid x3, 64(x28)
        bn.lid x4, 128(x28)
        bn.lid x5, 192(x28)
        bn.lid x6, 256(x28)
        bn.lid x7, 320(x28)
        bn.lid x8, 384(x28)
        bn.lid x9, 448(x28)
        bn.lid x10, 512(x28)
        bn.lid x11, 576(x28)
        bn.lid x12, 640(x28)
        bn.lid x13, 704(x28)
        bn.lid x14, 768(x28)
        bn.lid x15, 832(x28)
        bn.lid x16, 896(x28)
        bn.lid x17, 960(x28)

        /* Reverse Layer 4, stride 16 */
        bn.submv.8S   w30, w2, w3
        bn.addmv.8S   w2, w2, w3
        bn.mulmv.l.8S w3, w30, w18, 0
        bn.submv.8S   w30, w4, w5
        bn.addmv.8S   w4, w4, w5
        bn.mulmv.l.8S w5, w30, w18, 1
        bn.submv.8S   w30, w6, w7
        bn.addmv.8S   w6, w6, w7
        bn.mulmv.l.8S w7, w30, w18, 2
        bn.submv.8S   w30, w8, w9
        bn.addmv.8S   w8, w8, w9
        bn.mulmv.l.8S w9, w30, w18, 3
        bn.submv.8S   w30, w10, w11
        bn.addmv.8S   w10, w10, w11
        bn.mulmv.l.8S w11, w30, w18, 4
        bn.submv.8S   w30, w12, w13
        bn.addmv.8S   w12, w12, w13
        bn.mulmv.l.8S w13, w30, w18, 5
        bn.submv.8S   w30, w14, w15
        bn.addmv.8S   w14, w14, w15
        bn.mulmv.l.8S w15, w30, w18, 6
        bn.submv.8S   w30, w16, w17
        bn.addmv.8S   w16, w16, w17
        bn.mulmv.l.8S w17, w30, w18, 7

        /* Layer 3 */
        bn.submv.8S   w30, w2, w4
        bn.addmv.8S   w2, w2, w4
        bn.mulmv.l.8S w4, w30, w19, 0
        bn.submv.8S   w30, w3, w5
        bn.addmv.8S   w3, w3, w5
        bn.mulmv.l.8S w5, w30, w19, 0
        bn.submv.8S   w30, w6, w8
        bn.addmv.8S   w6, w6, w8
        bn.mulmv.l.8S w8, w30, w19, 1
        bn.submv.8S   w30, w7, w9
        bn.addmv.8S   w7, w7, w9
        bn.mulmv.l.8S w9, w30, w19, 1
        bn.submv.8S   w30, w10, w12
        bn.addmv.8S   w10, w10, w12
        bn.mulmv.l.8S w12, w30, w19, 2
        bn.submv.8S   w30, w11, w13
        bn.addmv.8S   w11, w11, w13
        bn.mulmv.l.8S w13, w30, w19, 2
        bn.submv.8S   w30, w14, w16
        bn.addmv.8S   w14, w14, w16
        bn.mulmv.l.8S w16, w30, w19, 3
        bn.submv.8S   w30, w15, w17
        bn.addmv.8S   w15, w15, w17
        bn.mulmv.l.8S w17, w30, w19, 3

        /* Layer 2 */
        bn.submv.8S   w30, w2, w6
        bn.addmv.8S   w2, w2, w6
        bn.mulmv.l.8S w6, w30, w19, 4
        bn.submv.8S   w30, w3, w7
        bn.addmv.8S   w3, w3, w7
        bn.mulmv.l.8S w7, w30, w19, 4
        bn.submv.8S   w30, w4, w8
        bn.addmv.8S   w4, w4, w8
        bn.mulmv.l.8S w8, w30, w19, 4
        bn.submv.8S   w30, w5, w9
        bn.addmv.8S   w5, w5, w9
        bn.mulmv.l.8S w9, w30, w19, 4
        bn.submv.8S   w30, w10, w14
        bn.addmv.8S   w10, w10, w14
        bn.mulmv.l.8S w14, w30, w19, 5
        bn.submv.8S   w30, w11, w15
        bn.addmv.8S   w11, w11, w15
        bn.mulmv.l.8S w15, w30, w19, 5
        bn.submv.8S   w30, w12, w16
        bn.addmv.8S   w12, w12, w16
        bn.mulmv.l.8S w16, w30, w19, 5
        bn.submv.8S   w30, w13, w17
        bn.addmv.8S   w13, w13, w17
        bn.mulmv.l.8S w17, w30, w19, 5

        /* Layer 1 */
        bn.submv.8S   w30, w2, w10
        bn.addmv.8S   w2, w2, w10
        bn.mulmv.l.8S w10, w30, w19, 6
        bn.submv.8S   w30, w3, w11
        bn.addmv.8S   w3, w3, w11
        bn.mulmv.l.8S w11, w30, w19, 6
        bn.submv.8S   w30, w4, w12
        bn.addmv.8S   w4, w4, w12
        bn.mulmv.l.8S w12, w30, w19, 6
        bn.submv.8S   w30, w5, w13
        bn.addmv.8S   w5, w5, w13
        bn.mulmv.l.8S w13, w30, w19, 6
        bn.submv.8S   w30, w6, w14
        bn.addmv.8S   w6, w6, w14
        bn.mulmv.l.8S w14, w30, w19, 6
        bn.submv.8S   w30, w7, w15
        bn.addmv.8S   w7, w7, w15
        bn.mulmv.l.8S w15, w30, w19, 6
        bn.submv.8S   w30, w8, w16
        bn.addmv.8S   w8, w8, w16
        bn.mulmv.l.8S w16, w30, w19, 6
        bn.submv.8S   w30, w9, w17
        bn.addmv.8S   w9, w9, w17
        bn.mulmv.l.8S w17, w30, w19, 6

        /* Multiply n^{-1} */
        bn.mulmv.l.8S w2, w2, w19, 7
        bn.mulmv.l.8S w3, w3, w19, 7
        bn.mulmv.l.8S w4, w4, w19, 7
        bn.mulmv.l.8S w5, w5, w19, 7
        bn.mulmv.l.8S w6, w6, w19, 7
        bn.mulmv.l.8S w7, w7, w19, 7
        bn.mulmv.l.8S w8, w8, w19, 7
        bn.mulmv.l.8S w9, w9, w19, 7

        /* Store output data */
        bn.sid x2,  0(x28)
        bn.sid x3, 64(x28)
        bn.sid x4, 128(x28)
        bn.sid x5, 192(x28)
        bn.sid x6, 256(x28)
        bn.sid x7, 320(x28)
        bn.sid x8, 384(x28)
        bn.sid x9, 448(x28)
        bn.sid x10, 512(x28)
        bn.sid x11, 576(x28)
        bn.sid x12, 640(x28)
        bn.sid x13, 704(x28)
        bn.sid x14, 768(x28)
        bn.sid x15, 832(x28)
        bn.sid x16, 896(x28)
        bn.sid x17, 960(x28)
        
        addi x28, x28, 32
    ret