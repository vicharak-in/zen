// tb-dspi-pio-echo.v - self-checking testbench: a model of the RP2350 PIO state machine (the same instruction timing as the Shrike firmware: 200 ns per step, 2.5 MHz SCK)
// sends characters on the two data lines and reads the echo back; then the MCU stays quiet and the FPGA must raise the alert on the chip-select line.

`timescale 1ns/1ps

module tb_dspi_pio_echo;

    // FPGA clock
    reg clk = 1'b0;
    // MCU side
    reg sck = 1'b0;
    reg m_cs = 1'b1, m_cs_oe = 1'b0;
    reg [1:0] m_d = 2'b00;
    reg m_d_oe = 1'b0;
    // Pads
    wire ss_pad;
    wire [1:0] dual_pad;
    wire spi_ss_out, spi_ss_oe;
    wire [1:0] dual_out, dual_oe;
    wire led1;
    // Error counter
    integer errs = 0;
    // Reply
    reg [7:0] r;
    integer i;

    // 50 MHz clock
    always #10 clk = ~clk;

    // Chip select is open drain with a pull-up: the MCU or the FPGA can pull it low
    assign (pull1, strong0) ss_pad = m_cs_oe ? m_cs : 1'bz;
    assign (pull1, strong0) ss_pad = spi_ss_oe ? spi_ss_out : 1'bz;
    pullup (ss_pad);
    // Data lines
    genvar g;
    generate for (g = 0; g < 2; g = g + 1) begin : g_d
        assign dual_pad[g] = m_d_oe ? m_d[g] : 1'bz;
        assign dual_pad[g] = dual_oe[g] ? dual_out[g] : 1'bz;
    end endgenerate

    // This contains the instantiation for the design under test (short alert time and a fast heartbeat for the test)
    dspi_pio_echo_zen4_top #(.ALERT_CLKS(4000), .BLINK_BIT(7)) dut (
        .clk(clk), .btn1(1'b1), .spi_sck(sck), .spi_ss_in(ss_pad), .spi_ss_out(spi_ss_out), .spi_ss_oe(spi_ss_oe),
        .dual_in(dual_pad), .dual_out(dual_out), .dual_oe(dual_oe), .led1(led1));

    // The PIO program of the Shrike firmware, step by step (one instruction = 100 ns, [1] adds 100 ns):
    // 4 x (out pins, 2 bits | SCK low 200 ns, SCK high 200 ns), turnaround, 4 x (SCK high 200 ns, sample, SCK low 200 ns)
    task pio_xfer(input [7:0] b, output [7:0] rx);
        integer k;
        begin
            m_cs_oe = 1'b1; m_cs = 1'b0; #5000;           // Chip select low, give the FPGA time to wake up
            m_d_oe = 1'b1;                                  // set pindirs 3
            for (k = 0; k < 4; k = k + 1) begin
                m_d = b[7 - 2 * k -: 2]; sck = 1'b0; #200;
                sck = 1'b1; #200;
            end
            m_d_oe = 1'b0; sck = 1'b0; #200;                // set pindirs 0
            sck = 1'b1; #200;
            sck = 1'b0; #100;
            for (k = 0; k < 4; k = k + 1) begin
                sck = 1'b1; #200;
                sck = 1'b0; rx[7 - 2 * k -: 2] = dual_pad; #200;
            end
            #2000; m_cs = 1'b1; #100; m_cs_oe = 1'b0;       // Release chip select (pull-up takes over)
            #2000;
        end
    endtask

    // Counts heartbeat toggles
    integer toggles = 0;
    reg led_prev = 1'b1;
    always @(posedge clk) begin if (led1 !== led_prev) toggles = toggles + 1; led_prev <= led1; end

    // This block runs the test
    initial begin
        #(20 * 400);
        // Echo of a few characters
        for (i = 0; i < 6; i = i + 1) begin
            pio_xfer("h" + i * 3, r);
            if (r !== "h" + i * 3) begin errs = errs + 1; $display("FAIL: sent %h, echo %h", "h" + i * 3, r); end
        end
        pio_xfer(8'h00, r); if (r !== 8'h00) begin errs = errs + 1; $display("FAIL: echo of 0x00 is %h", r); end
        pio_xfer(8'hFF, r); if (r !== 8'hFF) begin errs = errs + 1; $display("FAIL: echo of 0xFF is %h", r); end
        pio_xfer(8'hA5, r); if (r !== 8'hA5) begin errs = errs + 1; $display("FAIL: echo of 0xA5 is %h", r); end
        // The chip-select line is high while the MCU is active
        if (ss_pad !== 1'b1) begin errs = errs + 1; $display("FAIL: chip select not high while idle"); end
        // MCU quiet: after ALERT_CLKS the FPGA pulls chip select low
        #(20 * 4200);
        if (ss_pad !== 1'b0) begin errs = errs + 1; $display("FAIL: no alert on the chip-select line"); end
        // A transfer cancels the alert (SCK activity); chip select returns high
        pio_xfer("?", r);
        $display("INFO: reply to '?' during an alert: 0x%h", r);
        #1000;
        if (ss_pad !== 1'b1) begin errs = errs + 1; $display("FAIL: alert not cleared by the transfer"); end
        // Heartbeat toggled
        if (toggles < 4) begin errs = errs + 1; $display("FAIL: heartbeat toggled only %0d times", toggles); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin
        #50_000_000;
        $display("FAIL: timeout");
        $finish;
    end

endmodule
