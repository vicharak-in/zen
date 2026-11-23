// uart-led.v - UART-controlled LED: byte 0xAB switches the LED on, byte 0xFF switches it off, any other byte leaves it as it was.
// Ported from the Shrike example. Changes from the original: reset has priority over the byte decode, and the decode acts only on the receiver's byte-valid
// strobe (the original looked at the held byte every clock, so a reset was undone straight away by the last 0xAB still sitting in the receiver).

module uart_led #(
    parameter CLK       = 50_000_000, // Fabric clock in Hz
    parameter BAUD_RATE = 115200      // UART baud rate
) (
    input  wire clk,     // Fabric clock
    input  wire rst,     // Reset, active high
    input  wire rx,      // UART receive line (synchronised)
    output reg  led = 1'b0 // LED state, 1 = on
);

    // Received byte
    wire [7:0] data;
    // Byte-valid strobe: one clock when a complete byte has arrived
    wire data_valid;

    // This contains the instantiation for the UART receiver
    uart_rx #(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) U_uart_rx (.i_Clock(clk), .i_RX_Serial(rx), .o_RX_DV(data_valid), .o_RX_Byte(data));

    // This block sets and clears the LED from the last received byte
    always @(posedge clk) begin
        if (rst) led <= 1'b0;
        else if (data_valid && data == 8'hAB) led <= 1'b1;
        else if (data_valid && data == 8'hFF) led <= 1'b0;
    end

endmodule
