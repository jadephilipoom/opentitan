/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Standalone tests for SHA-3 hash computation.
 */

.section .text.start
run_sha3:
  /* Load stack pointer */
  la x2, stack_end

  la x10, context
  li x11, 48 /* mdlen */
  jal x1, sha3_init

  la x10, context
  la x11, test_msg
  li x12, 208 /* msglen */
  jal x1, sha3_update

  la x10, context
  la x11, test_dst
  jal x1, sha3_final

  ecall

.section .data
.balign 32
test_dst:
  .zero 256

.global context
context:
.balign 32
.zero 212

.globl rc
.balign 32
rc:
  .balign 32
  .dword 0x0000000000000001
  .balign 32
  .dword 0x0000000000008082
  .balign 32
  .dword 0x800000000000808a
  .balign 32
  .dword 0x8000000080008000
  .balign 32
  .dword 0x000000000000808b
  .balign 32
  .dword 0x0000000080000001
  .balign 32
  .dword 0x8000000080008081
  .balign 32
  .dword 0x8000000000008009
  .balign 32
  .dword 0x000000000000008a
  .balign 32
  .dword 0x0000000000000088
  .balign 32
  .dword 0x0000000080008009
  .balign 32
  .dword 0x000000008000000a
  .balign 32
  .dword 0x000000008000808b
  .balign 32
  .dword 0x800000000000008b
  .balign 32
  .dword 0x8000000000008089
  .balign 32
  .dword 0x8000000000008003
  .balign 32
  .dword 0x8000000000008002
  .balign 32
  .dword 0x8000000000000080
  .balign 32
  .dword 0x000000000000800a
  .balign 32
  .dword 0x800000008000000a
  .balign 32
  .dword 0x8000000080008081
  .balign 32
  .dword 0x8000000000008080
  .balign 32
  .dword 0x0000000080000001
  .balign 32
  .dword 0x8000000080008008

.balign 32
test_msg:
  /* .dword 0x0D09DE907CCC2F9F
  .dword 0xEAC118977ECD876B
  .dword 0xE95D2DFC1811B26C
  .dword 0x109C1EACB65D7EF9 */
  .dword 0x4CAD9997EB8057E3
  .dword 0xF33C68DB4D5D5377
  .dword 0x4CCF27537167F33E
  .dword 0x86D4CDBD9CED584A
  .dword 0xA949D58901F869F6
  .dword 0x5426A5512AA84F36
  .dword 0xCE5DB9AAB31B72EC
  .dword 0x6D8293FA6A6AA8B4
  .dword 0xE3338F927E5123B9
  .dword 0x83EF6056D450A8FB
  .dword 0x98A9A2AFCC6A87B9
  .dword 0x0A146E7C134B257A
  .dword 0x48384169101E6921

  .zero 512
stack_end:
  .zero 1