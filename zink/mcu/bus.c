#include "bus.h"

/* ========================================================================= */
/*  INTERNAL FUNCTIONS                                                       */
/* ========================================================================= */

// True once bus_attach has claimed the pins (plain global: mpy_ld.py rejects static bss).
bool bus_attached;
// Hold time in loops, 0 means "use the default".
uint32_t bus_delay_loops;

// BUS_WAIT: hold the current pin levels for 'loops' loop iterations (loops must be >= 1).
// Always inlined and the count stays in a register, so the hot paths make no function
// calls and no memory accesses between two pin changes. One iteration is subs + a taken
// bne, about 3 cycles (20 ns at 150 MHz).
#ifdef BUS_HOST_TEST
    // Host test: let the simulated clock advance instead of spinning.
    #define BUS_WAIT(loops) bus_test_delay(loops)
#else
static inline __attribute__((always_inline)) void bus_wait(uint32_t loops) {
    // The asm volatile keeps -Os from deleting the loop.
    __asm__ volatile ("1: subs %0, %0, #1\n\tbne 1b" : "+r"(loops) : : "cc");
}
    #define BUS_WAIT(loops) bus_wait(loops)
#endif

// BUS_SPREAD: turn a byte into the GPIO bit pattern (D0..3 -> GPIO24..27, D4..7 -> GPIO0..3).
static inline __attribute__((always_inline)) uint32_t bus_spread(uint32_t byte) {
    // Low nibble goes to GPIO24..27, high nibble goes to GPIO0..3.
    return ((byte & 0x0Fu) << BUS_D_LO_SHIFT) | ((byte >> 4) & 0x0Fu);
}

// BUS_GATHER: turn a GPIO input snapshot back into a byte (inverse of bus_spread).
static inline __attribute__((always_inline)) uint32_t bus_gather(uint32_t gpio) {
    // GPIO24..27 are the low nibble, GPIO0..3 are the high nibble.
    return ((gpio >> BUS_D_LO_SHIFT) & 0x0Fu) | ((gpio & 0x0Fu) << 4);
}

// BUS_PUT_BYTE: drive one byte and give the FPGA one full link-clock cycle.
// Data settles for a half period, CLK rises (the FPGA samples), CLK falls.
// The next byte may be applied immediately after the fall.
static inline __attribute__((always_inline)) void bus_put_byte(uint32_t byte, uint32_t loops) {
    // GPIO pattern for this byte.
    uint32_t bits = bus_spread(byte);

    // Clear the data pins that must be low.
    reg_write(SIO_GPIO_OUT_CLR, BUS_DATA_MASK & ~bits);
    // Set the data pins that must be high.
    reg_write(SIO_GPIO_OUT_SET, bits);
    // Setup time before the rising edge.
    BUS_WAIT(loops);
    // CLK: low -> high (FPGA samples D here).
    reg_write(SIO_GPIO_OUT_SET, BUS_CLK_MASK);
    // Hold time while CLK is high.
    BUS_WAIT(loops);
    // CLK: high -> low.
    reg_write(SIO_GPIO_OUT_CLR, BUS_CLK_MASK);
}

// BUS_CLOCK_IN: one link-clock cycle where the FPGA drives D. Wait for the byte to
// settle, sample it just before the rising edge, then finish the cycle.
// If sample is false this is the turnaround clock and nothing is read.
static inline __attribute__((always_inline)) uint32_t bus_clock_in(bool sample, uint32_t loops) {
    // Byte read from the pins (stays 0 for the turnaround clock).
    uint32_t byte = 0u;

    // Low phase: the FPGA drives (or, on the turnaround clock, nobody drives).
    BUS_WAIT(loops);
    // Sample D just before the rising edge.
    if (sample) {
        byte = bus_gather(reg_read(SIO_GPIO_IN));
    }
    // CLK: low -> high.
    reg_write(SIO_GPIO_OUT_SET, BUS_CLK_MASK);
    // Hold time while CLK is high.
    BUS_WAIT(loops);
    // CLK: high -> low (the FPGA moves to the next byte here).
    reg_write(SIO_GPIO_OUT_CLR, BUS_CLK_MASK);

    // Return what was sampled.
    return byte;
}

