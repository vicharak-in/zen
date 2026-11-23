// tml-zink.v - TinyML engine behind the Zink user bus (addresses 0x100 and up). A set of RAM windows plus a few registers; no pointers, no auto-increment,
// so a plain fpga.write_block / fpga.read_block of consecutive addresses (the link already auto-increments the address) moves a whole tensor.
//
// User bus map (byte addresses):
//   0x0100  CMD      W    1 = RUN, any other value only clears the error flag
//   0x0101  STATUS   R    bit0 busy, bit1 done (cleared by the next RUN), bit2 error (bad layer table, or a write while running)
//   0x0102  NLAYERS  RW   number of layers to run (1..16)
//   0x0103  CONFIG   R    {W_AW[3:0], 4'd1}: weight RAM address width, interface version 1
//   0x0104..0x0107  CYCLES  R   clocks used by the last run, byte 0 = bits 7:0
//   0x0200..0x023F  LAYER TABLE  W/R   64 bytes, 4 per layer: in_dim, out_dim, shift, flags (bit0 = ReLU)
//   0x0600..0x06FF  INPUT        W/R   input vector, int8 (activation buffer 0)
//   0x0700..0x07FF  OUTPUT       R     result vector, int8 (the buffer the last layer wrote)
//   0x2000..0x3FFF  WEIGHTS      W/R   int8, one run of in_dim bytes per output neuron, neurons and layers back to back (2**W_AW bytes used)
//   0x4000..0x43FF  BIASES       W/R   int32 little endian, one per output neuron, layers back to back (2**B_AW bytes used)
// Memory windows are write-protected while a run is in progress (the write is dropped and the error flag is set).
// Reads of the RAM windows come from registered RAM outputs: they are valid two clocks after usr_addr settles, which is how the Zink slave fetches (kick, then read strobe).

