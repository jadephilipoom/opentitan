.text

/**
 * Constant Time Dilithium conditional add q
 *
 * Returns: caddq(input1)
 *
 * This implements caddq for Dilithium, where n=256,q=8380417.
 *
 * Flags: Flags have no meaning beyond the scope of this subroutine.
 *
 * 
 * @param[in]  x10: dptr_input1, dmem pointer to first word of input1 polynomial
 * @param[in]  w31: all-zero
 *
 * clobbered registers: x5 to x7, x10
 *                      w2 to w6
 */
.globl poly_caddq_dilithium
poly_caddq_dilithium:
    /* Set up constants for input/state */
    li x5, 3
    li x6, 6

    /* Load q */
    la     x7, modulus
    bn.lid x6, 0(x7)

    /* Set up constants for input/state */
    li x7, 2    

    LOOPI 32, 8
        bn.lid x7, 0(x10)
        
        /* (a >> 31) */
        bn.orv.8S w3, w31, w2 >> 31
        /* (a >> 31) & Q */
        bn.and w3, w3, w6
        /* a += (a >> 31) & Q */
        bn.add w2, w2, w3

        bn.sid x7, 0(x10)

        addi x10, x10, 32

    ret