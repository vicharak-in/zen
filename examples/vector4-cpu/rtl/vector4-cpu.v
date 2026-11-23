// vector4-cpu.v - 4-bit CPU driven by single command bytes: {data[3:0], mode[1:0], reset, step}.
//   mode 0 LOADPROG (write data to program memory at pc, pc++)   1 LOADDATA (write data to data memory at pc, pc++)
//   mode 2 SETRUNPT (pc = data)                                   3 RUNPROG (execute the instruction at pc)
//   reset = 1 resets the CPU, step = 1 executes the command once. The reply byte is {regval, pc}.
// Ported from the Shrike example (module "top"): the spi_target and pad ports are gone, the core has the plain byte interface and the logic is unchanged.

module vector4_cpu (
    input  wire       clk,       // Fabric clock
    input  wire       rst_n,     // Reset, active low
    input  wire [7:0] rx_data,   // Command byte from the master
    input  wire       rx_valid,  // One clock when rx_data is new
    output wire [7:0] tx_data    // {regval, pc}
);

    // CPU outputs
    wire [3:0] cpu_pc;
    wire [3:0] cpu_regval;
    // Decoded command
    reg cpu_reset_cmd = 1'b0;
    reg step_cmd = 1'b0;
    reg [1:0] cpu_instr = 2'b00;
    reg [3:0] cpu_data = 4'b0000;
    reg last_data_bit_3 = 1'b0;
    // Delayed copy of rx_valid for the edge detect
    reg rx_valid_d = 1'b0;

    // This block splits the command byte into its fields
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_valid_d      <= 1'b0;
            cpu_reset_cmd   <= 1'b0;
            step_cmd        <= 1'b0;
            cpu_instr       <= 2'b00;
            cpu_data        <= 4'b0000;
            last_data_bit_3 <= 1'b0;
        end else begin
            rx_valid_d <= rx_valid;
            step_cmd   <= 1'b0;
            if (rx_valid && !rx_valid_d) begin
                cpu_data      <= rx_data[7:4];
                cpu_instr     <= rx_data[3:2];
                cpu_reset_cmd <= rx_data[1];
                if (rx_data[0]) step_cmd <= 1'b1;
                last_data_bit_3 <= rx_data[7];
            end
        end
    end

    // The reply is the register value and the program counter
    assign tx_data = {cpu_regval, cpu_pc};

    // This contains the instantiation for the CPU
    cpu_core u_cpu (
        .clk(clk), .rst_n(rst_n && !cpu_reset_cmd), .i_step(step_cmd), .instruction(cpu_instr), .data_in(cpu_data),
        .data_in_3_latched(last_data_bit_3), .pc(cpu_pc), .regval(cpu_regval));

endmodule
