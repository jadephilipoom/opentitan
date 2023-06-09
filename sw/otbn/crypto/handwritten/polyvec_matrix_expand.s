/*************************************************
* Name:        expand_mat
*
* Description: Implementation of ExpandA. Generates matrix A with uniformly
*              random coefficients a_{i,j} by performing rejection
*              sampling on the output stream of SHAKE128(rho|j|i)
*              or AES256CTR(rho,j|i).
*
* Arguments:   - polyvecl mat[K]: output matrix
*              - const uint8_t rho[]: byte array containing seed rho
**************************************************/

.text

/**
 * expand_mat
 *
 * Returns: -
 *
 * Flags: TODO
 *
 * @param[in]     x11: rho
 * @param[in/out] x10: dmem pointer to matrix
 *
 * clobbered registers: TODO
 *                      TODO
 */

.global polyvec_matrix_expand
polyvec_matrix_expand:
    LOOP 4, 3
        LOOP 4, 1
            poly_uniform
        NOP