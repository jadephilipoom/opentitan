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
 * polyt1_unpack_dilithium
 *
 * Unpack polynomial t1 with coefficients fitting in 10 bits.
 * Output coefficients are standard representatives.
 * 
 * Returns: -
 *
 * @param[in]  a1: pointer to input byte array with POLYT1_PACKEDBYTES bytes
 * @param[out] a0: pointer to output polynomial
 *
 * clobbered registers: a0-a1, t0-t2
 */

.global polyt1_unpack_dilithium
polyt1_unpack_dilithium:
    /* Unpack all 16 * 16 = 256 = n coefficients */
    LOOPI 16, 62
        lw t0, 0(a1)
        andi t1, t0, 0x3ff
        sw t1, 0(a0) /* coeff 0 */
        srli t0, t0, 10
        andi t1, t0, 0x3ff
        sw t1, 4(a0) /* coeff 1 */
        srli t0, t0, 10
        andi t1, t0, 0x3ff
        sw t1, 8(a0) /* coeff 2 */
        srli t0, t0, 10
        /* Bits remaining in register: 2 */
        lw t2, 4(a1)
        andi t1, t2, 0xff
        slli t1, t1, 2
        or t1, t1, t0
        sw t1, 12(a0) /* coeff 3 */
        srli t0, t2, 8
        /* Bytes processed: 8 */

        andi t1, t0, 0x3ff
        sw t1, 16(a0) /* coeff 4 */
        srli t0, t0, 10
        andi t1, t0, 0x3ff
        sw t1, 20(a0) /* coeff 5 */
        srli t0, t0, 10
        /* Bits remaining in register: 4 */
        lw t2, 8(a1)
        andi t1, t2, 0x3f
        slli t1, t1, 4
        or t1, t1, t0
        sw t1, 24(a0) /* coeff 6 */
        srli t0, t2, 6
        /* Bytes processed: 12 */

        andi t1, t0, 0x3ff
        sw t1, 28(a0) /* coeff 7 */
        srli t0, t0, 10
        andi t1, t0, 0x3ff
        sw t1, 32(a0) /* coeff 8 */
        srli t0, t0, 10
        /* Bits remaining in register: 6 */
        lw t2, 12(a1)
        andi t1, t2, 0xf
        slli t1, t1, 6
        or t1, t1, t0
        sw t1, 36(a0) /* coeff 9 */
        srli t0, t2, 4
        /* Bytes processed: 16 */

        andi t1, t0, 0x3ff
        sw t1, 40(a0) /* coeff 10 */
        srli t0, t0, 10
        andi t1, t0, 0x3ff
        sw t1, 44(a0) /* coeff 11 */
        srli t0, t0, 10
        /* Bits remaining in register: 8 */
        lw t2, 16(a1)
        andi t1, t2, 0x3
        slli t1, t1, 8
        or t1, t1, t0
        sw t1, 48(a0) /* coeff 12 */
        srli t0, t2, 2
        /* Bytes processed: 20 */

        andi t1, t0, 0x3ff
        sw t1, 52(a0) /* coeff 13 */
        srli t0, t0, 10
        andi t1, t0, 0x3ff
        sw t1, 56(a0) /* coeff 14 */
        srli t0, t0, 10
        /* Bits remaining in register: 10 */
        andi t1, t0, 0x3ff
        sw t1, 60(a0) /* coeff 15 */
        /* Bytes processed: 20 */

        addi a1, a1, 20
        addi a0, a0, 64

    ret

/**
 * polyz_unpack_dilithium
 *
 * Unpack polynomial z with coefficients in [-(GAMMA1 - 1), GAMMA1] fitting into
 * 18 bits. 
 * 
 * Returns: -
 *
 * @param[in]  a1: pointer to input byte array with POLYZ_PACKEDBYTES bytes
 * @param[out] a0: pointer to output polynomial
 *
 * clobbered registers: a0-a1, t0-t6
 */
.global polyz_unpack_dilithium
polyz_unpack_dilithium:
    /* Constants for masking (don't fit immediate) */
    li t3, 0x3ffff
    li t4, 0xffff
    li t5, 0xfff
    li t6, 0x3fff

    /* Unpack all 16 * 16 = 256 = n coefficients */
    LOOPI 16, 74
        lw t0, 0(a1)
        and t1, t0, t3
        sw t1, 0(a0) /* coeff 0 */
        srli t0, t0, 18
        /* Bits remaining in register: 14 */
        lw t2, 4(a1)
        andi t1, t2, 15
        slli t1, t1, 14
        or t1, t1, t0
        sw t1, 4(a0)
        srli t0, t2, 4
        /* Bytes processed: 8 */

        and t1, t0, t3
        sw t1, 8(a0) /* coeff 2 */
        srli t0, t0, 18
        /* Bits remaining in register: 10 */
        lw t2, 8(a1)
        andi t1, t2, 255
        slli t1, t1, 10
        or t1, t1, t0
        sw t1, 12(a0)
        srli t0, t2, 8
        /* Bytes processed: 12 */

        and t1, t0, t3
        sw t1, 16(a0) /* coeff 4 */
        srli t0, t0, 18
        /* Bits remaining in register: 6 */
        lw t2, 12(a1)
        and t1, t2, t5
        slli t1, t1, 6
        or t1, t1, t0
        sw t1, 20(a0)
        srli t0, t2, 12
        /* Bytes processed: 16 */

        and t1, t0, t3
        sw t1, 24(a0) /* coeff 6 */
        srli t0, t0, 18
        /* Bits remaining in register: 2 */
        lw t2, 16(a1)
        and t1, t2, t4
        slli t1, t1, 2
        or t1, t1, t0
        sw t1, 28(a0)
        srli t0, t2, 16
        /* Bytes processed: 20 */

        /* Bits remaining in register: 16 */
        lw t2, 20(a1)
        andi t1, t2, 3
        slli t1, t1, 16
        or t1, t1, t0
        sw t1, 32(a0)
        srli t0, t2, 2
        /* Bytes processed: 24 */

        and t1, t0, t3
        sw t1, 36(a0) /* coeff 9 */
        srli t0, t0, 18
        /* Bits remaining in register: 12 */
        lw t2, 24(a1)
        andi t1, t2, 63
        slli t1, t1, 12
        or t1, t1, t0
        sw t1, 40(a0)
        srli t0, t2, 6
        /* Bytes processed: 28 */

        and t1, t0, t3
        sw t1, 44(a0) /* coeff 11 */
        srli t0, t0, 18
        /* Bits remaining in register: 8 */
        lw t2, 28(a1)
        andi t1, t2, 1023
        slli t1, t1, 8
        or t1, t1, t0
        sw t1, 48(a0)
        srli t0, t2, 10
        /* Bytes processed: 32 */

        and t1, t0, t3
        sw t1, 52(a0) /* coeff 13 */
        srli t0, t0, 18
        /* Bits remaining in register: 4 */
        lw t2, 32(a1)
        and t1, t2, t6
        slli t1, t1, 4
        or t1, t1, t0
        sw t1, 56(a0)
        srli t0, t2, 14
        /* Bytes processed: 36 */

        /* Bits remaining in register: 18 */
        and t1, t0, t3
        sw t1, 60(a0) /* coeff 15 */
        /* Bytes processed: 36 */

        addi a1, a1, 36
        addi a0, a0, 64
    
    /* reset pointer */
    addi a0, a0, -1024

    /* vectorized subtraction from gamma1 */
    li t0, 0
    li t1, 1
    la t2, gamma1_vec_const
    bn.lid t1, 0(t2)
    LOOPI 32, 3
        /* w0 <= coeffs[i:i+8] */
        bn.lid t0, 0(a0)
        /* w0 <= gamma1_vec_const - w0 */
        bn.subv.8S w0, w1, w0
        /* coeffs[i:i+8] <= w0 */
        bn.sid t0, 0(a0++)

    ret

/**
 * poly_chknorm_dilithium
 *
 * Check infinity norm of polynomial against given bound.
 * Assumes input coefficients were reduced by reduce32().
 * 
 * Returns: 0 if norm is strictly smaller than B <= (Q-1)/8 and 1 otherwise.
 *
 * Flags: TODO
 *
 * @param[in]     a1: norm bound
 * @param[in]     a0: pointer to polynomial
 *
 * clobbered registers: a0-a1, t0-t5, w1-w2
 */
 .global poly_chknorm_dilithium
poly_chknorm_dilithium:
    /* save fp to stack */
    addi sp, sp, -32
    sw   fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -32

    /* Reserve space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR -32

    /* Load modulus Q */
    la   t0, modulus
    lw   t1, 0(t0)
    /* Compute (Q-1)/8 */
    addi t1, t1, -1
    srli t1, t1, 3 /* /8 */

    /* (Q-1)/8 <? B  */
    slt t2, t1, a1
    li  t0, 1
    beq t0, t2, _ret1_poly_chknorm_dilithium

    /* Set end address */
    addi t0, a0, 1024
    /* Setup WDRs */
    li t1, 1
    li t2, 2
_loop_poly_chknorm_dilithium:
    bn.lid      t1, 0(a0)
    /* constant time absolute value 
       t = a->coeffs[i] >> 31;
       t = a->coeffs[i] - (t & 2*a->coeffs[i]);
    */
    /* Get the mask */
    /* w2 <= 0, if w1 >=? 0, else 0xFFFFFFFF */ 
    bn.orv.8S   w2, bn0, w1 a >> 31
    /* w2 <= w2 & (2 * w1) */
    bn.andv.8S  w2, w2, w1 a << 1
    /* w2 <= w1 - w2 */
    bn.subv.8S  w2, w1, w2
    bn.sid      t2, STACK_WDR2GPR(fp)
    
    addi t4, fp, STACK_WDR2GPR
    /* Check bound */
    .irp    offset,0,4,8,12,16,20,24,28
        lw  t3, \offset(t4)
        /* t5 <= 1, if t3 <? a1, else 0 with a1 the bound */
        slt t5, t3, a1
        beq t5, zero, _ret1_poly_chknorm_dilithium
    .endr

    addi a0, a0, 32
    bne a0, t0, _loop_poly_chknorm_dilithium

_ret0_poly_chknorm_dilithium:
    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32
    /* return success */
    li a0, 0
    ret
_ret1_poly_chknorm_dilithium:
    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32
    /* return fail */
    li a0, 1
    ret

/**
 * poly_challenge
 *
 * Implementation of H. Samples polynomial with TAU nonzero coefficients in
 * {-1,1} using the output stream of SHAKE256(seed).
 * 
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]  a1: mu byte array containing seed of length SEEDBYTES
 * @param[out] a0: pointer to output polynomial
 *
 * clobbered registers: a0-a5, t0-t3, w0-w3
 */
