.text
#define SEEDBYTES 32
#define CRHBYTES 64
#define N 256
#define Q 8380417
#define D 13
#define ROOT_OF_UNITY 1753

#define Q 8380417
#define K 4
#define L 4
#define ETA 2
#define TAU 39
#define BETA 78
#define GAMMA1 131072
#define GAMMA2 95232
#define OMEGA 80

#define POLYT1_PACKEDBYTES  320
#define POLYT0_PACKEDBYTES  416
#define POLYVECH_PACKEDBYTES (OMEGA + K)

#define POLYZ_PACKEDBYTES   576

#define POLYW1_PACKEDBYTES  192

#define POLYETA_PACKEDBYTES  96

#define CRYPTO_PUBLICKEYBYTES 1312
#define CRYPTO_SECRETKEYBYTES (3*SEEDBYTES \
                               + L*POLYETA_PACKEDBYTES \
                               + K*POLYETA_PACKEDBYTES \
                               + K*POLYT0_PACKEDBYTES)
#define CRYPTO_BYTES (SEEDBYTES + L*POLYZ_PACKEDBYTES + POLYVECH_PACKEDBYTES)

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
 .global keccak_send_message
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
 * Dilithium Verify
 *
 * Returns: 0 on success
 *
 * Flags: TODO
 *
 * @param[in]  x10: zeta (random bytes)
 * TODO params
 * @param[out] x10: 0 on success, -1 on failure
 *
 * clobbered registers: TODO
 *                      TODO
 */
