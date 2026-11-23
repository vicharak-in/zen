// vector8-cpu.v - 8-bit accumulator CPU driven by two-byte instructions (opcode, then data byte) inside one chip select; the reply byte is the accumulator.
//   opcodes: 0x01 LDA, 02 ADD, 03 SUB, 04 AND, 05 OR, 06 XOR, 07 LSL, 08 LSR, 09 ROL, 0A ROR, 0B INC, 0C DEC, 0D JMP, 0E JZ, 0F JNZ, 00 NOP.
// Ported from the Shrike example (module "top"): the spi_target and pad ports are gone, the core has the plain byte interface plus the chip-select level, and the logic is unchanged.

module vector8_cpu (
    input  wire       clk,       // Fabric clock
    input  wire       rst_n,     // Reset, active low
    input  wire [7:0] rx_data,   // Byte from the master
    input  wire       rx_valid,  // One clock when rx_data is new
    input  wire       ss_n,      // Chip select, active low
    output wire [7:0] tx_data    // Accumulator
);

    // Instruction under construction
    reg [4:0] r_opcode = 5'd0;
    reg [7:0] r_data = 8'd0;
    // 0 = waiting for the opcode byte, 1 = waiting for the data byte
    reg byte_cnt = 1'b0;
    // One-clock execute
    reg step_pulse = 1'b0;
    // Delayed copy of rx_valid for the edge detect
    reg rx_valid_d = 1'b0;
    // CPU state
    wire [7:0] cpu_pc;
    wire [7:0] cpu_acc;

    // The reply is the accumulator
    assign tx_data = cpu_acc;

    // This block collects the opcode and data bytes and fires the CPU
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_cnt    <= 1'b0;
            step_pulse  <= 1'b0;
            rx_valid_d  <= 1'b0;
        end else begin
            rx_valid_d <= rx_valid;
            step_pulse <= 1'b0;
            if (rx_valid && !rx_valid_d) begin
                if (byte_cnt == 1'b0) begin
                    r_opcode <= rx_data[4:0];
                    byte_cnt <= 1'b1;
                end else begin
                    r_data     <= rx_data;
                    byte_cnt   <= 1'b0;
                    step_pulse <= 1'b1;
                end
            end
            if (ss_n) byte_cnt <= 1'b0;
        end
    end

    // This contains the instantiation for the CPU
    cpu_core u_cpu (.clk(clk), .rst_n(rst_n), .i_step(step_pulse), .opcode(r_opcode), .data_in(r_data), .pc(cpu_pc), .acc(cpu_acc));

endmodule