.global poly_challenge
poly_challenge:
    /* save fp to stack */
    addi sp, sp, -32
    sw fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -32

    /* Reserve space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR -32

    /* Initialize output poly to 0 */
    add t1, zero, a0
    /* w31 contains all zeros by convention */ 
    li t0, 31
    LOOPI 32, 1
        bn.sid t0, 0(t1++)

    /* save output pointer */
    addi a4, a0, 0

    /* Initialize a SHAKE256 operation. */
    addi      t0, zero, SHAKE256_START_CMD
    csrrw     zero, KECCAK_CMD_REG, t0
    /* Send the message to the Keccak core. */
    addi a0, a1, 0 /* a0 <= *mu */
    li a1, 32 /* a1 <= SEEDBYTES */
    jal x1, keccak_send_message

    /* Restore output pointer */
    addi a1, a0, 0
    addi a0, a4, 0

    /* Setup WDR */
    li t0, 0
    li a6, 3
    /* Read first SHAKE output */
    bn.wsrr  w0, 0x9 /* KECCAK_DIGEST */

    /* fill signs */

    /* Load mask (2**64)-1 to w2 */
    bn.addi w1, bn0, 1
    bn.or w2, bn0, w1 << 64
    bn.sub w2, w2, w1

    /* w1 <= signs */
    /* Mask out the sign bits from the WDR containing the SHAKE output */
    bn.or w1, bn0, w0
    bn.and w1, w1, w2
    /* w2 <= 1-bit mask */
    bn.addi w2, bn0, 1
    /* shift out sign bits from the register containing the SHAKE output */
    bn.rshi w0, bn0, w0 >> 64
    /* a2 <= number of remaining bits in buf */
    li a2, 192
    
    li t1, TAU
    li a4, N
    /* a3 <= i = N-TAU */
    sub a3, a4, t1
    li t3, 1

    /* TODO: Check if we could use HW loop? */
_loop_poly_challenge:
    /* get address of c->coeffs[i], the current coefficient */
    slli a5, a3, 2 /* i * 4 for byte position */
    add  a5, a5, a0 /* Add the array start address: c->coeffs + i * 4 */
    /* start do-while loop */
_loop_inner_poly_challenge:
        /* If the SHAKE output "buffer" register w0 is empty, squeeze again.
           Since all reads from w0 are equally large (8 bits) and 8 | 256, 
           we can just check for "zero" */
        bne zero, a2, _loop_inner_skip_load_poly_challenge
        bn.wsrr  w0, 0x9 /* KECCAK_DIGEST */
        li a2, 256 /* reset the remaining bits counter */
_loop_inner_skip_load_poly_challenge:
        /* Store w0 to the stack in order to read one word into a GPR */
        bn.sid t0, STACK_WDR2GPR(fp)
        bn.rshi w0, bn0, w0 >> 8 /* shift out used bits */
        addi a2, a2, -8 /* decrease number of remaining bits */
        /* TODO: optimize this to use all bytes from this load */
        lw t1, STACK_WDR2GPR(fp) /* get one word of SHAKE output into GPR */
        /* t1 = b from the reference implementation */
        andi t1, t1, 0xFF /* mask out one byte, because we only need one */
        sltu t2, a3, t1 /* i <? b */
        /* while(b > i); */
        beq t3, t2, _loop_inner_poly_challenge


    /* Implements:
       c->coeffs[i] = c->coeffs[b];
       c->coeffs[b] = 1 - 2*(signs & 1);
       signs >>= 1; */
    /* get address of c->coeffs[b] */
    slli t1, t1, 2  /* b * 4 for byte position */
    add  t1, t1, a0 /* Add the array start address: c->coeffs + b * 4 */

    /* "swap" */
    lw t2, 0(t1) /* Load c->coeffs[b] */
    sw t2, 0(a5) /* c->coeffs[i] = c->coeffs[b]; */

    /* TODO: accumulate result values in WDR and store once 32 bytes; avoid 
       moving between WDR and GPR? */
    bn.and  w3, w1, w2            /* signs & 1 */
    bn.add  w3, w3, w3            /* 2 * (signs & 1) */
    bn.sub  w3, w2, w3            /* 1 - 2 * (signs & 1) */
    bn.sid  a6, STACK_WDR2GPR(fp) /* Store w3 to memory to move value to GPR */
    lw      t2, STACK_WDR2GPR(fp)
    sw      t2, 0(t1)             /* c->coeffs[b] = 1 - 2*(signs & 1); */

    bn.rshi w1, bn0, w1 >> 1 /* Discard the used bit: signs >>= 1 */

    addi a3, a3, 1 /* i++ */
    bne  a3, a4, _loop_poly_challenge /* i != N */

    /* Finish the SHAKE-256 operation. */
    addi  t0, zero, KECCAK_DONE_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* sp <- fp */
    addi sp, fp, 0

    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32

    ret

/**
 * poly_uniform
 *
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]  a0: pointer to rho
 * @param[in]  a2: nonce
 * @param[out] a1: dmem pointer to polynomial
 *
 * clobbered registers: a0-a5, t0-t5, w8
 */
.global poly_uniform
poly_uniform:
    /* TODO: Check if this is required */ 
    /* 32 byte align the sp */
    andi a5, sp, 31
    beq  a5, zero, _aligned
    sub  sp, sp, a5
_aligned:
    /* save fp to stack, use 32 bytes to keep it 32-byte aligned */
    addi sp, sp, -32
    sw   fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -64

    /* Space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR -32
    /* Space for the nonce */
    #define STACK_NONCE -64

    /* Store nonce to memory */
    sw a2, STACK_NONCE(fp)

    /* Load Q to GPR */
    la t0, modulus
    lw a2, 0(t0)
    
    /* Initialize a SHAKE128 operation. */
    addi  t0, zero, SHAKE128_START_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Send the message to the Keccak core. */
    addi a4, a1, 0               /* save output pointer */
    addi a1, zero, 32            /* set message length */
    jal  x1, keccak_send_message /* a0 already contains the input buffer */
    addi a1, zero, 2             /* set message length */
    /* TODO: Have a separate keccak_send_message that can read from a reg, not
       mem? */
    addi a0, fp, STACK_NONCE      /* Set a0 to point to the nonce in memory */
    jal  x1, keccak_send_message

    addi a1, a4, 0 /* move output pointer back to a1 */
    
    /* t0 = 1020, a1 + 1020 is the last valid address */
    addi t0, a1, 1020

    /* Load mask for coefficient */
    li t2, 0x7FFFFF

    /* WDR index */
    li t5, 8

    /* Loop until 256 coefficients have been written to the output */
_rej_sample_loop:
    /* First squeeze */
    .equ w8, shake_reg
    bn.wsrr  shake_reg, 0x9 /* KECCAK_DIGEST */

    /* With one SHAKE squeeze, we get 32 bytes of data. From this, we can try to
       build 10 coefficients with 3 bytes each and are left with 2 bytes
       remainder. We then take the two remaining bytes and one byte from the
       next squeeze operation and try to get another coefficient, leaving us
       with 31 bytes from which we can, again, try to read 10 coefficients and
       are left with 1 byte remainder. From the next 32 bytes, we take 2 bytes
       and try to build one coefficient with the remaining 1 byte. Finally, we
       are left with 30 bytes which we can try to turn into 10 coefficients
       without any remainder. lcm(3, 32) = 96, meaning we use 96 bytes of SHAKE
       output each (full) iteration of the main loop. In case we reach the
       target amount of coefficients, we jump to _end_rej_sample_loop and exit.
       */

    /* Process floor(32 bytes / 3 bytes) * 3 bytes = 30 bytes */
    /* Init loop counter because we cannot early exit hw loops */
    li t4, 10
_rej_sample_loop_p1:
        /* Get least significant word of shake output into GPR */
        bn.sid t5, STACK_WDR2GPR(fp)
        lw     t1, STACK_WDR2GPR(fp)

        /* Shift out the 3 bytes we read for the next potential coefficient */
        bn.or shake_reg, bn0, shake_reg >> 24

        and  t1, t2, t1             /* Mask the bytes from Shake */
        slt  t3, t1, a2             /* t3 <= 1, if t1 <? Q, else 0 */ 
        beq  t3, zero, _skip_store1 /* Reject */
        sw   t1, 0(a1)

        /* if we have written the last coefficient, exit */
        beq  a1, t0, _end_rej_sample_loop
        addi a1, a1, 4 /* increment output pointer */

_skip_store1:
        /* Loop logic */
        addi t4, t4, -1
        bne  t4, zero, _rej_sample_loop_p1

    /* Process remaining 2 bytes */
    /* Get last two bytes of shake output in shake_reg into GPR t1 */
    bn.sid t5, STACK_WDR2GPR(fp)
    lw     t1, STACK_WDR2GPR(fp)

    /* Squeeze */
    bn.wsrr shake_reg, 0x9 /* KECCAK_DIGEST */

    /* Move 4 byte of the SHAKE output into GPR t3 */
    bn.sid t5, STACK_WDR2GPR(fp)
    lw     t3, STACK_WDR2GPR(fp)
    /* We use only 1 byte of the 4, so shift by 8 */
    bn.or  shake_reg, bn0, shake_reg >> 8
    andi   t3, t3, 0xFF                   /* Only keep lowest byte */
    slli   t3, t3, 16                     /* Shift it to be byte at index 3 */
    or     t1, t3, t1                     /* Merge with remaining bytes */
    and    t1, t2, t1                     /* Mask the bytes from Shake */
    slt    t3, t1, a2                     /* t3 <= 1, if t1 <? Q, else 0 */ 
    beq    t3, zero, _skip_store2         /* reject */
    sw     t1, 0(a1)                      /* Store fitting coefficient */

    /* if we have written the last coefficient, exit */
    beq  a1, t0, _end_rej_sample_loop
    addi a1, a1, 4 /* increment output pointer */
_skip_store2:

    /* Process floor(31/3)*3 = 30 bytes */
    /* Init loop counter because we cannot early exit hw loops */
    addi t4, zero, 10
_rej_sample_loop_p2:
        /* Get least significant word of shake output into GPR */
        bn.sid t5, STACK_WDR2GPR(fp)
        lw     t1, STACK_WDR2GPR(fp)

        /* Shift out the 3 bytes we read for the next potential coefficient */
        bn.or  shake_reg, bn0, shake_reg >> 24

        and  t1, t2, t1             /* Mask the bytes from Shake */
        slt  t3, t1, a2             /* t3 <= 1, if t1 <? Q, else 0 */ 
        beq  t3, zero, _skip_store3 /* reject */ 
        sw   t1, 0(a1)              /* Store fitting coefficient */

        /* if we have written the last coefficient, exit */
        beq  a1, t0, _end_rej_sample_loop
        addi a1, a1, 4 /* increment output pointer */

