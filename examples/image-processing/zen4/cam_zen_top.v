// cam_zen_top.v - board top for the camera-to-VGA design on the Vicharak Zen 4 (Trion T4F81).
// The RP2350 sends pixels over the ten internal Zen Link pads used as plain GPIO:
//   cam_pixel[7:0] = GPIOL_00, 03, 05, 07, 04, 02, 01, 06 (RP2350 GPIO 24, 25, 26, 27, 0, 1, 2, 3)
//   cam_we         = GPIOL_09 (RP2350 GPIO28), pulse high for at least 2 clocks (80 ns) per pixel
//   cam_vsync      = GPIOL_10 (RP2350 GPIO29), rising edge starts a frame
// VGA is a 4-bit resistor DAC per colour. The picture is grayscale: R = G = B = pixel[7:4].
// Fabric clock: 50 MHz oscillator on GPIOL_20 -> PLL x16 / 32 = 25 MHz.
//   led1 = a full frame was captured (stretched), led2 = a frame start was seen (stretched), both active low.
//   btn1 resets the design (active low).
`default_nettype none

module cam_zen_top (
    input  wire       clk25,       // 25 MHz fabric clock from the PLL
    input  wire       btn1,        // Button 1, active low: reset the design
    input  wire [7:0] cam_pixel,   // Pixel byte from the RP2350
    input  wire       cam_we,      // Pixel strobe from the RP2350
    input  wire       cam_vsync,   // Frame start from the RP2350
    output wire [3:0] vga_r,       // VGA red, through the resistor ladder
    output wire [3:0] vga_g,       // VGA green, through the resistor ladder
    output wire [3:0] vga_b,       // VGA blue, through the resistor ladder
    output wire       vga_hs,      // VGA horizontal sync
    output wire       vga_vs,      // VGA vertical sync
    output wire       led1,        // LED 1, active low: a full frame was captured
    output wire       led2         // LED 2, active low: a frame start was seen
);

    // Power-on reset counter: holds the design in reset for 255 clocks after configuration
    reg  [7:0]  por = 8'd0;
    // Two-flop synchroniser for the button (pressed = 0)
    reg  [1:0]  btn_sync = 2'b11;
    // Active-low reset: power-on counter finished and button not pressed
    wire        rst_n = (por == 8'hFF) & btn_sync[1];
    // Pixel data from the core
    wire [7:0]  vga_rgb;
    // One-clock pulse from the core when a full frame was captured
    wire        frame_done;
    // One-clock pulse from the core when a new frame starts
    wire        frame_start;
    // Stretch counter for the frame-done LED
    reg  [22:0] done_cnt  = 23'd0;
    // Stretch counter for the frame-start LED
    reg  [22:0] start_cnt = 23'd0;

    // This block runs the power-on counter and the button synchroniser
    always @(posedge clk25) begin
        if (por != 8'hFF) por <= por + 8'd1;       // Count until the end value, then stay
        btn_sync <= {btn_sync[0], btn1};           // Button is active low
    end

    // This block stretches the frame pulses so the LEDs are visible
    always @(posedge clk25) begin
        if (frame_done)  done_cnt  <= {23{1'b1}};          // Reload on a frame-done pulse
        else if (done_cnt != 0)  done_cnt  <= done_cnt - 23'd1;  // Count down while lit
        if (frame_start) start_cnt <= {23{1'b1}};          // Reload on a frame-start pulse
        else if (start_cnt != 0) start_cnt <= start_cnt - 23'd1; // Count down while lit
    end

    // LED 1 sinks current while the stretch counter runs
    assign led1 = ~(done_cnt  != 0);
    // LED 2 sinks current while the stretch counter runs
    assign led2 = ~(start_cnt != 0);
    // Red uses the top four bits of the pixel
    assign vga_r = vga_rgb[7:4];
    // Green uses the top four bits of the pixel
    assign vga_g = vga_rgb[7:4];
    // Blue uses the top four bits of the pixel
    assign vga_b = vga_rgb[7:4];

    // This contains the instantiation for cam_top
    cam_top #(.HRES(80), .VRES(60), .SHIFT(3)) u_cam (
        .clk         (clk25),
        .rst_n       (rst_n),
        .cam_pixel   (cam_pixel),
        .cam_we      (cam_we),
        .cam_vsync   (cam_vsync),
        .vga_rgb     (vga_rgb),
        .vga_hsync   (vga_hs),
        .vga_vsync   (vga_vs),
        .frame_done  (frame_done),
        .frame_start (frame_start)
    );

endmodule

`default_nettype wire
