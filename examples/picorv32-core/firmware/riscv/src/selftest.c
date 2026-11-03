// This is the PicoRV32 self-check firmware: it exercises registers, ALU, shifts, memory, MUL, DIV, counters and
// compressed instructions, reports over a bit-banged UART and shows the verdict on the LEDs (led1 = pass, led2 = fail).
// It can also be compiled for a normal PC with -DHOST to prove the expected values are right before trusting the CPU.

// Set to 1 to build the hardware diagnostic: RAM store/load and call/return probes run before the self-test, and MUL/DIV are left out to fit in memory.
#define DIAG 0

#ifdef HOST
#include <stdio.h>
#include <stdlib.h>
#endif

// GPIO register address: bit0 -> led1 (pass), bit1 -> led2 (fail), bit2 -> UART TX pin (idles high).
#define GPIO_ADDR   0x10000000u
// Clock cycles per UART bit: 25 MHz / 115200 baud = 217.01.
#define BIT_CYCLES  217u
// Number of operand pairs used by the MUL and DIV tests (16 edge-case pairs, then pseudo-random).
#define NPAIRS      40

// Assembly routine from regtest.S: returns 0 if every register holds its value, else the failing register number.
extern int regtest(void);

// Shadow copy of the GPIO register (starts with the UART pin high); also lives in .data so it needs no start-up code.
static unsigned gp_shadow = 0x4u;

#ifndef HOST
// This reads the low 32 bits of the cycle counter.
static inline unsigned rdcycle(void) { unsigned v; __asm__ volatile("rdcycle %0" : "=r"(v)); return v; }
// This reads the low 32 bits of the retired-instruction counter.
static inline unsigned rdinstret(void) { unsigned v; __asm__ volatile("rdinstret %0" : "=r"(v)); return v; }
// This reads the high 32 bits of the cycle counter (exercises ENABLE_COUNTERS64).
static inline unsigned rdcycleh(void) { unsigned v; __asm__ volatile("rdcycleh %0" : "=r"(v)); return v; }
// This reads the high 32 bits of the instruction counter.
static inline unsigned rdinstreth(void) { unsigned v; __asm__ volatile("rdinstreth %0" : "=r"(v)); return v; }
// This writes the GPIO register.
static inline void gpio_write(unsigned v) { *(volatile unsigned *)GPIO_ADDR = v; }

