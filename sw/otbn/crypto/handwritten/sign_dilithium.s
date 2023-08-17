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
#define CRYPTO_BYTES 2420 /* (SEEDBYTES + L*POLYZ_PACKEDBYTES + POLYVECH_PACKEDBYTES)  */

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
#define KECCAK_CMD_REG 0x7dc
/* Command to start a SHAKE-128 operation. */
#define SHAKE128_START_CMD 0x1d
/* Command to start a SHAKE-256 operation. */
#define SHAKE256_START_CMD 0x5d
/* Command to end an ongoing Keccak operation of any kind. */
#define KECCAK_DONE_CMD 0x16
/* Index of the Keccak write-length special register. */
#define KECCAK_WRITE_LEN_REG 0x7e0

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
  beq t0, zero, _no_full_wdr
  loop     t0, 2
    /* w0 <= dmem[x10..x10+32] = msg[32*i..32*i-1]
       x10 <= x10 + 32 */
    bn.lid   x0, 0(x10++)
    /* Write to the KECCAK_MSG wide special register (index 8).
         KECCAK_MSG <= w0 */
    bn.wsrw  0x8, w0
_no_full_wdr:
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
 * Dilithium Sign
 *
 * Returns: 0 on success
 *
 * Flags: TODO
 *
 * @param[in]  x10: *sig
 * @param[in]  x11: *msg
 * @param[in]  x12: msglen
 * @param[in]  x13: *sk
 * @param[out] x10: 0 (success)
 * @param[out] x11: siglen
 *
 * clobbered registers: TODO
 *                      TODO
 */
.global sign_dilithium
sign_dilithium:
    /* Stack address mapping */
    #define STACK_SIG -4
    #define STACK_MSG -8
    #define STACK_MSGLEN -12
    #define STACK_SK -16
    #define STACK_RHO -64
    #define STACK_KEY -96
    #define STACK_TR -128
    #define STACK_T0  -4224
    #define STACK_S1  -8320
    #define STACK_S2  -12416
    #define STACK_MU  -12480
    #define STACK_RHOPRIME  -12544
    #define STACK_MAT -28928
    #define STACK_Y -33024
    #define STACK_Z -37120
    #define STACK_W1 -41216
    #define STACK_W0 -45312
    #define STACK_CP -46336
    #define STACK_H -50432

    /* Initialize the frame pointer */
    addi fp, sp, 0

    /* Reserve space on the stack */
    li t0, -52192
    add sp, sp, t0

    /* Store parameters to stack */
    li  t0, STACK_SIG
    add t0, fp, t0
    sw  a0, 0(t0)
    li  t0, STACK_MSG
    add t0, fp, t0
    sw  a1, 0(t0)
    li  t0, STACK_MSGLEN
    add t0, fp, t0
    sw  a2, 0(t0)
    li  t0, STACK_SK
    add t0, fp, t0
    sw  a3, 0(t0)

    /* Unpack sk */

    /* Setup WDR */
    li t0, 0

    /* Copy to stack */

    /* rho */
    bn.lid t0, 0(a3++)
    /* Load *rho */
    li     t1, STACK_RHO
    add    t1, fp, t1
    bn.sid t0, 0(t1++)

    /* key */
    bn.lid t0, 0(a3++)
    /* Load *key */
    li     t1, STACK_KEY
    add    t1, fp, t1
    bn.sid t0, 0(t1++)

    /* tr */
    bn.lid t0, 0(a3++)
    /* Load *tr */
    li     t1, STACK_TR
    add    t1, fp, t1
    bn.sid t0, 0(t1)

    
    /* Unpack s1 */
    /* Load pointer to s1 */
    li   a0, STACK_S1
    add  a0, fp, a0
    /* Load pointer to packed s1 */
    addi a1, a3, 0

    LOOPI 4, 2
        jal x1, polyeta_unpack_dilithium
        nop
    
    /* Unpack s2 */
    /* Load pointer to s2 */
    li  a0, STACK_S2
    add a0, fp, a0

    LOOPI 4, 2
        jal x1, polyeta_unpack_dilithium
        nop

    /* Unpack t0 */
    /* Load pointer to t0 */
    li  a0, STACK_T0
    add a0, fp, a0

    LOOPI 4, 2
        jal x1, polyt0_unpack_dilithium
        nop

    /* CRH(tr, msg) */

    /* Initialize a SHAKE256 operation. */
    addi  t0, zero, SHAKE256_START_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Send TR to the Keccak core. */
    li  a1, SEEDBYTES /* set message length to CRYPTO_PUBLICKEYBYTES */
    li  a0, STACK_TR
    add a0, fp, a0
    jal x1, keccak_send_message

    /* Send MSG to the Keccak core. */
    li  a0, STACK_MSG
    add a0, fp, a0
    lw  a0, 0(a0)
    li  a1, STACK_MSGLEN
    add a1, fp, a1
    lw  a1, 0(a1)
    jal x1, keccak_send_message

    /* Setup WDR */
    li t1, 8

    /* Write SHAKE output to dmem */
    li      a0, STACK_MU
    add     a0, fp, a0
    bn.wsrr w8, 0x9     /* KECCAK_DIGEST */
    bn.sid  t1, 0(a0++) /* Store into mu buffer */
    bn.wsrr w8, 0x9     /* KECCAK_DIGEST */
    bn.sid  t1, 0(a0++) /* Store into mu buffer */

    /* Finish the SHAKE-256 operation. */
    addi  t0, zero, KECCAK_DONE_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Initialize a SHAKE256 operation. */
    addi  t0, zero, SHAKE256_START_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Send key to the Keccak core. */
    li  a1, 32 /* set message length to SEEDBYTES + CRHBYTES */
    li  a0, STACK_KEY
    add a0, fp, a0
    jal x1, keccak_send_message

    /* Send mu to the Keccak core. */
    li  a1, 64 /* set message length to SEEDBYTES + CRHBYTES */
    li  a0, STACK_MU
    add a0, fp, a0
    jal x1, keccak_send_message

    /* TODO: randomized signing */

    li      a0, STACK_RHOPRIME
    add     a0, fp, a0
    bn.wsrr w8, 0x9     /* KECCAK_DIGEST */
    bn.sid  t1, 0(a0++) /* Store into rhoprime buffer */
    bn.wsrr w8, 0x9     /* KECCAK_DIGEST */
    bn.sid  t1, 0(a0++) /* Store into rhoprime buffer */

    /* Finish the SHAKE-256 operation. */
    addi  t0, zero, KECCAK_DONE_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Expand matrix */
    /* Initialize the nonce */
    li a2, 0

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

    /* NTT(s1) */
    li   a0, STACK_S1
    add  a0, fp, a0
    addi a2, a0, 0 /* Inplace */
    la   a1, twiddles_fwd

    /* TODO: Remove not save worthy registers */
    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
       push \reg
    .endr

    LOOPI 4, 2
        jal x1, ntt_dilithium
        addi a1, a1, -1024 /* Reset twiddle pointer */

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* NTT(s2) */
    li   a0, STACK_S2
    add  a0, fp, a0
    addi a2, a0, 0 /* inplace */

    /* TODO: Remove not save worthy registers */
    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
       push \reg
    .endr

    LOOPI 4, 2
      jal  x1, ntt_dilithium
      addi a1, a1, -1024 /* Reset twiddle pointer */

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* NTT(t0) */
    li   a0, STACK_T0
    add  a0, fp, a0
    addi a2, a0, 0 /* Inplace */

    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
       push \reg
    .endr

    LOOPI 4, 2
        jal x1, ntt_dilithium
        addi a1, a1, -1024 /* Reset twiddle pointer */

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    li s11, 0 /* nonce */

