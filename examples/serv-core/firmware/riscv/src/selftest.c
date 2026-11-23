/* SERVxZen self-test (RV32I + Zicsr): checks the core with independent Python golden values and reports over the UART.
 * Build with build.sh. Hardware: runs forever, repeating the report about every 2 s. Simulation: halts after one pass by writing the halt address.
 * No multiply, divide, libc or libgcc is used, so it builds for plain rv32i.
 */
#include <stdint.h>
#include "golden.h"

/* Test groups, selected at build time so each image fits the 4 KB RAM of Zen 4:
 *   WITH_CORE  alu, branch, mem, flow, csr   (default image "selftest")
 *   WITH_TRAP  ecall, ebreak, misaligned traps, timer interrupt
 *   WITH_PERF  clocks per instruction report
 *   WITH_SOFT  software multiply/divide loops (needs more than 4 KB; simulation only)
 */
#if !defined(WITH_CORE) && !defined(WITH_TRAP) && !defined(WITH_SOFT) && !defined(WITH_PERF)
#define WITH_CORE
#endif

/* Memory-mapped registers of the SERVxZen SoC */
#define GPIO  (*(volatile uint32_t *)0x40000000u)
#define UART  (*(volatile uint32_t *)0x40000004u)
#define CYC   (*(volatile uint32_t *)0x40000008u)
#define MTIME (*(volatile uint32_t *)0x80000000u)
#define MTCMP (*(volatile uint32_t *)0x80000000u)
#define HALT  (*(volatile uint32_t *)0x90000000u)

/* Clocks to wait between repeated reports on hardware (2 s at 25 MHz); a smaller value can be passed to test the repeat in simulation */
#ifndef REPEAT_CLKS
#define REPEAT_CLKS 50000000u
#endif

/* Linker symbol: first free RAM byte above the program image */
extern char __image_end[];

#ifdef WITH_TRAP
/* Counters filled in by the trap handler */
static volatile uint32_t n_ecall, n_ebreak, n_timer, n_misl, n_mist, n_other;
/* Last trap cause seen by the handler */
static volatile uint32_t last_cause;
#endif
/* Total number of failed checks */
static uint32_t fails;

/* Sends one character, waiting while the UART is busy */
static void putc_(char c) {
    /* Wait until the transmitter is idle */
    while (UART & 1u) { }
    /* Start sending */
    UART = (uint32_t)(unsigned char)c;
}

/* Sends a zero-terminated string */
static void puts_(const char *s) {
    /* Send characters until the terminator */
    while (*s) putc_(*s++);
}

/* Sends a 32-bit value as 8 hex digits */
static void puthex(uint32_t v) {
    /* From the top nibble down */
    for (int i = 28; i >= 0; i -= 4) putc_("0123456789ABCDEF"[(v >> i) & 15u]);
}

/* Sends an unsigned decimal number using repeated subtraction (no divide instruction exists in RV32I) */
__attribute__((unused)) static void putdec(uint32_t v) {
    /* Powers of ten, largest first */
    static const uint32_t p10[] = {1000000000u, 100000000u, 10000000u, 1000000u, 100000u, 10000u, 1000u, 100u, 10u, 1u};
    /* Becomes 1 after the first non-zero digit so leading zeros are skipped */
    int started = 0;
    /* One digit per power of ten */
    for (int i = 0; i < 10; i++) {
        /* Digit value */
        int d = 0;
        /* Subtract the power while it fits */
        while (v >= p10[i]) { v -= p10[i]; d++; }
        /* Print unless it is a leading zero (always print the last digit) */
        if (d || started || i == 9) { putc_((char)('0' + d)); started = 1; }
    }
}

/* Number of the next check inside the current test (starts at 1); failures print this number instead of a name to keep the image small */
static uint32_t seq;

/* Compares one result with its expected value; on mismatch prints "  FAIL <n> got <hex> exp <hex>" where n is the order of the check() call in its test function */
static void check(uint32_t got, uint32_t exp) {
    /* Number this check */
    seq++;
    /* Equal values pass silently */
    if (got == exp) return;
    /* Count and report the failure */
    fails++;
    puts_("  FAIL "); puthex(seq); puts_(" got "); puthex(got); puts_(" exp "); puthex(exp); puts_("\n");
}

