# aes-engine

An AES-128 engine written entirely in RTL (no CPU, no firmware) for the Vicharak Zen 4 (Trion T4F81) and Zen 8 (Trion T8F81).
The RP2350 reaches it over the Zen Link. Inside the FPGA a bridge turns the link bytes into the UART lines of the unchanged engine, so the UART command protocol below is the same as before.

```
PC --USB--> RP2350 (rp-pipe.py) --Zen Link--> FPGA: bridge -> uart_rx -> FIFO -> parser -> aes_core -> uart_tx -> bridge
```

**Board:** Vicharak Zen 4 (Efinix Trion T4F81 + RP2350), and Zen 8 (simulated only).

## Status

| Check | Result |
| --- | --- |
| Simulation (Icarus Verilog, self-checking) | passes, prints `ALL TESTS PASSED`: the engine on its own, the Zen 4 board top driven by real Zen Link frames, and the PC tool against a model |
| Efinity project, pad assignment, timing | built in Efinity 2026.1 for the T4F81: 2,879 / 3,888 logic elements (74%), 2,140 LUT4, 1,173 flip-flops, 6 RAM blocks; `clk` meets 50 MHz (maximum 50.6 MHz) and `clk_core` meets 25 MHz (maximum 32.2 MHz) |
| On hardware | the self-test passes on a Zen 4: `aes_host.py --via rp selftest` through `rp-pipe.py` on the RP2350, over the Zen Link. Only the self-test was run; file encryption and decryption were not tried. |

## Layout

- `rtl/` `aes-top.v` (parser, ECB, CTR), `aes-core.v` (key expansion + cipher), `aes-sbox-rom.v` (generated), `uart-rx.v`, `uart-tx.v`, `byte-fifo.v`, board tops `aes-zen4-top.v` and `aes-zen8-top.v`, `zl-uart-bridge.v`, `zl-afifo.v`, `zink/zen-link.v`, `zink/zl-slave.v`, `zink/zl-regs.v`
- `sim/` `run-sim.sh`, testbenches `tb-aes-core.v`, `tb-aes-top.v` and `tb-aes-zink.v`, `zink-host-model.vh`, generators `gen-sbox-rom.py` and `gen-vectors.py`, `test-host.py`
- `firmware/RP2350/` `rp-pipe.py`, `zink_uart.py`
- `firmware/pc-tools/` `aes_host.py`
- Efinity: `aes-engine.xml`, `aes-engine.peri.xml`, and `sdc/` (`aes-engine.sdc`)
- `bitstream/` `aes-engine.hex.bin`, the built bitstream (Efinity writes a new one to `outflow/` when you rebuild)

## Zen 4 vs Zen 8

One parameterised design. Only the parallelism differs.

| | Zen 4 | Zen 8 |
|---|---|---|
| `SB_LANES` (S-box lookups per clock) | 1 | 4 |
| `MC_PAR` (MixColumns columns per clock) | 1 | 4 |
| Clocks per 16-byte block | 272 | 125 |
| Key expansion | 160 clocks | 160 clocks |

Other measured settings: 2 lanes / 1 column = 192, 4 lanes / 1 column = 152 clocks. Clock is 25 MHz, so the core does about 1.5 MB/s on Zen 4 and 3.2 MB/s on Zen 8. The UART is the real limit (115200 baud is about 11 kB/s; 1 Mbaud is about 100 kB/s).

## Architecture

- Key expansion runs byte-serial on S-box ROM lane 0, and writes 44 round-key words into a block RAM. The result is independent of lane count.
- Cipher phases per round: ShiftRows (one clock, wire permutation), SubBytes (`SB_LANES` bytes per clock from a 512x8 ROM holding the forward and inverse tables), MixColumns, AddRoundKey (one column per clock).
- Decryption is the straight inverse cipher (not the equivalent one), so the same key schedule serves both directions. InvMixColumns is a pre-step `u=4(a0^a2), v=4(a1^a3)` followed by the forward MixColumns.
- The parser has a 512-byte receive FIFO. Keep every command at 256 bytes or less.
- After about 0.7 s without a received byte, the parser resets and the baud rate returns to 115200.

## UART protocol

8N1, 115200 baud after reset. Divisor `D` means baud = 25 MHz / D.