_skip_store3:
        /* Loop logic */
        addi t4, t4, -1
        bne  t4, zero, _rej_sample_loop_p2

    /* Process remaining 1 byte */
    /* Get last byte of shake output in shake_reg into GPR */
    bn.sid t5, STACK_WDR2GPR(fp)
    lw     t1, STACK_WDR2GPR(fp)

    /* Squeeze */
    bn.wsrr  shake_reg, 0x9 /* KECCAK_DIGEST */

    /* Move 4 byte of the SHAKE output into GPR t3 */
    bn.sid t5, STACK_WDR2GPR(fp)
    lw     t3, STACK_WDR2GPR(fp)
    bn.or  shake_reg, bn0, shake_reg >> 16 /* Using 2 of 4 bytes, so shift 16 */
    li     t4, 0xFFFF                      /* Only keep lower 2 bytes */
    and    t3, t3, t4                      /* Mask */
    slli   t3, t3, 8                       /* Shift to be bytes at index 2+3 */
    or     t1, t1, t3                      /* Merge with remaining byte */
    and    t1, t2, t1                      /* Mask the bytes from Shake */
    slt    t3, t1, a2                      /* t3 <= 1, if t1 <? Q, else 0 */ 
    beq    t3, zero, _skip_store4          /* Reject */
    sw     t1, 0(a1)                       /* Store fitting coefficient */

    /* if we have written the last coefficient, exit */
    beq  a1, t0, _end_rej_sample_loop
    addi a1, a1, 4 /* increment output pointer */
_skip_store4:

    /* Process floor(30/3)*3 = 30 bytes */
    /* Init loop counter because we cannot early exit hw loops */
    li t4, 10
_rej_sample_loop_p3:
        /* Get least significant word of shake output into GPR */
        bn.sid t5, STACK_WDR2GPR(fp)
        lw     t1, STACK_WDR2GPR(fp)

        /* Shift out the 3 bytes we read for the next potential coefficient */
        bn.or  shake_reg, bn0, shake_reg >> 24

        and t1, t2, t1             /* Mask the bytes from Shake */
        slt t3, t1, a2             /* t3 <= 1, if t1 <? Q, else 0 */ 
        beq t3, zero, _skip_store5 /* Reject */
        sw  t1, 0(a1)

        /* if we have written the last coefficient, exit */
        beq  a1, t0, _end_rej_sample_loop
        addi a1, a1, 4

_skip_store5:
        /* Loop logic */
        addi t4, t4, -1
        bne t4, zero, _rej_sample_loop_p3

    /* No remainder! Start all over again. */
    beq zero, zero, _rej_sample_loop

_end_rej_sample_loop:
    /* Finish the SHAKE-256 operation. */
    addi  t0, zero, KECCAK_DONE_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32
    /* Correct alignment offset (unalign) */
    add sp, sp, a5

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
 * clobbered registers: a1, a3-a5, w8-w15, t0-t6
 */
.global poly_uniform_eta
poly_uniform_eta:
/* 32 byte align the sp */
    andi a5, sp, 31
    beq a5, zero, _aligned_poly_uniform_eta
    sub sp, sp, a5
_aligned_poly_uniform_eta:
    /* save fp to stack, use 32 bytes to keep it 32-byte aligned */
    addi sp, sp, -32
    sw fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -64

    /* Space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR -32

    /* Space for the nonce */
    #define STACK_NONCE -64

    /* Store nonce to memory */
    sw a2, STACK_NONCE(fp)

    /* Load a3 <= Q */
    la t0, modulus
    lw a3, 0(t0)
    
    /* Initialize a SHAKE256 operation. */
    addi  t0, zero, SHAKE256_START_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Send the messages to the Keccak core. */
    addi a4, a1, 0               /* save output pointer */
    addi a1, zero, 64            /* set rho length */
    jal  x1, keccak_send_message /* a0 already contains the input buffer */
    addi a1, zero, 2             /* set nonce length */
    addi a0, fp, STACK_NONCE     /* After rho, absorb nonce */
    jal  x1, keccak_send_message
    addi a1, a4, 0 /* move output pointer back to a1 */

    /* t0 = 1024, stop address*/
    addi t0, a1, 1024

    /* Initialize constants for WDR index */
    li t5, 9
    li t6, 10
_rej_eta_sample_loop:
    /* First squeeze */
    .equ w8, shake_reg
    bn.wsrr  shake_reg, 0x9 /* KECCAK_DIGEST */
    
    /* Loop counter, we have 32B to read from shake */
    li t4, 32
    /* Initialize constants */
    bn.addi w14, bn0, 0xFF
    bn.addi w15, bn0, 15
    bn.addi w12, bn0, 205
    bn.addi w0, bn0, 5
    bn.addi w1, bn0, 2

_rej_eta_sample_loop_inner:
        /* Process first 4 bits */
        bn.and  w9, shake_reg, w14            /* Mask out all other bytes */
        bn.or  shake_reg, bn0, shake_reg >> 8 /* shift out the used byte */

        
        bn.rshi w10, bn0, w9 >> 4 /* Prepare "t1" */
        bn.and  w9, w9, w15       /* Prepare "t0" */

        /* Check "t0" < 15 */
        /* Instead of < 15, != 15 can also be checked because we are
            operating on 4-bit values */
        bn.cmp w9, w15
            /* Get the FG0.Z flag into a register.
            t2 <= (CSRs[FG0] >> 3) & 1 = FG0.Z */
        csrrs  t2, 0x7c0, zero
        srli   t2, t2, 3
        andi   t2, t2, 1

        bne t2, zero, _rej_eta_sample_loop_inner_1

        /* "t{0,1}" indicate the variable names from the reference code */ 

        /* Compute "t0" = "t0" - (205 * "t0" >> 10) * 5 from reference code */
        bn.mulv.8S w13, w12, w9        /* 205 * "t0" */
        bn.rshi    w13, bn0, w13 >> 10 /* (205 * "t0" >> 10) */
        bn.mulv.8S w13, w0, w13        /* (205 * "t0" >> 10) * 5 */
        bn.subv.8S w9, w9, w13         /* "t0" - (205 * "t0" >> 10) * 5 */
        bn.subv.8S w9, w1, w9          /* 2 - ("t0" - (205 * "t0" >> 10) * 5) */

        /* Store coefficient value from WDR into target polynomial */
        bn.sid t5, STACK_WDR2GPR(fp)
        lw     t2, STACK_WDR2GPR(fp)
        sw     t2, 0(a1)

        /* Loop logic */
        addi a1, a1, 4
        beq  a1, t0, _end_rej_eta_sample_loop

_rej_eta_sample_loop_inner_1:
        /* Process last 4 bits */

        /* Check "t1" != 15 */
        bn.cmp  w10, w15
            /* Get the FG0.Z flag into a register.
            t2 <= (CSRs[FG0] >> 3) & 1 = FG0.Z */
        csrrs    t2, 0x7c0, zero
        srli     t2, t2, 3
        andi     t2, t2, 1

        bne t2, zero, _rej_eta_sample_loop_inner_none

        /* Compute "t1" = "t1" - (205 * "t1" >> 10) * 5 from reference code */
        bn.mulv.8S w13, w12, w10       /* 205 * "t1" */
        bn.rshi    w13, bn0, w13 >> 10 /* (205 * "t1" >> 10) */
        bn.mulv.8S w13, w0, w13        /* (205 * "t1" >> 10) * 5 */
        bn.subv.8S w10, w10, w13       /* "t1" - (205 * "t1" >> 10) * 5 */
        bn.subv.8S w10, w1, w10        /* 2 - ("t1" - (205 * "t1" >> 10) * 5) */

        /* Store coefficient value from WDR into target polynomial */
        bn.sid t6, STACK_WDR2GPR(fp)
        lw     t2, STACK_WDR2GPR(fp)
        sw     t2, 0(a1)

        /* Loop logic */
        addi a1, a1, 4
        beq  a1, t0, _end_rej_eta_sample_loop

_rej_eta_sample_loop_inner_none:
    /* Check if there are still SHAKE bytes left for next iteration */
    addi t4, t4, -1
    bne zero, t4, _rej_eta_sample_loop_inner

    /* All SHAKE bytes used and not done, squeeze again */
    beq zero, zero, _rej_eta_sample_loop

_end_rej_eta_sample_loop:
    /* Finish the SHAKE-256 operation. */
    addi  t0, zero, KECCAK_DONE_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32
    /* Correct alignment offset (unalign) */
    add sp, sp, a5

    ret

/**
 * poly_use_hint_dilithium
 *
 * Use hint polynomial to correct the high bits of a polynomial.
 * 
 * Returns: 
 *
 * Flags: TODO
 *
 * @param[in]     a0: output poly pointer
 * @param[out]    a1: input poly pointer
 * @param[out]    a2: input hint poly pointer
 *
 * clobbered registers: a0-a5, t0-t6, w0-w11
 */
.global poly_use_hint_dilithium
poly_use_hint_dilithium:
    /* save fp to stack */
    addi sp, sp, -32
    sw fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -64

    /* Reserve space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR1 -32
    #define STACK_WDR2GPR2 -64
    addi a3, a0, 1024 /* overall stop address */

    /* Constants */
    li a4, 43
    li a5, 1
    li a6, 2

    /* WDR constants for decompose */
    la t0, decompose_127_const
    li t1, 5
    /* w5 <= decompose_127_const */
    bn.lid t1, 0(t0)

    la t0, decompose_const
    li t1, 6
    /* w6 <= decompose_const */
    bn.lid t1, 0(t0)

    la t0, reduce32_const
    li t1, 7
    /* w7 <= reduce32_const */
    bn.lid t1, 0(t0)

    la t0, decompose_43_const
    li t1, 8
    /* w8 <= decompose_43_const */
    bn.lid t1, 0(t0)

    la t0, gamma2_vec_const
    li t1, 9
    /* w9 <= gamma2_vec_const */
    bn.lid t1, 0(t0)

    la t0, qm1half_const
    li t1, 10
    /* w10 <= qm1half_const */
    bn.lid t1, 0(t0)

    la t0, modulus
    li t1, 11
    /* w11 <= modulus */
    bn.lid t1, 0(t0)

_loop_poly_use_hint_dilithium:
    /* vectorized part: decompose */
    li     t0, 0
    bn.lid t0, 0(a1++)
    jal    x1, decompose_dilithium

    /* Store result form decomposition do dmem */
    bn.sid a5, STACK_WDR2GPR1(fp)
    bn.sid a6, STACK_WDR2GPR2(fp)

    /* "a{0,1}" refers to the variables from the reference code */

    addi t2, fp, STACK_WDR2GPR1 /* "a0" */
    addi t3, fp, STACK_WDR2GPR2 /* "a1" */
    addi t4, a0, 32             /* stop address */

    /* scalar part starts here */
    LOOPI 8, 23
        lw  t1, 0(t3) /* Load "a1" */
        /* Check if hint is 0 */
        lw  t5, 0(a2)
        bne t5, zero, _inner_loop_skip_store1_poly_use_hint_dilithium
        sw  t1, 0(a0)
        beq zero, zero, _inner_loop_end_poly_use_hint_dilithium
_inner_loop_skip_store1_poly_use_hint_dilithium:
        /* if(0 < "a0") */
        lw t5, 0(t2)
        slt t5, zero, t5
        bne t5, a5, _inner_loop_else_poly_use_hint_dilithium /* go to else-branch */
        /* if("a1" == 43) */
        bne t1, a4, _inner_loop_aplus1_poly_use_hint_dilithium /* go to else-branch */
        sw zero, 0(a0) /* return 0 */
        beq zero, zero, _inner_loop_end_poly_use_hint_dilithium /* go to iteration end */
