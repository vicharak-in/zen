// vga_reader.v - reads the frame buffer and drives the VGA output, each camera pixel is shown (1 << SHIFT) pixels wide and tall
`default_nettype none

module vga_reader #(
    parameter ADDR_WIDTH = 13,                 // Address bits
    parameter HRES       = 80,                 // Camera frame width in pixels
    parameter SHIFT      = 3                   // log2 of the pixel doubling factor (640 / HRES = 1 << SHIFT)
) (
    input  wire                  clk,          // VGA pixel clock
    input  wire                  rst_n,        // Active-low reset
    input  wire [9:0]            x,            // Visible-area pixel column
    input  wire [9:0]            y,            // Visible-area pixel row
    input  wire                  active,       // High inside the visible area
    input  wire                  hsync_in,     // Horizontal sync from vga_timing
    input  wire                  vsync_in,     // Vertical sync from vga_timing
    input  wire [7:0]            rdata,        // Pixel data from the frame buffer (one clock after raddr)
    output reg  [ADDR_WIDTH-1:0] raddr,        // Frame buffer read address
    output reg  [7:0]            rgb,          // Pixel data to the VGA pins (black outside the visible area)
    output reg                   hsync_out,    // Horizontal sync, delayed to match the pixel data
    output reg                   vsync_out     // Vertical sync, delayed to match the pixel data
);

    // Camera column for the current screen column
    wire [9:0] xs = x >> SHIFT;
    // Camera row for the current screen row
    wire [9:0] ys = y >> SHIFT;

    // Active flag after the address register stage
    reg active_d1;
    // Active flag after the memory read stage, lines up with rdata
    reg active_d2;
    // Horizontal sync after the address register stage
    reg hs_d1;
    // Horizontal sync after the memory read stage
    reg hs_d2;
    // Vertical sync after the address register stage
    reg vs_d1;
    // Vertical sync after the memory read stage
    reg vs_d2;

    // This block pipelines the address and the control signals to match the three-clock data path
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                                      // Clear the pipeline on reset
            raddr     <= {ADDR_WIDTH{1'b0}};                   // Read address cleared
            active_d1 <= 1'b0;                                 // Stage 1 active cleared
            active_d2 <= 1'b0;                                 // Stage 2 active cleared
            hs_d1     <= 1'b1;                                 // Stage 1 hsync idles high
            hs_d2     <= 1'b1;                                 // Stage 2 hsync idles high
            vs_d1     <= 1'b1;                                 // Stage 1 vsync idles high
            vs_d2     <= 1'b1;                                 // Stage 2 vsync idles high
            rgb       <= 8'd0;                                 // Output black
            hsync_out <= 1'b1;                                 // Output hsync idles high
            vsync_out <= 1'b1;                                 // Output vsync idles high
        end else begin                                         // Normal operation
            raddr     <= ys * HRES + xs;                       // Map the screen position to a camera pixel address
            active_d1 <= active;                               // Delay active by one clock
            hs_d1     <= hsync_in;                             // Delay hsync by one clock
            vs_d1     <= vsync_in;                             // Delay vsync by one clock
            active_d2 <= active_d1;                            // Delay active by the memory read clock
            hs_d2     <= hs_d1;                                // Delay hsync by the memory read clock
            vs_d2     <= vs_d1;                                // Delay vsync by the memory read clock
            rgb       <= active_d2 ? rdata : 8'd0;             // Show the pixel inside the visible area, black outside
            hsync_out <= hs_d2;                                // Output the aligned hsync
            vsync_out <= vs_d2;                                // Output the aligned vsync
        end
    end

endmodule

`default_nettype wire
