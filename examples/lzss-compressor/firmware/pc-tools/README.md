# firmware/pc-tools

PC side of compengine. Needs Python 3 and `pip install pyserial` (not needed for decompress or the tests).

| File | Use |
| --- | --- |
| `compress.cmd`, `decompress.cmd` | Windows wrappers: `.\compress FILE`, `.\decompress FILE.lzb`; `--rp COM8` goes through the RP2350 |
| `compengine.py` | the compress / decompress tool behind the wrappers |
| `zink_uart.py` | UART-style helper for the Zen Link; `compengine.py` sends it to the RP2350 in front of its programs (no copying needed) |
| `lzss_ref.py` | Python reference encoder and decoder (other scripts import it, hence the underscore) |
| `lzss-host.py` | compress on the PicoRV32 build (`PicoRV32-Zen/examples/lzss`) and compare with the reference; use `rp:COM8` as the port to go through the RP2350 and the Zen Link |
| `hw-probe.py`, `rp-check.py` | check the Zen Link and the hardware engine through the RP2350 |
| `tests/test-compengine.py` | tests the tool against a simulated board, no hardware: the RP2350 programs run on CPython against a fake Zen Link (`python3 tests/test-compengine.py`) |
| `samples/` | `cat.png`, `fakeimu.csv`, `test.txt` and compressed examples |
