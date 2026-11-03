# i2c-to-spi-bridge timing constraints
# Fabric clock: 50 MHz (50 MHz oscillator on GPIOL_20 through the PLL x16 / 16)
create_clock -period 20.000 -name clk [get_ports clk]
set_false_path -from [get_ports {sda_in scl spi_miso}]
set_false_path -to [get_ports {sda_out sda_oe spi_sclk spi_ss spi_mosi led1}]
