.text

/**
 * Constant Time Dilithium reduce32
 *
 * Returns: reduce32(input1)
 *
 * This implements reduce32 for Dilithium, where n=256,q=8380417.
 *
 * Flags: Flags have no meaning beyond the scope of this subroutine.
 *
 * 
 * @param[in]  x30: dptr_input1, dmem pointer to first word of input1 polynomial
 * @param[in]  w31: all-zero
 * @param[out] x29: dmem pointer to result
 *
 * clobbered registers: x2 to x6
 *                      w2 to w6
 */
.globl poly_reduce32_dilithium
poly_reduce32_dilithium:
    /* Set up constants for input/state */
    li x3, 3
    li x4, 4
    li x6, 6

    /* Setup constant 1 << 22 */
    la        x3, const1
    bn.lid    x4, 0(x3)
    bn.xor    w3, w3, w3
    bn.orv.8S w4, w3, w4 << 22 
    
    /* Load q */
    la     x2, Q
    bn.lid x6, 0(x2)

    /* Set up constants for input/state */
    li x2, 2

    LOOPI 32, 8
        bn.lid x2, 0(x30)
        
        /* t = a + (1 << 22) */
        bn.addmv.8S w5, w2, w4, nored
        /* t = (a + (1 << 22)) >> 23 */
        bn.orv.8S   w5, w3, w5 a >> 23
        /* t = t * q */
        bn.mulmv.l.8S  w5, w5, w6, 0, nored
        /* a - t */
        bn.submv.8S w2, w2, w5, nored

        bn.sid x2, 0(x29)

        addi x30, x30, 32
        addi x29, x29, 32

    ret

.data 
.balign 32
const1:
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
    .word 0x1
Q:
    .word 0x7fe001
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0