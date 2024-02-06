/* Based on: https://github.com/mjosaarinen/tiny_sha3 */
/* Compiled using: RISC-V (32-bit) gcc 13.2.0, flags: -Ofast -g -march=rv32id  -fno-builtin */
/* Manual fixes to accomodate OTBN are applied */
    /* mov -> addi with 0 */
    /* j x -> beq zero, zero, x */
    /* neg x, y -> sub x, zero, y */
    /* call x -> jal x1, x */
    /* jr ra -> ret */
    /* bgt x, y, z-> sub t0, y, x; srli t0, t0, 31; bne t0, zero, z */

.text
/* Register aliases */
.equ x0, zero
.equ x2, sp
.equ x3, fp

.equ x5, t0
.equ x6, t1
.equ x7, t2

.equ x8, s0
.equ x9, s1

.equ x10, a0
.equ x11, a1

.equ x12, a2
.equ x13, a3
.equ x14, a4
.equ x15, a5
.equ x16, a6
.equ x17, a7

.equ x18, s2
.equ x19, s3
.equ x20, s4
.equ x21, s5
.equ x22, s6
.equ x23, s7
.equ x24, s8
.equ x25, s9
.equ x26, s10
.equ x27, s11

.equ x28, t3
.equ x29, t4
.equ x30, t5
.equ x31, t6

.global sha3_update
.global shake_xof
.global shake_out

.macro lbu_rep dst, offset, addr, tmp
    addi \tmp, \addr, \offset
    /* set lowest two bits to 0 */
    srli \dst, \tmp, 2
    slli \dst, \dst, 2
    /* aligned load */
    lw \dst, 0(\dst)
    andi \tmp, \tmp, 0x3
    slli \tmp, \tmp, 3
    srl \dst, \dst, \tmp
    andi \dst, \dst, 0xFF
.endm

.macro lbu_rep dst, offset, addr, tmp
    addi \tmp, \addr, \offset
    /* set lowest two bits to 0 */
    srli \dst, \tmp, 2
    slli \dst, \dst, 2
    /* aligned load */
    lw \dst, 0(\dst)
    andi \tmp, \tmp, 0x3
    slli \tmp, \tmp, 3
    srl \dst, \dst, \tmp
    andi \dst, \dst, 0xFF
.endm

sha3_keccakf:
        addi    sp,sp,-592
        lui     a5,%hi(.LANCHOR0)
        addi    a4,a5,%lo(.LANCHOR0)
        sw      s11,544(sp)
        addi    s11,sp,352
        sw      s7,560(sp)
        sw      s0,588(sp)
        sw      s1,584(sp)
        sw      s2,580(sp)
        sw      s3,576(sp)
        sw      s4,572(sp)
        sw      s5,568(sp)
        sw      s6,564(sp)
        sw      s8,556(sp)
        sw      s9,552(sp)
        sw      s10,548(sp)
        addi    s7,a0,0
        addi    a5,a5,%lo(.LANCHOR0)
        addi    a2,a4,192
        addi    a3,s11,0
.L2:
        lw      a7,0(a5)
        lw      a6,4(a5)
        lw      a0,8(a5)
        lw      a1,12(a5)
        sw      a7,0(a3)
        sw      a6,4(a3)
        sw      a0,8(a3)
        sw      a1,12(a3)
        addi    a5,a5,16
        addi    a3,a3,16
        bne     a5,a2,.L2
        addi    a3,sp,160
        addi    a2,a4,288
.L3:
        lw      a7,0(a5)
        lw      a6,4(a5)
        lw      a0,8(a5)
        lw      a1,12(a5)
        sw      a7,0(a3)
        sw      a6,4(a3)
        sw      a0,8(a3)
        sw      a1,12(a3)
        addi    a5,a5,16
        addi    a3,a3,16
        bne     a5,a2,.L3
        addi    a5,a4,288
        addi    a3,sp,256
        addi    a4,a4,384
