.globl trans8
trans8:
    /* Set up constants for input/output*/
    li      x23, 23
    li      x24, 24
    li      x25, 25
    li      x26, 26
    li      x27, 27
    li      x28, 28
    li      x29, 29
    li      x30, 30

    /* Load */
    bn.lid  x23, 0(x10)
    bn.lid  x24, 32(x10)
    bn.lid  x25, 64(x10)
    bn.lid  x26, 96(x10)
    bn.lid  x27, 128(x10)
    bn.lid  x28, 160(x10)
    bn.lid  x29, 192(x10)
    bn.lid  x30, 224(x10)

    bn.trans8 w23, w23

    ret

