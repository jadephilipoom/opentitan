.text

/**
 * Constant Time Dilithium polynomial power2round
 *
 * Returns: power2round(output2, output1, input) reduced mod q
 *
 * This implements the polynomial addition for Dilithium, where n=256,q=8380417.
 *
 * Flags: -
 *
 * @param[in]  x10:  a, dmem pointer to first word of input polynomial
 * @param[in]  x11: a0, dmem pointer to output polynomial with coefficients c0
 * @param[in]  x12: a1, dmem pointer to output polynomial with coefficients c1
 * @param[in]  w31: all-zero
 *
 * clobbered registers: x4-x7, w2-w4
 */
.global poly_power2round_dilithium
poly_power2round_dilithium:
    #define D 13
    /* Set up constants for input/state */
    li x4, 4
    li x6, 6
    li x7, 7

    /* Load (1 << (D-1)) - 1 as vector */
    la x5, power2round_D_preprocessed
    bn.lid x4, 0(x5)

    li x5, 5

    LOOPI 32, 7
        /* Load input */
        bn.lid x5, 0(x10++)
        
        /* Compute */
        /* (a + (1 << (D-1)) - 1) */
        bn.addv.8S w6, w4, w5
        /* a1 = (a + (1 << (D-1)) - 1) >> D */
        bn.orv.8S w6, w31, w6 >> D
        /* a0 = (a1 << D) */
        bn.orv.8S w7, w31, w6 << D
        /* a0 = (a1 << D) */
        bn.subv.8S w7, w5, w7

        /* Store */
        bn.sid x6, 0(x12++)
        bn.sid x7, 0(x11++)

    ret