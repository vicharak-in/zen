// flight_fpga_top.v - board top for the Zen flight simulator (Zen 4, Trion T4F81): the CORDIC engine runs in the FPGA
// The RP2350 writes the raw accelerometer values and reads back the rotated plane over the Zen Link
// Same port list as zink_aes_top.v / tetris_fpga_top.v, so the same peri.xml and sdc pattern works
// Fabric clock: 25 MHz (PLL x16 / 32)
// User bus map (addresses >= 0x100):
//   0x100 ax  0x102 ay  0x104 az    int16 little endian (raw accelerometer)
//   0x106 yaw  0x108 roll_trim  0x10A pitch_trim    uint16 binary angles (65536 = 360 degrees)
//   0x10C write any value: start the engine
//   0x110 roll_m  0x112 pitch_m     (read only, measured by the FPGA)
//   0x140 buttons {A, B} (1 = pressed)   0x141 bitstream ID
//   0x200..0x271 rotated vertices, NV*3 int16 little endian (x, y, z per vertex, 16384 = 1.0)
// STAT0 bit 0 = busy, STAT1 = number of finished jobs

`default_nettype none

module flight_fpga_top (
    input  wire       clk,          // 25 MHz fabric clock from the PLL
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    input  wire       btn1,         // Button B (right), active low
    input  wire       btn2,         // Button A (left), active low
    output wire       led1,         // LED 1, active low: lit while the engine is busy
    output wire       led2          // LED 2, active low: toggles with every finished job
);
    // Bitstream ID the launcher expects at 0x141
    localparam [7:0] BITSTREAM_ID = 8'hF1;
    // Number of plane vertices
    localparam NV = 19;

    // Zen Link control registers (not used by this design)
    wire [31:0] ctrl_flat;
    // User bus address
    wire [15:0] usr_addr;
    // User bus write strobe
    wire        usr_wr;
    // User bus read strobe
    wire        usr_rd;
    // User bus write data
    wire [7:0]  usr_wdata;
    // User bus read data
    reg  [7:0]  usr_rdata;
    // Engine busy flag
    wire        busy;
    // Number of finished jobs
    reg  [7:0]  jobs = 8'd0;
    // Zen Link status registers: STAT0 = busy, STAT1 = jobs
    wire [31:0] stat_flat = {16'd0, jobs, 7'd0, busy};
    // Synchroniser of button B
    reg  [1:0]  b1s = 2'b11;
    // Synchroniser of button A
    reg  [1:0]  b2s = 2'b11;
    // Input registers 0x100..0x10B written by the MCU
    reg  [7:0]  inr [0:11];
    // Loop index for the power-up values
    integer     k;
    // One-clock start pulse for the engine
    reg         start = 1'b0;
    // Measured roll
    wire [15:0] roll_m;
    // Measured pitch
    wire [15:0] pitch_m;
    // Result RAM write enable
    wire        ram_we;
    // Result RAM word address
    wire [5:0]  ram_wa;
    // Result RAM word
    wire [15:0] ram_wd;
    // Busy of the previous clock, to find the end of a job
    reg         busy_d = 1'b0;
    // Result RAM, 16-bit words
    reg  [15:0] vram [0:63];
    // The word of the RAM that contains the byte being read
    wire [15:0] vw = vram[usr_addr[6:1]];

    // This block gives the input registers a defined value at power-up
    initial for (k = 0; k < 12; k = k + 1) inr[k] = 8'd0;

    // This block synchronises the buttons, stores the MCU writes, makes the start pulse and counts finished jobs
    always @(posedge clk) begin
        // Two-flop synchroniser of button B
        b1s <= {b1s[0], btn1};
        // Two-flop synchroniser of button A
        b2s <= {b2s[0], btn2};
        // The start pulse lasts one clock
        start <= 1'b0;
        // Remember busy
        busy_d <= busy;
        // A job just finished: count it
        if (busy_d && !busy) jobs <= jobs + 8'd1;
        // A write to 0x100..0x10B stores one byte of an input register
        if (usr_wr && usr_addr[15:4] == 12'h010 && usr_addr[3:0] < 4'd12) inr[usr_addr[3:0]] <= usr_wdata;
        // A write to 0x10C starts the engine
        if (usr_wr && usr_addr == 16'h010C) start <= 1'b1;
    end

    // This block stores the engine results in the result RAM
    always @(posedge clk) begin
        // One word per write strobe
        if (ram_we) vram[ram_wa] <= ram_wd;
    end

    // This block is the read mux of the user bus (combinational, valid in the clock of the read strobe)
    always @* begin
        // Unmapped addresses read as zero
        usr_rdata = 8'd0;
        // Result vertices: low byte or high byte of the word
        if (usr_addr[15:8] == 8'h02) usr_rdata = usr_addr[0] ? vw[15:8] : vw[7:0];
        // Input registers read back
        else if (usr_addr[15:4] == 12'h010 && usr_addr[3:0] < 4'd12) usr_rdata = inr[usr_addr[3:0]];
        // Other registers
        else case (usr_addr)
            // Measured roll, low byte
            16'h0110: usr_rdata = roll_m[7:0];
            // Measured roll, high byte
            16'h0111: usr_rdata = roll_m[15:8];
            // Measured pitch, low byte
            16'h0112: usr_rdata = pitch_m[7:0];
            // Measured pitch, high byte
            16'h0113: usr_rdata = pitch_m[15:8];
            // Buttons: bit 0 = B (btn1), bit 1 = A (btn2), 1 = pressed
            16'h0140: usr_rdata = {6'd0, ~b2s[1], ~b1s[1]};
            // Bitstream ID
            16'h0141: usr_rdata = BITSTREAM_ID;
            // Nothing else is mapped
            default:  usr_rdata = 8'd0;
        endcase
    end

    // LED 1 is lit while the engine works (active low)
    assign led1 = ~busy;
    // LED 2 toggles with every finished job (active low)
    assign led2 = ~jobs[0];

    // This contains the instantiation for the flight engine
    flight_engine #(.NV(NV)) u_eng (
        .clk(clk), .start(start),
        .ax({inr[1], inr[0]}), .ay({inr[3], inr[2]}), .az({inr[5], inr[4]}),
        .yaw({inr[7], inr[6]}), .roll_trim({inr[9], inr[8]}), .pitch_trim({inr[11], inr[10]}),
        .busy(busy), .roll_m(roll_m), .pitch_m(pitch_m),
        .ram_we(ram_we), .ram_wa(ram_wa), .ram_wd(ram_wd)
    );

    // This contains the instantiation for the Zen Link slave
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
        .usr_rdata   (usr_rdata)
    );

    // Unused signals are combined here so the linter stays quiet
    wire _unused = ^{usr_rd, ctrl_flat};

endmodule

`default_nettype wire
