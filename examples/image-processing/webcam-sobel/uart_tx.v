// uart_tx.v - 8N1 UART transmitter.

`default_nettype none

module uart_tx #(
    parameter CLKS_PER_BIT = 868           // clock / baud (100 MHz / 115200)
) (
    input  wire       clk,                  // clock
    input  wire       rst,                  // synchronous reset, active high
    input  wire [7:0] data,                 // byte to send
    input  wire       send,                 // one-clock pulse: start sending data (ignored while busy)
    output reg        tx,                   // serial output (idle high)
    output wire       busy                  // high while a byte is being sent
);

    // Width of the bit-time counter.
    localparam CW = $clog2(CLKS_PER_BIT + 1);

    // Frame shift register: stop bit, 8 data bits, start bit (sent LSB first).
    reg [9:0]    sh;
    // Bits left to send.
    reg [3:0]    left;
    // Clock counter within a bit.
    reg [CW-1:0] cnt;

    // Busy while bits remain.
    assign busy = (left != 4'd0);

    // Transmitter: load a 10-bit frame and shift one bit out per bit time.
    always @(posedge clk) begin
        // Reset to idle.
        if (rst) begin
            // Line idle high.
            tx   <= 1'b1;
            // Nothing to send.
            left <= 4'd0;
        end else if (!busy) begin
            // Line idle high.
            tx <= 1'b1;
            // New byte to send.
            if (send) begin
                // Stop bit, data, start bit.
                sh   <= {1'b1, data, 1'b0};
                // Ten bits.
                left <= 4'd10;
                // Fresh bit time.
                cnt  <= 0;
            end
        end else begin
            // Current bit on the line.
            tx <= sh[0];
            // End of the bit time.
            if (cnt == CLKS_PER_BIT - 1) begin
                // Restart the counter.
                cnt  <= 0;
                // Next bit.
                sh   <= {1'b1, sh[9:1]};
                // One fewer.
                left <= left - 4'd1;
            end else cnt <= cnt + 1'b1;
        end
    end

endmodule

`default_nettype wire
