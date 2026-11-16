# chess_fpga timing constraints (same pins and clock plan as zink_aes; the file name must match the project name)
# Fabric clock: PLL x16 / 32 = 25 MHz (the same clock plan as zink_aes)
create_clock -period 40.000 -name clk [get_ports clk]
# The Zen Link pins are asynchronous to clk and oversampled by the synchronisers in
# zl_slave.v (CLK / CS_N / D go through 2-3 flops), so they are not timed against clk.
set_false_path -from [get_ports {link_clk_in link_csn_in link_d_in[*]}]
set_false_path -to [get_ports {link_d_out[*] link_d_oe[*]}]
# Buttons are asynchronous (two-flop synchronised in btn_debounce.v) and the LEDs are slow outputs.
set_false_path -from [get_ports {btn1 btn2}]
set_false_path -to [get_ports {led1 led2}]
