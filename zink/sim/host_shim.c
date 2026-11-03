/* host_shim.c - lets Python (ctypes) supply the hardware hooks bus.c needs when it is
 * built with -DBUS_HOST_TEST: register read/write and the delay.
 * Python registers three callbacks once; bus.c then calls straight through to them,
 * so the real driver code runs against the simulated FPGA pins. */
#include <stdint.h>

/* Callback for a register read. */
static uint32_t (*cb_read)(uint32_t);
/* Callback for a register write. */
static void (*cb_write)(uint32_t, uint32_t);
/* Callback for the hold-time delay (argument = loops). */
static void (*cb_delay)(uint32_t);

/* SHIM_SET_CALLBACKS: called once from Python before any bus_* function. */
void shim_set_callbacks(uint32_t (*r)(uint32_t), void (*w)(uint32_t, uint32_t), void (*d)(uint32_t)) {
    cb_read = r;
    cb_write = w;
    cb_delay = d;
}

/* The three hooks declared in bus.h under BUS_HOST_TEST. */
uint32_t bus_test_reg_read(uint32_t address) { return cb_read(address); }
void bus_test_reg_write(uint32_t address, uint32_t value) { cb_write(address, value); }
void bus_test_delay(uint32_t loops) { cb_delay(loops); }
