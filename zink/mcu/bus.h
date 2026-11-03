#ifndef ZEN_LINK_BUS_H
#define ZEN_LINK_BUS_H

#include <stdbool.h>
#include <stdint.h>

/* ========================================================================= */
/*  The pins                                                                 */
/* ========================================================================= */

// Zen Link, RP2350B side. Pin table: zen/assets/docs/zen_link_pinouts.png
// D0..D3 are GPIO24..27 (contiguous) and D4..D7 are GPIO0..3 (contiguous), so a
// byte is two masked writes and never needs a per-bit loop.
//
//   D0 GPIO24 (GPIOL_00, G5)   D4 GPIO0 (GPIOL_04, F4)   CLK  GPIO28 (GPIOL_08, J2)
//   D1 GPIO25 (GPIOL_03, G4)   D5 GPIO1 (GPIOL_02, H4)   CS_N GPIO29 (GPIOL_10, H2)
//   D2 GPIO26 (GPIOL_05, J3)   D6 GPIO2 (GPIOL_01, J4)
//   D3 GPIO27 (GPIOL_07, G3)   D7 GPIO3 (GPIOL_06, H3)
//
// GPIO0..3 are also the FPGA's SPI configuration pins; they only become link
// pins once the FPGA is configured (CDONE = GPIO4 high).
#define BUS_D_LO_SHIFT      (24u)
#define BUS_D_LO_MASK       (0x0Fu << BUS_D_LO_SHIFT)   // D0..D3
#define BUS_D_HI_MASK       (0x0Fu)                     // D4..D7
#define BUS_DATA_MASK       (BUS_D_LO_MASK | BUS_D_HI_MASK)

#define BUS_CLK_PIN         (28u)
#define BUS_CSN_PIN         (29u)
#define BUS_CDONE_PIN       (4u)

#define BUS_CLK_MASK        (1u << BUS_CLK_PIN)
#define BUS_CSN_MASK        (1u << BUS_CSN_PIN)
#define BUS_CDONE_MASK      (1u << BUS_CDONE_PIN)

// Every pin this module drives, and nothing else is ever driven.
// CDONE is only read, never driven, so it is not in this mask.
#define BUS_ALL_MASK        (BUS_DATA_MASK | BUS_CLK_MASK | BUS_CSN_MASK)

/* ========================================================================= */
/*  The protocol                                                             */
/* ========================================================================= */

#define BUS_CMD_READ        (0x80u)  // CMD bit 7: 1 = read, 0 = write
#define BUS_MAX_BYTES       (128u)   // CMD[6:0] holds bytes-1, so 128 per frame
#define BUS_ADDR_MAX        (0xFFFFu) // 16-bit address, registers are 8 bits wide

// Register 0 of the FPGA reads back this value, register 1 its complement.
#define BUS_ID_ADDRESS      (0x0000u)
#define BUS_ID_VALUE        (0x5Au)

/* ========================================================================= */
/*  How long to hold each level                                              */
/* ========================================================================= */

// Loops held per half link-clock. One loop is subs + a taken bne, about 3 cycles
// (20 ns at the default 150 MHz); the half period is about 3*loops + 3 cycles
// (~20 ns * loops + 20 ns). The FPGA wants a half period of at least 6.5 of its own
// clocks: with the 50 MHz fabric clock that is 130 ns, so 6 loops (~140 ns) is the
// fastest in-spec setting. Measured on the Zen board (stress.py): 0 errors from 20
// down to 4 loops (3.65 MB/s read at 4), and errors at 3 loops, so the real edge sits
// between 80 and 100 ns. The default of 8 loops (~180 ns, about 2x the failing half
// period) gives 2.3 MB/s with margin for temperature, voltage and board variation.
// Too long is always safe, too short drops bytes.
#define BUS_DELAY_DEFAULT   (8u)
#define BUS_DELAY_MIN       (1u)
#define BUS_DELAY_MAX       (100000u)

/* ========================================================================= */
/*  RP2350 registers                                                         */
/* ========================================================================= */

// NOTE: every address and bit below was checked against pico-sdk
// (src/rp2350/hardware_regs/include/hardware/regs/{sio,io_bank0,pads_bank0}.h).
// NOTE: the RP2350 SIO layout is not the RP2040 one, offsets differ.
// GPIO0..31 are all reachable through the low SIO registers, which is every pin we use.

#define SIO_BASE            (0xd0000000u)

