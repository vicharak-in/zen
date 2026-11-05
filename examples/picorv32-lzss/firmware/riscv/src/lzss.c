// This firmware compresses data sent over UART with LZSS (512-byte window) and sends the compressed bytes back, one 64-byte block at a time.
//
// Protocol on the UART (115200 8N1), lock-step so the slow CPU never overruns:
//   PC -> board : L (1..64), then L raw bytes.          board -> PC : C, then C compressed bytes for that block.
//   PC -> board : 0 (reset history).                    board -> PC : 0.
// Bit format inside one block (most significant bit first, last byte padded with zero bits):
//   literal = 0 + 8 bits;   match = 1 + 9 bits (distance-1) + 4 bits (length-3); distance 1..512, length 3..18.
// The history window carries over from block to block; a match never crosses the end of its own block.
// Build for the board with build.sh; build with -DHOST to test the same compressor on a PC (reads a file, writes the block stream).

#ifdef HOST
#include <stdio.h>
#include <stdlib.h>
#endif

// Window size in bytes (a power of two) and the bits needed for a distance.
#define WINDOW    512u
#define OFF_BITS  9
// Bits for the length field, and the shortest and longest match one token can describe.
#define LEN_BITS  4
#define MIN_LEN   3u
#define MAX_LEN   18u
// Raw bytes per block.
#define BLOCK     64u

// History plus the block being compressed: the first `hist` bytes are history, the new block is appended after them.
static unsigned char buf[WINDOW + BLOCK];
// Number of valid history bytes in buf (0 after a reset, at most WINDOW between blocks).
static unsigned hist;
// Compressed bytes of the block being built (worst case 64 literals x 9 bits = 72 bytes).
static unsigned char out[80];
// Number of bits written into out so far.
static unsigned outbits;

// This appends the low n bits of v (most significant first) to the output of the current block.
// v: the value.  n: how many bits to write.
static void put_bits(unsigned v, int n)
{
    // Write from the top bit down to bit 0.
    for (int i = n - 1; i >= 0; i--) {
        // Set the bit in its byte only when it is 1 (out was cleared before the block).
        if ((v >> i) & 1u) out[outbits >> 3] |= (unsigned char)(0x80u >> (outbits & 7u));
        // Move to the next bit position.
        outbits++;
    }
}

// This compresses the `len` new bytes that sit in buf[hist .. hist+len) and returns the number of compressed bytes now in out[].
// It tries every distance from 1 to the window size and keeps the longest match; the nearest distance wins ties.
static unsigned compress_block(unsigned len)
{
    // Clear the output bytes and the bit counter.
    for (unsigned i = 0; i < sizeof out; i++) out[i] = 0;
    outbits = 0;
    // End of this block inside buf, and the first position to encode.
    unsigned end = hist + len, p = hist;
    // Encode until the whole block is consumed.
    while (p < end) {
        // Best match found so far.
        unsigned best_len = 0, best_d = 0;
        // Farthest distance allowed (no farther than the start of the data or the window), and longest length allowed (not past the block end).
        unsigned maxd = p < WINDOW ? p : WINDOW;
        unsigned maxl = end - p;
        if (maxl > MAX_LEN) maxl = MAX_LEN;
        // Search only when a match could be long enough to pay off.
        if (maxl >= MIN_LEN) {
            // Pointer to the byte being coded, and its value: a candidate must start with the same byte, which rejects most distances in a few instructions.
            const unsigned char *cur = buf + p;
            unsigned char c0 = cur[0];
            // Try each distance, nearest first.
            for (unsigned d = 1; d <= maxd; d++) {
                // Candidate position d bytes back.
                const unsigned char *cand = cur - d;
                // Skip quickly when the first byte differs.
                if (*cand != c0) continue;
                // Count how many bytes match at this distance (overlap with the bytes being coded is allowed).
                unsigned l = 1;
                while (l < maxl && cand[l] == cur[l]) l++;
                // Keep it only if strictly longer, so the nearest distance wins ties.
                if (l > best_len) { best_len = l; best_d = d; }
                // Nothing can beat the longest allowed match.
                if (best_len == maxl) break;
            }
        }
        if (best_len >= MIN_LEN) {
            // Match token: flag 1, distance-1, length-3.
            put_bits(1, 1); put_bits(best_d - 1, OFF_BITS); put_bits(best_len - MIN_LEN, LEN_BITS);
            // Skip the matched bytes.
            p += best_len;
        } else {
            // Literal token: flag 0 and the raw byte.
            put_bits(0, 1); put_bits(buf[p], 8);
            // Skip one byte.
            p++;
        }
    }
    // Slide the window: keep only the newest WINDOW bytes as history for the next block.
    hist = end;
    if (hist > WINDOW) {
        // Copy the newest WINDOW bytes to the front of buf.
        for (unsigned i = 0; i < WINDOW; i++) buf[i] = buf[hist - WINDOW + i];
        hist = WINDOW;
    }
    // Round the bit count up to whole bytes.
    return (outbits + 7u) >> 3;
}

