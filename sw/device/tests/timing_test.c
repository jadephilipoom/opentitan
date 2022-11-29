#include <stdint.h>

#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/csr.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/print.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

OTTF_DEFINE_TEST_CONFIG();

static __attribute__((noinline)) uint64_t mcycle_read() {
  return ibex_mcycle_read();
}

/**
 * Custom noinline function instead of LOG_INFO to prevent printing from being
 * inlined/reordered with other instructions.
 */
static __attribute__((noinline)) void print_cycles(const uint64_t cycles) {
  CHECK(cycles <= UINT32_MAX);
  base_printf("  %u cycles\n", (uint32_t) cycles);
}

/**
 * Disable instruction cache to prevent timing interference from setup.
 */
static __attribute__((noinline)) void disable_icache(void) {
  uint32_t cpuctrl;
  CSR_READ(CSR_REG_CPUCTRL, &cpuctrl);
  CSR_WRITE(CSR_REG_CPUCTRL, 0x7C0);
  // Instruction cache enable is bit 0 of CPUCTRL CSR:
  // https://ibex-core.readthedocs.io/en/latest/03_reference/cs_registers.html
  cpuctrl = bitfield_bit32_write(cpuctrl, 0, 0);
  CSR_WRITE(CSR_REG_CPUCTRL, cpuctrl);
}

bool test_main(void) {
  disable_icache();

  uint64_t t_start = mcycle_read();
  uint64_t t_end = mcycle_read();
  uint64_t cycles = t_end - t_start;

  print_cycles(cycles);

  return true;
}
