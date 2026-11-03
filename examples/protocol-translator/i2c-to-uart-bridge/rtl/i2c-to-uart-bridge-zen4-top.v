// i2c-to-uart-bridge-zen4-top.v - board top for the I2C <-> UART bridge on the Vicharak Zen 4 (Trion T4F81).
// The FPGA is an I2C slave at 0x50 (100 kHz, SDA open-drain, needs external pull-ups) and a full-duplex UART (115200 8N1) on the pads wired to the RP2350 UART1 (GPIO24 / GPIO25).
// A byte written over I2C goes out on the UART; the last byte received on the UART is what the next I2C read returns.

module i2c_to_uart_bridge_zen4_top (
    input  wire clk,       // 50 MHz fabric clock from the PLL
    input  wire uart_rx,   // UART receive (RP2350 UART1 TX, GPIO24)
    output wire uart_tx,   // UART transmit (RP2350 UART1 RX, GPIO25)
    input  wire sda_in,    // I2C SDA pad input
    output wire sda_out,   // I2C SDA pad output (always low)
    output wire sda_oe,    // I2C SDA pull-down enable
    input  wire scl         // I2C SCL (input only)
);

    // This contains the instantiation for the bridge
    i2c_to_uart_bridge u_bridge (
        .clk(clk), .i_uart_rx(uart_rx), .o_uart_tx(uart_tx),
        .i_i2c_sda(sda_in), .i_i2c_scl(scl), .o_i2c_sda(sda_out), .o_i2c_sda_oe(sda_oe));

endmodule
