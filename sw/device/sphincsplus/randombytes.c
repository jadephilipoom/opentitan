/*
This code was taken from the SPHINCS reference implementation and is public domain.
*/

#include "randombytes.h"

#include "sw/device/lib/base/hardened.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/crypto/drivers/entropy.h"

void randombytes(unsigned char *x, unsigned long xlen)
{
  // Empty CSRNG seed material; we are not providing additional seed material
  // to CSRNG here.
  entropy_seed_material_t empty_seed = {
    .len = 0,
    .data = {0},
  }

  // If x is not word-aligned, write random bytes until it is.
  size_t offset = x % sizeof(uint32_t);
  if (offset != 0) {
    uint32_t rnd_data;
    // Note: CSRNG must be initialized before now.
    if (!status_ok(entropy_csrng_generate(&empty_seed, &rnd_data, 1))) {
      abort();
    }
    size_t nbytes = sizeof(uint32_t) - offset;
    memcpy(x, &rnd_data, nbytes);
    xlen -= nbytes;
  }

  // Write all the full words that will fit to the output buffer.
  size_t nwords = xlen / sizeof(uint32_t);
  status_t status = entropy_csrng_generate(&empty_seed, (uint32_t *)x, nwords);
  if (!status_ok(status)) {
    abort();
  }
  xlen -= nwords * sizeof(uint32_t);

  // Write any remaining bytes.
  if (xlen > 0) {
    uint32_t rnd_data;
    if (!status_ok(entropy_csrng_generate(&empty_seed, &rnd_data, 1))) {
      abort();
    }
    memcpy(x, &rnd_data, xlen);
  }
}
