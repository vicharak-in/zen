// Memory-mapped UART transmitter (8N1): firmware writes a byte, polls busy; idles high
// A hardware TX is used because SERV needs 30+ clocks per instruction, so a bit-banged 115200 baud loop is too tight at 25 MHz
`default_nettype none

module servxzen_uart_tx #(
    // Clock cycles per UART bit (25 MHz / 115200 = 217)
    parameter CLKS_PER_BIT = 217
) (
    // System clock
    input  wire       i_clk,
    // Synchronous active-high reset
    input  wire       i_rst,
    // Write strobe: start sending i_data when idle
    input  wire       i_start,
    // Byte to send
    input  wire [7:0] i_data,
    // High while a frame is being sent
    output wire       o_busy,
    // Serial output, idles high
    output wire       o_tx
);

    // Shift register holding stop bit, 8 data bits and start bit (LSB sent first)
    reg [9:0] shift = 10'h3FF;
    // Number of bits still to send (0 = idle)
    reg [3:0] bits  = 4'd0;
    // Clock divider counter for one bit time
    reg [$clog2(CLKS_PER_BIT)-1:0] cnt = 0;

    // Busy while any bit remains
    assign o_busy = (bits != 4'd0);
    // Line is the lowest shift bit; shift register fills with ones so the line idles high
    assign o_tx   = shift[0];

    // Transmit block: loads a frame on start, then shifts one bit per CLKS_PER_BIT clocks
    always @(posedge i_clk) begin
        // Reset block: force idle state
        if (i_rst) begin
            // Line high
            shift <= 10'h3FF;
            // No bits pending
            bits  <= 4'd0;
            // Divider cleared
            cnt   <= 0;
        end else if (bits == 4'd0) begin
            // Idle: accept a new byte (frame = stop, data, start)
            if (i_start) begin
                // Load {stop=1, data, start=0}
                shift <= {1'b1, i_data, 1'b0};
                // Ten bits to send
                bits  <= 4'd10;
                // Restart the bit timer
                cnt   <= 0;
            end
        end else begin
            // Sending: wait out one bit time
            if (cnt == CLKS_PER_BIT - 1) begin
                // Next bit slot starts
                cnt   <= 0;
                // Shift right, filling with ones
                shift <= {1'b1, shift[9:1]};
                // One fewer bit left
                bits  <= bits - 4'd1;
            end else begin
                // Keep counting
                cnt <= cnt + 1'b1;
            end
        end
    end

endmodule
