// uart-sum.v - receives two bytes over UART and sends back their 8-bit sum (num1 + num2, wraps at 256).
// Ported from the Shrike example (module "top") to the Zen 4: only the Forge pad attributes and the clk_en / tx_en ports were removed; the logic is unchanged.

module uart_sum #(
    parameter CLK       = 50_000_000, // Fabric clock in Hz
    parameter BAUD_RATE = 115200      // UART baud rate
) (
    input  wire clk,   // Fabric clock
    input  wire rst,   // Reset, active high
    input  wire rx,    // UART receive line (synchronised)
    output wire tx     // UART transmit line
);

    // Operands and result
    reg [7:0] num1 = 8'd0, num2 = 8'd0, sum = 8'd0;
    // Transmit-start pulse
    reg flag = 1'b0;
    // Received byte and its valid strobe
    wire [7:0] data;
    wire data_valid;

    // This contains the instantiation for the UART receiver
    uart_rx #(.CLK(CLK), .BAUD_RATE(BAUD_RATE)) U_uart_rx (.i_Clock(clk), .i_RX_Serial(rx), .o_RX_DV(data_valid), .o_RX_Byte(data));

    // This contains the instantiation for the UART transmitter
    uart_tx #(.IN_CLK_HZ(CLK), .DATA_FRAME(8), .BAUD_RATE(BAUD_RATE), .OVERSAMPLING_MODE(16), .STOP_BIT(1), .LSB(1'b0)) U_uart_tx (
        .i_clk(clk), .i_rst(rst), .o_tx(tx),
        .i_tx_data(sum),     // sum = num1 + num2
        .i_tx_start(flag),   // transmit the sum when flag is high
        .o_tx_done());

    // States of the sum machine
    localparam S1 = 2'b00;  // Wait for the first byte
    localparam S2 = 2'b01;  // Wait for the second byte
    localparam S3 = 2'b10;  // Add and start the transmitter
    localparam S4 = 2'b11;  // Drop the start pulse

    // State
    reg [1:0] state = S1;

    // This block collects two bytes, adds them and starts the transmitter
    always @(posedge clk) begin
        if (rst) begin
            state <= S1;
        end else begin
            if (state == S1 && data_valid) begin
                num1 <= data;
                state <= S2;
            end else if (state == S2 && data_valid) begin
                num2 <= data;
                state <= S3;
            end else if (state == S3) begin
                sum <= num1 + num2;
                flag <= 1'b1;
                state <= S4;
            end else if (state == S4) begin
                flag <= 1'b0;
                state <= S1;
            end
        end
    end

endmodule
