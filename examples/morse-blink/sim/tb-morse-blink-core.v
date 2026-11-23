// tb-morse-blink-core.v - self-checking testbench at CLK = 1.152 MHz (10 clocks per UART bit, DOT_TIME = 230400 clocks): sends 'S', 'o', 'A' and '!' and measures the
// LED pulses. S = three dots, o = three dashes, A = dot + dash, '!' = nothing.

`timescale 1ns/1ps

module tb_morse_blink;

    // Clock rate of the test and the dot time that follows from it
    localparam CLKHZ = 1_152_000;
    localparam DOT = CLKHZ / 5;
    // Bit time: 10 clocks of the 1.152 MHz clock (868 ns each, rounded to 870 ns)
    localparam CLK_NS = 868;
    localparam BIT_NS = 10 * CLK_NS;
    // Clock
    reg clk = 1'b0;
    // Serial line
    reg rx = 1'b1;
    // LED output
    wire LED;
    // Error counter
    integer errs = 0;
    // Pulse log
    integer pulses = 0, width = 0, w0 = 0, w1 = 0, w2 = 0;
    // Previous LED value
    reg prev = 1'b0;

    // 1.152 MHz clock (half period 434 ns)
    always #434 clk = ~clk;

    // This contains the instantiation for the design under test
    morse_blink #(.CLK(CLKHZ), .BAUD_RATE(115200)) dut (.clk(clk), .rx(rx), .LED(LED));

    // Sends one 8N1 byte, LSB first, on the serial line
    task send_byte(input [7:0] b);
        integer k;
        begin
            rx = 1'b0; #(BIT_NS);
            for (k = 0; k < 8; k = k + 1) begin rx = b[k]; #(BIT_NS); end
            rx = 1'b1; #(BIT_NS);
            #(BIT_NS);
        end
    endtask

    // This block logs the width (in clocks) of each LED pulse
    always @(posedge clk) begin
        prev <= LED;
        if (LED) width = width + 1;
        if (!LED && prev) begin
            if (pulses == 0) w0 = width; else if (pulses == 1) w1 = width; else if (pulses == 2) w2 = width;
            pulses = pulses + 1; width = 0;
        end
    end

    // Waits for the letter to finish (idle state) and checks the pulses
    task finish_letter(input integer n, input integer expect_dash_mask, input integer wait_dots, input [127:0] what);
        integer j, wj, e;
        begin
            // Wait until the letter has finished (the core ignores bytes that arrive while it is busy)
            repeat (wait_dots * DOT) @(posedge clk);
            if (pulses !== n) begin errs = errs + 1; $display("FAIL: %0s gave %0d pulses, expected %0d", what, pulses, n); end
            for (j = 0; j < n; j = j + 1) begin
                wj = (j == 0) ? w0 : (j == 1) ? w1 : w2;
                e = (expect_dash_mask >> j) & 1 ? 3 * DOT : DOT;
                if (wj < e || wj > e + 4) begin errs = errs + 1; $display("FAIL: %0s pulse %0d is %0d clocks, expected %0d", what, j, wj, e); end
            end
            pulses = 0; width = 0;
        end
    endtask

    // This block runs the test
    initial begin
        repeat (20) @(posedge clk);
        send_byte("S"); finish_letter(3, 3'b000, 7, "S");
        send_byte("o"); finish_letter(3, 3'b111, 13, "o");
        send_byte("A"); finish_letter(2, 3'b010, 7, "A");
        send_byte("!"); finish_letter(0, 3'b000, 2, "!");
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
