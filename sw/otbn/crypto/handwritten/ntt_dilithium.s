.text

/**
 * Constant Time Dilithium NTT
 *
 * Returns: NTT(input)
 *
 * This implements the in-place NTT for Dilithium, where n=256, q=8380417.
 *
 * Flags: Flags have no meaning beyond the scope of this subroutine.
 *
 * @param[in]  x30: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x31: dptr_tw, dmem pointer to array of twiddle factors
 * @param[in]  w31: all-zero
 * @param[out] x30: dmem pointer to result
 *
 * clobbered registers: x2 to x25, x28 to x29
 *                      w2 to w25, w30
 */
.globl ntt_dilithium
ntt_dilithium:
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

    /* Load twiddle factors for layers 1--4 */
    bn.lid x18, 0(x29)
    bn.lid x19, 32(x29)
    
    LOOPI 2, 129
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

        /* Layer 1, stride 128 */

        bn.mulmv.l.8S w30, w10, w18, 0
        bn.submv.8S   w10, w2, w30
        bn.addmv.8S   w2, w2, w30
        bn.mulmv.l.8S w30, w11, w18, 0
        bn.submv.8S   w11, w3, w30
        bn.addmv.8S   w3, w3, w30
        bn.mulmv.l.8S w30, w12, w18, 0
        bn.submv.8S   w12, w4, w30
        bn.addmv.8S   w4, w4, w30
        bn.mulmv.l.8S w30, w13, w18, 0
        bn.submv.8S   w13, w5, w30
        bn.addmv.8S   w5, w5, w30
        bn.mulmv.l.8S w30, w14, w18, 0
        bn.submv.8S   w14, w6, w30
        bn.addmv.8S   w6, w6, w30
        bn.mulmv.l.8S w30, w15, w18, 0
        bn.submv.8S   w15, w7, w30
        bn.addmv.8S   w7, w7, w30
        bn.mulmv.l.8S w30, w16, w18, 0
        bn.submv.8S   w16, w8, w30
        bn.addmv.8S   w8, w8, w30
        bn.mulmv.l.8S w30, w17, w18, 0
        bn.submv.8S   w17, w9, w30
        bn.addmv.8S   w9, w9, w30
        
        /* Layer 2, stride 64 */

        bn.mulmv.l.8S w30, w6, w18, 1
        bn.submv.8S   w6, w2, w30
        bn.addmv.8S   w2, w2, w30
        bn.mulmv.l.8S w30, w7, w18, 1
        bn.submv.8S   w7, w3, w30
        bn.addmv.8S   w3, w3, w30
        bn.mulmv.l.8S w30, w8, w18, 1
        bn.submv.8S   w8, w4, w30
        bn.addmv.8S   w4, w4, w30
        bn.mulmv.l.8S w30, w9, w18, 1
        bn.submv.8S   w9, w5, w30
        bn.addmv.8S   w5, w5, w30
        bn.mulmv.l.8S w30, w14, w18, 2
        bn.submv.8S   w14, w10, w30
        bn.addmv.8S   w10, w10, w30
        bn.mulmv.l.8S w30, w15, w18, 2
        bn.submv.8S   w15, w11, w30
        bn.addmv.8S   w11, w11, w30
        bn.mulmv.l.8S w30, w16, w18, 2
        bn.submv.8S   w16, w12, w30
        bn.addmv.8S   w12, w12, w30
        bn.mulmv.l.8S w30, w17, w18, 2
        bn.submv.8S   w17, w13, w30
        bn.addmv.8S   w13, w13, w30

        /* Layer 3, stride 32 */

        bn.mulmv.l.8S w30, w4, w18, 3
        bn.submv.8S   w4, w2, w30
        bn.addmv.8S   w2, w2, w30
        bn.mulmv.l.8S w30, w5, w18, 3
        bn.submv.8S   w5, w3, w30
        bn.addmv.8S   w3, w3, w30
        bn.mulmv.l.8S w30, w8, w18, 4
        bn.submv.8S   w8, w6, w30
        bn.addmv.8S   w6, w6, w30
        bn.mulmv.l.8S w30, w9, w18, 4
        bn.submv.8S   w9, w7, w30
        bn.addmv.8S   w7, w7, w30
        bn.mulmv.l.8S w30, w12, w18, 5
        bn.submv.8S   w12, w10, w30
        bn.addmv.8S   w10, w10, w30
        bn.mulmv.l.8S w30, w13, w18, 5
        bn.submv.8S   w13, w11, w30
        bn.addmv.8S   w11, w11, w30
        bn.mulmv.l.8S w30, w16, w18, 6
        bn.submv.8S   w16, w14, w30
        bn.addmv.8S   w14, w14, w30
        bn.mulmv.l.8S w30, w17, w18, 6
        bn.submv.8S   w17, w15, w30
        bn.addmv.8S   w15, w15, w30

        /* Layer 4, stride 16 */

        bn.mulmv.l.8S w30, w3, w18, 7
        bn.submv.8S   w3, w2, w30
        bn.addmv.8S   w2, w2, w30
        bn.mulmv.l.8S w30, w5, w19, 0
        bn.submv.8S   w5, w4, w30
        bn.addmv.8S   w4, w4, w30
        bn.mulmv.l.8S w30, w7, w19, 1
        bn.submv.8S   w7, w6, w30
        bn.addmv.8S   w6, w6, w30
        bn.mulmv.l.8S w30, w9, w19, 2
        bn.submv.8S   w9, w8, w30
        bn.addmv.8S   w8, w8, w30
        bn.mulmv.l.8S w30, w11, w19, 3
        bn.submv.8S   w11, w10, w30
        bn.addmv.8S   w10, w10, w30
        bn.mulmv.l.8S w30, w13, w19, 4
        bn.submv.8S   w13, w12, w30
        bn.addmv.8S   w12, w12, w30
        bn.mulmv.l.8S w30, w15, w19, 5
        bn.submv.8S   w15, w14, w30
        bn.addmv.8S   w14, w14, w30
        bn.mulmv.l.8S w30, w17, w19, 6
        bn.submv.8S   w17, w16, w30
        bn.addmv.8S   w16, w16, w30

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
    
    /* Restore input pointer */
    addi x28, x30, 0

    /* Set the twiddle pointer for layer 5 */
    addi x29, x29, 64

    /* w18--w25 are used for the twiddle factors on layers 5--8 */
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

        /* Layer 5, stride 8 */

        /* Load twiddle factors */
        bn.lid x18, 0(x29)

        /* Butterflies */
        bn.mulmv.l.8S w30, w3, w18, 0
        bn.submv.8S   w3, w2, w30
        bn.addmv.8S   w2, w2, w30
        bn.mulmv.l.8S w30, w5, w18, 1
        bn.submv.8S   w5, w4, w30
        bn.addmv.8S   w4, w4, w30
        bn.mulmv.l.8S w30, w7, w18, 2
        bn.submv.8S   w7, w6, w30
        bn.addmv.8S   w6, w6, w30
        bn.mulmv.l.8S w30, w9, w18, 3
        bn.submv.8S   w9, w8, w30
        bn.addmv.8S   w8, w8, w30
        bn.mulmv.l.8S w30, w11, w18, 4
        bn.submv.8S   w11, w10, w30
        bn.addmv.8S   w10, w10, w30
        bn.mulmv.l.8S w30, w13, w18, 5
        bn.submv.8S   w13, w12, w30
        bn.addmv.8S   w12, w12, w30
        bn.mulmv.l.8S w30, w15, w18, 6
        bn.submv.8S   w15, w14, w30
        bn.addmv.8S   w14, w14, w30
        bn.mulmv.l.8S w30, w17, w18, 7
        bn.submv.8S   w17, w16, w30
        bn.addmv.8S   w16, w16, w30

        /* Transpose */
        bn.trans8 w2, w2
        bn.trans8 w10, w10

        /* Layer 6, stride 4 */

        /* Load twiddle factors */
        bn.lid x18, 32(x29)
        bn.lid x19, 64(x29)

        /* Butterflies */
        bn.mulmv.8S w30, w6, w18, 0
        bn.submv.8S w6, w2, w30
        bn.addmv.8S w2, w2, w30
        bn.mulmv.8S w30, w7, w18, 0
        bn.submv.8S w7, w3, w30
        bn.addmv.8S w3, w3, w30
        bn.mulmv.8S w30, w8, w18, 0
        bn.submv.8S w8, w4, w30
        bn.addmv.8S w4, w4, w30
        bn.mulmv.8S w30, w9, w18, 0
        bn.submv.8S w9, w5, w30
        bn.addmv.8S w5, w5, w30
        bn.mulmv.8S w30, w14, w19, 0
        bn.submv.8S w14, w10, w30
        bn.addmv.8S w10, w10, w30
        bn.mulmv.8S w30, w15, w19, 0
        bn.submv.8S w15, w11, w30
        bn.addmv.8S w11, w11, w30
        bn.mulmv.8S w30, w16, w19, 0
        bn.submv.8S w16, w12, w30
        bn.addmv.8S w12, w12, w30
        bn.mulmv.8S w30, w17, w19, 0
        bn.submv.8S w17, w13, w30
        bn.addmv.8S w13, w13, w30

        /* Layer 7, stride 2 */

        /* Load twiddle factors */
        bn.lid x18, 96(x29)
        bn.lid x19, 128(x29)
        bn.lid x20, 160(x29)
        bn.lid x21, 192(x29)

        /* Butterflies */
        bn.mulmv.8S w30, w4, w18, 0
        bn.submv.8S w4, w2, w30
        bn.addmv.8S w2, w2, w30
        bn.mulmv.8S w30, w5, w18, 0
        bn.submv.8S w5, w3, w30
        bn.addmv.8S w3, w3, w30
        bn.mulmv.8S w30, w8, w19, 0
        bn.submv.8S w8, w6, w30
        bn.addmv.8S w6, w6, w30
        bn.mulmv.8S w30, w9, w19, 0
        bn.submv.8S w9, w7, w30
        bn.addmv.8S w7, w7, w30
        bn.mulmv.8S w30, w12, w20, 0
        bn.submv.8S w12, w10, w30
        bn.addmv.8S w10, w10, w30
        bn.mulmv.8S w30, w13, w20, 0
        bn.submv.8S w13, w11, w30
        bn.addmv.8S w11, w11, w30
        bn.mulmv.8S w30, w16, w21, 0
        bn.submv.8S w16, w14, w30
        bn.addmv.8S w14, w14, w30
        bn.mulmv.8S w30, w17, w21, 0
        bn.submv.8S w17, w15, w30
        bn.addmv.8S w15, w15, w30

        /* Layer 8, stride 1 */

        /* Load twiddle factors */
        bn.lid x18, 224(x29)
        bn.lid x19, 256(x29)
        bn.lid x20, 288(x29)
        bn.lid x21, 320(x29)
        bn.lid x22, 352(x29)
        bn.lid x23, 384(x29)
        bn.lid x24, 416(x29)
        bn.lid x25, 448(x29)

        /* Butterflies */
        bn.mulmv.8S w30, w3, w18, 0
        bn.submv.8S w3, w2, w30
        bn.addmv.8S w2, w2, w30
        bn.mulmv.8S w30, w5, w19, 0
        bn.submv.8S w5, w4, w30
        bn.addmv.8S w4, w4, w30
        bn.mulmv.8S w30, w7, w20, 0
        bn.submv.8S w7, w6, w30
        bn.addmv.8S w6, w6, w30
        bn.mulmv.8S w30, w9, w21, 0
        bn.submv.8S w9, w8, w30
        bn.addmv.8S w8, w8, w30
        bn.mulmv.8S w30, w11, w22, 0
        bn.submv.8S w11, w10, w30
        bn.addmv.8S w10, w10, w30
        bn.mulmv.8S w30, w13, w23, 0
        bn.submv.8S w13, w12, w30
        bn.addmv.8S w12, w12, w30
        bn.mulmv.8S w30, w15, w24, 0
        bn.submv.8S w15, w14, w30
        bn.addmv.8S w14, w14, w30
        bn.mulmv.8S w30, w17, w25, 0
        bn.submv.8S w17, w16, w30
        bn.addmv.8S w16, w16, w30

        /* Transpose back */
        bn.trans8 w2, w2
        bn.trans8 w10, w10

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

    ret