| Command | Bytes sent | Reply |
|---|---|---|
| Key | `K` + 16 bytes | `K` (after expansion) |
| Counter block | `I` + 16 bytes (big endian) | `I` |
| ECB encrypt | `E` + N + N*16 bytes (N = 1..255) | N*16 bytes |
| ECB decrypt | `D` + N + N*16 bytes | N*16 bytes |
| CTR | `C` + LEN_H + LEN_L + LEN bytes | LEN bytes |
| Baud | `B` + D (4..255, 0 = default) | `B` (at the old rate) |
| Version | `V` | `A` `E` `S` + config byte `{MC_PAR, SB_LANES}` |
| Anything else, N = 0, D = 1..3 | | `X` |

CTR notes: the 128-bit counter advances once per started block. Use chunk sizes that are multiples of 16 so a stream continues correctly across commands (`aes_host.py` uses 256).

## Clocks and pins

Two clocks from the same PLL: `clk` 50 MHz (Zen Link, bridge registers, divider 16) and `clk_core` 25 MHz (the engine, divider 32, as before). They meet only in the bridge's dual-clock FIFOs. The second PLL output (`clk_core`) builds and meets timing in Efinity.

| Signal | Pad | Note |
|---|---|---|
| clock | GPIOL_20 | 50 MHz oscillator, through the PLL |
| `btn1` (reset) | GPIOR_15 | active low |
| `led1` (busy), `led2` (error) | GPIOL_13, GPIOL_14 | active low |
| Zen Link `link_clk_in`, `link_csn_in` | GPIOL_09, GPIOL_10 | RP GPIO28, GPIO29 |
| Zen Link `link_d[7:0]` | GPIOL_00, 03, 05, 07, 04, 02, 01, 06 | RP GPIO24, 25, 26, 27, 0, 1, 2, 3 |

`led2` lights when the receive FIFO overflowed (sticky until reset).

## Zen Link registers (bridge)

| Address | Name | Use |
| --- | --- | --- |
| `0x100` | DATA | write: queue a byte for the engine; read: take a byte the engine sent (0 when none) |
| `0x101` | STATUS | bit0 data waiting, bit1 room to write, bit2 write overflow, bit3 receive overflow, bit4 idle |
| `0x102` / `0x103` | RXCNT / TXFREE | bytes waiting from the engine / room for more (max 255) |
| `0x104` / `0x105` | CPB_LO / CPB_HI | clocks per UART bit on the 25 MHz clock (217 = 115200 baud); `rp-pipe.py` sets it when the PC changes the baud rate |
| `0x180`..`0x1FF` | window | every address acts like DATA, up to 128 bytes in one frame |
| `0x10` | CTRL0 | bit 0 = software reset of the engine |

## Run

Simulation (needs `iverilog`, `python3`, and `cryptography` for the host test):

```
bash sim/run-sim.sh
```

On the board:

```
mpremote cp firmware/RP2350/zink_uart.py :        # once, then load the bitstream
mpremote run firmware/RP2350/rp-pipe.py           # on the RP2350 (or save it as main.py)
python3 firmware/pc-tools/aes_host.py --port COM5 --via rp selftest
python3 firmware/pc-tools/aes_host.py --port COM5 --via rp --div 25 --mode ctr --key 000102030405060708090a0b0c0d0e0f enc in.bin out.bin
```

ECB files are PKCS7 padded. CTR files are IV (16 bytes) followed by the cipher text.

## Verification so far

All self-checking, all passing in `run-sim.sh`:

- `tb-aes-core`: 68 cases (FIPS-197, NIST, zero, all-ones, 60 random), encrypt and decrypt, in four lane/column settings.
- `tb-aes-top`: version, unknown command, key load, ECB both directions, CTR with partial blocks and counter continuation, re-keying, baud switch, error replies, idle timeout. Three settings: 1/1, 4/4, 2/4.
- `tb-aes-zink`: the Zen 4 board top driven by real Zen Link frames: version, key load, ECB encrypt of the FIPS-197 block and decrypt back, unknown command.
- `test-host.py`: the PC tool against a Python model of the protocol.
- Mutation check: a CTR increment of +2 and single wrong entries in the forward and inverse S-box tables each make `tb-aes-top` fail (56, 262 and 64 errors).

## Area 



| | LUT4 | Block RAM (iCE40 4 Kb) |
|---|---|---|
| Zen 4 top | about 2470 | 4 |


