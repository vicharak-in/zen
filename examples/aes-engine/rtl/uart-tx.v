// uart-tx.v - UART transmitter, 8N1, with a run-time clocks-per-bit setting (minimum 4).

module uart_tx (
    input  wire        clk,   // Clock
    input  wire        rst,   // Synchronous reset, active high
    input  wire [15:0] cpb,   // Clocks per bit (clock frequency / baud rate)
    input  wire [7:0]  data,  // Byte to send, sampled when start is high
    input  wire        start, // One clock pulse: send data (ignored while busy)
    output reg         tx,    // Serial output to the pin (idle high)
    output reg         busy   // High from the start pulse until the stop bit has finished
);

    // Down counter that times one bit
    reg [15:0] cnt;
    // Data bits followed by the stop bit, shifted out LSB first
    reg [8:0]  sh;
    // Number of bits already started after the start bit
    reg [3:0]  n;

    // This block sends frames: start bit, eight data bits, stop bit
    always @(posedge clk) begin
        if (rst) begin
            tx   <= 1'b1;                                         // Idle high
            busy <= 1'b0;                                         // Not sending
        end else if (!busy) begin
            if (start) begin
                tx   <= 1'b0;                                     // Start bit
                sh   <= {1'b1, data};                             // Data bits plus the stop bit behind them
                n    <= 4'd0;                                     // No data bit sent yet
                cnt  <= cpb - 16'd1;                              // Time one bit
                busy <= 1'b1;                                     // Now sending
            end
        end else begin
            if (cnt == 16'd0) begin
                cnt <= cpb - 16'd1;                               // Time the next bit
                if (n == 4'd9) begin
                    busy <= 1'b0;                                 // The stop bit has been held for one bit time: done
                end else begin
                    tx <= sh[0];                                  // Next data bit (the ninth shift gives the stop bit)
                    sh <= {1'b1, sh[8:1]};                        // Shift on
                    n  <= n + 4'd1;                               // Count it
                end
            end else begin
                cnt <= cnt - 16'd1;                               // Keep counting down
            end
        end
    end

endmodule
