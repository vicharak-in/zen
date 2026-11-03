// cam_top.v - connects the camera writer, frame buffer, VGA timing and VGA reader (one clock for everything)
`default_nettype none

module cam_top #(
    parameter HRES  = 80,                      // Camera frame width in pixels
    parameter VRES  = 60,                      // Camera frame height in pixels
    parameter SHIFT = 3                        // log2 of the pixel doubling factor (640 / HRES = 1 << SHIFT)
) (
    input  wire       clk,                     // 25 MHz clock for everything
    input  wire       rst_n,                   // Active-low reset
    input  wire [7:0] cam_pixel,               // Pixel byte from the RP2350
    input  wire       cam_we,                  // Pixel valid strobe
    input  wire       cam_vsync,               // Frame start from the RP2350
    output wire [7:0] vga_rgb,                 // Pixel data to the VGA pins
    output wire       vga_hsync,               // VGA horizontal sync
    output wire       vga_vsync,               // VGA vertical sync
    output wire       frame_done,              // One-clock pulse when a full frame has been captured
    output wire       frame_start              // One-clock pulse when a new frame starts
);

    // Returns the number of bits needed to address value entries
    function integer clog2;
        input integer value;                   // Number of entries
        integer v;                             // Working copy
        begin
            v = value - 1;                     // Highest address
            for (clog2 = 0; v > 0; clog2 = clog2 + 1)
                v = v >> 1;                    // Count the bits
        end
    endfunction

    // Pixels per frame
    localparam FRAME_SIZE = HRES * VRES;
    // Address bits for the frame buffer
    localparam ADDR_WIDTH = clog2(FRAME_SIZE);

    // Write address from the writer to the frame buffer
    wire [ADDR_WIDTH-1:0] waddr;
    // Write data from the writer to the frame buffer
    wire [7:0]            wdata;
    // Write enable from the writer to the frame buffer
    wire                  we_bram;
    // Read address from the reader to the frame buffer
    wire [ADDR_WIDTH-1:0] raddr;
    // Read data from the frame buffer to the reader
    wire [7:0]            rdata;
    // Horizontal sync from the timing generator
    wire                  hsync_t;
    // Vertical sync from the timing generator
    wire                  vsync_t;
    // Visible-area flag from the timing generator
    wire                  active_t;
    // Visible-area column from the timing generator
    wire [9:0]            x_t;
    // Visible-area row from the timing generator
    wire [9:0]            y_t;

    // This contains the instantiation for ov7670_writer
    ov7670_writer #(.ADDR_WIDTH(ADDR_WIDTH), .FRAME_SIZE(FRAME_SIZE)) u_writer (
        .clk         (clk),
        .rst_n       (rst_n),
        .pixel       (cam_pixel),
        .we          (cam_we),
        .vsync_in    (cam_vsync),
        .waddr       (waddr),
        .wdata       (wdata),
        .we_bram     (we_bram),
        .frame_done  (frame_done),
        .frame_start (frame_start)
    );

    // This contains the instantiation for cam_bram
    cam_bram #(.ADDR_WIDTH(ADDR_WIDTH), .DEPTH(FRAME_SIZE)) u_bram (
        .wclk  (clk),
        .we    (we_bram),
        .waddr (waddr),
        .wdata (wdata),
        .rclk  (clk),
        .raddr (raddr),
        .rdata (rdata)
    );

    // This contains the instantiation for vga_timing
    vga_timing u_timing (
        .clk    (clk),
        .rst_n  (rst_n),
        .hsync  (hsync_t),
        .vsync  (vsync_t),
        .active (active_t),
        .x      (x_t),
        .y      (y_t)
    );

    // This contains the instantiation for vga_reader
    vga_reader #(.ADDR_WIDTH(ADDR_WIDTH), .HRES(HRES), .SHIFT(SHIFT)) u_reader (
        .clk       (clk),
        .rst_n     (rst_n),
        .x         (x_t),
        .y         (y_t),
        .active    (active_t),
        .hsync_in  (hsync_t),
        .vsync_in  (vsync_t),
        .rdata     (rdata),
        .raddr     (raddr),
        .rgb       (vga_rgb),
        .hsync_out (vga_hsync),
        .vsync_out (vga_vsync)
    );

endmodule

`default_nettype wire
