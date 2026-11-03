// lifo-bram.v - 4-bit LIFO (stack) of depth 256 on block RAM, from the Shrike stack_processor example.
// Shrike used the Forge BRAM macro ports (BRAM0_*, active-low write and read enables, 9-bit addresses). On the Zen 4 the memory is inferred: a 512 x 4 RAM with a synchronous write
// and a synchronous read with an output register, which Efinity maps to a block RAM. The control logic and the clock-by-clock timing (sp, flags, address registers, DOUT latency) are kept as they were.
// The RAM is 512 deep because, as in the original, the "full" flag is registered one clock late, so a push right at the limit can still write address 256.

module lifo_bram #(
    parameter DEPTH  = 256,    // Stack depth
    parameter ADDR_W = 8       // log2(DEPTH)
) (
    input  wire       clk,
    input  wire       nReset,        // Reset, active low
    input  wire [3:0] DIN,           // Value to push
    input  wire       WE,            // Push
    input  wire       RE,            // Pop
    output reg  [3:0] DOUT,          // Value popped (a few clocks after RE)
    output reg        LIFO_full,
    output reg        LIFO_empty
);

    // Stack pointer (0 = empty)
    reg [ADDR_W:0] sp;

    // RAM and the registers in front of it (the same ones the BRAM macro had outside)
    reg [3:0] mem [0:511];
    reg [3:0] ram_din;
    reg       ram_wen_n;
    reg [8:0] ram_waddr;
    reg       ram_ren_n;
    reg [8:0] ram_raddr;
    reg [3:0] ram_dout = 4'd0;

    // This block runs the stack pointer and the flags
    always @(posedge clk or negedge nReset) begin
        if (!nReset) begin
            sp         <= 0;
            LIFO_empty <= 1'b1;
            LIFO_full  <= 1'b0;
        end else begin
            // Push
            if (WE && !LIFO_full) begin
                sp <= sp + 1;
            end
            // Pop
            else if (RE && !LIFO_empty) begin
                sp <= sp - 1;
            end
            // Status flags
            LIFO_empty <= (sp == 0);
            LIFO_full  <= (sp == DEPTH);
        end
    end

    // This block is the write side: address and data registers, then the RAM write (enable is active low)
    always @(posedge clk) begin
        ram_din   <= DIN;
        ram_waddr <= sp;
        ram_wen_n <= !(WE && !LIFO_full);
        if (!ram_wen_n) mem[ram_waddr] <= ram_din;
    end

    // This block is the read side: address register, RAM read with an output register (enable is active low), then DOUT
    always @(posedge clk) begin
        ram_raddr <= sp - 1;
        ram_ren_n <= !(RE && !LIFO_empty);
        if (!ram_ren_n) ram_dout <= mem[ram_raddr];
        DOUT <= ram_dout;
    end

endmodule
