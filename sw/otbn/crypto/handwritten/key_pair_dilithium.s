.text

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

/* Index of the Keccak command special register. */
.equ KECCAK_CMD_REG, 0x7dc
/* #define KECCAK_CMD_REG 0x7dc*/
/* Command to start a SHAKE-128 operation. */
.equ SHAKE128_START_CMD, 0x1d
/* Command to start a SHAKE-256 operation. */
.equ SHAKE256_START_CMD, 0x5d
/* Command to end an ongoing Keccak operation of any kind. */
.equ KECCAK_DONE_CMD, 0x16
/* Index of the Keccak write-length special register. */
.equ KECCAK_WRITE_LEN_REG, 0x7e0

/* Macros */
.macro push reg
    addi sp, sp, -4      /* Decrement stack pointer by 4 bytes */
    sw \reg, 0(sp)      /* Store register value at the top of the stack */
.endm

.macro pop reg
    lw \reg, 0(sp)      /* Load value from the top of the stack into register */
    addi sp, sp, 4     /* Increment stack pointer by 4 bytes */
.endm

#define rej_sample_check(val, mask, Q, out_ptr, tmp, addr_boundary, label)/*MACRO
MACRO*/     and  val, mask, val /* Mask the bytes from Shake */ /*MACRO
MACRO*/     slt tmp, val, Q   /* (tmp = 1) <= val <? Q */ /*MACRO
MACRO*/     beq  tmp, zero, label /*MACRO
MACRO*/     sw   val, 0(out_ptr) /*MACRO
MACRO*/     beq  out_ptr, addr_boundary, end_rej_sample_loop /*MACRO
MACRO*/     addi out_ptr, out_ptr, 4

/**
 * Send a variable-length message to the Keccak core.
 *
 * Expects the Keccak core to have already received a `start` command matching
 * the desired hash function. After calling this routine, reading from the
 * KECCAK_DIGEST special register will return the hash digest.
 *
 * @param[in]   a1: len, byte-length of the message
 * @param[in]   a0: dptr_msg, pointer to message in DMEM
 * @param[in]   w31: all-zero
 * @param[in] dmem[dptr_msg..dptr_msg+len]: msg, hash function input
 *
 * clobbered registers: t0, a1, w0
 * clobbered flag groups: None
 */
keccak_send_message:
  /* Compute the number of full 256-bit message chunks.
       t0 <= x11 >> 5 = floor(len / 32) */
  srli     t0, x11, 5

  /* Write all full 256-bit sections of the test message. */
  beq t0, zero, no_full_wdr
  loop     t0, 2
    /* w0 <= dmem[x10..x10+32] = msg[32*i..32*i-1]
       x10 <= x10 + 32 */
    bn.lid   x0, 0(x10++)
    /* Write to the KECCAK_MSG wide special register (index 8).
         KECCAK_MSG <= w0 */
    bn.wsrw  0x8, w0
no_full_wdr:
  /* Compute the remaining message length.
       t0 <= x10 & 31 = len mod 32 */
  andi     t0, x11, 31

  /* If the remaining length is zero, return early. */
  beq      t0, x0, _keccak_send_message_end

  /* Partial write: set KECCAK_WRITE_LEN special register before sending. */
  csrrw    x0, KECCAK_WRITE_LEN_REG, t0
  bn.lid   x0, 0(x10)
  bn.wsrw  0x8, w0

  _keccak_send_message_end:
  ret

/**
 * poly_uniform
 *
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]     a0: pointer to rho
 * @param[in]     a2: nonce
 * @param[in]     a1: dmem pointer to polynomial
 *
 * clobbered registers: w8
 */
.global poly_uniform
poly_uniform:
    /* 32 byte align the sp */
    andi s11, sp, 31
    beq s11, zero, aligned
    sub sp, sp, s11
aligned:
    /* save fp to stack */
    addi sp, sp, -32
    sw fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -64

    /* Reserve space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR -32

    /* Reserve space for the nonce */
    #define STACK_NONCE -64

    /* Store nonce to memory */
    sw a2, STACK_NONCE(fp)

    /* Load Q to GPR */
    addi a2, zero, 128
    slli a2, a2, 16
    addi a3, zero, 32
    slli a3, a3, 8
    sub a2, a2, a3
    addi a2, a2, 1
    
    /* Initialize a SHAKE128 operation. */
    addi      t0, zero, SHAKE128_START_CMD
    csrrw     zero, KECCAK_CMD_REG, t0

    /* Send the message to the Keccak core. */
    addi a4, a1, 0 /* save output pointer */
    addi a1, zero, 32 /* set message length */
    jal  x1, keccak_send_message /* a0 already contains the input buffer */
    addi a1, zero, 2 /* set message length */
    addi a0, fp, STACK_NONCE
    jal  x1, keccak_send_message

    addi a1, a4, 0 /* move output pointer back to a1 */
    
    addi s0, zero, 8 

    /* t0 = 1020, last valid address*/
    addi t0, a1, 1020
    /* Load mask */
    li t2, 0x7FFFFF

rej_sample_loop:
    /* First squeeze */
    .equ w8, shake_reg
    bn.wsrr  shake_reg, 0x9 /* KECCAK_DIGEST */

    /* Process floor(32/3)*3 = 30 bytes */
    /* Init loop counter because we cannot early exit hw loops */
    addi t4, zero, 10
_rej_sample_loop_p1:
        /* Get least significant word into GPR */
        bn.sid s0, STACK_WDR2GPR(fp)
        lw     t1, STACK_WDR2GPR(fp)
        bn.or  shake_reg, bn0, shake_reg >> 24
        rej_sample_check(t1, t2, a2, a1, t3, t0, skip_store1)
