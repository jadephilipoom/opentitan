#include <stdint.h>

#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/csr.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/print.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

OTTF_DEFINE_TEST_CONFIG();

/**
 * Start a cycle-count timing profile.
 */
static __attribute__((noinline)) uint64_t profile_start() {
  return ibex_mcycle_read();
}

/**
 * End a cycle-count timing profile.
 *
 * Call `profile_start()` first.
 */
static __attribute__((noinline)) uint32_t profile_end(uint64_t t_start) {
  uint64_t t_end = ibex_mcycle_read();
  uint64_t cycles = t_end - t_start;
  return (uint32_t)cycles;
}

/**
 * Custom noinline function instead of LOG_INFO to prevent printing from being
 * inlined/reordered with other instructions.
 */
static __attribute__((noinline)) void print_cycles(const char *name, const uint32_t cycles) {
  base_printf("  %s took %u cycles\n", name, cycles);
}

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

  uint64_t t_start = profile_start();
  uint32_t cycles = profile_end(t_start);

  print_cycles("nothing", cycles);

  return true;
}