// BUS_FRAME_BEGIN: CS_N low, take the data pins and send CMD + the 16-bit address.
static inline __attribute__((always_inline)) void bus_frame_begin(uint32_t cmd, uint32_t address, uint32_t loops) {
    // CS_N low starts the frame.
    reg_write(SIO_GPIO_OUT_CLR, BUS_CSN_MASK);
    // We drive the data pins during the header.
    reg_write(SIO_GPIO_OE_SET, BUS_DATA_MASK);
    // Byte 0: direction and byte count.
    bus_put_byte(cmd, loops);
    // Byte 1: address high.
    bus_put_byte((address >> 8) & 0xFFu, loops);
    // Byte 2: address low.
    bus_put_byte(address & 0xFFu, loops);
}

// BUS_FRAME_END: hold, then CS_N high and release the data pins.
// CS_N is held high for two half periods so the FPGA always sees the gap.
static inline __attribute__((always_inline)) void bus_frame_end(uint32_t loops) {
    // Let the last level settle.
    BUS_WAIT(loops);
    // CS_N high ends the frame (the FPGA also releases D now).
    reg_write(SIO_GPIO_OUT_SET, BUS_CSN_MASK);
    // We stop driving the data pins.
    reg_write(SIO_GPIO_OE_CLR, BUS_DATA_MASK);
    // Minimum CS_N-high time (two half periods).
    BUS_WAIT(loops);
    BUS_WAIT(loops);
}

// BUS_CHUNK_WRITE: one write frame of 1..BUS_MAX_BYTES bytes.
static void bus_chunk_write(uint32_t address, const uint8_t *src, uint32_t nbytes) {
    // Byte counter.
    uint32_t i;
    // Hold time, read once so the byte loop never touches memory for it.
    uint32_t loops = bus_get_delay();

    // Header: write command with (nbytes - 1) in the low bits.
    bus_frame_begin(nbytes - 1u, address, loops);
    // Send each byte; the FPGA auto-increments the address.
    for (i = 0; i < nbytes; i++) {
        bus_put_byte(src[i], loops);
    }
    // Close the frame.
    bus_frame_end(loops);
}

// BUS_CHUNK_READ: one read frame of 1..BUS_MAX_BYTES bytes.
static void bus_chunk_read(uint32_t address, uint8_t *dst, uint32_t nbytes) {
    // Byte counter.
    uint32_t i;
    // Hold time, read once so the byte loop never touches memory for it.
    uint32_t loops = bus_get_delay();

    // Header: read command with (nbytes - 1) in the low bits.
    bus_frame_begin(BUS_CMD_READ | (nbytes - 1u), address, loops);
    // Release the data pins right after the falling edge of the last header byte.
    reg_write(SIO_GPIO_OE_CLR, BUS_DATA_MASK);
    // Turnaround clock: nobody drives D, the FPGA starts driving after its falling edge.
    (void)bus_clock_in(false, loops);
    // Receive each byte.
    for (i = 0; i < nbytes; i++) {
        dst[i] = (uint8_t)bus_clock_in(true, loops);
    }
    // Close the frame.
    bus_frame_end(loops);
}

/* ========================================================================= */
/*  SETUP                                                                    */
/* ========================================================================= */

// BUS_ATTACH: setup required pins for RP2350 <-> FPGA communication.
void bus_attach(void) {
    // Pin number.
    uint32_t pin;

    // 1. Give every link pin to SIO and configure its pad. A whole-register
    // pad write also clears ISO, which is set out of reset and disconnects the pad.
    for (pin = 0; pin < 32u; pin++) {
        // Skip pins that are not part of the link.
        if (!((BUS_ALL_MASK >> pin) & 1u)) {
            continue;
        }

        // Route the pin to SIO so GPIO_OUT / OE / IN control it.
        reg_write(IO_BANK0_CTRL(pin), IO_FUNCSEL_SIO);

        // Data pins get a pull-down so they never float while nobody drives them.
        if ((BUS_DATA_MASK >> pin) & 1u) {
            reg_write(PADS_BANK0(pin), PAD_IE | PAD_DRIVE_4MA | PAD_SCHMITT | PAD_PDE);
        } else {
            reg_write(PADS_BANK0(pin), PAD_IE | PAD_DRIVE_4MA | PAD_SCHMITT);
        }
    }

    // 2. Park the bus: CLK low, CS_N high (set before OE so CS_N never glitches low).
    reg_write(SIO_GPIO_OUT_CLR, BUS_CLK_MASK);
    reg_write(SIO_GPIO_OUT_SET, BUS_CSN_MASK);
    reg_write(SIO_GPIO_OE_SET, BUS_CLK_MASK | BUS_CSN_MASK);
    reg_write(SIO_GPIO_OE_CLR, BUS_DATA_MASK);

    // 3. Flag bus is ready for transport.
    bus_attached = true;
}

