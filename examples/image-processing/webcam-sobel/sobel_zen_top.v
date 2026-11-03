// sobel_zen_top.v - board top for the UART Sobel filter on the Vicharak Zen 4 (Trion T4F81).
// The host PC talks to the FPGA through the RP2350 (USB serial bridge) over the internal UART1 link, no wires:
//   uart_rx = GPIOL_00 (RP2350 GPIO24 TX), uart_tx = GPIOL_03 (RP2350 GPIO25 RX), 921600 baud (CLKS_PER_BIT = 27 at 25 MHz; 12 = 2.083 Mbaud, 8 = 3.125 Mbaud); the picture size is set per frame by the host.
// Fabric clock: 50 MHz oscillator on GPIOL_20 -> PLL x16 / 32 = 25 MHz.
//   led1 = a frame was completed (stretched), led2 = bytes are arriving (stretched), both active low.
//   btn1 resets the design (active low).
`default_nettype none

module sobel_zen_top (
    input  wire clk,        // 25 MHz fabric clock from the PLL
    input  wire btn1,       // Button 1, active low: reset the design
    input  wire uart_rx,    // UART from the RP2350 (GPIO24 TX)
    output wire uart_tx,    // UART to the RP2350 (GPIO25 RX)
    output wire led1,       // LED 1, active low: a frame was completed
    output wire led2        // LED 2, active low: bytes are arriving
);

    // Power-on reset counter: holds the design in reset for 255 clocks after configuration
    reg  [7:0]  por = 8'd0;
    // Two-flop synchroniser for the button (pressed = 0)
    reg  [1:0]  btn_sync = 2'b11;
    // Active-high reset: power-on counter running or button pressed
    wire        rst = (por != 8'hFF) | ~btn_sync[1];
    // One-clock pulse when a frame completes
    wire        frame_done;
    // One-clock pulse when a byte is received
    wire        rx_seen;
    // Stretch counter for the frame LED
    reg  [22:0] done_cnt = 23'd0;
    // Stretch counter for the receive LED
    reg  [22:0] rx_cnt   = 23'd0;

    // This block runs the power-on counter and the button synchroniser
    always @(posedge clk) begin
        if (por != 8'hFF) por <= por + 8'd1;       // Count until the end value, then stay
        btn_sync <= {btn_sync[0], btn1};           // Button is active low
    end

    // This block stretches the pulses so the LEDs are visible
    always @(posedge clk) begin
        if (frame_done) done_cnt <= {23{1'b1}};            // Reload on a frame-done pulse
        else if (done_cnt != 0) done_cnt <= done_cnt - 23'd1;  // Count down while lit
        if (rx_seen) rx_cnt <= {23{1'b1}};                 // Reload on a received byte
        else if (rx_cnt != 0) rx_cnt <= rx_cnt - 23'd1;    // Count down while lit
    end

    // LED 1 sinks current while the stretch counter runs
    assign led1 = ~(done_cnt != 0);
    // LED 2 sinks current while the stretch counter runs
    assign led2 = ~(rx_cnt != 0);

    // This contains the instantiation for sobel_uart_top
    sobel_uart_top #(.MAXW(640), .CLKS_PER_BIT(27), .TIMEOUT(2500000)) u_sobel (
        .clk        (clk),
        .rst        (rst),
        .rx         (uart_rx),
        .tx         (uart_tx),
        .frame_done (frame_done),
        .rx_seen    (rx_seen)
    );

endmodule

`default_nettype wire