skip_store1:
    addi t4, t4, -1
    bne t4, zero, _rej_sample_loop_p1
    /* Process remaining 2 bytes */
    /* Get last two bytes of shake output in shake_reg into GPR */
    bn.sid s0, STACK_WDR2GPR(fp)
    lw     t1, STACK_WDR2GPR(fp)
    /* Squeeze */
    bn.wsrr  shake_reg, 0x9 /* KECCAK_DIGEST */
    bn.sid s0, STACK_WDR2GPR(fp)
    lw     t3, STACK_WDR2GPR(fp)
    /* We read 1 byte from shake, so shift by 8 */
    bn.or  shake_reg, bn0, shake_reg >> 8
    /* Only keep lower byte */
    andi t3, t3, 0xFF
    /* Shift it to be byte 3 */
    slli t3, t3, 16
    or t1, t3, t1
    rej_sample_check(t1, t2, a2, a1, t3, t0, skip_store2)
skip_store2:

    /* Process floor(31/3)*3 = 30 bytes */
    /* Init loop counter because we cannot early exit hw loops */
    addi t4, zero, 10
_rej_sample_loop_p2:
        /* Get least significant word into GPR */
        bn.sid s0, STACK_WDR2GPR(fp)
        lw     t1, STACK_WDR2GPR(fp)
        bn.or  shake_reg, bn0, shake_reg >> 24
        rej_sample_check(t1, t2, a2, a1, t3, t0, skip_store3)
skip_store3:
    addi t4, t4, -1
    bne t4, zero, _rej_sample_loop_p2

    /* Process remaining 1 byte */
    /* Get last byte of shake output in shake_reg into GPR */
    bn.sid s0, STACK_WDR2GPR(fp)
    lw     t1, STACK_WDR2GPR(fp)
    /* Squeeze */
    bn.wsrr  shake_reg, 0x9 /* KECCAK_DIGEST */
    bn.sid s0, STACK_WDR2GPR(fp)
    lw     t3, STACK_WDR2GPR(fp)
    /* We read 2 byte from shake, so shift by 16 */
    bn.or  shake_reg, bn0, shake_reg >> 16
    /* Only keep lower bytes */
    li  t4, 0xFFFF
    and t3, t3, t4
    /* Shift to be bytes 2+3 */
    slli t3, t3, 8
    or t1, t1, t3 
    rej_sample_check(t1, t2, a2, a1, t3, t0, skip_store4)
skip_store4:

    /* Process floor(30/3)*3 = 30 bytes */
    /* Init loop counter because we cannot early exit hw loops */
    addi t4, zero, 10
_rej_sample_loop_p3:
        /* Get least significant word into GPR */
        bn.sid s0, STACK_WDR2GPR(fp)
        lw     t1, STACK_WDR2GPR(fp)
        bn.or  shake_reg, bn0, shake_reg >> 24
        rej_sample_check(t1, t2, a2, a1, t3, t0, skip_store5)
skip_store5:
    addi t4, t4, -1
    bne t4, zero, _rej_sample_loop_p3

    /* No remainder! Start all over again. */
    beq zero, zero, rej_sample_loop
end_rej_sample_loop:
    /* Finish the SHAKE-256 operation. */
    addi      t0, zero, KECCAK_DONE_CMD
    csrrw     zero, KECCAK_CMD_REG, t0

    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32
    /* Correct alignment offset (unalign) */
    add sp, sp, s11

    ret

/**
 * poly_uniform_eta
 *
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]     a0: pointer to rho
 * @param[in]     a2: nonce
 * @param[in]     a1: dmem pointer to polynomial
 *
 * clobbered registers: w8, w9, w10, w11, w12, w13
 */
.global poly_uniform_eta
poly_uniform_eta:
/* 32 byte align the sp */
    andi s11, sp, 31
    beq s11, zero, _aligned_poly_uniform_eta
    sub sp, sp, s11
_aligned_poly_uniform_eta:
    /* save fp to stack */
    addi sp, sp, -32
    sw fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -64

    /* Reserve space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR -32

    /* Reserve space for the nonce */
    #define STACK_NONCE -64

    /* Store nonce to memory */
    sw a2, STACK_NONCE(fp)

    /* Load a3 <- Q */
    addi a3, zero, 128
    slli a3, a3, 16
    addi a4, zero, 32
    slli a4, a4, 8
    sub a3, a3, a4
    addi a3, a3, 1
    
    /* Initialize a SHAKE256 operation. */
    addi      t0, zero, SHAKE256_START_CMD
    csrrw     zero, KECCAK_CMD_REG, t0

    /* Send the message to the Keccak core. */
    addi a4, a1, 0 /* save output pointer */
    addi a1, zero, 64 /* set message length */
    jal  x1, keccak_send_message /* a0 already contains the input buffer */
    addi a1, zero, 2 /* set message length */
    addi a0, fp, STACK_NONCE
    jal  x1, keccak_send_message

    addi a1, a4, 0 /* move output pointer back to a1 */
    
    addi s0, zero, 8 

    /* t0 = 1024, stop address*/
    addi t0, a1, 1024
    addi t5, zero, 15
rej_eta_sample_loop:
        /* First squeeze */
        .equ w8, shake_reg
        bn.wsrr  shake_reg, 0x9 /* KECCAK_DIGEST */
        
        /* Loop counter, we have 32B to read from shake */
        addi t4, zero, 32
        bn.addi w14, bn0, 0xFF
        bn.addi w15, bn0, 15
