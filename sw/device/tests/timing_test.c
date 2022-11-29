#include <stdint.h>

#include "sw/device/lib/base/hardened.h"
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

static __attribute__((noinline)) uint32_t add_test(const uint32_t a, const uint32_t b, uint32_t *res) {
  uint64_t t_start = profile_start();
  *res = a + b;
  return launder32(profile_end(t_start));
}

static __attribute__((noinline)) void print_cycles(const char *name, const uint32_t cycles) {
  base_printf("  %s took %u cycles\n", name, cycles);
}

bool test_main() {
  uint32_t a = launder32(5678);
  uint32_t b = launder32(1234);
  barrier32(a);
  barrier32(b);

  uint32_t sum;
  uint32_t add_cycles = add_test(a, b, &sum);

  uint64_t rem;
  udiv64_slow(a, b, &rem);

  print_cycles("add", add_cycles);

  return true;
}