_rej_sign_dilithium:
    /* Uniform GAMMA1 */
    li  a1, STACK_RHOPRIME
    add a1, fp, a1
    
    li  a0, STACK_Y
    add a0, fp, a0

    addi a2, s11, 0 /* Compute nonce */
    la   a3, gamma1_vec_const

    LOOPI L, 2
        jal  x1, poly_uniform_gamma1_dilithium
        addi a2, a2, 1 /* a2 should be preserved after execution */
    
    addi s11, s11, L

    /* NTT(s2) */
    li  a0, STACK_Y
    add a0, fp, a0 /* in */
    li  a2, STACK_Z
    add a2, fp, a2 /* out */
    la  a1, twiddles_fwd

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
    li  a0, STACK_Z
    add a0, fp, a0
    li  a1, STACK_MAT
    add a1, fp, a1

    /* Load destination pointer */
    li  a2, STACK_W1
    add a2, fp, a2

    /* Load offset for resetting pointer */
    li s0, 4096

    LOOPI 4, 7
        jal  x1, poly_pointwise_dilithium
        addi a2, a2, -1024
        LOOPI 3, 2
            jal  x1, poly_pointwise_acc_dilithium
            addi a2, a2, -1024
        /* Reset input vector pointer */
        sub  a0, a0, s0
        addi a2, a2, 1024

    /* Inverse NTT on w1 */
    li  a0, STACK_W1
    add a0, fp, a0
    la  a1, twiddles_inv
   
    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    LOOPI 4, 3
        jal x1, intt_dilithium
        /* Reset the twiddle pointer */
        addi a1, a1, -960
        /* Go to next input polynomial */
        addi a0, a0, 1024 /* TODO: why is this needed? */
    
    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* Decompose */
    li   a2, STACK_W1 /* Input */
    add  a2, fp, a2
    addi a1, a2, 0    /* Output inplace */
    li   a0, STACK_W0 /* Output */
    add  a0, fp, a0
    
    LOOPI 4, 2
        jal x1, poly_decompose_dilithium
        nop

    /* Pack w1 */
    li  a1, STACK_W1 /* Get *w1 */
    add a1, fp, a1
    li  a0, STACK_SIG
    add a0, fp, a0
    lw  a0, 0(a0) /* Get *sig */

    LOOPI 4, 2
        jal x1, polyw1_pack_dilithium
        nop

    /* Random oracle */
    /* Initialize a SHAKE256 operation. */
    addi  t0, zero, SHAKE256_START_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Send mu to the Keccak core. */
    li  a1, CRHBYTES /* set mu length to CRHBYTES */
    li  a0, STACK_MU
    add a0, fp, a0
    jal x1, keccak_send_message

    /* Send packed w1 to the Keccak core. */
    li   a1, 768 /* set packed w1 length to K*POLYW1_PACKEDBYTES */
    li   a0, STACK_SIG
    add  a0, fp, a0
    lw   a0, 0(a0) /* get *sig */
    addi s0, a0, 0 /* save a0 */
    jal  x1, keccak_send_message

    /* Setup WDR */
    li t1, 8

    bn.wsrr w8, 0x9   /* KECCAK_DIGEST */
    addi    a0, s0, 0 /* restore a0 */
    bn.sid  t1, 0(a0) /* Store SEEDBYTES into sig */

    /* Finish the SHAKE-256 operation. */
    addi  t0, zero, KECCAK_DONE_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Challenge */
    addi a1, a0, 0 /* move *sig to a1  */
    li   a0, STACK_CP
    add  a0, fp, a0
    jal  x1, poly_challenge

    /* NTT(cp) */
    li   a0, STACK_CP
    add  a0, fp, a0 /* Input */
    addi a2, a0, 0  /* Output inplace */
    la   a1, twiddles_fwd

    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    jal x1, ntt_dilithium /* Only one polynomial */

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* z = cp * s1 */
    li  a0, STACK_CP
    add a0, fp, a0
    li  a1, STACK_S1
    add a1, fp, a1
    li  a2, STACK_Z
    add a2, fp, a2

    LOOPI 4, 2
        jal  x1, poly_pointwise_dilithium
        addi a0, a0, -1024

    /* Inverse NTT on z */
    li  a0, STACK_Z
    add a0, fp, a0
    la  a1, twiddles_inv
   
    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    LOOPI 4, 3
        jal  x1, intt_dilithium
        /* Reset the twiddle pointer */
        addi a1, a1, -960
        /* Go to next input polynomial */
        addi a0, a0, 1024
    
    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* z = z + y */
    li  a0, STACK_Z
    add a0, fp, a0
    li  a1, STACK_Y
    add a1, fp, a1
    li  a2, STACK_Z
    add a2, fp, a2

    LOOPI 4, 2
        jal x1, poly_add_dilithium
        nop
    
    /* reduce32 z */
    li   a0, STACK_Z
    add  a0, fp, a0
    addi a1, a0, 0

    LOOPI 4, 2
        jal x1, poly_reduce32_dilithium
        nop

    /* chknorm */
    li  t0, GAMMA1
    li  t1, BETA
    sub a1, t0, t1
    li  s0, STACK_Z
    add s0, fp, s0

    LOOPI L, 5
        addi a0, s0, 0
        jal x1, poly_chknorm_dilithium
        addi s0, s0, 1024
        
        /* Reject */
        bne a0, zero, _rej_sign_dilithium
        nop /* Loops cannot end on a branch */

    /* h = cp * s2 */
    li  a0, STACK_CP
    add a0, fp, a0
    li  a1, STACK_S2
    add a1, fp, a1
    li  a2, STACK_H
    add a2, fp, a2

    LOOPI 4, 2
        jal  x1, poly_pointwise_dilithium
        addi a0, a0, -1024

    /* Inverse NTT on h */
    li  a0, STACK_H
    add a0, fp, a0
    la  a1, twiddles_inv
   
    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    LOOPI 4, 3
        jal  x1, intt_dilithium
        /* Reset the twiddle pointer */
        addi a1, a1, -960
        /* Go to next input polynomial */
        addi a0, a0, 1024

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* w0 = w0 + h */
    li  a0, STACK_W0
    add a0, fp, a0
    li  a1, STACK_H
    add a1, fp, a1
    li  a2, STACK_W0
    add a2, fp, a2

    LOOPI L, 2
        jal x1, poly_sub_dilithium
        nop 

    /* reduce32 w0 */
    li   a0, STACK_W0
    add  a0, fp, a0
    addi a1, a0, 0
    LOOPI 4, 2
        jal x1, poly_reduce32_dilithium
        nop

    /* chknorm */
    li  t0, GAMMA2
    li  t1, BETA
    sub a1, t0, t1
    li  s0, STACK_W0
    add s0, fp, s0

    LOOPI K, 4
        addi a0, s0, 0
        jal  x1, poly_chknorm_dilithium
        /* reject */
        bne  a0, zero, _rej_sign_dilithium
        addi s0, s0, 1024
    
    /* h = cp * t0 */
    li  a0, STACK_CP
    add a0, fp, a0
    li  a1, STACK_T0
    add a1, fp, a1
    li  a2, STACK_H
    add a2, fp, a2

    LOOPI K, 2
        jal  x1, poly_pointwise_dilithium
        addi a0, a0, -1024

    /* Inverse NTT on h */
    li  a0, STACK_H
    add a0, fp, a0
    la  a1, twiddles_inv

    .irp reg,t0,t1,t2,t3,t4,t5,t6,a0,a1,a2,a3,a4,a5,a6,a7
        push \reg
    .endr

    LOOPI 4, 3
        jal  x1, intt_dilithium
        /* Reset the twiddle pointer */
        addi a1, a1, -960
        /* Go to next input polynomial */
        addi a0, a0, 1024

    .irp reg,a7,a6,a5,a4,a3,a2,a1,a0,t6,t5,t4,t3,t2,t1,t0
        pop \reg
    .endr

    /* reduce32 h */
    li   a0, STACK_H
    add  a0, fp, a0
    addi a1, a0, 0

    LOOPI 4, 2
        jal x1, poly_reduce32_dilithium
        nop /* TODO: remove */

    /* chknorm */
    li  a1, GAMMA2
    li  s0, STACK_H
    add s0, fp, s0

    LOOPI K, 4
        addi a0, s0, 0
        jal  x1, poly_chknorm_dilithium
        /* reject */
        bne  a0, zero, _rej_sign_dilithium
        addi s0, s0, 1024

    /* w0 = w0 + h */
    li  a0, STACK_W0
    add a0, fp, a0
    li  a1, STACK_H
    add a1, fp, a1
    li  a2, STACK_W0
    add a2, fp, a2

    LOOPI L, 2
        jal x1, poly_add_dilithium
        nop

    /* make hint */
    

    /* TODO: get rid of this reduction by modifying make_hint like in python */
    /* reduce32 w0 */
    li   a0, STACK_W0
    add  a0, fp, a0
    addi a1, a0, 0
    LOOPI 4, 2
        jal x1, poly_reduce32_dilithium
        nop
    
    li  s0, 0
    li  s1, STACK_H
    add a0, fp, s1
    li  a1, STACK_W0
    add a1, fp, a1
    li  a2, STACK_W1
    add a2, fp, a2

    LOOPI K, 4
        add  a0, fp, s1
        jal  x1, poly_make_hint_dilithium
        addi s1, s1, 1024
        add  s0, s0, a0

    li   t0, OMEGA
    li   t1, 1
    sltu t2, t0, s0
    /* reject */
    beq  t1, t2, _rej_sign_dilithium

    /* Pack sig */
    li   a0, STACK_SIG
    add  a0, fp, a0
    lw   a0, 0(a0)  /* get *sig */
    /* c is already in sig */
    addi a0, a0, 32 /* increment *sig */
    /* z */
    li   a1, STACK_Z
    add  a1, fp, a1
    /* Load gamma1_vec_const to w0 */
    la   a2, gamma1_vec_const
    li   t0, 0
    bn.lid t0, 0(a2)
    LOOPI L, 2
        jal x1, polyz_pack_dilithium
        nop

    /* encode h */
    /* save *sig+SEEDBYTES+L*POLYZ_PACKEDBYTES */
    addi s0, a0, 0

    /* Set rest of sig to 0 */
    li     t0, 31
    bn.sid t0, 0(a0++)
    bn.sid t0, 0(a0++)

    LOOPI 5, 2
        sw   zero, 0(a0)
        addi a0, a0, 4

    addi a0, s0, 0 /* reset *sig */
    li   a1, STACK_H
    add  a1, fp, a1
    jal  x1, polyvec_encode_h_dilithium

    /* Return success and signature length */
    li a0, 0
    li a1, CRYPTO_BYTES

    /* Free space on the stack */
    addi sp, fp, 0
  ret