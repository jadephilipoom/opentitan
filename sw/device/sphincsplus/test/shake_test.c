#include <stdint.h>
#include <string.h>

#include "../fips202.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

OTTF_DEFINE_TEST_CONFIG();

static const size_t kTestMessageLen = 13;
static const char kTestMessage[13] = "Test message!";
static const size_t kOutLen = 7;

bool test_main() {
  uint8_t output[kOutLen];
  shake256(output, kOutLen, (uint8_t *)kTestMessage, kTestMessageLen);
  for (size_t i = 0; i < kOutLen; i++) {
    LOG_INFO("out[%d] = 0x%02x", i, output[i]);
  }

  return true;
}
