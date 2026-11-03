// tml-engine.v - int8 multilayer-perceptron engine: one MAC per clock, int32 accumulator, shift-and-saturate requantisation.
//
// What it computes, per layer (all integers, matches firmware/pc-tools/tinyml_model.py bit for bit):
//   acc[o] = bias[o] + sum over i of ( weight[o][i] * x[i] )        x, weight: int8     bias, acc: int32
//   y[o]   = saturate_int8( relu?( (acc[o] + (1 << (shift-1))) >>> shift ) )     (rounding add skipped when shift = 0)
//
// Memory layout the engine expects (the host loads these through the tml_zink windows):
//   layer table  4 bytes per layer: in_dim, out_dim, shift, flags (bit0 = relu)
//   weights      one run of in_dim bytes per output neuron, neurons in order, layers back to back
//   biases       4 bytes per output neuron, little endian int32, layers back to back
//   activations  three 256 byte buffers: buffer 0 holds the input and is never written by the engine (so a run can be repeated without reloading it);
//                layer 0 reads buffer 0 and writes 1, layer 1 reads 1 and writes 2, layer 2 reads 2 and writes 1, and so on (ping-pong between 1 and 2)
//
// Timing: the requantisation is a four-stage pipeline (add rounding constant, coarse shift, fine shift, ReLU + saturate) that runs in parallel with the
// next neuron's bias load, so it costs no extra clocks except a 4 clock drain at the end of a run.
// Run cost = sum over layers of (5 + out_dim * (in_dim + 9) + 1), plus 4. All RAMs have a registered read, so every address is issued one clock
// before its data is used.

