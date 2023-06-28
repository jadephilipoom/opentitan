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
 * @param[in]  x10: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x11: dptr_tw, dmem pointer to array of twiddle factors
 * @param[in]  w31: all-zero
 * @param[out] x12: dmem pointer to result
 *
 * clobbered registers: x4 to x30, x28 to x29
 *                      w2 to w25, w30
 */
.globl ntt_dilithium
ntt_dilithium:
    /* Set up constants for input/state */
    li x4, 2
    li x5, 3
    li x6, 4
    li x7, 5
    li x8, 6
    li x9, 7
    li x13, 8
    li x14, 9
    li x15, 10
    li x16, 11
    li x17, 12
    li x18, 13
    li x19, 14
    li x20, 15
    li x21, 16
    li x22, 17

    /* Set up constants for input/twiddle factors */
    li x23, 18
    li x24, 19
    li x25, 20
    li x26, 21
    li x31, 22
    li x28, 23
    li x29, 24
    li x30, 25

    /* Load twiddle factors for layers 1--4 */
    bn.lid x23, 0(x11)
    bn.lid x24, 32(x11)
    
    LOOPI 2, 130
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
        bn.sid x4,  0(x12)
        bn.sid x5, 64(x12)
        bn.sid x6, 128(x12)
        bn.sid x7, 192(x12)
        bn.sid x8, 256(x12)
        bn.sid x9, 320(x12)
        bn.sid x13, 384(x12)
        bn.sid x14, 448(x12)
        bn.sid x15, 512(x12)
        bn.sid x16, 576(x12)
        bn.sid x17, 640(x12)
        bn.sid x18, 704(x12)
        bn.sid x19, 768(x12)
        bn.sid x20, 832(x12)
        bn.sid x21, 896(x12)
        bn.sid x22, 960(x12)
        
        addi x10, x10, 32
        addi x12, x12, 32
    
    /* Restore input pointer */
    addi x10, x10, -64
    /* Restore output pointer */
    addi x12, x12, -64

    /* Set the twiddle pointer for layer 5 */
    addi x11, x11, 64

    /* w18--w25 are used for the twiddle factors on layers 5--8 */
    LOOPI 2, 150
        /* Load input data */
        bn.lid x4, 0(x12)
        bn.lid x5, 32(x12)
        bn.lid x6, 64(x12)
        bn.lid x7, 96(x12)
        bn.lid x8, 128(x12)
        bn.lid x9, 160(x12)
        bn.lid x13, 192(x12)
        bn.lid x14, 224(x12)
        bn.lid x15, 256(x12)
        bn.lid x16, 288(x12)
        bn.lid x17, 320(x12)
        bn.lid x18, 352(x12)
        bn.lid x19, 384(x12)
        bn.lid x20, 416(x12)
        bn.lid x21, 448(x12)
        bn.lid x22, 480(x12)

        /* Layer 5, stride 8 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11)

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
        bn.lid x23, 32(x11)
        bn.lid x24, 64(x11)

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
        bn.lid x23, 96(x11)
        bn.lid x24, 128(x11)
        bn.lid x25, 160(x11)
        bn.lid x26, 192(x11)

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
        bn.lid x23, 224(x11)
        bn.lid x24, 256(x11)
        bn.lid x25, 288(x11)
        bn.lid x26, 320(x11)
        bn.lid x31, 352(x11)
        bn.lid x28, 384(x11)
        bn.lid x29, 416(x11)
        bn.lid x30, 448(x11)

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

        bn.sid x4, 0(x12)
        bn.sid x5, 32(x12)
        bn.sid x6, 64(x12)
        bn.sid x7, 96(x12)
        bn.sid x8, 128(x12)
        bn.sid x9, 160(x12)
        bn.sid x13, 192(x12)
        bn.sid x14, 224(x12)
        bn.sid x15, 256(x12)
        bn.sid x16, 288(x12)
        bn.sid x17, 320(x12)
        bn.sid x18, 352(x12)
        bn.sid x19, 384(x12)
        bn.sid x20, 416(x12)
        bn.sid x21, 448(x12)
        bn.sid x22, 480(x12)

        addi x11, x11, 480
        addi x10, x10, 512
        addi x12, x12, 512

    ret