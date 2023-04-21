.text

/**
 * Constant Time Dilithium NTT, first 4 layers
 *
 * Returns: NTT_4(input)
 *
 * This implements the in-place NTT on the 256 word input input.
 *
 * Flags: Flags have no meaning beyond the scope of this subroutine.
 *
 * @param[in]  x30: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x31: dptr_tw, dmem pointer to array of twiddle factors
 * @param[in]  w31: all-zero
 * @param[out] x30: dmem pointer to result
 *
 * clobbered registers: x2 to x19
 *                      w2 to w19, w30
 */
.globl ntt_dilithium_4l
ntt_dilithium_4l:
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

    /* Set up constants for input/twiddle factors */
    li x18, 18
    li x19, 19

    /* Load twiddle factors for layers 1--4 */
    bn.lid x18, 0(x31)
    bn.lid x19, 32(x31)
    
    LOOPI 2, 129
        /* Load input data */
        bn.lid x2,    0(x30)     /* a[0-4] */
        bn.lid x3,   64(x30)   /* a[16-20] */
        bn.lid x4,  128(x30)   /* a[32-36] */
        bn.lid x5,  192(x30)   /* a[48-52] */
        bn.lid x6,  256(x30)   /* a[64-68] */
        bn.lid x7,  320(x30)   /* a[80-84] */
        bn.lid x8,  384(x30)  /* a[96-100] */
        bn.lid x9,  448(x30) /* a[112-116] */
        bn.lid x10, 512(x30) /* a[128-132] */
        bn.lid x11, 576(x30) /* a[144-148] */
        bn.lid x12, 640(x30) /* a[160-164] */
        bn.lid x13, 704(x30) /* a[176-180] */
        bn.lid x14, 768(x30) /* a[192-196] */
        bn.lid x15, 832(x30) /* a[208-212] */
        bn.lid x16, 896(x30) /* a[224-228] */
        bn.lid x17, 960(x30) /* a[240-244] */

        /* Layer 1, stride 128 */
        bn.mulmv.l.8S w30, w10, w18, 0
        bn.submv.8S w10, w2, w30
        bn.addmv.8S w2, w2, w30
        bn.mulmv.l.8S w30, w11, w18, 0
        bn.submv.8S w11, w3, w30
        bn.addmv.8S w3, w3, w30
        bn.mulmv.l.8S w30, w12, w18, 0
        bn.submv.8S w12, w4, w30
        bn.addmv.8S w4, w4, w30
        bn.mulmv.l.8S w30, w13, w18, 0
        bn.submv.8S w13, w5, w30
        bn.addmv.8S w5, w5, w30
        bn.mulmv.l.8S w30, w14, w18, 0
        bn.submv.8S w14, w6, w30
        bn.addmv.8S w6, w6, w30
        bn.mulmv.l.8S w30, w15, w18, 0
        bn.submv.8S w15, w7, w30
        bn.addmv.8S w7, w7, w30
        bn.mulmv.l.8S w30, w16, w18, 0
        bn.submv.8S w16, w8, w30
        bn.addmv.8S w8, w8, w30
        bn.mulmv.l.8S w30, w17, w18, 0
        bn.submv.8S w17, w9, w30
        bn.addmv.8S w9, w9, w30
        
        /* Layer 2, stride 64 */
        bn.mulmv.l.8S w30, w6, w18, 1
        bn.submv.8S w6, w2, w30
        bn.addmv.8S w2, w2, w30
        bn.mulmv.l.8S w30, w7, w18, 1
        bn.submv.8S w7, w3, w30
        bn.addmv.8S w3, w3, w30
        bn.mulmv.l.8S w30, w8, w18, 1
        bn.submv.8S w8, w4, w30
        bn.addmv.8S w4, w4, w30
        bn.mulmv.l.8S w30, w9, w18, 1
        bn.submv.8S w9, w5, w30
        bn.addmv.8S w5, w5, w30
        bn.mulmv.l.8S w30, w14, w18, 2
        bn.submv.8S w14, w10, w30
        bn.addmv.8S w10, w10, w30
        bn.mulmv.l.8S w30, w15, w18, 2
        bn.submv.8S w15, w11, w30
        bn.addmv.8S w11, w11, w30
        bn.mulmv.l.8S w30, w16, w18, 2
        bn.submv.8S w16, w12, w30
        bn.addmv.8S w12, w12, w30
        bn.mulmv.l.8S w30, w17, w18, 2
        bn.submv.8S w17, w13, w30
        bn.addmv.8S w13, w13, w30

        /* Layer 3 */
        bn.mulmv.l.8S w30, w4, w18, 3
        bn.submv.8S w4, w2, w30
        bn.addmv.8S w2, w2, w30
        bn.mulmv.l.8S w30, w5, w18, 3
        bn.submv.8S w5, w3, w30
        bn.addmv.8S w3, w3, w30
        bn.mulmv.l.8S w30, w8, w18, 4
        bn.submv.8S w8, w6, w30
        bn.addmv.8S w6, w6, w30
        bn.mulmv.l.8S w30, w9, w18, 4
        bn.submv.8S w9, w7, w30
        bn.addmv.8S w7, w7, w30
        bn.mulmv.l.8S w30, w12, w18, 5
        bn.submv.8S w12, w10, w30
        bn.addmv.8S w10, w10, w30
        bn.mulmv.l.8S w30, w13, w18, 5
        bn.submv.8S w13, w11, w30
        bn.addmv.8S w11, w11, w30
        bn.mulmv.l.8S w30, w16, w18, 6
        bn.submv.8S w16, w14, w30
        bn.addmv.8S w14, w14, w30
        bn.mulmv.l.8S w30, w17, w18, 6
        bn.submv.8S w17, w15, w30
        bn.addmv.8S w15, w15, w30

        /* Layer 4 */
        bn.mulmv.l.8S w30, w3, w18, 7
        bn.submv.8S w3, w2, w30
        bn.addmv.8S w2, w2, w30
        bn.mulmv.l.8S w30, w5, w19, 0
        bn.submv.8S w5, w4, w30
        bn.addmv.8S w4, w4, w30
        bn.mulmv.l.8S w30, w7, w19, 1
        bn.submv.8S w7, w6, w30
        bn.addmv.8S w6, w6, w30
        bn.mulmv.l.8S w30, w9, w19, 2
        bn.submv.8S w9, w8, w30
        bn.addmv.8S w8, w8, w30
        bn.mulmv.l.8S w30, w11, w19, 3
        bn.submv.8S w11, w10, w30
        bn.addmv.8S w10, w10, w30
        bn.mulmv.l.8S w30, w13, w19, 4
        bn.submv.8S w13, w12, w30
        bn.addmv.8S w12, w12, w30
        bn.mulmv.l.8S w30, w15, w19, 5
        bn.submv.8S w15, w14, w30
        bn.addmv.8S w14, w14, w30
        bn.mulmv.l.8S w30, w17, w19, 6
        bn.submv.8S w17, w16, w30
        bn.addmv.8S w16, w16, w30

        /* Store output data */
        bn.sid x2,    0(x30)
        bn.sid x3,   64(x30)
        bn.sid x4,  128(x30)
        bn.sid x5,  192(x30)
        bn.sid x6,  256(x30)
        bn.sid x7,  320(x30)
        bn.sid x8,  384(x30)
        bn.sid x9,  448(x30)
        bn.sid x10, 512(x30)
        bn.sid x11, 576(x30)
        bn.sid x12, 640(x30)
        bn.sid x13, 704(x30)
        bn.sid x14, 768(x30)
        bn.sid x15, 832(x30)
        bn.sid x16, 896(x30)
        bn.sid x17, 960(x30)
        
        addi x30, x30, 32

    ret