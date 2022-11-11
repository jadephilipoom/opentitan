/* Based on the public domain implementation in
 * crypto_hash/keccakc512/simple/ from http://bench.cr.yp.to/supercop.html
 * by Ronny Van Keer
 * and the public domain "TweetFips202" implementation
 * from https://twitter.com/tweetfips202
 * by Gilles Van Assche, Daniel J. Bernstein, and Peter Schwabe */

#include <stddef.h>
#include <stdint.h>

#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/dif/dif_kmac.h"
#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "fips202.h"

#define ABORT_IF_ERROR(_dif_result, msg) \
  if (_dif_result != kDifOk) {           \
    LOG_ERROR(msg);                      \
    abort();                             \
  }

void shake256_inc_init(shake256_inc_state_t *s_inc) {
  // Intialize KMAC hardware.
  ABORT_IF_ERROR(
      dif_kmac_init(mmio_region_from_addr(TOP_EARLGREY_KMAC_BASE_ADDR),
        &s_inc->kmac),
      "shake256: error during KMAC init.");

  // Configure KMAC hardware using software entropy.
  dif_kmac_config_t config = (dif_kmac_config_t){
      .entropy_mode = kDifKmacEntropyModeEdn,
      .entropy_seed = {0},
      .entropy_fast_process = kDifToggleEnabled,
  };
  ABORT_IF_ERROR(
      dif_kmac_configure(&s_inc->kmac, config),
      "shake256: error during KMAC config.");

  ABORT_IF_ERROR(
      dif_kmac_mode_shake_start(&s_inc->kmac, &s_inc->kmac_operation_state,
        kDifKmacModeShakeLen256),
      "shake256: error during KMAC start.");
}

void shake256_inc_absorb(shake256_inc_state_t *s_inc, const uint8_t *input, size_t inlen) {
  if (misalignment32_of((uintptr_t) input) != 0) {
    LOG_ERROR("shake256: input misaligned.");
    abort();
  }
  ABORT_IF_ERROR(
      dif_kmac_absorb(&s_inc->kmac, &s_inc->kmac_operation_state, (uint32_t *)input,
          inlen, NULL),
      "shake256: error during KMAC absorb.");
}

/**
 * Squeeze full words from KMAC.
 */
static void shake256_inc_squeezeblocks(uint32_t *output, size_t outlen_words, shake256_inc_state_t *s_inc) {
  ABORT_IF_ERROR(
      dif_kmac_squeeze(&s_inc->kmac, &s_inc->kmac_operation_state,
        output, outlen_words, NULL),
      "shake256: error during KMAC squeeze");
}

/**
 * Variant of `shake256_inc_squeeze_once` that strictly requires its output
 * buffer to be 32b aligned.
 */
static void shake256_inc_squeeze_once_aligned(uint8_t *output, size_t outlen, shake256_inc_state_t *s_inc) {
  if (misalignment32_of((uintptr_t) output) != 0) {
    LOG_ERROR("shake256: output misaligned. %u %u", output, (uintptr_t) output);
    abort();
  }

  // `dif_kmac_squeeze()` provides output at the granularity of 32b words, not
  // bytes.
  size_t outlen_words = outlen / sizeof(uint32_t);
  if (outlen_words > 0) {
    shake256_inc_squeezeblocks((uint32_t *)output, outlen_words, s_inc);
    outlen -= outlen_words * sizeof(uint32_t);
    output += outlen_words * sizeof(uint32_t);
  }

  // Squeeze remaining bytes (if any).
  if (outlen > 0) {
      uint32_t buf;
      shake256_inc_squeezeblocks(&buf, 1, s_inc);
      LOG_INFO("Last word: 0x%08x", buf);
      memcpy(output, &buf, outlen);
  }

  // XXX: this will not work for repeated squeezing! It just so happens that we
  // only ever squeeze once here.
  ABORT_IF_ERROR(
      dif_kmac_end(&s_inc->kmac, &s_inc->kmac_operation_state),
      "shake256: error during KMAC end.");
}

void shake256_inc_squeeze_once(uint8_t *output, size_t outlen, shake256_inc_state_t *s_inc) {
  if (misalignment32_of((uintptr_t) output) == 0) {
    LOG_INFO("Output is aligned.");
    // Output buffer is aligned; use it directly. 
    shake256_inc_squeeze_once_aligned(output, outlen, s_inc);
  } else {
    LOG_INFO("Output is NOT aligned.");
    // Output buffer is misaligned; write to an aligned buffer and later copy.
    size_t outlen_words = outlen / sizeof(uint32_t);
    if (outlen % sizeof(uint32_t) != 0) {
      outlen_words++;
    }
    uint32_t aligned_output[outlen_words];
    shake256_inc_squeeze_once_aligned((uint8_t *)aligned_output, outlen, s_inc);

    // TODO: consider ways to avoid this copying, e.g. adjusting the KMAC
    // driver to handle misaligned input buffers internally or changing a lot
    // of byte buffers to word buffers everywhere.
    memcpy(output, aligned_output, outlen);
  }
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
void shake256(uint8_t *output, size_t outlen,
              const uint8_t *input, size_t inlen) {
  shake256_inc_state_t s_inc;
  shake256_inc_init(&s_inc);
  shake256_inc_absorb(&s_inc, input, inlen);
  shake256_inc_squeeze_once(output, outlen, &s_inc);
}