_inner_loop_aplus1_poly_use_hint_dilithium:
        /* if("a1" == 43) else-branch */
        /* Store "a1" + 1 */
        addi t1, t1, 1
        sw t1, 0(a0)
        beq zero, zero, _inner_loop_end_poly_use_hint_dilithium /* unconditional */
_inner_loop_else_poly_use_hint_dilithium:
        /* if(0 < "a0") else-branch */
        /* if("a1" == 0) */
        bne t1, zero, _inner_loop_aminus1_poly_use_hint_dilithium /* go to else-branch */
        /* Store 43 */
        sw a4, 0(a0)
        beq zero, zero, _inner_loop_end_poly_use_hint_dilithium
_inner_loop_aminus1_poly_use_hint_dilithium:
        /* if("a1" == 0) else-branch */
        /* Store "a1" - 1 */
        addi t1, t1, -1
        sw t1, 0(a0)
_inner_loop_end_poly_use_hint_dilithium:
        addi t3, t3, 4 /* increment "a1" pointer */
        addi a0, a0, 4 /* increment output */
        addi t2, t2, 4 /* increment "a0" pointer */
        addi a2, a2, 4 /* increment *hint */
        /* LOOP END */

    bne a3, a0, _loop_poly_use_hint_dilithium

    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32
    ret

/**
 * polyt1_pack_dilithium
 *
 * Bit-pack polynomial t1 with coefficients fitting in 10 bits. Input
 * coefficients are assumed to be standard representatives.
 *
 * Flags: TODO
 *
 * @param[out] a0: pointer to output byte array with at least
                   POLYT1_PACKEDBYTES bytes
 * @param[in]  a1: pointer to input polynomial
 *
 * clobbered registers: a0-a1, t0-t2
 */
.global polyt1_pack_dilithium
polyt1_pack_dilithium:
    LOOPI 16, 63
        xor t2, t2, t2
        /* coefficient 1 */
        lw t0, 0(a1)
        or t2, t2, t0 /* 10 bits in t2 */
        /* coefficient 2 */
        lw t0, 4(a1)
        slli t1, t0, 10
        or t2, t2, t1 /* 20 bits in t2 */
        /* coefficient 3 */
        lw t0, 8(a1)
        slli t1, t0, 20
        or t2, t2, t1 /* 30 bits in t2 */
        /* coefficient 4 - first 2 bits */
        lw t0, 12(a1)
        slli t1, t0, 30
        or t2, t2, t1 /* 32 bits in t2 */
        sw t2, 0(a0)
        /* coefficient 4 - remaining 8 bits */
        srli t0, t0, 2
        or t2, zero, t0 /* 8 bits in t2 */

        /* coefficient 5 */
        lw t0, 16(a1)
        slli t1, t0, 8
        or t2, t2, t1 /* 18 bits in t2 */
        /* coefficient 6 */
        lw t0, 20(a1)
        slli t1, t0, 18
        or t2, t2, t1 /* 28 bits in t2 */
        /* coefficient 7 - first 4 bits */
        lw t0, 24(a1)
        slli t1, t0, 28
        or t2, t2, t1
        sw t2, 4(a0)
        /* coefficient 7 - remaining 6 bits */
        srli t0, t0, 4
        or t2, zero, t0 /* 6 bits in t2 */

        /* coefficient 8 */
        lw t0, 28(a1)
        slli t1, t0, 6
        or t2, t2, t1 /* 16 bits in t2 */
        /* coefficient 9 */
        lw t0, 32(a1)
        slli t1, t0, 16
        or t2, t2, t1 /* 26 bits in t2 */
        /* coefficient 10 - first 6 bits */
        lw t0, 36(a1)
        slli t1, t0, 26
        or t2, t2, t1
        sw t2, 8(a0)
        /* coefficient 10 - remaining 4 bits */
        srli t0, t0, 6
        or t2, zero, t0 /* 4 bits in t2 */

        /* coefficient 11 */
        lw t0, 40(a1)
        slli t1, t0, 4
        or t2, t2, t1 /* 14 bits in t2 */
        /* coefficient 12 */
        lw t0, 44(a1)
        slli t1, t0, 14
        or t2, t2, t1 /* 24 bits in t2 */
        /* coefficient 13 - first 8 bits */
        lw t0, 48(a1)
        slli t1, t0, 24
        or t2, t2, t1
        sw t2, 12(a0)
        /* coefficient 13 - remaining 2 bits */
        srli t0, t0, 8
        or t2, zero, t0 /* 2 bits in t2 */

        /* coefficient 14 */
        lw t0, 52(a1)
        slli t1, t0, 2
        or t2, t2, t1 /* 12 bits in t2 */
        /* coefficient 15 */
        lw t0, 56(a1)
        slli t1, t0, 12
        or t2, t2, t1 /* 22 bits in t2 */
        /* coefficient 16 */
        lw t0, 60(a1)
        slli t0, t0, 22
        or t2, t2, t0 /* 32 bits in t2 */
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
 * @param[out] a0: pointer to output byte array with at least
                   POLYETA_PACKEDBYTES bytes
 * @param[in]  a1: pointer to input polynomial
 *
 * clobbered registers: a0-a1, t0-t3, w1, w2
 */
.global polyeta_pack_dilithium
polyeta_pack_dilithium:
    /* Compute ETA - coeff */
    /* Setup WDRs */
    addi t1, zero, 1
    addi t2, zero, 2

    /* Load precomputed, vectorized eta */
    la t0, eta
    bn.lid t1, 0(t0)

    LOOPI 32, 3
        /* w2 <= coeffs[i:i+8] */
        bn.lid t2, 0(a1)
        /* w2 <= eta - w2 */
        bn.subv.8S w2, w1, w2
        /* coeffs[i:i+8] <= w2 */
        bn.sid t2, 0(a1++)

    /* reset input pointer */
    addi a1, a1, -1024

    /* Collect bytes in t3, the visualization shows the current state of t3 */
    LOOPI 8, 105
        xor t3, t3, t3
        /* oooooooooooooooooooooooooooooooo */
        /* coefficient 0 */
        lw t0, 0(a1)
        or t3, t3, t0
        /* ***ooooooooooooooooooooooooooooo| */
        /* coefficient 1 */
        lw t0, 4(a1)
        slli t1, t0, 3
        or t3, t3, t1
        /* ******oooooooooooooooooooooooooo| */
        /* coefficient 2 */
        lw t0, 8(a1)
        slli t1, t0, 6
        or t3, t3, t1
        /* *********ooooooooooooooooooooooo| */
        /* coefficient 3 */
        lw t0, 12(a1)
        slli t1, t0, 9
        or t3, t3, t1
        /* ************oooooooooooooooooooo| */
        /* coefficient 4 */
        lw t0, 16(a1)
        slli t1, t0, 12
        or t3, t3, t1
        /* ***************ooooooooooooooooo| */
        /* coefficient 5 */
        lw t0, 20(a1)
        slli t1, t0, 15
        or t3, t3, t1
        /* ******************oooooooooooooo| */
        /* coefficient 6 */
        lw t0, 24(a1)
        slli t1, t0, 18
        or t3, t3, t1
        /* *********************ooooooooooo| */
        /* coefficient 7 */
        lw t0, 28(a1)
        slli t1, t0, 21
        or t3, t3, t1
        /* ************************oooooooo| */
        /* coefficient 8 */
        lw t0, 32(a1)
        slli t1, t0, 24
        or t3, t3, t1
        /* ***************************ooooo| */
        /* coefficient 9 */
        lw t0, 36(a1)
        slli t1, t0, 27
        or t3, t3, t1
        /* ******************************oo| */
        /* coefficient 10 */
        lw t0, 40(a1)
        slli t1, t0, 30
        or t3, t3, t1
        /* ********************************|x */
        sw t3, 0(a0)
        srli t0, t0, 2
        or t3, zero, t0
        /* *ooooooooooooooooooooooooooooooo */
        /* coefficient 11 */
        lw t0, 44(a1)
        slli t1, t0, 1
        or t3, t3, t1
        /* ****oooooooooooooooooooooooooooo| */
        /* coefficient 12 */
        lw t0, 48(a1)
        slli t1, t0, 4
        or t3, t3, t1
        /* *******ooooooooooooooooooooooooo| */
        /* coefficient 13 */
        lw t0, 52(a1)
        slli t1, t0, 7
        or t3, t3, t1
        /* **********oooooooooooooooooooooo| */
        /* coefficient 14 */
        lw t0, 56(a1)
        slli t1, t0, 10
        or t3, t3, t1
        /* *************ooooooooooooooooooo| */
        /* coefficient 15 */
        lw t0, 60(a1)
        slli t1, t0, 13
        or t3, t3, t1
        /* ****************oooooooooooooooo| */
        /* coefficient 16 */
        lw t0, 64(a1)
        slli t1, t0, 16
        or t3, t3, t1
        /* *******************ooooooooooooo| */
        /* coefficient 17 */
        lw t0, 68(a1)
        slli t1, t0, 19
        or t3, t3, t1
        /* **********************oooooooooo| */
        /* coefficient 18 */
        lw t0, 72(a1)
        slli t1, t0, 22
        or t3, t3, t1
        /* *************************ooooooo| */
        /* coefficient 19 */
        lw t0, 76(a1)
        slli t1, t0, 25
        or t3, t3, t1
        /* ****************************oooo| */
        /* coefficient 20 */
        lw t0, 80(a1)
        slli t1, t0, 28
        or t3, t3, t1
        /* *******************************o| */
        /* coefficient 21 */
        lw t0, 84(a1)
        slli t1, t0, 31
        or t3, t3, t1
        /* ********************************|xx */
        sw t3, 4(a0)
        srli t0, t0, 1
        or t3, zero, t0
        /* **oooooooooooooooooooooooooooooo */
        /* coefficient 22 */
        lw t0, 88(a1)
        slli t1, t0, 2
        or t3, t3, t1
        /* *****ooooooooooooooooooooooooooo| */
        /* coefficient 23 */
        lw t0, 92(a1)
        slli t1, t0, 5
        or t3, t3, t1
        /* ********oooooooooooooooooooooooo| */
        /* coefficient 24 */
        lw t0, 96(a1)
        slli t1, t0, 8
        or t3, t3, t1
        /* ***********ooooooooooooooooooooo| */
        /* coefficient 25 */
        lw t0, 100(a1)
        slli t1, t0, 11
        or t3, t3, t1
        /* **************oooooooooooooooooo| */
        /* coefficient 26 */
        lw t0, 104(a1)
        slli t1, t0, 14
        or t3, t3, t1
        /* *****************ooooooooooooooo| */
        /* coefficient 27 */
        lw t0, 108(a1)
        slli t1, t0, 17
        or t3, t3, t1
        /* ********************oooooooooooo| */
        /* coefficient 28 */
        lw t0, 112(a1)
        slli t1, t0, 20
        or t3, t3, t1
        /* ***********************ooooooooo| */
        /* coefficient 29 */
        lw t0, 116(a1)
        slli t1, t0, 23
        or t3, t3, t1
        /* **************************oooooo| */
        /* coefficient 30 */
        lw t0, 120(a1)
        slli t1, t0, 26
        or t3, t3, t1
        /* *****************************ooo| */
        /* coefficient 31 */
        lw t0, 124(a1)
        slli t1, t0, 29
        or t3, t3, t1
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
 * Flags: TODO
 *
 * @param[out] a0: pointer to output byte array with at least
                   POLYETA_PACKEDBYTES bytes
 * @param[in]  a1: pointer to input polynomial
 *
 * clobbered registers: a0-a1, t0-t3, w1, w2
 */