/* Prints the test name and an ok/FAIL summary after a test function returns */
static void report(const char *name, uint32_t before) {
    /* Name column */
    puts_(name); puts_(fails == before ? " ok\n" : " FAILED\n");
}

/* xorshift32 pseudo-random generator, identical to gen-golden.py */
__attribute__((unused)) static uint32_t xorshift(uint32_t x) {
    /* Three shift-xor steps */
    x ^= x << 13; x ^= x >> 17; x ^= x << 5;
    return x;
}

/* Folds a result into a checksum: rotate left one bit, then xor */
__attribute__((unused)) static uint32_t fold(uint32_t c, uint32_t r) {
    /* Rotate and mix */
    return ((c << 1) | (c >> 31)) ^ r;
}

/* Scratch words for the memory test; placed in .bss, which start.S clears (and which the linker keeps below the stack) */
static volatile uint32_t scratch[4];

#ifdef WITH_CORE
/* Edge-case operand pairs, identical to gen-golden.py */
static const uint32_t edge[N_EDGE][2] = {
    {0u, 0u}, {1u, 1u}, {0xFFFFFFFFu, 1u}, {0x7FFFFFFFu, 1u}, {0x80000000u, 0xFFFFFFFFu},
    {0x80000000u, 0x7FFFFFFFu}, {5u, 0xFFFFFFFBu}, {0x12345678u, 0x9ABCDEF0u}
};

