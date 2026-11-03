// zink_alu_top.v - glue that connects the plain ALU (alu.v) to zink.
// The MCU writes the operands and opcode, then reads the result and flags:
//   fpga.write(0x10, A)      CTRL0 = operand A
//   fpga.write(0x11, B)      CTRL1 = operand B
//   fpga.write(0x12, op)     CTRL2[2:0] = opcode
//   fpga.read(0x20)          STAT0 = result
//   fpga.read(0x21)          STAT1 = {4'b0, overflow, negative, carry, zero}
// LEDs show the flags of the last operation: led1 = zero, led2 = carry (both active low).
// Same port list as rtl/top.v of the base example, so the existing peri.xml and sdc work unchanged.

`default_nettype none

module zink_alu_top (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       btn1,         // button 1 (unused here, kept so the pin setup is shared)
    input  wire       btn2,         // button 2 (unused here, kept so the pin setup is shared)
    output wire       led1,         // LED 1, active low
    output wire       led2          // LED 2, active low
);

    // Registers the MCU writes: CTRL0 = A, CTRL1 = B, CTRL2 = op, CTRL3 unused.
    wire [31:0] ctrl_flat;
    // Registers the MCU reads: STAT0 = result, STAT1 = flags.
    wire [31:0] stat_flat;
    // User bus outputs, unused.
    wire [15:0] usr_addr;
    // User bus write strobe, unused.
    wire        usr_wr;
    // User bus write data, unused.
    wire [7:0]  usr_wdata;
    // User bus read strobe, unused.
    wire        usr_rd;

    // ALU outputs (combinational).
    wire [7:0] alu_result;
    wire       alu_zero, alu_carry, alu_negative, alu_overflow;

    // This contains the instantiation for u_alu (the unmodified ALU, wired to CTRL).
    alu u_alu (
        .a        (ctrl_flat[7:0]),
        .b        (ctrl_flat[15:8]),
        .op       (ctrl_flat[18:16]),
        .result   (alu_result),
        .zero     (alu_zero),
        .carry    (alu_carry),
        .negative (alu_negative),
        .overflow (alu_overflow)
    );

    // Registered copies of the ALU outputs. The link bytes only change when the MCU writes,
    // and a read takes many clocks, so one register stage is plenty and keeps timing easy.
    reg [7:0] result_q   = 8'd0;
    reg [3:0] flags_q    = 4'd0;

    // Capture the ALU outputs every fabric clock.
    always @(posedge clk) begin
        // Result byte for STAT0.
        result_q <= alu_result;
        // Flags for STAT1: {overflow, negative, carry, zero}.
        flags_q  <= {alu_overflow, alu_negative, alu_carry, alu_zero};
    end

    // STAT0 = result, STAT1 = flags, STAT2 / STAT3 read 0.
    assign stat_flat = {16'd0, 4'd0, flags_q, result_q};
    // LEDs sink current: a 1 flag turns the LED on with a low pin.
    assign led1 = ~flags_q[0];
    assign led2 = ~flags_q[1];

    // This contains the instantiation for u_link
    zen_link #(
        .NCTRL (4),
        .NSTAT (4)
    ) u_link (
        .clk         (clk),
        .rst_n       (1'b1),
        .link_clk_in (link_clk_in),
        .link_csn_in (link_csn_in),
        .link_d_in   (link_d_in),
        .link_d_out  (link_d_out),
        .link_d_oe   (link_d_oe),
        .ctrl_flat   (ctrl_flat),
        .stat_flat   (stat_flat),
        .usr_addr    (usr_addr),
        .usr_wr      (usr_wr),
        .usr_wdata   (usr_wdata),
        .usr_rd      (usr_rd),
        .usr_rdata   (8'd0)
    );

endmodule

`default_nettype wire