rej_eta_sample_loop_inner:
            /* Get state into working copy */
            bn.add w9, shake_reg, bn0
            /* shift out the used byte */
            bn.or  shake_reg, bn0, shake_reg >> 8
            
            /* Mask out all other bytes */
            bn.and  w9, w9, w14
            /* Prepare "t1" */
            bn.rshi w10, bn0, w9 >> 4
            /* Prepare "t0" */
            bn.and  w9, w9, w15

            /* Instead of < 15, != 15 can also be checked */
            bn.cmp w9, w15
             /* Get the FG0.Z flag into a register.
                t2 <= (CSRs[FG0] >> 3) & 1 = FG0.Z */
            csrrs    t2, 0x7c0, zero
            srli     t2, t2, 3
            andi     t2, t2, 1

            bne t2, zero, rej_eta_sample_loop_inner_1

            /* t0 = t0 - (205*t0 >> 10)*5; */
            /* 205 * t0 */
            bn.addi w12, bn0, 205
            bn.mulmv.l.8S w13, w12, w9, 0, nored
            /* (205 * t0 >> 10) */
            bn.rshi w13, bn0, w13 >> 10
            /* (205*t0 >> 10)*5 */
            bn.addi w12, bn0, 5
            bn.mulmv.l.8S w13, w12, w13, 0, nored
            /* t0 - (205 * t0 >> 10) * 5 */
            bn.submv.8S w9, w9, w13 nored
            /* 2 - (t0 - (205 * t0 >> 10) * 5) */
            bn.addi w13, bn0, 2
            bn.submv.8S w9, w13, w9 nored

            /* WDR to GPR */
            addi t2, zero, 9
            bn.sid t2, STACK_WDR2GPR(fp)
            lw     t2, STACK_WDR2GPR(fp)
            sw     t2, 0(a1)
            addi a1, a1, 4
            beq a1, t0, end_rej_eta_sample_loop

            /* if(t1 < 15 && ctr < len) { */
rej_eta_sample_loop_inner_1:
            bn.addi w11, bn0, 15
            bn.cmp w10, w11
             /* Get the FG0.Z flag into a register.
                t2 <= (CSRs[FG0] >> 3) & 1 = FG0.Z */
            csrrs    t2, 0x7c0, zero
            srli     t2, t2, 3
            andi     t2, t2, 1

            bne t2, zero, rej_eta_sample_loop_inner_none

            /* t1 = t1 - (205*t1 >> 10)*5; */
            /* 205 * t1 */
            bn.addi w12, w31, 205
            bn.mulmv.l.8S w13, w12, w10, 0, nored
            /* (205 * t1 >> 10) */
            bn.rshi w13, bn0, w13 >> 10
            /* (205*t1 >> 10)*5 */
            bn.addi w12, bn0, 5
            bn.mulmv.8S w13, w12, w13, 0, nored
            /* t1 - (205 * t1 >> 10) * 5 */
            bn.submv.8S w10, w10, w13 nored
            /* 2 - (t1 - (205 * t1 >> 10) * 5) */
            bn.addi w13, bn0, 2
            bn.submv.8S w10, w13, w10 nored

            addi t2, zero, 10
            bn.sid t2, STACK_WDR2GPR(fp)
            lw     t2, STACK_WDR2GPR(fp)
            sw     t2, 0(a1)
            addi a1, a1, 4
            beq a1, t0, end_rej_eta_sample_loop

rej_eta_sample_loop_inner_none:

            addi t4, t4, -1
            bne zero, t4, rej_eta_sample_loop_inner

        /* Start all over again. */
        beq zero, zero, rej_eta_sample_loop
end_rej_eta_sample_loop:
    /* Finish the SHAKE-256 operation. */
    addi      t0, zero, KECCAK_DONE_CMD
    csrrw     zero, KECCAK_CMD_REG, t0

    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32
    /* Correct alignment offset (unalign) */
    add sp, sp, s11

    ret

/**
 * polyt1_pack_dilithium
 *
 * Bit-pack polynomial t1 with coefficients fitting in 10 bits. Input
 * coefficients are assumed to be standard representatives.
 * 
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]     a0: pointer to output byte array with at least
                      POLYT1_PACKEDBYTES bytes
 * @param[in]     a1: pointer to input polynomial
 *
 * clobbered registers: a0-a1, t0-t2
 */

polyt1_pack_dilithium:
    /* Collect bytes in a2 */
    LOOPI 16, 63
        xor t2, t2, t2
        /* coefficient 1 */
        lw t0, 0(a1)
        or t2, t2, t0 /* 10 */
        /* coefficient 2 */
        lw t0, 4(a1)
        slli t1, t0, 10
        or t2, t2, t1 /* 20 */
        /* coefficient 3 */
        lw t0, 8(a1)
        slli t1, t0, 20
        or t2, t2, t1 /* 30 */
        /* coefficient 4 - 2 bits */
        lw t0, 12(a1)
        slli t1, t0, 30
        or t2, t2, t1 /* 32 */
        /* Store 32 bits */
        sw t2, 0(a0)
        /* coefficient 4 - 8 bits */
        srli t0, t0, 2
        or t2, zero, t0 /* 8 */

        /* coefficient 5 */
        lw t0, 16(a1)
        slli t1, t0, 8
        or t2, t2, t1 /* 18 */
        /* coefficient 6 */
        lw t0, 20(a1)
        slli t1, t0, 18
        or t2, t2, t1 /* 28 */
        /* coefficient 7 - 4 bits */
        lw t0, 24(a1)
        slli t1, t0, 28
        or t2, t2, t1
        /* Store 32 bits */
        sw t2, 4(a0)
        /* coefficient 7 - 6 bits */
        srli t0, t0, 4
        or t2, zero, t0 /* 6 */

        /* coefficient 8 */
        lw t0, 28(a1)
        slli t1, t0, 6
        or t2, t2, t1 /* 16 */
        /* coefficient 9 */
        lw t0, 32(a1)
        slli t1, t0, 16
        or t2, t2, t1 /* 26 */
        /* coefficient 10 - 6 bits */
        lw t0, 36(a1)
        slli t1, t0, 26
        or t2, t2, t1
        /* Store 32 bits */
        sw t2, 8(a0)
        /* coefficient 10 - 4 bits */
        srli t0, t0, 6
        or t2, zero, t0 /* 4 */

        /* coefficient 11 */
        lw t0, 40(a1)
        slli t1, t0, 4
        or t2, t2, t1 /* 14 */
        /* coefficient 12 */
        lw t0, 44(a1)
        slli t1, t0, 14
        or t2, t2, t1 /* 24 */
        /* coefficient 13 - 8 bits */
        lw t0, 48(a1)
        slli t1, t0, 24
        or t2, t2, t1
        /* Store 32 bits */
        sw t2, 12(a0)
        /* coefficient 13 - 2 bits */
        srli t0, t0, 8
        or t2, zero, t0 /* 2 */

        /* coefficient 14 */
        lw t0, 52(a1)
        slli t1, t0, 2
        or t2, t2, t1 /* 12 */
        /* coefficient 15 */
        lw t0, 56(a1)
        slli t1, t0, 12
        or t2, t2, t1 /* 22 */
        /* coefficient 16 */
        lw t0, 60(a1)
        slli t0, t0, 22
        or t2, t2, t0 /* 32 */
        sw t2, 16(a0)

        addi a1, a1, 64
        addi a0, a0, 20

    ret