.L4:
        lw      a6,0(a5)
        lw      a0,4(a5)
        lw      a1,8(a5)
        lw      a2,12(a5)
        sw      a6,0(a3)
        sw      a0,4(a3)
        sw      a1,8(a3)
        sw      a2,12(a3)
        addi    a5,a5,16
        addi    a3,a3,16
        bne     a5,a4,.L4
        lw      a4,84(s7)
        sw      a4,92(sp)
        lw      a4,8(s7)
        sw      a4,20(sp)
        lw      a4,12(s7)
        sw      a4,24(sp)
        lw      a4,48(s7)
        sw      a4,60(sp)
        lw      a4,52(s7)
        sw      a4,64(sp)
        lw      a4,88(s7)
        sw      a4,96(sp)
        lw      a4,92(s7)
        lw      a5,40(s7)
        sw      a4,100(sp)
        lw      a4,128(s7)
        sw      a5,52(sp)
        sw      a4,4(sp)
        lw      a5,44(s7)
        lw      a4,168(s7)
        sw      a5,56(sp)
        sw      a4,8(sp)
        lw      a4,16(s7)
        lw      t1,4(s7)
        lw      a5,80(s7)
        lw      s2,132(s7)
        lw      t6,172(s7)
        lw      a0,0(s7)
        lw      s9,120(s7)
        lw      s8,124(s7)
        lw      s0,160(s7)
        lw      a1,164(s7)
        sw      a4,28(sp)
        lw      a3,100(s7)
        sw      a3,104(sp)
        lw      a3,140(s7)
        sw      a3,124(sp)
        lw      a3,24(s7)
        sw      a3,36(sp)
        lw      a3,28(s7)
        sw      a3,40(sp)
        lw      a3,64(s7)
        sw      a3,76(sp)
        lw      a3,68(s7)
        lw      a4,20(s7)
        sw      a3,80(sp)
        lw      a3,104(s7)
        sw      a4,32(sp)
        sw      a3,108(sp)
        lw      a4,56(s7)
        lw      a3,108(s7)
        sw      a4,68(sp)
        sw      a3,112(sp)
        lw      a4,60(s7)
        lw      a3,184(s7)
        sw      a4,72(sp)
        sw      a3,132(sp)
        sw      s11,156(sp)
        lw      a3,188(s7)
        lw      s5,136(s7)
        lw      t5,176(s7)
        lw      s4,144(s7)
        lw      a4,96(s7)
        lw      s1,148(s7)
        lw      t3,180(s7)
        sw      a3,136(sp)
        lw      a3,32(s7)
        sw      a3,44(sp)
        lw      a3,36(s7)
        sw      a3,48(sp)
        lw      a3,72(s7)
        sw      a3,84(sp)
        lw      a3,76(s7)
        sw      a3,88(sp)
        lw      a3,112(s7)
        sw      a3,116(sp)
        lw      a3,116(s7)
        sw      a3,120(sp)
        lw      a3,152(s7)
        lw      s6,196(s7)
        sw      a3,128(sp)
        lw      s3,156(s7)
        lw      a3,192(s7)
        addi    a7,s5,0
        addi    s5,s4,0
        addi    s4,a5,0
        addi    a5,t5,0
        sw      s6,152(sp)
        addi    t5,t1,0
        sw      a3,140(sp)
        li      s10,31
        sw      s2,144(sp)
        sw      s1,12(sp)
        sw      s3,148(sp)
        sw      t6,16(sp)
        addi    s6,a4,0
        addi    t1,a5,0
