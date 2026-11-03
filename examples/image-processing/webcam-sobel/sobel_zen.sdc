# sobel_zen.sdc - timing for the UART Sobel filter on the Zen 4 (T4F81).
# Fabric clock: 50 MHz oscillator on GPIOL_20 -> PLL x16 / 32 = 25 MHz.
create_clock -period 40.000 -name clk [get_ports clk]
# UART RX and the button are asynchronous (two-flop synchronised in uart_rx.v and sobel_zen_top.v).
set_false_path -from [get_ports {btn1 uart_rx}]
# UART TX and the LEDs are slow outputs.
set_false_path -to [get_ports {uart_tx led1 led2}]
