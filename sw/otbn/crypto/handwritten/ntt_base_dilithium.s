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

.equ x2, sp
.equ x3, fp

/**
 * Constant Time Dilithium NTT
 *
 * Returns: NTT(input)
 *
 * This implements the in-place NTT for Dilithium, where n=256, q=8380417.
 *
 * Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
 *
 * @param[in]  x10: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x11: dptr_tw, dmem pointer to array of twiddle factors
 * @param[in]  w31: all-zero
 * @param[out] x12: dmem pointer to result
 *
 * clobbered registers: x4-x30, w2-w25, w30
 */
.globl ntt_base_dilithium
ntt_base_dilithium:
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

    /* Set up constants for input/state */
    li x15, 8
    li x16, 9
    li x17, 10
    li x18, 11
    li x19, 12
    li x20, 13
    li x21, 14
    li x22, 15

    /* Set up constants for input/twiddle factors */
    li x23, 16
    li x24, 17

    /* w18 <= 0xFFFFFFFF for masking */
    bn.xor w31, w31, w31 /* TODO remove */
    bn.addi w18, w31, 1
    bn.rshi w18, w18, w31 >> 224
    bn.subi w18, w18, 1 
    #define mask w18

    /* Load twiddle factors for layers 1--4 */
    bn.lid x23, 0(x11)
    bn.lid x24, 32(x11)
    
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

    #define coeff8_idx x15
    #define coeff9_idx x16
    #define coeff10_idx x17
    #define coeff11_idx x18
    #define coeff12_idx x19
    #define coeff13_idx x20
    #define coeff14_idx x21
    #define coeff15_idx x22

    li coeff8_idx, 8
    li coeff9_idx, 9
    li coeff10_idx, 10
    li coeff11_idx, 11
    li coeff12_idx, 12
    li coeff13_idx, 13
    li coeff14_idx, 14
    li coeff15_idx, 15

    #define buf0 w31
    #define buf1 w30
    #define buf2 w29
    #define buf3 w28
    #define buf4 w27
    #define buf5 w26
    #define buf6 w25
    #define buf7 w24

    #define buf0_idx x4
    #define buf1_idx x5
    #define buf2_idx x6
    #define buf3_idx x7
    #define buf4_idx x8
    #define buf5_idx x9
    #define buf6_idx x13
    #define buf7_idx x14

    #define wtmp w23
    #define tf1 w16
    #define tf2 w17

    #define inp x10
    #define outp x12

    #define tmp_gpr x25

    li buf0_idx, 31
    li buf1_idx, 30
    li buf2_idx, 29
    li buf3_idx, 28
    li buf4_idx, 27
    li buf5_idx, 26
    li buf6_idx, 25
    li buf7_idx, 24

    /* We can process 16 coefficients each iteration and need to process N=256, meaning we require 16 iterations. */
    LOOPI 2, 179
        /* Load coefficients into buffer registers */
        bn.lid buf0_idx, 0(inp)
        bn.lid buf1_idx, 64(inp)
        bn.lid buf2_idx, 128(inp)
        bn.lid buf3_idx, 192(inp)
        bn.lid buf4_idx, 256(inp)
        bn.lid buf5_idx, 320(inp)
        bn.lid buf6_idx, 384(inp)
        bn.lid buf7_idx, 448(inp)
        LOOPI 8, 162
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

            
            /* Layer 1, stride 128 */

            bn.mulvm.l.8S wtmp, coeff8, tf1, 0
            bn.subvm.8S   coeff8, coeff0, wtmp
            bn.addvm.8S   coeff0, coeff0, wtmp
            bn.mulvm.l.8S wtmp, coeff9, tf1, 0
            bn.subvm.8S   coeff9, coeff1, wtmp
            bn.addvm.8S   coeff1, coeff1, wtmp
            bn.mulvm.l.8S wtmp, coeff10, tf1, 0
            bn.subvm.8S   coeff10, coeff2, wtmp
            bn.addvm.8S   coeff2, coeff2, wtmp
            bn.mulvm.l.8S wtmp, coeff11, tf1, 0
            bn.subvm.8S   coeff11, coeff3, wtmp
            bn.addvm.8S   coeff3, coeff3, wtmp
            bn.mulvm.l.8S wtmp, coeff12, tf1, 0
            bn.subvm.8S   coeff12, coeff4, wtmp
            bn.addvm.8S   coeff4, coeff4, wtmp
            bn.mulvm.l.8S wtmp, coeff13, tf1, 0
            bn.subvm.8S   coeff13, coeff5, wtmp
            bn.addvm.8S   coeff5, coeff5, wtmp
            bn.mulvm.l.8S wtmp, coeff14, tf1, 0
            bn.subvm.8S   coeff14, coeff6, wtmp
            bn.addvm.8S   coeff6, coeff6, wtmp
            bn.mulvm.l.8S wtmp, coeff15, tf1, 0
            bn.subvm.8S   coeff15, coeff7, wtmp
            bn.addvm.8S   coeff7, coeff7, wtmp
            
            /* Layer 2, stride 64 */

            bn.mulvm.l.8S wtmp, coeff4, tf1, 1
            bn.subvm.8S   coeff4, coeff0, wtmp
            bn.addvm.8S   coeff0, coeff0, wtmp
            bn.mulvm.l.8S wtmp, coeff5, tf1, 1
            bn.subvm.8S   coeff5, coeff1, wtmp
            bn.addvm.8S   coeff1, coeff1, wtmp
            bn.mulvm.l.8S wtmp, coeff6, tf1, 1
            bn.subvm.8S   coeff6, coeff2, wtmp
            bn.addvm.8S   coeff2, coeff2, wtmp
            bn.mulvm.l.8S wtmp, coeff7, tf1, 1
            bn.subvm.8S   coeff7, coeff3, wtmp
            bn.addvm.8S   coeff3, coeff3, wtmp
            bn.mulvm.l.8S wtmp, coeff12, tf1, 2
            bn.subvm.8S   coeff12, coeff8, wtmp
            bn.addvm.8S   coeff8, coeff8, wtmp
            bn.mulvm.l.8S wtmp, coeff13, tf1, 2
            bn.subvm.8S   coeff13, coeff9, wtmp
            bn.addvm.8S   coeff9, coeff9, wtmp
            bn.mulvm.l.8S wtmp, coeff14, tf1, 2
            bn.subvm.8S   coeff14, coeff10, wtmp
            bn.addvm.8S   coeff10, coeff10, wtmp
            bn.mulvm.l.8S wtmp, coeff15, tf1, 2
            bn.subvm.8S   coeff15, coeff11, wtmp
            bn.addvm.8S   coeff11, coeff11, wtmp

            /* Layer 3, stride 32 */

            bn.mulvm.l.8S wtmp, coeff2, tf1, 3
            bn.subvm.8S   coeff2, coeff0, wtmp
            bn.addvm.8S   coeff0, coeff0, wtmp
            bn.mulvm.l.8S wtmp, coeff3, tf1, 3
            bn.subvm.8S   coeff3, coeff1, wtmp
            bn.addvm.8S   coeff1, coeff1, wtmp
            bn.mulvm.l.8S wtmp, coeff6, tf1, 4
            bn.subvm.8S   coeff6, coeff4, wtmp
            bn.addvm.8S   coeff4, coeff4, wtmp
            bn.mulvm.l.8S wtmp, coeff7, tf1, 4
            bn.subvm.8S   coeff7, coeff5, wtmp
            bn.addvm.8S   coeff5, coeff5, wtmp
            bn.mulvm.l.8S wtmp, coeff10, tf1, 5
            bn.subvm.8S   coeff10, coeff8, wtmp
            bn.addvm.8S   coeff8, coeff8, wtmp
            bn.mulvm.l.8S wtmp, coeff11, tf1, 5
            bn.subvm.8S   coeff11, coeff9, wtmp
            bn.addvm.8S   coeff9, coeff9, wtmp
            bn.mulvm.l.8S wtmp, coeff14, tf1, 6
            bn.subvm.8S   coeff14, coeff12, wtmp
            bn.addvm.8S   coeff12, coeff12, wtmp
            bn.mulvm.l.8S wtmp, coeff15, tf1, 6
            bn.subvm.8S   coeff15, coeff13, wtmp
            bn.addvm.8S   coeff13, coeff13, wtmp

            /* Layer 4, stride 16 */

            bn.mulvm.l.8S wtmp, coeff1, tf1, 7
            bn.subvm.8S   coeff1, coeff0, wtmp
            bn.addvm.8S   coeff0, coeff0, wtmp
            bn.mulvm.l.8S wtmp, coeff3, tf2, 0
            bn.subvm.8S   coeff3, coeff2, wtmp
            bn.addvm.8S   coeff2, coeff2, wtmp
            bn.mulvm.l.8S wtmp, coeff5, tf2, 1
            bn.subvm.8S   coeff5, coeff4, wtmp
            bn.addvm.8S   coeff4, coeff4, wtmp
            bn.mulvm.l.8S wtmp, coeff7, tf2, 2
            bn.subvm.8S   coeff7, coeff6, wtmp
            bn.addvm.8S   coeff6, coeff6, wtmp
            bn.mulvm.l.8S wtmp, coeff9, tf2, 3
            bn.subvm.8S   coeff9, coeff8, wtmp
            bn.addvm.8S   coeff8, coeff8, wtmp
            bn.mulvm.l.8S wtmp, coeff11, tf2, 4
            bn.subvm.8S   coeff11, coeff10, wtmp
            bn.addvm.8S   coeff10, coeff10, wtmp
            bn.mulvm.l.8S wtmp, coeff13, tf2, 5
            bn.subvm.8S   coeff13, coeff12, wtmp
            bn.addvm.8S   coeff12, coeff12, wtmp
            bn.mulvm.l.8S wtmp, coeff15, tf2, 6
            bn.subvm.8S   coeff15, coeff14, wtmp
            bn.addvm.8S   coeff14, coeff14, wtmp


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
            sw tmp_gpr, 512(outp)
            /* Coeff9 */
            bn.sid coeff9_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 576(outp)
            /* Coeff10 */
            bn.sid coeff10_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 640(outp)
            /* Coeff11 */
            bn.sid coeff11_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 704(outp)
            /* Coeff12 */
            bn.sid coeff12_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 768(outp)
            /* Coeff13 */
            bn.sid coeff13_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 832(outp)
            /* Coeff14 */
            bn.sid coeff14_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 896(outp)
            /* Coeff15 */
            bn.sid coeff15_idx, STACK_WDR2GPR(fp)
            lw tmp_gpr, STACK_WDR2GPR(fp)
            sw tmp_gpr, 960(outp)
            
            /* Go to next coefficient for the unbuffered loads/stores */
            addi inp, inp, 4
            addi outp, outp, 4
            /* Inner Loop End */

        /* Subtract 32 from offset to account for the increment inside the LOOP 8 */
        bn.sid buf0_idx, -32(outp)
        bn.sid buf1_idx, 32(outp)
        bn.sid buf2_idx, 96(outp)
        bn.sid buf3_idx, 160(outp)
        bn.sid buf4_idx, 224(outp)
        bn.sid buf5_idx, 288(outp)
        bn.sid buf6_idx, 352(outp)
        bn.sid buf7_idx, 416(outp)
        /* Outer Loop End */
    
    /* Restore input pointer */
    addi x10, x10, -64
    /* Restore output pointer */
    addi x12, x12, -64

    /* Set the twiddle pointer for layer 5 */
    addi x11, x11, 64

    /* Constants for twiddle factors */
    li x25, 18

    LOOPI 16, 134
        /* Load layer 5 twiddle + 2 layer 6 twiddles + 4 layer 7 twiddles + padding */
        bn.lid x23, 0(x11++)
        /* Load layer 8 layer 8 twiddles */
        bn.lid x24, 0(x11++)

        /* Load Data */
        bn.lid buf0_idx, 0(outp)
        bn.and  coeff0, mask, buf0 >> 0
        bn.and  coeff1, mask, buf0 >> 32
        bn.and  coeff2, mask, buf0 >> 64
        bn.and  coeff3, mask, buf0 >> 96
        bn.and  coeff4, mask, buf0 >> 128
        bn.and  coeff5, mask, buf0 >> 160
        bn.and  coeff6, mask, buf0 >> 192
        bn.and  coeff7, mask, buf0 >> 224

        bn.lid buf0_idx, 32(outp)
        bn.and  coeff8, mask, buf0 >> 0
        bn.and  coeff9, mask, buf0 >> 32
        bn.and  coeff10, mask, buf0 >> 64
        bn.and  coeff11, mask, buf0 >> 96
        bn.and  coeff12, mask, buf0 >> 128
        bn.and  coeff13, mask, buf0 >> 160
        bn.and  coeff14, mask, buf0 >> 192
        bn.and  coeff15, mask, buf0 >> 224

        /* Layer 5, stride 8 */
        /* Butterflies */
        bn.mulvm.l.8S wtmp, coeff8, tf1, 0
        bn.subvm.8S   coeff8, coeff0, wtmp
        bn.addvm.8S   coeff0, coeff0, wtmp
        bn.mulvm.l.8S wtmp, coeff9, tf1, 0
        bn.subvm.8S   coeff9, coeff1, wtmp
        bn.addvm.8S   coeff1, coeff1, wtmp
        bn.mulvm.l.8S wtmp, coeff10, tf1, 0
        bn.subvm.8S   coeff10, coeff2, wtmp
        bn.addvm.8S   coeff2, coeff2, wtmp
        bn.mulvm.l.8S wtmp, coeff11, tf1, 0
        bn.subvm.8S   coeff11, coeff3, wtmp
        bn.addvm.8S   coeff3, coeff3, wtmp
        bn.mulvm.l.8S wtmp, coeff12, tf1, 0
        bn.subvm.8S   coeff12, coeff4, wtmp
        bn.addvm.8S   coeff4, coeff4, wtmp
        bn.mulvm.l.8S wtmp, coeff13, tf1, 0
        bn.subvm.8S   coeff13, coeff5, wtmp
        bn.addvm.8S   coeff5, coeff5, wtmp
        bn.mulvm.l.8S wtmp, coeff14, tf1, 0
        bn.subvm.8S   coeff14, coeff6, wtmp
        bn.addvm.8S   coeff6, coeff6, wtmp
        bn.mulvm.l.8S wtmp, coeff15, tf1, 0
        bn.subvm.8S   coeff15, coeff7, wtmp
        bn.addvm.8S   coeff7, coeff7, wtmp    

        /* Layer 6, stride 4 */
        /* Butterflies */
        bn.mulvm.l.8S wtmp, coeff4, tf1, 1
        bn.subvm.8S coeff4, coeff0, wtmp
        bn.addvm.8S coeff0, coeff0, wtmp
        bn.mulvm.l.8S wtmp, coeff5, tf1, 1
        bn.subvm.8S coeff5, coeff1, wtmp
        bn.addvm.8S coeff1, coeff1, wtmp
        bn.mulvm.l.8S wtmp, coeff6, tf1, 1
        bn.subvm.8S coeff6, coeff2, wtmp
        bn.addvm.8S coeff2, coeff2, wtmp
        bn.mulvm.l.8S wtmp, coeff7, tf1, 1
        bn.subvm.8S coeff7, coeff3, wtmp
        bn.addvm.8S coeff3, coeff3, wtmp
        bn.mulvm.l.8S wtmp, coeff12, tf1, 2
        bn.subvm.8S coeff12, coeff8, wtmp
        bn.addvm.8S coeff8, coeff8, wtmp
        bn.mulvm.l.8S wtmp, coeff13, tf1, 2
        bn.subvm.8S coeff13, coeff9, wtmp
        bn.addvm.8S coeff9, coeff9, wtmp
        bn.mulvm.l.8S wtmp, coeff14, tf1, 2
        bn.subvm.8S coeff14, coeff10, wtmp
        bn.addvm.8S coeff10, coeff10, wtmp
        bn.mulvm.l.8S wtmp, coeff15, tf1, 2
        bn.subvm.8S coeff15, coeff11, wtmp
        bn.addvm.8S coeff11, coeff11, wtmp

        /* Layer 7, stride 2 */
        /* Butterflies */
        bn.mulvm.l.8S wtmp, coeff2, tf1, 3
        bn.subvm.8S coeff2, coeff0, wtmp
        bn.addvm.8S coeff0, coeff0, wtmp
        bn.mulvm.l.8S wtmp, coeff3, tf1, 3
        bn.subvm.8S coeff3, coeff1, wtmp
        bn.addvm.8S coeff1, coeff1, wtmp
        bn.mulvm.l.8S wtmp, coeff6, tf1, 4
        bn.subvm.8S coeff6, coeff4, wtmp
        bn.addvm.8S coeff4, coeff4, wtmp
        bn.mulvm.l.8S wtmp, coeff7, tf1, 4
        bn.subvm.8S coeff7, coeff5, wtmp
        bn.addvm.8S coeff5, coeff5, wtmp
        bn.mulvm.l.8S wtmp, coeff10, tf1, 5
        bn.subvm.8S coeff10, coeff8, wtmp
        bn.addvm.8S coeff8, coeff8, wtmp
        bn.mulvm.l.8S wtmp, coeff11, tf1, 5
        bn.subvm.8S coeff11, coeff9, wtmp
        bn.addvm.8S coeff9, coeff9, wtmp
        bn.mulvm.l.8S wtmp, coeff14, tf1, 6
        bn.subvm.8S coeff14, coeff12, wtmp
        bn.addvm.8S coeff12, coeff12, wtmp
        bn.mulvm.l.8S wtmp, coeff15, tf1, 6
        bn.subvm.8S coeff15, coeff13, wtmp
        bn.addvm.8S coeff13, coeff13, wtmp

        /* Layer 8, stride 1 */

        /* Butterflies */
        bn.mulvm.l.8S wtmp, coeff1, tf1, 7
        bn.subvm.8S coeff1, coeff0, wtmp
        bn.addvm.8S coeff0, coeff0, wtmp
        bn.mulvm.l.8S wtmp, coeff3, tf2, 0
        bn.subvm.8S coeff3, coeff2, wtmp
        bn.addvm.8S coeff2, coeff2, wtmp
        bn.mulvm.l.8S wtmp, coeff5, tf2, 1
        bn.subvm.8S coeff5, coeff4, wtmp
        bn.addvm.8S coeff4, coeff4, wtmp
        bn.mulvm.l.8S wtmp, coeff7, tf2, 2
        bn.subvm.8S coeff7, coeff6, wtmp
        bn.addvm.8S coeff6, coeff6, wtmp
        bn.mulvm.l.8S wtmp, coeff9, tf2, 3
        bn.subvm.8S coeff9, coeff8, wtmp
        bn.addvm.8S coeff8, coeff8, wtmp
        bn.mulvm.l.8S wtmp, coeff11, tf2, 4
        bn.subvm.8S coeff11, coeff10, wtmp
        bn.addvm.8S coeff10, coeff10, wtmp
        bn.mulvm.l.8S wtmp, coeff13, tf2, 5
        bn.subvm.8S coeff13, coeff12, wtmp
        bn.addvm.8S coeff12, coeff12, wtmp
        bn.mulvm.l.8S wtmp, coeff15, tf2, 6
        bn.subvm.8S coeff15, coeff14, wtmp
        bn.addvm.8S coeff14, coeff14, wtmp

        /* Reassemble WDRs and store */
        bn.rshi buf0, coeff0, buf0 >> 32
        bn.rshi buf0, coeff1, buf0 >> 32
        bn.rshi buf0, coeff2, buf0 >> 32
        bn.rshi buf0, coeff3, buf0 >> 32
        bn.rshi buf0, coeff4, buf0 >> 32
        bn.rshi buf0, coeff5, buf0 >> 32
        bn.rshi buf0, coeff6, buf0 >> 32
        bn.rshi buf0, coeff7, buf0 >> 32
        bn.sid buf0_idx, 0(outp++)
        
        bn.rshi buf0, coeff8, buf0 >> 32
        bn.rshi buf0, coeff9, buf0 >> 32
        bn.rshi buf0, coeff10, buf0 >> 32
        bn.rshi buf0, coeff11, buf0 >> 32
        bn.rshi buf0, coeff12, buf0 >> 32
        bn.rshi buf0, coeff13, buf0 >> 32
        bn.rshi buf0, coeff14, buf0 >> 32
        bn.rshi buf0, coeff15, buf0 >> 32
        bn.sid buf0_idx, 0(outp++)

    .irp reg,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1,s0
        pop \reg
    .endr
    
    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32

    add sp, sp, 28
    pop x6
    add sp, sp, x6

    /* Zero w31 again */
    bn.xor w31, w31, w31

    ret