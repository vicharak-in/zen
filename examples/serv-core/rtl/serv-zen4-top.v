// serv-zen4-top.v - board top on the Vicharak Zen 4: the RP2350 reads the report of the unchanged SERV system (servxzen_soc: SERV core, 4 KB RAM, GPIO, UART TX, self-test firmware) over the Zen Link.
// The SoC sends its report on a UART TX line. The bridge below turns that line into bytes the RP2350 reads through Zen Link register accesses, so the firmware and its report are exactly the same as before.
// Two clocks from the PLL: clk is 50 MHz (Zen Link, bridge registers) and clk_core is 25 MHz (SERV and its UART timing, as before). They meet only in the bridge's dual-clock FIFOs.

module serv_zen4_top #(
    // RAM size in bytes (power of two); the firmware image, .bss and the stack must fit
    parameter MEMSIZE    = 4096,
    // 1 = SERV (bit-serial), 4 = QERV (4-bit datapath)
    parameter WIDTH      = 1,
    // 1 = enable the C extension (firmware must then be built with rv32ic)
    parameter COMPRESSED = 0,
    // Hex file used to initialise the on-chip memory (relative to the Efinity project folder)
    parameter FIRMWARE   = "firmware/riscv/firmware.hex"
) (
    input  wire       clk,          // 50 MHz clock from the PLL (Zen Link)
    input  wire       clk_core,     // 25 MHz clock from the PLL (SERV)
    input  wire       btn1,         // Button 1, active low: press to reset SERV
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    output wire       led1,         // LED 1, active low: lit when the self-test passed (gpio bit 0)
    output wire       led2          // LED 2, active low: lit when a test failed (gpio bit 1)
);

    // Power-on reset counters, one per clock: each counts up to 255 and the logic of that clock is held in reset until it is full
    reg [7:0] por_l = 8'd0, por_c = 8'd0;
    // Two flip-flops per clock that bring the asynchronous button into the clock domain (reset value 1 = not pressed)
    reg [1:0] bsync_l = 2'b11, bsync_c = 2'b11;
    // Zen Link control registers: CTRL0 (address 0x10) bit 0 is a software reset the RP2350 can pulse
    wire [31:0] ctrl_flat;
    // Zen Link user bus
    wire [15:0] usr_addr;
    wire usr_wr, usr_rd;
    wire [7:0] usr_wdata, usr_rdata;
    // Software reset (CTRL0 bit 0) brought into the SERV clock domain
    reg [1:0] sw_c = 2'b00;
    // Reset of the Zen Link side: active while the power-on counter is running
    wire rst_l = (por_l != 8'hFF);
    // Reset of the SERV side: active while its power-on counter is running, while the button is pressed or while the software reset is set
    wire rst_c = (por_c != 8'hFF) | ~bsync_c[1] | sw_c[1];
    // GPIO register from the SoC
    wire [7:0] gpio;
    // Serial line from the SoC to the bridge (idle high), and the unused line the other way (the SoC has no UART receiver)
    wire tx_line, rx_line;

    // This block makes the power-on reset of the Zen Link side and adds the button and the software reset as manual resets
    always @(posedge clk) begin
        bsync_l <= {bsync_l[0], btn1};                       // Synchronise the button
        if (!bsync_l[1] || ctrl_flat[0]) por_l <= 8'd0;      // Button or software reset: restart the reset counter
        else if (por_l != 8'hFF) por_l <= por_l + 8'd1;      // Otherwise count up until full
    end

    // This block makes the power-on reset of the SERV side and adds the button and the software reset as manual resets
    always @(posedge clk_core) begin
        bsync_c <= {bsync_c[0], btn1};                       // Synchronise the button
        sw_c    <= {sw_c[0], ctrl_flat[0]};                  // Synchronise the software reset
        if (!bsync_c[1] || sw_c[1]) por_c <= 8'd0;           // Button or software reset: restart the reset counter
        else if (por_c != 8'hFF) por_c <= por_c + 8'd1;      // Otherwise count up until full
    end

    // LED 1 sinks current, so a 1 in gpio bit 0 turns it on with a low pin
    assign led1 = ~gpio[0];
    // LED 2 sinks current, so a 1 in gpio bit 1 turns it on with a low pin
    assign led2 = ~gpio[1];

    // This contains the instantiation for the Zen Link
    zen_link #(.NCTRL(4), .NSTAT(4)) u_link (
        .clk(clk), .rst_n(1'b1), .link_clk_in(link_clk_in), .link_csn_in(link_csn_in),
        .link_d_in(link_d_in), .link_d_out(link_d_out), .link_d_oe(link_d_oe),
        .ctrl_flat(ctrl_flat), .stat_flat(32'd0),
        .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata));

    // This contains the instantiation for the Zen Link to UART bridge (217 clocks per bit at 25 MHz = 115200 baud, the rate of the SoC's UART)
    zl_uart_bridge #(.BASE(16'h0100), .CPB_DEFAULT(16'd217), .AW(7), .AW_RX(9), .FIXED_BAUD(1), .LITE(1)) u_bridge (
        .clk(clk), .rst_n(~rst_l), .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .core_clk(clk_core), .core_rst_n(~rst_c), .line_to_core(rx_line), .line_from_core(tx_line));

    // This contains the instantiation for servxzen_soc (unchanged), whose UART transmit line is wired to the bridge
    servxzen_soc #(
        .MEMFILE    (FIRMWARE),
        .MEMSIZE    (MEMSIZE),
        .WIDTH      (WIDTH),
        .COMPRESSED (COMPRESSED),
        .SIM        (0),
        .CLK_HZ     (25000000),
        .BAUD       (115200)
    ) u_soc (
        .i_clk     (clk_core),
        .i_rst     (rst_c),
        .o_gpio    (gpio),
        .o_uart_tx (tx_line)
    );

endmodule
