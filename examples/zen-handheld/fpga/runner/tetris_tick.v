// tetris_tick.v - makes a one-clock pulse every millisecond from the fabric clock

`default_nettype none

module tetris_tick #(
    parameter DIV = 25000   // clock cycles per millisecond (25 MHz -> 25000)
) (
    input  wire clk,    // fabric clock
    output reg  tick    // one-clock pulse every millisecond
);
    // Counts clock cycles inside one millisecond
    reg [15:0] cnt = 16'd0;

    // This block counts DIV clocks and pulses tick at the end of each millisecond
    always @(posedge clk) begin
        if (cnt == DIV - 1) begin
            cnt  <= 16'd0;     // start the next millisecond
            tick <= 1'b1;      // pulse
        end else begin
            cnt  <= cnt + 16'd1;   // keep counting
            tick <= 1'b0;          // no pulse
        end
    end
endmodule

`default_nettype wire