#ifndef HOST
// ---------------------------------------------------------------- board side: bit-banged UART on the GPIO register

// GPIO register address (write: bit 0 led1, bit 1 led2, bit 2 TX; read: same bits plus bit 8 = RX pin).
#define GPIO      (*(volatile unsigned *)0x10000000)
// Clock cycles per UART bit: 25 MHz / 115200 baud = 217.01.
#define BIT_CYCLES 217u

// Shadow of the GPIO output register (TX idles high).
static unsigned gp_shadow = 0x04;

// This reads the free-running cycle counter.
static inline unsigned rdcycle(void) { unsigned v; __asm__ volatile("rdcycle %0" : "=r"(v)); return v; }

// This waits until the cycle counter reaches t (signed compare survives wrap).
static void wait_until(unsigned t) { while ((int)(rdcycle() - t) < 0) { } }

// This updates selected GPIO output bits and writes the register.
static void gpio_set(unsigned mask, unsigned val) { gp_shadow = (gp_shadow & ~mask) | val; GPIO = gp_shadow; }

// This sends one byte as 8N1 on the TX pin (gpio bit 2), timed from the cycle counter.
static __attribute__((noinline)) void uart_putc(unsigned c)
{
    // Start time of the frame.
    unsigned t = rdcycle();
    // Frame = start bit (0), 8 data bits LSB first, stop bit (1); bit 0 goes out first.
    unsigned v = ((c & 0xFFu) << 1) | 0x200u;
    // Send 10 bits, each timed from the frame start so there is no drift.
    for (int i = 0; i < 10; i++) {
        // Wait for this bit's slot, then drive the pin.
        wait_until(t);
        gpio_set(4u, (v & 1u) << 2);
        // Next bit.
        v >>= 1;
        t += BIT_CYCLES;
    }
    // Hold the stop bit for its full length.
    wait_until(t);
}

// This waits for a start bit on the RX pin (gpio read bit 8) and returns the received byte, sampling in the middle of each bit.
// It returns right after the last data bit (not after the stop bit) so the caller has about 1.5 bit times (325 cycles) to get back here
// before the next byte's start edge; the next call first waits for the line to be high, so it can never mistake data for a start bit.
static unsigned uart_getc(void)
{
    // If we are still inside the previous byte (line low), wait for the line to go high (stop bit or idle).
    while (!(GPIO & 0x100u)) { }
    // Wait until the line goes low again: the start bit.
    while (GPIO & 0x100u) { }
    // First sample time: 1.5 bit times after the start edge, which is the middle of data bit 0.
    unsigned t = rdcycle() + BIT_CYCLES + BIT_CYCLES / 2;
    unsigned v = 0;
    // Sample 8 data bits, least significant first.
    for (int i = 0; i < 8; i++) {
        wait_until(t);
        v |= ((GPIO >> 8) & 1u) << i;
        t += BIT_CYCLES;
    }
    return v;
}

// This is the program: wait for a block, compress it, send it back, forever.
int main(void)
{
    // led1 on = idle and ready, off while working.
    gpio_set(3u, 1u);
    for (;;) {
        // First byte of every request is the block length (0 = reset history).
        unsigned len = uart_getc();
        if (len == 0) {
            // Forget the history and acknowledge.
            hist = 0;
            uart_putc(0);
            continue;
        }
        // Clip the length to the block size.
        if (len > BLOCK) len = BLOCK;
        // Receive the raw bytes into buf after the history (keep this loop tight: it must be back at uart_getc within 325 cycles).
        for (unsigned i = 0; i < len; i++) buf[hist + i] = (unsigned char)uart_getc();
        // Busy: led1 off.
        gpio_set(1u, 0u);
        // Compress the block.
        unsigned n = compress_block(len);
        // Reply: compressed length, then the compressed bytes.
        uart_putc(n);
        for (unsigned i = 0; i < n; i++) uart_putc(out[i]);
        // Ready again: led1 on.
        gpio_set(1u, 1u);
    }
}

#else
// ---------------------------------------------------------------- PC side: same compressor, file in, block stream out

// This reads the file named by argv[1] and writes the block stream ([n][n bytes] per block) to the file named by argv[2].
int main(int argc, char **argv)
{
    // Open input and output.
    FILE *fi = fopen(argv[1], "rb"), *fo = fopen(argv[2], "wb");
    if (!fi || !fo) return 1;
    // Process the input in 64-byte blocks, exactly as the board would.
    for (;;) {
        // Read up to one block after the history.
        unsigned n = (unsigned)fread(buf + hist, 1, BLOCK, fi);
        if (n == 0) break;
        // Compress it and write the length and bytes.
        unsigned c = compress_block(n);
        fputc((int)c, fo);
        fwrite(out, 1, c, fo);
    }
    fclose(fi); fclose(fo);
    return 0;
}
#endif
