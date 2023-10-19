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

/* Register aliases */
.equ x0, zero
.equ x2, sp
.equ x3, fp

.equ x5, t0
.equ x6, t1
.equ x7, t2

.equ x8, s0
.equ x9, s1

.equ x10, a0
.equ x11, a1

.equ x12, a2
.equ x13, a3
.equ x14, a4
.equ x15, a5
.equ x16, a6
.equ x17, a7

.equ x18, s2
.equ x19, s3
.equ x20, s4
.equ x21, s5
.equ x22, s6
.equ x23, s7
.equ x24, s8
.equ x25, s9
.equ x26, s10
.equ x27, s11

.equ x28, t3
.equ x29, t4
.equ x30, t5
.equ x31, t6

.equ w31, bn0

/**
 * Constant Time Dilithium inverse NTT (base)
 *
 * Returns: INTT(input)
 *
 * This implements the in-place INTT for Dilithium, where n=256, q=8380417.
 *
 * Flags: -
 *
 * @param[in]  x10: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x11: dptr_tw, dmem pointer to array of twiddle factors,
                    last element is n^{-1} mod q
 * @param[in]  w31: all-zero
 * @param[out] x10: dmem pointer to result
 *
 * clobbered registers: x4-x30, w0-w23, w30
 */
.global intt_base_dilithium
intt_base_dilithium:
/* 32 byte align the sp */
    andi x6, sp, 31
    beq  x6, zero, _aligned
    sub  sp, sp, x6
