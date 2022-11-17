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
#include "sw/device/lib/dif/dif_kmac.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/sphincsplus/drivers/kmac.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "kmac_regs.h"

#define ABORT_IF_ERROR(_dif_result, msg) \
  if (_dif_result != kDifOk) {           \
    LOG_ERROR(msg);                      \
    abort();                             \
  }

// Copied from dif_kmac.c
static bool is_state_idle(const dif_kmac_t *kmac) {
  uint32_t reg = mmio_region_read32(kmac->base_addr, KMAC_STATUS_REG_OFFSET);
  return bitfield_bit32_read(reg, KMAC_STATUS_SHA3_IDLE_BIT);
}

// Copied from dif_kmac.c
static bool has_error_occurred(const dif_kmac_t *kmac) {
  uint32_t reg =
      mmio_region_read32(kmac->base_addr, KMAC_INTR_STATE_REG_OFFSET);
  return bitfield_bit32_read(reg, KMAC_INTR_STATE_KMAC_ERR_BIT);
}

// Copied from dif_kmac.c
static dif_result_t poll_state(const dif_kmac_t *kmac, uint32_t flag) {
  while (true) {
    uint32_t reg = mmio_region_read32(kmac->base_addr, KMAC_STATUS_REG_OFFSET);
    if (bitfield_bit32_read(reg, flag)) {
      break;
    }
    if (has_error_occurred(kmac)) {
      return kDifError;
    }
  }
  return kDifOk;
}

/**
 * Issues a start command to KMAC, preserving the preexisting configuration.
 *
 * XXX: this is a bit of a hack to get around the driver combining "start
 * hash" and "configure which hash function you're using"; these should be
 * decoupled for performance.
 *
 * This code is selectively copied from `dif_kmac_mode_shake_start`, which
 * combines the steps of setting up KMAC to run SHAKE-256 and actually starting
 * a hash operation. For SPHINCS+, we want to decouple these two so we're not
 * wasting time reconfiguring the KMAC hardware every time we want to hash
 * something, since we only use SHAKE-256 anyway.
 *
 * Callers must use `shake256_setup` first to configure the KMAC hardware for
 * SHA-256.
 */
static dif_result_t kmac_start(const dif_kmac_t *kmac,
                               dif_kmac_operation_state_t *operation_state) {
  // Hardware must be idle to start an operation.
  if (!is_state_idle(kmac)) {
    return kDifError;
  }
  operation_state->squeezing = false;
  operation_state->append_d = false;
  operation_state->r = (1600 - (2 * 256)) / 32;
  operation_state->d = 0;  // Zero indicates variable digest length.
  operation_state->offset = 0;

  // Issue start command.
  uint32_t cmd_reg =
      bitfield_field32_write(0, KMAC_CMD_CMD_FIELD, KMAC_CMD_CMD_VALUE_START);
  mmio_region_write32(kmac->base_addr, KMAC_CMD_REG_OFFSET, cmd_reg);

  return poll_state(kmac, KMAC_STATUS_SHA3_ABSORB_BIT);
}

void shake256_inc_init(shake256_inc_state_t *s_inc) {
  s_inc->kmac = (dif_kmac_t){
      .base_addr = mmio_region_from_addr(TOP_EARLGREY_KMAC_BASE_ADDR),
  };
  ABORT_IF_ERROR(kmac_start(&s_inc->kmac, &s_inc->kmac_operation_state),
                 "sha256: error during KMAC start");
}

void shake256_inc_absorb(shake256_inc_state_t *s_inc, const uint8_t *input,
                         size_t inlen) {
  ABORT_IF_ERROR(dif_kmac_absorb(&s_inc->kmac, &s_inc->kmac_operation_state,
                                 input, inlen, NULL),
                 "shake256: error during KMAC absorb.");
}

/**
 * Squeeze full words from KMAC.
 */
static void shake256_inc_squeezeblocks(uint32_t *output, size_t outlen_words,
                                       shake256_inc_state_t *s_inc) {
  ABORT_IF_ERROR(dif_kmac_squeeze(&s_inc->kmac, &s_inc->kmac_operation_state,
                                  output, outlen_words, NULL),
                 "shake256: error during KMAC squeeze");
}

/**
 * Variant of `shake256_inc_squeeze_once` that strictly requires its output
 * buffer to be 32b aligned.
 */
static void shake256_inc_squeeze_once_aligned(uint8_t *output, size_t outlen,
                                              shake256_inc_state_t *s_inc) {
  // `dif_kmac_squeeze()` provides output at the granularity of 32b words, not
  // bytes.
  size_t outlen_words = outlen / sizeof(uint32_t);
  if (outlen_words > 0) {
    shake256_inc_squeezeblocks((uint32_t *)output, outlen_words, s_inc);
    output += outlen_words * sizeof(uint32_t);
    outlen = outlen_words % sizeof(uint32_t);
  }

  // Squeeze remaining bytes (if any).
  if (outlen > 0) {
    uint32_t buf;
    shake256_inc_squeezeblocks(&buf, 1, s_inc);
    memcpy(output, &buf, outlen);
  }

  // XXX: this will not work for repeated squeezing! It just so happens that we
  // only ever squeeze once here.
  ABORT_IF_ERROR(dif_kmac_end(&s_inc->kmac, &s_inc->kmac_operation_state),
                 "shake256: error during KMAC end.");
}

void shake256_inc_squeeze_once(uint8_t *output, size_t outlen,
                               shake256_inc_state_t *s_inc) {
  if (misalignment32_of((uintptr_t)output) == 0) {
    // Output buffer is aligned; use it directly.
    shake256_inc_squeeze_once_aligned(output, outlen, s_inc);
  } else {
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

void shake256_setup(void) {
  if (kmac_shake256_configure() != kKmacErrorOk) {
    LOG_ERROR("Error during KMAC configuration.");
    abort();
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
void shake256(uint8_t *output, size_t outlen, const uint8_t *input,
              size_t inlen) {
  shake256_inc_state_t s_inc;
  shake256_inc_init(&s_inc);
  shake256_inc_absorb(&s_inc, input, inlen);
  shake256_inc_squeeze_once(output, outlen, &s_inc);
}
