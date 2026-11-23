// uart-to-i2c-bridge-zen4-top.v - board top for the UART -> I2C bridge on the Vicharak Zen 4 (Trion T4F81).
// The UART (115200 8N1) is on the pads wired to the RP2350 UART1 (GPIO24 / GPIO25). The FPGA is the I2C master (100 kHz) of a sensor at 0x50: each UART byte is written to the sensor, one byte is read back and sent
// on the UART. SDA and SCL are open-drain pads and need external pull-up resistors.

module uart_to_i2c_bridge_zen4_top (
    input  wire clk,       // 50 MHz fabric clock from the PLL
    input  wire uart_rx,   // UART receive (RP2350 UART1 TX, GPIO24)
    output wire uart_tx,   // UART transmit (RP2350 UART1 RX, GPIO25)
    input  wire sda_in,    // I2C SDA pad input
    output wire sda_out,   // I2C SDA pad output (always low)
    output wire sda_oe,    // I2C SDA pull-down enable
    input  wire scl_in,    // I2C SCL pad input
    output wire scl_out,   // I2C SCL pad output (always low)
    output wire scl_oe     // I2C SCL pull-down enable
);

    // This contains the instantiation for the bridge
    uart_to_i2c_bridge #(.CLK(50000000), .BAUD_RATE(115200)) u_bridge (
        .clk(clk), .i_uart_rx(uart_rx), .o_uart_tx(uart_tx),
        .i_i2c_sda(sda_in), .i_i2c_scl(scl_in), .o_i2c_scl(scl_out), .o_i2c_scl_oe(scl_oe), .o_i2c_sda(sda_out), .o_i2c_sda_oe(sda_oe));

endmodule
