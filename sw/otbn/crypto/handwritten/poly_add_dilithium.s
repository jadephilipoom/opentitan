.text

/**
 * Constant Time Dilithium polynomial addition
 *
 * Returns: add(input1, input2) reduced mod q
 *
 * This implements the polynomial addition for Dilithium, where n=256,q=8380417.
 *
 * Flags: Flags have no meaning beyond the scope of this subroutine.
 *
 * 
 * @param[in]  x10: dptr_input1, dmem pointer to first word of input1 polynomial
 * @param[in]  x11: dptr_input2, dmem pointer to first word of input2 polynomial
 * @param[in]  w31: all-zero
 * @param[out] x12: dmem pointer to result
 *
 * clobbered registers: x4 to x6
 *                      w2 to w4
 */
.globl poly_add_dilithium
poly_add_dilithium:
    /* Set up constants for input/state */
    li x6, 2
    li x5, 3
    li x4, 4

    LOOPI 32, 7
        bn.lid x6, 0(x10)
        bn.lid x5, 0(x11)
        
        bn.addmv.8S w2, w2, w3
        
        bn.sid x6, 0(x12)

        addi x10, x10, 32
        addi x11, x11, 32
        addi x12, x12, 32

    ret