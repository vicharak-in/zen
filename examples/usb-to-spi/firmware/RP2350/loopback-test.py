# loopback-test.py - self-test for the usb_to_spi bridge on the Zen 4 (replaces the Shrike script, which needs the shrike module).
# Jumper header pad R-05 (m_mosi) to R-06 (m_miso) so the FPGA SPI master reads back its own output. Each byte sent comes back on the next transfer
# (the bridge is one transfer behind), so a trailing dummy byte flushes the last reply. Prints OK or MANGLED for each byte.
# Run with:  python -m mpremote run loopback-test.py   (zen_spi.py must be on the board)

import time
from zen_spi import ZenSPI

# Bytes to send through the bridge
TEST_BYTES = [0xBB, 0xCD, 0xEF, 0x42, 0x81, 0x00]

# Open the Zen Link byte port
spi = ZenSPI()

# Send every test byte, then one dummy byte to flush the last reply
sent = TEST_BYTES + [0x00]
replies = []
for b in sent:
    replies.append(spi.exchange(b))     # Reply of the previous SPI transfer
    time.sleep_ms(5)                    # Give the SPI master time to finish (it drops a byte that arrives while busy)

print("Sent   :", ["0x%02X" % b for b in sent])
print("Replies:", ["0x%02X" % r for r in replies])

# Reply number i+1 must equal test byte i
errors = 0
for i, b in enumerate(TEST_BYTES):
    got = replies[i + 1]
    if got == b:
        print("0x%02X -> 0x%02X OK" % (b, got))
    else:
        errors += 1
        print("0x%02X -> 0x%02X MANGLED" % (b, got))

print("Errors =", errors)
print("PASS" if errors == 0 else "FAIL")
