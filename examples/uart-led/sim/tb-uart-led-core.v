// tb-uart-led-core.v - self-checking testbench: sends 0xAB (LED on), 0x11 (no change), 0xFF (LED off), 0xAB again, then pulses reset

`timescale 1ns/1ps

module tb_uart_led;

    // Bit time at 115200 baud for a 50 MHz clock: 434 clocks of 20 ns
    localparam BIT_NS = 434 * 20;
    // Clock
    reg clk = 1'b0;
    // Reset
    reg rst = 1'b1;
    // Serial line
    reg rx = 1'b1;
    // LED output
    wire led;
    // Error counter
    integer errs = 0;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    uart_led #(.CLK(50_000_000), .BAUD_RATE(115200)) dut (.clk(clk), .rst(rst), .rx(rx), .led(led));

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

    // Checks the LED level
    task expect_led(input e, input [255:0] what);
        begin
            if (led !== e) begin errs = errs + 1; $display("FAIL: %0s: led=%b expected %b", what, led, e); end
        end
    endtask

    // This block runs the test
    initial begin
        repeat (5) @(posedge clk);
        rst = 1'b0;
        send_byte(8'hAB); expect_led(1'b1, "after 0xAB");
        send_byte(8'h11); expect_led(1'b1, "after 0x11");
        send_byte(8'hFF); expect_led(1'b0, "after 0xFF");
        send_byte(8'hAB); expect_led(1'b1, "after second 0xAB");
        rst = 1'b1; repeat (3) @(posedge clk); rst = 1'b0; repeat (3) @(posedge clk);
        expect_led(1'b0, "after reset");
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

endmodule
