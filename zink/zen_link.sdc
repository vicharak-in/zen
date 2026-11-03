# zen_link timing constraints
# Fabric clock: 50 MHz oscillator -> run at 50 MHz (oscillator directly, or PLL x16 / 16)
create_clock -period 20.000 -name clk [get_ports clk]
# The Zen Link pins are asynchronous to clk and oversampled by the synchronisers in
# zl_slave.v (CLK / CS_N / D go through 2-3 flops), so they are not timed against clk.
set_false_path -from [get_ports {link_clk_in link_csn_in link_d_in[*]}]
set_false_path -to [get_ports {link_d_out[*] link_d_oe[*]}]
# Buttons are asynchronous (two-flop synchronised in top.v) and the LEDs are slow outputs.
set_false_path -from [get_ports {btn1 btn2}]
set_false_path -to [get_ports {led1 led2}]