.global polyt0_pack_dilithium
polyt0_pack_dilithium:
    /* Compute (1 << (D-1)) - coeff */
    /* Setup WDRs */
    li t1, 1
    li t2, 2

    /* Load precomputed (1 << (D-1)) */
    la     t0, polyt0_pack_const
    bn.lid t1, 0(t0)

    /* This loop overwrites the original t0 */
    LOOPI 32, 3
        bn.lid     t2, 0(a1)   /* w2 <= coeffs[i:i+8] */
        bn.subv.8S w2, w1, w2  /* w2 <= (1 << (D-1)) - coeffs */
        bn.sid     t2, 0(a1++) /* coeffs[i:i+8] <= w2 */

    /* reset input pointer */
    addi a1, a1, -1024

    LOOPI 8, 135
        xor t3, t3, t3
        /* oooooooooooooooooooooooooooooooo */
        /* coefficient 0 */
        lw t0, 0(a1)
        or t3, t3, t0
        /* *************ooooooooooooooooooo| */
        /* coefficient 1 */
        lw t0, 4(a1)
        slli t1, t0, 13
        or t3, t3, t1
        /* **************************oooooo| */
        /* coefficient 2 */
        lw t0, 8(a1)
        slli t1, t0, 26
        or t3, t3, t1
        /* ********************************|xxxxxxx */
        sw t3, 0(a0)
        srli t0, t0, 6
        or t3, zero, t0
        /* *******ooooooooooooooooooooooooo */
        /* coefficient 3 */
        lw t0, 12(a1)
        slli t1, t0, 7
        or t3, t3, t1
        /* ********************oooooooooooo| */
        /* coefficient 4 */
        lw t0, 16(a1)
        slli t1, t0, 20
        or t3, t3, t1
        /* ********************************|x */
        sw t3, 4(a0)
        srli t0, t0, 12
        or t3, zero, t0
        /* *ooooooooooooooooooooooooooooooo */
        /* coefficient 5 */
        lw t0, 20(a1)
        slli t1, t0, 1
        or t3, t3, t1
        /* **************oooooooooooooooooo| */
        /* coefficient 6 */
        lw t0, 24(a1)
        slli t1, t0, 14
        or t3, t3, t1
        /* ***************************ooooo| */
        /* coefficient 7 */
        lw t0, 28(a1)
        slli t1, t0, 27
        or t3, t3, t1
        /* ********************************|xxxxxxxx */
        sw t3, 8(a0)
        srli t0, t0, 5
        or t3, zero, t0
        /* ********oooooooooooooooooooooooo */
        /* coefficient 8 */
        lw t0, 32(a1)
        slli t1, t0, 8
        or t3, t3, t1
        /* *********************ooooooooooo| */
        /* coefficient 9 */
        lw t0, 36(a1)
        slli t1, t0, 21
        or t3, t3, t1
        /* ********************************|xx */
        sw t3, 12(a0)
        srli t0, t0, 11
        or t3, zero, t0
        /* **oooooooooooooooooooooooooooooo */
        /* coefficient 10 */
        lw t0, 40(a1)
        slli t1, t0, 2
        or t3, t3, t1
        /* ***************ooooooooooooooooo| */
        /* coefficient 11 */
        lw t0, 44(a1)
        slli t1, t0, 15
        or t3, t3, t1
        /* ****************************oooo| */
        /* coefficient 12 */
        lw t0, 48(a1)
        slli t1, t0, 28
        or t3, t3, t1
        /* ********************************|xxxxxxxxx */
        sw t3, 16(a0)
        srli t0, t0, 4
        or t3, zero, t0
        /* *********ooooooooooooooooooooooo */
        /* coefficient 13 */
        lw t0, 52(a1)
        slli t1, t0, 9
        or t3, t3, t1
        /* **********************oooooooooo| */
        /* coefficient 14 */
        lw t0, 56(a1)
        slli t1, t0, 22
        or t3, t3, t1
        /* ********************************|xxx */
        sw t3, 20(a0)
        srli t0, t0, 10
        or t3, zero, t0
        /* ***ooooooooooooooooooooooooooooo */
        /* coefficient 15 */
        lw t0, 60(a1)
        slli t1, t0, 3
        or t3, t3, t1
        /* ****************oooooooooooooooo| */
        /* coefficient 16 */
        lw t0, 64(a1)
        slli t1, t0, 16
        or t3, t3, t1
        /* *****************************ooo| */
        /* coefficient 17 */
        lw t0, 68(a1)
        slli t1, t0, 29
        or t3, t3, t1
        /* ********************************|xxxxxxxxxx */
        sw t3, 24(a0)
        srli t0, t0, 3
        or t3, zero, t0
        /* **********oooooooooooooooooooooo */
        /* coefficient 18 */
        lw t0, 72(a1)
        slli t1, t0, 10
        or t3, t3, t1
        /* ***********************ooooooooo| */
        /* coefficient 19 */
        lw t0, 76(a1)
        slli t1, t0, 23
        or t3, t3, t1
        /* ********************************|xxxx */
        sw t3, 28(a0)
        srli t0, t0, 9
        or t3, zero, t0
        /* ****oooooooooooooooooooooooooooo */
        /* coefficient 20 */
        lw t0, 80(a1)
        slli t1, t0, 4
        or t3, t3, t1
        /* *****************ooooooooooooooo| */
        /* coefficient 21 */
        lw t0, 84(a1)
        slli t1, t0, 17
        or t3, t3, t1 /* 17 */
        /* ******************************oo| */
        /* coefficient 22 */
        lw t0, 88(a1)
        slli t1, t0, 30
        or t3, t3, t1
        /* ********************************|xxxxxxxxxxx */
        sw t3, 32(a0)
        srli t0, t0, 2
        or t3, zero, t0
        /* ***********ooooooooooooooooooooo */
        /* coefficient 23 */
        lw t0, 92(a1)
        slli t1, t0, 11
        or t3, t3, t1
        /* ************************oooooooo| */
        /* coefficient 24 */
        lw t0, 96(a1)
        slli t1, t0, 24
        or t3, t3, t1
        /* ********************************|xxxxx */
        sw t3, 36(a0)
        srli t0, t0, 8
        or t3, zero, t0
        /* *****ooooooooooooooooooooooooooo */
        /* coefficient 25 */
        lw t0, 100(a1)
        slli t1, t0, 5
        or t3, t3, t1
        /* ******************oooooooooooooo| */
        /* coefficient 26 */
        lw t0, 104(a1)
        slli t1, t0, 18
        or t3, t3, t1
        /* *******************************o| */
        /* coefficient 27 */
        lw t0, 108(a1)
        slli t1, t0, 31
        or t3, t3, t1
        /* ********************************|xxxxxxxxxxxx */
        sw t3, 40(a0)
        srli t0, t0, 1
        or t3, zero, t0
        /* ************oooooooooooooooooooo */
        /* coefficient 28 */
        lw t0, 112(a1)
        slli t1, t0, 12
        or t3, t3, t1
        /* *************************ooooooo| */
        /* coefficient 29 */
        lw t0, 116(a1)
        slli t1, t0, 25
        or t3, t3, t1
        /* ********************************|xxxxxx */
        sw t3, 44(a0)
        srli t0, t0, 7
        or t3, zero, t0
        /* ******oooooooooooooooooooooooooo */
        /* coefficient 30 */
        lw t0, 120(a1)
        slli t1, t0, 6
        or t3, t3, t1
        /* *******************ooooooooooooo| */
        /* coefficient 31 */
        lw t0, 124(a1)
        slli t1, t0, 19
        or t3, t3, t1
        /* ********************************| */
        sw t3, 48(a0)

        addi a1, a1, 128
        addi a0, a0, 52
    
    ret

/**
 * polyw1_pack_dilithium
 *
 * Bit-pack polynomial w1 with coefficients fitting in 6 bits. Input
 * coefficients are assumed to be standard representatives.
 * 
 * Flags: TODO
 *
 * @param[out] a0: pointer to output byte array with at least
                   POLYW1_PACKEDBYTES bytes
 * @param[in]  a1: pointer to input polynomial
 *
 * clobbered registers: a0-a1, t0-t2
 */
.global polyw1_pack_dilithium
polyw1_pack_dilithium:
    LOOPI 16, 57
        xor t2, t2, t2
    
        /* oooooooooooooooooooooooooooooooo */
        /* coefficient 0 */
        lw t0, 0(a1)
        or t2, t2, t0
        /* ******oooooooooooooooooooooooooo| */
        /* coefficient 1 */
        lw t0, 4(a1)
        slli t1, t0, 6
        or t2, t2, t1
        /* ************oooooooooooooooooooo| */
        /* coefficient 2 */
        lw t0, 8(a1)
        slli t1, t0, 12
        or t2, t2, t1
        /* ******************oooooooooooooo| */
        /* coefficient 3 */
        lw t0, 12(a1)
        slli t1, t0, 18
        or t2, t2, t1
        /* ************************oooooooo| */
        /* coefficient 4 */
        lw t0, 16(a1)
        slli t1, t0, 24
        or t2, t2, t1
        /* ******************************oo| */
        /* coefficient 5 */
        lw t0, 20(a1)
        slli t1, t0, 30
        or t2, t2, t1
        /* ********************************|xxxx */
        sw t2, 0(a0)
        srli t0, t0, 2
        or t2, zero, t0
        /* ****oooooooooooooooooooooooooooo */
        /* coefficient 6 */
        lw t0, 24(a1)
        slli t1, t0, 4
        or t2, t2, t1
        /* **********oooooooooooooooooooooo| */
        /* coefficient 7 */
        lw t0, 28(a1)
        slli t1, t0, 10
        or t2, t2, t1
        /* ****************oooooooooooooooo| */
        /* coefficient 8 */
        lw t0, 32(a1)
        slli t1, t0, 16
        or t2, t2, t1
        /* **********************oooooooooo| */
        /* coefficient 9 */
        lw t0, 36(a1)
        slli t1, t0, 22
        or t2, t2, t1
        /* ****************************oooo| */
        /* coefficient 10 */
        lw t0, 40(a1)
        slli t1, t0, 28
        or t2, t2, t1
        /* ********************************|xx */
        sw t2, 4(a0)
        srli t0, t0, 4
        or t2, zero, t0
        /* **oooooooooooooooooooooooooooooo */
        /* coefficient 11 */
        lw t0, 44(a1)
        slli t1, t0, 2
        or t2, t2, t1
        /* ********oooooooooooooooooooooooo| */
        /* coefficient 12 */
        lw t0, 48(a1)
        slli t1, t0, 8
        or t2, t2, t1
        /* **************oooooooooooooooooo| */
        /* coefficient 13 */
        lw t0, 52(a1)
        slli t1, t0, 14
        or t2, t2, t1
        /* ********************oooooooooooo| */
        /* coefficient 14 */
        lw t0, 56(a1)
        slli t1, t0, 20
        or t2, t2, t1
        /* **************************oooooo| */
        /* coefficient 15 */
        lw t0, 60(a1)
        slli t1, t0, 26
        or t2, t2, t1
        /* ********************************| */
        sw t2, 8(a0)

        addi a1, a1, 64
        addi a0, a0, 12
    ret

