#include <stdint.h>
#include <string.h>

#include "utils.h"
#include "thash.h"
#include "address.h"
#include "params.h"

#include "fips202.h"

/**
 * Takes an array of inblocks concatenated arrays of SPX_N bytes.
 */
void thash(unsigned char *out, const unsigned char *in, unsigned int inblocks,
           const spx_ctx *ctx, uint32_t addr[8])
{
    shake256_inc_state_t s_inc;
    shake256_inc_init(&s_inc);
    shake256_inc_absorb(&s_inc, ctx->pub_seed, SPX_N);
    shake256_inc_absorb(&s_inc, (unsigned char *)addr, SPX_ADDR_BYTES);
    shake256_inc_absorb(&s_inc, in, inblocks * SPX_N);
    shake256_inc_squeeze_once(out, SPX_N, &s_inc);
}