module tml_engine #(
    parameter W_AW = 12, // Weight RAM address width
    parameter B_AW = 10  // Bias RAM address width
) (
    input  wire            clk,       // Clock
    input  wire            rst,       // Synchronous reset, active high
    input  wire            start,     // One-clock pulse: run all layers
    input  wire [4:0]      nlayers,   // Number of layers to run (1..16)
    output wire            busy,      // High while a run is in progress
    output reg             done,      // Sticky: a run finished (cleared by the next start)
    output reg             err,       // Sticky: bad layer count or bad layer table entry (cleared by the next start)
    output reg  [31:0]     cycles,    // Clocks used by the last run
    output wire [1:0]      res_buf,   // Activation buffer that holds the result when done is set (1 or 2)
    output wire [5:0]      tbl_raddr, // Layer table read address
    input  wire [7:0]      tbl_rdata, // Layer table read data (one clock after the address)
    output wire [W_AW-1:0] w_raddr,   // Weight RAM read address
    input  wire [7:0]      w_rdata,   // Weight RAM read data (one clock after the address)
    output wire [B_AW-1:0] b_raddr,   // Bias RAM read address
    input  wire [7:0]      b_rdata,   // Bias RAM read data (one clock after the address)
    output wire [9:0]      a_raddr,   // Activation RAM read address: {buffer, index}
    input  wire [7:0]      a_rdata,   // Activation RAM read data (one clock after the address)
    output wire            a_we,      // Activation RAM write enable
    output wire [9:0]      a_waddr,   // Activation RAM write address: {buffer, index}
    output wire [7:0]      a_wdata    // Activation RAM write data
);

    // Sequencer states
    localparam [2:0] S_IDLE  = 3'd0; // Wait for start
    localparam [2:0] S_TBL   = 3'd1; // Read the four layer table bytes
    localparam [2:0] S_BIAS  = 3'd2; // Read the four bias bytes of one neuron into the accumulator
    localparam [2:0] S_MAC   = 3'd3; // Multiply-accumulate all inputs of one neuron
    localparam [2:0] S_REQ   = 3'd4; // Hand the finished accumulator to the requantisation pipeline
    localparam [2:0] S_NEXT  = 3'd5; // Move on to the next layer or finish
    localparam [2:0] S_DRAIN = 3'd6; // Wait for the requantisation pipeline to write the last outputs

    // Current state
    reg  [2:0]       st = S_IDLE;
    // Layer index (after a finished run it equals nlayers)
    reg  [4:0]       l = 5'd0;
    // Small counter used for the table and bias reads
    reg  [2:0]       cnt = 3'd0;
    // Number of inputs of the current layer
    reg  [7:0]       in_dim = 8'd0;
    // Number of outputs of the current layer
    reg  [7:0]       out_dim = 8'd0;
    // Right shift of the current layer
    reg  [4:0]       shift = 5'd0;
    // ReLU flag of the current layer
    reg              relu = 1'b0;
    // Rounding constant 1 << (shift-1) of the current layer (zero when shift is zero), computed once per layer
    reg  signed [31:0] half_q = 32'sd0;
    // Output neuron counter
    reg  [7:0]       o = 8'd0;
    // Input counter (address issue side)
    reg  [7:0]       i = 8'd0;
    // Next weight address (weights are read strictly in order)
    reg  [W_AW-1:0]  wptr = {W_AW{1'b0}};
    // Next bias address (4 bytes per neuron, in order)
    reg  [B_AW-1:0]  bptr = {B_AW{1'b0}};
    // Accumulator
    reg  signed [31:0] acc = 32'sd0;
    // High when the data on w_rdata / a_rdata belongs to a real multiply (the address was issued in the previous clock)
    reg              v = 1'b0;
    // Registered 8 x 8 product (cuts the path RAM -> multiplier -> 32-bit adder in two)
    reg  signed [15:0] prod_q = 16'sd0;
    // High when prod_q holds a real product that still has to be added to the accumulator
    reg              vq = 1'b0;

    // Requantisation pipeline: valid bits of the four stages
    reg              rq_v0 = 1'b0, rq_v1 = 1'b0, rq_v2 = 1'b0, rq_v3 = 1'b0;
    // Stage 1 result: accumulator plus rounding constant
    reg  signed [31:0] rq_sum = 32'sd0;
    // Stage 2 result: shifted right by 0, 8, 16 or 24
    reg  signed [31:0] rq_t   = 32'sd0;
    // Stage 3 result: shifted right by the remaining 0..7
    reg  signed [31:0] rq_u   = 32'sd0;
    // Stage 4 result: ReLU applied and saturated to int8
    reg  [7:0]       rq_y = 8'd0;
    // Shift amount carried along the pipeline (stage 2 uses bits 4:3, stage 3 uses bits 2:0)
    reg  [4:0]       rq_sh0 = 5'd0, rq_sh1 = 5'd0;
    // ReLU flag carried along the pipeline
    reg              rq_r0 = 1'b0, rq_r1 = 1'b0, rq_r2 = 1'b0;
    // Output address carried along the pipeline (captured at launch, so a layer change cannot disturb it)
    reg  [9:0]       rq_a0 = 10'd0, rq_a1 = 10'd0, rq_a2 = 10'd0, rq_a3 = 10'd0;

    // Busy whenever the sequencer is not idle
    assign busy      = (st != S_IDLE);
    // Input buffer of the current layer: 0 for layer 0, then 1 and 2 alternating
    wire [1:0] in_buf  = (l == 5'd0) ? 2'd0 : (l[0] ? 2'd1 : 2'd2);
    // Output buffer of the current layer: 1 for even layers, 2 for odd layers
    wire [1:0] out_buf = l[0] ? 2'd2 : 2'd1;
    // After a run l = nlayers, so the last layer was l-1: an odd l means the last layer was even and wrote buffer 1
    assign res_buf   = l[0] ? 2'd1 : 2'd2;
    // Layer table address: layer number and byte number
    assign tbl_raddr = {l[3:0], cnt[1:0]};
    // Weight address
    assign w_raddr   = wptr;
    // Bias address: base of the neuron plus byte number
    assign b_raddr   = bptr + {{(B_AW-2){1'b0}}, cnt[1:0]};
    // Activation read address: input buffer of this layer and input index
    assign a_raddr   = {in_buf, i};
    // Activation write enable: the last pipeline stage holds a finished output
    assign a_we      = rq_v3;
    // Activation write address: captured when the neuron was launched
    assign a_waddr   = rq_a3;
    // Activation write data: the saturated int8 output
    assign a_wdata   = rq_y;

    // Signed views of the two multiplier operands
    wire signed [7:0]  ws   = w_rdata;
    // Signed activation
    wire signed [7:0]  xs   = a_rdata;
    // 8 x 8 signed product (maps to a Trion multiplier or logic, the tool decides)
    wire signed [15:0] prod = ws * xs;
    // ReLU applied to the stage 3 result
    wire signed [31:0] rl   = (rq_r2 && (rq_u < 0)) ? 32'sd0 : rq_u;
    // Saturate to int8
    wire        [7:0]  ysat = (rl > 127) ? 8'h7F : ((rl < -128) ? 8'h80 : rl[7:0]);

    // This block is the sequencer: it walks the layer table, the neurons and the inputs, and counts the clocks of a run
    always @(posedge clk) begin
        if (rst) begin
            st     <= S_IDLE;                                              // Idle after reset
            done   <= 1'b0;                                                // No result yet
            err    <= 1'b0;                                                // No error
            cycles <= 32'd0;                                               // Counter cleared
            l      <= 5'd0;                                                // Layer 0
            cnt    <= 3'd0;                                                // Counter cleared
            v      <= 1'b0;                                                // No multiply pending
            vq     <= 1'b0;                                                // No product pending
        end else begin
            if (st != S_IDLE) cycles <= cycles + 32'd1;                    // Count every clock of the run
            case (st)
                S_IDLE: if (start) begin
                    done   <= 1'b0;                                        // Old result is gone
                    err    <= 1'b0;                                        // Old error is gone
                    cycles <= 32'd0;                                       // Restart the clock counter
                    if (nlayers == 5'd0 || nlayers > 5'd16) err <= 1'b1;   // Bad layer count: do not run
                    else begin
                        st   <= S_TBL;                                     // Fetch the table entry of layer 0
                        l    <= 5'd0;                                      // Start at layer 0
                        cnt  <= 3'd0;                                      // Table byte 0 first
                        wptr <= {W_AW{1'b0}};                              // Weights start at address 0
                        bptr <= {B_AW{1'b0}};                              // Biases start at address 0
                    end
                end
                S_TBL: begin
                    cnt <= cnt + 3'd1;                                     // Next table byte (data arrives one clock after the address)
                    case (cnt)
                        3'd1: in_dim  <= tbl_rdata;                        // Byte 0: inputs per neuron
                        3'd2: out_dim <= tbl_rdata;                        // Byte 1: number of neurons
                        3'd3: shift   <= tbl_rdata[4:0];                   // Byte 2: requantisation shift
                        3'd4: begin
                            relu   <= tbl_rdata[0];                        // Byte 3: flags, bit 0 = ReLU
                            half_q <= (shift == 5'd0) ? 32'sd0 : (32'sd1 << (shift - 5'd1));   // Rounding constant of this layer, computed once
                            if (in_dim == 8'd0 || out_dim == 8'd0) begin
                                err <= 1'b1;                               // A layer with no inputs or no outputs is a mistake
                                st  <= S_IDLE;                             // Stop the run
                            end else begin
                                st  <= S_BIAS;                             // Table entry complete: start the first neuron
                                cnt <= 3'd0;                               // Bias byte 0 first
                                o   <= 8'd0;                               // First neuron
                            end
                        end
                        default: ;                                         // Cycle 0 only issues the first address
                    endcase
                end
                S_BIAS: begin
                    cnt <= cnt + 3'd1;                                     // Next bias byte
                    if (cnt != 3'd0) acc <= {b_rdata, acc[31:8]};          // Shift the new byte in at the top: after four bytes acc = {b3,b2,b1,b0}
                    if (cnt == 3'd4) begin
                        st   <= S_MAC;                                     // Bias loaded: start the multiplies
                        i    <= 8'd0;                                      // First input
                        v    <= 1'b0;                                      // Nothing pending yet
                        bptr <= bptr + {{(B_AW-3){1'b0}}, 3'd4};           // Next neuron's bias starts four bytes later
                    end
                end
                S_MAC: begin
                    v <= (i != in_dim);                                    // A read is issued in this clock, so its data is multiplied in the next one
                    if (i != in_dim) begin
                        i    <= i + 8'd1;                                  // Next input
                        wptr <= wptr + {{(W_AW-1){1'b0}}, 1'b1};           // Next weight
                    end
                    vq      <= v;                                          // The product registered below is real when the read data was real
                    prod_q  <= prod;                                       // Register the product (multiplier output no longer feeds the adder directly)
                    if (vq) acc <= acc + prod_q;                           // Accumulate the product registered one clock ago
                    if (i == in_dim && !v && !vq) st <= S_REQ;             // All reads issued, multiplied and added: acc is final
                end
                S_REQ: begin
                    o <= o + 8'd1;                                         // The accumulator is launched into the pipeline this clock, move to the next neuron
                    if (o + 8'd1 == out_dim) st <= S_NEXT;                 // That was the last neuron of the layer
                    else begin
                        st  <= S_BIAS;                                     // Next neuron: load its bias while the pipeline finishes this one
                        cnt <= 3'd0;                                       // Bias byte 0 first
                    end
                end
                S_NEXT: begin
                    l <= l + 5'd1;                                         // Next layer (its input buffer is this layer's output buffer)
                    if (l + 5'd1 == nlayers) st <= S_DRAIN;                // Last layer launched: wait for the pipeline to empty
                    else begin
                        st  <= S_TBL;                                      // Fetch the next table entry
                        cnt <= 3'd0;                                       // Table byte 0 first
                    end
                end
                S_DRAIN: if (!(rq_v0 || rq_v1 || rq_v2 || rq_v3)) begin
                    st   <= S_IDLE;                                        // Every output has been written
                    done <= 1'b1;                                          // Tell the host
                end
                default: st <= S_IDLE;                                     // Never happens
            endcase
        end
    end

    // This block is the requantisation pipeline: four registered stages (add rounding constant, coarse shift, fine shift, ReLU + saturate),
    // started by S_REQ and finished by a write into the activation RAM; it runs in parallel with the sequencer
    always @(posedge clk) begin
        if (rst) begin
            rq_v0 <= 1'b0;                                                 // Pipeline empty after reset
            rq_v1 <= 1'b0;                                                 // Stage 2 empty
            rq_v2 <= 1'b0;                                                 // Stage 3 empty
            rq_v3 <= 1'b0;                                                 // Stage 4 empty
        end else begin
            rq_v0  <= (st == S_REQ);                                       // Stage 1 valid one clock after the launch
            rq_sum <= acc + half_q;                                        // Stage 1: add the rounding constant (only used when rq_v0 is set)
            rq_sh0 <= shift;                                               // Carry the shift of this neuron's layer
            rq_r0  <= relu;                                                // Carry the ReLU flag
            rq_a0  <= {out_buf, o};                                        // Carry the output address
            rq_v1  <= rq_v0;                                               // Stage 2 valid
            rq_t   <= rq_sum >>> {rq_sh0[4:3], 3'b000};                    // Stage 2: arithmetic shift right by 0, 8, 16 or 24
            rq_sh1 <= rq_sh0;                                              // Carry the shift
            rq_r1  <= rq_r0;                                               // Carry the ReLU flag
            rq_a1  <= rq_a0;                                               // Carry the output address
            rq_v2  <= rq_v1;                                               // Stage 3 valid
            rq_u   <= rq_t >>> rq_sh1[2:0];                                // Stage 3: arithmetic shift right by the remaining 0..7
            rq_r2  <= rq_r1;                                               // Carry the ReLU flag
            rq_a2  <= rq_a1;                                               // Carry the output address
            rq_v3  <= rq_v2;                                               // Stage 4 valid: the output is written in the next clock
            rq_y   <= ysat;                                                // Stage 4: ReLU and saturate to int8
            rq_a3  <= rq_a2;                                               // Carry the output address
        end
    end

endmodule
