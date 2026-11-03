# spi-to-i2c-bridge timing constraints
# Fabric clock: 50 MHz (50 MHz oscillator on GPIOL_20 through the PLL x16 / 16)
create_clock -period 20.000 -name clk [get_ports clk]
set_false_path -from [get_ports {spi_sck spi_mosi spi_ss sda_in scl_in}]
set_false_path -to [get_ports {spi_miso_out spi_miso_oe sda_out sda_oe scl_out scl_oe}]
