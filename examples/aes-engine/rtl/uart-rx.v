// uart-rx.v - UART receiver, 8N1, with a run-time clocks-per-bit setting (minimum 4).

module uart_rx (
    input  wire        clk,   // Clock
    input  wire        rst,   // Synchronous reset, active high
    input  wire [15:0] cpb,   // Clocks per bit (clock frequency / baud rate)
    input  wire        rx,    // Serial input from the pin (idle high)
    output reg  [7:0]  data,  // Received byte, valid when valid is high
    output reg         valid  // One clock pulse for every received byte
);

    // Two flip-flops that bring the asynchronous pin into the clock domain
    reg [1:0]  sync;
    // Down counter that times the bit centres
    reg [15:0] cnt;
    // Bit number: 0 = start bit check, 1..8 = data bits, 9 = stop bit
    reg [3:0]  bitn;
    // Shift register that collects the data bits (LSB arrives first)
    reg [7:0]  sh;
    // High while a frame is being received
    reg        busy;

    // This block receives frames: it finds the start edge, then samples every bit in its middle
    always @(posedge clk) begin
        sync  <= {sync[0], rx};                                   // Synchronise the input
        valid <= 1'b0;                                            // Default: no byte this clock
        if (rst) begin
            busy <= 1'b0;                                         // Idle
        end else if (!busy) begin
            if (!sync[1]) begin
                busy <= 1'b1;                                     // The line went low: a start bit begins
                cnt  <= {1'b0, cpb[15:1]} - 16'd1;                // Wait half a bit to reach the middle of the start bit
                bitn <= 4'd0;                                     // Next sample is the start bit check
            end
        end else begin
            if (cnt == 16'd0) begin
                cnt <= cpb - 16'd1;                               // One full bit until the next sample
                if (bitn == 4'd0) begin
                    if (sync[1]) busy <= 1'b0;                    // The line is high again: it was a glitch, not a start bit
                    else bitn <= 4'd1;                            // A real start bit, go on with the data bits
                end else if (bitn <= 4'd8) begin
                    sh   <= {sync[1], sh[7:1]};                   // Shift the sampled bit in at the top
                    bitn <= bitn + 4'd1;                          // Next bit
                end else begin
                    if (sync[1]) begin
                        data  <= sh;                              // The stop bit is high: the frame is good
                        valid <= 1'b1;                            // Announce the byte
                    end
                    busy <= 1'b0;                                 // Ready for the next frame
                end
            end else begin
                cnt <= cnt - 16'd1;                               // Keep counting down
            end
        end
    end

endmodule