.L5:
        lw      a5,20(sp)
        lw      a3,60(sp)
        xor     t2,a5,a3
        lw      a2,24(sp)
        lw      t4,44(sp)
        lw      t0,84(sp)
        lw      s1,36(sp)
        lw      s3,96(sp)
        lw      a6,64(sp)
        lw      s2,76(sp)
        xor     a5,t4,t0
        lw      a4,100(sp)
        lw      a3,116(sp)
        lw      t0,40(sp)
        xor     a6,a2,a6
        xor     s2,s1,s2
        lw      a2,108(sp)
        xor     t2,t2,s3
        lw      s3,80(sp)
        xor     t4,t0,s3
        xor     a6,a6,a4
        xor     a5,a5,a3
        lw      a4,112(sp)
        lw      a3,4(sp)
        xor     s2,s2,a2
        lw      a2,144(sp)
        xor     t4,t4,a4
        xor     t2,t2,a3
        lw      a4,12(sp)
        lw      a3,28(sp)
        xor     a6,a6,a2
        lw      a2,68(sp)
        lw      s1,128(sp)
        xor     t4,t4,a4
        xor     a4,a3,a2
        lw      a3,16(sp)
        xor     a6,a6,a3
        lw      t0,8(sp)
        lw      a3,132(sp)
        xor     a5,a5,s1
        xor     s2,s2,s5
        lw      s1,140(sp)
        xor     t2,t2,t0
        xor     s2,s2,a3
        xor     a5,a5,s1
        lw      a2,136(sp)
        lw      a3,72(sp)
        lw      s1,32(sp)
        xor     t4,t4,a2
        xor     s1,s1,a3
        lw      a2,104(sp)
        slli    a3,t2,1
        srli    s3,a6,31
        xor     s1,s1,a2
        lw      t0,124(sp)
        or      s3,s3,a3
        lw      a2,88(sp)
        lw      a3,48(sp)
        xor     s1,s1,t0
        xor     a2,a3,a2
        lw      t0,120(sp)
        xor     a2,a2,t0
        lw      a3,148(sp)
        xor     a2,a2,a3
        lw      a3,52(sp)
        lw      t0,152(sp)
        lw      t6,56(sp)
        xor     a3,a0,a3
        xor     s3,s3,a5
        xor     a2,a2,t0
        xor     a3,a3,s4
        xor     t0,t5,t6
        lw      t6,92(sp)
        xor     a0,s3,a0
        xor     a3,a3,s9
        xor     t0,t0,t6
        lw      t6,52(sp)
        xor     a3,a3,s0
        xor     t6,s3,t6
        xor     s4,s3,s4
        xor     s9,s3,s9
        sw      a0,0(s7)
        xor     s3,s3,s0
        slli    a0,a6,1
        srli    s0,t2,31
        or      a0,s0,a0
        xor     a0,a0,a2
        sw      t6,40(s7)
        sw      s4,80(s7)
        lw      t6,56(sp)
        xor     s4,a0,t5
        xor     t0,t0,s8
        sw      s4,4(s7)
        xor     s4,a0,t6
        lw      t6,92(sp)
        xor     t0,t0,a1
        slli    s0,s2,1
        xor     t6,a0,t6
        xor     s8,a0,s8
        xor     a0,a0,a1
        srli    a1,t4,31
        or      a1,a1,s0
        xor     a1,a1,t2
        sw      a0,164(s7)
        srli    t2,s2,31
        slli    a0,t4,1
        lw      s0,28(sp)
        xor     a4,a4,s6
        or      t2,t2,a0
        xor     t2,t2,a6
        srli    a0,a2,31
        xor     a4,a4,a7
        sw      s9,120(s7)
        slli    a2,a2,1
        xor     s9,s0,a1
        slli    a6,a5,1
        lw      s0,68(sp)
        srli    a5,a5,31
        xor     a4,a4,t1
        xor     s1,s1,t3
        sw      t6,84(s7)
        or      a5,a5,a2
        xor     t6,s0,a1
        lw      s0,32(sp)
        xor     a2,a5,s1
        sw      t6,56(s7)
        or      a6,a0,a6
        xor     t6,s0,t2
        srli    a0,s1,31
        lw      s0,72(sp)
        slli    a5,a4,1
        slli    t5,a3,1
        sw      s4,44(s7)
        or      a5,a0,a5
        xor     s4,s0,t2
        srli    a0,t0,31
        lw      s0,104(sp)
        or      a0,a0,t5
        sw      t6,20(s7)
        xor     t6,s0,t2
        lw      s0,124(sp)
        xor     a5,a5,a3
        xor     a6,a6,a4
        xor     a0,a0,s2
        xor     t3,t3,t2
        xor     s2,s0,t2
        lw      t5,60(sp)
        lw      t2,40(sp)
        slli    s1,s1,1
        srli    a4,a4,31
        xor     s0,t2,a2
        xor     a7,a7,a1
        xor     t2,t5,a5
        xor     t1,t1,a1
        lw      t5,96(sp)
        xor     s6,s6,a1
        or      a1,a4,s1
        xor     a1,a1,t0
        sw      t6,100(s7)
        slli    t0,t0,1
        xor     t6,a5,t5
        srli    a3,a3,31
        or      a3,a3,t0
        lw      s1,36(sp)
        lw      a4,20(sp)
        sw      t6,88(s7)
        lw      t0,4(sp)
        xor     t6,a5,t0
        lw      t0,8(sp)
        lw      t5,64(sp)
        sw      t6,128(s7)
        xor     t6,a5,t0
        sw      t6,168(s7)
        xor     t6,t5,a1
        lw      t5,100(sp)
        xor     a3,a3,t4
        sw      t6,52(s7)
        lw      t4,44(sp)
        xor     t6,a1,t5
        lw      t5,144(sp)
        xor     t5,a1,t5
        xor     t0,t4,a0
        lw      t4,84(sp)
        xor     a4,a4,a5
        sw      t6,92(s7)
        lw      a5,24(sp)
        xor     t6,t4,a0
        sw      t5,132(s7)
        lw      t4,116(sp)
        lw      t5,16(sp)
        xor     a5,a5,a1
        sw      s3,160(s7)
        xor     a1,a1,t5
        lw      s3,140(sp)
        xor     t5,t4,a0
        sw      a7,136(s7)
        lw      t4,128(sp)
        lw      a7,108(sp)
        xor     s1,s1,a6
        xor     t4,t4,a0
        sw      s0,28(s7)
        xor     a0,s3,a0
        xor     s0,a7,a6
        lw      s3,80(sp)
        lw      a7,112(sp)
        sw      t1,176(s7)
        sw      s4,60(s7)
        sw      s2,140(s7)
        sw      t3,180(s7)
        sw      s1,24(s7)
        xor     t3,a7,a2
        xor     s1,s3,a2
        lw      s2,76(sp)
        sw      s9,16(s7)
        sw      s6,96(s7)
        sw      s8,124(s7)
        lw      a7,12(sp)
        lw      s3,132(sp)
        xor     t1,s5,a6
        xor     s2,s2,a6
        sw      t2,48(s7)
        xor     a6,s3,a6
        lw      t2,88(sp)
        lw      s3,136(sp)
        xor     a7,a7,a2
        xor     a2,s3,a2
        xor     s3,t2,a3
        lw      t2,120(sp)
        xor     s4,t2,a3
        lw      t2,148(sp)
        xor     s5,t2,a3
        sw      a1,172(s7)
        lw      t2,152(sp)
        lw      a1,48(sp)
        xor     a1,a1,a3
        xor     a3,t2,a3
        sw      t3,108(s7)
        sw      t5,112(s7)
        sw      a4,8(s7)
        sw      a5,12(s7)
        sw      s2,64(s7)
        addi    t2,sp,256
        sw      t0,32(s7)
        sw      s1,68(s7)
        sw      s0,104(s7)
        sw      t1,144(s7)
        sw      a7,148(s7)
        sw      a6,184(s7)
        sw      a2,188(s7)
        sw      t6,72(s7)
        sw      t4,152(s7)
        sw      a0,192(s7)
        sw      a1,36(s7)
        sw      s3,76(s7)
        sw      s4,116(s7)
        sw      s5,156(s7)
        sw      a3,196(s7)
        addi    t3,sp,160
        addi    t5,a4,0
        beq zero, zero, .L10