#define SIO_GPIO_IN         (SIO_BASE + 0x004u) // the level on each pin
#define SIO_GPIO_OUT        (SIO_BASE + 0x010u) // the level we drive
#define SIO_GPIO_OUT_SET    (SIO_BASE + 0x018u) // drive these pins high
#define SIO_GPIO_OUT_CLR    (SIO_BASE + 0x020u) // drive these pins low
#define SIO_GPIO_OE         (SIO_BASE + 0x030u) // which pins we drive at all
#define SIO_GPIO_OE_SET     (SIO_BASE + 0x038u) // start driving these pins
#define SIO_GPIO_OE_CLR     (SIO_BASE + 0x040u) // stop driving these pins

#define IO_BANK0_BASE       (0x40028000u)

// One control register per pin: GPIO0 at +0x004, then every 8 bytes.
#define IO_BANK0_CTRL(pin) (IO_BANK0_BASE + 0x004u + 0x008u * (uint32_t)(pin))

// Function 5 is SIO on every GPIO, so GPIO_OUT / OE / IN control the pin.
#define IO_FUNCSEL_SIO      (5u)

#define PADS_BANK0_BASE     (0x40038000u)

// One pad register per pin: GPIO0 at +0x004, then every 4 bytes.
#define PADS_BANK0(pin)     (PADS_BANK0_BASE + 0x004u + 0x004u * (uint32_t)(pin))

#define PAD_ISO             (1u << 8) // pad disconnected, SET out of reset
#define PAD_IE              (1u << 6) // input enable
#define PAD_DRIVE_4MA       (1u << 4) // drive strength, bits 5..4 (0=2, 1=4, 2=8, 3=12 mA)
#define PAD_PDE             (1u << 2) // pull-down enable
#define PAD_SCHMITT         (1u << 1) // schmitt trigger on the input

#ifdef BUS_HOST_TEST
    // NOTE: REG_READ / REG_WRITE: the only way this module touches hardware.
    // Functions not macros, so the host test can swap in its own GPIO model.
    // bus_test_delay replaces the busy loop so the host model can advance time.
    // On the board they compile to a single load or store.

    uint32_t bus_test_reg_read(uint32_t address);
    void bus_test_reg_write(uint32_t address, uint32_t value);
    void bus_test_delay(uint32_t loops);

    static inline uint32_t reg_read(uint32_t address) {
        return bus_test_reg_read(address);
    }

    static inline void reg_write(uint32_t address, uint32_t value) {
        bus_test_reg_write(address, value);
    }

#else

    static inline uint32_t reg_read(uint32_t address) {
        return *(volatile uint32_t *)(uintptr_t)address;
    }

    static inline void reg_write(uint32_t address, uint32_t value) {
        *(volatile uint32_t *)(uintptr_t)address = value;
    }

#endif

/* ========================================================================= */
/*  Functions                                                                */
/* ========================================================================= */

// True once the pins are claimed. Read it, do not write it.
// A plain global because mpy_ld.py rejects static bss, so a getter guards nothing.
extern bool bus_attached;

// BUS_ATTACH: claim the 10 link pins and park the bus (CLK low, CS_N high, D released).
// Called automatically on first use, so only call it directly to pick the moment.
void bus_attach(void);

// BUS_DETACH: let go of the data lines and leave CLK low and CS_N high.
void bus_detach(void);

// BUS_SET_DELAY: set the hold time in loops. Returns false, and changes
// nothing, if the value is outside BUS_DELAY_MIN..BUS_DELAY_MAX.
bool bus_set_delay(uint32_t loops);

// BUS_GET_DELAY: the hold time in use, or the default if none was set.
uint32_t bus_get_delay(void);

// BUS_READY: true when the FPGA reports configuration done (CDONE, GPIO4).
bool bus_ready(void);

// BUS_LINK_OK: true when registers 0 and 1 read back the Zen Link ID.
bool bus_link_ok(void);

// WRITE: send an 8-bit value to the register at an address.
void bus_write(uint32_t address, uint8_t value);

// READ: fetch the 8-bit register at an address.
uint8_t bus_read(uint32_t address);

// WRITE_BLOCK: write nbytes consecutive registers from src.
// Splits into frames of at most BUS_MAX_BYTES bytes.
void bus_write_block(uint32_t address, const uint8_t *src, uint32_t nbytes);

// READ_BLOCK: read nbytes consecutive registers into dst.
// Splits into frames of at most BUS_MAX_BYTES bytes.
void bus_read_block(uint32_t address, uint8_t *dst, uint32_t nbytes);

#endif /* ZEN_LINK_BUS_H */
