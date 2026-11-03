// aes-top.v - AES-128 engine behind a UART: command parser, ECB and CTR modes, baud switch, all in RTL (no CPU).
//
// Commands (one letter, then the arguments; every reply byte is sent back on the same UART):
//   'K' + 16 bytes        set the key and expand it                -> 'K'
//   'I' + 16 bytes        set the CTR counter block (big endian)    -> 'I'
//   'E' + N + N*16 bytes  ECB encrypt N blocks (N = 1..255)         -> N*16 bytes
//   'D' + N + N*16 bytes  ECB decrypt N blocks (N = 1..255)         -> N*16 bytes
//   'C' + LH + LL + bytes CTR crypt LEN bytes (LEN = LH*256 + LL)   -> LEN bytes (the counter advances one per started block)
//   'B' + D               set the baud rate to clock/D (D = 4..255, 0 = default)   -> 'B' (sent at the old rate)
//   'V'                   version                                    -> 'A' 'E' 'S' and one config byte {MC_PAR, SB_LANES}
//   anything else                                                    -> 'X'
// After about IDLE_CLKS clocks without a received byte the parser resets and the baud rate returns to the default.

module aes_top #(
    parameter SB_LANES    = 1,        // S-box lookups per clock (Zen 4: 1, Zen 8: 4)
    parameter MC_PAR      = 1,        // MixColumns columns per clock (Zen 4: 1, Zen 8: 4)
    parameter CPB_DEFAULT = 217,      // Clocks per bit after reset (25 MHz / 115200)
    parameter IDLE_CLKS   = 17500000  // Clocks of silence before the parser resets (0.7 s at 25 MHz)
) (
    input  wire clk,       // Clock
    input  wire rst,       // Synchronous reset, active high
    input  wire uart_rx,   // UART receive pin
    output wire uart_tx,   // UART transmit pin
    output wire busy_led,  // High while a command is being processed
    output wire err_led    // High after the receive FIFO overflowed (sticky)
);

    // Configuration byte reported by the 'V' command
    localparam [7:0] CFG = MC_PAR * 16 + SB_LANES;

    // Parser states
    localparam S_CMD   = 5'd0;   // Wait for a command letter
    localparam S_KEY   = 5'd1;   // Receive the 16 key bytes
    localparam S_KGO   = 5'd2;   // Start the key expansion
    localparam S_KWAIT = 5'd3;   // Wait until the expansion is finished
    localparam S_IVIN  = 5'd4;   // Receive the 16 counter bytes
    localparam S_NB    = 5'd5;   // Receive the block count
    localparam S_BIN   = 5'd6;   // Receive the 16 bytes of an ECB block
    localparam S_BGO   = 5'd7;   // Start the cipher on the block
    localparam S_BWAIT = 5'd8;   // Wait until the cipher is finished
    localparam S_BOUT  = 5'd9;   // Send the 16 result bytes
    localparam S_LH    = 5'd10;  // Receive the high byte of the CTR length
    localparam S_LL    = 5'd11;  // Receive the low byte of the CTR length
    localparam S_CLD   = 5'd12;  // Load the counter block into the cipher
    localparam S_CINC  = 5'd13;  // Increment the counter
    localparam S_CGO   = 5'd14;  // Start the cipher on the counter block
    localparam S_CWAIT = 5'd15;  // Wait until the key stream block is ready
    localparam S_CIN   = 5'd16;  // Receive one CTR data byte
    localparam S_COUT  = 5'd17;  // Send one CTR result byte
    localparam S_BDIV  = 5'd18;  // Receive the baud divisor
    localparam S_REP   = 5'd19;  // Send the reply bytes
    localparam S_REPW  = 5'd20;  // Wait until the last reply byte is on the wire

    // Parser state
    reg [4:0]  state;
    // Clocks per bit used by both UART halves
    reg [15:0] cpb;
    // Byte counter inside a block, a key or a counter block
    reg [3:0]  kcnt;
    // Byte counter inside a CTR chunk
    reg [3:0]  cj;
    // Number of ECB blocks requested
    reg [7:0]  nb;
    // Number of ECB blocks finished
    reg [7:0]  bcnt;
    // Remaining CTR bytes
    reg [15:0] rem;
    // 0 = encrypt, 1 = decrypt for the ECB command
    reg        dec_cmd;
    // Shift register that collects a key word
    reg [31:0] wsh;
    // CTR counter block, big endian (byte 0 of the block in bits 127:120)
    reg [127:0] ctr;
    // Reply bytes waiting to be sent, first byte in bits 7:0
    reg [31:0] rep_buf;
    // Number of reply bytes still to send
    reg [2:0]  rep_n;
    // New baud divisor from the 'B' command
    reg [7:0]  newdiv;
    // High when the baud divisor must be applied after the reply
    reg        apply;
    // Holds the CTR output byte until the transmitter is free
    reg [7:0]  xb;
    // Counts clocks without a received byte
    reg [26:0] idle_cnt;
    // High while a read from the FIFO is outstanding
    reg        inflight;
    // One clock pulse: read the FIFO
    reg        fifo_rd;
    // One clock pulse: empty the FIFO
    reg        soft_clr;

    // Transmitter control
    reg  [7:0] tx_data;
    // One clock pulse: send tx_data
    reg        tx_start;
    // Transmitter busy
    wire       tx_busy;
    // Transmitter ready for a new byte
    wire       tx_free = !tx_busy && !tx_start;

    // Core control
    reg         kw_clr, kw_valid, ks_start, ld_valid, unld_valid, blk_start, blk_dec;
    // Key word for the core
    reg  [31:0] kw_data;
    // Byte for the core
    reg  [7:0]  ld_byte;
    // Core status
    wire        ks_busy, ks_done, blk_busy, blk_done;
    // Low state byte of the core
    wire [7:0]  st_byte;

    // Receiver outputs
    wire [7:0]  rx_data;
    // One clock pulse per received byte
    wire        rx_valid;
    // FIFO outputs
    wire [7:0]  fq;
    // One clock pulse when fq holds a requested byte
    wire        fq_v;
    // FIFO empty flag
    wire        fempty;
    // FIFO overflow flag
    wire        fovf;

    // High in every state that waits for a byte from the FIFO
    wire need = (state == S_CMD) || (state == S_KEY) || (state == S_IVIN) || (state == S_NB) || (state == S_BIN) ||
                (state == S_LH)  || (state == S_LL)  || (state == S_CIN)  || (state == S_BDIV);

    // LEDs
    assign busy_led = (state != S_CMD);
    // Error LED
    assign err_led  = fovf;

    // This contains the instantiation for the UART receiver
    uart_rx u_rx (.clk(clk), .rst(rst), .cpb(cpb), .rx(uart_rx), .data(rx_data), .valid(rx_valid));

    // This contains the instantiation for the receive FIFO
    byte_fifo u_fifo (.clk(clk), .rst(rst), .clr(soft_clr), .wr_en(rx_valid), .wr_data(rx_data), .rd_en(fifo_rd),
                      .rd_data(fq), .rd_valid(fq_v), .empty(fempty), .overflow(fovf));

    // This contains the instantiation for the UART transmitter
    uart_tx u_tx (.clk(clk), .rst(rst), .cpb(cpb), .data(tx_data), .start(tx_start), .tx(uart_tx), .busy(tx_busy));

    // This contains the instantiation for the AES core
    aes_core #(.SB_LANES(SB_LANES), .MC_PAR(MC_PAR)) u_core (
        .clk(clk), .rst(rst), .kw_clr(kw_clr), .kw_valid(kw_valid), .kw_data(kw_data), .ks_start(ks_start),
        .ks_busy(ks_busy), .ks_done(ks_done), .ld_valid(ld_valid), .ld_byte(ld_byte), .unld_valid(unld_valid),
        .st_byte(st_byte), .blk_start(blk_start), .blk_dec(blk_dec), .blk_busy(blk_busy), .blk_done(blk_done));

    // This block is the command parser: it fetches bytes from the FIFO and drives the core and the transmitter
    always @(posedge clk) begin
        tx_start   <= 1'b0;                                                    // Default: no byte to send
        kw_clr     <= 1'b0;                                                    // Default: no key word counter restart
        kw_valid   <= 1'b0;                                                    // Default: no key word
        ks_start   <= 1'b0;                                                    // Default: no expansion start
        ld_valid   <= 1'b0;                                                    // Default: no state load
        unld_valid <= 1'b0;                                                    // Default: no state unload
        blk_start  <= 1'b0;                                                    // Default: no block start
        soft_clr   <= 1'b0;                                                    // Default: no FIFO clear
        fifo_rd    <= 1'b0;                                                    // Default: no FIFO read
        if (rst) begin
            state    <= S_CMD;                                                 // Wait for a command
            cpb      <= CPB_DEFAULT;                                           // Default baud rate
            inflight <= 1'b0;                                                  // No FIFO read outstanding
            idle_cnt <= 27'd0;                                                 // No silence yet
            apply    <= 1'b0;                                                  // No baud change pending
        end else begin
            // ---- idle timeout: after a long silence reset the parser and the baud rate
            if (!need || rx_valid) begin
                idle_cnt <= 27'd0;                                             // Not waiting, or just heard something
            end else if (idle_cnt == IDLE_CLKS) begin
                idle_cnt <= 27'd0;                                             // Start counting again
                state    <= S_CMD;                                             // Give up the current command
                cpb      <= CPB_DEFAULT;                                       // Back to the default baud rate
                soft_clr <= 1'b1;                                              // Throw away what is in the FIFO
                inflight <= 1'b0;                                              // Forget the outstanding read
                apply    <= 1'b0;                                              // Forget the baud change
            end else begin
                idle_cnt <= idle_cnt + 27'd1;                                  // Count the silence
            end
            // ---- fetch engine: ask the FIFO for one byte whenever the current state needs one
            if (need && !inflight && !fempty && !fifo_rd) begin
                fifo_rd  <= 1'b1;                                              // Request the oldest byte
                inflight <= 1'b1;                                              // Wait for it
            end
            if (fq_v) inflight <= 1'b0;                                        // The byte has arrived
            // ---- the parser itself
            case (state)
                S_CMD: if (fq_v) begin
                    case (fq)
                        8'h4B: begin state <= S_KEY;  kcnt <= 4'd0; kw_clr <= 1'b1; end   // 'K': key
                        8'h49: begin state <= S_IVIN; kcnt <= 4'd0; end                   // 'I': counter block
                        8'h45: begin state <= S_NB;   dec_cmd <= 1'b0; end                // 'E': ECB encrypt
                        8'h44: begin state <= S_NB;   dec_cmd <= 1'b1; end                // 'D': ECB decrypt
                        8'h43: state <= S_LH;                                             // 'C': CTR
                        8'h42: state <= S_BDIV;                                           // 'B': baud
                        8'h56: begin rep_buf <= {CFG, 8'h53, 8'h45, 8'h41}; rep_n <= 3'd4; state <= S_REP; end // 'V': "AES" + config
                        default: begin rep_buf <= 32'h58; rep_n <= 3'd1; state <= S_REP; end                  // unknown: 'X'
                    endcase
                end
                S_KEY: if (fq_v) begin
                    wsh  <= {fq, wsh[31:8]};                                   // Collect the word, first byte ends up in bits 7:0
                    kcnt <= kcnt + 4'd1;                                       // Count the byte
                    if (kcnt[1:0] == 2'd3) begin
                        kw_data  <= {fq, wsh[31:8]};                           // The finished word
                        kw_valid <= 1'b1;                                      // Write it to the core
                    end
                    if (kcnt == 4'd15) state <= S_KGO;                         // All 16 bytes received
                end
                S_KGO: begin
                    ks_start <= 1'b1;                                          // Start the expansion
                    state    <= S_KWAIT;                                       // Wait for it
                end
                S_KWAIT: if (ks_done) begin
                    rep_buf <= 32'h4B;                                         // Reply 'K'
                    rep_n   <= 3'd1;                                           // One byte
                    state   <= S_REP;                                          // Send it
                end
                S_IVIN: if (fq_v) begin
                    ctr  <= {ctr[119:0], fq};                                  // Shift the byte into the counter, first byte ends up on top
                    kcnt <= kcnt + 4'd1;                                       // Count the byte
                    if (kcnt == 4'd15) begin
                        rep_buf <= 32'h49;                                     // Reply 'I'
                        rep_n   <= 3'd1;                                       // One byte
                        state   <= S_REP;                                      // Send it
                    end
                end
                S_NB: if (fq_v) begin
                    if (fq == 8'd0) begin
                        rep_buf <= 32'h58;                                     // Zero blocks is an error: reply 'X'
                        rep_n   <= 3'd1;                                       // One byte
                        state   <= S_REP;                                      // Send it
                    end else begin
                        nb    <= fq;                                           // Number of blocks
                        bcnt  <= 8'd0;                                         // None finished yet
                        kcnt  <= 4'd0;                                         // First byte of the first block
                        state <= S_BIN;                                        // Receive the first block
                    end
                end
                S_BIN: if (fq_v) begin
                    ld_byte  <= fq;                                            // Hand the byte to the core
                    ld_valid <= 1'b1;                                          // Shift it in
                    kcnt     <= kcnt + 4'd1;                                   // Count the byte
                    if (kcnt == 4'd15) state <= S_BGO;                         // Block complete
                end
                S_BGO: begin
                    blk_dec   <= dec_cmd;                                      // Direction
                    blk_start <= 1'b1;                                         // Start the cipher
                    state     <= S_BWAIT;                                      // Wait for it
                end
                S_BWAIT: if (blk_done) begin
                    kcnt  <= 4'd0;                                             // First result byte
                    state <= S_BOUT;                                           // Send the result
                end
                S_BOUT: if (tx_free) begin
                    tx_data    <= st_byte;                                     // Next result byte
                    tx_start   <= 1'b1;                                        // Send it
                    unld_valid <= 1'b1;                                        // Move the core state along
                    kcnt       <= kcnt + 4'd1;                                 // Count the byte
                    if (kcnt == 4'd15) begin
                        bcnt <= bcnt + 8'd1;                                   // One more block finished
                        kcnt <= 4'd0;                                          // First byte of the next block
                        if (bcnt + 8'd1 == nb) state <= S_CMD;                 // That was the last block
                        else state <= S_BIN;                                   // Receive the next block
                    end
                end
                S_LH: if (fq_v) begin
                    rem[15:8] <= fq;                                           // High byte of the length
                    state     <= S_LL;                                         // Low byte next
                end
                S_LL: if (fq_v) begin
                    rem[7:0] <= fq;                                            // Low byte of the length
                    kcnt     <= 4'd0;                                          // Start loading the counter block
                    if ({rem[15:8], fq} == 16'd0) state <= S_CMD;              // Zero length: nothing to do
                    else state <= S_CLD;                                       // Make the first key stream block
                end
                S_CLD: begin
                    ld_byte  <= ctr[127:120];                                  // Next counter byte, first byte first
                    ld_valid <= 1'b1;                                          // Shift it into the core
                    ctr      <= {ctr[119:0], ctr[127:120]};                    // Rotate the counter register
                    kcnt     <= kcnt + 4'd1;                                   // Count the byte
                    if (kcnt == 4'd15) state <= S_CINC;                        // 16 rotations bring the counter back to its value
                end
                S_CINC: begin
                    ctr   <= ctr + 128'd1;                                     // The next block uses the next counter value
                    state <= S_CGO;                                            // Start the cipher
                end
                S_CGO: begin
                    blk_dec   <= 1'b0;                                         // CTR always encrypts
                    blk_start <= 1'b1;                                         // Start the cipher
                    state     <= S_CWAIT;                                      // Wait for it
                end
                S_CWAIT: if (blk_done) begin
                    cj    <= 4'd0;                                             // First byte of this chunk
                    state <= S_CIN;                                            // Receive the data bytes
                end
                S_CIN: if (fq_v) begin
                    xb    <= fq ^ st_byte;                                     // XOR with the key stream byte
                    state <= S_COUT;                                           // Send the result
                end
                S_COUT: if (tx_free) begin
                    tx_data    <= xb;                                          // The result byte
                    tx_start   <= 1'b1;                                        // Send it
                    unld_valid <= 1'b1;                                        // Next key stream byte
                    rem        <= rem - 16'd1;                                 // One byte less to do
                    cj         <= cj + 4'd1;                                   // Count the byte in this chunk
                    if (rem == 16'd1) state <= S_CMD;                          // That was the last byte
                    else if (cj == 4'd15) begin
                        kcnt  <= 4'd0;                                         // Chunk finished: make the next key stream block
                        state <= S_CLD;                                        // Load the next counter value
                    end else state <= S_CIN;                                   // Next byte of this chunk
                end
                S_BDIV: if (fq_v) begin
                    if (fq != 8'd0 && fq < 8'd4) begin
                        rep_buf <= 32'h58;                                     // Divisors 1..3 are too fast: reply 'X'
                        rep_n   <= 3'd1;                                       // One byte
                    end else begin
                        newdiv  <= fq;                                         // Remember the divisor
                        apply   <= 1'b1;                                       // Apply it after the reply
                        rep_buf <= 32'h42;                                     // Reply 'B' at the old rate
                        rep_n   <= 3'd1;                                       // One byte
                    end
                    state <= S_REP;                                            // Send the reply
                end
                S_REP: if (tx_free) begin
                    tx_data  <= rep_buf[7:0];                                  // Next reply byte
                    tx_start <= 1'b1;                                          // Send it
                    rep_buf  <= {8'h00, rep_buf[31:8]};                        // Move the next byte down
                    rep_n    <= rep_n - 3'd1;                                  // Count the byte
                    if (rep_n == 3'd1) state <= S_REPW;                        // That was the last one
                end
                S_REPW: if (tx_free) begin
                    if (apply) begin
                        cpb   <= (newdiv == 8'd0) ? CPB_DEFAULT : {8'd0, newdiv}; // Switch the baud rate now that the reply is out
                        apply <= 1'b0;                                         // Done
                    end
                    state <= S_CMD;                                            // Ready for the next command
                end
                default: state <= S_CMD;                                       // Safety net
            endcase
        end
    end

endmodule
