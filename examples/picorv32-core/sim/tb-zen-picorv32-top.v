// This is the testbench that runs the firmware and checks the GPIO write
`timescale 1 ns / 1 ps

module tb_zen_picorv32_top;

    // Testbench clock
    reg clk = 1'b0;
    // Testbench button 1 (low = reset pressed)
    reg btn1 = 1'b0;
    // LED 1 output from the DUT (active low)
    wire led1;
    // LED 2 output from the DUT (active low, lit on trap)
    wire led2;

    // 50 MHz clock generator (20 ns period)
    always #10 clk = ~clk;

    // This contains the instantiation for zen_picorv32_top
    zen_picorv32_top #(
        .MEM_WORDS (256),
        .FIRMWARE  ("sim/firmware-test.hex")
    ) dut (
        .clk  (clk),
        .btn1 (btn1),
        .led1 (led1),
        .led2 (led2),
        .uart_tx ()
    );

    // Stimulus block: releases reset, waits, then checks the result
    initial begin
        // Hold reset (button pressed) for 10 clocks
        repeat (10) @(posedge clk);
        // Release the button
        btn1 = 1'b1;
        // Let the firmware run
        repeat (600) @(posedge clk);
        // Check that the firmware's dependent-register chain (5, 6, 11, then MUL 11*6 = 0x42) reached GPIO and did not trap (led2 is not used here because 0x42 has bit 1 set, the firmware fail flag)
        if (dut.gpio_reg === 8'h42 && dut.trap === 1'b0) $display("PASS: gpio_reg = 0x%02h", dut.gpio_reg);
        // Otherwise report failure
        else $display("FAIL: gpio_reg = 0x%02h, led1 = %b, led2 = %b", dut.gpio_reg, led1, led2);
        // End the simulation
        $finish;
    end

endmodule
