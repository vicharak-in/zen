// tb-serv-zink.v - testbench: a model of the RP2350 reads the SERV self-test firmware's UART report through real Zen Link frames (Zen 4 board top, 50 MHz link clock, 25 MHz SERV clock).
// It collects the report text from the bridge and passes when it contains "RESULT: ALL PASS" and the LEDs show a pass.
`timescale 1ns/1ps

module tb_serv_zink;

    // Firmware image to load into the on-chip RAM
    parameter FW = "firmware/riscv/selftest.hex";
    // 1 = SERV, 4 = QERV
    parameter WIDTH = 1;

    // Zen Link clock, 50 MHz
    reg clk = 1'b0;
    // SERV clock, 25 MHz
    reg clk_core = 1'b0;
    // The two clocks
    always #10 clk = ~clk;
    always #20 clk_core = ~clk_core;

    `include "zink-host-model.vh"

    // LED pins
    wire led1, led2;
    // Report text collected so far (last 24 characters kept for matching)
    reg [8*24-1:0] line = 0;
    // Verdict flags
    reg saw_pass = 1'b0, saw_fail = 1'b0;
    // Loop variables
    integer k, c, polls;

    // This contains the instantiation for the design under test, running the self-test firmware
    serv_zen4_top #(.FIRMWARE(FW), .WIDTH(WIDTH)) dut (.clk(clk), .clk_core(clk_core), .btn1(1'b1), .link_clk_in(m_clk), .link_csn_in(m_csn),
        .link_d_in(d_bus), .link_d_out(f_out), .link_d_oe(f_oe), .led1(led1), .led2(led2));

    // This block polls the bridge like the RP2350 script does and looks for the verdict line
    initial begin
        #(20 * 3000);
        rdn(16'h0000, 2); check8(rb[0], 8'h5A, "link ID"); check8(rb[1], 8'hA5, "link ID_INV");
        polls = 0;
        while (!saw_pass && !saw_fail && polls < 4000) begin
            rdn(16'h0102, 1); c = rb[0];
            if (c > 100) c = 100;
            if (c > 0) begin
                rdn(16'h0180, c);
                for (k = 0; k < c; k = k + 1) begin
                    $write("%c", rb[k]);
                    if (rb[k] == 8'h0A) line = 0; else line = {line[8*23-1:0], rb[k]};
                    if (line[8*16-1:0] == "RESULT: ALL PASS") saw_pass = 1'b1;
                    if (line[8*12-1:0] == "RESULT: FAIL") saw_fail = 1'b1;
                end
            end
            polls = polls + 1;
            #(100_000);
        end
        if (!saw_pass) errs = errs + 1;
        if (saw_fail) errs = errs + 1;
        // LED 1 is lit (low) once the SoC wrote the pass bit, LED 2 stays off (high)
        if (led1 !== 1'b0 || led2 !== 1'b1) begin errs = errs + 1; $display("FAIL: LEDs led1=%b led2=%b (expected 0 and 1)", led1, led2); end
        rdn(16'h0101, 1);
        if (rb[0][2] || rb[0][3]) begin errs = errs + 1; $display("FAIL: overflow flag set (status %h)", rb[0]); end
        if (errs == 0) $display("\nALL PASS: SERV reported ALL PASS over the Zen Link, led1=%b (0 = lit), led2=%b (1 = off)", led1, led2);
        else $display("\nSOME FAILED: pass=%b fail=%b", saw_pass, saw_fail);
        $finish;
    end

    // Safety timeout
    initial begin
        #400_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
