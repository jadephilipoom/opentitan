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


/* Stack address mapping */
.set STACK_MODE,         0
.set STACK_OP_STATE,     4
.set STACK_SEEDBUF,     20 /* TODO: remove aliases */
.set STACK_TR,         148
.set STACK_RHO,        180
.set STACK_RHOPRIME,   184
.set STACK_KEY,        188
.set STACK_MAT,        192
.set STACK_S1HAT,    20672
.set STACK_S2,       24768
.set STACK_T1,       28864
.set STACK_T0,       32960

/* Macros */
.macro push reg
    addi sp, sp, 4    # Decrement stack pointer by 4 bytes
    sw \reg, 0(sp)     # Store register value at the top of the stack
.endm

.macro pop reg
    lw \reg, 0(sp)     # Load value from the top of the stack into register
    addi sp, sp, -4     # Increment stack pointer by 4 bytes
.endm

/**
 * poly_uniform
 *
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]     x10: nonce
 * @param[in]     x11: rho
 * @param[out]    x12: dmem pointer to polynomial
 *
 * clobbered registers: TODO
 */
.global poly_uniform
poly_uniform:
    push fp
    addi fp, sp, 0

    /* Reserve space for buf */
    /* POLY_UNIFORM_NBLOCKS*STREAM128_BLOCKBYTES + 2 = 
        floor(((768 + 168 - 1)/168)) * 168 */
    .equ STACK_BUF, 0
    addi sp, sp, 844

    /* Reserve space for nonce (2 bytes) */
    .equ STACK_NONCE, 844
    addi sp, sp, 4 /* must be 4 byte aligned */

    /* Reserve space for wide vector containing offset off */
    .equ STACK_OFF, 848
    addi sp, sp, 32 /* for one wdr */

    /* set t0 = buflen */
    addi x5, zero, 840

    /* Initialize SHAKE128 */
    la          x28, stack
    addi        x6, x28, STACK_MODE
    addi        x28, x28, STACK_OP_STATE
    /* Set mode for 128-bit */
    addi        x29, zero, 1
    sw          x29, 0(x6)
    shake_start x5, x6

    /* Absorb */
    /* length of SEEDBYTES */
    li           x7, 32
    /* absorb seed */
    shake_absorb x5, x11, x7

    /* length of nonce */
    li           x7, 2
    /* store nonce to stack */
    addi         x11, fp, STACK_NONCE
    sw           x10, 0(x11)
    /* absorb nonce */
    shake_absorb x5, x11, x7

    /* x6 = ctr = 0*/
    xor  x6, x6, x6

    addi sp, fp, 0
    pop fp
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
    /* Initialize the frame pointer */
    addi fp, sp, 0

    /* Reserve space on the stack */
    li x5, 37056
    add sp, sp, x5

    /* Initialize the SHAKE core */
    addi        t1, fp, STACK_MODE
    addi        t0, fp, STACK_OP_STATE
    shake_start x5, x6

    /* length of SEEDBYTES */
    li x7, 32
    /* absorb zeta */
    shake_absorb x5, x10, x7

    /* load seedbuf address */
    addi x28, fp, STACK_SEEDBUF
    /* length of 2*SEEDBYTES + CRHBYTES */
    li   x7, 128
    /* squeeze into seedbuf */
    shake_squeeze x5, x28, x7

    /* expand matrix */
    /* initialize the nonce */
    addi x10, zero, 0

    /* ! specific to dilithium2 */
    LOOPI 4, 4
        LOOPI 4, 5
            /* Load parameters */
            addi x12, zero, STACK_MAT
            addi x11, zero, STACK_SEEDBUF
            jal  x1, poly_uniform
            addi x12, x12, 1024
            addi x10, x10, 1
        addi x10, x10, 252

    /* Free space on the stack */
    addi sp, fp, 0
    ret

.data
.balign 32