/**
 * polyeta_unpack_dilithium
 *
 * Unpack polynomial with coefficients fitting in [-ETA, ETA]. 
 *
 * Flags: TODO
 *
 * @param[in]  a1: byte array with bit-packed polynomial
 * @param[out] a0: pointer to output polynomial
 *
 * clobbered registers: a0-a1, t0-t2, w1-w2
 */

.global polyeta_unpack_dilithium
polyeta_unpack_dilithium:
    /* Collect bytes in a2 */
    LOOPI 8, 104
        /* oooooooooooooooooooooooooooooooo */
        lw t0, 0(a1)
        andi t1, t0, 7
        sw t1, 0(a0) /* coeff 0 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 4(a0) /* coeff 1 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 8(a0) /* coeff 2 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 12(a0) /* coeff 3 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 16(a0) /* coeff 4 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 20(a0) /* coeff 5 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 24(a0) /* coeff 6 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 28(a0) /* coeff 7 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 32(a0) /* coeff 8 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 36(a0) /* coeff 9 */
        srli t0, t0, 3
        /* Bits remaining in register: 2 */
        lw t2, 4(a1)
        andi t1, t2, 1
        slli t1, t1, 2
        or t1, t1, t0
        sw t1, 40(a0)
        srli t0, t2, 1
        /* Bytes processed: 8 */

        andi t1, t0, 7
        sw t1, 44(a0) /* coeff 11 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 48(a0) /* coeff 12 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 52(a0) /* coeff 13 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 56(a0) /* coeff 14 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 60(a0) /* coeff 15 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 64(a0) /* coeff 16 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 68(a0) /* coeff 17 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 72(a0) /* coeff 18 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 76(a0) /* coeff 19 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 80(a0) /* coeff 20 */
        srli t0, t0, 3
        /* Bits remaining in register: 1 */
        lw t2, 8(a1)
        andi t1, t2, 3
        slli t1, t1, 1
        or t1, t1, t0
        sw t1, 84(a0)
        srli t0, t2, 2
        /* Bytes processed: 12 */

        andi t1, t0, 7
        sw t1, 88(a0) /* coeff 22 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 92(a0) /* coeff 23 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 96(a0) /* coeff 24 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 100(a0) /* coeff 25 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 104(a0) /* coeff 26 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 108(a0) /* coeff 27 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 112(a0) /* coeff 28 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 116(a0) /* coeff 29 */
        srli t0, t0, 3
        andi t1, t0, 7
        sw t1, 120(a0) /* coeff 30 */
        srli t0, t0, 3
        /* Bits remaining in register: 3 */
        andi t1, t0, 7
        sw t1, 124(a0) /* coeff 31 */
        /* Bytes processed: 12 */

        addi a1, a1, 12
        addi a0, a0, 128

    /* reset output pointer */
    addi a0, a0, -1024

    /* Setup WDRs */
    li t1, 1
    li t2, 2

    /* Load precomputed, vectorized eta */
    la t0, eta
    bn.lid t1, 0(t0)

    LOOPI 32, 3
        bn.lid     t2, 0(a0)   /* w2 <= coeffs[i:i+8] */
        bn.subv.8S w2, w1, w2  /* w2 <= eta - w2 */
        bn.sid     t2, 0(a0++) /* coeffs[i:i+8] <= w2 */

    ret

/**
 * polyvec_decode_h_dilithium
 *
 * Decode h from signature into polyvec h. Check extra indices. 
 *
 * Flags: TODO
 *
 * @param[in]  a1: pointer to input byte array signature
 * @param[out] a0: pointer to output polynomial h
 *
 * clobbered registers: a0-a7, t0-t6
 */
.global polyvec_decode_h_dilithium
polyvec_decode_h_dilithium:
    /* Initialize h to zero */
    add t1, zero, a0
    li t0, 31
    LOOPI 32, 1
        bn.sid t0, 0(t1++)
    
    li t0, 0 /* "k" = 0 */
    li t1, 0 /* "i" = 0 */
    /* Initialize constants */ 
    li t4, OMEGA
    li a2, 0xFFFFFFFC
    li a7, 1

    /* The notation inside the comments goes in line with the reference code */
_loop_decode_h_dilithium:
    /* Load sig[OMEGA + i] to t2 */
    addi t2, t1, OMEGA /* i + OMEGA */
    add  t6, t2, a1    /* (sig + OMEGA + i) */
    and  a4, t6, 0x3   /* get lower two bits */
    and  t6, t6, a2    /* set lowest two bits to 0 */
    lw   t6, 0(t6)     /* aligned load */
    slli a4, a4, 3
    srl  t6, t6, a4    /* extract the respective byte */
    andi t2, t6, 0xFF

    /* sig[OMEGA + i] <? k  */
    slt t3, t2, t0
    bne t3, zero, _ret1_decode_h_dilithium
    /* || sig[OMEGA + i] >? OMEGA */
    slt t3, t4, t2
    bne t3, zero, _ret1_decode_h_dilithium

    addi t5, t0, 0 /* j = k */
    
    /* Do first iteration separately */
    /* Load sig[j] */
    add  t6, t5, a1   /* (sig + j) */
    andi a4, t6, 0x3  /* get lower two bits */
    and  t6, t6, a2   /* set lowest two bits to 0 */
    lw   t6, 0(t6)    /* aligned load */
    slli a4, a4, 3
    srl  t6, t6, a4   /* extract the respective byte */
    andi a6, t6, 0xFF /* a6 = sig[j] */

    /* Store a 1 to h */ 
    slli a4, a6, 2  /* sig[j] * 4 */
    add  t6, a0, a4 /* (h[sig[j]]) */
    sw   a7, 0(t6)  /* h->vec[i].coeffs[sig[j]] = a7 = 1 */

    /* Skip the loop if we are already done here */
    addi t5, t5, 1
    beq t5, t2, _loop_inner_skip_decode_h_dilithium
_loop_inner_decode_h_dilithium:
        /* TODO: Do this more efficiently, probably dont need to compute this every iteration */
        /* Load sig[j] */
        add  a5, t5, a1  /* (sig + j) */
        andi a4, a5, 0x3 /* get lower two bits */
        and  t6, a5, a2  /* set lowest two bits to 0 */
        lw   a3, 0(t6)   /* aligned load */
        slli a4, a4, 3
        srl  a3, a3, a4  /* extract the respective byte */
        andi a3, a3, 0xFF

        /* sig[j - 1] is in a6 at this point */

        /* sig[j] ==? sig[j-1] */
        beq  a3, a6, _ret1_decode_h_dilithium
        sltu t6, a3, a6

        /* sig[j] <? sig[j-1] */
        li  a4, 1
        beq t6, a4, _ret1_decode_h_dilithium


        slli a4, a3, 2  /* sig[j] * 4 */
        add  t6, a0, a4 /* (h[sig[j]]) */
        sw   a7, 0(t6)  /* h->vec[i].coeffs[sig[j]] = 1 */

        
        addi a6, a3, 0 /* set sig[j - 1] from sig[j] */
        addi t5, t5, 1 /* j++ */

        /* j != sig[OMEGA + i] */
        bne t5, t2, _loop_inner_decode_h_dilithium
_loop_inner_skip_decode_h_dilithium:

    addi t0, t2, 0    /* k = sig[OMEGA + i]; */
    addi t1, t1, 1    /* i++ */
    addi a0, a0, 1024 /* Go to next poly in h */
    li   t5, 4

    /* i <? 4 (K = 4): Check if all polynomials are done */
    bne t1, t5, _loop_decode_h_dilithium

    /* Extra indices zero  */
    addi t5, t0, 0 /* j = k */
_loop_extra_decode_h_dilithium:
    /* Load sig[j] */
    add  t6, t5, a1   /* (sig + j) */
    and  a4, t6, 0x3  /* get lower two bits */
    and  t6, t6, a2   /* set lowest two bits to 0 */
    lw   t6, 0(t6)    /* aligned load */
    slli a4, a4, 3
    srl  t6, t6, a4   /* extract the respective byte */
    andi a6, t6, 0xFF /* a6 = sig[j] */

    /* if(sig[j]) return 1; */
    bne a6, zero, _ret1_decode_h_dilithium

    addi t5, t5, 1 /* j++ */
    bne  t5, t4, _loop_extra_decode_h_dilithium

_ret0_decode_h_dilithium:
    li a0, 0
    ret

_ret1_decode_h_dilithium:
    li a0, 1
    ret

/**
 * polyt0_unpack_dilithium
 *
 * Bit-unpack polynomial t0 with coefficients in ]-2^{D-1}, 2^{D-1}].
 *
 * Flags: TODO
 *
 * @param[out] a0: pointer to output byte array with at least
                   POLYETA_PACKEDBYTES bytes
 * @param[in]  a1: pointer to input polynomial
 *
 * clobbered registers: a0-a1, t0-t4, w1-w2
 */
