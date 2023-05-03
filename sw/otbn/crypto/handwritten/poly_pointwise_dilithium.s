.text

/**
 * Constant Time Dilithium base multiplication (pointwise)
 *
 * Returns: poly_pointwise(input1, input2)
 *
 * This implements the base multiplication for Dilithium, where n=256,q=8380417.
 *
 * Flags: Flags have no meaning beyond the scope of this subroutine.
 *
 * 
 * @param[in]  x30: dptr_input1, dmem pointer to first word of input1 polynomial
 * @param[in]  x31: dptr_input2, dmem pointer to first word of input2 polynomial
 * @param[in]  w31: all-zero
 * @param[out] x29: dmem pointer to result
 *
 * clobbered registers: x2 to x4
 *                      w2 to w4
 */
.globl poly_pointwise_dilithium
poly_pointwise_dilithium:
    /* Set up constants for input/state */
    li x2, 2
    li x3, 3
    li x4, 4

    LOOPI 32, 7
        bn.lid x2, 0(x30)
        bn.lid x3, 0(x31)
        
        bn.mulmv.8S w2, w2, w3
        
        bn.sid x2, 0(x29)

        addi x30, x30, 32
        addi x31, x31, 32
        addi x29, x29, 32

    ret