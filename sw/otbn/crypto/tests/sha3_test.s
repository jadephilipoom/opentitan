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

  jal x1, sha3_init

  ecall

.section .data
.globl cfg_data
cfg_data:
.balign 32
init_state:
  /* initial hash values h[0] to h[7]*/
  .dword 0x6a09e667f3bcc908
  .balign 32
  .dword 0xbb67ae8584caa73b
  .balign 32
  .dword 0x3c6ef372fe94f82b
  .balign 32
  .dword 0xa54ff53a5f1d36f1
  .balign 32
  .dword 0x510e527fade682d1
  .balign 32
  .dword 0x9b05688c2b3e6c1f
  .balign 32
  .dword 0x1f83d9abfb41bd6b
  .balign 32
  .dword 0x5be0cd19137e2179

.balign 32
test_msg:
  .dword 0x6162638000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000000
  .dword 0x0000000000000018

  .zero 512
stack_end:
  .zero 1