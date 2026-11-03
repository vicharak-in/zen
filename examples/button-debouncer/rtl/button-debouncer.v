// Ported from the Vicharak Shrike examples (GPL-2.0) to the Zen 4 (Trion T4F81); logic unchanged, Renesas pad/enable ports removed.
// button-debouncer.v - NUM_PORTS debouncers side by side (was module "top" in the Shrike example)
// Original author: Upendra Reddi (Vicharak Computers).

module button_debouncer #(
    parameter NUM_PORTS = 1,                  // Number of debouncer channels
    parameter DEBOUNCE_CNT_LIMIT = 500_000    // Steady time in clocks
) (
    input  wire                 clk,      // Fabric clock
    input  wire [NUM_PORTS-1:0] i_pulse,  // Raw switch inputs
    output wire [NUM_PORTS-1:0] o_pulse   // Debounced outputs
);

    // Channel index
    genvar i;
    // One debouncer per channel
    generate
        for (i = 0; i < NUM_PORTS; i = i + 1) begin : GEN_DEBOUNCERS
            // This contains the instantiation for debouncer channel i
            debouncer #(.DEBOUNCE_CNT_LIMIT(DEBOUNCE_CNT_LIMIT)) u_debouncer (.clk(clk), .i_pulse(i_pulse[i]), .o_pulse(o_pulse[i]));
        end
    endgenerate

endmodule
