// tb-uart-sum-core.v - self-checking testbench: sends operand pairs (3,4), (200,100), (0,0) and (255,1) and decodes the reply byte from the tx line

`timescale 1ns/1ps

module tb_uart_sum;

    // Bit time at 115200 baud for a 50 MHz clock: 434 clocks of 20 ns
    localparam BIT_NS = 434 * 20;
    // Clock
    reg clk = 1'b0;
    // Reset
    reg rst = 1'b1;
    // Serial line into the design
    reg rx = 1'b1;
    // Serial line out of the design
    wire tx;
    // Error counter
    integer errs = 0;
    // Reply byte
    reg [7:0] reply;

    // 50 MHz clock
    always #10 clk = ~clk;

    // This contains the instantiation for the design under test
    uart_sum #(.CLK(50_000_000), .BAUD_RATE(115200)) dut (.clk(clk), .rst(rst), .rx(rx), .tx(tx));

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

    // Waits for a start bit on tx, then samples each bit in its middle
    task recv_byte(output [7:0] b);
        integer k;
        begin
            @(negedge tx);
            #(BIT_NS / 2);
            for (k = 0; k < 8; k = k + 1) begin #(BIT_NS); b[k] = tx; end
            #(BIT_NS);
            if (tx !== 1'b1) begin errs = errs + 1; $display("FAIL: stop bit low"); end
        end
    endtask

    // Sends two operands and checks the sum that comes back
    task check_sum(input [7:0] a, input [7:0] b);
        begin
            send_byte(a);
            fork
                send_byte(b);
                begin : waiter
                    recv_byte(reply);
                end
            join
            if (reply !== a + b) begin errs = errs + 1; $display("FAIL: %0d + %0d = %0d, expected %0d", a, b, reply, (a + b) & 255); end
        end
    endtask

    // This block runs the test
    initial begin
        repeat (5) @(posedge clk);
        rst = 1'b0;
        repeat (50) @(posedge clk);
        check_sum(8'd3, 8'd4);
        check_sum(8'd200, 8'd100);
        check_sum(8'd0, 8'd0);
        check_sum(8'd255, 8'd1);
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #200_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
