#include <stdint.h>
#include <string.h>

#include "../fips202.h"
#include "sw/device/lib/base/macros.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

OTTF_DEFINE_TEST_CONFIG();

typedef struct shake256_test {
  size_t message_len;
  char *message;
  size_t output_len;
  const uint32_t *exp_output;
} shake256_test_t;

static const uint32_t exp_output_test0[8] = {
    0x84f1c984, 0x7a0316bb, 0xe404cfed, 0x83f9078a,
    0x21491adc, 0xd6c30988, 0xc6822ff6, 0x20b73405,
};
static const shake256_test_t kTests[1] = {
    // Simple test with short input.
    {
        .message_len = 13,
        .message = "Test message!",
        .output_len = 8,
        .exp_output = exp_output_test0,
    }};

static void run_test(const shake256_test_t *test) {
  uint32_t output[test->output_len];
  shake256((uint8_t *)output, test->output_len * sizeof(uint32_t),
           (uint8_t *)test->message, test->message_len);
  CHECK_ARRAYS_EQ(output, test->exp_output, test->output_len);
}

bool test_main() {
  shake256_setup();
  for (size_t i = 0; i < ARRAYSIZE(kTests); i++) {
    run_test(&kTests[i]);
  }

  return true;
}