.globl verify_dilithium
verify_dilithium:
    /* Stack address mapping */
    #define STACK_SIG -4
    #define STACK_SIGLEN -8
    #define STACK_MSG -12
    #define STACK_MSGLEN -16
    #define STACK_PK -20
    #define STACK_RHO -64
    #define STACK_T1 -4160
    #define STACK_C -4192
    #define STACK_Z -8288
    #define STACK_H -12384
    #define STACK_MU -12448
    #define STACK_CP -13472
    #define STACK_MAT -29856
    #define STACK_W1 -33952
    #define STACK_BUF -34720
    /* #define STACK_C2 -34752 */

    /* Initialize the frame pointer */
    addi fp, sp, 0

    /* Reserve space on the stack */
    li t0, -38400
    add sp, sp, t0

    /* Store parameters to stack */
    li t0, STACK_SIG
    add t0, fp, t0
    sw a0, 0(t0)
    li t0, STACK_SIGLEN
    add t0, fp, t0
    sw a1, 0(t0)
    li t0, STACK_MSG
    add t0, fp, t0
    sw a2, 0(t0)
    li t0, STACK_MSGLEN
    add t0, fp, t0
    sw a3, 0(t0)
    li t0, STACK_PK
    add t0, fp, t0
    sw a4, 0(t0)

    /* Unpack pk */
    /* Unpack rho */
    addi   t0, zero, 0
    bn.lid t0, 0(a4)
    li     t1, STACK_RHO
    add    t1, fp, t1
    bn.sid t0, 0(t1)

    /* Advance pk */
    addi a4, a4, 32

    /* Unpack t1 */
    /* Load pointer to t1 */
    li a0, STACK_T1
    add a0, fp, a0
    /* Load pointer to packed t1 */
    addi a1, a4, 0
    /* Store t1 */
    LOOPI 4, 2
        jal x1, polyt1_unpack_dilithium
        nop

    /* Unpack sig */
    /* Unpack c */
    /* Load sig pointer */
    li t0, STACK_SIG
    add t0, fp, t0
    lw t0, 0(t0)
    /* Load c pointer */
    li t1, STACK_C
    add t1, fp, t1
    li t2, 2
    bn.lid t2, 0(t0)
    bn.sid t2, 0(t1)

    /* Unpack z */
    /* Advance sig pointer */
    addi a1, t0, 32
    /* Load pointer to z */
    li a0, STACK_Z
    add a0, fp, a0
    LOOPI 4, 2
        jal x1, polyz_unpack_dilithium
        nop

    /* Decode h */
    
    /* Load pointer to h */
    li a0, STACK_H
    add a0, fp, a0
    jal x1, polyvec_decode_h_dilithium
    /* Raise error */
    bne a0, zero, exit_err

    /* chknorm */
    li t0, GAMMA1
    li t1, BETA
    sub a1, t0, t1
    li a0, STACK_Z
    add a0, fp, a0

    LOOPI 4, 2
        jal x1, poly_chknorm_dilithium
        nop
    /* Raise error */
    bne a0, zero, exit_err

    /* Compute H(rho, t1) */
    /* Load pointer to pk */
    li a0, STACK_PK
    add a0, fp, a0
    lw a0, 0(a0)
    /* Initialize a SHAKE256 operation. */
    addi      t0, zero, SHAKE256_START_CMD
    csrrw     zero, KECCAK_CMD_REG, t0
    /* Send the message to the Keccak core. */
    li  a1, CRYPTO_PUBLICKEYBYTES /* set message length to CRYPTO_PUBLICKEYBYTES */
    jal x1, keccak_send_message
    
    li a0, STACK_MU
    add a0, fp, a0
    /* Setup WDR */
    li t1, 8
    /* Write SHAKE output to dmem */
    bn.wsrr  w8, 0x9 /* KECCAK_DIGEST */
    bn.sid t1, 0(a0) /* Store into buffer */

    /* Finish the SHAKE-256 operation. */
    addi      t2, zero, KECCAK_DONE_CMD
    csrrw     zero, KECCAK_CMD_REG, t2

    /* Compute CRH(H(rho, t1), msg) */
    /* Initialize a SHAKE256 operation. */
    addi      t2, zero, SHAKE256_START_CMD
    csrrw     zero, KECCAK_CMD_REG, t2
    /* Send mu to the Keccak core. */
    li a1, 32
    /* a0 already contains mu pointer */
    jal  x1, keccak_send_message
    /* Send msg to the Keccak core. */
    li t2, STACK_MSGLEN
    add t2, fp, t2
    lw a1, 0(t2) /* a1 <= msglen */
    li t2, STACK_MSG
    add a0, fp, t2
    lw a0, 0(a0) /* a0 <= *msg */
    jal  x1, keccak_send_message
    /* Setup WDR */
    li t1, 8
    /* Load *mu */
    li a0, STACK_MU
    add a0, fp, a0
    /* Write SHAKE output to dmem */
    bn.wsrr  w8, 0x9 /* KECCAK_DIGEST */
    bn.sid t1, 0(a0) /* Store into buffer */
    bn.wsrr  w8, 0x9 /* KECCAK_DIGEST */
    bn.sid t1, 32(a0) /* Store into buffer */
    /* Finish the SHAKE-256 operation. */
    addi      t2, zero, KECCAK_DONE_CMD
    csrrw     zero, KECCAK_CMD_REG, t2

    li a0, STACK_CP
    add a0, fp, a0
    li a1, STACK_C
    add a1, fp, a1
    jal x1, poly_challenge

    /* expand matrix */
    /* initialize the nonce */
    addi a2, zero, 0

    li a1, STACK_MAT
    add a1, fp, a1
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

    /* NTT(z) */
    li a0, STACK_Z
    add a0, fp, a0
    addi a2, a0, 0 /* inplace */
    la a1, twiddles_fwd

    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    LOOPI 4, 2
        jal x1, ntt_dilithium
        addi a1, a1, -1024

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* NTT(c) */
    li a0, STACK_CP
    add a0, fp, a0
    addi a2, a0, 0 /* inplace */
    la a1, twiddles_fwd
    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    jal x1, ntt_dilithium

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr
    /* shiftl(t1) */

    li a0, STACK_T1
    add a0, fp, a0
    li t0, 0
    li t1, 1
    LOOPI 4, 5
        LOOPI 32, 3
            bn.lid t0, 0(a0)
            bn.orv.8S w0, bn0, w0 << D
            bn.sid t0, 0(a0++)
        nop /* TODO: find a better way */

    /* NTT(t1) */
    li a0, STACK_T1
    add a0, fp, a0
    addi a2, a0, 0 /* inplace */
    la a1, twiddles_fwd

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
    li a0, STACK_Z
    add a0, fp, a0

    li a1, STACK_MAT
    add a1, fp, a1
    /* Load destination pointer */
    li a2, STACK_W1
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

    /* polyveck_pointwise_poly_montgomery(&t1, &cp, &t1); */
    li a0, STACK_CP
    add a0, fp, a0
    li a1, STACK_T1
    add a1, fp, a1
    li a2, STACK_T1
    add a2, fp, a2
    LOOPI 4, 2
        jal x1, poly_pointwise_dilithium
        addi a0, a0, -1024

    /* polyveck_sub(&w1, &w1, &t1); */
    li a0, STACK_W1
    add a0, fp, a0
    li a1, STACK_T1
    add a1, fp, a1
    li a2, STACK_W1
    add a2, fp, a2
    LOOPI 4, 2
        jal x1, poly_sub_dilithium
        nop /* TODO: why is this needed? */

    /* Inverse NTT on w1 */
    li a0, STACK_W1
    add a0, fp, a0
    la a1, twiddles_inv
   
    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    LOOPI 4, 3
        jal x1, intt_dilithium
        /* Reset the twiddle pointer */
        addi a1, a1, -960
        /* Go to next input polynomial */
        addi a0, a0, 1024

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* Use hint */
    li a0, STACK_W1
    add a0, fp, a0
    li a1, STACK_W1
    add a1, fp, a1
    li a2, STACK_H
    add a2, fp, a2
   
    LOOPI 4, 2 /* TODO Check pointers */
        jal x1, poly_use_hint_dilithium
        nop

    /* Pack w1 */
    li a1, STACK_W1
    add a1, fp, a1
    li a0, STACK_BUF
    add a0, fp, a0

    LOOPI 4, 2
        jal x1, polyw1_pack_dilithium
        nop

    /* Call random oracle and verify challenge */
    /* Initialize a SHAKE256 operation. */
    addi      t0, zero, SHAKE256_START_CMD
    csrrw     zero, KECCAK_CMD_REG, t0
    /* Send mu to the Keccak core. */
    li a0, STACK_MU
    add a0, fp, a0
    li  a1, CRHBYTES /* set mu length to CRHBYTES */
    jal x1, keccak_send_message
    /* Send buf to the Keccak core. */
    li a0, STACK_BUF
    add a0, fp, a0
    li  a1, 768 /* set mu length to K*POLYW1_PACKEDBYTES */
    jal x1, keccak_send_message

    /* Setup WDR for c2 */
    li t1, 8
    /* Write SHAKE output to dmem */
    bn.wsrr  w8, 0x9 /* KECCAK_DIGEST */

    /* Finish the SHAKE-256 operation. */
    addi      t2, zero, KECCAK_DONE_CMD
    csrrw     zero, KECCAK_CMD_REG, t2

    /* Setup WDR for c */
    li t2, 9
    li t0, STACK_C
    add t0, fp, t0
    bn.lid t2, 0(t0)

    bn.cmp w8, w9

    /* Get the FG0.Z flag into a register.
    x2 <= (CSRs[FG0] >> 3) & 1 = FG0.Z */
    csrrs    t0, 0x7c0, zero
    srli     t0, t0, 3
    andi     t0, t0, 1

    beq t0, zero, _fail_verify_dilithium
    beq zero, zero, _success_verify_dilithium

    /* ------------------------ */

    /* Free space on the stack */
    addi sp, fp, 0
_success_verify_dilithium:
    li a0, 0
    ret

exit_err:
_fail_verify_dilithium:
    li a0, -1
    unimp
    ret