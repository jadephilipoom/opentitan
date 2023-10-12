.text
/**
 * Constant Time Dilithium polynomial addition
 *
 * Returns: add(input1, input2) reduced mod q (taken from MOD WDR)
 *
 * This implements the polynomial addition for e.g. Dilithium, where n=256.
 *
 * Flags: -
 *
 * @param[in]  x10: dptr_input1, dmem pointer to first word of input1 polynomial
 * @param[in]  x11: dptr_input2, dmem pointer to first word of input2 polynomial
 * @param[in]  w31: all-zero
 * @param[out] x12: dmem pointer to result
 *
 * clobbered registers: x4-x6, w2-w4
 */
.global poly_add_base_dilithium
poly_add_base_dilithium:
    

    /* Init mask */
    bn.addi w7, w31, 1
    bn.or w7, w31, w7 << 32
    bn.subi w7, w7, 1

    la x4, modulus
    li x5, 21 /* Load q to wtmp */
    bn.lid x5, 0(x4)
    bn.and w21, w21, w7
    bn.wsrw 0x0, w21 /* set modulus to q only once */

    /* Set up constants for input/state */
    li x6, 2
    li x5, 3
    li x4, 6

    LOOPI 32, 10
        bn.lid x6, 0(x10++)
        bn.lid x5, 0(x11++)

        LOOPI 8, 6
            /* Mask one coefficient to working registers */
            bn.and w4, w2, w7
            bn.and w5, w3, w7
            /* Shift out used coefficient */
            bn.rshi w2, w31, w2 >> 32
            bn.rshi w3, w31, w3 >> 32

            bn.addm w4, w4, w5
            bn.rshi w6, w4, w6 >> 32
        
        bn.sid x4, 0(x12++)

    /* Restore modulus */
    la x4, modulus
    li x5, 21 /* Load q to wtmp */
    bn.lid x5, 0(x4)
    bn.wsrw 0x0, w21 /* set modulus to q only once */

    ret