_aligned:
    push x6
    addi sp, sp, -28
    /* save fp to stack */
    addi sp, sp, -32
    sw   fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -32

    /* Reserve space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR -32

    /* Save callee-saved registers */
    .irp reg,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11
        push \reg
    .endr
    
    #define coeff0 w0
    #define coeff1 w1
    #define coeff2 w2
    #define coeff3 w3
    #define coeff4 w4
    #define coeff5 w5
    #define coeff6 w6
    #define coeff7 w7

    #define coeff8 w8
    #define coeff9 w9
    #define coeff10 w10
    #define coeff11 w11
    #define coeff12 w12
    #define coeff13 w13
    #define coeff14 w14
    #define coeff15 w15

    #define buf0 w31
    #define buf1 w30
    #define buf2 w29
    #define buf3 w28
    #define buf4 w27
    #define buf5 w26
    #define buf6 w25
    #define buf7 w24
    /* Twiddle Factors */
    #define tf1 w16
    #define tf2 w17
    #define tf3 w18
    #define tf4 w19

    /* Other */
    #define wtmp w20
    #define wtmp2 w21
    #define wtmp3 w22
    #define mask w23
    
    /* GPRs with indices to access WDRs */
    #define buf0_idx x4
    #define buf1_idx x5
    #define buf2_idx x6
    #define buf3_idx x7
    #define buf4_idx x8
    #define buf5_idx x9
    #define buf6_idx x13
    #define buf7_idx x14
    #define inp x10
    #define twp x11
    #define outp x12
    #define coeff8_idx x15
    #define coeff9_idx x16
    #define coeff10_idx x17
    #define coeff11_idx x18
    #define coeff12_idx x19
    #define coeff13_idx x20
    #define coeff14_idx x21
    #define coeff15_idx x22
    #define tf1_idx x23
    #define tf2_idx x24
    #define tf3_idx x25
    #define tf4_idx x26
    #define tmp_gpr x27
    #define tmp_gpr2 x28

    /* In place */
    addi outp, inp, 0

    /* Set up constants for input/twiddle factors */
    li tf1_idx, 16
    li tf2_idx, 17
    li tf3_idx, 18
    li tf4_idx, 19

    /* w18 <= 0xFFFFFFFF for masking */
    bn.addi mask, w31, 1
    bn.rshi mask, mask, w31 >> 224
    bn.subi mask, mask, 1 

    li coeff8_idx, 8
    li coeff9_idx, 9
    li coeff10_idx, 10
    li coeff11_idx, 11
    li coeff12_idx, 12
    li coeff13_idx, 13
    li coeff14_idx, 14
    li coeff15_idx, 15

    li buf0_idx, 31
    li buf1_idx, 30
    li buf2_idx, 29
    li buf3_idx, 28
    li buf4_idx, 27
    li buf5_idx, 26
    li buf6_idx, 25
    li buf7_idx, 24

    /* Zero out one register */
    bn.xor wtmp2, wtmp2, wtmp2

    /* Set second WLEN/4 quad word to modulus */
    la tmp_gpr, modulus
    li tmp_gpr2, 20 /* Load q to wtmp */
    bn.lid tmp_gpr2, 0(tmp_gpr)
    bn.and wtmp, wtmp, mask
    bn.or wtmp3, wtmp2, wtmp

    /* Set second WLEN/4 quarter word to barrett constant */
    la tmp_gpr, barrett_const
    bn.lid tmp_gpr2, 0(tmp_gpr)
    bn.or wtmp3, wtmp3, wtmp << 64

    /* Set up constants for input/twiddle factors */
    li tf1_idx, 16
    li tf2_idx, 17
    li tf3_idx, 18
    li tf4_idx, 19

    LOOPI 16, 232
        /* Load Data */
        bn.lid buf0_idx, 0(inp)
        bn.and  coeff0, mask, buf0 >> 0
        bn.and  coeff1, mask, buf0 >> 32
        bn.and  coeff2, mask, buf0 >> 64
        bn.and  coeff3, mask, buf0 >> 96
        bn.and  coeff4, mask, buf0 >> 128
        bn.and  coeff5, mask, buf0 >> 160
        bn.and  coeff6, mask, buf0 >> 192
        bn.and  coeff7, mask, buf0 >> 224

        bn.lid buf0_idx, 32(inp)
        bn.and  coeff8, mask, buf0 >> 0
        bn.and  coeff9, mask, buf0 >> 32
        bn.and  coeff10, mask, buf0 >> 64
        bn.and  coeff11, mask, buf0 >> 96
        bn.and  coeff12, mask, buf0 >> 128
        bn.and  coeff13, mask, buf0 >> 160
        bn.and  coeff14, mask, buf0 >> 192
        bn.and  coeff15, mask, buf0 >> 224

        /* Load layer 8 twiddle 4x */
        bn.lid tf1_idx, 0(twp++)

        bn.subm wtmp, coeff0, coeff1
        bn.addm coeff0, coeff0, coeff1
        /* Barrett */
        bn.mulqacc.wo.z coeff1, wtmp.0, tf1.0, 0 /* (coeff0 - coeff1) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff1.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff1, coeff1, wtmp

        bn.subm wtmp, coeff2, coeff3
        bn.addm coeff2, coeff2, coeff3
        /* Barrett */
        bn.mulqacc.wo.z coeff3, wtmp.0, tf1.1, 0 /* (coeff2 - coeff3) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff3.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff3, coeff3, wtmp

        bn.subm wtmp, coeff4, coeff5
        bn.addm coeff4, coeff4, coeff5
        /* Barrett */
        bn.mulqacc.wo.z coeff5, wtmp.0, tf1.2, 0 /* (coeff4 - coeff5) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff5.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff5, coeff5, wtmp

        bn.subm wtmp, coeff6, coeff7
        bn.addm coeff6, coeff6, coeff7
        /* Barrett */
        bn.mulqacc.wo.z coeff7, wtmp.0, tf1.3, 0 /* (coeff6 - coeff7) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff7.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff7, coeff7, wtmp
            
        /* Load layer 8 twiddle 4x */
        bn.lid tf1_idx, 0(twp++)

        bn.subm wtmp, coeff8, coeff9
        bn.addm coeff8, coeff8, coeff9
        /* Barrett */
        bn.mulqacc.wo.z coeff9, wtmp.0, tf1.0, 0 /* (coeff8 - coeff9) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff9.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff9, coeff9, wtmp

        bn.subm wtmp, coeff10, coeff11
        bn.addm coeff10, coeff10, coeff11
        /* Barrett */
        bn.mulqacc.wo.z coeff11, wtmp.0, tf1.1, 0 /* (coeff10 - coeff11) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff11.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff11, coeff11, wtmp

        bn.subm wtmp, coeff12, coeff13
        bn.addm coeff12, coeff12, coeff13
        /* Barrett */
        bn.mulqacc.wo.z coeff13, wtmp.0, tf1.2, 0 /* (coeff12 - coeff13) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff13.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff13, coeff13, wtmp

        bn.subm wtmp, coeff14, coeff15
        bn.addm coeff14, coeff14, coeff15
        /* Barrett */
        bn.mulqacc.wo.z coeff15, wtmp.0, tf1.3, 0 /* (coeff14 - coeff15) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff15.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff15, coeff15, wtmp

        /* Layer 7, stride 2 */
        /* Load layer 7 4x */
        bn.lid tf1_idx, 0(twp++)

        bn.subm wtmp, coeff0, coeff2
        bn.addm coeff0, coeff0, coeff2
        /* Barrett */
        bn.mulqacc.wo.z coeff2, wtmp.0, tf1.0, 0 /* (coeff0 - coeff2) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff2.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff2, coeff2, wtmp

        bn.subm wtmp, coeff1, coeff3
        bn.addm coeff1, coeff1, coeff3
        /* Barrett */
        bn.mulqacc.wo.z coeff3, wtmp.0, tf1.0, 0 /* (coeff1 - coeff3) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff3.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff3, coeff3, wtmp

        bn.subm wtmp, coeff4, coeff6
        bn.addm coeff4, coeff4, coeff6
        /* Barrett */
        bn.mulqacc.wo.z coeff6, wtmp.0, tf1.1, 0 /* (coeff4 - coeff6) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff6.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff6, coeff6, wtmp

        bn.subm wtmp, coeff5, coeff7
        bn.addm coeff5, coeff5, coeff7
        /* Barrett */
        bn.mulqacc.wo.z coeff7, wtmp.0, tf1.1, 0 /* (coeff5 - coeff7) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff7.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff7, coeff7, wtmp

        bn.subm wtmp, coeff8, coeff10
        bn.addm coeff8, coeff8, coeff10
        /* Barrett */
        bn.mulqacc.wo.z coeff10, wtmp.0, tf1.2, 0 /* (coeff8 - coeff10) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff10.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff10, coeff10, wtmp

        bn.subm wtmp, coeff9, coeff11
        bn.addm coeff9, coeff9, coeff11
        /* Barrett */
        bn.mulqacc.wo.z coeff11, wtmp.0, tf1.2, 0 /* (coeff9 - coeff11) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff11.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff11, coeff11, wtmp

        bn.subm wtmp, coeff12, coeff14
        bn.addm coeff12, coeff12, coeff14
        /* Barrett */
        bn.mulqacc.wo.z coeff14, wtmp.0, tf1.3, 0 /* (coeff12 - coeff14) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff14.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff14, coeff14, wtmp

        bn.subm wtmp, coeff13, coeff15
        bn.addm coeff13, coeff13, coeff15
        /* Barrett */
        bn.mulqacc.wo.z coeff15, wtmp.0, tf1.3, 0 /* (coeff13 - coeff15) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff15.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff15, coeff15, wtmp

        /* Layer 6, stride 4 */
        /* Load layer 6 x2 + layer 5 x1 + pad */
        bn.lid tf1_idx, 0(twp++)

        bn.subm wtmp, coeff0, coeff4
        bn.addm coeff0, coeff0, coeff4
        /* Barrett */
        bn.mulqacc.wo.z coeff4, wtmp.0, tf1.0, 0 /* (coeff0 - coeff4) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff4.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff4, coeff4, wtmp

        bn.subm wtmp, coeff1, coeff5
        bn.addm coeff1, coeff1, coeff5
        /* Barrett */
        bn.mulqacc.wo.z coeff5, wtmp.0, tf1.0, 0 /* (coeff1 - coeff5) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff5.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff5, coeff5, wtmp

        bn.subm wtmp, coeff2, coeff6
        bn.addm coeff2, coeff2, coeff6
        /* Barrett */
        bn.mulqacc.wo.z coeff6, wtmp.0, tf1.0, 0 /* (coeff2 - coeff6) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff6.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff6, coeff6, wtmp

        bn.subm wtmp, coeff3, coeff7
        bn.addm coeff3, coeff3, coeff7
        /* Barrett */
        bn.mulqacc.wo.z coeff7, wtmp.0, tf1.0, 0 /* (coeff3 - coeff7) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff7.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff7, coeff7, wtmp

        bn.subm wtmp, coeff8, coeff12
        bn.addm coeff8, coeff8, coeff12
        /* Barrett */
        bn.mulqacc.wo.z coeff12, wtmp.0, tf1.1, 0 /* (coeff8 - coeff12) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff12.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff12, coeff12, wtmp

        bn.subm wtmp, coeff9, coeff13
        bn.addm coeff9, coeff9, coeff13
        /* Barrett */
        bn.mulqacc.wo.z coeff13, wtmp.0, tf1.1, 0 /* (coeff9 - coeff13) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff13.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff13, coeff13, wtmp

        bn.subm wtmp, coeff10, coeff14
        bn.addm coeff10, coeff10, coeff14
        /* Barrett */
        bn.mulqacc.wo.z coeff14, wtmp.0, tf1.1, 0 /* (coeff10 - coeff14) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff14.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff14, coeff14, wtmp

        bn.subm wtmp, coeff11, coeff15
        bn.addm coeff11, coeff11, coeff15
        /* Barrett */
        bn.mulqacc.wo.z coeff15, wtmp.0, tf1.1, 0 /* (coeff11 - coeff15) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff15.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff15, coeff15, wtmp

        /* Layer 5, stride 8 */         

        bn.subm wtmp, coeff0, coeff8
        bn.addm coeff0, coeff0, coeff8
        /* Barrett */
        bn.mulqacc.wo.z coeff8, wtmp.0, tf1.2, 0 /* (coeff0 - coeff8) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff8.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff8, coeff8, wtmp

        bn.subm wtmp, coeff1, coeff9
        bn.addm coeff1, coeff1, coeff9
        /* Barrett */
        bn.mulqacc.wo.z coeff9, wtmp.0, tf1.2, 0 /* (coeff1 - coeff9) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff9.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff9, coeff9, wtmp

        bn.subm wtmp, coeff2, coeff10
        bn.addm coeff2, coeff2, coeff10
        /* Barrett */
        bn.mulqacc.wo.z coeff10, wtmp.0, tf1.2, 0 /* (coeff2 - coeff10) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff10.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff10, coeff10, wtmp

        bn.subm wtmp, coeff3, coeff11
        bn.addm coeff3, coeff3, coeff11
        /* Barrett */
        bn.mulqacc.wo.z coeff11, wtmp.0, tf1.2, 0 /* (coeff3 - coeff11) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff11.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff11, coeff11, wtmp

        bn.subm wtmp, coeff4, coeff12
        bn.addm coeff4, coeff4, coeff12
        /* Barrett */
        bn.mulqacc.wo.z coeff12, wtmp.0, tf1.2, 0 /* (coeff4 - coeff12) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff12.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff12, coeff12, wtmp

        bn.subm wtmp, coeff5, coeff13
        bn.addm coeff5, coeff5, coeff13
        /* Barrett */
        bn.mulqacc.wo.z coeff13, wtmp.0, tf1.2, 0 /* (coeff5 - coeff13) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff13.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff13, coeff13, wtmp

        bn.subm wtmp, coeff6, coeff14
        bn.addm coeff6, coeff6, coeff14
        /* Barrett */
        bn.mulqacc.wo.z coeff14, wtmp.0, tf1.2, 0 /* (coeff6 - coeff14) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff14.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff14, coeff14, wtmp

        bn.subm wtmp, coeff7, coeff15
        bn.addm coeff7, coeff7, coeff15
        /* Barrett */
        bn.mulqacc.wo.z coeff15, wtmp.0, tf1.2, 0 /* (coeff7 - coeff15) * twiddle */
        bn.mulqacc.wo.z wtmp, coeff15.0, wtmp3.1, 0 /* * barrett const */
        bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
        bn.sub          coeff15, coeff15, wtmp

        /* Reassemble WDRs and store */
        bn.rshi buf0, coeff0, buf0 >> 32
        bn.rshi buf0, coeff1, buf0 >> 32
        bn.rshi buf0, coeff2, buf0 >> 32
        bn.rshi buf0, coeff3, buf0 >> 32
        bn.rshi buf0, coeff4, buf0 >> 32
        bn.rshi buf0, coeff5, buf0 >> 32
        bn.rshi buf0, coeff6, buf0 >> 32
        bn.rshi buf0, coeff7, buf0 >> 32
        bn.sid buf0_idx, 0(inp++)
        
        bn.rshi buf0, coeff8, buf0 >> 32
        bn.rshi buf0, coeff9, buf0 >> 32
        bn.rshi buf0, coeff10, buf0 >> 32
        bn.rshi buf0, coeff11, buf0 >> 32
        bn.rshi buf0, coeff12, buf0 >> 32
        bn.rshi buf0, coeff13, buf0 >> 32
        bn.rshi buf0, coeff14, buf0 >> 32
        bn.rshi buf0, coeff15, buf0 >> 32
        bn.sid buf0_idx, 0(inp++)

    /* Restore output pointer */
    addi inp, inp, -1024

    /* Set up constants for input/twiddle factors */
    li tf1_idx, 16
    li tf2_idx, 17
    li tf3_idx, 18
    li tf4_idx, 19

    /* Load twiddle factors for layers 1--4 */
    bn.lid tf1_idx, 0(twp)
    bn.lid tf2_idx, 32(twp)
    bn.lid tf3_idx, 64(twp)
    bn.lid tf4_idx, 96(twp)

    /* We can process 16 coefficients each iteration and need to process N=256, meaning we require 16 iterations. */
    LOOPI 2, 306
        /* Load coefficients into buffer registers */
        bn.lid buf0_idx, 0(inp)
        bn.lid buf1_idx, 64(inp)
        bn.lid buf2_idx, 128(inp)
        bn.lid buf3_idx, 192(inp)
        bn.lid buf4_idx, 256(inp)
        bn.lid buf5_idx, 320(inp)
        bn.lid buf6_idx, 384(inp)
        bn.lid buf7_idx, 448(inp)
        LOOPI 8, 289
            /* Extract coefficients from buffer registers into working state */
            bn.and coeff0, buf0, mask
            bn.and coeff1, buf1, mask
            bn.and coeff2, buf2, mask
            bn.and coeff3, buf3, mask
            bn.and coeff4, buf4, mask
            bn.and coeff5, buf5, mask
            bn.and coeff6, buf6, mask
            bn.and coeff7, buf7, mask

            /* Load remaining coefficients using 32-bit loads */
            /* Coeff 8 */
            lw tmp_gpr, 512(inp)
            sw tmp_gpr, STACK_WDR2GPR(fp)
            bn.lid coeff8_idx, STACK_WDR2GPR(fp)
            /* Coeff 9 */
            lw tmp_gpr, 576(inp)
            sw tmp_gpr, STACK_WDR2GPR(fp)
            bn.lid coeff9_idx, STACK_WDR2GPR(fp)
            /* Coeff 10 */
            lw tmp_gpr, 640(inp)
            sw tmp_gpr, STACK_WDR2GPR(fp)
            bn.lid coeff10_idx, STACK_WDR2GPR(fp)
            /* Coeff 11 */
            lw tmp_gpr, 704(inp)
            sw tmp_gpr, STACK_WDR2GPR(fp)
            bn.lid coeff11_idx, STACK_WDR2GPR(fp)
            /* Coeff 12 */
            lw tmp_gpr, 768(inp)
            sw tmp_gpr, STACK_WDR2GPR(fp)
            bn.lid coeff12_idx, STACK_WDR2GPR(fp)
            /* Coeff 13 */
            lw tmp_gpr, 832(inp)
            sw tmp_gpr, STACK_WDR2GPR(fp)
            bn.lid coeff13_idx, STACK_WDR2GPR(fp)
            /* Coeff 14 */
            lw tmp_gpr, 896(inp)
            sw tmp_gpr, STACK_WDR2GPR(fp)
            bn.lid coeff14_idx, STACK_WDR2GPR(fp)
            /* Coeff 15 */
            lw tmp_gpr, 960(inp)
            sw tmp_gpr, STACK_WDR2GPR(fp)
            bn.lid coeff15_idx, STACK_WDR2GPR(fp)

            /* Layer 0 */

            bn.subm wtmp, coeff0, coeff1
            bn.addm coeff0, coeff0, coeff1
            /* Barrett */
            bn.mulqacc.wo.z coeff1, wtmp.0, tf1.0, 0 /* (coeff0 - coeff1) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff1.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff1, coeff1, wtmp

            bn.subm wtmp, coeff2, coeff3
            bn.addm coeff2, coeff2, coeff3
            /* Barrett */
            bn.mulqacc.wo.z coeff3, wtmp.0, tf1.1, 0 /* (coeff2 - coeff3) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff3.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff3, coeff3, wtmp

            bn.subm wtmp, coeff4, coeff5
            bn.addm coeff4, coeff4, coeff5
            /* Barrett */
            bn.mulqacc.wo.z coeff5, wtmp.0, tf1.2, 0 /* (coeff4 - coeff5) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff5.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff5, coeff5, wtmp

            bn.subm wtmp, coeff6, coeff7
            bn.addm coeff6, coeff6, coeff7
            /* Barrett */
            bn.mulqacc.wo.z coeff7, wtmp.0, tf1.3, 0 /* (coeff6 - coeff7) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff7.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff7, coeff7, wtmp

            bn.subm wtmp, coeff8, coeff9
            bn.addm coeff8, coeff8, coeff9
            /* Barrett */
            bn.mulqacc.wo.z coeff9, wtmp.0, tf2.0, 0 /* (coeff8 - coeff9) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff9.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff9, coeff9, wtmp

            bn.subm wtmp, coeff10, coeff11
            bn.addm coeff10, coeff10, coeff11
            /* Barrett */
            bn.mulqacc.wo.z coeff11, wtmp.0, tf2.1, 0 /* (coeff10 - coeff11) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff11.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff11, coeff11, wtmp

            bn.subm wtmp, coeff12, coeff13
            bn.addm coeff12, coeff12, coeff13
            /* Barrett */
            bn.mulqacc.wo.z coeff13, wtmp.0, tf2.2, 0 /* (coeff12 - coeff13) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff13.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff13, coeff13, wtmp

            bn.subm wtmp, coeff14, coeff15
            bn.addm coeff14, coeff14, coeff15
            /* Barrett */
            bn.mulqacc.wo.z coeff15, wtmp.0, tf2.3, 0 /* (coeff14 - coeff15) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff15.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff15, coeff15, wtmp
/* Layer 1 */

            bn.subm wtmp, coeff0, coeff2
            bn.addm coeff0, coeff0, coeff2
            /* Barrett */
            bn.mulqacc.wo.z coeff2, wtmp.0, tf3.0, 0 /* (coeff0 - coeff2) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff2.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff2, coeff2, wtmp

            bn.subm wtmp, coeff1, coeff3
            bn.addm coeff1, coeff1, coeff3
            /* Barrett */
            bn.mulqacc.wo.z coeff3, wtmp.0, tf3.0, 0 /* (coeff1 - coeff3) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff3.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff3, coeff3, wtmp

            bn.subm wtmp, coeff4, coeff6
            bn.addm coeff4, coeff4, coeff6
            /* Barrett */
            bn.mulqacc.wo.z coeff6, wtmp.0, tf3.1, 0 /* (coeff4 - coeff6) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff6.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff6, coeff6, wtmp

            bn.subm wtmp, coeff5, coeff7
            bn.addm coeff5, coeff5, coeff7
            /* Barrett */
            bn.mulqacc.wo.z coeff7, wtmp.0, tf3.1, 0 /* (coeff5 - coeff7) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff7.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff7, coeff7, wtmp

            bn.subm wtmp, coeff8, coeff10
            bn.addm coeff8, coeff8, coeff10
            /* Barrett */
            bn.mulqacc.wo.z coeff10, wtmp.0, tf3.2, 0 /* (coeff8 - coeff10) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff10.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff10, coeff10, wtmp

            bn.subm wtmp, coeff9, coeff11
            bn.addm coeff9, coeff9, coeff11
            /* Barrett */
            bn.mulqacc.wo.z coeff11, wtmp.0, tf3.2, 0 /* (coeff9 - coeff11) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff11.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff11, coeff11, wtmp

            bn.subm wtmp, coeff12, coeff14
            bn.addm coeff12, coeff12, coeff14
            /* Barrett */
            bn.mulqacc.wo.z coeff14, wtmp.0, tf3.3, 0 /* (coeff12 - coeff14) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff14.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff14, coeff14, wtmp

            bn.subm wtmp, coeff13, coeff15
            bn.addm coeff13, coeff13, coeff15
            /* Barrett */
            bn.mulqacc.wo.z coeff15, wtmp.0, tf3.3, 0 /* (coeff13 - coeff15) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff15.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff15, coeff15, wtmp
/* Layer 2 */

            bn.subm wtmp, coeff0, coeff4
            bn.addm coeff0, coeff0, coeff4
            /* Barrett */
            bn.mulqacc.wo.z coeff4, wtmp.0, tf4.0, 0 /* (coeff0 - coeff4) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff4.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff4, coeff4, wtmp

            bn.subm wtmp, coeff1, coeff5
            bn.addm coeff1, coeff1, coeff5
            /* Barrett */
            bn.mulqacc.wo.z coeff5, wtmp.0, tf4.0, 0 /* (coeff1 - coeff5) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff5.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff5, coeff5, wtmp

            bn.subm wtmp, coeff2, coeff6
            bn.addm coeff2, coeff2, coeff6
            /* Barrett */
            bn.mulqacc.wo.z coeff6, wtmp.0, tf4.0, 0 /* (coeff2 - coeff6) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff6.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff6, coeff6, wtmp

            bn.subm wtmp, coeff3, coeff7
            bn.addm coeff3, coeff3, coeff7
            /* Barrett */
            bn.mulqacc.wo.z coeff7, wtmp.0, tf4.0, 0 /* (coeff3 - coeff7) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff7.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff7, coeff7, wtmp

            bn.subm wtmp, coeff8, coeff12
            bn.addm coeff8, coeff8, coeff12
            /* Barrett */
            bn.mulqacc.wo.z coeff12, wtmp.0, tf4.1, 0 /* (coeff8 - coeff12) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff12.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff12, coeff12, wtmp

            bn.subm wtmp, coeff9, coeff13
            bn.addm coeff9, coeff9, coeff13
            /* Barrett */
            bn.mulqacc.wo.z coeff13, wtmp.0, tf4.1, 0 /* (coeff9 - coeff13) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff13.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff13, coeff13, wtmp

            bn.subm wtmp, coeff10, coeff14
            bn.addm coeff10, coeff10, coeff14
            /* Barrett */
            bn.mulqacc.wo.z coeff14, wtmp.0, tf4.1, 0 /* (coeff10 - coeff14) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff14.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff14, coeff14, wtmp

            bn.subm wtmp, coeff11, coeff15
            bn.addm coeff11, coeff11, coeff15
            /* Barrett */
            bn.mulqacc.wo.z coeff15, wtmp.0, tf4.1, 0 /* (coeff11 - coeff15) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff15.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff15, coeff15, wtmp
/* Layer 3 */

            bn.subm wtmp, coeff0, coeff8
            bn.addm coeff0, coeff0, coeff8
            /* Barrett */
            bn.mulqacc.wo.z coeff8, wtmp.0, tf4.2, 0 /* (coeff0 - coeff8) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff8.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff8, coeff8, wtmp

            bn.subm wtmp, coeff1, coeff9
            bn.addm coeff1, coeff1, coeff9
            /* Barrett */
            bn.mulqacc.wo.z coeff9, wtmp.0, tf4.2, 0 /* (coeff1 - coeff9) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff9.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff9, coeff9, wtmp

            bn.subm wtmp, coeff2, coeff10
            bn.addm coeff2, coeff2, coeff10
            /* Barrett */
            bn.mulqacc.wo.z coeff10, wtmp.0, tf4.2, 0 /* (coeff2 - coeff10) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff10.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff10, coeff10, wtmp

            bn.subm wtmp, coeff3, coeff11
            bn.addm coeff3, coeff3, coeff11
            /* Barrett */
            bn.mulqacc.wo.z coeff11, wtmp.0, tf4.2, 0 /* (coeff3 - coeff11) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff11.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff11, coeff11, wtmp

            bn.subm wtmp, coeff4, coeff12
            bn.addm coeff4, coeff4, coeff12
            /* Barrett */
            bn.mulqacc.wo.z coeff12, wtmp.0, tf4.2, 0 /* (coeff4 - coeff12) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff12.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff12, coeff12, wtmp

            bn.subm wtmp, coeff5, coeff13
            bn.addm coeff5, coeff5, coeff13
            /* Barrett */
            bn.mulqacc.wo.z coeff13, wtmp.0, tf4.2, 0 /* (coeff5 - coeff13) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff13.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff13, coeff13, wtmp

            bn.subm wtmp, coeff6, coeff14
            bn.addm coeff6, coeff6, coeff14
            /* Barrett */
            bn.mulqacc.wo.z coeff14, wtmp.0, tf4.2, 0 /* (coeff6 - coeff14) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff14.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff14, coeff14, wtmp

            bn.subm wtmp, coeff7, coeff15
            bn.addm coeff7, coeff7, coeff15
            /* Barrett */
            bn.mulqacc.wo.z coeff15, wtmp.0, tf4.2, 0 /* (coeff7 - coeff15) * twiddle */
            bn.mulqacc.wo.z wtmp, coeff15.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff15, coeff15, wtmp

            /* Mul ninv */
            bn.mulqacc.wo.z coeff0, coeff0.0, tf4.3, 0 /* coeff{0-7} * ninv */
            bn.mulqacc.wo.z wtmp, coeff0.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff0, coeff0, wtmp

            bn.mulqacc.wo.z coeff1, coeff1.0, tf4.3, 0 /* coeff{0-7} * ninv */
            bn.mulqacc.wo.z wtmp, coeff1.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff1, coeff1, wtmp

            bn.mulqacc.wo.z coeff2, coeff2.0, tf4.3, 0 /* coeff{0-7} * ninv */
            bn.mulqacc.wo.z wtmp, coeff2.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff2, coeff2, wtmp

            bn.mulqacc.wo.z coeff3, coeff3.0, tf4.3, 0 /* coeff{0-7} * ninv */
            bn.mulqacc.wo.z wtmp, coeff3.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff3, coeff3, wtmp

            bn.mulqacc.wo.z coeff4, coeff4.0, tf4.3, 0 /* coeff{0-7} * ninv */
            bn.mulqacc.wo.z wtmp, coeff4.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff4, coeff4, wtmp

            bn.mulqacc.wo.z coeff5, coeff5.0, tf4.3, 0 /* coeff{0-7} * ninv */
            bn.mulqacc.wo.z wtmp, coeff5.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff5, coeff5, wtmp

            bn.mulqacc.wo.z coeff6, coeff6.0, tf4.3, 0 /* coeff{0-7} * ninv */
            bn.mulqacc.wo.z wtmp, coeff6.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff6, coeff6, wtmp

            bn.mulqacc.wo.z coeff7, coeff7.0, tf4.3, 0 /* coeff{0-7} * ninv */
            bn.mulqacc.wo.z wtmp, coeff7.0, wtmp3.1, 0 /* * barrett const */
            bn.mulqacc.wo.z wtmp, wtmp3.0, wtmp.1, 0 /* q * (wtmp >> 64) */
            bn.sub          coeff7, coeff7, wtmp

            /* Shift result values into the top of buffer registers */
            /* implicitly removes the old value */
            bn.rshi buf0, coeff0, buf0 >> 32
            bn.rshi buf1, coeff1, buf1 >> 32
            bn.rshi buf2, coeff2, buf2 >> 32
            bn.rshi buf3, coeff3, buf3 >> 32
            bn.rshi buf4, coeff4, buf4 >> 32
            bn.rshi buf5, coeff5, buf5 >> 32
            bn.rshi buf6, coeff6, buf6 >> 32
            bn.rshi buf7, coeff7, buf7 >> 32

            /* Store unbuffered values */
            /* Coeff8 */
            bn.sid coeff8_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 512(inp)
            /* Coeff9 */
            bn.sid coeff9_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 576(inp)
            /* Coeff10 */
            bn.sid coeff10_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 640(inp)
            /* Coeff11 */
            bn.sid coeff11_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 704(inp)
            /* Coeff12 */
            bn.sid coeff12_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 768(inp)
            /* Coeff13 */
            bn.sid coeff13_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 832(inp)
            /* Coeff14 */
            bn.sid coeff14_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 896(inp)
            /* Coeff15 */
            bn.sid coeff15_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 960(inp)
            
            /* Go to next coefficient for the unbuffered loads/stores */
            addi inp, inp, 4
            /* Inner Loop End */

        /* Subtract 32 from offset to account for the increment inside the LOOP 8 */
        bn.sid buf0_idx, -32(inp)
        bn.sid buf1_idx, 32(inp)
        bn.sid buf2_idx, 96(inp)
        bn.sid buf3_idx, 160(inp)
        bn.sid buf4_idx, 224(inp)
        bn.sid buf5_idx, 288(inp)
        bn.sid buf6_idx, 352(inp)
        bn.sid buf7_idx, 416(inp)
        /* Outer Loop End */

    .irp reg,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1,s0
        pop \reg
    .endr

    /* Zero w31 again */
    bn.xor w31, w31, w31

    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32

    add sp, sp, 28
    pop x6
    add sp, sp, x6

    ret

.data 
.balign 32
barrett_const:
    .word 0x801c0601
    .word 0x00000200
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0