# picorv32-lzss timing constraints
# Two clocks from the same PLL: clk (50 MHz, Zen Link) and clk_core (25 MHz, the design). They only meet inside the dual-clock FIFOs and a few
# synchronised flags, so they are declared asynchronous to each other.
create_clock -period 20.000 -name clk [get_ports clk]
create_clock -period 40.000 -name clk_core [get_ports clk_core]
set_clock_groups -asynchronous -group {clk} -group {clk_core}
set_false_path -from [get_ports {link_clk_in link_csn_in link_d_in[*] btn1}]
set_false_path -to [get_ports {link_d_out[*] link_d_oe[*] led1 led2}]
