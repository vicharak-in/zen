// This is the micropython wrapper for the bus.h header file
#include "py/dynruntime.h"

#include "bus.h"


/* ========================================================================= */
/*  INTERNAL                                                                 */
/* ========================================================================= */

// fpga.FPGAError, raised when the bus cannot do what was asked.
// Not static: mpy_ld.py rejects static bss, same rule as the globals in bus.c.
mp_obj_full_type_t fpga_error_type;

// ARG_TO_U32: turn a python int into a non-negative integer.
// A negative number is a mistake, so report it as a ValueError.
// Note: anything that is not an int raises TypeError from micropython below.
static uint32_t arg_to_u32(mp_obj_t obj) {
    if (mp_obj_get_int(obj) < 0) {
        mp_raise_ValueError("values must not be negative");
    }

    return (uint32_t)mp_obj_get_int_truncated(obj);
}

// ARG_TO_ADDR: a register address, 16 bits.
static uint32_t arg_to_addr(mp_obj_t obj) {
    uint32_t address = arg_to_u32(obj);

    if (address > BUS_ADDR_MAX) {
        mp_raise_ValueError("address must be 0..0xFFFF");
    }

    return address;
}

// ARG_TO_BYTE: a register value, 8 bits.
static uint8_t arg_to_byte(mp_obj_t obj) {
    uint32_t value = arg_to_u32(obj);

    if (value > 0xFFu) {
        mp_raise_ValueError("value must be 0..255");
    }

    return (uint8_t)value;
}

// CHECK_BLOCK: a block must be non-empty and stay inside the 64 KB register space.
static uint32_t check_block(uint32_t address, size_t len) {
    if (len == 0u || (uint32_t)len > 0x10000u - address) {
        mp_raise_ValueError("empty buffer, or block runs past the end of the address space");
    }

    return (uint32_t)len;
}

/* ========================================================================= */
/*  PYTHON FUNCTIONS                                                         */
/* ========================================================================= */

// WRITE: fpga.write(address, value) -> None
static mp_obj_t fpga_write(mp_obj_t address_in, mp_obj_t value_in) {
    uint32_t address = arg_to_addr(address_in);
    uint8_t value = arg_to_byte(value_in);

    bus_write(address, value);

    return mp_const_none;
}
static MP_DEFINE_CONST_FUN_OBJ_2(fpga_write_obj, fpga_write);

// READ: fpga.read(address) -> int
static mp_obj_t fpga_read(mp_obj_t address_in) {
    uint32_t address = arg_to_addr(address_in);

    return MP_OBJ_NEW_SMALL_INT(bus_read(address));
}
static MP_DEFINE_CONST_FUN_OBJ_1(fpga_read_obj, fpga_read);

// WRITE_BLOCK: fpga.write_block(address, buf) -> None
// buf is any bytes-like object (bytes, bytearray, ...). The address auto-increments
// by 1 per byte.
static mp_obj_t fpga_write_block(mp_obj_t address_in, mp_obj_t buf_in) {
    uint32_t address = arg_to_addr(address_in);
    mp_buffer_info_t bufinfo;
    uint32_t nbytes;

    mp_get_buffer_raise(buf_in, &bufinfo, MP_BUFFER_READ);
    nbytes = check_block(address, bufinfo.len);

    bus_write_block(address, (const uint8_t *)bufinfo.buf, nbytes);

    return mp_const_none;
}
static MP_DEFINE_CONST_FUN_OBJ_2(fpga_write_block_obj, fpga_write_block);

// READ_BLOCK: fpga.read_block(address, buf) -> None
// Fills a writable buffer (e.g. bytearray(16)) with consecutive registers.
static mp_obj_t fpga_read_block(mp_obj_t address_in, mp_obj_t buf_in) {
    uint32_t address = arg_to_addr(address_in);
    mp_buffer_info_t bufinfo;
    uint32_t nbytes;

    mp_get_buffer_raise(buf_in, &bufinfo, MP_BUFFER_WRITE);
    nbytes = check_block(address, bufinfo.len);

    bus_read_block(address, (uint8_t *)bufinfo.buf, nbytes);

    return mp_const_none;
}
static MP_DEFINE_CONST_FUN_OBJ_2(fpga_read_block_obj, fpga_read_block);

