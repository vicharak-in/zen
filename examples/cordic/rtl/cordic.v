// cordic.v - CORDIC coprocessor: sin, cos, tan and a 3-bit signed multiply, selected by the top two bits of the byte it receives.
//   rx_data[7:6] = 00 cos, 01 sin, 10 multiply, 11 tan;  rx_data[5:0] = angle in Q1.6 radians (0 to 45 degrees), or two 3-bit signed operands for the multiply.
// The result (Q1.6 for cos / sin / tan, plain integer for the multiply) is returned by the next transfer.
// Ported from the Shrike example (module "top"): the spi_target and pad ports are gone, the core has the plain byte interface and the logic is unchanged.

module cordic (
    input  wire       clk,       // Fabric clock
    input  wire       rst_n,     // Reset, active low
    input  wire [7:0] rx_data,   // Request byte from the master
    input  wire       rx_valid,  // One clock when rx_data is new
    output reg  [7:0] tx_data    // Result byte returned to the master
);

    // Operation select and operand
    reg [1:0] mode_reg;
    reg [5:0] data_reg;
    // One-clock start of the engines
    reg       engine_start;

    // Circular engine (cos, sin)
    wire signed [7:0] circ_cos;
    wire signed [7:0] circ_sin;
    wire              circ_done;
    // Multiplier
    wire signed [7:0] mult_out;
    wire              mult_done;
    // Divider (tan = sin / cos)
    wire signed [7:0] div_out;
    wire              div_done;

    // This block latches the request and starts the engines
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            engine_start <= 1'b0;
            mode_reg     <= 2'b00;
            data_reg     <= 6'b000000;
        end else begin
            engine_start <= 1'b0;
            if (rx_valid) begin
                mode_reg     <= rx_data[7:6];  // Operation select
                data_reg     <= rx_data[5:0];  // Operand payload
                engine_start <= 1'b1;
            end
        end
    end

    // This block selects the result byte
    always @(*) begin
        case (mode_reg)
            2'b00:   tx_data = circ_cos;
            2'b01:   tx_data = circ_sin;
            2'b10:   tx_data = mult_out;
            2'b11:   tx_data = div_out;
            default: tx_data = 8'h00;
        endcase
    end

    // This contains the instantiation for the circular engine
    cordic_circular U_CIRCULAR (
        .clk(clk), .rst_n(rst_n), .start(engine_start && (mode_reg != 2'b10)),
        .angle_in({2'b00, data_reg}),  // Zero-pad the top two bits, no sign extension
        .cos_out(circ_cos), .sin_out(circ_sin), .done(circ_done));

    // This contains the instantiation for the multiplier
    cordic_multiply U_MULTIPLY (
        .clk(clk), .rst_n(rst_n), .start(engine_start && (mode_reg == 2'b10)),
        .in1({{5{data_reg[5]}}, data_reg[5:3]}),  // Sign-extend the upper three bits
        .in2({{5{data_reg[2]}}, data_reg[2:0]}),  // Sign-extend the lower three bits
        .out(mult_out), .done(mult_done));

    // This contains the instantiation for the divider (tan)
    cordic_divide U_DIVIDE (
        .clk(clk), .rst_n(rst_n), .start(circ_done && (mode_reg == 2'b11)),
        .in_y(circ_sin), .in_x(circ_cos), .out_z(div_out), .done(div_done));

endmodule