.L19:
        sub     a3,zero,a3
        andi    a3,a3,63
        sll     a6,a1,a7
        sub     a4,s10,a3
        slli    a7,a0,1
        addi    t4,a3,-32
        li      t1,0
        sll     a7,a7,a4
        srl     a1,a1,a3
        /* blt     t4,zero,.L8 */
        srli    t6,t4,31
        bne     t6,zero,.L8
.L20:
        srl     a1,a0,t4
        li      a0,0
        or      a3,t1,a1
        or      a6,a6,a0
        sw      a3,0(a2)
        sw      a6,4(a2)
        addi    t2,t2,4
        addi    t3,t3,4
        beq     s11,t2,.L18
.L10:
        lw      a2,0(t2)
        lw      a3,0(t3)
        slli    a2,a2,3
        sub     a0,s10,a3
        add     a2,s7,a2
        srli    a4,t5,1
        addi    a7,a3,-32
        addi    a1,t5,0
        srl     a4,a4,a0
        sll     a6,a5,a3
        addi    a0,a5,0
        lw      t5,0(a2)
        lw      a5,4(a2)
        /* bge     a7,zero,.L19 */
        srli    t1, a7, 31
        beq     t1, zero, .L19

        sll     t1,a1,a3
        sub     a3,zero,a3
        andi    a3,a3,63
        or      a6,a4,a6
        slli    a7,a0,1
        sub     a4,s10,a3
        addi    t4,a3,-32
        sll     a7,a7,a4
        srl     a1,a1,a3
        /* bge     t4,zero,.L20 */
        srli    t0, t4, 31
        beq     t0, zero, .L20
.L8:
        srl     a0,a0,a3
        or      a1,a7,a1
        or      a3,t1,a1
        or      a6,a6,a0
        sw      a3,0(a2)
        sw      a6,4(a2)
        addi    t2,t2,4
        addi    t3,t3,4
        bne     s11,t2,.L10