/**
 * polyeta_pack_dilithium
 *
 * Bit-pack polynomial with coefficients in [-ETA,ETA].
 * 
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]     a0: pointer to output byte array with at least
                      POLYETA_PACKEDBYTES bytes
 * @param[in]     a1: pointer to input polynomial
 *
 * clobbered registers: a0-a1, t0-t3, w1, w2
 */

polyeta_pack_dilithium:
    /* Compute ETA - coeff */
    /* Setup WDRs */
    addi t1, zero, 1
    addi t2, zero, 2

    /* Load precomputed eta */
    la t0, eta
    bn.lid t1, 0(t0)

    LOOPI 32, 4
        /* w2 <= coeffs[i:i+8] */
        bn.lid t2, 0(a1)
        /* w2 <= eta - w2 */
        bn.submv.8S w2, w1, w2 nored
        /* coeffs[i:i+8] <= w2 */
        bn.sid t2, 0(a1)
        addi a1, a1, 32

    /* reset pointer */
    addi a1, a1, -1024

    /* Collect bytes in t3 */
    LOOPI 8, 105
        xor t3, t3, t3
        /* oooooooooooooooooooooooooooooooo */
        /* coefficient 0 */
        lw t0, 0(a1)
        or t3, t3, t0 /* 0 */
        /* ***ooooooooooooooooooooooooooooo| */
        /* coefficient 1 */
        lw t0, 4(a1)
        slli t1, t0, 3
        or t3, t3, t1 /* 3 */
        /* ******oooooooooooooooooooooooooo| */
        /* coefficient 2 */
        lw t0, 8(a1)
        slli t1, t0, 6
        or t3, t3, t1 /* 6 */
        /* *********ooooooooooooooooooooooo| */
        /* coefficient 3 */
        lw t0, 12(a1)
        slli t1, t0, 9
        or t3, t3, t1 /* 9 */
        /* ************oooooooooooooooooooo| */
        /* coefficient 4 */
        lw t0, 16(a1)
        slli t1, t0, 12
        or t3, t3, t1 /* 12 */
        /* ***************ooooooooooooooooo| */
        /* coefficient 5 */
        lw t0, 20(a1)
        slli t1, t0, 15
        or t3, t3, t1 /* 15 */
        /* ******************oooooooooooooo| */
        /* coefficient 6 */
        lw t0, 24(a1)
        slli t1, t0, 18
        or t3, t3, t1 /* 18 */
        /* *********************ooooooooooo| */
        /* coefficient 7 */
        lw t0, 28(a1)
        slli t1, t0, 21
        or t3, t3, t1 /* 21 */
        /* ************************oooooooo| */
        /* coefficient 8 */
        lw t0, 32(a1)
        slli t1, t0, 24
        or t3, t3, t1 /* 24 */
        /* ***************************ooooo| */
        /* coefficient 9 */
        lw t0, 36(a1)
        slli t1, t0, 27
        or t3, t3, t1 /* 27 */
        /* ******************************oo| */
        /* coefficient 10 */
        lw t0, 40(a1)
        slli t1, t0, 30
        or t3, t3, t1 /* 30 */
        /* ********************************|x */
        sw t3, 0(a0)
        srli t0, t0, 2
        or t3, zero, t0
        /* *ooooooooooooooooooooooooooooooo */
        /* coefficient 11 */
        lw t0, 44(a1)
        slli t1, t0, 1
        or t3, t3, t1 /* 1 */
        /* ****oooooooooooooooooooooooooooo| */
        /* coefficient 12 */
        lw t0, 48(a1)
        slli t1, t0, 4
        or t3, t3, t1 /* 4 */
        /* *******ooooooooooooooooooooooooo| */
        /* coefficient 13 */
        lw t0, 52(a1)
        slli t1, t0, 7
        or t3, t3, t1 /* 7 */
        /* **********oooooooooooooooooooooo| */
        /* coefficient 14 */
        lw t0, 56(a1)
        slli t1, t0, 10
        or t3, t3, t1 /* 10 */
        /* *************ooooooooooooooooooo| */
        /* coefficient 15 */
        lw t0, 60(a1)
        slli t1, t0, 13
        or t3, t3, t1 /* 13 */
        /* ****************oooooooooooooooo| */
        /* coefficient 16 */
        lw t0, 64(a1)
        slli t1, t0, 16
        or t3, t3, t1 /* 16 */
        /* *******************ooooooooooooo| */
        /* coefficient 17 */
        lw t0, 68(a1)
        slli t1, t0, 19
        or t3, t3, t1 /* 19 */
        /* **********************oooooooooo| */
        /* coefficient 18 */
        lw t0, 72(a1)
        slli t1, t0, 22
        or t3, t3, t1 /* 22 */
        /* *************************ooooooo| */
        /* coefficient 19 */
        lw t0, 76(a1)
        slli t1, t0, 25
        or t3, t3, t1 /* 25 */
        /* ****************************oooo| */
        /* coefficient 20 */
        lw t0, 80(a1)
        slli t1, t0, 28
        or t3, t3, t1 /* 28 */
        /* *******************************o| */
        /* coefficient 21 */
        lw t0, 84(a1)
        slli t1, t0, 31
        or t3, t3, t1 /* 31 */
        /* ********************************|xx */
        sw t3, 4(a0)
        srli t0, t0, 1
        or t3, zero, t0
        /* **oooooooooooooooooooooooooooooo */
        /* coefficient 22 */
        lw t0, 88(a1)
        slli t1, t0, 2
        or t3, t3, t1 /* 2 */
        /* *****ooooooooooooooooooooooooooo| */
        /* coefficient 23 */
        lw t0, 92(a1)
        slli t1, t0, 5
        or t3, t3, t1 /* 5 */
        /* ********oooooooooooooooooooooooo| */
        /* coefficient 24 */
        lw t0, 96(a1)
        slli t1, t0, 8
        or t3, t3, t1 /* 8 */
        /* ***********ooooooooooooooooooooo| */
        /* coefficient 25 */
        lw t0, 100(a1)
        slli t1, t0, 11
        or t3, t3, t1 /* 11 */
        /* **************oooooooooooooooooo| */
        /* coefficient 26 */
        lw t0, 104(a1)
        slli t1, t0, 14
        or t3, t3, t1 /* 14 */
        /* *****************ooooooooooooooo| */
        /* coefficient 27 */
        lw t0, 108(a1)
        slli t1, t0, 17
        or t3, t3, t1 /* 17 */
        /* ********************oooooooooooo| */
        /* coefficient 28 */
        lw t0, 112(a1)
        slli t1, t0, 20
        or t3, t3, t1 /* 20 */
        /* ***********************ooooooooo| */
        /* coefficient 29 */
        lw t0, 116(a1)
        slli t1, t0, 23
        or t3, t3, t1 /* 23 */
        /* **************************oooooo| */
        /* coefficient 30 */
        lw t0, 120(a1)
        slli t1, t0, 26
        or t3, t3, t1 /* 26 */
        /* *****************************ooo| */
        /* coefficient 31 */
        lw t0, 124(a1)
        slli t1, t0, 29
        or t3, t3, t1 /* 29 */
        /* ********************************| */
        sw t3, 8(a0)

        addi a1, a1, 128
        addi a0, a0, 12

    ret

