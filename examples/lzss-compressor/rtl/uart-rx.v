// This is a UART receiver (8N1): it samples every bit in the middle and pulses valid for one clock when a byte is complete.
`timescale 1 ns / 1 ps

module uart_rx (
    // System clock
    input  wire       clk,
    // Clock cycles per UART bit (25 MHz / 115200 = 217); may change between bytes
    input  wire [7:0] cpb,
    // Active-low reset
    input  wire       rst_n,
    // Serial input, already synchronised to clk (idles high)
    input  wire       rx,
    // One-clock pulse when data holds a new byte
    output reg        valid,
    // The received byte
    output reg  [7:0] data
);

    // Half a bit time, used to find the middle of the start bit
    wire [7:0] half = cpb >> 1;
    // State: waiting for the start edge
    localparam S_IDLE  = 2'd0;
    // State: waiting for the middle of the start bit
    localparam S_START = 2'd1;
    // State: sampling the 8 data bits
    localparam S_DATA  = 2'd2;
    // State: waiting for the middle of the stop bit
    localparam S_STOP  = 2'd3;

    // Current state
    reg [1:0] st;
    // Clock-cycle counter inside a bit
    reg [7:0] cnt;
    // Number of data bits received so far
    reg [2:0] nbit;
    // Shift register that collects the data bits (least significant bit first)
    reg [7:0] sh;

    // Receiver always block: runs the bit-sampling state machine
    always @(posedge clk) begin
        // The valid pulse lasts one clock unless set again below
        valid <= 1'b0;
        if (!rst_n) begin
            // Reset: back to idle
            st <= S_IDLE;
        end else begin
            case (st)
                // Idle: a low level is the start of a start bit
                S_IDLE: if (!rx) begin
                    // Count half a bit to reach the middle of the start bit
                    st  <= S_START;
                    cnt <= half - 8'd1;
                end
                // Start bit: confirm it is still low in the middle, else it was a glitch
                S_START: begin
                    if (cnt == 0) begin
                        if (!rx) begin
                            // Real start bit: sample the first data bit one full bit later
                            st   <= S_DATA;
                            cnt  <= cpb - 8'd1;
                            nbit <= 3'd0;
                        end else begin
                            // Glitch: go back to idle
                            st <= S_IDLE;
                        end
                    end else cnt <= cnt - 1'b1;
                end
                // Data bits: sample in the middle of each bit, least significant first
                S_DATA: begin
                    if (cnt == 0) begin
                        // Shift the new bit in from the top
                        sh   <= {rx, sh[7:1]};
                        cnt  <= cpb - 8'd1;
                        nbit <= nbit + 1'b1;
                        // After the eighth bit wait for the middle of the stop bit
                        if (nbit == 3'd7) st <= S_STOP;
                    end else cnt <= cnt - 1'b1;
                end
                // Stop bit: report the byte in the middle of the stop bit so the next start edge is not missed
                S_STOP: begin
                    if (cnt == 0) begin
                        valid <= 1'b1;
                        data  <= sh;
                        st    <= S_IDLE;
                    end else cnt <= cnt - 1'b1;
                end
            endcase
        end
    end

endmodule
