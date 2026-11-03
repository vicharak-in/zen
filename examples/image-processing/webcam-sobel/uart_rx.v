// uart_rx.v - 8N1 UART receiver, samples the middle of each bit (sample point centred for high baud rates).

`default_nettype none

module uart_rx #(
    parameter CLKS_PER_BIT = 868           // clock / baud (100 MHz / 115200)
) (
    input  wire       clk,                  // clock
    input  wire       rst,                  // synchronous reset, active high
    input  wire       rx,                   // serial input (idle high)
    output reg  [7:0] data,                 // received byte
    output reg        valid                 // one-clock pulse: data holds a new byte
);

    // Width of the bit-time counter.
    localparam CW = $clog2(CLKS_PER_BIT + 1);
    // Clocks from the start edge to the middle of the start bit, less the synchroniser and state latency (about 1 clock).
    localparam HALF = (CLKS_PER_BIT / 2 > 1) ? (CLKS_PER_BIT / 2 - 1) : 0;
    // Receiver states.
    localparam [1:0] R_IDLE = 2'd0, R_START = 2'd1, R_BITS = 2'd2, R_STOP = 2'd3;

    // Two-flop synchroniser for the asynchronous input.
    reg [1:0]    sy = 2'b11;
    // State.
    reg [1:0]    st;
    // Clock counter within a bit.
    reg [CW-1:0] cnt;
    // Bit index.
    reg [2:0]    bi;
    // Shift register.
    reg [7:0]    sh;
    // Synchronised input.
    wire         rxs = sy[1];

    // Receiver: wait for the start edge, check the start bit in its middle, then sample 8 bits and the stop bit.
    always @(posedge clk) begin
        // Shift the input through the synchroniser.
        sy    <= {sy[0], rx};
        // valid is a single-clock pulse.
        valid <= 1'b0;
        // Reset to idle.
        if (rst) begin
            // Idle.
            st <= R_IDLE;
        end else begin
            // State dispatch.
            case (st)
                // Line idle: a low level is a start bit.
                R_IDLE: if (!rxs) begin
                    // Count to the middle of the start bit.
                    cnt <= 0;
                    // Next state.
                    st  <= R_START;
                end
                // Middle of the start bit: still low means a real start.
                R_START: if (cnt == HALF) begin
                    // Restart the bit counter.
                    cnt <= 0;
                    // First data bit.
                    bi  <= 3'd0;
                    // Glitch: back to idle; real start: receive bits.
                    st  <= rxs ? R_IDLE : R_BITS;
                end else cnt <= cnt + 1'b1;
                // One full bit time later sample the next data bit (LSB first).
                R_BITS: if (cnt == CLKS_PER_BIT - 1) begin
                    // Restart the bit counter.
                    cnt <= 0;
                    // Shift the bit in at the top.
                    sh  <= {rxs, sh[7:1]};
                    // Count bits.
                    bi  <= bi + 3'd1;
                    // After bit 7 check the stop bit.
                    if (bi == 3'd7) st <= R_STOP;
                end else cnt <= cnt + 1'b1;
                // Stop bit: report the byte if it is high.
                R_STOP: if (cnt == CLKS_PER_BIT - 1) begin
                    // Output the byte.
                    data  <= sh;
                    // Valid only with a proper stop bit.
                    valid <= rxs;
                    // Back to idle.
                    st    <= R_IDLE;
                end else cnt <= cnt + 1'b1;
            endcase
        end
    end

endmodule

`default_nettype wire