// INIT: fpga.init() -> None
// Note: the pins are claimed on first use anyway, this only picks the moment.
static mp_obj_t fpga_init(void) {
    bus_attach();

    return mp_const_none;
}
static MP_DEFINE_CONST_FUN_OBJ_0(fpga_init_obj, fpga_init);

// DEINIT: fpga.deinit() -> None
static mp_obj_t fpga_deinit(void) {
    bus_detach();

    return mp_const_none;
}
static MP_DEFINE_CONST_FUN_OBJ_0(fpga_deinit_obj, fpga_deinit);

// READY: fpga.ready() -> bool
// True once the FPGA reports configuration done (CDONE, GPIO4 high).
static mp_obj_t fpga_ready(void) {
    return mp_obj_new_bool(bus_ready());
}
static MP_DEFINE_CONST_FUN_OBJ_0(fpga_ready_obj, fpga_ready);

// LINK_OK: fpga.link_ok() -> bool
// True when registers 0 and 1 read back the Zen Link ID, so the FPGA is configured
// with a zen_link design and the wiring and timing are good.
static mp_obj_t fpga_link_ok(void) {
    return mp_obj_new_bool(bus_link_ok());
}
static MP_DEFINE_CONST_FUN_OBJ_0(fpga_link_ok_obj, fpga_link_ok);

// SET_PULSE_DELAY: fpga.set_pulse_delay(loops) -> None
// Raise it if bytes are being missed. Lower it only with a scope or the
// FPGA logic analyser watching the bus.
static mp_obj_t fpga_set_pulse_delay(mp_obj_t loops_in) {
    uint32_t loops = arg_to_u32(loops_in);

    if (!bus_set_delay(loops)) {
        mp_raise_msg((mp_obj_type_t *)&fpga_error_type, "pulse delay out of range");
    }

    return mp_const_none;
}
static MP_DEFINE_CONST_FUN_OBJ_1(fpga_set_pulse_delay_obj, fpga_set_pulse_delay);

// GET_PULSE_DELAY: fpga.get_pulse_delay() -> int
static mp_obj_t fpga_get_pulse_delay(void) {
    return mp_obj_new_int_from_uint(bus_get_delay());
}
static MP_DEFINE_CONST_FUN_OBJ_0(fpga_get_pulse_delay_obj, fpga_get_pulse_delay);


/* ========================================================================= */
/*  MODULE TABLE                                                             */
/* ========================================================================= */

// MPY_INIT: runs on "import fpga". Everything the module exports is listed
// here, and nothing not listed here is reachable from python.
mp_obj_t mpy_init(mp_obj_fun_bc_t *self, size_t n_args, size_t n_kw, mp_obj_t *args) {
    MP_DYNRUNTIME_INIT_ENTRY

    mp_obj_exception_init(&fpga_error_type, MP_QSTR_FPGAError, &mp_type_Exception);
    mp_store_global(MP_QSTR_FPGAError, MP_OBJ_FROM_PTR(&fpga_error_type));

    mp_store_global(MP_QSTR_write, MP_OBJ_FROM_PTR(&fpga_write_obj));
    mp_store_global(MP_QSTR_read, MP_OBJ_FROM_PTR(&fpga_read_obj));
    mp_store_global(MP_QSTR_write_block, MP_OBJ_FROM_PTR(&fpga_write_block_obj));
    mp_store_global(MP_QSTR_read_block, MP_OBJ_FROM_PTR(&fpga_read_block_obj));

    mp_store_global(MP_QSTR_init, MP_OBJ_FROM_PTR(&fpga_init_obj));
    mp_store_global(MP_QSTR_deinit, MP_OBJ_FROM_PTR(&fpga_deinit_obj));
    mp_store_global(MP_QSTR_ready, MP_OBJ_FROM_PTR(&fpga_ready_obj));
    mp_store_global(MP_QSTR_link_ok, MP_OBJ_FROM_PTR(&fpga_link_ok_obj));

    mp_store_global(MP_QSTR_set_pulse_delay, MP_OBJ_FROM_PTR(&fpga_set_pulse_delay_obj));
    mp_store_global(MP_QSTR_get_pulse_delay, MP_OBJ_FROM_PTR(&fpga_get_pulse_delay_obj));

    MP_DYNRUNTIME_INIT_EXIT
}
