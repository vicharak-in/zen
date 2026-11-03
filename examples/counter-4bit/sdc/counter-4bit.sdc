# counter-4bit timing constraints
# Fabric clock: 50 MHz (50 MHz oscillator on GPIOL_20 through the PLL x16 / 16)
create_clock -period 20.000 -name clk [get_ports clk]
set_false_path -from [get_ports {btn1 btn2}]
set_false_path -to [get_ports {count[*] led1}]