.L18:
        lw      s1,32(s7)
        lw      t2,24(s7)
        lw      a4,0(s7)
        lw      s3,16(s7)
        lw      t4,36(s7)
        lw      a3,4(s7)
        lw      s8,0(s7)
        sub     s2,zero,a4
        sub     s0,zero,s1
        lw      a4,8(s7)
        sub     t0,zero,t2
        lw      s6,52(s7)
        lw      t1,28(s7)
        lw      s4,20(s7)
        lw      s5,12(s7)
        sw      a4,4(sp)
        and     s0,s0,s8
        and     t0,t0,s1
        lw      s8,4(s7)
        sub     t6,zero,s3
        sub     t5,zero,a3
        sub     t3,zero,t4
        and     s2,s2,a4
        and     t5,t5,s5
        and     t3,t3,s8
        sub     a7,zero,t1
        sub     a6,zero,s4
        sub     a2,zero,s6
        and     t6,t6,t2
        sw      s5,8(sp)
        xor     t2,s0,t2
        lw      s5,60(s7)
        xor     s0,t0,s3
        lw      t0,4(sp)
        lw      a5,56(s7)
        xor     s1,s2,s1
        xor     t6,t6,t0
        and     a7,a7,t4
        and     a2,a2,s5
        xor     t4,t5,t4
        lw      a3,60(s7)
        and     a6,a6,t1
        xor     t1,t3,t1
        lw      a4,64(s7)
        sub     a1,zero,a5
        sw      a2,56(sp)
        sw      s1,44(sp)
        lw      a2,68(s7)
        sw      t2,36(sp)
        sw      s3,12(sp)
        sw      s0,28(sp)
        sw      t6,20(sp)
        sw      t4,48(sp)
        sw      t1,40(sp)
        sub     a3,zero,a3
        lw      s9,48(s7)
        lw      s8,40(s7)
        lw      s5,44(s7)
        and     a1,a1,a4
        sw      s4,16(sp)
        and     a3,a3,a2
        sub     a4,zero,a4
        lw      a2,72(s7)
        and     a4,a4,a2
        xor     a4,a4,a5
        sw      a4,68(sp)
        sw      a4,56(s7)
        lw      a4,72(s7)
        xor     t3,a7,s4
        sub     a0,zero,s9
        lw      a7,8(sp)
        sub     s3,zero,a4
        lw      a4,68(s7)
        xor     a6,a6,a7
        and     a0,a0,a5
        lw      a7,56(sp)
        sub     s2,zero,a4
        lw      a4,96(s7)
        xor     a2,a7,s5
        xor     a0,a0,s8
        xor     a1,a1,s9
        xor     a3,a3,s6
        sw      t3,32(sp)
        sw      s1,32(s7)
        sw      t1,28(s7)
        sw      t3,20(s7)
        lw      t1,88(s7)
        sub     s1,zero,s5
        sub     t3,zero,a4
        lw      a4,84(s7)
        and     s1,s1,s6
        sw      a6,24(sp)
        sw      a0,52(sp)
        sw      a1,60(sp)
        sw      a2,56(sp)
        sw      a3,64(sp)
        sw      t2,24(s7)
        sw      s0,16(s7)
        sw      t6,8(s7)
        lw      s0,76(s7)
        lw      t6,112(s7)
        sw      t4,36(s7)
        sw      a6,12(s7)
        lw      t4,80(s7)
        lw      a6,104(s7)
        sw      a0,40(s7)
        sw      a1,48(s7)
        sw      a2,44(s7)
        sw      a3,52(s7)
        sub     t5,zero,t1
        sub     a1,zero,a4
        lw      a4,92(s7)
        lw      s6,96(s7)
        and     t5,t5,s6
        lw      s6,92(s7)
        sub     a2,zero,a4
        and     a1,a1,s6
        lw      a4,100(s7)
        lw      s6,100(s7)
        sub     a3,zero,a4
        and     a2,a2,s6
        lw      a4,116(s7)
        lw      s6,108(s7)
        lw      a5,108(s7)
        and     a3,a3,s6
        sub     a4,zero,a4
        lw      s6,84(s7)
        sub     s4,zero,s8
        and     a4,a4,s6
        sub     a5,zero,a5
        lw      s6,116(s7)
        and     s4,s4,s9
        and     a5,a5,s6
        lw      s6,72(s7)
        and     s3,s3,s8
        and     t3,t3,a6
        xor     s8,s4,s6
        sub     t0,zero,t4
        lw      s6,64(s7)
        sub     a0,zero,a6
        xor     s9,s3,s6
        and     t0,t0,t1
        and     a0,a0,t6
        xor     t1,t3,t1
        lw      s6,60(s7)
        lw      t3,96(s7)
        and     s2,s2,s0
        xor     s2,s2,s6
        xor     s6,a0,t3
        lw      a0,116(s7)
        xor     a1,a1,a0
        lw      a0,84(s7)
        xor     a2,a2,a0
        sub     t2,zero,s0
        lw      a0,92(s7)
        sub     a7,zero,t6
        xor     s0,s1,s0
        xor     a3,a3,a0
        and     a7,a7,t4
        lw      s1,68(s7)
        lw      a0,108(s7)
        and     t2,t2,s5
        xor     t2,t2,s1
        xor     t6,t0,t6
        xor     a6,a7,a6
        xor     a4,a4,a0
        lw      a0,100(s7)
        xor     a0,a5,a0
        xor     s4,t5,t4
        sw      s8,84(sp)
        sw      s9,76(sp)
        sw      s2,72(sp)
        sw      s0,88(sp)
        sw      t2,80(sp)
        sw      t6,116(sp)
        sw      t1,96(sp)
        sw      a6,108(sp)
        sw      a1,120(sp)
        sw      a2,92(sp)
        sw      a3,100(sp)
        sw      a4,112(sp)
        sw      a0,104(sp)
        lw      a7,120(s7)
        lw      t5,124(s7)
        lw      t0,136(s7)
        lw      t4,156(s7)
        lw      s1,128(s7)
        lw      t3,148(s7)
        lw      s3,188(s7)
        sw      s9,64(s7)
        sw      s8,72(s7)
        sw      s2,60(s7)
        sw      s0,76(s7)
        sw      t2,68(s7)
        lw      s0,152(s7)
        lw      t2,144(s7)
        sw      t6,112(s7)
        sw      t1,88(s7)
        lw      t6,132(s7)
        lw      t1,140(s7)
        sw      a6,104(s7)
        sw      a1,116(s7)
        lw      a6,168(s7)
        lw      a1,192(s7)
        sw      a2,84(s7)
        sw      a3,92(s7)
        lw      a2,184(s7)
        lw      a3,176(s7)
        sw      a4,108(s7)
        sw      a0,100(s7)
        lw      a4,180(s7)
        lw      a0,160(s7)
        sw      s4,80(s7)
        sw      s6,96(s7)
        lw      a5,4(sp)
        sub     s2,zero,a5
        lw      s5,12(sp)
        and     s2,s2,s5
        sub     s5,zero,t0
        and     s5,s5,t2
        lw      a5,8(sp)
        xor     s5,s5,s1
        sw      s5,4(sp)
        sub     a5,zero,a5
        lw      s5,16(sp)
        and     a5,a5,s5
        sub     s9,zero,s1
        sub     s5,zero,a7
        and     s9,s9,t0
        and     s1,s5,s1
        sub     s5,zero,s0
        xor     s9,s9,a7
        and     s5,s5,a7
        sub     a7,zero,t2
        and     a7,a7,s0
        xor     s5,s5,t2
        sub     t2,zero,t1
        sub     s8,zero,t6
        and     t2,t2,t3
        xor     a7,a7,t0
        sub     t0,zero,t5
        xor     t2,t2,t6
        and     s8,s8,t1
        and     t0,t0,t6
        sub     t6,zero,t4
        and     t6,t6,t5
        xor     s8,s8,t5
        sub     t5,zero,t3
        and     t5,t5,t4
        xor     t5,t5,t1
        sub     t1,zero,a3
        xor     t0,t0,t4
        and     t1,t1,a2
        sub     t4,zero,a0
        xor     s1,s1,s0
        and     t4,t4,a6
        sub     s0,zero,a6
        xor     a6,t1,a6
        sub     t1,zero,a2
        xor     t3,t6,t3
        and     t1,t1,a1
        sw      t3,12(sp)
        lw      t6,196(s7)
        and     s0,s0,a3
        xor     t1,t1,a3
        sub     t3,zero,s3
        sub     a3,zero,a4
        and     t3,t3,t6
        and     a3,a3,s3
        lw      t6,172(s7)
        xor     t4,t4,a1
        sw      a6,8(sp)
        xor     a3,a3,t6
        sub     a6,zero,a1
        lw      a1,172(s7)
        xor     s0,s0,a0
        sw      a3,16(sp)
        and     a0,a6,a0
        lw      a3,196(s7)
        sub     a1,zero,a1
        xor     a0,a0,a2
        and     a1,a1,a4
        lw      a2,164(s7)
        xor     t3,t3,a4
        sub     a4,zero,a3
        and     a4,a4,a2
        xor     a3,a4,s3
        lw      a4,4(sp)
        sw      a4,128(s7)
        lw      a4,12(sp)
        sw      t5,124(sp)
        sw      a0,132(sp)
        sw      a3,136(sp)
        sw      a4,148(s7)
        sw      t5,140(s7)
        sw      s1,128(sp)
        sw      t2,144(sp)
        sw      t0,148(sp)
        sw      t4,140(sp)
        sw      s9,120(s7)
        sw      s8,124(s7)
        sw      s1,152(s7)
        sw      s5,144(s7)
        sw      a7,136(s7)
        sw      t2,132(s7)
        sw      t0,156(s7)
        sw      t4,192(s7)
        xor     a1,a1,a2
        lw      a4,16(sp)
        sub     a2,zero,a2
        and     a2,a2,t6
        sw      a4,172(s7)
        lw      a4,196(s7)
        sw      a3,188(s7)
        xor     a3,a2,a4
        sw      a3,152(sp)
        lw      a4,0(s7)
        lw      a2,4(s7)
        sw      a3,196(s7)
        lw      a3,156(sp)
        xor     a4,s2,a4
        xor     t5,a5,a2
        sw      a0,184(s7)
        lw      a5,4(a3)
        lw      a0,0(a3)
        xor     a0,a0,a4
        xor     t5,a5,t5
        lw      a6,8(sp)
        addi    a5,a3,8
        sw      s0,160(s7)
        sw      a6,168(s7)
        sw      t1,176(s7)
        sw      a1,164(s7)
        sw      t3,180(s7)
        sw      a0,0(s7)
        sw      t5,4(s7)
        sw      a5,156(sp)
        addi    a4,sp,544
        bne     a4,a5,.L5
        lw      s0,588(sp)
        lw      s1,584(sp)
        lw      s2,580(sp)
        lw      s3,576(sp)
        lw      s4,572(sp)
        lw      s5,568(sp)
        lw      s6,564(sp)
        lw      s7,560(sp)
        lw      s8,556(sp)
        lw      s9,552(sp)
        lw      s10,548(sp)
        lw      s11,544(sp)
        addi    sp,sp,592
        ret
