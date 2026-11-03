# main.py - example use of dspi_bus.py on the Zen 4 (ported from the Shrike example: the flash call is gone, the pins come from dspi_bus.py).
import time
from dspi_bus import DSPI

# 1. Initialize the bus (uses the Zen 4 default pins CS 29, SCK 28, data 24/25; load dspi-pio-echo into the FPGA first)
fpga_bus = DSPI()

print("Bus initialized. Sending one-time test packet...")

# ---------------------------------------------------------
# ONE-TIME TRANSMISSION
# ---------------------------------------------------------
tx_string = "hello, how Are you?"
rx_data = fpga_bus.transfer(tx_string)

print(f"Sent: {tx_string}")
print(f"Received (Hex): {[hex(b) for b in rx_data]}")

print("\nEntering listening mode for FPGA alerts (Press Ctrl+C to stop)...")

# ---------------------------------------------------------
# CONTINUOUS LISTENING LOOP
# ---------------------------------------------------------
while True:
    # Check if the FPGA triggered the IRQ pin
    if fpga_bus.has_alert():
        # Read the alert code by sending a dummy byte
        alert_data = fpga_bus.transfer([ord('?')]) 
        print(f"[ALERT] FPGA initiated communication: {hex(alert_data[0])}")

    # Sleep briefly to yield CPU time, keeping it highly responsive to IRQs
    time.sleep(0.1)