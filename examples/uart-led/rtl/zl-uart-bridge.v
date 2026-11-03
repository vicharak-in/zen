// zl-uart-bridge.v - Zen Link to UART adapter: the RP2350 reads and writes bytes over the Zen Link, and this block turns them into the UART lines of an unchanged core.
// line_to_core is the serial line the core receives on (idles high), line_from_core is the serial line the core transmits on.
// The Zen Link side runs on clk (50 MHz); the UART side runs on core_clk, which may be a different, slower clock (the core's own clock). The two are joined by dual-clock FIFOs.
//
// Registers on the Zen Link user bus (BASE = 0x100):
//   BASE+0  DATA     write: queue one byte towards the core;  read: take one byte from the core (0 when none)
//   BASE+1  STATUS   read: bit0 = bytes from the core waiting, bit1 = room to queue a byte, bit2 = write overflow (sticky),
//                    bit3 = receive overflow (sticky), bit4 = idle (nothing queued and the line is quiet).  write: clears the sticky bits
//   BASE+2  RXCNT    read: bytes from the core waiting (max 255)
//   BASE+3  TXFREE   read: free room for bytes towards the core (max 255)
//   BASE+4  CPB_LO   read / write: clocks per UART bit on core_clk, low byte
//   BASE+5  CPB_HI   read / write: clocks per UART bit, high byte (change only while idle)
//   BASE+0x80 .. BASE+0xFF   window: every address behaves like DATA, so a burst of up to 128 bytes moves in one frame
// 8N1 frames. The receiver drops a byte whose stop bit is low.

