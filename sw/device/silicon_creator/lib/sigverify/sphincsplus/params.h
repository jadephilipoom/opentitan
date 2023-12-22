// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_PARAMS_H_
#define OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_PARAMS_H_

#include "sw/device/silicon_creator/lib/sigverify/sphincsplus/params/benchmark_params.h"

/**
 * This file inserts parameters from benchmark_params.h.
 *
 * The OpenTitan implementation refers to constants using a different format
 * than the SPHINCS+ reference implementation. For benchmarking purposes, this
 * version expects the exact same format as the reference implementation in
 * benchmark_params.h and instantiates all the OpenTitan constants using those
 * values.
 */

enum {
  /**
   * Hash output length in bytes.
   */
  kSpxN = SPX_N,
  /**
   * Height of the hypertree.
   */
  kSpxFullHeight = SPX_FULL_HEIGHT,
  /**
   * Number of subtree layers.
   */
  kSpxD = SPX_D,
  /**
   * FORS tree dimension (height).
   */
  kSpxForsHeight = SPX_FORS_HEIGHT,
  /**
   * FORS tree dimension (number of trees).
   */
  kSpxForsTrees = SPX_FORS_TREES,
  /**
   * Winternitz parameter.
   */
  kSpxWotsW = SPX_WOTS_W,
  /**
   * Number of bytes in a hypertree address (for clarity).
   */
  kSpxAddrBytes = SPX_ADDR_BYTES,
  /**
   * Bit-length of the Winternitz parameter.
   */
  kSpxWotsLogW = SPX_WOTS_LOGW,
  /**
   * Parameter `len1` for WOTS signatures.
   *
   * See section 3.1 of the SPHINCS+ NIST submission:
   *   https://sphincs.org/data/sphincs+-r3.1-specification.pdf
   */
  kSpxWotsLen1 = SPX_WOTS_LEN1,
  /**
   * Parameter `len2` for WOTS signatures.
   *
   * This value is precomputed and equal to:
   *   floor(log(len1 * (w - 1)) / log(w)) + 1
   *
   * During the WOTS computation, the maximum checksum value is `len1 * (w -
   * 1)`. The log() functions here essentially apply the change-of-base rule;
   * what we are actually computing is floor(log_w(len1 * (w - 1))) + 1, which
   * expresses the number of base-w integers required to encode the checksum.
   *
   * Some precomputed values based on w and n:
   *   +------+----------------+----------+
   *   |  w   |        n       |   len2   |
   *   +------+----------------+----------+
   *   | 256  |   0 < n <= 1   |    1     |
   *   | 256  |   1 < n <= 256 |    2     |
   *   |  16  |   0 < n <= 8   |    2     |
   *   |  16  |   8 < n <= 136 |    3     |
   *   |  16  | 136 < n <= 256 |    4     |
   *   +------+----------------+----------+
   *
   * See section 3.1 of the SPHINCS+ NIST submission:
   *   https://sphincs.org/data/sphincs+-r3.1-specification.pdf
   */
  kSpxWotsLen2 = SPX_WOTS_LEN2,
  /**
   * Number of chains to compute for a WOTS signature.
   */
  kSpxWotsLen = SPX_WOTS_LEN,
  /**
   * WOTS signature length in bytes.
   *
   * The signature is composed of `kSpxWotsLen` blocks of `kSpxN` bytes each.
   */
  kSpxWotsBytes = SPX_WOTS_BYTES,
  /**
   * WOTS public key length in bytes.
   */
  kSpxWotsPkBytes = SPX_WOTS_PK_BYTES,
  /**
   * Subtree size.
   */
  kSpxTreeHeight = SPX_TREE_HEIGHT,
  /**
   * FORS message length.
   */
  kSpxForsMsgBytes = SPX_FORS_MSG_BYTES,
  /**
   * FORS signature length.
   */
  kSpxForsBytes = SPX_FORS_BYTES,
  /**
   * FORS public key length.
   */
  kSpxForsPkBytes = SPX_FORS_PK_BYTES,
  /**
   * SPHINCS+ signature.
   */
  kSpxBytes = SPX_BYTES,
  /**
   * SPHINCS+ public key length.
   */
  kSpxPkBytes = SPX_PK_BYTES,
  /**
   * SPHINCS+ secret key length.
   */
  kSpxSkBytes = SPX_SK_BYTES,
  /**
   * Hash output length (n) in words.
   */
  kSpxNWords = kSpxN / sizeof(uint32_t),
  /**
   * FORS signature size in words.
   */
  kSpxForsWords = kSpxForsBytes / sizeof(uint32_t),
  /**
   * WOTS signature size in words.
   */
  kSpxWotsWords = kSpxWotsBytes / sizeof(uint32_t),
  /**
   * WOTS public key size in words.
   */
  kSpxWotsPkWords = kSpxWotsPkBytes / sizeof(uint32_t),
  /**
   * SPHINCS+ public key length in words.
   */
  kSpxPkWords = kSpxPkBytes / sizeof(uint32_t),
};

/**
 * These constants are byte offsets within the hypertree address structure.
 */
enum {
  /**
   * Byte used to specify the Merkle tree layer.
   */
  kSpxOffsetLayer = SPX_OFFSET_LAYER,
  /**
   * Starting byte of the tree field (8 bytes).
   */
  kSpxOffsetTree = SPX_OFFSET_TREE,
  /**
   * Byte used to specify the hash type (reason).
   */
  kSpxOffsetType = SPX_OFFSET_TYPE,
  /**
   * High byte of the key pair.
   */
  kSpxOffsetKpAddr2 = SPX_OFFSET_KP_ADDR2,
  /**
   * Low byte of the key pair.
   */
  kSpxOffsetKpAddr1 = SPX_OFFSET_KP_ADDR1,
  /**
   * Byte for the chain address (i.e. which Winternitz chain).
   */
  kSpxOffsetChainAddr = SPX_OFFSET_CHAIN_ADDR,
  /**
   * Byte for the hash address (i.e. where in the Winternitz chain).
   */
  kSpxOffsetHashAddr = SPX_OFFSET_HASH_ADDR,
  /**
   * Byte for the height of this node in the FORS or Merkle tree.
   */
  kSpxOffsetTreeHeight = SPX_OFFSET_TREE_HGT,
  /**
   * Starting byte for the tree index field (4 bytes) in the FORS or Merkle
   * tree.
   */
  kSpxOffsetTreeIndex = SPX_OFFSET_TREE_INDEX,
};

#endif  // OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_SIGVERIFY_SPHINCSPLUS_PARAMS_H_
