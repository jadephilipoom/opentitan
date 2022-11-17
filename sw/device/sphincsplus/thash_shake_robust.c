#include <stdint.h>
#include <string.h>

#include "address.h"
#include "fips202.h"
#include "params.h"
#include "thash.h"
#include "utils.h"

/**
 * Takes an array of inblocks concatenated arrays of SPX_N bytes.
 */
void thash(unsigned char *out, const unsigned char *in, unsigned int inblocks,
           const spx_ctx *ctx, uint32_t addr[8]) {
  uint8_t bitmask[inblocks * SPX_N];
  unsigned int i;
  shake256_inc_state_t s_inc;

  // Compute bitmask.
  shake256_inc_init(&s_inc);
  shake256_inc_absorb(&s_inc, ctx->pub_seed, SPX_N);
  shake256_inc_absorb(&s_inc, (unsigned char *)addr, SPX_ADDR_BYTES);
  shake256_inc_squeeze_once(bitmask, inblocks * SPX_N, &s_inc);

  for (i = 0; i < inblocks * SPX_N; i++) {
    bitmask[i] ^= in[i];
  }

  // Compute output.
  shake256_inc_init(&s_inc);
  shake256_inc_absorb(&s_inc, ctx->pub_seed, SPX_N);
  shake256_inc_absorb(&s_inc, (unsigned char *)addr, SPX_ADDR_BYTES);
  shake256_inc_absorb(&s_inc, bitmask, inblocks * SPX_N);
  shake256_inc_squeeze_once(out, SPX_N, &s_inc);
}