// BUS_DETACH: If the user wants to let the data lines go, use this function.
void bus_detach(void) {
    // Stop driving the data pins.
    reg_write(SIO_GPIO_OE_CLR, BUS_DATA_MASK);
    // Leave the idle levels so the FPGA never sees a floating CS_N.
    reg_write(SIO_GPIO_OUT_CLR, BUS_CLK_MASK);
    reg_write(SIO_GPIO_OUT_SET, BUS_CSN_MASK);

    // Pins are no longer claimed.
    bus_attached = false;
}

// BUS_SET_DELAY: user can call this to set their own delay based on the FPGA frequency.
bool bus_set_delay(uint32_t loops) {
    // Reject values outside the allowed range.
    if (loops < BUS_DELAY_MIN || loops > BUS_DELAY_MAX) {
        return false;
    }

    // Store the new hold time.
    bus_delay_loops = loops;
    return true;
}

// BUS_GET_DELAY: read once per frame by the chunk functions. User can call to check for debugging.
uint32_t bus_get_delay(void) {
    // If the user does not specify a delay, use the default.
    if (bus_delay_loops == 0u) {
        return BUS_DELAY_DEFAULT;
    }

    return bus_delay_loops;
}

// BUS_READY: CDONE is high once the FPGA has been configured.
bool bus_ready(void) {
    // Read the pin level directly (works whatever function the pin is set to).
    return (reg_read(SIO_GPIO_IN) & BUS_CDONE_MASK) != 0u;
}

/* ========================================================================= */
/*  Write                                                                    */
/* ========================================================================= */

// WRITE: one 8-bit register.
void bus_write(uint32_t address, uint8_t value) {
    // 1. Attach/setup bus pins if needed.
    if (!bus_attached) {
        bus_attach();
    }

    // 2. One frame, one byte.
    bus_chunk_write(address, &value, 1u);
}

// WRITE_BLOCK: nbytes registers, address auto-increments by 1 per byte.
void bus_write_block(uint32_t address, const uint8_t *src, uint32_t nbytes) {
    // Bytes in this frame.
    uint32_t n;

    // 1. Attach/setup bus pins if needed.
    if (!bus_attached) {
        bus_attach();
    }

    // 2. One frame per BUS_MAX_BYTES bytes.
    while (nbytes > 0u) {
        // Largest frame the command byte can describe.
        n = (nbytes > BUS_MAX_BYTES) ? BUS_MAX_BYTES : nbytes;
        // Send the frame.
        bus_chunk_write(address, src, n);
        // Move on in the buffer, the address and the count.
        src += n;
        address += n;
        nbytes -= n;
    }
}

/* ========================================================================= */
/*  Read                                                                     */
/* ========================================================================= */

// READ: one 8-bit register.
uint8_t bus_read(uint32_t address) {
    // Receive buffer.
    uint8_t b;

    // 1. Attach/setup bus pins if needed.
    if (!bus_attached) {
        bus_attach();
    }

    // 2. One frame, one byte.
    bus_chunk_read(address, &b, 1u);

    return b;
}

// READ_BLOCK: nbytes registers, address auto-increments by 1 per byte.
void bus_read_block(uint32_t address, uint8_t *dst, uint32_t nbytes) {
    // Bytes in this frame.
    uint32_t n;

    // 1. Attach/setup bus pins if needed.
    if (!bus_attached) {
        bus_attach();
    }

    // 2. One frame per BUS_MAX_BYTES bytes.
    while (nbytes > 0u) {
        // Largest frame the command byte can describe.
        n = (nbytes > BUS_MAX_BYTES) ? BUS_MAX_BYTES : nbytes;
        // Receive the frame.
        bus_chunk_read(address, dst, n);
        // Move on in the buffer, the address and the count.
        dst += n;
        address += n;
        nbytes -= n;
    }
}

// LINK_OK: true when ID reads 0x5A and ID_INV reads its complement (one 2-byte frame).
bool bus_link_ok(void) {
    // ID then ID_INV.
    uint8_t id[2];

    // Read both in one burst.
    bus_read_block(BUS_ID_ADDRESS, id, 2u);

    return id[0] == BUS_ID_VALUE && id[1] == (uint8_t)~BUS_ID_VALUE;
}
