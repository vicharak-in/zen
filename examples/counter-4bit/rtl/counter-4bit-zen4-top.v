// counter-4bit-zen4-top.v - board top for counter_4bit on the Zen 4: count on four header pads, LED 1 shows bit 0.
// btn1 resets the counter (hold to keep it at zero), btn2 counts down while held (up when released). Fabric clock is 50 MHz (PLL x16 / 16).

module counter_4bit_zen4_top (
    input  wire       clk,    // 50 MHz fabric clock from the PLL
    input  wire       btn1,   // Button 1, active low: reset
    input  wire       btn2,   // Button 2, active low: hold to count down
    output wire [3:0] count,  // Header pads, active high
    output wire       led1    // On-board LED 1, active low
);

    // Two-flop synchroniser for the reset button (reset value 0 keeps the counter in reset until the first clocks)
    reg [1:0] rst_sync = 2'b00;
    // Two-flop synchroniser for the direction button
    reg [1:0] dir_sync = 2'b11;

    // This block brings the asynchronous buttons into the clock domain
    always @(posedge clk) begin
        rst_sync <= {rst_sync[0], btn1};  // Reset button, 1 = released
        dir_sync <= {dir_sync[0], btn2};  // Direction button, 1 = released = count up
    end

    // This contains the instantiation for the counter
    counter_4bit #(.TICK_CLKS(50_000_000)) u_cnt (.clk(clk), .nreset(rst_sync[1]), .up_down(dir_sync[1]), .count(count));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~count[0];

endmodule
