// Generic SERV SoC for SERVxZen: SERV (via the upstream "servile" wrapper), RAM, register-file RAM, GPIO, UART TX, cycle counter, timer
// Board-independent: a board top (serv-zen4-top.v) only supplies the clock, reset, pins and the firmware file
//
// Memory map (CPU view)
//   0x0000_0000 ..  RAM (MEMSIZE bytes, firmware is preloaded)
//   0x4000_0000  GPIO output register (bit 0 = pass LED, bit 1 = fail LED), read/write
//   0x4000_0004  UART: write = send low byte, read bit 0 = busy
//   0x4000_0008  Free-running 32-bit clock-cycle counter (read only)
//   0x8000_0000  Timer: read = mtime, write = mtimecmp (timer interrupt, MTIP)
//   0x9000_0000  Simulation only (SIM=1): any write ends the simulation
`default_nettype none

module servxzen_soc #(
    // Firmware image, one 32-bit hex word per line, loaded with $readmemh
    parameter MEMFILE      = "",
    // RAM size in bytes (power of two)
    parameter MEMSIZE      = 4096,
    // SERV datapath width: 1 = SERV (bit-serial), 4 = QERV (4-bit)
    parameter WIDTH        = 1,
    // 1 = enable the C (compressed) extension in the core
    parameter COMPRESSED   = 0,
    // 1 = enable the simulation halt address 0x9000_0000
    parameter SIM          = 0,
    // System clock in Hz, used for the UART divider
    parameter CLK_HZ       = 25000000,
    // UART baud rate
    parameter BAUD         = 115200,
    // SERV reset strategy: "MINI" resets only what is needed; "NONE" has no reset at all
    parameter RESET_STRATEGY = "MINI"
) (
    // System clock
    input  wire       i_clk,
    // Synchronous active-high reset
    input  wire       i_rst,
    // GPIO output register (bit 0 = pass, bit 1 = fail)
    output wire [7:0] o_gpio,
    // UART transmit, idles high
    output wire       o_uart_tx
);

    // Registers are 32 plus 4 CSR registers, stored 2*WIDTH bits wide in a small RAM
    localparam CSR_REGS = 4;
    // Width of the register-file RAM word
    localparam RF_WIDTH = WIDTH * 2;
    // Address width of the register-file RAM
    localparam RF_L2D   = $clog2((32 + CSR_REGS) * 32 / RF_WIDTH);

    // Timer interrupt from the timer to the core
    wire        timer_irq;

    // Memory bus from the core
    wire [31:0] wb_mem_adr;
    // Memory write data
    wire [31:0] wb_mem_dat;
    // Memory byte selects
    wire [3:0]  wb_mem_sel;
    // Memory write enable
    wire        wb_mem_we;
    // Memory request
    wire        wb_mem_stb;
    // Memory read data
    wire [31:0] wb_mem_rdt;
    // Memory acknowledge
    wire        wb_mem_ack;

    // Extension (peripheral) bus from the core
    wire [31:0] wb_ext_adr;
    // Peripheral write data
    wire [31:0] wb_ext_dat;
    // Peripheral byte selects (unused, peripherals are word wide)
    wire [3:0]  wb_ext_sel;
    // Peripheral write enable
    wire        wb_ext_we;
    // Peripheral request
    wire        wb_ext_stb;
    // Peripheral read data
    reg  [31:0] wb_ext_rdt;
    // Peripheral acknowledge
    reg         wb_ext_ack;

    // Register-file RAM write address
    wire [RF_L2D-1:0]   rf_waddr;
    // Register-file RAM write data
    wire [RF_WIDTH-1:0] rf_wdata;
    // Register-file RAM write enable
    wire                rf_wen;
    // Register-file RAM read address
    wire [RF_L2D-1:0]   rf_raddr;
    // Register-file RAM read enable
    wire                rf_ren;
    // Register-file RAM read data
    wire [RF_WIDTH-1:0] rf_rdata;

    // Peripheral select: address bits 31:30 = 01 means the I/O block, 10 means the timer
    wire sel_io    = (wb_ext_adr[31:30] == 2'b01);
    // Timer select
    wire sel_timer = (wb_ext_adr[31:30] == 2'b10);
    // Word index inside the I/O block (bits 3:2)
    wire [1:0] io_reg = wb_ext_adr[3:2];

    // GPIO output register: bit 0 pass LED, bit 1 fail LED
    reg [7:0]  gpio_reg = 8'h00;
    // Free-running clock-cycle counter
    reg [31:0] cycle_cnt = 32'd0;
    // UART busy flag from the transmitter
    wire       uart_busy;
    // Timer read data
    wire [31:0] timer_rdt;

    // UART start pulse: a write to the UART register while idle
    wire uart_start = wb_ext_stb & wb_ext_we & sel_io & (io_reg == 2'd1) & ~wb_ext_ack;
    // GPIO write pulse
    wire gpio_write = wb_ext_stb & wb_ext_we & sel_io & (io_reg == 2'd0) & ~wb_ext_ack;
    // Timer write pulse (sets mtimecmp)
    wire timer_cyc  = wb_ext_stb & sel_timer & ~wb_ext_ack;

    // Peripheral register block: GPIO register, cycle counter and bus acknowledge
    always @(posedge i_clk) begin
        // Count every clock
        cycle_cnt <= cycle_cnt + 32'd1;
        // Acknowledge one clock after a request, as upstream servant does
        wb_ext_ack <= wb_ext_stb & ~wb_ext_ack;
        // Update the GPIO register on a write
        if (gpio_write) gpio_reg <= wb_ext_dat[7:0];
        // Reset block: clears the acknowledge, GPIO register and counter
        if (i_rst) begin
            // No acknowledge during reset
            wb_ext_ack <= 1'b0;
            // LEDs off
            gpio_reg   <= 8'h00;
            // Counter restarts
            cycle_cnt  <= 32'd0;
        end
    end

    // Read data mux block: chooses the register the CPU is reading
    always @* begin
        // Default: reads of unused addresses return zero
        wb_ext_rdt = 32'd0;
        // Timer region
        if (sel_timer) wb_ext_rdt = timer_rdt;
        // I/O region: pick by word index
        else if (sel_io) begin
            // Word index decode
            case (io_reg)
                // GPIO register
                2'd0: wb_ext_rdt = {24'd0, gpio_reg};
                // UART status: bit 0 = busy
                2'd1: wb_ext_rdt = {31'd0, uart_busy};
                // Cycle counter
                2'd2: wb_ext_rdt = cycle_cnt;
                // Reserved
                default: wb_ext_rdt = 32'd0;
            endcase
        end
    end

    // Drive the pins from the registers
    assign o_gpio = gpio_reg;

    // This contains the instantiation for servxzen_uart_tx
    servxzen_uart_tx #(
        .CLKS_PER_BIT (CLK_HZ / BAUD)
    ) u_uart (
        .i_clk   (i_clk),
        .i_rst   (i_rst),
        .i_start (uart_start),
        .i_data  (wb_ext_dat[7:0]),
        .o_busy  (uart_busy),
        .o_tx    (o_uart_tx)
    );

    // This contains the instantiation for servant_timer (upstream timer, 32-bit mtime/mtimecmp)
    servant_timer #(
        .RESET_STRATEGY (RESET_STRATEGY),
        .WIDTH          (32)
    ) u_timer (
        .i_clk    (i_clk),
        .i_rst    (i_rst),
        .o_irq    (timer_irq),
        .i_wb_cyc (timer_cyc),
        .i_wb_we  (wb_ext_we),
        .i_wb_dat (wb_ext_dat),
        .o_wb_dat (timer_rdt)
    );

    // This contains the instantiation for servant_ram (firmware RAM, preloaded from MEMFILE)
    servant_ram #(
        .memfile        (MEMFILE),
        .depth          (MEMSIZE),
        .RESET_STRATEGY (RESET_STRATEGY)
    ) u_ram (
        .i_wb_clk (i_clk),
        .i_wb_rst (i_rst),
        .i_wb_adr (wb_mem_adr[$clog2(MEMSIZE)-1:2]),
        .i_wb_cyc (wb_mem_stb),
        .i_wb_we  (wb_mem_we),
        .i_wb_sel (wb_mem_sel),
        .i_wb_dat (wb_mem_dat),
        .o_wb_rdt (wb_mem_rdt),
        .o_wb_ack (wb_mem_ack)
    );

    // This contains the instantiation for serv_rf_ram (register-file storage for SERV)
    serv_rf_ram #(
        .width    (RF_WIDTH),
        .csr_regs (CSR_REGS)
    ) u_rf_ram (
        .i_clk   (i_clk),
        .i_waddr (rf_waddr),
        .i_wdata (rf_wdata),
        .i_wen   (rf_wen),
        .i_raddr (rf_raddr),
        .i_ren   (rf_ren),
        .o_rdata (rf_rdata)
    );

    // This contains the instantiation for servile (SERV core plus bus mux, arbiter and register-file interface)
    servile #(
        .width          (WIDTH),
        .reset_strategy (RESET_STRATEGY),
        .sim            (SIM[0]),
        .debug          (1'b0),
        .with_c         (COMPRESSED[0]),
        .with_csr       (1'b1),
        .with_mdu       (1'b0)
    ) u_cpu (
        .i_clk        (i_clk),
        .i_rst        (i_rst),
        .i_timer_irq  (timer_irq),
        .o_wb_mem_adr (wb_mem_adr),
        .o_wb_mem_dat (wb_mem_dat),
        .o_wb_mem_sel (wb_mem_sel),
        .o_wb_mem_we  (wb_mem_we),
        .o_wb_mem_stb (wb_mem_stb),
        .i_wb_mem_rdt (wb_mem_rdt),
        .i_wb_mem_ack (wb_mem_ack),
        .o_wb_ext_adr (wb_ext_adr),
        .o_wb_ext_dat (wb_ext_dat),
        .o_wb_ext_sel (wb_ext_sel),
        .o_wb_ext_we  (wb_ext_we),
        .o_wb_ext_stb (wb_ext_stb),
        .i_wb_ext_rdt (wb_ext_rdt),
        .i_wb_ext_ack (wb_ext_ack),
        .o_rf_waddr   (rf_waddr),
        .o_rf_wdata   (rf_wdata),
        .o_rf_wen     (rf_wen),
        .o_rf_raddr   (rf_raddr),
        .o_rf_ren     (rf_ren),
        .i_rf_rdata   (rf_rdata)
    );

endmodule
