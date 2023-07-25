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
 * decompose_dilithium
 *
 * For finite field element a, compute high and low bits a0, a1 such that a
 * mod^+ Q = a1*ALPHA + a0 with -ALPHA/2 < a0 <= ALPHA/2 except if a1 =
 * (Q-1)/ALPHA where we set a1 = 0 and -ALPHA/2 <= a0 = a mod^+ Q - Q < 0.
 * Assumes a to be standard representative.
 * 
 * Returns: 
 *
 * Flags: TODO
 *
 * @param[in]     w0: input element vector
 * @param[out]    w1: output element vector "a0"
 * @param[out]    w2: output element vector "a1"
 *
 * clobbered registers: TODO
 */
.global decompose_dilithium
decompose_dilithium:
/* TODO: load constants only once outside */
    la t0, decompose_127_const
    li t3, 3
    bn.lid t3, 0(t0)
    /* a + 127 */
    bn.addv.8S w2, w0, w3
    /* (a + 127) >> 7 */
    bn.orv.8S w2, bn0, w2 >> 7
    la t0, decompose_const
    li t4, 4
    bn.lid t4, 0(t0)
    bn.mulv.8S w2, w2, w4
    la t0, reduce32_const
    bn.lid t4, 0(t0)
    bn.orv.8S w4, bn0, w4 << 23
    bn.addv.8S w2, w2, w4
    bn.orv.8S w2, bn0, w2 >> 24
    la t0, decompose_43_const
    bn.lid t4, 0(t0)
    bn.subv.8S w3, w4, w2
    bn.andv.8S w3, w2, w3 a >> 31 /* (((Q-1)/2 - *a0) >> 31) & Q */ 
    bn.xorv.8S w2, w2, w3
    /* a0 */
    la t0, gamma2_vec_const
    bn.lid t4, 0(t0)
    bn.mulv.8S w4, w4, w2 /* *a */
    bn.orv.8S w4, bn0, w4 << 1 /* *2 */
    bn.subv.8S w1, w0, w4 /* a - a1*2*GAMMA2 */
    la t0, qm1half_const
    bn.lid t4, 0(t0)
    bn.subv.8S w4, w4, w1 /* ((Q-1)/2 - *a0) */
    la t0, modulus
    li t3, 3
    bn.lid t3, 0(t0)
    /* TODO: double check the shift type */
    bn.andv.8S w4, w3, w4 a >> 31 /* (((Q-1)/2 - *a0) >> 31) & Q */ 
    bn.subv.8S w1, w1, w4
    ret