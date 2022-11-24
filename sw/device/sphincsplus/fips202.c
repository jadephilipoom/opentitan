/* Based on the public domain implementation in
 * crypto_hash/keccakc512/simple/ from http://bench.cr.yp.to/supercop.html
 * by Ronny Van Keer
 * and the public domain "TweetFips202" implementation
 * from https://twitter.com/tweetfips202
 * by Gilles Van Assche, Daniel J. Bernstein, and Peter Schwabe */

#include "fips202.h"

#include <stddef.h>
#include <stdint.h>

#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/sphincsplus/drivers/kmac.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "kmac_regs.h"

#define ABORT_IF_ERROR(_kmac_err, msg) \
  if (_kmac_err != kKmacOk) {          \
    LOG_ERROR(msg);                    \
    abort();                           \
  }

void shake256_inc_init(shake256_inc_state_t *s_inc) {
  ABORT_IF_ERROR(kmac_shake256_start(), "shake256: error during start.");
}

void shake256_inc_absorb(shake256_inc_state_t *s_inc, const uint8_t *input,
                         size_t inlen) {
  ABORT_IF_ERROR(kmac_shake256_absorb(input, inlen),
                 "shake256: error during absorb.");
}

/**
 * Squeeze full words from KMAC.
 */
static void shake256_inc_squeezeblocks(uint32_t *output, size_t outlen_words,
                                       shake256_inc_state_t *s_inc) {
  ABORT_IF_ERROR(
      kmac_shake256_squeeze(output, outlen_words, s_inc),
      "shake256: error during squeeze.");
}

/**
 * Variant of `shake256_inc_squeeze_once` that strictly requires its output
 * buffer to be 32b aligned.
 */
static void shake256_inc_squeeze_once_aligned(uint8_t *output, size_t outlen,
                                              shake256_inc_state_t *s_inc) {
  // Start squeezing stage.
  ABORT_IF_ERROR(kmac_shake256_squeeze_start(s_inc),
                 "shake256: error during squeeze start.");

  size_t outlen_words = outlen / sizeof(uint32_t);
  if (outlen_words > 0) {
    shake256_inc_squeezeblocks((uint32_t *)output, outlen_words, s_inc);
    outlen = outlen % sizeof(uint32_t);
  }

  // Squeeze remaining bytes (if any).
  if (outlen > 0) {
    uint32_t buf;
    shake256_inc_squeezeblocks(&buf, 1, s_inc);
    memcpy(&output[outlen_words * sizeof(uint32_t)], &buf, outlen);
  }

  // XXX: this will not work for repeated squeezing! It just so happens that we
  // only ever squeeze once here.
  ABORT_IF_ERROR(kmac_shake256_end(), "shake256: error during end.");
}

void shake256_inc_squeeze_once(uint8_t *output, size_t outlen,
                               shake256_inc_state_t *s_inc) {
  if (misalignment32_of((uintptr_t)output) == 0) {
    // Output buffer is aligned; use it directly.
    shake256_inc_squeeze_once_aligned(output, outlen, s_inc);
  } else {
    LOG_ERROR("sha256: error: output misaligned.");
    abort();
  }
}

void shake256_setup(void) {
  ABORT_IF_ERROR(kmac_shake256_configure(),
                 "sha256: error during configuration.");
}

/*************************************************
 * Name:        shake256
 *
 * Description: SHAKE256 XOF with non-incremental API
 *
 * Arguments:   - uint8_t *output: pointer to output
 *              - size_t outlen: requested output length in bytes
 *              - const uint8_t *input: pointer to input
 *              - size_t inlen: length of input in bytes
 **************************************************/
void shake256(uint8_t *output, size_t outlen, const uint8_t *input,
              size_t inlen) {
  shake256_inc_state_t s_inc;
  shake256_inc_init(&s_inc);
  shake256_inc_absorb(&s_inc, input, inlen);
  shake256_inc_squeeze_once(output, outlen, &s_inc);
}
