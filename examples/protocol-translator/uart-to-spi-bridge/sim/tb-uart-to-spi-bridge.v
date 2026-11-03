// tb-uart-to-spi-bridge.v - self-checking testbench for the UART <-> SPI bridge with MOSI wired to MISO (as in the original test): every byte sent on the UART must come back unchanged.
// Also checks that chip select pulses once per byte and that a burst of back-to-back bytes is returned in order.

`timescale 1ns/1ps

module tb_uart_to_spi_bridge;

    // 50 MHz clock
    reg clk = 1'b0;
    always #10 clk = ~clk;
    // UART from the host
    reg rx = 1'b1;
    wire tx, sclk, cs, mosi;
    // Reset, active low
    reg rst_n = 1'b0;
    integer errs = 0;

    // This contains the instantiation for the design under test (MOSI looped to MISO)
    uart_to_spi_bridge_zen4_top dut (.clk(clk), .btn1(rst_n), .rx(rx), .tx(tx), .sclk(sclk), .cs(cs), .mosi(mosi), .miso(mosi));

    // UART transmit, 115200 8N1
    localparam BIT = 8680;
    task uart_send; input [7:0] d; integer i; begin
        rx = 1'b0; #BIT;
        for (i = 0; i < 8; i = i + 1) begin rx = d[i]; #BIT; end
        rx = 1'b1; #BIT;
    end endtask

    // UART receive
    reg [7:0] rxbuf [0:63];
    integer nrx = 0;
    integer ri;
    always @(negedge tx) begin : rx_proc
        reg [7:0] v;
        #(BIT / 2);
        if (tx === 1'b0) begin
            for (ri = 0; ri < 8; ri = ri + 1) begin #BIT; v[ri] = tx; end
            #BIT;
            rxbuf[nrx] = v; nrx = nrx + 1;
        end
    end

    // Chip select pulse counter
    integer ncs = 0;
    always @(negedge cs) ncs = ncs + 1;

    // Test data
    reg [7:0] vec [0:11];
    integer idx;

    // This block runs the test
    initial begin
        vec[0] = 8'h00; vec[1] = 8'hFF; vec[2] = 8'h55; vec[3] = 8'hAA; vec[4] = 8'h01; vec[5] = 8'h80;
        vec[6] = 8'hC8; vec[7] = 8'h7F; vec[8] = 8'h47; vec[9] = 8'h3C; vec[10] = 8'hE1; vec[11] = 8'h12;
        #1000; rst_n = 1'b1; #20000;
        // One byte at a time
        for (idx = 0; idx < 12; idx = idx + 1) begin
            nrx = 0; ncs = 0;
            uart_send(vec[idx]);
            #300000;
            if (nrx != 1) begin errs = errs + 1; $display("FAIL: byte %0d: %0d bytes came back", idx, nrx); end
            else if (rxbuf[0] !== vec[idx]) begin errs = errs + 1; $display("FAIL: byte %0d: sent 0x%h got 0x%h", idx, vec[idx], rxbuf[0]); end
            if (ncs != 1) begin errs = errs + 1; $display("FAIL: byte %0d: chip select pulsed %0d times", idx, ncs); end
        end
        // Burst of 4 bytes with no gaps
        nrx = 0; ncs = 0;
        for (idx = 0; idx < 4; idx = idx + 1) uart_send(vec[idx + 6]);
        #600000;
        if (nrx != 4) begin errs = errs + 1; $display("FAIL: burst: %0d bytes came back", nrx); end
        else for (idx = 0; idx < 4; idx = idx + 1) if (rxbuf[idx] !== vec[idx + 6]) begin errs = errs + 1; $display("FAIL: burst byte %0d: expected 0x%h got 0x%h", idx, vec[idx + 6], rxbuf[idx]); end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin #400_000_000; $display("FAIL: timeout"); $finish; end

endmodule
