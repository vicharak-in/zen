// dspi-pio-echo-zen4-top.v - board top for dspi_pio_echo on the Zen 4: a Dual-SPI echo target on the RP2350 link wires (no Zen Link IP in this bitstream).
// Pads (all verified from the Zen Link pin set): spi_sck = GPIOL_09 (RP2350 GPIO28), spi_ss = GPIOL_10 (RP2350 GPIO29, bidirectional: the FPGA pulls it low to raise the alert),
// dual[0] = GPIOL_00 (RP2350 GPIO24), dual[1] = GPIOL_03 (RP2350 GPIO25). GPIO24/25 are contiguous, which the RP2350 PIO needs for its two data lines.
// Fabric clock 50 MHz (PLL x16 / 16). btn1 resets. LED 1 is the heartbeat (active low).

module dspi_pio_echo_zen4_top #(
    parameter ALERT_CLKS = 100_000_000,  // Quiet time before the alert, in clocks
    parameter BLINK_BIT  = 24            // Heartbeat bit
) (
    input  wire       clk,          // 50 MHz fabric clock from the PLL
    input  wire       btn1,         // Button 1, active low: reset
    input  wire       spi_sck,      // SCK from the RP2350 (GPIOL_09)
    input  wire       spi_ss_in,    // Chip select pad, input side (GPIOL_10)
    output wire       spi_ss_out,   // Chip select pad, output side
    output wire       spi_ss_oe,    // Chip select pad, output enable
    input  wire [1:0] dual_in,      // Data pads, input side (GPIOL_00, GPIOL_03)
    output wire [1:0] dual_out,     // Data pads, output side
    output wire [1:0] dual_oe,      // Data pads, output enable
    output wire       led1          // On-board LED 1, active low: heartbeat
);

    // Power-on reset counter: the design is held in reset for 255 clocks after configuration
    reg [7:0] por = 8'd0;
    // Two-flop synchroniser for the button (released = 1)
    reg [1:0] btn_sync = 2'b11;
    // Active-low reset: power-on counter running or button pressed
    wire rst_n = (por == 8'hFF) & btn_sync[1];
    // Heartbeat from the core, 1 = on
    wire led;

    // This block runs the power-on counter and the button synchroniser
    always @(posedge clk) begin
        if (por != 8'hFF) por <= por + 8'd1;  // Count until the end value, then stay
        btn_sync <= {btn_sync[0], btn1};      // Synchronise the button
    end

    // This contains the instantiation for the Dual-SPI echo core
    dspi_pio_echo #(.ALERT_CLKS(ALERT_CLKS), .BLINK_BIT(BLINK_BIT)) u_core (
        .clk(clk), .rst_n(rst_n), .spi_sck(spi_sck), .spi_ss_in(spi_ss_in), .spi_ss_out(spi_ss_out), .spi_ss_oe(spi_ss_oe),
        .dual_rx(dual_in), .dual_tx(dual_out), .dual_oe(dual_oe), .led(led));

    // LED 1 sinks current: a low pin lights it
    assign led1 = ~led;

endmodule
