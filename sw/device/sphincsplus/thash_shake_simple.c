#include <stdint.h>
#include <string.h>

#include "utils.h"
#include "thash.h"
#include "address.h"
#include "params.h"

#include "sw/device/lib/runtime/ibex.h" // TODO: remove, for profiling
#include "sw/device/lib/runtime/log.h" // TODO: remove, for profiling
#include "fips202.h"


/**
 * Start a cycle-count timing profile.
 */
static uint64_t profile_start() { return ibex_mcycle_read(); }

/**
 * End a cycle-count timing profile.
 *
 * Call `profile_start()` first.
 */
static uint32_t profile_end(uint64_t t_start) {
  uint64_t t_end = ibex_mcycle_read();
  uint64_t cycles = t_end - t_start;
  return (uint32_t)cycles;
}
/**
 * Takes an array of inblocks concatenated arrays of SPX_N bytes.
 */
void thash(unsigned char *out, const unsigned char *in, unsigned int inblocks,
           const spx_ctx *ctx, uint32_t addr[8])
{
    shake256_inc_state_t s_inc;
    shake256_inc_init(&s_inc);
    shake256_inc_absorb(&s_inc, ctx->pub_seed, SPX_N);
    shake256_inc_absorb(&s_inc, (const unsigned char *)addr, SPX_ADDR_BYTES);
    shake256_inc_absorb(&s_inc, in, inblocks * SPX_N);
    shake256_inc_squeeze_once(out, SPX_N, &s_inc);
}
