.globl mulv
mulv:
    /* Set up constants for input/output
         x23 <= 23
         x24 <= 24
         x25 <= 25 */
    li      x23, 23
    li      x24, 24
    li      x25, 25

    /* Load the least significant limbs of x and y.
         w23 <= dmem[x10] = x[255:0]
         w24 <= dmem[x11] = y[255:0] */
    bn.lid  x23, 0(x10)
    bn.lid  x24, 0(x11)
    bn.mulmv.8S w25, w23, w24, 0, nored

    /* Write result
         dmem[x10] <= w25 */
    bn.sid  x25, 0(x10)

    ret