/* Test 1: all 19 ALU operations over edge and pseudo-random operands, compared to golden checksums */
__attribute__((noinline)) static void test_alu(void) {
    /* Running checksum per operation */
    uint32_t c[N_ALU_OPS];
    /* Zero the checksums with a loop (a brace initialiser would call memset, which is not linked) */
    for (int k = 0; k < N_ALU_OPS; k++) c[k] = 0;
    /* Generator state */
    uint32_t x = SEED_ALU;
    /* Walk every operand pair */
    for (int i = 0; i < N_EDGE + N_RAND; i++) {
        /* Operands (volatile so the compiler cannot constant-fold the operations away) */
        volatile uint32_t va, vb;
        /* Edge pairs first, then generated pairs */
        if (i < N_EDGE) { va = edge[i][0]; vb = edge[i][1]; }
        else { x = xorshift(x); va = x; x = xorshift(x); vb = x; }
        /* Load operands into registers */
        uint32_t a = va, b = vb, r;
        /* Register-register operations, one asm statement each so the exact instruction is emitted */
        __asm__ volatile ("add  %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[0]  = fold(c[0],  r);
        __asm__ volatile ("sub  %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[1]  = fold(c[1],  r);
        __asm__ volatile ("and  %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[2]  = fold(c[2],  r);
        __asm__ volatile ("or   %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[3]  = fold(c[3],  r);
        __asm__ volatile ("xor  %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[4]  = fold(c[4],  r);
        __asm__ volatile ("slt  %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[5]  = fold(c[5],  r);
        __asm__ volatile ("sltu %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[6]  = fold(c[6],  r);
        __asm__ volatile ("sll  %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[7]  = fold(c[7],  r);
        __asm__ volatile ("srl  %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[8]  = fold(c[8],  r);
        __asm__ volatile ("sra  %0,%1,%2" : "=r"(r) : "r"(a), "r"(b)); c[9]  = fold(c[9],  r);
        /* Register-immediate operations */
        __asm__ volatile ("addi  %0,%1,-1234" : "=r"(r) : "r"(a)); c[10] = fold(c[10], r);
        __asm__ volatile ("xori  %0,%1,0x555" : "=r"(r) : "r"(a)); c[11] = fold(c[11], r);
        __asm__ volatile ("andi  %0,%1,-256"  : "=r"(r) : "r"(a)); c[12] = fold(c[12], r);
        __asm__ volatile ("ori   %0,%1,0x7ff" : "=r"(r) : "r"(a)); c[13] = fold(c[13], r);
        __asm__ volatile ("slti  %0,%1,-7"    : "=r"(r) : "r"(a)); c[14] = fold(c[14], r);
        __asm__ volatile ("sltiu %0,%1,-7"    : "=r"(r) : "r"(a)); c[15] = fold(c[15], r);
        __asm__ volatile ("slli  %0,%1,3"     : "=r"(r) : "r"(a)); c[16] = fold(c[16], r);
        __asm__ volatile ("srli  %0,%1,9"     : "=r"(r) : "r"(a)); c[17] = fold(c[17], r);
        __asm__ volatile ("srai  %0,%1,31"    : "=r"(r) : "r"(a)); c[18] = fold(c[18], r);
    }
    /* Compare each operation's checksum with the golden value */
    for (int k = 0; k < N_ALU_OPS; k++) check(c[k], alu_golden[k]);
}

/* Branch operand pairs, identical to gen-golden.py */
static const uint32_t brp[7][2] = {
    {0u, 0u}, {1u, 2u}, {2u, 1u}, {0xFFFFFFFFu, 1u}, {1u, 0xFFFFFFFFu}, {0x80000000u, 0x7FFFFFFFu}, {0x7FFFFFFFu, 0x80000000u}
};

/* Test 2: the six conditional branches, taken and not taken; result is a bit mask per branch compared to golden */
__attribute__((noinline)) static void test_branch(void) {
    /* One mask per branch type */
    uint32_t m[6] = {0};
    /* Walk every operand pair */
    for (int i = 0; i < 7; i++) {
        /* Load operands into registers */
        volatile uint32_t va = brp[i][0], vb = brp[i][1];
        uint32_t a = va, b = vb, t;
        /* Each asm sets t to 1 when the branch is taken, 0 otherwise */
        __asm__ volatile ("li %0,1\n beq  %1,%2,1f\n li %0,0\n 1:" : "=&r"(t) : "r"(a), "r"(b)); m[0] |= t << i;
        __asm__ volatile ("li %0,1\n bne  %1,%2,1f\n li %0,0\n 1:" : "=&r"(t) : "r"(a), "r"(b)); m[1] |= t << i;
        __asm__ volatile ("li %0,1\n blt  %1,%2,1f\n li %0,0\n 1:" : "=&r"(t) : "r"(a), "r"(b)); m[2] |= t << i;
        __asm__ volatile ("li %0,1\n bge  %1,%2,1f\n li %0,0\n 1:" : "=&r"(t) : "r"(a), "r"(b)); m[3] |= t << i;
        __asm__ volatile ("li %0,1\n bltu %1,%2,1f\n li %0,0\n 1:" : "=&r"(t) : "r"(a), "r"(b)); m[4] |= t << i;
        __asm__ volatile ("li %0,1\n bgeu %1,%2,1f\n li %0,0\n 1:" : "=&r"(t) : "r"(a), "r"(b)); m[5] |= t << i;
    }
    /* Compare each mask with the golden value (index order: beq bne blt bge bltu bgeu) */
    for (int k = 0; k < 6; k++) check(m[k], br_golden[k]);
}

/* Test 3: byte, halfword and word loads and stores, including sign extension */
__attribute__((noinline)) static void test_mem(void) {
    /* Word view and narrower views of the same memory */
    volatile uint32_t *w = &scratch[0];
    volatile uint8_t  *b = (volatile uint8_t *)w;
    volatile uint16_t *h = (volatile uint16_t *)w;
    /* Store a word with distinct bytes */
    w[0] = 0xA1B2C3D4u;
    /* Word read back */
    check(w[0], 0xA1B2C3D4u);
    /* Signed and unsigned byte and halfword loads at every offset, folded into one checksum each (golden from Python) */
    uint32_t cb = 0, cbu = 0, ch = 0, chu = 0;
    /* Four byte offsets */
    for (int i = 0; i < 4; i++) { cb = fold(cb, (uint32_t)(int32_t)(int8_t)b[i]); cbu = fold(cbu, b[i]); }
    /* Two halfword offsets */
    for (int i = 0; i < 2; i++) { ch = fold(ch, (uint32_t)(int32_t)(int16_t)h[i]); chu = fold(chu, h[i]); }
    check(cb,  0x0000016Cu);
    check(cbu, 0x00000469u);
    check(ch,  0x0000261Bu);
    check(chu, 0x0001261Au);
    /* Byte store into the middle of a word */
    b[1] = 0x11;
    check(w[0], 0xA1B211D4u);
    /* Halfword store into the upper half */
    h[1] = 0x5566;
    check(w[0], 0x556611D4u);
    /* Neighbouring words must be untouched */
    w[1] = 0x01234567u; w[2] = 0x89ABCDEFu;
    w[1] = 0x0F0F0F0Fu;
    check(w[1], 0x0F0F0F0Fu);
    check(w[2], 0x89ABCDEFu);
    check(w[0], 0x556611D4u);
}

/* Recursive Fibonacci: exercises call, return, stack frames and branches */
static uint32_t fib(uint32_t n) {
    /* Base case */
    if (n < 2) return n;
    /* Two recursive calls */
    return fib(n - 1) + fib(n - 2);
}

/* Function-pointer target for the jalr test */
static uint32_t plus7(uint32_t x) { return x + 7; }

/* Test 4: jal, jalr, lui, auipc and recursion */
__attribute__((noinline)) static void test_flow(void) {
    /* Recursive calls and returns */
    check(fib(12), 144u);
    /* Indirect call through a volatile pointer forces jalr */
    uint32_t (*volatile fp)(uint32_t) = plus7;
    check(fp(35), 42u);
    /* lui puts the immediate in the upper 20 bits */
    uint32_t u;
    __asm__ volatile ("lui %0,0xABCDE" : "=r"(u));
    check(u, 0xABCDE000u);
    /* auipc 0 must equal the address of its own label */
    uint32_t pc, here;
    __asm__ volatile (".option push\n .option norelax\n 1: auipc %0,0\n la %1,1b\n .option pop" : "=&r"(pc), "=&r"(here));
    check(pc, here);
}

#endif /* WITH_CORE (alu, branch, mem, flow) */

#if defined(WITH_SOFT) || defined(WITH_PERF)
/* Shift-and-add multiply, low 32 bits */
__attribute__((unused)) static uint32_t umul(uint32_t a, uint32_t b) {
    /* Accumulator */
    uint32_t r = 0;
    /* One step per multiplier bit */
    while (b) { if (b & 1u) r += a; a <<= 1; b >>= 1; }
    return r;
}

/* Restoring unsigned divide: returns the quotient and writes the remainder through rem */
static uint32_t udiv(uint32_t n, uint32_t d, uint32_t *rem) {
    /* Quotient and partial remainder */
    uint32_t q = 0, r = 0;
    /* One step per dividend bit, MSB first */
    for (int i = 31; i >= 0; i--) {
        /* Bring down the next dividend bit */
        r = (r << 1) | ((n >> i) & 1u);
        /* Subtract the divisor when it fits */
        if (r >= d) { r -= d; q |= 1u << i; }
    }
    *rem = r;
    return q;
}

#ifdef WITH_SOFT
/* Test 5: software multiply and divide loops compared with Python results (heavy use of shifts, compares, branches) */
__attribute__((noinline)) static void test_soft(void) {
    /* Checksums for multiply, divide, remainder */
    uint32_t cm = 0, cd = 0, cr = 0;
    /* Generator state, same seed as gen-golden.py */
    uint32_t x = 0x1B873593u;
    /* 16 operand pairs */
    for (int i = 0; i < 16; i++) {
        /* Operands: divisor is made odd (so never zero) and smaller */
        x = xorshift(x); uint32_t a = x;
        x = xorshift(x); uint32_t b = (x >> 12) | 1u;
        /* Remainder output */
        uint32_t rem;
        /* Fold the three results */
        cm = fold(cm, umul(a, b));
        cd = fold(cd, udiv(a, b, &rem));
        cr = fold(cr, rem);
    }
    check(cm, SOFT_MUL);
    check(cd, SOFT_DIV);
    check(cr, SOFT_REM);
}
#endif

#endif /* WITH_SOFT || WITH_PERF */

#ifdef WITH_CORE
/* Test 6: CSR instructions on mscratch (read/write, set, clear, immediate forms) */
__attribute__((noinline)) static void test_csr(void) {
    /* Scratch values */
    uint32_t v = 0x0F0F0F0Fu, m = 0x30303030u, old;
    /* csrrw: write, read back */
    __asm__ volatile ("csrw mscratch,%0" :: "r"(v));
    __asm__ volatile ("csrr %0,mscratch" : "=r"(old));
    check(old, 0x0F0F0F0Fu);
    /* csrrs: returns old, sets bits */
    __asm__ volatile ("csrrs %0,mscratch,%1" : "=r"(old) : "r"(m));
    check(old, 0x0F0F0F0Fu);
    __asm__ volatile ("csrr %0,mscratch" : "=r"(old));
    check(old, 0x3F3F3F3Fu);
    /* csrrc: returns old, clears bits */
    __asm__ volatile ("csrrc %0,mscratch,%1" : "=r"(old) : "r"(v));
    check(old, 0x3F3F3F3Fu);
    __asm__ volatile ("csrr %0,mscratch" : "=r"(old));
    check(old, 0x30303030u);
    /* Immediate form */
    __asm__ volatile ("csrwi mscratch,21");
    __asm__ volatile ("csrr %0,mscratch" : "=r"(old));
    check(old, 21u);
}

#endif /* WITH_CORE csr */

#ifdef WITH_TRAP
/* Trap handler called from trap_entry in start.S: counts the cause and returns the PC to resume at */
uint32_t trap_handler(uint32_t mcause, uint32_t mepc) {
    /* Remember the cause for debugging */
    last_cause = mcause;
    /* Interrupt (top bit set) */
    if (mcause & 0x80000000u) {
        /* Machine timer interrupt is cause 7 */
        if ((mcause & 0x7FFFFFFFu) == 7u) {
            /* Count it and push the compare value far into the future so it stops firing */
            n_timer++;
            MTCMP = MTIME + 0x40000000u;
        } else n_other++;
        /* Interrupts resume at the interrupted instruction */
        return mepc;
    }
    /* Synchronous exceptions: count and skip the 4-byte faulting instruction */
    if (mcause == 11u) n_ecall++;
    else if (mcause == 3u) n_ebreak++;
    else if (mcause == 4u) n_misl++;
    else if (mcause == 6u) n_mist++;
    else n_other++;
    return mepc + 4u;
}

/* Trap entry point (in start.S) */
extern void trap_entry(void);

/* Test 7: ecall, ebreak, misaligned load and store traps, then a timer interrupt */
__attribute__((noinline)) static void test_trap(void) {
    /* Clear the counters so every pass starts from zero (the hardware repeats the report, and without this the second pass sees 2, 3, ...) */
    n_ecall = 0; n_ebreak = 0; n_timer = 0; n_misl = 0; n_mist = 0; n_other = 0; last_cause = 0;
    /* Install the trap vector */
    __asm__ volatile ("csrw mtvec,%0" :: "r"((uint32_t)trap_entry));
    /* ecall (forced to 4 bytes so the handler can skip it) */
    __asm__ volatile (".option push\n .option norvc\n ecall\n .option pop");
    check(n_ecall, 1u);
    /* ebreak */
    __asm__ volatile (".option push\n .option norvc\n ebreak\n .option pop");
    check(n_ebreak, 1u);
    /* Misaligned word load and store from an odd address */
    uint32_t t;
    uint32_t odd = (uint32_t)&scratch[0] + 1u;
    __asm__ volatile (".option push\n .option norvc\n lw %0,0(%1)\n .option pop" : "=&r"(t) : "r"(odd));
    check(n_misl, 1u);
    __asm__ volatile (".option push\n .option norvc\n sw %0,0(%1)\n .option pop" :: "r"(t), "r"(odd) : "memory");
    check(n_mist, 1u);
    /* No unexpected traps so far */
    check(n_other, 0u);
    /* Timer interrupt: arm mtimecmp a little in the future, enable MTIE and MIE, wait with a bounded loop */
    MTCMP = MTIME + 3000u;
    __asm__ volatile ("csrs mie,%0" :: "r"(0x80u));
    __asm__ volatile ("csrsi mstatus,8");
    /* Bounded wait measured with the cycle counter (about 4 million clocks max) */
    uint32_t t0 = CYC;
    while (n_timer == 0 && (CYC - t0) < 4000000u) { }
    /* Interrupts off again */
    __asm__ volatile ("csrci mstatus,8");
    check(n_timer, 1u);
    check(n_other, 0u);
}

#else
/* Without the trap tests an interrupt/exception just resumes at the faulting PC (never expected) */
uint32_t trap_handler(uint32_t mcause, uint32_t mepc) { (void)mcause; return mepc; }
#endif /* WITH_TRAP */

#ifdef WITH_PERF
/* Prints cycles for a block of identical instructions as clk per instruction with one decimal */
static void perf_line(const char *name, uint32_t cycles, uint32_t instrs) {
    /* Remainder output of udiv */
    uint32_t rem;
    /* Tenths of a clock per instruction, rounded down */
    uint32_t tenths = udiv(cycles * 10u, instrs, &rem);
    /* Whole clocks per instruction */
    uint32_t whole = udiv(tenths, 10u, &rem);
    /* Name, total clocks, instruction count, then the ratio */
    puts_("  "); puts_(name); puts_(": "); putdec(cycles); puts_(" clk / "); putdec(instrs); puts_(" = ");
    putdec(whole); putc_('.'); putdec(rem); puts_("\n");
}

/* Runs 16 copies of one instruction between two cycle-counter reads and prints the result; BODY may use operand %0 (a pointer) */
#define PERF(NAME, BODY) do { \
        uint32_t s_ = CYC; \
        __asm__ volatile (".rept 16\n " BODY "\n .endr" :: "r"(p_) : "t0", "memory"); \
        uint32_t e_ = CYC; \
        perf_line(NAME, e_ - s_ - base, 16u); \
    } while (0)

/* Measures clocks per instruction for several instruction classes (informational, never fails) */
__attribute__((noinline)) static void test_perf(void) {
    /* Pointer into scratch memory for the load/store cases */
    volatile uint32_t *p_ = &scratch[0];
    /* Cost of the two counter reads themselves, measured back to back and subtracted from every result */
    uint32_t a = CYC, b = CYC;
    uint32_t base = b - a;
    puts_("perf (clk per instruction, 16 each):\n");
    PERF("add",    "add t0,%0,%0");
    PERF("slli",   "slli t0,%0,3");
    PERF("sll",    "sll t0,%0,%0");
    PERF("slt",    "slt t0,%0,%0");
    PERF("lw",     "lw t0,0(%0)");
    PERF("sw",     "sw zero,0(%0)");
    PERF("beq nt", "beq %0,zero,.+4");
    PERF("beq tk", "beq zero,zero,.+4");
    PERF("jal",    "jal zero,.+4");
}
#endif

/* Runs all tests once and prints the summary */
static void run_all(void) {
    /* Reset counters */
    fails = 0;
    /* Banner */
    puts_("\nSERVxZen selftest\n");
    uint32_t f = 0;
    (void)f;
#ifdef WITH_CORE
    f = fails; seq = 0; test_alu();    report("alu",    f);
    f = fails; seq = 0; test_branch(); report("branch", f);
    f = fails; seq = 0; test_mem();    report("mem",    f);
    f = fails; seq = 0; test_flow();   report("flow",   f);
#endif
#ifdef WITH_SOFT
    f = fails; seq = 0; test_soft();   report("soft",   f);
#endif
#ifdef WITH_CORE
    f = fails; seq = 0; test_csr();    report("csr",    f);
#endif
#ifdef WITH_TRAP
    f = fails; seq = 0; test_trap();   report("trap",   f);
#endif
#ifdef WITH_PERF
    test_perf();
#endif
    /* Final verdict and LEDs */
    puts_(fails ? "RESULT: FAIL\n" : "RESULT: ALL PASS\n");
    GPIO = fails ? 2u : 1u;
}

/* Program entry, called from start.S */
int main(void) {
    /* Run once */
    run_all();
    /* Simulation: any write to the halt address ends the run (on hardware this only writes the timer compare register, which is harmless here) */
#ifndef NO_HALT
    HALT = 0;
#endif
    /* Hardware: repeat the report about every 2 s (50 million clocks at 25 MHz) */
    for (;;) {
        /* Wait 2 s */
        uint32_t t0 = CYC;
        while ((CYC - t0) < REPEAT_CLKS) { }
        /* Run again so a late failure shows up */
        run_all();
    }
}