module tml_zink #(
    parameter W_AW = 12, // Weight RAM address width (4 KB by default, max 13 for the 0x2000..0x3FFF window)
    parameter B_AW = 10  // Bias RAM address width (1 KB by default = 256 neurons, max 10 for the 0x4000..0x43FF window)
) (
    input  wire        clk,        // Clock
    input  wire        rst,        // Synchronous reset, active high
    input  wire [15:0] usr_addr,   // Zink user bus byte address
    input  wire        usr_wr,     // Zink user bus write strobe (one clock)
    input  wire [7:0]  usr_wdata,  // Zink user bus write data
    input  wire        usr_rd,     // Zink user bus read strobe (one clock, not needed here: reads have no side effects)
    output reg  [7:0]  usr_rdata,  // Zink user bus read data
    output wire [7:0]  status_o    // STATUS byte, for the Zink STAT0 register
);

    // Address decode of the user bus
    wire sel_reg = (usr_addr[15:8]  == 8'h01);        // Registers 0x0100..0x01FF
    // Layer table window
    wire sel_tbl = (usr_addr[15:6]  == 10'h008);      // 0x0200..0x023F
    // Input window
    wire sel_in  = (usr_addr[15:8]  == 8'h06);        // 0x0600..0x06FF
    // Output window
    wire sel_out = (usr_addr[15:8]  == 8'h07);        // 0x0700..0x07FF
    // Weight window
    wire sel_w   = (usr_addr[15:13] == 3'b001);       // 0x2000..0x3FFF
    // Bias window
    wire sel_b   = (usr_addr[15:10] == 6'b010000);    // 0x4000..0x43FF
    // Register index inside the register window
    wire [7:0] ridx = usr_addr[7:0];

    // Number of layers to run
    reg  [4:0] nl = 5'd0;
    // Sticky error from a bus access that is not allowed (write while running)
    reg        wr_err = 1'b0;

    // Engine outputs
    wire        busy, done, e_err;
    // Buffer that holds the result (1 or 2)
    wire [1:0]  res_buf;
    // Clocks of the last run
    wire [31:0] cycles;
    // Engine side of the RAM ports
    wire [5:0]      e_t_raddr;
    wire [W_AW-1:0] e_w_raddr;
    wire [B_AW-1:0] e_b_raddr;
    wire [9:0]      e_a_raddr, e_a_waddr;
    wire            e_a_we;
    wire [7:0]      e_a_wdata;
    // RAM read data
    wire [7:0] t_rdata, w_rdata, b_rdata, a_rdata;

    // Status byte: {error, done, busy}
    assign status_o = {5'd0, (e_err | wr_err), done, busy};

    // A RUN command: register 0, value 1, not busy
    wire start = usr_wr & sel_reg & (ridx == 8'h00) & (usr_wdata == 8'd1) & ~busy;
    // Memory window write strobes (dropped while busy)
    wire t_we  = usr_wr & sel_tbl & ~busy;
    wire w_we  = usr_wr & sel_w   & ~busy;
    wire b_we  = usr_wr & sel_b   & ~busy;
    wire a_we_m = usr_wr & sel_in & ~busy;

    // Activation RAM port muxing: the engine owns it while busy, the bus owns it otherwise
    wire        a_we    = busy ? e_a_we    : a_we_m;
    // Activation write address
    wire [9:0]  a_waddr = busy ? e_a_waddr : {2'b00, usr_addr[7:0]};
    // Activation write data
    wire [7:0]  a_wdata = busy ? e_a_wdata : usr_wdata;
    // Activation read address: the output window reads the result buffer, the input window reads buffer 0
    wire [9:0]  a_raddr = busy ? e_a_raddr : (sel_out ? {res_buf, usr_addr[7:0]} : {2'b00, usr_addr[7:0]});

    // This block holds the small register file of the user bus and the error flag
    always @(posedge clk) begin
        if (rst) begin
            nl     <= 5'd0;                                                // No layers selected
            wr_err <= 1'b0;                                                // No error
        end else begin
            if (usr_wr && busy && (sel_tbl || sel_w || sel_b || sel_in)) wr_err <= 1'b1;   // A write into a memory window while running is dropped and flagged
            if (usr_wr && sel_reg && ridx == 8'h00) wr_err <= busy;                          // A command clears the error (a command while busy is flagged instead)
            if (usr_wr && sel_reg && ridx == 8'h02) begin
                if (busy) wr_err <= 1'b1;                                  // Changing the layer count while running is a mistake
                else nl <= usr_wdata[4:0];                                 // Store the layer count
            end
        end
    end

    // This block is the read mux of the user bus (the RAM outputs are already registered)
    always @* begin
        usr_rdata = 8'd0;                                                  // Unmapped addresses read zero
        if (sel_tbl) usr_rdata = t_rdata;                                  // Layer table
        if (sel_in || sel_out) usr_rdata = a_rdata;                        // Input or output vector
        if (sel_w)   usr_rdata = w_rdata;                                  // Weights
        if (sel_b)   usr_rdata = b_rdata;                                  // Biases
        if (sel_reg) begin
            case (ridx)
                8'h01: usr_rdata = status_o;                               // STATUS
                8'h02: usr_rdata = {3'd0, nl};                             // NLAYERS
                8'h03: usr_rdata = {W_AW[3:0], 4'd1};                      // CONFIG
                8'h04: usr_rdata = cycles[7:0];                            // CYCLES byte 0
                8'h05: usr_rdata = cycles[15:8];                           // CYCLES byte 1
                8'h06: usr_rdata = cycles[23:16];                          // CYCLES byte 2
                8'h07: usr_rdata = cycles[31:24];                          // CYCLES byte 3
                default: usr_rdata = 8'd0;                                 // Other registers read zero
            endcase
        end
    end

    // This contains the instantiation for the engine
    tml_engine #(.W_AW(W_AW), .B_AW(B_AW)) u_eng (
        .clk(clk), .rst(rst), .start(start), .nlayers(nl),
        .busy(busy), .done(done), .err(e_err), .cycles(cycles), .res_buf(res_buf),
        .tbl_raddr(e_t_raddr), .tbl_rdata(t_rdata),
        .w_raddr(e_w_raddr), .w_rdata(w_rdata),
        .b_raddr(e_b_raddr), .b_rdata(b_rdata),
        .a_raddr(e_a_raddr), .a_rdata(a_rdata),
        .a_we(e_a_we), .a_waddr(e_a_waddr), .a_wdata(e_a_wdata)
    );

    // This contains the instantiation for the layer table RAM
    tml_ram #(.AW(6)) u_tmem (
        .clk(clk), .we(t_we), .waddr(usr_addr[5:0]), .wdata(usr_wdata),
        .raddr(busy ? e_t_raddr : usr_addr[5:0]), .rdata(t_rdata)
    );

    // This contains the instantiation for the weight RAM
    tml_ram #(.AW(W_AW)) u_wmem (
        .clk(clk), .we(w_we), .waddr(usr_addr[W_AW-1:0]), .wdata(usr_wdata),
        .raddr(busy ? e_w_raddr : usr_addr[W_AW-1:0]), .rdata(w_rdata)
    );

    // This contains the instantiation for the bias RAM
    tml_ram #(.AW(B_AW)) u_bmem (
        .clk(clk), .we(b_we), .waddr(usr_addr[B_AW-1:0]), .wdata(usr_wdata),
        .raddr(busy ? e_b_raddr : usr_addr[B_AW-1:0]), .rdata(b_rdata)
    );

    // This contains the instantiation for the activation RAM (buffer 0 = input, buffers 1 and 2 = ping-pong, 256 bytes each)
    tml_ram #(.AW(10)) u_amem (
        .clk(clk), .we(a_we), .waddr(a_waddr), .wdata(a_wdata),
        .raddr(a_raddr), .rdata(a_rdata)
    );

endmodule
