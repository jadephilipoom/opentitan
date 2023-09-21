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

    /* Save callee-saved registers */
    .irp reg,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11
        push \reg
    .endr

    /* Set up constants for input/state */
    li x4, 0
    li x5, 1
    li x6, 2
    li x7, 3
    li x8, 4
    li x9, 5
    li x13, 6
    li x14, 7
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

    /* w16 <= 0xFFFFFFFF for masking */
    bn.addi w16, bn0, 1
    bn.rshi w16, w16, bn0 >> 224
    bn.subi w16, w16, 1 

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

    #define buf0 w31
    #define buf1 w30
    #define buf2 w29
    #define buf3 w28
    #define buf4 w27
    #define buf5 w26
    #define buf6 w25
    #define buf7 w24

    #define wtmp w23
    #define tf1 w16
    #define tf2 w17

    /* We can process 16 coefficients each iteration and need to process N=256, meaning we require 16 iterations. */
    LOOP 2, X
        /* Load coefficients into buffer registers */
        bn.lid buf0, 0(addr)
        bn.lid buf1, 64(addr)
        bn.lid buf2, 128(addr)
        bn.lid buf3, 192(addr)
        bn.lid buf4, 256(addr)
        bn.lid buf5, 320(addr)
        bn.lid buf6, 384(addr)
        bn.lid buf7, 448(addr)
        LOOP 8, Y
            /* Extract coefficients from buffer registers into working state */
            .irp idx,0,1,2,3,4,5,6,7
                bn.and coeff\idx, buf\idx, mask
            .endr
            /* Load remaining coefficients using 32-bit loads */
            /* Coeff 8 */
            lw t0, 512(addr)
            sw t0, 0(STACK_GPR2WDR)
            bn.lid coeff8, 0(STACK_GPR2WDR)
            /* Coeff 9 */
            lw t0, 576(addr)
            sw t0, 0(STACK_GPR2WDR)
            bn.lid coeff9, 0(STACK_GPR2WDR)
            /* Coeff 10 */
            lw t0, 640(addr)
            sw t0, 0(STACK_GPR2WDR)
            bn.lid coeff10, 0(STACK_GPR2WDR)
            /* Coeff 11 */
            lw t0, 704(addr)
            sw t0, 0(STACK_GPR2WDR)
            bn.lid coeff11, 0(STACK_GPR2WDR)
            /* Coeff 12 */
            lw t0, 768(addr)
            sw t0, 0(STACK_GPR2WDR)
            bn.lid coeff12, 0(STACK_GPR2WDR)
            /* Coeff 13 */
            lw t0, 832(addr)
            sw t0, 0(STACK_GPR2WDR)
            bn.lid coeff13, 0(STACK_GPR2WDR)
            /* Coeff 14 */
            lw t0, 896(addr)
            sw t0, 0(STACK_GPR2WDR)
            bn.lid coeff14, 0(STACK_GPR2WDR)
            /* Coeff 15 */
            lw t0, 960(addr)
            sw t0, 0(STACK_GPR2WDR)
            bn.lid coeff15, 0(STACK_GPR2WDR)

            
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
            .irp idx,0,1,2,3,4,5,6,7
                bn.rshi buf\idx, coeff\idx, buf\idx >> 32 /* implicitly removes the old value */
            .endr

            /* Store unbuffered values */
            /* Coeff8 */
            bn.sid coeff8, 0(STACK_GPR2WDR)
            lw t0, 0(STACK_GPR2WDR)
            sw t0, 512(addr)
            /* Coeff9 */
            bn.sid coeff9, 0(STACK_GPR2WDR)
            lw t0, 0(STACK_GPR2WDR)
            sw t0, 576(addr)
            /* Coeff10 */
            bn.sid coeff10, 0(STACK_GPR2WDR)
            lw t0, 0(STACK_GPR2WDR)
            sw t0, 640(addr)
            /* Coeff11 */
            bn.sid coeff11, 0(STACK_GPR2WDR)
            lw t0, 0(STACK_GPR2WDR)
            sw t0, 704(addr)
            /* Coeff12 */
            bn.sid coeff12, 0(STACK_GPR2WDR)
            lw t0, 0(STACK_GPR2WDR)
            sw t0, 768(addr)
            /* Coeff13 */
            bn.sid coeff13, 0(STACK_GPR2WDR)
            lw t0, 0(STACK_GPR2WDR)
            sw t0, 832(addr)
            /* Coeff14 */
            bn.sid coeff14, 0(STACK_GPR2WDR)
            lw t0, 0(STACK_GPR2WDR)
            sw t0, 896(addr)
            /* Coeff15 */
            bn.sid coeff15, 0(STACK_GPR2WDR)
            lw t0, 0(STACK_GPR2WDR)
            sw t0, 960(addr)
            
            /* Go to next coefficient for the unbuffered loads/stores */
            addi addr, addr, 4
            /* Inner Loop End */

            /* Subtract 32 from offset to account for the increment inside the LOOP 8 */
            bn.sid buf0, -64(addr)
            bn.sid buf1, 0(addr)
            bn.sid buf2, 64(addr)
            bn.sid buf3, 128(addr)
            bn.sid buf4, 192(addr)
            bn.sid buf5, 256(addr)
            bn.sid buf6, 320(addr)
            bn.sid buf7, 384(addr)
            /* Outer Loop End */
    
    /* Restore input pointer */
    addi x10, x10, -64
    /* Restore output pointer */
    addi x12, x12, -64

    /* Set the twiddle pointer for layer 5 */
    addi x11, x11, 64

    /* Constants for twiddle factors */
    li x25, 18

