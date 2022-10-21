// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/abs_mmio.h"
#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/csr.h"
#include "sw/device/lib/base/hardened.h"
#include "sw/device/silicon_creator/lib/drivers/otp.h"
#include "sw/device/silicon_creator/lib/manifest_def.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "otp_ctrl_regs.h"
#include "pinmux_regs.h"
#include "uart_regs.h"

enum {
  /**
   * Base address of the pinmux registers.
   */
  kPinmuxBase = TOP_EARLGREY_PINMUX_AON_BASE_ADDR,
  /**
   * Base address of the UART registers.
   */
  kUartBase = TOP_EARLGREY_UART0_BASE_ADDR,
};

/**
 * Triggers an instruction access fault.
 */
static void fault(void) {
  ((void (*)(void))TOP_EARLGREY_SRAM_CTRL_MAIN_RAM_BASE_ADDR)();
}

/**
 * Triggers an instruction access fault if the condition is not true.
 */
#define CHECK(condition) \
  do {                   \
    if (!(condition)) {  \
      fault();           \
    }                    \
  } while (false)

/**
 * Check that the pinmux has been initialized correctly.
 *
 * Expected configuration:
 * - If the OTP BOOTSTRAP_EN option is set, then pinmux should be configured
 *   with the following peripheral/pad mapping, with pull-down enabled for all
 *   pads:
 *     * GPIO22 -> IOC0
 *     * GPIO23 -> IOC1
 *     * GPIO24 -> IOC2
 * - Regardless of the OTP values, the pinmux should be configured with the
 *   following mapping for UART0:
 *     * UART RX -> IOC3
 *     * IOC4 -> UART TX (output)
 */
static void pinmux_init_test(void) {
  uint32_t bootstrap_en =
      otp_read32(OTP_CTRL_PARAM_OWNER_SW_CFG_ROM_BOOTSTRAP_EN_OFFSET);
  if (bootstrap_en == kHardenedBoolTrue) {
    // GPIO 22 (input 22) -> IOC0 (MIO pad 22), pad attributes: pull-down
    // enabled
    uint32_t insel_gpio22 =
        abs_mmio_read32(kPinmuxBase + PINMUX_MIO_PERIPH_INSEL_22_REG_OFFSET);
    CHECK(insel_gpio22 == kTopEarlgreyPinmuxInselIoc0);
    uint32_t attr22 =
        abs_mmio_read32(kPinmuxBase + PINMUX_MIO_PAD_ATTR_22_REG_OFFSET);
    // TODO: why is this attribute not legal on FPGA?
    // CHECK(bitfield_bit32_read(attr22, PINMUX_MIO_PAD_ATTR_22_PULL_EN_22_BIT)
    // == true);
    CHECK(bitfield_bit32_read(
              attr22, PINMUX_MIO_PAD_ATTR_22_PULL_SELECT_22_BIT) == false);

    // GPIO 23 (input 23) -> IOC1 (MIO pad 23), pad attributes: pull-down
    // enabled
    uint32_t insel_gpio23 =
        abs_mmio_read32(kPinmuxBase + PINMUX_MIO_PERIPH_INSEL_23_REG_OFFSET);
    CHECK(insel_gpio23 == kTopEarlgreyPinmuxInselIoc1);
    uint32_t attr23 =
        abs_mmio_read32(kPinmuxBase + PINMUX_MIO_PAD_ATTR_23_REG_OFFSET);
    // TODO: why is this attribute not legal on FPGA?
    // CHECK(bitfield_bit32_read(attr23, PINMUX_MIO_PAD_ATTR_23_PULL_EN_23_BIT)
    // == true);
    CHECK(bitfield_bit32_read(
              attr23, PINMUX_MIO_PAD_ATTR_23_PULL_SELECT_23_BIT) == false);

    // GPIO 24 (input 24) -> IOC2 (MIO pad 24), pad attributes: pull-down
    // enabled
    uint32_t insel_gpio24 =
        abs_mmio_read32(kPinmuxBase + PINMUX_MIO_PERIPH_INSEL_24_REG_OFFSET);
    CHECK(insel_gpio24 == kTopEarlgreyPinmuxInselIoc2);
    uint32_t attr24 =
        abs_mmio_read32(kPinmuxBase + PINMUX_MIO_PAD_ATTR_24_REG_OFFSET);
    // TODO: why is this attribute not legal on FPGA?
    // CHECK(bitfield_bit32_read(attr24, PINMUX_MIO_PAD_ATTR_24_PULL_EN_24_BIT)
    // == true);
    CHECK(bitfield_bit32_read(
              attr24, PINMUX_MIO_PAD_ATTR_24_PULL_SELECT_24_BIT) == false);

    // TODO: this checks legal bits, failing if the pull_en is legal
    abs_mmio_write32(kPinmuxBase + PINMUX_MIO_PAD_ATTR_22_REG_OFFSET,
                     UINT32_MAX);
    uint32_t legal22 =
        abs_mmio_read32(kPinmuxBase + PINMUX_MIO_PAD_ATTR_22_REG_OFFSET);
    CHECK(legal22 == 3);
  }
  // UART RX (input 42) -> IOC3 (MIO pad 25)
  uint32_t insel_uartrx =
      abs_mmio_read32(kPinmuxBase + PINMUX_MIO_PERIPH_INSEL_42_REG_OFFSET);
  CHECK(insel_uartrx == kTopEarlgreyPinmuxInselIoc3);

  // IOC4 (MIO pad 26) -> UART TX (output 42)
  uint32_t outsel_ioc4 =
      abs_mmio_read32(kPinmuxBase + PINMUX_MIO_OUTSEL_26_REG_OFFSET);
  CHECK(outsel_ioc4 == kTopEarlgreyPinmuxOutselUart0Tx);
}

