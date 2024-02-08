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

  /* SHA3-224, corner case with 0-length message */

  la x10, context
  li x11, 28 /* mdlen */
  jal x1, sha3_init

  la x10, context
  la x11, test_msg_256_32
  li x12, 0 /* msglen */
  jal x1, sha3_update

  la x10, context
  la x11, test_dst_224
  jal x1, sha3_final

  /* SHA3-256, short message */

  la x10, context
  li x11, 32 /* mdlen */
  jal x1, sha3_init

  la x10, context
  la x11, test_msg_256_32
  li x12, 32 /* msglen */
  jal x1, sha3_update

  la x10, context
  la x11, test_dst_256
  jal x1, sha3_final

  /* SHA3-384, exact block size */

  la x10, context
  li x11, 48 /* mdlen */
  jal x1, sha3_init

  la x10, context
  la x11, test_msg_384_104
  li x12, 104 /* msglen */
  jal x1, sha3_update

  la x10, context
  la x11, test_dst_384
  jal x1, sha3_final

  /* SHA3-512, multiblock message */

  la x10, context
  li x11, 64 /* mdlen */
  jal x1, sha3_init

  la x10, context
  la x11, test_msg_512_255
  li x12, 255 /* msglen */
  jal x1, sha3_update

  la x10, context
  la x11, test_dst_512
  jal x1, sha3_final

  ecall

.section .data

.global msg
msg:
  .balign 32
  .zero 1024

.global digest
digest:
  .balign 32
  .zero 1024

.global msg_len
msg_len:
  .balign 4
  .zero 4

.global dgst_mode /* 0=SHA-3, 1=SHAKE */
dgst_mode:
  .balign 4
  .zero 4

.global dgst_size /* Desired digest size/length for SHAKE */
dgst_mode:
  .balign 4
  .zero 4

.global context
context:
  .balign 32
  .zero 212

.global rc
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

  .zero 64
stack_end:
  .zero 1