LOOPI 2
	LOOPI 2
		/* Load layer 5 twiddles */
        bn.lid x23, 0(x11++)
		LOOPI 2
			/* Load layer 6 twiddles */
            bn.lid x24, 0(x11++)
			LOOPI 2
                /* Load layer 7 twiddles */
                bn.lid x25, 0(x11++)

				/* Load Data */
				bn.lid buf0, 0(addr)
				bn.and  coeff0, mask, buf0 >> 0
				bn.and  coeff1, mask, buf0 >> 32
				bn.and  coeff2, mask, buf0 >> 64
				bn.and  coeff3, mask, buf0 >> 96
				bn.and  coeff4, mask, buf0 >> 128
				bn.and  coeff5, mask, buf0 >> 160
				bn.and  coeff6, mask, buf0 >> 192
				bn.and  coeff7, mask, buf0 >> 224

				bn.lid buf0, 32(addr)
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
                bn.mulvm.l.8S wtmp, coeff1, tf1, 0
                bn.subvm.8S   coeff1, coeff0, wtmp
                bn.addvm.8S   coeff0, coeff0, wtmp
                bn.mulvm.l.8S wtmp, coeff3, tf1, 1
                bn.subvm.8S   coeff3, coeff2, wtmp
                bn.addvm.8S   coeff2, coeff2, wtmp
                bn.mulvm.l.8S wtmp, coeff5, tf1, 2
                bn.subvm.8S   coeff5, coeff4, wtmp
                bn.addvm.8S   coeff4, coeff4, wtmp
                bn.mulvm.l.8S wtmp, coeff7, tf1, 3
                bn.subvm.8S   coeff7, coeff6, wtmp
                bn.addvm.8S   coeff6, coeff6, wtmp
                bn.mulvm.l.8S wtmp, coeff9, tf1, 4
                bn.subvm.8S   coeff9, coeff8, wtmp
                bn.addvm.8S   coeff8, coeff8, wtmp
                bn.mulvm.l.8S wtmp, coeff11, tf1, 5
                bn.subvm.8S   coeff11, coeff10, wtmp
                bn.addvm.8S   coeff10, coeff10, wtmp
                bn.mulvm.l.8S wtmp, coeff13, tf1, 6
                bn.subvm.8S   coeff13, coeff12, wtmp
                bn.addvm.8S   coeff12, coeff12, wtmp
                bn.mulvm.l.8S wtmp, coeff15, tf1, 7
                bn.subvm.8S   coeff15, coeff14, wtmp
                bn.addvm.8S   coeff14, coeff14, wtmp            

                /* Layer 6, stride 4 */
                /* Butterflies */
                bn.mulvm.8S wtmp, coeff4, tf1, 0
                bn.subvm.8S coeff4, coeff0, wtmp
                bn.addvm.8S coeff0, coeff0, wtmp
                bn.mulvm.8S wtmp, coeff5, tf1, 0
                bn.subvm.8S coeff5, coeff1, wtmp
                bn.addvm.8S coeff1, coeff1, wtmp
                bn.mulvm.8S wtmp, coeff6, tf1, 0
                bn.subvm.8S coeff6, coeff2, wtmp
                bn.addvm.8S coeff2, coeff2, wtmp
                bn.mulvm.8S wtmp, coeff7, tf1, 0
                bn.subvm.8S coeff7, coeff3, wtmp
                bn.addvm.8S coeff3, coeff3, wtmp
                bn.mulvm.8S wtmp, coeff12, tf2, 0
                bn.subvm.8S coeff12, coeff8, wtmp
                bn.addvm.8S coeff8, coeff8, wtmp
                bn.mulvm.8S wtmp, coeff13, tf2, 0
                bn.subvm.8S coeff13, coeff9, wtmp
                bn.addvm.8S coeff9, coeff9, wtmp
                bn.mulvm.8S wtmp, coeff14, tf2, 0
                bn.subvm.8S coeff14, coeff10, wtmp
                bn.addvm.8S coeff10, coeff10, wtmp
                bn.mulvm.8S wtmp, coeff15, tf2, 0
                bn.subvm.8S coeff15, coeff11, wtmp
                bn.addvm.8S coeff11, coeff11, wtmp

                /* Layer 7, stride 2 */
                /* Butterflies */
                bn.mulvm.8S wtmp, coeff2, tf1, 0
                bn.subvm.8S coeff2, coeff0, wtmp
                bn.addvm.8S coeff0, coeff0, wtmp
                bn.mulvm.8S wtmp, coeff3, tf1, 0
                bn.subvm.8S coeff3, coeff1, wtmp
                bn.addvm.8S coeff1, coeff1, wtmp
                bn.mulvm.8S wtmp, coeff6, tf2, 0
                bn.subvm.8S coeff6, coeff4, wtmp
                bn.addvm.8S coeff4, coeff4, wtmp
                bn.mulvm.8S wtmp, coeff7, tf2, 0
                bn.subvm.8S coeff7, coeff5, wtmp
                bn.addvm.8S coeff5, coeff5, wtmp
                bn.mulvm.8S wtmp, coeff10, tf3, 0
                bn.subvm.8S coeff10, coeff8, wtmp
                bn.addvm.8S coeff8, coeff8, wtmp
                bn.mulvm.8S wtmp, coeff11, tf3, 0
                bn.subvm.8S coeff11, coeff9, wtmp
                bn.addvm.8S coeff9, coeff9, wtmp
                bn.mulvm.8S wtmp, coeff14, tf4, 0
                bn.subvm.8S coeff14, coeff12, wtmp
                bn.addvm.8S coeff12, coeff12, wtmp
                bn.mulvm.8S wtmp, coeff15, tf4, 0
                bn.subvm.8S coeff15, coeff13, wtmp
                bn.addvm.8S coeff13, coeff13, wtmp

                /* Layer 8, stride 1 */

                /* Butterflies */
                /* Load layer 8 tcoeffiddles - Part 1 */
                bn.lid x25, 0(x11++)
                bn.mulvm.8S wtmp, coeff1, tf1, 0
                bn.subvm.8S coeff1, coeff0, wtmp
                bn.addvm.8S coeff0, coeff0, wtmp
                bn.mulvm.8S wtmp, coeff3, tf2, 0
                bn.subvm.8S coeff3, coeff2, wtmp
                bn.addvm.8S coeff2, coeff2, wtmp
                bn.mulvm.8S wtmp, coeff5, tf3, 0
                bn.subvm.8S coeff5, coeff4, wtmp
                bn.addvm.8S coeff4, coeff4, wtmp
                bn.mulvm.8S wtmp, coeff7, tf4, 0
                bn.subvm.8S coeff7, coeff6, wtmp
                bn.addvm.8S coeff6, coeff6, wtmp
                /* Load layer 8 tcoeffiddles - Part 2 */
                bn.lid x25, 0(x11++)
                bn.mulvm.8S wtmp, coeff9, tf5, 0
                bn.subvm.8S coeff9, coeff8, wtmp
                bn.addvm.8S coeff8, coeff8, wtmp
                bn.mulvm.8S wtmp, coeff11, tf6, 0
                bn.subvm.8S coeff11, coeff10, wtmp
                bn.addvm.8S coeff10, coeff10, wtmp
                bn.mulvm.8S wtmp, coeff13, tf7, 0
                bn.subvm.8S coeff13, coeff12, wtmp
                bn.addvm.8S coeff12, coeff12, wtmp
                bn.mulvm.8S wtmp, coeff15, tf8, 0
                bn.subvm.8S coeff15, coeff14, wtmp
                bn.addvm.8S coeff14, coeff14, wtmp

				/* Reassemble WDRs and store */
				.irp idx,0,1,2,3,4,5,6,7
					bn.rshi buf0, coeff\idx, buf0 >> 32
				.endr
				bn.sid buf0, 0(addr++)
                
				.irp idx,8,9,10,11,12,13,14,15
					bn.rshi buf0, coeff\idx, buf0 >> 32
				.endr
				bn.sid buf0, 0(addr++)

            


    .irp reg,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1,s0
        pop \reg
    .endr

    /* Zero w31 again */
    bn.xor w31, w31, w31

    ret