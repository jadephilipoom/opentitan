#include <stdint.h>

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

bool test_main(void) {
  uint64_t t_start = profile_start();
  uint32_t cycles = profile_end(t_start);

  print_cycles("nothing", cycles);

  return true;
}
