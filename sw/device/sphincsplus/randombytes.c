/*
This code was taken from the SPHINCS reference implementation and is public domain.
*/

#include "randombytes.h"

#include "sw/device/lib/dif/dif_rv_core_ibex.h"
#include "sw/device/lib/runtime/ibex.h"

// N.B. As currently implemented, `abort()` will just wait for an interrupt and
// eventually time out.
#define CHECK(cond) \
  do {              \
    if (!cond) {    \
      abort();      \
    }               \
  } while (false)

/* Adapted from rv_core_ibx_testutils.c */
static bool is_rnd_data_valid(const dif_rv_core_ibex_t *rv_core_ibex) {
  dif_rv_core_ibex_rnd_status_t rnd_status;
  CHECK(dif_rv_core_ibex_get_rnd_status(rv_core_ibex, &rnd_status) == kDifOk);
  return rnd_status & kDifRvCoreIbexRndStatusValid;
}

/* Adapted from rv_core_ibx_testutils.c */
static void read_rnd_data(const dif_rv_core_ibex_t *rv_core_ibex, uint32_t *rnd_data) {
  while (!is_rnd_data_valid(rv_core_ibex)) {
    // Spin until rnd is valid.
  }

  CHECK(dif_rv_core_ibex_read_rnd_data(rv_core_ibex, rnd_data) == kDifOk);
}

void randombytes(unsigned char *x, unsigned long xlen)
{

    // Initialize Ibex. It is OK to do this several times (it just records the
    // base address passed to it).
    dif_rv_core_ibex_t rv_core_ibex;
    CHECK_DIF_OK(dif_rv_core_ibex_init(
          mmio_region_from_addr(TOP_EARLGREY_RV_CORE_IBEX_CFG_BASE_ADDR),
          &rv_core_ibex));

    // If x is not word-aligned, write some random bytes until it is.
    size_t offset = x % sizeof(uint32_t);
    if (offset != 0) {
      uint32_t rnd_data;
      read_rnd_data(&rv_core_ibex, &rnd_data);
      for (size_t i = 0; i < sizeof(uint32_t) - offset; i++) {
        x[i] = (uint8_t) (rnd_data & 255);
        rnd_data >>= 8;
        xlen--;
      }
    }

    size_t nwords = xlen / sizeof(uint32_t);
    for (size_t i = 0; i < nwords; i++) {
      // Read 32 bits of randomness and store in the result buffer.
      read_rnd_data(&rv_core_ibex, x);
      xlen -= sizeof(uint32_t);
    }

    if (xlen > 0) {
      // There is a non-full-word amount of bytes remaining; write these
      // byte-by-byte.
      uint32_t rnd_data;
      read_rnd_data(&rv_core_ibex, &rnd_data);
      for (size_t i = 0; i < sizeof(uint32_t) - offset; i++) {
        x[i] = (uint8_t) (rnd_data & 255);
        rnd_data >>= 8;
      }
    }
}
