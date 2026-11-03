// Generic SERVxZen SoC testbench: runs a firmware image on servxzen_soc, decodes the UART, and checks the RESULT line
// Parameters select the firmware, datapath width (SERV/QERV), compressed ISA and RAM size, so one file covers the whole test matrix
`timescale 1 ns / 1 ps

module tb_soc;

    // Firmware hex image to run
    parameter FIRMWARE   = "firmware/riscv/src/out/selftest.hex";
    // 1 = SERV, 4 = QERV
    parameter WIDTH      = 1;
    // 1 = core built with the C extension
    parameter COMPRESSED = 0;
    // RAM size in bytes
    parameter MEMSIZE    = 4096;
    // File written by firmware/riscv/src/build.sh holding the first free RAM byte above the image ("" = skip the stack-overlap check)
    parameter ENDFILE    = "";
    // Label printed in the final TEST_PASS/TEST_FAIL line
    parameter NAME       = "soc";
    // Simulated-time limit in microseconds (watchdog)
    parameter LIMIT_US   = 400000;

    // System clock frequency, same as the Zen 4 board (25 MHz => 40 ns period)
    localparam integer CLK_HZ = 25000000;
    // UART baud rate
    localparam integer BAUD   = 115200;
    // Clocks per UART bit, as the transmitter computes it
    localparam integer CPB    = CLK_HZ / BAUD;

    // Clock into the SoC
    reg  clk = 1'b0;
    // Active-high reset
    reg  rst = 1'b1;
    // GPIO register outputs
    wire [7:0] gpio;
    // UART line from the SoC
    wire tx;

    // Clock generator block: 40 ns period
    always #20 clk = ~clk;

    // Reset release block: hold reset for 8 clocks
    initial begin
        // Wait 8 clock periods
        repeat (8) @(posedge clk);
        // Release reset
        rst = 1'b0;
    end

    // This contains the instantiation for servxzen_soc with the simulation halt address enabled
    servxzen_soc #(
        .MEMFILE    (FIRMWARE),
        .MEMSIZE    (MEMSIZE),
        .WIDTH      (WIDTH),
        .COMPRESSED (COMPRESSED),
        .SIM        (1),
        .CLK_HZ     (CLK_HZ),
        .BAUD       (BAUD)
    ) dut (
        .i_clk     (clk),
        .i_rst     (rst),
        .o_gpio    (gpio),
        .o_uart_tx (tx)
    );

    // Receive shift register
    reg [7:0]  rx;
    // Rolling text history (last 24 characters) used to spot the RESULT line
    reg [8*24-1:0] hist = 0;
    // Number of characters received
    integer nchar = 0;
    // Set when "ALL PASS" has been printed
    reg seen_pass = 0;
    // Set when a FAIL text has been printed
    reg seen_fail = 0;

    // UART receiver block: finds a start bit, samples every bit in the middle, prints the character
    initial begin
        // Wait until reset is released
        @(negedge rst);
        // Receive forever; the firmware ends the simulation
        forever begin
            // Wait for the start bit (line falls)
            @(negedge tx);
            // Go to the middle of the start bit
            repeat (CPB / 2) @(posedge clk);
            // Eight data bits, LSB first
            repeat (8) begin
                // Move one bit time
                repeat (CPB) @(posedge clk);
                // Shift the new bit in at the top
                rx = {tx, rx[7:1]};
            end
            // Echo the character to the simulator output
            $write("%c", rx);
            // Update history and count
            hist = {hist[8*23-1:0], rx};
            nchar = nchar + 1;
            // Spot the verdict strings
            if (hist[8*14-1:0] == "RESULT: ALL PA" || hist[8*16-1:0] == "RESULT: ALL PASS") seen_pass = 1;
            if (hist[8*5-1:0] == "FAIL\n" || hist[8*5-1:0] == " FAIL" || hist[8*7-1:0] == "FAILED\n") seen_fail = 1;
        end
    end

    // End of code and constants (start of .bss), 0 when no ENDFILE is given
    integer ro_end = 0;
    // First free byte above the firmware image
    integer image_end = 0;
    // Stack bytes the linker script reserves (must match firmware/riscv/src/link.ld)
    parameter integer STACK_RESERVE = 480;
    // Set when a write hit the firmware image (code or constants), i.e. the stack grew into it
    reg stack_clash = 0;
    // Reads the image end value from the file written by the build script
    initial begin : read_end
        // File handle
        integer fd, r;
        // Only when a file name is given
        if (ENDFILE != "") begin
            // Open and read one number
            fd = $fopen(ENDFILE, "r");
            r  = $fscanf(fd, "%d %d", ro_end, image_end);
            $fclose(fd);
        end
    end

    // Stack depth monitor: lowest data write address above the image seen on the memory bus (RAM top - lowest = stack used)
    integer min_wr = 1 << 30;
    // Memory monitor block: tracks write addresses
    always @(posedge clk) begin
        // A write acknowledged on the memory bus
        if (dut.wb_mem_stb && dut.wb_mem_ack && dut.wb_mem_we && dut.wb_mem_adr < MEMSIZE) begin
            // Remember the lowest write address above the image (stack area); bss variables are below image_end
            if (dut.wb_mem_adr >= ((image_end != 0) ? image_end : MEMSIZE / 2) && dut.wb_mem_adr < min_wr) min_wr = dut.wb_mem_adr;
            // A write into code or constants (below .bss) means a stray store or a stack that grew into the image
            if (ro_end != 0 && dut.wb_mem_adr < ro_end) stack_clash = 1;
        end
    end

    // Final report block: runs when the firmware halts the simulation
    final begin
        // Verdict from the text and the GPIO LEDs (bit 0 = pass, bit 1 = fail)
        if (seen_pass && !seen_fail && gpio == 8'h01 && !stack_clash && (MEMSIZE - min_wr) <= STACK_RESERVE)
            $display("TEST_PASS %0s (%0d chars, gpio=%02x, image_end=0x%0x, stack used=%0d of %0d B, %0d clocks)", NAME, nchar, gpio, image_end, MEMSIZE - min_wr, STACK_RESERVE, $time / 40);
        else
            $display("TEST_FAIL %0s (pass_text=%0d fail_text=%0d gpio=%02x chars=%0d stack_clash=%0d stack_used=%0d)", NAME, seen_pass, seen_fail, gpio, nchar, stack_clash, MEMSIZE - min_wr);
    end

    // Watchdog block: ends a hung run
    initial begin
        // Wait the time limit
        #(LIMIT_US * 1000);
        // Report the hang and stop
        $display("TEST_FAIL %0s timeout after %0d us (chars=%0d)", NAME, LIMIT_US, nchar);
        $finish;
    end

endmodule
