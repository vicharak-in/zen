// tb-spi-to-uart-bridge.v - self-checking testbench for the SPI <-> UART bridge.
// A SPI host sends a byte; the UART peer must see it, answers with the inverted byte, and the host reads that answer back over SPI (two reads, as in the board script: the FPGA loads its SPI transmit byte at the start of a frame).
// Note: the bridge sends every SPI byte to the UART twice (a direct path and a FIFO path), and the dummy read bytes are forwarded as well; the board script flushes its UART buffer for the same reason,
// so this test waits for the line to go idle before each vector, then requires the first UART byte to be right and checks the count is 1 or 2.

`timescale 1ns/1ps

module tb_spi_to_uart_bridge;

    // 50 MHz clock
    reg clk = 1'b0;
    always #10 clk = ~clk;
    // SPI host signals
    reg spi_sck = 1'b0, spi_cs = 1'b1, spi_mosi = 1'b0;
    wire spi_miso;
    // UART lines
    reg uart_rx = 1'b1;
    wire uart_tx, fpga_ready;
    integer errs = 0;

    // This contains the instantiation for the design under test
    spi_to_uart_bridge dut (.clk(clk), .spi_sck(spi_sck), .spi_cs(spi_cs), .spi_mosi(spi_mosi), .spi_miso(spi_miso), .uart_rx(uart_rx), .uart_tx(uart_tx), .fpga_ready(fpga_ready));

    // SPI host, mode 0, 1 MHz, MSB first: sends one byte and returns the byte shifted out of MISO
    localparam HALF = 500;
    task spi_xfer; input [7:0] tx; output [7:0] rx; integer i; begin
        spi_cs = 1'b0; #(HALF * 2);
        for (i = 7; i >= 0; i = i - 1) begin
            spi_mosi = tx[i]; #HALF;
            spi_sck = 1'b1;   #(HALF / 2);
            rx[i] = spi_miso; #(HALF / 2);
            spi_sck = 1'b0;
        end
        #(HALF * 2); spi_cs = 1'b1; #(HALF * 2);
    end endtask

    // UART peer transmit, 115200 8N1 (8680 ns per bit)
    localparam BIT = 8680;
    task uart_send; input [7:0] d; integer i; begin
        uart_rx = 1'b0; #BIT;
        for (i = 0; i < 8; i = i + 1) begin uart_rx = d[i]; #BIT; end
        uart_rx = 1'b1; #BIT;
    end endtask

    // UART peer receive: collects bytes sent by the bridge
    reg [7:0] rxbuf [0:15];
    integer nrx = 0;
    integer ri;
    always @(negedge uart_tx) begin : rx_proc
        reg [7:0] v;
        #(BIT / 2);
        if (uart_tx === 1'b0) begin
            for (ri = 0; ri < 8; ri = ri + 1) begin #BIT; v[ri] = uart_tx; end
            #BIT;
            if (nrx < 16) begin rxbuf[nrx] = v; nrx = nrx + 1; end
        end
    end

    // Test data
    reg [7:0] vec [0:7];
    integer idx;
    reg [7:0] req, resp, junk, got;

    // This block runs the test
    initial begin
        vec[0] = 8'hC8; vec[1] = 8'h7F; vec[2] = 8'h47; vec[3] = 8'h00; vec[4] = 8'hFF; vec[5] = 8'h55; vec[6] = 8'hAA; vec[7] = 8'h01;
        #20000;
        if (fpga_ready !== 1'b1) begin errs = errs + 1; $display("FAIL: fpga_ready low when idle"); end
        for (idx = 0; idx < 8; idx = idx + 1) begin
            req = vec[idx]; resp = ~req;
            // Let the UART go idle: the dummy SPI reads of the previous vector were also forwarded to the UART (the board script flushes its UART buffer for the same reason)
            #1_000_000;
            nrx = 0;
            // SPI -> UART
            spi_xfer(req, junk);
            #400000;
            if (nrx < 1 || nrx > 2) begin errs = errs + 1; $display("FAIL: vector %0d: %0d UART bytes, expected 1 or 2", idx, nrx); end
            else if (rxbuf[0] !== req || (nrx == 2 && rxbuf[1] !== req)) begin errs = errs + 1; $display("FAIL: vector %0d: UART saw 0x%h, expected 0x%h", idx, rxbuf[0], req); end
            // UART -> SPI
            uart_send(resp);
            #200000;
            spi_xfer(8'h00, junk);
            #100000;
            spi_xfer(8'h00, got);
            if (got !== resp) begin errs = errs + 1; $display("FAIL: vector %0d: SPI read 0x%h, expected 0x%h", idx, got, resp); end
            #50000;
        end
        if (errs == 0) $display("ALL PASS"); else $display("SOME FAILED");
        $finish;
    end

    // Safety timeout
    initial begin #400_000_000; $display("FAIL: timeout"); $finish; end

endmodule