sha3_init:
        addi    a5,a0,0
        addi    a4,a0,200
.L22:
        li      a2,0
        li      a3,0
        sw      a2,0(a5)
        sw      a3,4(a5)
        addi    a5,a5,8
        bne     a5,a4,.L22
        li      a5,100
        sub     a5,a5,a1
        slli    a5,a5,1
        sw      a1,208(a0)
        sw      zero,200(a0)
        sw      a5,204(a0)
        li      a0,1
        ret
sha3_update:
        addi    sp,sp,-32
        sw      s1,20(sp)
        sw      ra,28(sp)
        addi    s1,a0,0
        lw      a5,200(a0)
        beq     a2,zero,.L25
        sw      s0,24(sp)
        sw      s2,16(sp)
        sw      s3,12(sp)
        addi    s0,a1,0
        add     s2,a1,a2
        lw      s3,204(a0)
        beq zero, zero, .L27
.L26:
        addi    s0,s0,1
        beq     s0,s2,.L34
.L27:
        add     a3,s1,a5
        lbu_rep a4, 0, a3, t0
        lbu_rep a1, 0, s0, t0
        xor     a4,a4,a1
        addi    a5,a5,1
        sb      a4,0(a3)
        /* blt     a5,s3,.L26 */
        sub     a0,a5,s3
        srli    a0,a0,31
        bne     a0,zero,.L26
        addi    a0,s1,0
        jal     x1, sha3_keccakf
        addi    s0,s0,1
        li      a5,0
        bne     s0,s2,.L27
