// This is a UART transmitter (8N1): a byte is accepted when valid and ready are both high, then sent as start bit, 8 data bits, stop bit.
`timescale 1 ns / 1 ps

module uart_tx (
    // System clock
    input  wire       clk,
    // Clock cycles per UART bit (25 MHz / 115200 = 217); must not change while a frame is going out
    input  wire [7:0] cpb,
    // Active-low reset
    input  wire       rst_n,
    // The sender has a byte
    input  wire       valid,
    // The byte to send (must stay stable while valid is high)
    input  wire [7:0] data,
    // High when the transmitter is idle and will take a byte this clock
    output wire       ready,
    // Serial output (idles high)
    output reg        tx
);

    // High while a frame is going out
    reg       busy;
    // Frame being sent: stop bit, data bits, start bit (bit 0 is the one on the wire)
    reg [9:0] sh;
    // Index of the bit being sent (0 = start bit, 9 = stop bit)
    reg [3:0] n;
    // Clock-cycle counter inside a bit
    reg [7:0] cnt;

    // Ready whenever no frame is in progress
    assign ready = !busy;

    // Transmitter always block: loads a frame and shifts it out one bit per CPB clocks
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset: idle line, no frame
            busy <= 1'b0;
            tx   <= 1'b1;
        end else if (!busy) begin
            // Idle: keep the line high and wait for a byte
            tx <= 1'b1;
            if (valid) begin
                // Load the frame, start the start bit now
                sh   <= {1'b1, data, 1'b0};
                busy <= 1'b1;
                n    <= 4'd0;
                cnt  <= cpb - 8'd1;
                tx   <= 1'b0;
            end
        end else if (cnt == 0) begin
            // End of a bit time
            cnt <= cpb - 8'd1;
            if (n == 4'd9) begin
                // The stop bit has been sent for a full bit time: finished
                busy <= 1'b0;
            end else begin
                // Move to the next bit
                n  <= n + 1'b1;
                tx <= sh[1];
                sh <= {1'b1, sh[9:1]};
            end
        end else begin
            // Inside a bit: keep counting
            cnt <= cnt - 1'b1;
        end
    end

endmodule
