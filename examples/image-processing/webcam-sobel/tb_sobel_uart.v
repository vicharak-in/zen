// tb_sobel_uart.v - self-checking testbench for sobel_uart_top: several picture sizes, padding, a bad header, and a stalled frame.
`timescale 1ns / 1ps

module tb_sobel_uart;

    // Clocks per UART bit (override with -Ptb_sobel_uart.CPB=n).
    parameter CPB = 8;
    // Widest picture the design under test holds.
    localparam MAXW = 32;
    // Clocks of silence that drop a half-sent frame.
    localparam TMO = 3000;
    // Largest number of pixels used in the test.
    localparam MAXN = 32 * 24;

    // Clock.
    reg         clk = 1'b0;
    // Reset, active high.
    reg         rst = 1'b1;
    // Line from the testbench to the design.
    reg         rx_line = 1'b1;
    // Line from the design to the testbench.
    wire        tx_line;
    // Frame done pulse (unused by the checks).
    wire        frame_done;
    // Receive pulse (unused by the checks).
    wire        rx_seen;
    // Current picture width.
    integer     cw;
    // Current picture height.
    integer     ch;
    // Input image.
    reg  [7:0]  img [0:MAXN-1];
    // Bytes captured from the design.
    reg  [7:0]  got [0:MAXN+63];
    // Number of bytes captured.
    integer     ngot = 0;
    // Error counter.
    integer     errors = 0;
    // Loop index.
    integer     i;
    // Byte from the capture receiver.
    wire [7:0]  cap_data;
    // Pulse from the capture receiver.
    wire        cap_valid;

    // Clock: 100 MHz in simulation.
    always #5 clk = ~clk;

    // This contains the instantiation for the design under test
    sobel_uart_top #(.MAXW(MAXW), .CLKS_PER_BIT(CPB), .TIMEOUT(TMO)) dut (
        .clk        (clk),
        .rst        (rst),
        .rx         (rx_line),
        .tx         (tx_line),
        .frame_done (frame_done),
        .rx_seen    (rx_seen)
    );

    // This contains the instantiation for the capture receiver on the design's output
    uart_rx #(.CLKS_PER_BIT(CPB)) cap (
        .clk   (clk),
        .rst   (rst),
        .rx    (tx_line),
        .data  (cap_data),
        .valid (cap_valid)
    );

    // This block stores every byte the design sends
    always @(posedge clk) begin
        if (cap_valid) begin
            got[ngot] <= cap_data;     // Store the byte
            ngot      <= ngot + 1;     // Count it
        end
    end

    // Send one byte on rx_line as an 8N1 UART frame.
    task send_byte(input [7:0] b);
        integer k;
        begin
            rx_line = 1'b0;                              // Start bit
            repeat (CPB) @(posedge clk);                 // Hold one bit time
            for (k = 0; k < 8; k = k + 1) begin
                rx_line = b[k];                          // Data bit, LSB first
                repeat (CPB) @(posedge clk);             // Hold one bit time
            end
            rx_line = 1'b1;                              // Stop bit
            repeat (CPB) @(posedge clk);                 // Hold one bit time
        end
    endtask

    // Fill img (cw x ch) with a test pattern: a bright box on a gradient, changed by p.
    task make_image(input integer p);
        integer x, y;
        begin
            for (y = 0; y < ch; y = y + 1)
                for (x = 0; x < cw; x = x + 1)
                    img[y*cw + x] = (x >= cw/3 && x < 2*cw/3 && y >= ch/4 && y < 3*ch/4) ? (8'd200 ^ p[7:0])
                                                                                     : ((x*13 + y*29 + p*7) & 8'h7F);
        end
    endtask

    // Expected Sobel output for pixel index idx of img (border = 0).
    function [7:0] expect_px(input integer idx);
        integer x, y, gx, gy, m;
        begin
            y = idx / cw;
            x = idx % cw;
            if (x == 0 || y == 0 || x == cw-1 || y == ch-1) expect_px = 8'd0;
            else begin
                gx = (img[(y-1)*cw+x+1] + 2*img[y*cw+x+1] + img[(y+1)*cw+x+1])
                   - (img[(y-1)*cw+x-1] + 2*img[y*cw+x-1] + img[(y+1)*cw+x-1]);
                gy = (img[(y+1)*cw+x-1] + 2*img[(y+1)*cw+x] + img[(y+1)*cw+x+1])
                   - (img[(y-1)*cw+x-1] + 2*img[(y-1)*cw+x] + img[(y-1)*cw+x+1]);
                if (gx < 0) gx = -gx;
                if (gy < 0) gy = -gy;
                m = gx + gy;
                expect_px = (m > 255) ? 8'd255 : m;
            end
        end
    endfunction

    // Send a header for the given size.
    task send_header(input integer w, input integer h);
        begin
            send_byte(8'hA5);
            send_byte(w[7:0]);
            send_byte(w[15:8]);
            send_byte(h[7:0]);
            send_byte(h[15:8]);
        end
    endtask

    // Send the whole image (header, pixels) followed by extra padding bytes.
    task send_frame(input integer pad);
        integer k;
        begin
            send_header(cw, ch);
            for (k = 0; k < cw*ch; k = k + 1) send_byte(img[k]);   // The frame
            for (k = 0; k < pad; k = k + 1) send_byte(8'hFF);      // Padding the design must ignore
        end
    endtask

    // Wait for all result bytes (or give up), then compare them with the reference.
    task check_frame(input [255:0] name);
        integer t, k, bad, n;
        begin
            n = cw * ch;
            t = 0;
            while (ngot < n && t < 600000) begin @(posedge clk); t = t + 1; end   // Wait for the results
            repeat (CPB * 40) @(posedge clk);                                      // Let any extra bytes show up
            bad = 0;
            if (ngot != n) begin
                $display("FAIL %0s: got %0d bytes, expected %0d", name, ngot, n);
                bad = 1;
            end
            for (k = 0; k < n && k < ngot; k = k + 1)
                if (got[k] !== expect_px(k)) begin
                    if (bad < 6) $display("FAIL %0s: byte %0d got %0d expected %0d", name, k, got[k], expect_px(k));
                    bad = bad + 1;
                end
            if (bad == 0) $display("ok   %0s (%0dx%0d): %0d bytes match", name, cw, ch, ngot);
            else errors = errors + 1;
            ngot = 0;                                                              // Ready for the next frame
        end
    endtask

    // Main test sequence.
    initial begin
        repeat (20) @(posedge clk);
        rst = 1'b0;
        repeat (50) @(posedge clk);
        cw = 16; ch = 12; make_image(0);  send_frame(0);  check_frame("16x12");
        cw = 32; ch = 24; make_image(9);  send_frame(5);  check_frame("widest 32x24 + padding");
        cw = 3;  ch = 3;  make_image(4);  send_frame(0);  check_frame("smallest");
        cw = 20; ch = 7;  make_image(11); send_frame(63); check_frame("20x7 + long padding");
        // Bad header (width 2 is not allowed) must be ignored, then a good frame follows.
        send_header(2, 5);
        send_header(40, 5);
        cw = 18; ch = 10; make_image(2);  send_frame(0);  check_frame("after bad headers");
        // Stalled frame: half a frame, then silence longer than the timeout, then a clean frame.
        cw = 16; ch = 12; make_image(3);
        send_header(cw, ch);
        for (i = 0; i < cw*ch/2; i = i + 1) send_byte(img[i]);
        repeat (TMO + 800) @(posedge clk);
        ngot = 0;
        make_image(21);  send_frame(0);  check_frame("after a stalled frame");
        // Dump the last picture and its result for the Python cross-check.
        begin : dump
            integer fin, fout;
            fin = $fopen("sobel_in.hex", "w");
            fout = $fopen("sobel_out.hex", "w");
            for (i = 0; i < cw*ch; i = i + 1) begin
                $fdisplay(fin, "%02x", img[i]);
                $fdisplay(fout, "%02x", expect_px(i));
            end
            $fclose(fin);
            $fclose(fout);
        end
        if (errors == 0) $display("PASS");
        else $display("FAIL: %0d frame(s) wrong", errors);
        $finish;
    end

    // Safety stop.
    initial begin
        #400000000;
        $display("FAIL: testbench timeout");
        $finish;
    end

endmodule
