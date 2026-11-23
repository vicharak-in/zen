// This is the top module of the hardware compressor for the Zen 4 board: UART in, LZSS core, UART out. It has the same ports as zen_picorv32_top, so it fits the same pin file.
`timescale 1 ns / 1 ps

module lzss_hw_top #(
    // Clock cycles per UART bit at power-up and after a reset or idle timeout (25 MHz / 115200 = 217)
    parameter CPB      = 217,
    // Width of the idle timeout counter (2**IDLE_BITS clocks of silence return the link to the default baud rate: 25 bits = 1.3 s at 25 MHz)
    parameter IDLE_BITS = 25,
    // Width of the power-on delay counter (the core is held in reset for 2**POR_BITS clocks after configuration)
    parameter POR_BITS = 17
) (
    // 25 MHz fabric clock from the PLL
    input  wire clk,
    // Button 1, active low: press to reset
    input  wire btn1,
    // LED 1, active low: lit while the core is idle and ready
    output wire led1,
    // LED 2, active low: always off
    output wire led2,
    // UART transmit pin (idles high)
    output wire uart_tx,
    // UART receive pin (idles high)
    input  wire uart_rx
);

    // Power-on delay counter
    reg [POR_BITS-1:0] por_cnt = {POR_BITS{1'b0}};
    // High once the power-on delay is over
    wire por_done = &por_cnt;
    // Reset synchroniser: two flops
    reg [1:0] rst_sync = 2'b00;
    // Synchronised active-low reset: released when the button is up and the power-on delay is over
    wire rst_n = rst_sync[1] & por_done;
    // Two-flop synchroniser for the asynchronous UART input
    reg [1:0] rx_sync = 2'b11;

    // Housekeeping always block: power-on counter, reset synchroniser, input synchroniser
    always @(posedge clk) begin
        // Count until the delay is over
        if (!por_done) por_cnt <= por_cnt + 1'b1;
        // Shift the button level through two flops
        rst_sync <= {rst_sync[0], btn1};
        // Shift the receive pin through two flops
        rx_sync <= {rx_sync[0], uart_rx};
    end

    // The UART receiver has a new byte
    wire       u_valid;
    // The byte from the UART receiver
    wire [7:0] u_data;
    // The FIFO has a byte for the core
    wire       f_valid;
    // The byte at the head of the FIFO
    wire [7:0] f_data;
    // The core is waiting for a byte
    wire       rx_want;
    // A byte is handed to the core this clock
    wire       rx_valid = f_valid & rx_want;
    // The byte handed to the core
    wire [7:0] rx_data = f_data;
    // The core has a byte for the host
    wire       tx_valid;
    // The byte for the host
    wire [7:0] tx_data;
    // The transmitter can take a byte
    wire       tx_ready;
    // The core is working
    wire       busy;
    // Clock cycles per UART bit currently in use (the host can change it with the 0x7E command)
    wire [7:0] cpb;

    // This contains the instantiation for the UART receiver
    uart_rx u_rx (.clk(clk), .cpb(cpb), .rst_n(rst_n), .rx(rx_sync[1]), .valid(u_valid), .data(u_data));
    // This contains the instantiation for the receive FIFO
    rx_fifo u_fifo (.clk(clk), .rst_n(rst_n), .push(u_valid), .din(u_data), .pop(rx_valid), .valid(f_valid), .dout(f_data));
    // This contains the instantiation for the UART transmitter
    uart_tx u_tx (.clk(clk), .cpb(cpb), .rst_n(rst_n), .valid(tx_valid), .data(tx_data), .ready(tx_ready), .tx(uart_tx));
    // This contains the instantiation for the LZSS core
    lzss_core #(.CPB_DEFAULT(CPB), .IDLE_BITS(IDLE_BITS)) u_core (.clk(clk), .cpb(cpb), .rst_n(rst_n), .rx_valid(rx_valid), .rx_data(rx_data), .rx_want(rx_want), .tx_valid(tx_valid), .tx_data(tx_data), .tx_ready(tx_ready), .busy(busy));

    // LED 1 is lit (pin low) while idle, LED 2 stays off
    assign led1 = busy;
    assign led2 = 1'b1;

endmodule
