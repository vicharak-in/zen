// pll-oscillator-zen4-top.v - board top for pll_oscillator on the Vicharak Zen 4 (Trion T4F81).
// The fabric clock comes from the Efinity PLL (50 MHz oscillator on GPIOL_20, x16 / 16 = 50 MHz). The counter is on four header pads for a logic analyser and on the two LEDs.
// btn1 = reset (hold), btn2 = rate select (each press steps through the four rates).

module pll_oscillator_zen4_top (
    input  wire       clk,       // PLL output clock
    input  wire       btn1,      // Reset, active low (pressed = low)
    input  wire       btn2,      // Rate step, active low
    output wire [3:0] counter,   // Counter outputs on header pads
    output wire       led1,      // LED 1: counter bit 3, active low
    output wire       led2       // LED 2: rate bit 0, active low
);

    // Synchronised buttons
    reg [2:0] s1 = 3'b111;
    reg [2:0] s2 = 3'b111;
    // Rate select
    reg [1:0] rate = 2'd0;
    // Debounce timer for btn2 (about 20 ms at 50 MHz)
    reg [19:0] deb = 20'd0;

    // This block synchronises the buttons, debounces btn2 and steps the rate
    always @(posedge clk) begin
        s1 <= {s1[1:0], btn1};
        s2 <= {s2[1:0], btn2};
        if (deb != 20'd0) deb <= deb - 20'd1;
        else if (s2[2:1] == 2'b10) begin
            rate <= rate + 2'd1;
            deb  <= 20'd1_000_000;
        end
    end

    // Counter value
    wire [3:0] cnt;

    // This contains the instantiation for the counter
    pll_counter u_cnt (.clk(clk), .rst_n(s1[2]), .rate(rate), .counter(cnt));

    // Header outputs and LEDs
    assign counter = cnt;
    assign led1 = ~cnt[3];
    assign led2 = ~rate[0];

endmodule
