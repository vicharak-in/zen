import machine, utime

FILE_NAME = "serv-core.hex.bin"

# --- verify against Configuration Timing, p.20-21 ---
T_CRESET_US = 10
T_DMIN_US   = 10
DUMMY_BYTES = 10

spi = machine.SoftSPI(baudrate=16_000_000,
                      polarity=0, phase=0,
                      sck=machine.Pin(1),    # CCK
                      mosi=machine.Pin(0),   # CDI
                      miso=machine.Pin(3))   # unused, dummy

ss     = machine.Pin(2, machine.Pin.OUT, value=0)
cdone  = machine.Pin(4, machine.Pin.IN, machine.Pin.PULL_UP)
creset = machine.Pin(5, machine.Pin.OUT, value=1)

def configure():
    ss.value(0)                      # strap low = passive mode
    creset.value(0)
    utime.sleep_us(T_CRESET_US)
    creset.value(1)                  # mode latched on this edge
    utime.sleep_us(T_DMIN_US)

    if cdone.value():
        print("warning: CDONE high before bitstream")

    n = 0
    with open(FILE_NAME, 'rb') as f:
        while True:
            chunk = f.read(1024)
            if not chunk:
                break
            spi.write(chunk)
            n += len(chunk)

    spi.write(bytes(DUMMY_BYTES))
    print(f"sent {n} bytes, CDONE = {cdone.value()}")

configure()

