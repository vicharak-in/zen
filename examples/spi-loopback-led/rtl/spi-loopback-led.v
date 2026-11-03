// spi-loopback-led.v - SPI loopback with an LED: every byte received is sent back on the next transfer, 0xAB switches the LED on and 0xFF switches it off.
// Ported from the Shrike example. The spi_target and the pad ports are gone: the core now has the plain byte interface of the Zen Link byte port
// (rx_data / rx_valid in, tx_data out), the logic is unchanged.

module spi_loopback_led (
    input  wire       clk,       // Fabric clock
    input  wire       rst_n,     // Reset, active low
    input  wire [7:0] rx_data,   // Byte received from the master
    input  wire       rx_valid,  // One clock when rx_data is new
    output reg  [7:0] tx_data,   // Byte returned to the master on the next transfer
    output reg        led        // LED state, 1 = on
);

    // This block remembers the last byte received so it can be echoed back
    always @(posedge clk) begin
        if (!rst_n) tx_data <= 8'h00;
        else if (rx_valid) tx_data <= rx_data;
    end

    // This block sets and clears the LED
    always @(posedge clk) begin
        if (!rst_n) begin
            led <= 1'b0;
        end else if (rx_valid) begin
            if (rx_data == 8'hAB) led <= 1'b1;
            else if (rx_data == 8'hFF) led <= 1'b0;
        end
    end

endmodule
