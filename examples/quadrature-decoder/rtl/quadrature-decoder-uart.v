// quadrature-decoder-uart.v - decoder + packetizer + UART transmitter in one block (the "top" of the Shrike example, renamed and without the pad/enable ports).
// The Shrike top tied the decoder reset low and the UART reset high; here one reset input drives both.

module quadrature_decoder_uart #(
    parameter WIDTH        = 16,          // Width of position and speed
    parameter CLK_FREQ     = 50_000_000,  // Fabric clock in Hz
    parameter UPDATE_MS    = 500,         // Speed window and packet interval in ms
    parameter CPR          = 4000,        // Counts per revolution (4x decoding)
    parameter CLKS_PER_BIT = 434          // Clocks per UART bit (50 MHz / 115200)
) (
    input  wire clk,        // Fabric clock
    input  wire rst,        // Reset, active high
    input  wire enc_a,      // Encoder channel A
    input  wire enc_b,      // Encoder channel B
    output wire uart_tx,    // UART out (8-byte packets)
    output wire direction   // Last step direction, 1 = forward
);

    // Measurement from the decoder
    wire signed [15:0] position;
    wire signed [15:0] speed;
    wire [15:0] angle;
    wire data_valid;
    // UART handshake and byte
    wire uart_active;
    wire uart_dv;
    wire [7:0] uart_byte;

    // This contains the instantiation for the quadrature decoder
    quadrature_decoder #(.WIDTH(WIDTH), .CLK_FREQ(CLK_FREQ), .UPDATE_MS(UPDATE_MS), .CPR(CPR)) QUAD_DEC_INST (
        .clk(clk), .rst(rst), .enc_a(enc_a), .enc_b(enc_b),
        .position(position), .speed(speed), .angle(angle), .direction(direction), .data_valid(data_valid));

    // This contains the instantiation for the packetizer
    uart_packetizer PKT_SENDER (
        .clk(clk), .position(position), .speed(speed), .angle(angle), .direction(direction), .data_valid(data_valid),
        .uart_busy(uart_active), .uart_dv(uart_dv), .uart_byte(uart_byte));

    // This contains the instantiation for the UART transmitter (its reset is active low)
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_TX (
        .rst(~rst), .clk(clk), .i_TX_DV(uart_dv), .i_TX_Byte(uart_byte), .o_TX_Active(uart_active), .o_TX_Serial(uart_tx), .o_TX_Done());

endmodule