.L34:
        lw      s0,24(sp)
        lw      s2,16(sp)
        lw      s3,12(sp)
.L25:
        sw      a5,200(s1)
        lw      ra,28(sp)
        lw      s1,20(sp)
        li      a0,1
        addi    sp,sp,32
        ret
sha3_final:
        lw      a4,200(a1)
        add     a4,a1,a4
        lbu_rep     a3, 0, a4, t0
        addi    sp,sp,-16
        sw      s0,8(sp)
        sw      s1,4(sp)
        lw      a5,204(a1)
        sw      ra,12(sp)
        xori    a3,a3,6
        add     a5,a1,a5
        sb      a3,0(a4)
        lbu_rep  a4, -1, a5, t0
        xori    a4,a4,-128
        sb      a4,-1(a5)
        addi    s1,a0,0
        addi    a0,a1,0
        addi    s0,a1,0
        jal     x1, sha3_keccakf
        lw      a5,208(s0)
        ble     a5,zero,.L36
        li      a5,0
.L37:
        add     a4,s0,a5
        lbu_rep a3, 0, a4, t0
        add     a4,s1,a5
        sb      a3,0(a4)
        addi    a5,a5,1
        lw      a4,208(s0)
        /* bgt     a4,a5,.L37 */
        sub     t0, a5, a4
        srli    t0, t0, 31
        bne     t0, zero, .L37
.L36:
        lw      ra,12(sp)
        lw      s0,8(sp)
        lw      s1,4(sp)
        li      a0,1
        addi    sp,sp,16
        ret
sha3:
        addi    sp,sp,-256
        sw      s1,244(sp)
        addi    s1,sp,8
        sw      s2,240(sp)
        sw      s5,228(sp)
        sw      ra,252(sp)
        sw      s3,236(sp)
        addi    s2,a2,0
        addi    s5,a3,0
        addi    a5,s1,0
        addi    a4,sp,208
.L41:
        li      a2,0
        li      a3,0
        sw      a2,0(a5)
        sw      a3,4(a5)
        addi    a5,a5,8
        bne     a5,a4,.L41
        li      s3,100
        sub     s3,s3,s5
        slli    s3,s3,1
        sw      s5,216(sp)
        sw      zero,208(sp)
        sw      s3,212(sp)
        beq     a1,zero,.L51
        sw      s0,248(sp)
        sw      s4,232(sp)
        addi    s0,a0,0
        add     s4,a0,a1
        li      a5,0
        beq zero, zero, .L44
.L43:
        addi    s0,s0,1
        beq     s0,s4,.L58
