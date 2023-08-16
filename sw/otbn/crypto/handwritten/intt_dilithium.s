.text
/* Macros */
.macro push reg
    addi sp, sp, -4      /* Decrement stack pointer by 4 bytes */
    sw \reg, 0(sp)      /* Store register value at the top of the stack */
.endm

.macro pop reg
    lw \reg, 0(sp)      /* Load value from the top of the stack into register */
    addi sp, sp, 4     /* Increment stack pointer by 4 bytes */
.endm

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

    /* Save callee-saved registers */
    .irp reg,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11
        push \reg
    .endr

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

    LOOPI 2, 207
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
        /* bn.trans8 w2, w2 */
        bn.trans.8S w23, w2, 0
        bn.trans.8S w23, w3, 1
        bn.trans.8S w23, w4, 2
        bn.trans.8S w23, w5, 3
        bn.trans.8S w23, w6, 4
        bn.trans.8S w23, w7, 5
        bn.trans.8S w23, w8, 6
        bn.trans.8S w23, w9, 7
        bn.addi w2, w23, 0
        bn.addi w3, w24, 0
        bn.addi w4, w25, 0
        bn.addi w5, w26, 0
        bn.addi w6, w27, 0
        bn.addi w7, w28, 0
        bn.addi w8, w29, 0
        bn.addi w9, w30, 0
        
        /* bn.trans8 w10, w10 */
        bn.trans.8S w23, w10, 0
        bn.trans.8S w23, w11, 1
        bn.trans.8S w23, w12, 2
        bn.trans.8S w23, w13, 3
        bn.trans.8S w23, w14, 4
        bn.trans.8S w23, w15, 5
        bn.trans.8S w23, w16, 6
        bn.trans.8S w23, w17, 7
        bn.addi w10, w23, 0
        bn.addi w11, w24, 0
        bn.addi w12, w25, 0
        bn.addi w13, w26, 0
        bn.addi w14, w27, 0
        bn.addi w15, w28, 0
        bn.addi w16, w29, 0
        bn.addi w17, w30, 0

        /* Reverse Layer 8, stride 1 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11++)
        bn.lid x24, 0(x11++)
        bn.lid x25, 0(x11++)
        bn.lid x26, 0(x11++)
        bn.lid x31, 0(x11++)
        bn.lid x28, 0(x11++)
        bn.lid x29, 0(x11++)
        bn.lid x30, 0(x11++)

        /* Butterflies */
        bn.subvm.8S w30, w2, w3
        bn.addvm.8S w2, w2, w3
        bn.mulvm.8S w3, w30, w18
        bn.subvm.8S w30, w4, w5
        bn.addvm.8S w4, w4, w5
        bn.mulvm.8S w5, w30, w19
        bn.subvm.8S w30, w6, w7
        bn.addvm.8S w6, w6, w7
        bn.mulvm.8S w7, w30, w20
        bn.subvm.8S w30, w8, w9
        bn.addvm.8S w8, w8, w9
        bn.mulvm.8S w9, w30, w21
        bn.subvm.8S w30, w10, w11
        bn.addvm.8S w10, w10, w11
        bn.mulvm.8S w11, w30, w22
        bn.subvm.8S w30, w12, w13
        bn.addvm.8S w12, w12, w13
        bn.mulvm.8S w13, w30, w23
        bn.subvm.8S w30, w14, w15
        bn.addvm.8S w14, w14, w15
        bn.mulvm.8S w15, w30, w24
        bn.subvm.8S w30, w16, w17
        bn.addvm.8S w16, w16, w17
        bn.mulvm.8S w17, w30, w25

        /* Reverse Layer 7, stride 2 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11++)
        bn.lid x24, 0(x11++)
        bn.lid x25, 0(x11++)
        bn.lid x26, 0(x11++)

        /* Butterflies */
        bn.subvm.8S w30, w2, w4
        bn.addvm.8S w2, w2, w4
        bn.mulvm.8S w4, w30, w18
        bn.subvm.8S w30, w3, w5
        bn.addvm.8S w3, w3, w5
        bn.mulvm.8S w5, w30, w18
        bn.subvm.8S w30, w6, w8
        bn.addvm.8S w6, w6, w8
        bn.mulvm.8S w8, w30, w19
        bn.subvm.8S w30, w7, w9
        bn.addvm.8S w7, w7, w9
        bn.mulvm.8S w9, w30, w19
        bn.subvm.8S w30, w10, w12
        bn.addvm.8S w10, w10, w12
        bn.mulvm.8S w12, w30, w20
        bn.subvm.8S w30, w11, w13
        bn.addvm.8S w11, w11, w13
        bn.mulvm.8S w13, w30, w20
        bn.subvm.8S w30, w14, w16
        bn.addvm.8S w14, w14, w16
        bn.mulvm.8S w16, w30, w21
        bn.subvm.8S w30, w15, w17
        bn.addvm.8S w15, w15, w17
        bn.mulvm.8S w17, w30, w21

        /* Reverse Layer 6, stride 4 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11++)
        bn.lid x24, 0(x11++)

        /* Butterflies */
        bn.subvm.8S w30, w2, w6
        bn.addvm.8S w2, w2, w6
        bn.mulvm.8S w6, w30, w18
        bn.subvm.8S w30, w3, w7
        bn.addvm.8S w3, w3, w7
        bn.mulvm.8S w7, w30, w18
        bn.subvm.8S w30, w4, w8
        bn.addvm.8S w4, w4, w8
        bn.mulvm.8S w8, w30, w18
        bn.subvm.8S w30, w5, w9
        bn.addvm.8S w5, w5, w9
        bn.mulvm.8S w9, w30, w18
        bn.subvm.8S w30, w10, w14
        bn.addvm.8S w10, w10, w14
        bn.mulvm.8S w14, w30, w19
        bn.subvm.8S w30, w11, w15
        bn.addvm.8S w11, w11, w15
        bn.mulvm.8S w15, w30, w19
        bn.subvm.8S w30, w12, w16
        bn.addvm.8S w12, w12, w16
        bn.mulvm.8S w16, w30, w19
        bn.subvm.8S w30, w13, w17
        bn.addvm.8S w13, w13, w17
        bn.mulvm.8S w17, w30, w19

        /* Transpose */
        /* bn.trans8 w2, w2 */
        bn.trans.8S w23, w2, 0
        bn.trans.8S w23, w3, 1
        bn.trans.8S w23, w4, 2
        bn.trans.8S w23, w5, 3
        bn.trans.8S w23, w6, 4
        bn.trans.8S w23, w7, 5
        bn.trans.8S w23, w8, 6
        bn.trans.8S w23, w9, 7
        bn.addi w2, w23, 0
        bn.addi w3, w24, 0
        bn.addi w4, w25, 0
        bn.addi w5, w26, 0
        bn.addi w6, w27, 0
        bn.addi w7, w28, 0
        bn.addi w8, w29, 0
        bn.addi w9, w30, 0
        
        /* bn.trans8 w10, w10 */
        bn.trans.8S w23, w10, 0
        bn.trans.8S w23, w11, 1
        bn.trans.8S w23, w12, 2
        bn.trans.8S w23, w13, 3
        bn.trans.8S w23, w14, 4
        bn.trans.8S w23, w15, 5
        bn.trans.8S w23, w16, 6
        bn.trans.8S w23, w17, 7
        bn.addi w10, w23, 0
        bn.addi w11, w24, 0
        bn.addi w12, w25, 0
        bn.addi w13, w26, 0
        bn.addi w14, w27, 0
        bn.addi w15, w28, 0
        bn.addi w16, w29, 0
        bn.addi w17, w30, 0

        /* Reverse Layer 5, stride 8 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11++)
        
        /* Butterflies */
        bn.subvm.8S   w30, w2, w3
        bn.addvm.8S   w2, w2, w3
        bn.mulvm.l.8S w3, w30, w18, 0
        bn.subvm.8S   w30, w4, w5
        bn.addvm.8S   w4, w4, w5
        bn.mulvm.l.8S w5, w30, w18, 1
        bn.subvm.8S   w30, w6, w7
        bn.addvm.8S   w6, w6, w7
        bn.mulvm.l.8S w7, w30, w18, 2
        bn.subvm.8S   w30, w8, w9
        bn.addvm.8S   w8, w8, w9
        bn.mulvm.l.8S w9, w30, w18, 3
        bn.subvm.8S   w30, w10, w11
        bn.addvm.8S   w10, w10, w11
        bn.mulvm.l.8S w11, w30, w18, 4
        bn.subvm.8S   w30, w12, w13
        bn.addvm.8S   w12, w12, w13
        bn.mulvm.l.8S w13, w30, w18, 5
        bn.subvm.8S   w30, w14, w15
        bn.addvm.8S   w14, w14, w15
        bn.mulvm.l.8S w15, w30, w18, 6
        bn.subvm.8S   w30, w16, w17
        bn.addvm.8S   w16, w16, w17
        bn.mulvm.l.8S w17, w30, w18, 7

        bn.sid x4, 0(x10++)
        bn.sid x5, 0(x10++)
        bn.sid x6, 0(x10++)
        bn.sid x7, 0(x10++)
        bn.sid x8, 0(x10++)
        bn.sid x9, 0(x10++)
        bn.sid x13,0(x10++)
        bn.sid x14,0(x10++)
        bn.sid x15,0(x10++)
        bn.sid x16,0(x10++)
        bn.sid x17,0(x10++)
        bn.sid x18,0(x10++)
        bn.sid x19,0(x10++)
        bn.sid x20,0(x10++)
        bn.sid x21,0(x10++)
        bn.sid x22,0(x10++)

    /* Restore input pointer */
    addi x10, x10, -1024

    /* Load twiddle factors for layers 1--4 */
    bn.lid x23, 0(x11)
    bn.lid x24, 32(x11)

    LOOPI 2, 136
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
        bn.subvm.8S   w30, w2, w3
        bn.addvm.8S   w2, w2, w3
        bn.mulvm.l.8S w3, w30, w18, 0
        bn.subvm.8S   w30, w4, w5
        bn.addvm.8S   w4, w4, w5
        bn.mulvm.l.8S w5, w30, w18, 1
        bn.subvm.8S   w30, w6, w7
        bn.addvm.8S   w6, w6, w7
        bn.mulvm.l.8S w7, w30, w18, 2
        bn.subvm.8S   w30, w8, w9
        bn.addvm.8S   w8, w8, w9
        bn.mulvm.l.8S w9, w30, w18, 3
        bn.subvm.8S   w30, w10, w11
        bn.addvm.8S   w10, w10, w11
        bn.mulvm.l.8S w11, w30, w18, 4
        bn.subvm.8S   w30, w12, w13
        bn.addvm.8S   w12, w12, w13
        bn.mulvm.l.8S w13, w30, w18, 5
        bn.subvm.8S   w30, w14, w15
        bn.addvm.8S   w14, w14, w15
        bn.mulvm.l.8S w15, w30, w18, 6
        bn.subvm.8S   w30, w16, w17
        bn.addvm.8S   w16, w16, w17
        bn.mulvm.l.8S w17, w30, w18, 7

        /* Layer 3 */
        bn.subvm.8S   w30, w2, w4
        bn.addvm.8S   w2, w2, w4
        bn.mulvm.l.8S w4, w30, w19, 0
        bn.subvm.8S   w30, w3, w5
        bn.addvm.8S   w3, w3, w5
        bn.mulvm.l.8S w5, w30, w19, 0
        bn.subvm.8S   w30, w6, w8
        bn.addvm.8S   w6, w6, w8
        bn.mulvm.l.8S w8, w30, w19, 1
        bn.subvm.8S   w30, w7, w9
        bn.addvm.8S   w7, w7, w9
        bn.mulvm.l.8S w9, w30, w19, 1
        bn.subvm.8S   w30, w10, w12
        bn.addvm.8S   w10, w10, w12
        bn.mulvm.l.8S w12, w30, w19, 2
        bn.subvm.8S   w30, w11, w13
        bn.addvm.8S   w11, w11, w13
        bn.mulvm.l.8S w13, w30, w19, 2
        bn.subvm.8S   w30, w14, w16
        bn.addvm.8S   w14, w14, w16
        bn.mulvm.l.8S w16, w30, w19, 3
        bn.subvm.8S   w30, w15, w17
        bn.addvm.8S   w15, w15, w17
        bn.mulvm.l.8S w17, w30, w19, 3

        /* Layer 2 */
        bn.subvm.8S   w30, w2, w6
        bn.addvm.8S   w2, w2, w6
        bn.mulvm.l.8S w6, w30, w19, 4
        bn.subvm.8S   w30, w3, w7
        bn.addvm.8S   w3, w3, w7
        bn.mulvm.l.8S w7, w30, w19, 4
        bn.subvm.8S   w30, w4, w8
        bn.addvm.8S   w4, w4, w8
        bn.mulvm.l.8S w8, w30, w19, 4
        bn.subvm.8S   w30, w5, w9
        bn.addvm.8S   w5, w5, w9
        bn.mulvm.l.8S w9, w30, w19, 4
        bn.subvm.8S   w30, w10, w14
        bn.addvm.8S   w10, w10, w14
        bn.mulvm.l.8S w14, w30, w19, 5
        bn.subvm.8S   w30, w11, w15
        bn.addvm.8S   w11, w11, w15
        bn.mulvm.l.8S w15, w30, w19, 5
        bn.subvm.8S   w30, w12, w16
        bn.addvm.8S   w12, w12, w16
        bn.mulvm.l.8S w16, w30, w19, 5
        bn.subvm.8S   w30, w13, w17
        bn.addvm.8S   w13, w13, w17
        bn.mulvm.l.8S w17, w30, w19, 5

        /* Layer 1 */
        bn.subvm.8S   w30, w2, w10
        bn.addvm.8S   w2, w2, w10
        bn.mulvm.l.8S w10, w30, w19, 6
        bn.subvm.8S   w30, w3, w11
        bn.addvm.8S   w3, w3, w11
        bn.mulvm.l.8S w11, w30, w19, 6
        bn.subvm.8S   w30, w4, w12
        bn.addvm.8S   w4, w4, w12
        bn.mulvm.l.8S w12, w30, w19, 6
        bn.subvm.8S   w30, w5, w13
        bn.addvm.8S   w5, w5, w13
        bn.mulvm.l.8S w13, w30, w19, 6
        bn.subvm.8S   w30, w6, w14
        bn.addvm.8S   w6, w6, w14
        bn.mulvm.l.8S w14, w30, w19, 6
        bn.subvm.8S   w30, w7, w15
        bn.addvm.8S   w7, w7, w15
        bn.mulvm.l.8S w15, w30, w19, 6
        bn.subvm.8S   w30, w8, w16
        bn.addvm.8S   w8, w8, w16
        bn.mulvm.l.8S w16, w30, w19, 6
        bn.subvm.8S   w30, w9, w17
        bn.addvm.8S   w9, w9, w17
        bn.mulvm.l.8S w17, w30, w19, 6

        /* Multiply n^{-1} */
        bn.mulvm.l.8S w2, w2, w19, 7
        bn.mulvm.l.8S w3, w3, w19, 7
        bn.mulvm.l.8S w4, w4, w19, 7
        bn.mulvm.l.8S w5, w5, w19, 7
        bn.mulvm.l.8S w6, w6, w19, 7
        bn.mulvm.l.8S w7, w7, w19, 7
        bn.mulvm.l.8S w8, w8, w19, 7
        bn.mulvm.l.8S w9, w9, w19, 7

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
        bn.sid x22, 960(x10++)
        
    .irp reg,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1,s0
        pop \reg
    .endr
    /* Restore input pointer */
    addi x10, x10, -64
    ret