// This is the testbench for the LZSS compressor firmware: it plays the PC, sending blocks over the UART RX pin and decoding the TX pin (115200 8N1)
`timescale 1 ns / 1 ps

module tb_lzss_core;
    // Number of input bytes in lzss-in.hex (set from the command line with -P if the file changes)
    parameter NBYTES = 0;

    // 25 MHz clock: 40 ns period
    reg clk = 1'b0;
    // Button level (active low reset): low at start, then released
    reg btn1 = 1'b0;
    // LED outputs (active low)
    wire led1, led2;
    // UART lines: TX comes from the board, RX goes to the board and idles high
    wire uart_tx;
    reg  uart_rx = 1'b1;

    // Clock generator: toggles every 20 ns
    always #20 clk = ~clk;

    // This contains the instantiation for zen_picorv32_top running the LZSS firmware
    zen_picorv32_top #(
        .FIRMWARE ("firmware/riscv/src/lzss.hex"),
        .POR_BITS (4)
    ) dut (
        .clk     (clk),
        .btn1    (btn1),
        .led1    (led1),
        .led2    (led2),
        .uart_tx (uart_tx),
        .uart_rx (uart_rx)
    );

    // Nanoseconds per UART bit at 115200 baud (the PC side uses exact timing; the board counts 217 cycles = 8680 ns)
    localparam real BIT_NS = 1e9 / 115200.0;

    // Input bytes, loaded from a hex file with one byte per line
    reg [7:0] input_bytes [0:1023];

    // This task sends one byte to the board as 8N1 on uart_rx
    task send_byte(input [7:0] b);
        integer i;
        begin
            // Start bit
            uart_rx = 1'b0; #(BIT_NS);
            // Eight data bits, least significant first
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = b[i]; #(BIT_NS);
            end
            // Stop bit
            uart_rx = 1'b1; #(BIT_NS);
        end
    endtask

    // Queue of bytes received from the board, filled by the always-listening receiver below
    reg [7:0] rxq [0:1023];
    // Write and read positions of the queue
    integer wr = 0, rd = 0;

    // Receiver process: runs for the whole simulation, decoding every frame on uart_tx (sampling in the middle of each bit)
    initial begin : receiver
        integer i;
        reg [7:0] b;
        forever begin
            // Wait for the start bit
            @(negedge uart_tx);
            // Move to the middle of the start bit
            #(BIT_NS / 2.0);
            // Sample eight data bits, one bit time apart
            for (i = 0; i < 8; i = i + 1) begin
                #(BIT_NS); b[i] = uart_tx;
            end
            // Wait to the middle of the stop bit, then store the byte
            #(BIT_NS);
            rxq[wr] = b; wr = wr + 1;
        end
    end

    // This task takes the next received byte from the queue, waiting for it if it has not arrived yet
    task recv_byte(output [7:0] b);
        begin
            // Wait until the receiver has stored something new
            wait (rd != wr);
            b = rxq[rd]; rd = rd + 1;
        end
    endtask

    // Working variables for the main sequence
    integer pos, len, k;
    reg [7:0] r, n;

    // Main sequence: reset, handshake, send each 64-byte block, print every reply byte as "OUT xx"
    initial begin
        // Load the input bytes
        $readmemh("sim/lzss-in.hex", input_bytes);
        // Hold reset for a while, then release the button
        #400; btn1 = 1'b1;
        // Give the firmware time to start and idle
        #200_000;
        // Reset the board's history: send 0, expect 0 back
        send_byte(8'h00); recv_byte(r);
        $display("ACK %02x", r);
        // Send the file in blocks of up to 64 bytes
        pos = 0;
        while (pos < NBYTES) begin
            // Block length
            len = (NBYTES - pos > 64) ? 64 : (NBYTES - pos);
            // A real PC needs at least tens of microseconds to answer; wait three bit times so the board has left its stop bit
            #(BIT_NS * 3.0);
            // Request: length then the raw bytes
            send_byte(len[7:0]);
            for (k = 0; k < len; k = k + 1) send_byte(input_bytes[pos + k]);
            // Reply: compressed length then that many bytes
            recv_byte(n);
            $display("OUT %02x", n);
            for (k = 0; k < n; k = k + 1) begin
                recv_byte(r);
                $display("OUT %02x", r);
            end
            pos = pos + len;
        end
        // Total simulated time for the whole exchange (UART transfer plus compression), for a throughput figure
        $display("TIME %0t ps for %0d input bytes", $time, NBYTES);
        $display("[tb] DONE");
        $finish;
    end

    // Watchdog: stop if the board never answers
    initial begin
        #500_000_000;
        $display("[tb] TIMEOUT");
        $finish;
    end
endmodule
