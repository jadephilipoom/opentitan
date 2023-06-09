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
 * @param[in]  x10: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x11: dptr_tw, dmem pointer to array of twiddle factors,
                    last element is n^{-1} mod q
 * @param[in]  w31: all-zero
 * @param[out] x10: dmem pointer to result
 *
 * clobbered registers: x4 to x30
 *                      w2 to w25, w30
 */
.globl intt_dilithium
intt_dilithium:
    /* Set up constants for input/state */
    li x4, 2 /* x2 */
    li x5, 3 /* x3 */
    li x6, 4 /* x4 */
    li x7, 5 /* x5 */
    li x8, 6 /* x6 */
    li x9, 7 /* x7 */
    li x13, 8 /* x8 */
    li x14, 9 /* x9 */
    li x15, 10 /* x10 */
    li x16, 11 /* x11 */
    li x17, 12 /* x12 */
    li x18, 13 /* x13 */
    li x19, 14 /* x14 */
    li x20, 15 /* x15 */
    li x21, 16 /* x16 */
    li x22, 17 /* x17 */

    /* Set up constants for input/twiddle factors */
    li x23, 18 /* x18 */
    li x24, 19 /* x19 */
    li x25, 20 /* x20 */
    li x26, 21 /* x21 */
    li x27, 22 /* x22 */
    li x28, 23 /* x23 */
    li x29, 24 /* x24 */
    li x30, 25 /* x25 */

    LOOPI 2, 149
        /* Load input data */
        bn.lid x4, 0(x10)
        bn.lid x5, 32(x10)
        bn.lid x6, 64(x10)
        bn.lid x7, 96(x10)
        bn.lid x8, 128(x10)
        bn.lid x9, 160(x10)
        bn.lid x13, 192(x10)
        bn.lid x14, 224(x10)
        bn.lid x15, 256(x10)
        bn.lid x16, 288(x10)
        bn.lid x17, 320(x10)
        bn.lid x18, 352(x10)
        bn.lid x19, 384(x10)
        bn.lid x20, 416(x10)
        bn.lid x21, 448(x10)
        bn.lid x22, 480(x10)

        /* Transpose */
        bn.trans8 w2, w2
        bn.trans8 w10, w10

        /* Reverse Layer 8, stride 1 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11)
        bn.lid x24, 32(x11)
        bn.lid x25, 64(x11)
        bn.lid x26, 96(x11)
        bn.lid x27, 128(x11)
        bn.lid x28, 160(x11)
        bn.lid x29, 192(x11)
        bn.lid x30, 224(x11)

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
        bn.lid x23, 256(x11)
        bn.lid x24, 288(x11)
        bn.lid x25, 320(x11)
        bn.lid x26, 352(x11)

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
        bn.lid x23, 384(x11)
        bn.lid x24, 416(x11)

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
        bn.lid x23, 448(x11)
        
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

        bn.sid x4, 0(x10)
        bn.sid x5, 32(x10)
        bn.sid x6, 64(x10)
        bn.sid x7, 96(x10)
        bn.sid x8, 128(x10)
        bn.sid x9, 160(x10)
        bn.sid x13, 192(x10)
        bn.sid x14, 224(x10)
        bn.sid x15, 256(x10)
        bn.sid x16, 288(x10)
        bn.sid x17, 320(x10)
        bn.sid x18, 352(x10)
        bn.sid x19, 384(x10)
        bn.sid x20, 416(x10)
        bn.sid x21, 448(x10)
        bn.sid x22, 480(x10)

        addi x11, x11, 480
        addi x10, x10, 512

    /* Restore input pointer */
    addi x10, x10, -1024

    /* Load twiddle factors for layers 1--4 */
    bn.lid x23, 0(x11)
    bn.lid x24, 32(x11)

    LOOPI 2, 137
        /* Load input data */
        bn.lid x4, 0(x10)
        bn.lid x5, 64(x10)
        bn.lid x6, 128(x10)
        bn.lid x7, 192(x10)
        bn.lid x8, 256(x10)
        bn.lid x9, 320(x10)
        bn.lid x13, 384(x10)
        bn.lid x14, 448(x10)
        bn.lid x15, 512(x10)
        bn.lid x16, 576(x10)
        bn.lid x17, 640(x10)
        bn.lid x18, 704(x10)
        bn.lid x19, 768(x10)
        bn.lid x20, 832(x10)
        bn.lid x21, 896(x10)
        bn.lid x22, 960(x10)

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
        bn.sid x4,  0(x10)
        bn.sid x5, 64(x10)
        bn.sid x6, 128(x10)
        bn.sid x7, 192(x10)
        bn.sid x8, 256(x10)
        bn.sid x9, 320(x10)
        bn.sid x13, 384(x10)
        bn.sid x14, 448(x10)
        bn.sid x15, 512(x10)
        bn.sid x16, 576(x10)
        bn.sid x17, 640(x10)
        bn.sid x18, 704(x10)
        bn.sid x19, 768(x10)
        bn.sid x20, 832(x10)
        bn.sid x21, 896(x10)
        bn.sid x22, 960(x10)
        
        addi x10, x10, 32

    addi x10, x10, -64
    ret