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

    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    LOOPI 4, 2
        jal x1, ntt_dilithium
        addi a1, a1, -1024

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

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
    /* Save caller-saved registers */
    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr
    LOOPI 4, 3
        jal x1, intt_dilithium
        /* Reset the twiddle pointer */
        addi a1, a1, -960
        /* Go to next input polynomial */
        addi a0, a0, 1024
    /* Restore caller-saved registers */
    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

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