.L44:
        add     a1,a5,sp
        lbu_rep     a4, 8, a1, t0
        lbu_rep     a2, 0, s0, t0
        xor     a4,a4,a2
        addi    a5,a5,1
        sb      a4,8(a1)
        /* bgt     s3,a5,.L43 */
        sub     t0, a5, s3
        srli    t0, t0, 31
        bne     t0, zero, .L37
        addi    a0,sp,8
        jal     x1, sha3_keccakf
        addi    s0,s0,1
        li      a5,0
        bne     s0,s4,.L44
.L58:
        lw      s0,248(sp)
        lw      s4,232(sp)
.L42:
        add     a5,a5,sp
        lbu_rep a4, 8, a5, t0
        xori    a4,a4,6
        add     s3,s3,sp
        sb      a4,8(a5)
        lbu_rep a5,7, s3, t0
        xori    a5,a5,-128
        addi    a0,sp,8
        sb      a5,7(s3)
        jal     x1, sha3_keccakf
        ble     s5,zero,.L45
        addi    a5,s5,-1
        li      a4,5
        bleu    a5,a4,.L46
        andi    a5,s2,3
        bne     a5,zero,.L46
        andi    a2,s5,-4
        add     a3,s2,a2
        addi    a5,s2,0
.L47:
        lw      a4,0(s1)
        sw      a4,0(a5)
        addi    a5,a5,4
        addi    s1,s1,4
        bne     a5,a3,.L47
        beq     s5,a2,.L45
        andi    a5,s5,-4
        add     a4,a2,sp
        add     a5,s2,a5
        lbu_rep a4, 8, a4, t0
        sb      a4,0(a5)
        addi    a5,a2,1
        ble     s5,a5,.L45
        add     a4,a2,sp
        lbu_rep a4, 9, a4, t0
        add     a5,s2,a5
        addi    a2,a2,2
        sb      a4,0(a5)
        ble     s5,a2,.L45
        add     a5,a2,sp
        lbu_rep a5, 8, a5, t0
        add     a2,s2,a2
        sb      a5,0(a2)
.L45:
        lw      ra,252(sp)
        addi    a0,s2,0
        lw      s1,244(sp)
        lw      s2,240(sp)
        lw      s3,236(sp)
        lw      s5,228(sp)
        addi    sp,sp,256
        ret
.L46:
        addi    a5,sp,8
        add     a5,a5,s5
        addi    a4,s2,0
.L49:
        lbu_rep a3, 0, s1, t0
        sb      a3,0(a4)
        addi    s1,s1,1
        addi    a4,a4,1
        bne     s1,a5,.L49
        lw      ra,252(sp)
        addi    a0,s2,0
        lw      s1,244(sp)
        lw      s2,240(sp)
        lw      s3,236(sp)
        lw      s5,228(sp)
        addi    sp,sp,256
        ret
.L51:
        li      a5,0
        beq zero, zero, .L42
shake_xof:
        lw      a4,200(a0)
        add     a4,a0,a4
        addi    sp,sp,-16
        lbu_rep a3, 0, a4, t0
        sw      s0,8(sp)
        sw      ra,12(sp)
        lw      a5,204(a0)
        xori    a3,a3,31
        sb      a3,0(a4)
        add     a5,a0,a5
        lbu_rep     a4, -1, a5, t0
        xori    a4,a4,-128
        sb      a4,-1(a5)
        addi    s0,a0,0
        jal     x1, sha3_keccakf
        lw      ra,12(sp)
        sw      zero,200(s0)
        lw      s0,8(sp)
        addi    sp,sp,16
        ret
shake_out:
        addi    sp,sp,-16
        sw      s1,4(sp)
        sw      ra,12(sp)
        addi    s1,a0,0
        lw      a5,200(a0)
        beq     a2,zero,.L62
        sw      s0,8(sp)
        sw      s2,0(sp)
        addi    s0,a1,0
        add     s2,a1,a2
.L65:
        lw      a4,204(s1)
        add     a3,s1,a5
        ble     a4,a5,.L63
        lbu_rep a4, 0, a3, t0
        sb      a4,0(s0)
        addi    s0,s0,1
        addi    a5,a5,1
        bne     s2,s0,.L65
.L67:
        lw      s0,8(sp)
        lw      s2,0(sp)
.L62:
        sw      a5,200(s1)
        lw      ra,12(sp)
        lw      s1,4(sp)
        addi    sp,sp,16
        ret
.L63:
        addi    a0,s1,0
        jal     x1, sha3_keccakf
        lbu_rep a5, 0, s1, lbu_rep
        sb      a5,0(s0)
        addi    s0,s0,1
        li      a5,1
        bne     s0,s2,.L65
        beq zero, zero, .L67