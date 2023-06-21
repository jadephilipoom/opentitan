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
 * @param[in]  x10: dptr_input1, dmem pointer to first word of input1 polynomial
 * @param[in]  w31: all-zero
 * @param[out] x11: dmem pointer to result
 *
 * clobbered registers: x4 to x7, x10-x11
 *                      w2 to w6
 */
.globl poly_reduce32_dilithium
poly_reduce32_dilithium:
    /* Set up constants for input/state */
    li x5, 3
    li x4, 4
    li x6, 6

    /* Setup constant 1 << 22 */
    la        x5, reduce32_const
    bn.lid    x4, 0(x5)
    bn.xor    w3, w3, w3
    bn.orv.8S w4, w3, w4 << 22 
    
    /* Load q */
    la     x7, modulus
    bn.lid x6, 0(x7)

    /* Set up constants for input/state */
    li x7, 2    

    LOOPI 32, 8
        bn.lid x7, 0(x10)
        
        /* t = a + (1 << 22) */
        bn.addmv.8S w5, w2, w4 nored
        /* t = (a + (1 << 22)) >> 23 */
        bn.orv.8S   w5, w3, w5 a >> 23
        /* t = t * q */
        bn.mulmv.l.8S  w5, w5, w6, 0, nored
        /* a - t */
        bn.submv.8S w2, w2, w5 nored

        bn.sid x7, 0(x11)

        addi x10, x10, 32
        addi x11, x11, 32

    ret