// Hardware multiply/divide wrappers use inline asm so the compiler can never fold or replace them.
// 'mul' returns the low 32 bits of a*b.
static unsigned hw_mul(unsigned a, unsigned b)    { unsigned r; __asm__ volatile("mul %0,%1,%2"    : "=r"(r) : "r"(a), "r"(b)); return r; }
// 'mulh' returns the high 32 bits of signed*signed.
static unsigned hw_mulh(unsigned a, unsigned b)   { unsigned r; __asm__ volatile("mulh %0,%1,%2"   : "=r"(r) : "r"(a), "r"(b)); return r; }
// 'mulhsu' returns the high 32 bits of signed*unsigned.
static unsigned hw_mulhsu(unsigned a, unsigned b) { unsigned r; __asm__ volatile("mulhsu %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); return r; }
// 'mulhu' returns the high 32 bits of unsigned*unsigned.
static unsigned hw_mulhu(unsigned a, unsigned b)  { unsigned r; __asm__ volatile("mulhu %0,%1,%2"  : "=r"(r) : "r"(a), "r"(b)); return r; }
// 'div' is signed division.
static unsigned hw_div(unsigned a, unsigned b)    { unsigned r; __asm__ volatile("div %0,%1,%2"    : "=r"(r) : "r"(a), "r"(b)); return r; }
// 'divu' is unsigned division.
static unsigned hw_divu(unsigned a, unsigned b)   { unsigned r; __asm__ volatile("divu %0,%1,%2"   : "=r"(r) : "r"(a), "r"(b)); return r; }
// 'rem' is the signed remainder.
static unsigned hw_rem(unsigned a, unsigned b)    { unsigned r; __asm__ volatile("rem %0,%1,%2"    : "=r"(r) : "r"(a), "r"(b)); return r; }
// 'remu' is the unsigned remainder.
static unsigned hw_remu(unsigned a, unsigned b)   { unsigned r; __asm__ volatile("remu %0,%1,%2"   : "=r"(r) : "r"(a), "r"(b)); return r; }
#else
// Host stand-ins so the same checks run on a PC: a fake cycle counter, a no-op GPIO and plain C maths with the RISC-V rules.
static unsigned fake_cycles = 0;
// Each read advances the fake counter so wait loops terminate.
static unsigned rdcycle(void) { fake_cycles += 100; return fake_cycles; }
// Instruction counter stand-in (advances faster than cycles/CPI would, only the ordering matters on host).
static unsigned fake_instret = 0;
// Each read advances the fake instruction counter.
static unsigned rdinstret(void) { fake_instret += 10; return fake_instret; }
// High cycle word is zero.
static unsigned rdcycleh(void) { return 0; }
// High instruction word is zero.
static unsigned rdinstreth(void) { return 0; }
// GPIO writes are ignored on host.
static void gpio_write(unsigned v) { (void)v; }
// Low 32 bits of the product.
static unsigned hw_mul(unsigned a, unsigned b) { return a * b; }
// High half of signed*signed.
static unsigned hw_mulh(unsigned a, unsigned b) { return (unsigned)(((long long)(int)a * (long long)(int)b) >> 32); }
// High half of signed*unsigned.
static unsigned hw_mulhsu(unsigned a, unsigned b) { return (unsigned)(((long long)(int)a * (long long)(unsigned long long)b) >> 32); }
// High half of unsigned*unsigned.
static unsigned hw_mulhu(unsigned a, unsigned b) { return (unsigned)(((unsigned long long)a * b) >> 32); }
// Signed division with the RISC-V special cases.
static unsigned hw_div(unsigned a, unsigned b) { if (b == 0) return 0xFFFFFFFFu; if (a == 0x80000000u && b == 0xFFFFFFFFu) return a; return (unsigned)((int)a / (int)b); }
// Unsigned division with divide-by-zero giving all ones.
static unsigned hw_divu(unsigned a, unsigned b) { return b ? a / b : 0xFFFFFFFFu; }
// Signed remainder with the RISC-V special cases.
static unsigned hw_rem(unsigned a, unsigned b) { if (b == 0) return a; if (a == 0x80000000u && b == 0xFFFFFFFFu) return 0; return (unsigned)((int)a % (int)b); }
// Unsigned remainder with divide-by-zero returning the dividend.
static unsigned hw_remu(unsigned a, unsigned b) { return b ? a % b : a; }
// Host stand-in for the assembly register test.
int regtest(void) { return 0; }
#endif

// This updates selected GPIO bits and writes the register.
static void gpio_set(unsigned mask, unsigned val) { gp_shadow = (gp_shadow & ~mask) | val; gpio_write(gp_shadow); }

// This waits until n cycles have passed since the reference time t0 (signed compare survives counter wrap).
static void wait_until(unsigned t) { while ((int)(rdcycle() - t) < 0) { } }

// This sends one byte as 8N1 on the UART pin (gpio bit 2), timed from the cycle counter.
static __attribute__((noinline)) void uart_putc(char c)
{
    // Start time of the frame.
    unsigned t = rdcycle();
    // Frame = start bit (0), 8 data bits LSB first, stop bit (1) packed into one word, bit 0 sent first.
    unsigned v = ((unsigned)(unsigned char)c << 1) | 0x200u;
    // Send the 10 bits, each one BIT_CYCLES long and timed from the frame start (no drift).
    for (int i = 0; i < 10; i++) {
        // Wait for this bit's slot.
        wait_until(t);
        // Drive the pin with the current bit.
        gpio_set(4u, (v & 1u) << 2);
        // Move to the next bit.
        v >>= 1;
        // Schedule the next slot.
        t += BIT_CYCLES;
    }
    // Hold the stop bit for its full length.
    wait_until(t);
}

// This sends a zero-terminated string.
static void uart_puts(const char *s) { while (*s) uart_putc(*s++); }

// This sends a 32-bit value as 8 hex digits.
static void uart_hex(unsigned v)
{
    // Send from the top nibble down.
    for (int i = 28; i >= 0; i -= 4) uart_putc("0123456789ABCDEF"[(v >> i) & 0xF]);
}

// This returns the n-th pseudo-random 32-bit value from a simple LCG (fixed seed, so the run is repeatable).
static unsigned lcg(unsigned *s) { *s = *s * 1664525u + 1013904223u; return *s; }

// This produces operand pair number i: edge cases first (zero, one, -1, INT_MIN, INT_MAX ...), then pseudo-random values.
// s is the LCG state and must be carried between calls (start it at 0xC0FFEE11).
static void get_pair(int i, unsigned *s, unsigned *x, unsigned *y)
{
    // Edge-case operand list.
    static const unsigned e[] = { 0u, 1u, 0xFFFFFFFFu, 0x80000000u, 0x7FFFFFFFu, 2u, 0xFFFFFFFEu, 0x12345678u };
    // The first 16 pairs use edge values: even index pairs two different edges, odd index repeats one edge.
    if (i < 16) {
        // Edge entry for this pair.
        unsigned k = (unsigned)i >> 1;
        // First operand.
        *x = e[k];
        // Second operand: a different edge for even i, the same edge for odd i.
        *y = (i & 1) ? e[k] : e[(k * 3 + 1) & 7];
    } else {
        // Pseudo-random operands; the second is shifted by a varying amount so small divisors appear too.
        *x = lcg(s);
        *y = lcg(s) >> (i & 15);
    }
}

// Software reference: high 32 bits of the unsigned 64-bit product, built with shift-and-add only.
static unsigned sw_mulhu(unsigned a, unsigned b)
{
    // 64-bit accumulator kept as two 32-bit halves, and the multiplicand shifted left each step.
    unsigned acc_lo = 0, acc_hi = 0, m_lo = a, m_hi = 0;
    // Walk the 32 multiplier bits.
    for (int i = 0; i < 32; i++) {
        // Add the shifted multiplicand if this multiplier bit is set.
        if (b & 1u) {
            // Low half add with carry out.
            unsigned old = acc_lo; acc_lo += m_lo; acc_hi += m_hi + (acc_lo < old);
        }
        // Shift the multiplicand left by one across both halves.
        m_hi = (m_hi << 1) | (m_lo >> 31); m_lo <<= 1;
        // Next multiplier bit.
        b >>= 1;
    }
    // Only the high half is returned.
    return acc_hi;
}

// Software reference: unsigned restoring division giving quotient and remainder (divide-by-zero follows the RISC-V rule).
static void sw_divu(unsigned n, unsigned d, unsigned *q, unsigned *r)
{
    // RISC-V rule: x/0 = all ones, x%0 = x.
    if (d == 0) { *q = 0xFFFFFFFFu; *r = n; return; }
    // Quotient and partial remainder.
    unsigned qq = 0, rr = 0;
    // Process the dividend from the top bit down.
    for (int i = 31; i >= 0; i--) {
        // Bring down the next dividend bit.
        rr = (rr << 1) | ((n >> i) & 1u);
        // If the partial remainder reaches the divisor, subtract and set the quotient bit.
        if (rr >= d) { rr -= d; qq |= 1u << i; }
    }
    // Hand back the results.
    *q = qq; *r = rr;
}

// ---------------------------------------------------------------- individual tests (0 = pass, nonzero = failure code)

// Test: fixed-value ALU results (add, sub, logic, compares, wrap-around).
static int t_alu(void)
{
    // Volatile operands stop the compiler from folding the operations away.
    volatile unsigned a = 0x12345678u, b = 0x9ABCDEF0u, one = 1u, zero = 0u, m1 = 0xFFFFFFFFu;
    // a + b wraps modulo 2^32.
    if (a + b != 0xACF13568u) return 1;
    // a - b wraps modulo 2^32.
    if (a - b != 0x77777788u) return 2;
    // Bitwise AND.
    if ((a & b) != 0x12345670u) return 3;
    // Bitwise OR.
    if ((a | b) != 0x9ABCDEF8u) return 4;
    // Bitwise XOR.
    if ((a ^ b) != 0x88888888u) return 5;
    // Signed compare: -1 < 1 is true.
    if (!((int)m1 < (int)one)) return 6;
    // Unsigned compare: 0xFFFFFFFF < 1 is false.
    if (m1 < one) return 7;
    // Signed compare: 0 < -1 is false.
    if ((int)zero < (int)m1) return 8;
    // Overflow wrap: 0xFFFFFFFF + 1 = 0.
    if (m1 + one != 0u) return 9;
    // Equality and inequality branches.
    if (a == b) return 10;
    // Everything matched.
    return 0;
}

// Test: shifts by every amount 0..31, left/right logical and arithmetic, against repeated single-step references.
static int t_shift(void)
{
    // Test operands (volatile so the shifts really execute on the CPU's shifter).
    volatile unsigned pos = 0x89ABCDEFu;
    // A negative number for arithmetic shifts.
    volatile int neg = (int)0x89ABCDEF;
    // Reference values built by shifting one bit at a time.
    unsigned ref_l = pos, ref_r = pos;
    // Reference for arithmetic right shift.
    int ref_a = neg;
    // Try each shift amount.
    for (unsigned s = 0; s < 32; s++) {
        // Variable amount (volatile) forces register-shift instructions.
        volatile unsigned amt = s;
        // Logical left shift.
        if ((pos << amt) != ref_l) return 100 + (int)s;
        // Logical right shift.
        if ((pos >> amt) != ref_r) return 200 + (int)s;
        // Arithmetic right shift.
        if ((neg >> amt) != ref_a) return 300 + (int)s;
        // Advance the references by one bit (sign bit replicated for the arithmetic one).
        ref_l <<= 1; ref_r >>= 1; ref_a = (ref_a >> 1) | (int)(neg & 0x80000000);
    }
    // Fixed spot checks that do not depend on the loop.
    volatile unsigned sh4 = 4;
    // 0x89ABCDEF << 4 keeps the low 28 bits shifted up.
    if ((pos << sh4) != 0x9ABCDEF0u) return 1;
    // 0x89ABCDEF >> 4 logical.
    if ((pos >> sh4) != 0x089ABCDEu) return 2;
    // 0x89ABCDEF >> 4 arithmetic keeps the sign.
    if ((neg >> sh4) != (int)0xF89ABCDE) return 3;
    // Everything matched.
    return 0;
}

// Test: byte/half/word loads and stores with sign and zero extension.
static int t_mem(void)
{
    // Word-aligned scratch buffer on the stack.
    volatile unsigned buf[2];
    // Byte, halfword and word views of the same memory.
    volatile unsigned char *bp = (volatile unsigned char *)buf;
    // Halfword view.
    volatile unsigned short *hp = (volatile unsigned short *)buf;
    // Write a word, then read it back through every width (little endian).
    buf[0] = 0x80F1A2B3u; buf[1] = 0u;
    // Byte reads.
    if (bp[0] != 0xB3 || bp[1] != 0xA2 || bp[2] != 0xF1 || bp[3] != 0x80) return 1;
    // Halfword reads.
    if (hp[0] != 0xA2B3 || hp[1] != 0x80F1) return 2;
    // Signed byte read sign-extends.
    if ((int)(signed char)bp[3] != (int)0xFFFFFF80) return 3;
    // Signed halfword read sign-extends.
    if ((int)(short)hp[1] != (int)0xFFFF80F1) return 4;
    // Byte store only changes one byte.
    bp[1] = 0x55;
    // Word now reflects only that change.
    if (buf[0] != 0x80F155B3u) return 5;
    // Halfword store only changes two bytes.
    hp[1] = 0x1234;
    // Word reflects the halfword change.
    if (buf[0] != 0x123455B3u) return 6;
    // Second word is untouched.
    if (buf[1] != 0u) return 7;
    // Everything matched.
    return 0;
}

// Test: MUL, MULH, MULHSU, MULHU against shift-and-add references over edge and random operands.
static int t_mul(void)
{
    // LCG state for the pseudo-random operands.
    unsigned s = 0xC0FFEE11u;
    // Check every pair.
    for (int i = 0; i < NPAIRS; i++) {
        // Operands for this round.
        unsigned x, y;
        // Fetch pair i.
        get_pair(i, &s, &x, &y);
        // Reference high half of the unsigned product.
        unsigned hu = sw_mulhu(x, y);
        // Reference low half: shift-and-add using only adds and shifts.
        unsigned lo = 0, mm = x, bb = y;
        // Walk the multiplier bits.
        for (int k = 0; k < 32; k++) { if (bb & 1u) lo += mm; mm <<= 1; bb >>= 1; }
        // Compare the hardware low product with the reference.
        if (hw_mul(x, y) != lo) return 1000 + i;
        // MULHU compares directly.
        if (hw_mulhu(x, y) != hu) return 2000 + i;
        // MULH = MULHU - (x<0 ? y : 0) - (y<0 ? x : 0).
        if (hw_mulh(x, y) != hu - (((int)x < 0) ? y : 0u) - (((int)y < 0) ? x : 0u)) return 3000 + i;
        // MULHSU = MULHU - (x<0 ? y : 0).
        if (hw_mulhsu(x, y) != hu - (((int)x < 0) ? y : 0u)) return 4000 + i;
    }
    // Everything matched.
    return 0;
}

// Test: DIV, DIVU, REM, REMU against a restoring-division reference, including divide-by-zero and INT_MIN / -1.
static int t_div(void)
{
    // LCG state for the pseudo-random operands.
    unsigned s = 0xC0FFEE11u;
    // Check every pair.
    for (int i = 0; i < NPAIRS; i++) {
        // Operands for this round.
        unsigned x, y;
        // Fetch pair i.
        get_pair(i, &s, &x, &y);
        // Reference unsigned quotient and remainder.
        unsigned q, r;
        // Compute them.
        sw_divu(x, y, &q, &r);
        // Unsigned division.
        if (hw_divu(x, y) != q) return 1000 + i;
        // Unsigned remainder.
        if (hw_remu(x, y) != r) return 2000 + i;
        // Signed reference via magnitudes.
        unsigned sq, sr;
        // Magnitudes of both operands.
        unsigned ux = ((int)x < 0) ? (0u - x) : x, uy = ((int)y < 0) ? (0u - y) : y;
        // Divide the magnitudes.
        sw_divu(ux, uy, &sq, &sr);
        // Quotient is negative when the signs differ; remainder takes the dividend's sign.
        if (((int)x < 0) != ((int)y < 0)) sq = 0u - sq;
        // Remainder sign follows the dividend.
        if ((int)x < 0) sr = 0u - sr;
        // Special case: divide by zero gives -1 and the dividend as remainder.
        if (y == 0u) { sq = 0xFFFFFFFFu; sr = x; }
        // Special case: INT_MIN / -1 overflows to INT_MIN with remainder 0.
        if (x == 0x80000000u && y == 0xFFFFFFFFu) { sq = 0x80000000u; sr = 0u; }
        // Signed division.
        if (hw_div(x, y) != sq) return 3000 + i;
        // Signed remainder.
        if (hw_rem(x, y) != sr) return 4000 + i;
    }
    // Everything matched.
    return 0;
}

// Test: control flow (loops, nested branches, function-pointer calls).
static int t_flow(void)
{
    // Volatile bound so the loop really runs.
    volatile unsigned n = 100;
    // Sum 1..100 = 5050.
    unsigned sum = 0;
    // Loop.
    for (unsigned i = 1; i <= n; i++) sum += i;
    // Check the sum.
    if (sum != 5050u) return 1;
    // Indirect call through a volatile function pointer (jalr).
    unsigned (*volatile fp)(void) = (unsigned (*)(void))rdcycle;
    // The cycle counter must have advanced between two calls.
    unsigned c0 = fp(), c1 = fp();
    // Counter must move forward.
    if ((int)(c1 - c0) <= 0) return 2;
    // Nested conditionals with several outcomes.
    volatile int v = -7;
    // Sign classification.
    int cls = (v < 0) ? ((v < -5) ? 2 : 1) : ((v > 5) ? 4 : 3);
    // Expect the "very negative" class.
    if (cls != 2) return 3;
    // Everything matched.
    return 0;
}

// Test: cycle and instruction counters (low and high words) behave sensibly.
static int t_counters(void)
{
    // Snapshot before a small amount of work.
    unsigned c0 = rdcycle(), i0 = rdinstret();
    // Some work so both counters must move.
    volatile unsigned x = 0;
    // Short loop.
    for (int k = 0; k < 20; k++) x += (unsigned)k;
    // Snapshot after.
    unsigned c1 = rdcycle(), i1 = rdinstret();
    // Both must have advanced.
    if ((int)(c1 - c0) <= 0) return 1;
    // Instructions must have advanced.
    if ((int)(i1 - i0) <= 0) return 2;
    // The core needs at least one cycle per instruction, so cycles >= instructions.
    if ((c1 - c0) < (i1 - i0)) return 3;
    // The 64-bit counter high words must be readable (they stay 0 for the first ~171 s, so just read them).
    volatile unsigned hi = rdcycleh() + rdinstreth();
    // Use the value so the reads are not optimised away.
    (void)hi;
    // Everything matched.
    return 0;
}

// Test: compressed (16-bit) instructions executed explicitly.
static int t_rvc(void)
{
#ifdef HOST
    // On host there is nothing to run.
    return 0;
#else
    // Result register for the compressed sequence.
    unsigned r;
    // Sequence: 5+3=8, <<2=32, copy, add -> 64, sub -> 32, >>2 -> 8, >>1 (arith) -> 4, &6 -> 4.
    __asm__ volatile(
        ".option push\n"
        ".option rvc\n"
        "c.li   a5, 5\n"
        "c.addi a5, 3\n"
        "c.slli a5, 2\n"
        "c.mv   a4, a5\n"
        "c.add  a4, a5\n"
        "c.sub  a4, a5\n"
        "c.srli a4, 2\n"
        "c.srai a4, 1\n"
        "c.andi a4, 6\n"
        "mv     %0, a4\n"
        ".option pop\n"
        : "=r"(r) : : "a4", "a5");
    // Expect 4.
    return (r == 4u) ? 0 : 1;
#endif
}

// Test: all 32 registers hold distinct values (assembly routine).
static int t_regs(void) { return regtest(); }

// ---------------------------------------------------------------- test table and main

// One entry per test: name and function.
struct test { const char *name; int (*fn)(void); };

// The list of tests, run in this order.
static const struct test tests[] = {
    { "alu     ", t_alu },
    { "shift   ", t_shift },
    { "mem     ", t_mem },
#if !DIAG
    // MUL and DIV are left out of the diagnostic build to save memory (they pass in simulation).
    { "mul     ", t_mul },
    { "div     ", t_div },
#endif
    { "flow    ", t_flow },
    { "counters", t_counters },
    { "rvc     ", t_rvc },
    // The register test goes last: it is the most invasive one (it overwrites sp and every register).
    { "regs    ", t_regs },
};

// Number of tests.
#define NTESTS ((int)(sizeof(tests) / sizeof(tests[0])))

// This runs all tests once, prints a report and returns the number of failures.
static int run_all(void)
{
    // Failure counter.
    int fails = 0;
    // Banner.
    uart_puts("\r\nPicoRV32 selftest\r\n");
    // Run each test.
    for (int i = 0; i < NTESTS; i++) {
        // Print its name first, so a test that never returns is visible on the terminal.
        uart_puts(tests[i].name);
        // Execute it.
        int rc = tests[i].fn();
        // Print the verdict (and the code when it failed).
        if (rc == 0) uart_puts(" ok\r\n");
        else { uart_puts(" FAIL code "); uart_hex((unsigned)rc); uart_puts("\r\n"); fails++; }
#ifdef HOST
        printf("%s rc=%d\n", tests[i].name, rc);
#endif
    }
    // Final verdict line.
    uart_puts(fails ? "RESULT: FAIL\r\n" : "RESULT: ALL PASS\r\n");
    // Return the count.
    return fails;
}

#ifdef HOST
// Host entry: run once and exit with the failure count.
int main(void) { return run_all(); }
#else
// Firmware entry: loop forever, re-running the suite every ~2 seconds so a terminal opened late still sees a report.
#if DIAG
// This prints a 32-bit value as 8 hex digits plus a space, using only the leaf function uart_putc (no stack use).
#define PUTHEX(val) do { unsigned v_ = (val); for (int i_ = 28; i_ >= 0; i_ -= 4) uart_putc("0123456789ABCDEF"[(v_ >> i_) & 15]); uart_putc(' '); } while (0)

// This is a deliberately non-leaf function: it saves its return address on the stack, calls uart_putc, then returns.
static __attribute__((noinline)) unsigned nonleaf_probe(unsigned x)
{
    // Calling another function forces the compiler to push ra on the stack and pop it before returning.
    uart_putc('r');
    // Return a value derived from the argument so the compiler cannot drop the call.
    return x + 1;
}

// This is the assembly stack probe from diagprobe.S.
extern void stack_probe(volatile unsigned *out);

// This ends a diagnostic output line.
#define CRLF() do { uart_putc('\r'); uart_putc('\n'); } while (0)

// This runs the diagnostic probes once.
static void diag(void)
{
    // Marker so the diagnostic output is easy to spot.
    uart_putc('\r'); uart_putc('\n'); uart_putc('D'); CRLF();

    // Line 1: the stack pointer here (expect a value just below 00000C00).
    unsigned spv;
    // Read sp with inline assembly.
    __asm__ volatile("mv %0, sp" : "=r"(spv));
    // Print it.
    PUTHEX(spv); CRLF();

    // Line 2: code-region words read as DATA at addresses 4, 8, C, 10, 40, 100, 200, 2C0 (compare with the same lines of firmware.hex).
    static const unsigned ca[8] = { 0x4, 0x8, 0xC, 0x10, 0x40, 0x100, 0x200, 0x2C0 };
    // Read and print each one.
    for (int k = 0; k < 8; k++) PUTHEX(*(volatile unsigned *)ca[k]);
    // End of line.
    CRLF();

    // Line 3: write eight consecutive words at 0xAA0 then read them back; expect C0DE0000 .. C0DE0007.
    volatile unsigned *a = (volatile unsigned *)0xAA0;
    // Write the pattern.
    for (int k = 0; k < 8; k++) a[k] = 0xC0DE0000u + (unsigned)k;
    // Read it back and print it.
    for (int k = 0; k < 8; k++) PUTHEX(a[k]);
    // End of line.
    CRLF();

    // Line 4: the stack probe; expect DEAD0000 .. DEAD0007 then the stack pointer inside the probe (spv minus 32).
    volatile unsigned *o = (volatile unsigned *)0xAC0;
    // Run the probe.
    stack_probe(o);
    // Print its nine results.
    for (int k = 0; k < 9; k++) PUTHEX(o[k]);
    // End of line.
    CRLF();

    // Line 5: a real non-leaf call; prints 'r' inside, then 00000042 if the return works, then K.
    PUTHEX(nonleaf_probe(0x41u));
    // Reaching this point means the return address survived the stack round trip.
    uart_putc('K'); CRLF();
}
#endif

int main(void)
{
#if DIAG
    // Run the diagnostic once before the normal self-test.
    diag();
#endif
    // Run forever.
    for (;;) {
        // Execute the whole suite.
        int fails = run_all();
        // Show the verdict on the LEDs: pass lights led1 steady, fail lights led2.
        gpio_set(3u, fails ? 2u : 1u);
        // Wait about 2 seconds at 25 MHz.
        unsigned t = rdcycle() + 50000000u;
        // Busy-wait.
        wait_until(t);
    }
}
#endif
