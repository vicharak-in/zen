// This is the top module that wraps PicoRV32 (all features on) with a small BRAM and a GPIO register for the Zen board
// GPIO bit 0 = led1, bit 1 = led2 (fail), bit 2 = UART TX pin (bit-banged by the firmware)
`timescale 1 ns / 1 ps

module zen_picorv32_top #(
    // Number of 32-bit words in the on-chip memory (768 words = 3 KB, enough for the self-check firmware)
    parameter MEM_WORDS = 768,
    // 1 = full RV32I (32 registers), 0 = RV32E (16 registers; compile firmware with -march=rv32e)
    parameter REGS_16_31 = 1,
    // Hex file used to initialise the on-chip memory
    parameter FIRMWARE  = "firmware/riscv/firmware.hex",
    // 1 = barrel shifter (fast shifts, more logic), 0 = two-stage shifter (smaller)
    parameter BARREL    = 1,
    // 1 = interrupt logic (irq, timer, q registers) on, 0 = off (smaller, the self-test firmware does not use interrupts)
    parameter IRQ       = 1
) (
    // 25 MHz fabric clock from the PLL (Efinity Interface Designer)
    input  wire       clk,
    // Button 1, active low: press to reset the CPU
    input  wire       btn1,
    // LED 1, active low: lit when gpio bit 0 is 1
    output wire       led1,
    // LED 2, active low: lit when the CPU has trapped or the firmware sets gpio bit 1 (self-check failed)
    output wire       led2,
    // UART transmit pin (idles high), driven by gpio bit 2; connect to the RX pin of a USB-serial adapter
    output wire       uart_tx
);

    // Reset synchroniser: two flops so reset releases cleanly on clk
    reg [1:0] rst_sync = 2'b00;
    // Synchronised active-low reset used by the CPU
    wire resetn = rst_sync[1];

    // Reset synchroniser always block: shifts the external reset through two flops
    always @(posedge clk) begin
        // Shift in the button level (low while pressed)
        rst_sync <= {rst_sync[0], btn1};
    end

    // CPU trap flag from the core
    wire        trap;
    // CPU native memory interface: request valid
    wire        mem_valid;
    // CPU native memory interface: instruction fetch flag
    wire        mem_instr;
    // CPU native memory interface: ready back to CPU
    reg         mem_ready;
    // CPU native memory interface: byte address
    wire [31:0] mem_addr;
    // CPU native memory interface: write data
    wire [31:0] mem_wdata;
    // CPU native memory interface: byte write strobes
    wire [3:0]  mem_wstrb;
    // CPU native memory interface: read data
    reg  [31:0] mem_rdata;

    // This contains the instantiation for picorv32 (every optional feature enabled)
    picorv32 #(
        .ENABLE_COUNTERS     (1),
        .ENABLE_COUNTERS64   (1),
        .ENABLE_REGS_16_31   (REGS_16_31),
        .ENABLE_REGS_DUALPORT(1),
        .TWO_STAGE_SHIFT     (1),
        .BARREL_SHIFTER      (BARREL),
        .TWO_CYCLE_COMPARE   (0),
        .TWO_CYCLE_ALU       (0),
        .COMPRESSED_ISA      (1),
        .CATCH_MISALIGN      (1),
        .CATCH_ILLINSN       (1),
        .ENABLE_PCPI         (0),
        .ENABLE_MUL          (1),
        .ENABLE_FAST_MUL     (0),
        .ENABLE_DIV          (1),
        .ENABLE_IRQ          (IRQ),
        .ENABLE_IRQ_QREGS    (IRQ),
        .ENABLE_IRQ_TIMER    (IRQ),
        .ENABLE_TRACE        (0),
        .PROGADDR_RESET      (32'h0000_0000),
        .PROGADDR_IRQ        (32'h0000_0010),
        .STACKADDR           (MEM_WORDS * 4)
    ) u_cpu (
        .clk       (clk),
        .resetn    (resetn),
        .trap      (trap),
        .mem_valid (mem_valid),
        .mem_instr (mem_instr),
        .mem_ready (mem_ready),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (mem_rdata),
        .irq       (32'b0)
    );

    // On-chip memory array (inferred as block RAM)
    reg [31:0] mem [0:MEM_WORDS-1];
    // GPIO output register, written at address 0x1000_0000 (bit 2 starts high so the UART line idles high)
    reg [7:0]  gpio_reg = 8'h04;
    // LED 1 sinks current, so a 1 in gpio bit 0 turns it on with a low pin
    assign led1 = ~gpio_reg[0];
    // LED 2 sinks current, so a trap or a firmware-reported failure turns it on with a low pin
    assign led2 = ~(trap | gpio_reg[1]);
    // The UART TX pin follows gpio bit 2
    assign uart_tx = gpio_reg[2];

    // Address decode: high when the access targets on-chip memory
    wire sel_mem  = mem_valid && (mem_addr < MEM_WORDS * 4);
    // Address decode: high when the access targets the GPIO register
    wire sel_gpio = mem_valid && (mem_addr == 32'h1000_0000);

    // Memory initialisation block: loads the firmware hex into the array at start
    initial begin
        // Load the firmware image into memory
        $readmemh(FIRMWARE, mem);
    end

    // Memory and GPIO access block: synchronous read and byte-wise write, ready one cycle after valid
    always @(posedge clk) begin
        // Default: ready is a single-cycle pulse
        mem_ready <= 1'b0;
        // Start a new transfer only when the CPU requests and we have not just answered
        if (mem_valid && !mem_ready) begin
            // Answer on the next cycle
            mem_ready <= 1'b1;
            // Handle on-chip memory accesses
            if (sel_mem) begin
                // Synchronous read of the addressed word
                mem_rdata <= mem[mem_addr[31:2]];
                // Write byte 0 if strobe set
                if (mem_wstrb[0]) mem[mem_addr[31:2]][ 7: 0] <= mem_wdata[ 7: 0];
                // Write byte 1 if strobe set
                if (mem_wstrb[1]) mem[mem_addr[31:2]][15: 8] <= mem_wdata[15: 8];
                // Write byte 2 if strobe set
                if (mem_wstrb[2]) mem[mem_addr[31:2]][23:16] <= mem_wdata[23:16];
                // Write byte 3 if strobe set
                if (mem_wstrb[3]) mem[mem_addr[31:2]][31:24] <= mem_wdata[31:24];
            end
            // Handle GPIO accesses
            else if (sel_gpio) begin
                // Reading GPIO returns the register zero-extended
                mem_rdata <= {24'b0, gpio_reg};
                // Update the low byte when written
                if (mem_wstrb[0]) gpio_reg <= mem_wdata[7:0];
            end
            // Unmapped addresses return zero
            else begin
                // Return zero for anything else
                mem_rdata <= 32'h0;
            end
        end
    end

endmodule
