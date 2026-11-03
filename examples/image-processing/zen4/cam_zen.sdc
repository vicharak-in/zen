# cam_zen.sdc - timing for the camera-to-VGA design on the Zen 4 (T4F81).
# Fabric clock: 50 MHz oscillator on GPIOL_20 -> PLL x16 / 32 = 25 MHz.
create_clock -period 40.000 -name clk25 [get_ports clk25]
# The RP2350 pixel bus, strobes and the button are asynchronous (two-flop synchronised in ov7670_writer.v and cam_zen_top.v).
set_false_path -from [get_ports {btn1 cam_we cam_vsync cam_pixel[*]}]
# VGA colour and sync pins feed resistor ladders and a monitor, the LEDs are slow outputs.
set_false_path -to [get_ports {vga_r[*] vga_g[*] vga_b[*] vga_hs vga_vs led1 led2}]