/**
 * Check that the UART has been initialized correctly.
 *
 * Expected configuration:
 * - `CTRL.TX` (TX enable) bit is true
 * - `CTRL.RX` (RX enable) bit is false
 * - `CTRL.SLPBK` (system loopback) bit is false
 * - `CTRL.LLPBK` (line loopback) bit is false
 * - `CTRL.NCO` is set to the precomputed `kUartNCOValue` for this device
 * - `CTRL.PARITY_EN` (parity enable) bit is false
 * - All interrupts are disabled
 * - All FIFOs have been cleared (both Rx and Tx are empty)
 */
static void uart_init_test(void) {
  // Check the control register values.
  uint32_t ctrl = abs_mmio_read32(kUartBase + UART_CTRL_REG_OFFSET);
  CHECK(bitfield_bit32_read(ctrl, UART_CTRL_TX_BIT) == true);
  CHECK(bitfield_bit32_read(ctrl, UART_CTRL_RX_BIT) == false);
  CHECK(bitfield_bit32_read(ctrl, UART_CTRL_SLPBK_BIT) == false);
  CHECK(bitfield_bit32_read(ctrl, UART_CTRL_LLPBK_BIT) == false);
  CHECK(bitfield_field32_read(ctrl, UART_CTRL_NCO_FIELD) == kUartNCOValue);
  CHECK(bitfield_bit32_read(ctrl, UART_CTRL_PARITY_EN_BIT) == false);

  // Check that all interrupts are disabled.
  uint32_t intr_enable =
      abs_mmio_read32(kUartBase + UART_INTR_ENABLE_REG_OFFSET);
  CHECK(intr_enable == 0x0);

  // Check that both FIFOs are idle and empty.
  uint32_t status = abs_mmio_read32(kUartBase + UART_STATUS_REG_OFFSET);
  CHECK(bitfield_bit32_read(status, UART_STATUS_TXIDLE_BIT) == true);
  CHECK(bitfield_bit32_read(status, UART_STATUS_RXIDLE_BIT) == true);
  CHECK(bitfield_bit32_read(status, UART_STATUS_TXEMPTY_BIT) == true);
  CHECK(bitfield_bit32_read(status, UART_STATUS_RXEMPTY_BIT) == true);
}

/**
 * Check that the CPUCTRL CSR has been initialized correctly.
 *
 * Expected configuration:
 * - Bits 0:5 of the CPUCTRL CSR should match the value specified in OTP.
 */
static void cpuctrl_init_test(void) {
  uint32_t expected_value =
      otp_read32(OTP_CTRL_PARAM_CREATOR_SW_CFG_CPUCTRL_OFFSET);
  bitfield_field32_t cpuctrl_mask = {.mask = 0x3f, .index = 0};
  uint32_t cpuctrl_csr;
  CSR_READ(CSR_REG_CPUCTRL, &cpuctrl_csr);
  CHECK(bitfield_field32_read(cpuctrl_csr, cpuctrl_mask) == expected_value);
}

/**
 * Test entrypoint.
 *
 * Because this function becomes the entrypoint for the manifest, it must be
 * word-aligned, otherwise it will trigger a `kManifestBadEntryPoint` boot
 * fault.
 */
void __attribute__((aligned(4))) _ottf_start(void) {
  pinmux_init_test();
  uart_init_test();
  cpuctrl_init_test();
}
