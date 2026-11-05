// picorv32-lzss-zen4-top.v - board top on the Vicharak Zen 4: the RP2350 reaches the unchanged zen_picorv32_top (PicoRV32 soft CPU, LZSS compressor firmware) over the Zen Link.
// The CPU talks UART by bit-banging a gpio pin. The bridge below turns Zen Link register accesses into that pin's serial line (and back), so the byte protocol of the firmware is exactly the same.
// Two clocks from the PLL: clk is 50 MHz (Zen Link, bridge registers) and clk_core is 25 MHz (the CPU and its UART timing, as before). They meet only in the bridge's dual-clock FIFOs.

module picorv32_lzss_zen4_top #(
    // Number of 32-bit words in the on-chip memory (768 words = 3 KB)
    parameter MEM_WORDS = 768,
    // 1 = full RV32I (32 registers), 0 = RV32E (16 registers)
    parameter REGS_16_31 = 1,
    // Hex file used to initialise the on-chip memory
    parameter FIRMWARE  = "firmware/riscv/firmware.hex",
    // Width of the CPU's power-on delay counter (shrink it in simulation)
    parameter POR_BITS  = 17
) (
    input  wire       clk,          // 50 MHz clock from the PLL (Zen Link)
    input  wire       clk_core,     // 25 MHz clock from the PLL (CPU)
    input  wire       btn1,         // Button 1, active low: press to reset the CPU
    input  wire       link_clk_in,  // Zen Link CLK from the RP2350 (GPIO28)
    input  wire       link_csn_in,  // Zen Link CS_N from the RP2350 (GPIO29)
    input  wire [7:0] link_d_in,    // Zen Link data pins, input side
    output wire [7:0] link_d_out,   // Zen Link data pins, output side
    output wire [7:0] link_d_oe,    // Zen Link data pins, output enable
    output wire       led1,         // LED 1, active low: from the CPU
    output wire       led2          // LED 2, active low: from the CPU (trap or failure)
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
    // Software reset (CTRL0 bit 0) brought into the CPU clock domain
    reg [1:0] sw_c = 2'b00;
    // Reset of the Zen Link side: active while the power-on counter is running
    wire rst_l = (por_l != 8'hFF);
    // Reset of the bridge on the CPU clock: active while its power-on counter is running
    wire rst_c = (por_c != 8'hFF);
    // Button level handed to the CPU: low while the button or the software reset is active, or the CPU clock has not been running long enough
    wire core_btn = btn1 & ~sw_c[1] & ~rst_c;
    // Serial lines between the bridge and the CPU (idle high)
    wire rx_line, tx_line;

    // This block makes the power-on reset of the Zen Link side and adds the button and the software reset as manual resets
    always @(posedge clk) begin
        bsync_l <= {bsync_l[0], btn1};                       // Synchronise the button
        if (!bsync_l[1] || ctrl_flat[0]) por_l <= 8'd0;      // Button or software reset: restart the reset counter
        else if (por_l != 8'hFF) por_l <= por_l + 8'd1;      // Otherwise count up until full
    end

    // This block makes the power-on reset of the bridge's CPU side and adds the button and the software reset as manual resets
    always @(posedge clk_core) begin
        bsync_c <= {bsync_c[0], btn1};                       // Synchronise the button
        sw_c    <= {sw_c[0], ctrl_flat[0]};                  // Synchronise the software reset
        if (!bsync_c[1] || sw_c[1]) por_c <= 8'd0;           // Button or software reset: restart the reset counter
        else if (por_c != 8'hFF) por_c <= por_c + 8'd1;      // Otherwise count up until full
    end

    // This contains the instantiation for the Zen Link
    zen_link #(.NCTRL(4), .NSTAT(4)) u_link (
        .clk(clk), .rst_n(1'b1), .link_clk_in(link_clk_in), .link_csn_in(link_csn_in),
        .link_d_in(link_d_in), .link_d_out(link_d_out), .link_d_oe(link_d_oe),
        .ctrl_flat(ctrl_flat), .stat_flat(32'd0),
        .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata));

    // This contains the instantiation for the Zen Link to UART bridge (217 clocks per bit at 25 MHz = 115200 baud, the rate the firmware's bit-banging is timed for)
    zl_uart_bridge #(.BASE(16'h0100), .CPB_DEFAULT(16'd217), .AW(7), .AW_RX(8), .FIXED_BAUD(1), .LITE(1)) u_bridge (
        .clk(clk), .rst_n(~rst_l), .usr_addr(usr_addr), .usr_wr(usr_wr), .usr_wdata(usr_wdata), .usr_rd(usr_rd), .usr_rdata(usr_rdata),
        .core_clk(clk_core), .core_rst_n(~rst_c), .line_to_core(rx_line), .line_from_core(tx_line));

    // This contains the instantiation for the PicoRV32 system (unchanged), whose gpio UART pins are wired to the bridge
    zen_picorv32_top #(
        .MEM_WORDS (MEM_WORDS),
        .REGS_16_31(REGS_16_31),
        .BARREL(0),
        .IRQ(0),
        .MUL(0),
        .DIV(0),
        .FIRMWARE  (FIRMWARE),
        .POR_BITS  (POR_BITS)
    ) u_cpu (
        .clk(clk_core), .btn1(core_btn), .led1(led1), .led2(led2), .uart_tx(tx_line), .uart_rx(rx_line));

endmodule
