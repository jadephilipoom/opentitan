#ifndef SPX_FIPS202_H
#define SPX_FIPS202_H

#include <stddef.h>
#include <stdint.h>

#include "sw/device/lib/dif/dif_kmac.h"

#define SHAKE256_RATE 136

typedef struct shake256_inc_state {
  dif_kmac_operation_state_t kmac_operation_state;
} shake256_inc_state_t;

// Call this once to set up the hardware for SHAKE-256.
void shake256_setup();

// Incremental hashing interface.
void shake256_inc_init(shake256_inc_state_t *s_inc);
void shake256_inc_absorb(shake256_inc_state_t *s_inc, const uint8_t *input, size_t inlen);
void shake256_inc_squeeze_once(uint8_t *output, size_t outlen, shake256_inc_state_t *s_inc);

// One-shot hashing interface.
void shake256(uint8_t *output, size_t outlen,
              const uint8_t *input, size_t inlen);

#endif
