
/* secret value: w3 */
func:
  /* x10 = 1 */
  xor      x10, x10, x10
  addi     x10, x10, 1

  /* x11 = -1 */
  xor     x11, x11, x11
  sub     x11, x11, x10

  /* x3 <= 3 = *secret */
  li       x3, 3
  /* x4 <= 4 = *nonsecret */
  li       x4, 4

  /* x6 <= i = 0 */
  li       x6, 0

  /* x7 <= 7 */
  li       x7, 7

  /* x8 <= 0 */
  li       x8, 0

  /* loop for valueof[x5] iterations*/
  loop     x5, 11
    /* x12 <= x5 - 1*/
    sub   x12, x5, x10
    /* x12 <= x12 - i = inlen - 1 - i */
    sub    x12, x12, x6
    /* x12 <= - x12 */
    sub    x12, x8, x12
    /* x12 <= x12 >> 31 */
    srli   x12, x12, 31
    /* x12 <= - x12 */
    sub    x12, x8, x12

    /* x12 is zero on last iteration and all 1s otherwise */

    /* x13 <= mask & *secret */
    and   x13, x12, x3
    /* x12 <= mask ^ -1 = ~mask */
    xor   x12, x12, x11
    /* x14 <= mask & *nonsecret */
    and   x14, x12, x4
    /* x13 <= p */
    or    x13, x13, x14
    /* w7 <= *p */
    bn.movr  x7, x13
    /* i++ */
    addi   x6, x6, 1

  la      x15, dmem_ptr
  bn.sid  x15, 0(x7)

  ret

.section .text.start

main:
  li     x5, 32
  jal    x1, func

  ecall


.data

.balign 32
dmem_ptr:
.zero 32
