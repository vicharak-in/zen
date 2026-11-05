// This is the testbench that runs the self-check firmware and decodes the UART pin like a serial terminal (115200 8N1)
`timescale 1 ns / 1 ps

module tb_selftest;
    // 25 MHz clock: 40 ns period
    reg clk = 1'b0;
    // Button level (active low reset): low at start, then released
    reg btn1 = 1'b0;
    // LED outputs (active low)
    wire led1, led2;
    // UART transmit line from the CPU system
    wire uart_tx;

    // Clock generator: toggles every 20 ns
    always #20 clk = ~clk;

    // This contains the instantiation for zen_picorv32_top running the self-check firmware
    zen_picorv32_top #(
        .FIRMWARE ("firmware/riscv/src/selftest.hex")
    ) dut (
        .clk     (clk),
        .btn1    (btn1),
        .led1    (led1),
        .led2    (led2),
        .uart_tx (uart_tx)
    );

    // Clock cycles per UART bit (25 MHz / 115200 = 217.01; a real receiver samples mid-bit using its own clock)
    localparam real BIT_NS = 1e9 / 115200.0;

    // Last received byte and a flag for the printer
    reg [7:0] rx_byte;
    // Line buffer used to spot the verdict lines
    reg [8*24-1:0] line;
    // Final verdict flags set by the receiver
    reg saw_pass = 1'b0, saw_fail = 1'b0;

    // UART receiver process: waits for a falling edge (start bit), then samples each bit in the middle of its slot
    initial begin
        // Wait until after reset release before listening
        #1000;
        // Receive bytes forever
        forever begin
            // Wait for the start bit
            @(negedge uart_tx);
            // Move to the middle of the start bit
            #(BIT_NS / 2.0);
            // Make sure it is still low (not a glitch)
            if (uart_tx !== 1'b0) begin
                $display("[tb] glitch on uart_tx");
            end else begin : rx
                // Bit counter
                integer i;
                // Shift in 8 data bits, LSB first
                for (i = 0; i < 8; i = i + 1) begin
                    // Advance one full bit time
                    #(BIT_NS);
                    // Sample the data bit
                    rx_byte[i] = uart_tx;
                end
                // Advance to the middle of the stop bit
                #(BIT_NS);
                // The stop bit must be high
                if (uart_tx !== 1'b1) $display("[tb] framing error");
                // Print the byte as a character
                $write("%c", rx_byte);
                // Keep a rolling line buffer
                if (rx_byte == 8'h0A) line = 0; else line = {line[8*23-1:0], rx_byte};
                // Detect the verdict lines
                if (line[8*16-1:0] == "RESULT: ALL PASS") saw_pass = 1'b1;
                if (line[8*12-1:0] == "RESULT: FAIL") saw_fail = 1'b1;
            end
        end
    end

    // Main control: release reset, then wait for a verdict or time out
    initial begin
        // Hold reset for a while
        #400;
        // Release the button (reset ends after the synchroniser)
        btn1 = 1'b1;
        // Wait up to 60 ms of simulated time for the first full report (about 2.5 million cycles)
        #60_000_000;
        // Decide the outcome
        if (saw_pass && !saw_fail) $display("\n[tb] PASS: firmware reported ALL PASS, led1=%b (0 = lit), led2=%b (1 = off)", led1, led2);
        else                       $display("\n[tb] FAIL: pass=%b fail=%b led1=%b led2=%b", saw_pass, saw_fail, led1, led2);
        // Stop the simulation
        $finish;
    end
endmodule