/**
 * polyt0_pack_dilithium
 *
 * Bit-pack polynomial t0 with coefficients in ]-2^{D-1}, 2^{D-1}].
 * 
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]     a0: pointer to output byte array with at least
                      POLYETA_PACKEDBYTES bytes
 * @param[in]     a1: pointer to input polynomial
 *
 * clobbered registers: a0-a1, t0-t3, w1, w2
 */

polyt0_pack_dilithium:
    /* Compute (1 << (D-1)) - coeff */
    /* Setup WDRs */
    addi t1, zero, 1
    addi t2, zero, 2
    /* Load precomputed (1 << (D-1)) */
    la t0, polyt0_pack_const
    bn.lid t1, 0(t0)
    /* This loop overwrites the original t0 */
    LOOPI 32, 4
        /* w2 <= coeffs[i:i+8] */
        bn.lid t2, 0(a1)
        /* w2 <= (1 << (D-1)) - coeffs */
        bn.submv.8S w2, w1, w2 nored
        /* coeffs[i:i+8] <= w2 */
        bn.sid t2, 0(a1)
        addi a1, a1, 32

    /* reset pointer */
    addi a1, a1, -1024

    LOOPI 8, 135
        xor t3, t3, t3
        /* oooooooooooooooooooooooooooooooo */
        /* coefficient 0 */
        lw t0, 0(a1)
        or t3, t3, t0 /* 0 */
        /* *************ooooooooooooooooooo| */
        /* coefficient 1 */
        lw t0, 4(a1)
        slli t1, t0, 13
        or t3, t3, t1 /* 13 */
        /* **************************oooooo| */
        /* coefficient 2 */
        lw t0, 8(a1)
        slli t1, t0, 26
        or t3, t3, t1 /* 26 */
        /* ********************************|xxxxxxx */
        sw t3, 0(a0)
        srli t0, t0, 6
        or t3, zero, t0
        /* *******ooooooooooooooooooooooooo */
        /* coefficient 3 */
        lw t0, 12(a1)
        slli t1, t0, 7
        or t3, t3, t1 /* 7 */
        /* ********************oooooooooooo| */
        /* coefficient 4 */
        lw t0, 16(a1)
        slli t1, t0, 20
        or t3, t3, t1 /* 20 */
        /* ********************************|x */
        sw t3, 4(a0)
        srli t0, t0, 12
        or t3, zero, t0
        /* *ooooooooooooooooooooooooooooooo */
        /* coefficient 5 */
        lw t0, 20(a1)
        slli t1, t0, 1
        or t3, t3, t1 /* 1 */
        /* **************oooooooooooooooooo| */
        /* coefficient 6 */
        lw t0, 24(a1)
        slli t1, t0, 14
        or t3, t3, t1 /* 14 */
        /* ***************************ooooo| */
        /* coefficient 7 */
        lw t0, 28(a1)
        slli t1, t0, 27
        or t3, t3, t1 /* 27 */
        /* ********************************|xxxxxxxx */
        sw t3, 8(a0)
        srli t0, t0, 5
        or t3, zero, t0
        /* ********oooooooooooooooooooooooo */
        /* coefficient 8 */
        lw t0, 32(a1)
        slli t1, t0, 8
        or t3, t3, t1 /* 8 */
        /* *********************ooooooooooo| */
        /* coefficient 9 */
        lw t0, 36(a1)
        slli t1, t0, 21
        or t3, t3, t1 /* 21 */
        /* ********************************|xx */
        sw t3, 12(a0)
        srli t0, t0, 11
        or t3, zero, t0
        /* **oooooooooooooooooooooooooooooo */
        /* coefficient 10 */
        lw t0, 40(a1)
        slli t1, t0, 2
        or t3, t3, t1 /* 2 */
        /* ***************ooooooooooooooooo| */
        /* coefficient 11 */
        lw t0, 44(a1)
        slli t1, t0, 15
        or t3, t3, t1 /* 15 */
        /* ****************************oooo| */
        /* coefficient 12 */
        lw t0, 48(a1)
        slli t1, t0, 28
        or t3, t3, t1 /* 28 */
        /* ********************************|xxxxxxxxx */
        sw t3, 16(a0)
        srli t0, t0, 4
        or t3, zero, t0
        /* *********ooooooooooooooooooooooo */
        /* coefficient 13 */
        lw t0, 52(a1)
        slli t1, t0, 9
        or t3, t3, t1 /* 9 */
        /* **********************oooooooooo| */
        /* coefficient 14 */
        lw t0, 56(a1)
        slli t1, t0, 22
        or t3, t3, t1 /* 22 */
        /* ********************************|xxx */
        sw t3, 20(a0)
        srli t0, t0, 10
        or t3, zero, t0
        /* ***ooooooooooooooooooooooooooooo */
        /* coefficient 15 */
        lw t0, 60(a1)
        slli t1, t0, 3
        or t3, t3, t1 /* 3 */
        /* ****************oooooooooooooooo| */
        /* coefficient 16 */
        lw t0, 64(a1)
        slli t1, t0, 16
        or t3, t3, t1 /* 16 */
        /* *****************************ooo| */
        /* coefficient 17 */
        lw t0, 68(a1)
        slli t1, t0, 29
        or t3, t3, t1 /* 29 */
        /* ********************************|xxxxxxxxxx */
        sw t3, 24(a0)
        srli t0, t0, 3
        or t3, zero, t0
        /* **********oooooooooooooooooooooo */
        /* coefficient 18 */
        lw t0, 72(a1)
        slli t1, t0, 10
        or t3, t3, t1 /* 10 */
        /* ***********************ooooooooo| */
        /* coefficient 19 */
        lw t0, 76(a1)
        slli t1, t0, 23
        or t3, t3, t1 /* 23 */
        /* ********************************|xxxx */
        sw t3, 28(a0)
        srli t0, t0, 9
        or t3, zero, t0
        /* ****oooooooooooooooooooooooooooo */
        /* coefficient 20 */
        lw t0, 80(a1)
        slli t1, t0, 4
        or t3, t3, t1 /* 4 */
        /* *****************ooooooooooooooo| */
        /* coefficient 21 */
        lw t0, 84(a1)
        slli t1, t0, 17
        or t3, t3, t1 /* 17 */
        /* ******************************oo| */
        /* coefficient 22 */
        lw t0, 88(a1)
        slli t1, t0, 30
        or t3, t3, t1 /* 30 */
        /* ********************************|xxxxxxxxxxx */
        sw t3, 32(a0)
        srli t0, t0, 2
        or t3, zero, t0
        /* ***********ooooooooooooooooooooo */
        /* coefficient 23 */
        lw t0, 92(a1)
        slli t1, t0, 11
        or t3, t3, t1 /* 11 */
        /* ************************oooooooo| */
        /* coefficient 24 */
        lw t0, 96(a1)
        slli t1, t0, 24
        or t3, t3, t1 /* 24 */
        /* ********************************|xxxxx */
        sw t3, 36(a0)
        srli t0, t0, 8
        or t3, zero, t0
        /* *****ooooooooooooooooooooooooooo */
        /* coefficient 25 */
        lw t0, 100(a1)
        slli t1, t0, 5
        or t3, t3, t1 /* 5 */
        /* ******************oooooooooooooo| */
        /* coefficient 26 */
        lw t0, 104(a1)
        slli t1, t0, 18
        or t3, t3, t1 /* 18 */
        /* *******************************o| */
        /* coefficient 27 */
        lw t0, 108(a1)
        slli t1, t0, 31
        or t3, t3, t1 /* 31 */
        /* ********************************|xxxxxxxxxxxx */
        sw t3, 40(a0)
        srli t0, t0, 1
        or t3, zero, t0
        /* ************oooooooooooooooooooo */
        /* coefficient 28 */
        lw t0, 112(a1)
        slli t1, t0, 12
        or t3, t3, t1 /* 12 */
        /* *************************ooooooo| */
        /* coefficient 29 */
        lw t0, 116(a1)
        slli t1, t0, 25
        or t3, t3, t1 /* 25 */
        /* ********************************|xxxxxx */
        sw t3, 44(a0)
        srli t0, t0, 7
        or t3, zero, t0
        /* ******oooooooooooooooooooooooooo */
        /* coefficient 30 */
        lw t0, 120(a1)
        slli t1, t0, 6
        or t3, t3, t1 /* 6 */
        /* *******************ooooooooooooo| */
        /* coefficient 31 */
        lw t0, 124(a1)
        slli t1, t0, 19
        or t3, t3, t1 /* 19 */
        /* ********************************| */
        sw t3, 48(a0)

        addi a1, a1, 128
        addi a0, a0, 52
    
    ret

