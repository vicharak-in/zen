// btn_debounce.v - two-flop synchroniser and debouncer for one active-low button

`default_nettype none

module btn_debounce #(
    parameter [17:0] CNT_MAX = 18'd249999  // Clocks the new level must hold before it is accepted (10 ms at 25 MHz)
) (
    input  wire clk,        // Fabric clock
    input  wire btn_raw_n,  // Raw button pin, low = pressed
    output wire pressed     // Debounced level, high = pressed
);
    // Two flops: the first takes the raw pin, the second is the synchronised copy
    reg [1:0]  sync = 2'b11;
    // Accepted (stable) level of the button, active low
    reg        stable_n = 1'b1;
    // Clocks the synchronised level has been different from the stable level
    reg [17:0] cnt = 18'd0;

    // This block synchronises the pin and accepts a new level only after it has held for CNT_MAX clocks
    always @(posedge clk) begin
        sync <= {sync[0], btn_raw_n};     // Shift the raw pin into the synchroniser
        if (sync[1] == stable_n)
            cnt <= 18'd0;                 // Same as the stable level: nothing to count
        else if (cnt == CNT_MAX) begin
            stable_n <= sync[1];          // The new level has held long enough: accept it
            cnt      <= 18'd0;            // Start counting again
        end else
            cnt <= cnt + 18'd1;           // Still different: keep counting
    end

    // Active high output for the rest of the design
    assign pressed = ~stable_n;

endmodule

`default_nettype wire
