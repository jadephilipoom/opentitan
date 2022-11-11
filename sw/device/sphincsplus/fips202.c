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

void shake256_inc_squeeze_once(uint8_t *output, size_t outlen, shake256_inc_state_t *s_inc) {
  if (misalignment32_of((uintptr_t) output) != 0) {
    LOG_ERROR("shake256: output misaligned.");
    abort();
  }

  // `dif_kmac_squeeze()` provides output at the granularity of 32b words, not
  // bytes.
  size_t outlen_words = outlen / sizeof(uint32_t);
  if (outlen_words > 0) {
    ABORT_IF_ERROR(
        dif_kmac_squeeze(&s_inc->kmac, &s_inc->kmac_operation_state,
          (uint32_t *)output, outlen_words, NULL),
          "shake256: error during KMAC squeeze.");
    outlen -= outlen_words * sizeof(uint32_t);
  }

  // Squeeze remaining bytes (if any).
  if (outlen > 0) {
      uint32_t buf;
      ABORT_IF_ERROR(
          dif_kmac_squeeze(&s_inc->kmac, &s_inc->kmac_operation_state,
            &buf, 1, NULL),
            "shake256: error during KMAC squeeze for last few bytes.");
      memcpy(output, &buf, outlen);
  }

  // XXX: this will not work for repeated squeezing! It just so happens that we
  // only ever squeeze once here.
  ABORT_IF_ERROR(
      dif_kmac_end(&s_inc->kmac, &s_inc->kmac_operation_state),
      "shake256: error during KMAC end.");
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

