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
MACRO*/     sltu tmp, val, Q   /* (tmp = 1) <= val <? Q */ /*MACRO
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
rej_eta_sample_loop_inner:
            /* Get state into working copy */
            bn.add w9, shake_reg, bn0
            /* shift out the used byte */
            bn.or  shake_reg, bn0, shake_reg >> 8
            
            /* Mask out all other bytes */
            bn.addi w11, bn0, 0xFF
            bn.and  w9, w9, w11
            /* Prepare "t1" */
            bn.rshi w10, bn0, w9 >> 4
            /* Prepare "t0" */
            bn.addi w11, bn0, 15
            bn.and  w9, w9, w11

            /* Instead of < 15, != 15 can also be checked */
            bn.addi w11, bn0, 15
            bn.cmp w9, w11
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
    /* Initialize the frame pointer */
    addi fp, sp, 0

    /* Reserve space on the stack */
    li t0, -38400
    add sp, sp, t0

    /* Store parameters to stack */
    /* TODO: Select correct registers (zeta gets removed) */
    li t0, STACK_PK_ADDR
    sw a1, 0(t0)
    li t0, STACK_SK_ADDR
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

    /* Finish the SHAKE-128 operation. */
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
    li a0, STACK_S1
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
    /* Store rho */
    bn.sid t0, 0(t1)

    /* Store t1 */
    LOOPI 4, 2
        jal x1, polyt1_pack_dilithium
        nop


    /* Free space on the stack */
    addi sp, fp, 0
    ret

.data
.balign 32