module zl_uart_bridge #(
    parameter [15:0] BASE        = 16'h0100,  // First register address on the user bus
    parameter [15:0] CPB_DEFAULT = 16'd434,   // Clocks per UART bit on core_clk after reset (clock / baud rate)
    parameter        AW          = 6,         // The FIFO towards the core holds 2**AW bytes (the window moves at most 128, keep AW <= 7)
    parameter        AW_RX       = 6          // The FIFO from the core holds 2**AW_RX bytes (make it big when the core answers while the RP2350 is still writing)
) (
    input  wire        clk,             // Zen Link clock (50 MHz)
    input  wire        rst_n,           // Reset on clk, active low
    input  wire [15:0] usr_addr,        // Zen Link user bus address
    input  wire        usr_wr,          // Write strobe
    input  wire [7:0]  usr_wdata,       // Write data
    input  wire        usr_rd,          // Read strobe
    output reg  [7:0]  usr_rdata,       // Read data (combinational from usr_addr)
    input  wire        core_clk,        // Clock of the core
    input  wire        core_rst_n,      // Reset on core_clk, active low
    output reg         line_to_core = 1'b1,  // Serial line into the core's UART receiver
    input  wire        line_from_core   // Serial line out of the core's UART transmitter
);

    // Register hits
    wire hit_data   = (usr_addr == BASE);
    wire hit_status = (usr_addr == BASE + 16'd1);
    wire hit_rxcnt  = (usr_addr == BASE + 16'd2);
    wire hit_txfree = (usr_addr == BASE + 16'd3);
    wire hit_cpblo  = (usr_addr == BASE + 16'd4);
    wire hit_cpbhi  = (usr_addr == BASE + 16'd5);
    // High for any address of the burst window
    wire hit_win    = (usr_addr >= BASE + 16'h0080) && (usr_addr <= BASE + 16'h00FF);
    // High when the access is a data access
    wire hit_fifo   = hit_data | hit_win;

    // Clocks per bit set by the RP2350
    reg [15:0] cpb_reg = CPB_DEFAULT;
    // Sticky write overflow flag
    reg tx_ovf = 1'b0;

    // FIFO towards the core: signals
    wire        ft_full, ft_empty, ft_rd;
    wire [AW:0] ft_space, ft_cnt;
    wire [7:0]  ft_rdata;
    // FIFO from the core: signals
    wire        fr_full, fr_empty;
    reg         fr_wr = 1'b0;
    reg  [7:0]  fr_wdata = 8'd0;
    wire [AW_RX:0] fr_space, fr_cnt;
    wire [7:0]  fr_rdata;

    // This contains the instantiation for the FIFO towards the core
    zl_afifo #(.AW(AW)) u_ft (.wclk(clk), .wrst_n(rst_n), .wr(usr_wr & hit_fifo), .wdata(usr_wdata), .full(ft_full), .wspace(ft_space),
        .rclk(core_clk), .rrst_n(core_rst_n), .rd(ft_rd), .rdata(ft_rdata), .empty(ft_empty), .rcount(ft_cnt));
    // This contains the instantiation for the FIFO from the core
    zl_afifo #(.AW(AW_RX)) u_fr (.wclk(core_clk), .wrst_n(core_rst_n), .wr(fr_wr), .wdata(fr_wdata), .full(fr_full), .wspace(fr_space),
        .rclk(clk), .rrst_n(rst_n), .rd(usr_rd & hit_fifo), .rdata(fr_rdata), .empty(fr_empty), .rcount(fr_cnt));

    // Clocks per bit brought into the core clock domain (two flops, change it only while idle)
    reg [15:0] cpb_s1 = CPB_DEFAULT, cpb_s2 = CPB_DEFAULT;
    // Receive overflow flag (core domain, sticky) and its copy in clk domain
    reg rx_ovf_c = 1'b0, rx_ovf_s1 = 1'b0, rx_ovf_s2 = 1'b0;
    // Serialiser busy flag (core domain) and its copy in clk domain
    reg s_busy = 1'b0, busy_s1 = 1'b0, busy_s2 = 1'b0;
    // Counts zero-extended to 16 bits so the saturation below works for any FIFO size
    wire [15:0] fr_cnt16   = {{(15-AW_RX){1'b0}}, fr_cnt};
    wire [15:0] ft_space16 = {{(15-AW){1'b0}}, ft_space};
    // Clocks per bit, never below 2
    wire [15:0] cpb = (cpb_s2 < 16'd2) ? 16'd2 : cpb_s2;
    // Terminal counts, registered so the counters below only compare for equality (a subtract plus a magnitude compare was too slow for 50 MHz):
    // a full bit counts 0 .. cpb-1, half a bit counts 0 .. cpb/2-1. The clocks-per-bit value only changes while the line is idle, so equality is safe.
    reg [15:0] cpb_m1 = CPB_DEFAULT - 16'd1, half_m1 = (CPB_DEFAULT >> 1) - 16'd1;
    // Register the terminal counts on the core clock
    always @(posedge core_clk) begin
        cpb_m1  <= cpb - 16'd1;
        half_m1 <= (cpb >> 1) - 16'd1;
    end

    // Zen Link side: register writes, flags and the clock domain crossings of the slow signals
    always @(posedge clk) begin
        // Bring the slow flags and the clocks-per-bit value across
        cpb_s1 <= cpb_reg; cpb_s2 <= cpb_s1;
        rx_ovf_s1 <= rx_ovf_c; rx_ovf_s2 <= rx_ovf_s1;
        busy_s1 <= s_busy; busy_s2 <= busy_s1;
        if (!rst_n) begin
            // Reset restores the default clocks per bit and clears the flag
            cpb_reg <= CPB_DEFAULT;
            tx_ovf  <= 1'b0;
        end else begin
            // A byte queued while the FIFO is full is lost and flagged
            if (usr_wr && hit_fifo && ft_full) tx_ovf <= 1'b1;
            // Writing STATUS clears the sticky flag
            if (usr_wr && hit_status) tx_ovf <= 1'b0;
            // Clocks per bit registers
            if (usr_wr && hit_cpblo) cpb_reg[7:0]  <= usr_wdata;
            if (usr_wr && hit_cpbhi) cpb_reg[15:8] <= usr_wdata;
        end
    end

    // Read multiplexer: combinational from the address
    always @* begin
        usr_rdata = 8'd0;
        if (hit_fifo)   usr_rdata = fr_empty ? 8'd0 : fr_rdata;
        if (hit_status) usr_rdata = {3'd0, (ft_empty & ~busy_s2), rx_ovf_s2, tx_ovf, ~ft_full, ~fr_empty};
        if (hit_rxcnt)  usr_rdata = (fr_cnt16 > 16'd255) ? 8'd255 : fr_cnt16[7:0];
        if (hit_txfree) usr_rdata = (ft_space16 > 16'd255) ? 8'd255 : ft_space16[7:0];
        if (hit_cpblo)  usr_rdata = cpb_reg[7:0];
        if (hit_cpbhi)  usr_rdata = cpb_reg[15:8];
    end

    // Serialiser state
    reg [15:0] s_cnt = 16'd0;   // Clock counter inside a bit
    reg [3:0]  s_bit = 4'd0;    // Bit index (0 start, 1..8 data, 9 stop)
    reg [9:0]  s_sh  = 10'h3FF; // Frame being sent
    // Pops the byte from the FIFO as the frame starts
    assign ft_rd = !s_busy && !ft_empty;

    // Serialiser (core clock): takes a byte from the FIFO and sends it as an 8N1 frame on line_to_core
    always @(posedge core_clk) begin
        if (!core_rst_n) begin
            // Idle line
            line_to_core <= 1'b1;
            s_busy <= 1'b0;
            s_cnt  <= 16'd0;
            s_bit  <= 4'd0;
        end else if (!s_busy) begin
            if (!ft_empty) begin
                // Load the frame: start bit, data LSB first, stop bit
                s_sh   <= {1'b1, ft_rdata, 1'b0};
                s_busy <= 1'b1;
                s_bit  <= 4'd0;
                s_cnt  <= 16'd0;
                // Drive the start bit
                line_to_core <= 1'b0;
            end
        end else if (s_cnt == cpb_m1) begin
            // One bit time has passed
            s_cnt <= 16'd0;
            if (s_bit == 4'd9) begin
                // Frame done
                s_busy <= 1'b0;
                line_to_core <= 1'b1;
            end else begin
                // Next bit
                s_bit <= s_bit + 4'd1;
                line_to_core <= s_sh[s_bit + 4'd1];
            end
        end else begin
            s_cnt <= s_cnt + 16'd1;
        end
    end

    // Deserialiser state
    reg [1:0]  r_sy   = 2'b11;  // Synchroniser for the incoming line
    reg        r_busy = 1'b0;   // A frame is being received
    reg [15:0] r_cnt  = 16'd0;  // Clock counter inside a bit
    reg [3:0]  r_bit  = 4'd0;   // Bit index (0 start, 1..8 data, 9 stop)
    reg [7:0]  r_sh   = 8'd0;   // Data shift register
    // Last count before the next sample: half a bit for the start bit, a full bit afterwards
    wire [15:0] r_last = (r_bit == 4'd0) ? half_m1 : cpb_m1;

    // Deserialiser (core clock): samples line_from_core in the middle of each bit and queues each good byte
    always @(posedge core_clk) begin
        // Default: no push
        fr_wr <= 1'b0;
        // Two-flop synchroniser
        r_sy <= {r_sy[0], line_from_core};
        if (!core_rst_n) begin
            r_busy   <= 1'b0;
            rx_ovf_c <= 1'b0;
        end else if (!r_busy) begin
            // Falling edge of the line starts a frame
            if (!r_sy[1]) begin
                r_busy <= 1'b1;
                r_cnt  <= 16'd0;
                r_bit  <= 4'd0;
            end
        end else if (r_cnt == r_last) begin
            // Sample point reached
            r_cnt <= 16'd0;
            if (r_bit == 4'd0) begin
                // Middle of the start bit: it must still be low
                if (r_sy[1]) r_busy <= 1'b0; else r_bit <= 4'd1;
            end else if (r_bit == 4'd9) begin
                // Middle of the stop bit: it must be high
                r_busy <= 1'b0;
                if (r_sy[1]) begin
                    fr_wr    <= 1'b1;
                    fr_wdata <= r_sh;
                    if (fr_full) rx_ovf_c <= 1'b1;
                end
            end else begin
                // Data bit, LSB first
                r_sh  <= {r_sy[1], r_sh[7:1]};
                r_bit <= r_bit + 4'd1;
            end
        end else begin
            r_cnt <= r_cnt + 16'd1;
        end
    end

endmodule
