#ifndef SPX_FIPS202_H
#define SPX_FIPS202_H

#include <stddef.h>
#include <stdint.h>

#define SHAKE256_RATE 136

void shake256_absorb(uint64_t *s, const uint8_t *input, size_t inlen);
void shake256_squeezeblocks(uint8_t *output, size_t nblocks, uint64_t *s);

void shake256_inc_init(uint64_t *s_inc);
void shake256_inc_absorb(uint64_t *s_inc, const uint8_t *input, size_t inlen);
void shake256_inc_finalize(uint64_t *s_inc);
void shake256_inc_squeeze(uint8_t *output, size_t outlen, uint64_t *s_inc);

void shake256(uint8_t *output, size_t outlen,
              const uint8_t *input, size_t inlen);

#endif