/**
 * Dilithium Key Pair generation
 *
 * Returns: 0 on success
 *
 * Flags: TODO
 *
 * @param[in]  x10: zeta (random bytes)
 * @param[in]  x31: dptr_tw, dmem pointer to array of twiddle factors
 * @param[out] x10: dmem pointer to public key
 * @param[out] x11: dmem pointer to private key
 *
 * clobbered registers: TODO
 *                      TODO
 */
.globl key_pair_dilithium
key_pair_dilithium:
    /* Stack address mapping */
    #define STACK_SEEDBUF -160
        #define STACK_RHO -160
        #define STACK_RHOPRIME -128
        #define STACK_KEY -64
    #define STACK_MAT -16576
    #define STACK_S1  -20672
    #define STACK_S2  -24768
    #define STACK_T1  -28864
    #define STACK_T0  -32960
    #define STACK_PK_ADDR -32964
    #define STACK_SK_ADDR -32968
    #define STACK_TR -33024
    #define STACK_S1_HAT  -37120
    /* Initialize the frame pointer */
    addi fp, sp, 0

    /* Reserve space on the stack */
    li t0, -38400
    add sp, sp, t0

    /* Store parameters to stack */
    /* TODO: Select correct registers (zeta gets removed) */
    li t0, STACK_PK_ADDR
    add t0, fp, t0
    sw a1, 0(t0)
    li t0, STACK_SK_ADDR
    add t0, fp, t0
    sw a2, 0(t0)

    /* Initialize a SHAKE256 operation. */
    addi      t0, zero, SHAKE256_START_CMD
    csrrw     zero, KECCAK_CMD_REG, t0

    /* Send the message to the Keccak core. */
    addi a1, zero, 32
    jal  x1, keccak_send_message

    /* Squeeze into output buffer */
    /* load seedbuf address */
    addi t1, fp, STACK_SEEDBUF
    /* Read the digest from the KECCAK_DIGEST special register (index 8).
       dmem[STACK_SEEDBUF] <= SHAKE256(zeta, 1024) */
    li t0, 8
    LOOPI 4, 3
        bn.wsrr  w8, 0x9 /* KECCAK_DIGEST */
        bn.sid t0, 0(t1) /* Store into buffer */
        addi t1, t1, 32

    /* Finish the SHAKE-256 operation. */
    addi      t0, zero, KECCAK_DONE_CMD
    csrrw     zero, KECCAK_CMD_REG, t0

    /* expand matrix */
    /* ! specific to dilithium2 */
    /* initialize the nonce */
    addi a2, zero, 0

    li s1, STACK_MAT
    add a1, fp, s1
    LOOPI 4, 10
        LOOPI 4, 8
            /* Load parameters */
            addi a0, fp, STACK_RHO
            push a2
            jal  x1, poly_uniform
            pop a2
            addi a1, a1, 4
            addi a2, a2, 1
        addi a2, a2, 252

    /* Sample s1 */
    /* initialize the nonce */
    addi a2, zero, 0
    /* Load output pointer */
    li s1, STACK_S1
    add a1, fp, s1
    LOOPI 4, 3
        /* Load pointer to input */
        addi a0, fp, STACK_RHOPRIME
        jal x1, poly_uniform_eta
        addi a2, a2, 1
    
    /* Sample s2 */
    /* initialize the nonce */
    addi a2, zero, 4
    /* Load output pointer */
    li s1, STACK_S2
    add a1, fp, s1
    LOOPI 4, 3
        /* Load pointer to input */
        addi a0, fp, STACK_RHOPRIME
        jal x1, poly_uniform_eta
        addi a2, a2, 1
    
    /* NTT(s1) */
    li s1, STACK_S1
    add a0, fp, s1
    la a1, twiddles_fwd
    li s1, STACK_S1_HAT
    add a2, fp, s1

    push x4
    push x5
    push x6
    push x7
    push x8
    push x9
    push x12
    push x13
    push x14
    push x15
    push x16
    push x17
    push x18
    push x19
    push x20
    push x21
    push x22
    push x23
    push x24
    push x25
    push x26
    push x27
    push x28
    push x29
    push x30
    push x31
    LOOPI 4, 2
        jal x1, ntt_dilithium
        addi a1, a1, -1024
    pop x4
    pop x5
    pop x6
    pop x7
    pop x8
    pop x9
    pop x12
    pop x13
    pop x14
    pop x15
    pop x16
    pop x17
    pop x18
    pop x19
    pop x20
    pop x21
    pop x22
    pop x23
    pop x24
    pop x25
    pop x26
    pop x27
    pop x28
    pop x29
    pop x30
    pop x31

    /* Matrix-vector multiplication */
    /* Load source pointers */
    li a0, STACK_S1_HAT
    add a0, fp, a0

    li a1, STACK_MAT
    add a1, fp, a1
    /* Load destination pointer */
    li a2, STACK_T1
    add a2, fp, a2

    /* Load offset for resetting pointer */
    li s1, 4096

    LOOPI 4, 7
        jal x1, poly_pointwise_dilithium
        addi a2, a2, -1024
        LOOPI 3, 2
            jal x1, poly_pointwise_acc_dilithium
            addi a2, a2, -1024
        /* Reset input vector pointer */
        sub a0, a0, s1
        addi a2, a2, 1024

    /* TODO: Do we need reduce32? Do range analysis! */

    /* Inverse NTT on t1 */
    li a0, STACK_T1
    add a0, fp, a0
    la a1, twiddles_inv
    push x4
    push x5
    push x6
    push x7
    push x8
    push x9
    push x12
    push x13
    push x14
    push x15
    push x16
    push x17
    push x18
    push x19
    push x20
    push x21
    push x22
    push x23
    push x24
    push x25
    push x26
    push x27
    push x28
    push x29
    push x30
    push x31
    LOOPI 4, 3
        jal x1, intt_dilithium
        /* Reset the twiddle pointer */
        addi a1, a1, -960
        /* Go to next input polynomial */
        addi a0, a0, 1024
    pop x4
    pop x5
    pop x6
    pop x7
    pop x8
    pop x9
    pop x12
    pop x13
    pop x14
    pop x15
    pop x16
    pop x17
    pop x18
    pop x19
    pop x20
    pop x21
    pop x22
    pop x23
    pop x24
    pop x25
    pop x26
    pop x27
    pop x28
    pop x29
    pop x30
    pop x31

    /* t1+s2 */
    /* Load source pointers */
    li a0, STACK_S2
    add a0, fp, a0
    li a1, STACK_T1
    add a1, fp, a1
    /* Load destination pointer */
    li a2, STACK_T1
    add a2, fp, a2

    /* TODO: Why cant the loop have only one instruction? */
    LOOPI 4, 2
        jal x1, poly_add_dilithium
        nop

    /* caddq(t1) */
    /* TODO: is this needed? */
     /* Load source pointers */
    /* li a0, STACK_T1
    add a0, fp, a0

    LOOPI 4, 2
        jal x1, poly_caddq_dilithium
        nop */

    /* power2round */
    /* Load source pointers */
    li a0, STACK_T1
    add a0, fp, a0
    li a1, STACK_T0
    add a1, fp, a1
    li a2, STACK_T1
    add a2, fp, a2

    LOOPI 4, 2
        jal x1, poly_power2round_dilithium
        nop

    /* Pack pk */

    /* Load rho pointer */
    li t1, STACK_RHO
    add t1, fp, t1
    /* w0 <= rho */
    addi t0, zero, 0
    bn.lid t0, 0(t1)
    /* Load pk pointer */
    li t1, STACK_PK_ADDR
    add t1, fp, t1
    lw a0, 0(t1)
    /* Store rho */
    bn.sid t0, 0(a0)
    
    /* Advance pk pointer */
    addi a0, a0, 32
    /* Load pointer to t1 */
    li a1, STACK_T1
    add a1, fp, a1
    /* Store t1 */
    LOOPI 4, 2
        jal x1, polyt1_pack_dilithium
        nop


    /* Hash pk */
    /* Initialize a SHAKE256 operation. */
    addi      t0, zero, SHAKE256_START_CMD
    csrrw     zero, KECCAK_CMD_REG, t0

    /* Send the message to the Keccak core. */
    addi a0, a0, -1312
    addi a1, zero, 1312
    jal  x1, keccak_send_message

    /* Squeeze into output buffer */
    /* load seedbuf address */
    li t0, STACK_TR
    add t1, fp, t0
    /* Read the digest from the KECCAK_DIGEST special register (index 8).
       dmem[STACK_SEEDBUF] <= SHAKE256(zeta, 1024) */
    li t0, 0
    bn.wsrr  w0, 0x9 /* KECCAK_DIGEST */
    bn.sid t0, 0(t1) /* Store into buffer */

    /* Finish the SHAKE-256 operation. */
    addi      t0, zero, KECCAK_DONE_CMD
    csrrw     zero, KECCAK_CMD_REG, t0

    /* Pack sk */

    /* Load sk pointer */
    li t1, STACK_SK_ADDR
    add t1, fp, t1
    lw a0, 0(t1)
    /* Load rho pointer */
    li t1, STACK_RHO
    add t1, fp, t1
    /* w0 <= rho */
    addi t0, zero, 0
    bn.lid t0, 0(t1)
    /* Store rho */
    bn.sid t0, 0(a0)
    
    /* Advance sk pointer */
    addi a0, a0, 32
    
    /* Load key pointer */
    li t1, STACK_KEY
    add t1, fp, t1
    /* w0 <= key */
    addi t0, zero, 0
    bn.lid t0, 0(t1)
    /* Store key */
    bn.sid t0, 0(a0)

    /* Advance sk pointer */
    addi a0, a0, 32
    
    /* Load tr pointer */
    li t1, STACK_TR
    add t1, fp, t1
    /* w0 <= tr */
    addi t0, zero, 0
    bn.lid t0, 0(t1)
    /* Store tr */
    bn.sid t0, 0(a0)

    /* Advance sk pointer */
    addi a0, a0, 32

    /* Load pointer to s1 */
    li a1, STACK_S1
    add a1, fp, a1
    /* Store s1 */
    LOOPI 4, 2
        jal x1, polyeta_pack_dilithium
        nop

    /* Load pointer to s2 */
    li a1, STACK_S2
    add a1, fp, a1
    /* Store packed(s2) */
    LOOPI 4, 2
        jal x1, polyeta_pack_dilithium
        nop

    /* Load pointer to t0 */
    li a1, STACK_T0
    add a1, fp, a1
    /* Store packed(t0) */
    LOOPI 4, 2
        jal x1, polyt0_pack_dilithium
        nop

    /* Free space on the stack */
    addi sp, fp, 0
    ret

.data
.balign 32