.global polyt0_unpack_dilithium
polyt0_unpack_dilithium:
       
    li t3, 8191
    li t4, 4095
    LOOPI 8, 134
        lw t0, 0(a1)
        and t1, t0, t3
        sw t1, 0(a0) /* coeff 0 */
        srli t0, t0, 13
        and t1, t0, t3
        sw t1, 4(a0) /* coeff 1 */
        srli t0, t0, 13
        /* Bits remaining in register: 6 */
        lw t2, 4(a1)
        andi t1, t2, 127
        slli t1, t1, 6
        or t1, t1, t0
        sw t1, 8(a0)
        srli t0, t2, 7
        /* Bytes processed: 8 */

        and t1, t0, t3
        sw t1, 12(a0) /* coeff 3 */
        srli t0, t0, 13
        /* Bits remaining in register: 12 */
        lw t2, 8(a1)
        andi t1, t2, 1
        slli t1, t1, 12
        or t1, t1, t0
        sw t1, 16(a0)
        srli t0, t2, 1
        /* Bytes processed: 12 */

        and t1, t0, t3
        sw t1, 20(a0) /* coeff 5 */
        srli t0, t0, 13
        and t1, t0, t3
        sw t1, 24(a0) /* coeff 6 */
        srli t0, t0, 13
        /* Bits remaining in register: 5 */
        lw t2, 12(a1)
        andi t1, t2, 255
        slli t1, t1, 5
        or t1, t1, t0
        sw t1, 28(a0)
        srli t0, t2, 8
        /* Bytes processed: 16 */

        and t1, t0, t3
        sw t1, 32(a0) /* coeff 8 */
        srli t0, t0, 13
        /* Bits remaining in register: 11 */
        lw t2, 16(a1)
        andi t1, t2, 3
        slli t1, t1, 11
        or t1, t1, t0
        sw t1, 36(a0)
        srli t0, t2, 2
        /* Bytes processed: 20 */

        and t1, t0, t3
        sw t1, 40(a0) /* coeff 10 */
        srli t0, t0, 13
        and t1, t0, t3
        sw t1, 44(a0) /* coeff 11 */
        srli t0, t0, 13
        /* Bits remaining in register: 4 */
        lw t2, 20(a1)
        andi t1, t2, 511
        slli t1, t1, 4
        or t1, t1, t0
        sw t1, 48(a0)
        srli t0, t2, 9
        /* Bytes processed: 24 */

        and t1, t0, t3
        sw t1, 52(a0) /* coeff 13 */
        srli t0, t0, 13
        /* Bits remaining in register: 10 */
        lw t2, 24(a1)
        andi t1, t2, 7
        slli t1, t1, 10
        or t1, t1, t0
        sw t1, 56(a0)
        srli t0, t2, 3
        /* Bytes processed: 28 */

        and t1, t0, t3
        sw t1, 60(a0) /* coeff 15 */
        srli t0, t0, 13
        and t1, t0, t3
        sw t1, 64(a0) /* coeff 16 */
        srli t0, t0, 13
        /* Bits remaining in register: 3 */
        lw t2, 28(a1)
        andi t1, t2, 1023
        slli t1, t1, 3
        or t1, t1, t0
        sw t1, 68(a0)
        srli t0, t2, 10
        /* Bytes processed: 32 */

        and t1, t0, t3
        sw t1, 72(a0) /* coeff 18 */
        srli t0, t0, 13
        /* Bits remaining in register: 9 */
        lw t2, 32(a1)
        andi t1, t2, 15
        slli t1, t1, 9
        or t1, t1, t0
        sw t1, 76(a0)
        srli t0, t2, 4
        /* Bytes processed: 36 */

        and t1, t0, t3
        sw t1, 80(a0) /* coeff 20 */
        srli t0, t0, 13
        and t1, t0, t3
        sw t1, 84(a0) /* coeff 21 */
        srli t0, t0, 13
        /* Bits remaining in register: 2 */
        lw t2, 36(a1)
        andi t1, t2, 2047
        slli t1, t1, 2
        or t1, t1, t0
        sw t1, 88(a0)
        srli t0, t2, 11
        /* Bytes processed: 40 */

        and t1, t0, t3
        sw t1, 92(a0) /* coeff 23 */
        srli t0, t0, 13
        /* Bits remaining in register: 8 */
        lw t2, 40(a1)
        andi t1, t2, 31
        slli t1, t1, 8
        or t1, t1, t0
        sw t1, 96(a0)
        srli t0, t2, 5
        /* Bytes processed: 44 */

        and t1, t0, t3
        sw t1, 100(a0) /* coeff 25 */
        srli t0, t0, 13
        and t1, t0, t3
        sw t1, 104(a0) /* coeff 26 */
        srli t0, t0, 13
        /* Bits remaining in register: 1 */
        lw t2, 44(a1)
        and t1, t2, t4
        slli t1, t1, 1
        or t1, t1, t0
        sw t1, 108(a0)
        srli t0, t2, 12
        /* Bytes processed: 48 */

        and t1, t0, t3
        sw t1, 112(a0) /* coeff 28 */
        srli t0, t0, 13
        /* Bits remaining in register: 7 */
        lw t2, 48(a1)
        andi t1, t2, 63
        slli t1, t1, 7
        or t1, t1, t0
        sw t1, 116(a0)
        srli t0, t2, 6
        /* Bytes processed: 52 */

        and t1, t0, t3
        sw t1, 120(a0) /* coeff 30 */
        srli t0, t0, 13
        /* Bits remaining in register: 13 */
        and t1, t0, t3
        sw t1, 124(a0) /* coeff 31 */
        /* Bytes processed: 52 */

        addi a0, a0, 128
        addi a1, a1, 52
    
    /* reset output pointer */ 
    addi a0, a0, -1024

    /* Compute (1 << (D-1)) - coeff */
    /* Setup WDRs */
    addi t1, zero, 1
    addi t2, zero, 2

    /* Load precomputed, vectorized (1 << (D-1)) */
    la t0, polyt0_pack_const
    bn.lid t1, 0(t0)
    /* This loop overwrites the original t0 */
    LOOPI 32, 3
        /* w2 <= coeffs[i:i+8] */
        bn.lid t2, 0(a0)
        /* w2 <= (1 << (D-1)) - coeffs */
        bn.subv.8S w2, w1, w2
        /* coeffs[i:i+8] <= w2 */
        bn.sid t2, 0(a0++)
    ret

/**
 * poly_uniform_gamma1_dilithium
 *
 *  Sample polynomial with uniformly random coefficients in [-(GAMMA1 - 1),
 *  GAMMA1] by unpacking output stream of SHAKE256(seed|nonce).
 *
 * Flags: TODO
 *
 * @param[out] a0: pointer to output polynomial
 * @param[in]  a1: byte array with seed of length CRHBYTES
 * @param[in]  a2: nonce
 * @param[in]  a3: pointer to gamma1_vec_const
 *
 * clobbered registers: a0, a4, t0-t6, w1-w2, w8
 */
.global poly_uniform_gamma1_dilithium
poly_uniform_gamma1_dilithium:
    /* save fp to stack */
    addi sp, sp, -32
    sw fp, 0(sp)

    addi fp, sp, 0
    
    /* Adjust sp to accomodate local variables */
    addi sp, sp, -320

    /* Reserve space for tmp buffer to hold a WDR */
    #define STACK_WDR2GPR -32
    #define STACK_BUF -320

    push a0
    push a1
    
    /* Initialize a SHAKE256 operation. */
    addi  t0, zero, SHAKE256_START_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Send the seed to the Keccak core. */
    addi a0, a1, 0    /* a0 <= seed address */
    li   a1, CRHBYTES /* a1 <= CRHBYTES */
    jal  x1, keccak_send_message

    /* Send the nonce to the Keccak core. */
    sw   a2, STACK_WDR2GPR(fp)
    addi a0, fp, STACK_WDR2GPR /* a0 <= *STACK_WDR2GPR = *nonce*/
    li   a1, 2 /* a1 <= 2 */
    jal  x1, keccak_send_message

    pop a1
    pop a0

    /* Constants for masking */
    /* {262143: 't3', 4095: 't4', 65535: 't5', 16383: 't6'} */
    li t3, 262143
    li t4, 4095
    li t5, 65535
    li t6, 16383

    LOOPI 2, 82
        /* fill buf */
        addi t0, fp, STACK_BUF
        li t1, 8
        LOOPI 9, 2
            /* Write SHAKE output to dmem */
            bn.wsrr  w8, 0x9 /* KECCAK_DIGEST */
            bn.sid t1, 0(t0++)

        /* Load pointer to shake output */
        addi a4, fp, STACK_BUF

        LOOPI 8, 74
            lw t0, 0(a4)
            and t1, t0, t3
            sw t1, 0(a0) /* coeff 0 */
            srli t0, t0, 18
            /* Bits remaining in register: 14 */
            lw t2, 4(a4)
            andi t1, t2, 15
            slli t1, t1, 14
            or t1, t1, t0
            sw t1, 4(a0)
            srli t0, t2, 4
            /* Bytes processed: 8 */

            and t1, t0, t3
            sw t1, 8(a0) /* coeff 2 */
            srli t0, t0, 18
            /* Bits remaining in register: 10 */
            lw t2, 8(a4)
            andi t1, t2, 255
            slli t1, t1, 10
            or t1, t1, t0
            sw t1, 12(a0)
            srli t0, t2, 8
            /* Bytes processed: 12 */

            and t1, t0, t3
            sw t1, 16(a0) /* coeff 4 */
            srli t0, t0, 18
            /* Bits remaining in register: 6 */
            lw t2, 12(a4)
            and t1, t2, t4
            slli t1, t1, 6
            or t1, t1, t0
            sw t1, 20(a0)
            srli t0, t2, 12
            /* Bytes processed: 16 */

            and t1, t0, t3
            sw t1, 24(a0) /* coeff 6 */
            srli t0, t0, 18
            /* Bits remaining in register: 2 */
            lw t2, 16(a4)
            and t1, t2, t5
            slli t1, t1, 2
            or t1, t1, t0
            sw t1, 28(a0)
            srli t0, t2, 16
            /* Bytes processed: 20 */

            /* Bits remaining in register: 16 */
            lw t2, 20(a4)
            andi t1, t2, 3
            slli t1, t1, 16
            or t1, t1, t0
            sw t1, 32(a0)
            srli t0, t2, 2
            /* Bytes processed: 24 */

            and t1, t0, t3
            sw t1, 36(a0) /* coeff 9 */
            srli t0, t0, 18
            /* Bits remaining in register: 12 */
            lw t2, 24(a4)
            andi t1, t2, 63
            slli t1, t1, 12
            or t1, t1, t0
            sw t1, 40(a0)
            srli t0, t2, 6
            /* Bytes processed: 28 */

            and t1, t0, t3
            sw t1, 44(a0) /* coeff 11 */
            srli t0, t0, 18
            /* Bits remaining in register: 8 */
            lw t2, 28(a4)
            andi t1, t2, 1023
            slli t1, t1, 8
            or t1, t1, t0
            sw t1, 48(a0)
            srli t0, t2, 10
            /* Bytes processed: 32 */

            and t1, t0, t3
            sw t1, 52(a0) /* coeff 13 */
            srli t0, t0, 18
            /* Bits remaining in register: 4 */
            lw t2, 32(a4)
            and t1, t2, t6
            slli t1, t1, 4
            or t1, t1, t0
            sw t1, 56(a0)
            srli t0, t2, 14
            /* Bytes processed: 36 */

            /* Bits remaining in register: 18 */
            and t1, t0, t3
            sw t1, 60(a0) /* coeff 15 */
            /* Bytes processed: 36 */

            addi a0, a0, 64
            addi a4, a4, 36
        nop /* Nested loops must not end on the same instruction */
   
    /* Finish the SHAKE-256 operation. */
    addi  t0, zero, KECCAK_DONE_CMD
    csrrw zero, KECCAK_CMD_REG, t0

    /* Reset output pointer */
    addi a0, a0, -1024

    /* Setup WDRs */
    li t1, 1
    li t2, 2

    /* Load precomputed, vectorized eta */
    bn.lid t1, 0(a3)

    LOOPI 32, 3
        bn.lid     t2, 0(a0)   /* w2 <= coeffs[i:i+8] */
        bn.subv.8S w2, w1, w2  /* w2 <= eta - w2 */
        bn.sid     t2, 0(a0++) /* coeffs[i:i+8] <= w2 */

    /* sp <- fp */
    addi sp, fp, 0
    /* Pop ebp */
    lw fp, 0(sp)
    addi sp, sp, 32

    ret

