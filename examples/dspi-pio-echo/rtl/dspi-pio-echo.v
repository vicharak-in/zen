// dspi-pio-echo.v - Dual-SPI echo target with a heartbeat LED and an asynchronous alert.
// The MCU (a PIO state machine) sends a byte on two data lines, the FPGA echoes it back on the same two lines. When the MCU has been quiet for ALERT_CLKS clocks the FPGA
// pulls the shared chip-select line low (open drain through spi_ss_oe) to ask for attention; any SCK activity or a received byte cancels the alert.
// Ported from the Shrike example (module "top"): the Forge pad attributes and enable ports are gone, the fixed 100_000_000 and bit 24 became parameters (same defaults),
// the reset comes from the board top, and the raw SCK level used to cancel the alert goes through a 2-flop synchroniser first.

module dspi_pio_echo #(
    parameter ALERT_CLKS = 100_000_000,  // Quiet time before the alert, in clocks (2 s at 50 MHz)
    parameter BLINK_BIT  = 24            // Heartbeat LED = this bit of a free-running counter
) (
    input  wire       clk,          // Fabric clock
    input  wire       rst_n,        // Reset, active low
    input  wire       spi_sck,      // SCK from the MCU
    input  wire       spi_ss_in,    // Chip select as read from the pad
    output wire       spi_ss_out,   // Chip select value to drive (always 0)
    output wire       spi_ss_oe,    // Pull chip select low (alert)
    input  wire [1:0] dual_rx,      // Data pads, input side
    output wire [1:0] dual_tx,      // Data pads, output side
    output wire [1:0] dual_oe,      // Data pads, output enable
    output reg        led = 1'b0    // Heartbeat
);

    // Alert state
    reg fpga_wants_to_talk = 1'b0;
    assign spi_ss_out = 1'b0;
    assign spi_ss_oe  = fpga_wants_to_talk;

    // Echo path: byte received, byte returned
    wire [7:0] rx_data_wire;
    wire       rx_valid_pulse;
    reg  [7:0] tx_data_reg;

    // The reply is the alert code while an alert is pending, otherwise the echo of the byte just received
    always @(*) begin
        if (fpga_wants_to_talk) tx_data_reg = 8'hFF;
        else tx_data_reg = rx_data_wire;
    end

    // Timers
    reg [31:0] timer = 32'd0;
    reg [24:0] blink_timer = 25'd0;
    // SCK through a synchroniser, for the alert cancel
    reg [1:0] sck_s = 2'b00;

    // This block runs the heartbeat and the alert timer
    always @(posedge clk) begin
        sck_s <= {sck_s[0], spi_sck};
        blink_timer <= blink_timer + 25'd1;
        led <= blink_timer[BLINK_BIT];

        if (!rst_n) begin
            fpga_wants_to_talk <= 1'b0;
            timer <= 32'd0;
        end else if (rx_valid_pulse || sck_s[1]) begin
            fpga_wants_to_talk <= 1'b0;
            timer <= 32'd0;
        end else begin
            if (timer == ALERT_CLKS) fpga_wants_to_talk <= 1'b1;
            else timer <= timer + 32'd1;
        end
    end

    // This contains the instantiation for the Dual-SPI target
    dual_spi_target u_target (
        .i_clk(clk), .i_rst_n(rst_n), .i_ss_n(spi_ss_in), .i_sck(spi_sck),
        .i_dual_rx(dual_rx), .o_dual_tx(dual_tx), .o_dual_oe(dual_oe),
        .o_rx_data(rx_data_wire), .o_rx_data_valid(rx_valid_pulse), .i_tx_data(tx_data_reg));

endmodule
