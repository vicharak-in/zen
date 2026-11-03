// tb_cam_zen_top.v - self-checking testbench for the camera-to-VGA design
`timescale 1ns/1ps

module tb_cam_zen_top;

    // Frame width in pixels
    localparam HRES  = 80;
    // Frame height in pixels
    localparam VRES  = 60;
    // log2 of the pixel doubling factor
    localparam SHIFT = 3;
    // Pixels per frame
    localparam FRAME_SIZE = HRES * VRES;
    // Total clocks per VGA frame
    localparam FRAME_CLKS = 800 * 525;

    // 25 MHz clock
    reg        clk25 = 1'b0;
    // Button, active low, not pressed
    reg        btn1 = 1'b1;
    // Pixel byte driven like the RP2350 would
    reg  [7:0] cam_pixel = 8'd0;
    // Pixel strobe driven like the RP2350 would
    reg        cam_we = 1'b0;
    // Frame start driven like the RP2350 would
    reg        cam_vsync = 1'b0;
    // VGA outputs
    wire [3:0] vga_r, vga_g, vga_b;
    wire       vga_hs, vga_vs, led1, led2;

    // Set once the frame captured LED has lit
    reg        led1_seen = 1'b0;
    // Set once the frame start LED has lit
    reg        led2_seen = 1'b0;
    // Enables the output checker
    reg        check_en = 1'b0;
    // Visible pixels compared
    integer    active_cnt = 0;
    // Pixel mismatches
    integer    pix_err = 0;
    // Sync mismatches
    integer    sync_err = 0;
    // Clocks checked
    integer    chk_cycles = 0;
    // Loop index
    integer    i;

    // Expected pixel for a camera address
    function [7:0] pat;
        input integer a;
        begin
            pat = (a & 255) ^ ((a >> 8) & 255);
        end
    endfunction

    // This contains the instantiation for cam_zen_top
    cam_zen_top dut (
        .clk25     (clk25),
        .btn1      (btn1),
        .cam_pixel (cam_pixel),
        .cam_we    (cam_we),
        .cam_vsync (cam_vsync),
        .vga_r     (vga_r),
        .vga_g     (vga_g),
        .vga_b     (vga_b),
        .vga_hs    (vga_hs),
        .vga_vs    (vga_vs),
        .led1      (led1),
        .led2      (led2)
    );

    // Clock generation, 40 ns period
    always #20 clk25 = ~clk25;

    // This block remembers that the LEDs lit
    always @(posedge clk25) begin
        if (!led1) led1_seen <= 1'b1;              // Frame captured LED lit
        if (!led2) led2_seen <= 1'b1;              // Frame start LED lit
    end

    // Three-stage history of the timing generator outputs, to line up with the three-clock output pipeline
    reg [9:0] x_d1, x_d2, x_d3, y_d1, y_d2, y_d3;
    reg       a_d1, a_d2, a_d3, h_d1, h_d2, h_d3, v_d1, v_d2, v_d3;

    // This block delays the timing outputs and compares the design output against the expected image
    always @(posedge clk25) begin
        x_d1 <= dut.u_cam.x_t;  x_d2 <= x_d1;  x_d3 <= x_d2;        // Delay the column
        y_d1 <= dut.u_cam.y_t;  y_d2 <= y_d1;  y_d3 <= y_d2;        // Delay the row
        a_d1 <= dut.u_cam.active_t; a_d2 <= a_d1; a_d3 <= a_d2;     // Delay the visible flag
        h_d1 <= dut.u_cam.hsync_t;  h_d2 <= h_d1; h_d3 <= h_d2;     // Delay hsync
        v_d1 <= dut.u_cam.vsync_t;  v_d2 <= v_d1; v_d3 <= v_d2;     // Delay vsync
        if (check_en) begin                                         // Only check after the frame is loaded
            chk_cycles <= chk_cycles + 1;                           // Count checked clocks
            if (vga_hs !== h_d3 || vga_vs !== v_d3)                 // Syncs must match the delayed timing
                sync_err <= sync_err + 1;                           // Record a sync mismatch
            if (a_d3) begin                                         // Inside the visible area
                active_cnt <= active_cnt + 1;                       // Count the visible pixel
                if (vga_r !== (pat((y_d3 >> SHIFT) * HRES + (x_d3 >> SHIFT)) >> 4) ||
                    vga_g !== vga_r || vga_b !== vga_r)             // All three channels must carry the pixel top nibble
                    pix_err <= pix_err + 1;                         // Record a pixel mismatch
            end else if (vga_r !== 4'd0 || vga_g !== 4'd0 || vga_b !== 4'd0) // Outside the visible area the output must be black
                pix_err <= pix_err + 1;                             // Record a blanking mismatch
        end
    end

    // This block runs the test sequence
    initial begin
        repeat (400) @(posedge clk25);               // Wait for the power-on reset to finish
        cam_vsync = 1'b1;                            // Start a frame with a rising vsync
        repeat (6) @(posedge clk25);                 // Hold it for a few clocks
        cam_vsync = 1'b0;                            // Drop vsync
        repeat (6) @(posedge clk25);                 // Wait before the first pixel
        for (i = 0; i < FRAME_SIZE; i = i + 1) begin // Send every pixel of the frame
            cam_pixel = pat(i);                      // Put the pixel on the bus
            repeat (2) @(posedge clk25);             // Let the data settle before the strobe
            cam_we = 1'b1;                           // Raise the strobe
            repeat (3) @(posedge clk25);             // Hold the strobe
            cam_we = 1'b0;                           // Drop the strobe
            repeat (3) @(posedge clk25);             // Gap before the next pixel
        end
        repeat (20) @(posedge clk25);                // Let the last write finish
        if (!led1_seen || !led2_seen) begin          // Both LEDs must have lit
            $display("FAIL: LEDs led1_seen=%0d led2_seen=%0d", led1_seen, led2_seen);
            $finish;
        end
        @(posedge clk25);                            // Align to the clock
        check_en = 1'b1;                             // Start checking the output
        repeat (FRAME_CLKS + 8) @(posedge clk25);    // Check exactly one frame period plus pipeline margin
        check_en = 1'b0;                             // Stop checking
        @(posedge clk25);                            // Let the final counts settle
        $display("checked clocks = %0d, visible pixels = %0d (expect %0d)", chk_cycles, active_cnt, 640 * 480);
        $display("pixel errors = %0d, sync errors = %0d", pix_err, sync_err);
        if (pix_err == 0 && sync_err == 0 && active_cnt >= 640 * 480 - 8 && active_cnt <= 640 * 480 + 8)
            $display("PASS");
        else
            $display("FAIL");
        $finish;
    end

    // This block stops a hung simulation
    initial begin
        #60_000_000;                                 // 60 ms of simulated time
        $display("FAIL: timeout");
        $finish;
    end

endmodule