/**
 * poly_decompose_dilithium
 *
 *  For all coefficients c of the input polynomial, compute high and low bits
 *  c0, c1 such c mod Q = c1*ALPHA + c0 with -ALPHA/2 < c0 <= ALPHA/2 except c1
 *  = (Q-1)/ALPHA where we set c1 = 0 and -ALPHA/2 <= c0 = c mod Q - Q < 0.
 *  Assumes coefficients to be standard representatives.
 *
 * Flags: TODO
 *
 * @param[out] a0: a0 pointer to output polynomial with coefficients c0
 * @param[out] a1: a1: pointer to output polynomial with coefficients c1
 * @param[in]  a2: *a: pointer to input polynomial
 *
 * clobbered registers: w0-w11, a0-a2, t0-t4
 */
.global poly_decompose_dilithium
poly_decompose_dilithium:
    /* WDR constants for decompose */
    la t0, decompose_127_const
    li t1, 5
    /* w5 <= decompose_127_const */
    bn.lid t1, 0(t0)

    la t0, decompose_const
    li t1, 6
    /* w6 <= decompose_const */
    bn.lid t1, 0(t0)

    la t0, reduce32_const
    li t1, 7
    /* w7 <= reduce32_const */
    bn.lid t1, 0(t0)

    la t0, decompose_43_const
    li t1, 8
    /* w8 <= decompose_43_const */
    bn.lid t1, 0(t0)

    la t0, gamma2_vec_const
    li t1, 9
    /* w9 <= gamma2_vec_const */
    bn.lid t1, 0(t0)

    la t0, qm1half_const
    li t1, 10
    /* w10 <= qm1half_const */
    bn.lid t1, 0(t0)

    la t0, modulus
    li t1, 11
    /* w11 <= modulus */
    bn.lid t1, 0(t0)

    /* Setup constants for WDRs */
    li t0, 0
    li t1, 1
    li t2, 2

    LOOPI 32, 4
        bn.lid t0, 0(a2++)
        jal x1, decompose_dilithium
        bn.sid t1, 0(a0++)
        bn.sid t2, 0(a1++)

    ret

/**
 * poly_make_hint_dilithium
 *
 *  Compute hint polynomial. The coefficients of which indicate whether the low
 *  bits of the corresponding coefficient of the input polynomial overflow into
 *  the high bits.
 * 
 * Returns: Number of one bits
 *
 * @param[out] a0: pointer to output hint polynomial
 * @param[in]  a1: a0 pointer to low part of input polynomial
 * @param[in]  a2: a1: pointer to high part of input polynomial
 *
 * clobbered registers: t0-t2, t4-t6, a0-a2, a4-a7
 */
.global poly_make_hint_dilithium
poly_make_hint_dilithium:
    /* TODO improve comments */
    li   t2, 0
    li   t4, 1

    li   t6, 94208
    addi t6, t6, 1024
    li   a6, 192512
    addi a6, a6, -2048
    li   a7, -94208
    addi a7, a7, -1024

    /* Loop over every coefficient of input */
    LOOPI 256, 18
        lw t0, 0(a1)
        lw t1, 0(a2)

        add  a4, t0, t6
        addi a5, t0, 0
        sltu t5, a6, a4
        beq  t4, t5, _L3_poly_make_hint_dilithium
        li   t0, 0
        beq  a5, a7, _L6_poly_make_hint_dilithium
        beq  zero, zero, _loop_end_poly_make_hint_dilithium

_L6_poly_make_hint_dilithium:
        sltu t0, zero, t1
        beq  zero, zero, _loop_end_poly_make_hint_dilithium

_L3_poly_make_hint_dilithium:
        li  t0, 1
        beq zero, zero, _loop_end_poly_make_hint_dilithium

_loop_end_poly_make_hint_dilithium:
        sw   t0, 0(a0) /* Write to output polynomial */
        add  t2, t2, t0
        addi a1, a1, 4
        addi a2, a2, 4
        addi a0, a0, 4

    addi a0, t2, 0 /* move result to return value */
    ret

/**
 * polyz_pack_dilithium
 *
 * Pack polynomial z with coefficients fitting in 18 bits. 
 *
 * Flags: TODO
 *
 * @param[in]  a2: address of gamma1_vec_const
 * @param[in]  a1: pointer to input polynomial
 * @param[out] a0: pointer to output byte array with at least
 *                 POLYZ_PACKEDBYTES bytes
 *
 * clobbered registers: a0-a1, t0-t2, w0-w1
 */
.global polyz_pack_dilithium
polyz_pack_dilithium:
    /* TODO: are constant addresses as parameters desired? */

    /* Setup WDRs */
    li t0, 0
    li t1, 1

    /* Load vectorized GAMMA1 */
    bn.lid t1, 0(a2)

    LOOPI 32, 3
        bn.lid     t0, 0(a1)
        bn.subv.8S w0, w1, w0
        bn.sid     t0, 0(a1++)
    
    /* Reset input pointer */
    addi a1, a1, -1024

    LOOPI 16, 75
        xor   t2, t2, t2
        /* oooooooooooooooooooooooooooooooo */
        /* coefficient 0 */
        lw   t0, 0(a1)
        or   t2, t2, t0
        /* ******************oooooooooooooo| */
        /* coefficient 1 */
        lw   t0, 4(a1)
        slli t1, t0, 18
        or   t2, t2, t1
        /* ********************************|xxxx */
        sw   t2, 0(a0)
        srli t0, t0, 14
        or   t2, zero, t0
        /* ****oooooooooooooooooooooooooooo */
        /* coefficient 2 */
        lw   t0, 8(a1)
        slli t1, t0, 4
        or   t2, t2, t1
        /* **********************oooooooooo| */
        /* coefficient 3 */
        lw   t0, 12(a1)
        slli t1, t0, 22
        or   t2, t2, t1
        /* ********************************|xxxxxxxx */
        sw   t2, 4(a0)
        srli t0, t0, 10
        or   t2, zero, t0
        /* ********oooooooooooooooooooooooo */
        /* coefficient 4 */
        lw   t0, 16(a1)
        slli t1, t0, 8
        or   t2, t2, t1
        /* **************************oooooo| */
        /* coefficient 5 */
        lw   t0, 20(a1)
        slli t1, t0, 26
        or   t2, t2, t1
        /* ********************************|xxxxxxxxxxxx */
        sw   t2, 8(a0)
        srli t0, t0, 6
        or   t2, zero, t0
        /* ************oooooooooooooooooooo */
        /* coefficient 6 */
        lw   t0, 24(a1)
        slli t1, t0, 12
        or   t2, t2, t1
        /* ******************************oo| */
        /* coefficient 7 */
        lw   t0, 28(a1)
        slli t1, t0, 30
        or   t2, t2, t1
        /* ********************************|xxxxxxxxxxxxxxxx */
        sw   t2, 12(a0)
        srli t0, t0, 2
        or   t2, zero, t0
        /* ****************oooooooooooooooo */
        /* coefficient 8 */
        lw   t0, 32(a1)
        slli t1, t0, 16
        or   t2, t2, t1
        /* ********************************|xx */
        sw   t2, 16(a0)
        srli t0, t0, 16
        or   t2, zero, t0
        /* **oooooooooooooooooooooooooooooo */
        /* coefficient 9 */
        lw   t0, 36(a1)
        slli t1, t0, 2
        or   t2, t2, t1
        /* ********************oooooooooooo| */
        /* coefficient 10 */
        lw   t0, 40(a1)
        slli t1, t0, 20
        or   t2, t2, t1
        /* ********************************|xxxxxx */
        sw   t2, 20(a0)
        srli t0, t0, 12
        or   t2, zero, t0
        /* ******oooooooooooooooooooooooooo */
        /* coefficient 11 */
        lw   t0, 44(a1)
        slli t1, t0, 6
        or   t2, t2, t1
        /* ************************oooooooo| */
        /* coefficient 12 */
        lw   t0, 48(a1)
        slli t1, t0, 24
        or   t2, t2, t1
        /* ********************************|xxxxxxxxxx */
        sw   t2, 24(a0)
        srli t0, t0, 8
        or   t2, zero, t0
        /* **********oooooooooooooooooooooo */
        /* coefficient 13 */
        lw   t0, 52(a1)
        slli t1, t0, 10
        or   t2, t2, t1
        /* ****************************oooo| */
        /* coefficient 14 */
        lw   t0, 56(a1)
        slli t1, t0, 28
        or   t2, t2, t1
        /* ********************************|xxxxxxxxxxxxxx */
        sw   t2, 28(a0)
        srli t0, t0, 4
        or   t2, zero, t0
        /* **************oooooooooooooooooo */
        /* coefficient 15 */
        lw   t0, 60(a1)
        slli t1, t0, 14
        or   t2, t2, t1
        /* ********************************| */
        sw   t2, 32(a0)

        addi a1, a1, 64
        addi a0, a0, 36

    ret

/**
 * polyvec_encode_h_dilithium
 *
 * Encode h to signature from polyvec h.
 *
 * Flags: TODO
 *
 * @param[in]  a1: pointer to input polynomial h
 * @param[out] a0: pointer to output byte array signature
 *
 * clobbered registers: a1-a2, t0-t6
 */
.global polyvec_encode_h_dilithium
polyvec_encode_h_dilithium:
    li t0, 0 /* k = 0 */
    li t1, 0 /* i = 0 */

    /* Masking constant for alignment */
    li a2, 0xFFFFFFFC
    LOOPI K, 25
        li t2, 0 /* j = 0 */
        LOOPI N, 13
            lw   t3, 0(a1)
            addi a1, a1, 4   /* Increment input pointer */
            beq  zero, t3, _skip_store_polyvec_encode_h_dilithium
            add  t4, a0, t0  /* *sig + k */
            andi t5, t4, 0x3 /* preserve lower 2 bits */
            and  t4, t4, a2  /* align */
            lw   t6, 0(t4)   /* load form aligned(sig+k) */
            slli t5, t5, 3   /* #bytes -> #bits */
            sll  t5, t2, t5  /* j << #bits */
            or   t6, t6, t5
            sw   t6, 0(t4)

            addi t0, t0, 1 /* k++ */
_skip_store_polyvec_encode_h_dilithium:
            addi t2, t2, 1
        addi t2, t1, OMEGA /* OMEGA + i */
        add  t2, a0, t2    /* *sig + OMEGA + i */
        andi t3, t2, 0x3   /* preserve lower 2 bits */
        and  t2, t2, a2    /* align */
        lw   t4, 0(t2)     /* load from aligned(*sig + OMEGA + i) */
        slli t3, t3, 3     /* #bytes -> #bits */
        sll  t3, t0, t3    /* k << #bits */
        or   t4, t4, t3
        sw   t4, 0(t2)

        addi t1, t1, 1

    ret