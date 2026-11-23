// This is the LZSS compressor and decompressor in hardware. It speaks the same byte protocol and produces the same bits as the PicoRV32 firmware (lzss.c) and lzss_ref.py:
//   host -> core : L (1..64) then L raw bytes          core -> host : C then C compressed bytes        host -> core : 0 (forget history)   core -> host : 0
//   host -> core : 0x7E then D (clocks per UART bit, at least 8)   core -> host : 0x7E (at the old rate), then both sides use the new rate; it falls back to the default after 2**IDLE_BITS idle clocks
//   host -> core : 0x7D then N (16 bit, low byte first) then N raw bytes     core -> host : the compressed blocks [C][C bytes], one per 64 input bytes (the core cuts the blocks itself; the last one is shorter)
//   host -> core : 0x7C then M (16 bit, low byte first) then whole compressed blocks [C][C bytes] totalling M bytes     core -> host : [D][D raw bytes] per block
//   host -> core : 0x80 | C then C compressed bytes (one block)     core -> host : D then D raw bytes     (the block is decoded with the same history window)
// Token format (most significant bit first, block padded with zero bits): literal = 0 + 8 bits; match = 1 + 9 bits (distance-1) + 4 bits (length-3), length 3..18, distance 1..512.
// The window lives in a 1024-byte circular RAM (written twice, so two bytes can be read per clock); the match search tests two candidate distances per clock (nearest first).
`timescale 1 ns / 1 ps

module lzss_core #(
    // Clock cycles per UART bit after reset and after an idle timeout
    parameter CPB_DEFAULT = 217,
    // Width of the idle timeout counter
    parameter IDLE_BITS   = 25
) (
    // System clock
    input  wire       clk,
    // Active-low reset
    input  wire       rst_n,
    // A byte arrived from the host
    input  wire       rx_valid,
    // The byte that arrived
    input  wire [7:0] rx_data,
    // The core is waiting for a byte from the host (the FIFO may hand one over this clock)
    output wire       rx_want,
    // A byte is waiting to be sent to the host (held until tx_ready)
    output reg        tx_valid,
    // The byte to send
    output reg  [7:0] tx_data,
    // The transmitter is idle and takes the byte this clock
    input  wire       tx_ready,
    // High while a block is being compressed or sent
    output wire       busy,
    // Clock cycles per UART bit currently in use
    output reg  [7:0] cpb
);

    // Longest match one token can describe
    localparam MAXLEN = 18;
    // State: wait for a command byte
    localparam S_CMD    = 5'd0;
    // State: receive the block bytes into the window RAM
    localparam S_RECV   = 5'd1;
    // State: start the next token (or finish the block)
    localparam S_TOK    = 5'd2;
    // State: present the address of the byte being coded
    localparam S_C0A    = 5'd3;
    // State: capture that byte and decide between literal and search
    localparam S_C0B    = 5'd4;
    // State: scan candidate distances, one per clock
    localparam S_SCAN   = 5'd5;
    // State: present the addresses of the next byte pair of a candidate match
    localparam S_EXTRD  = 5'd6;
    // State: compare that byte pair
    localparam S_EXTCMP = 5'd7;
    // State: build the token
    localparam S_EMIT   = 5'd8;
    // State: shift the token out, one bit per clock
    localparam S_SER    = 5'd9;
    // State: pad the last output byte with zero bits
    localparam S_PAD    = 5'd10;
    // State: start sending the compressed length (or the reset acknowledge)
    localparam S_TXC    = 5'd11;
    // State: present the address of the next output byte
    localparam S_TXA    = 5'd12;
    // State: capture the output byte and hand it to the transmitter
    localparam S_TXB    = 5'd13;
    // State: wait until the transmitter has taken the byte
    localparam S_TXW    = 5'd14;
    // State: receive the compressed bytes of a block to decode
    localparam S_DRECV  = 5'd15;
    // State: start the next token of the block being decoded (or finish)
    localparam S_DTOK   = 5'd16;
    // State: present the address of the compressed byte holding the next bit
    localparam S_DRD    = 5'd17;
    // State: take one bit out of the compressed byte
    localparam S_DBIT   = 5'd18;
    // State: a bit field is complete: act on it
    localparam S_DFLD   = 5'd19;
    // State: write a decoded literal into the window
    localparam S_DWR    = 5'd20;
    // State: present the address of the byte to copy for a match
    localparam S_DCPA   = 5'd21;
    // State: write the copied byte into the window
    localparam S_DCPB   = 5'd22;
    // State: the block is fully decoded
    localparam S_DFIN   = 5'd23;
    // State: receive the new clocks-per-bit value
    localparam S_BAUD   = 5'd24;
    // State: present the baud change acknowledge
    localparam S_BAK1   = 5'd25;
    // State: wait until the transmitter has taken the acknowledge
    localparam S_BAK2   = 5'd26;
    // State: wait until the acknowledge has left the wire, then switch rate
    localparam S_BAK3   = 5'd27;
    // State: receive the low byte of a stream length
    localparam S_SLO    = 5'd28;
    // State: receive the high byte of a stream length
    localparam S_SHI    = 5'd29;
    // State: start the next block of a stream (or end the stream when no bytes are left)
    localparam S_NXT    = 5'd30;
    // State: receive the length byte of the next compressed block of a decode stream
    localparam S_DHD    = 5'd31;

    // Current state
    reg [4:0] st;
    // The core takes a byte only in the states that wait for the host
    assign rx_want = (st == S_CMD) || (st == S_RECV) || (st == S_DRECV) || (st == S_BAUD) || (st == S_SLO) || (st == S_SHI) || (st == S_DHD);
    // Busy whenever the core is not waiting for a command
    assign busy = (st != S_CMD);

    // ------------------------------------------------------------ memories
    // Window RAM for reading the byte being coded (port copy A)
    reg [7:0] mem_a [0:1023];
    // Identical window RAM for reading the candidate byte (port copy B)
    reg [7:0] mem_b [0:1023];
    // Read data of copy A (one clock after the address)
    reg [7:0] q_a;
    // Read data of copy B (one clock after the address)
    reg [7:0] q_b;
    // Identical window RAM for reading the second candidate (port copy C)
    reg [7:0] mem_c [0:1023];
    // Read data of copy C (one clock after the address)
    reg [7:0] q_c;
    // Output RAM that holds the compressed block until its length is known
    reg [7:0] omem [0:127];
    // Read data of the output RAM
    reg [7:0] oq;

    // Read address of copy A
    wire [9:0] ra;
    // Read address of copy B
    wire [9:0] rb;
    // Read address of copy C: the candidate one distance farther than copy B while scanning
    wire [9:0] rc;
    // Write enable of both window RAMs: a byte arrives while receiving, or a decoded byte is stored
    wire       we;
    // Data written to both window RAMs
    wire [7:0] wd;
    // Write enable of the output RAM: a full output byte is complete, or a compressed byte to decode arrives
    wire       owe;
    // Write address of the output RAM
    wire [6:0] owa;
    // Data written to the output RAM
    wire [7:0] owd;
    // Read address of the output RAM
    wire [6:0] ora;

    // Window RAM always block: one write port and one read port on each copy
    always @(posedge clk) begin
        // Store the incoming or decoded byte in both copies
        if (we) begin
            mem_a[wptr] <= wd;
            mem_b[wptr] <= wd;
            mem_c[wptr] <= wd;
        end
        // Read both copies
        q_a <= mem_a[ra];
        q_b <= mem_b[rb];
        q_c <= mem_c[rc];
    end

    // Output RAM always block: write a finished byte, read the byte to send
    always @(posedge clk) begin
        // Store a completed output byte
        if (owe) omem[owa] <= owd;
        // Read the byte to send
        oq <= omem[ora];
    end

    // ------------------------------------------------------------ registers
    // Number of raw bytes in this block (1..64)
    reg [6:0] len;
    // Number of block bytes received so far
    reg [6:0] rcnt;
    // Offset of the token being coded inside the block
    reg [6:0] off;
    // Circular address of the first byte of the block
    reg [9:0] base;
    // Circular address where the next received byte is written
    reg [9:0] wptr;
    // Circular address of the byte being coded (base + off)
    reg [9:0] pa;
    // Number of history bytes before pa that may be referenced (saturates at 512)
    reg [9:0] avail;
    // Longest match allowed for this token (not past the block end, at most 18)
    reg [4:0] maxl;
    // First byte of the token being coded
    reg [7:0] cur0;
    // Distance being issued to the candidate RAM
    reg [9:0] di;
    // Distance whose read data arrives this clock (copy B; copy C holds dc + 1)
    reg [9:0] dc;
    // The copy-C candidate (distance dc + 1) of the read in flight is inside the history
    reg       v1;
    // A candidate read is in flight
    reg       sv;
    // Distance of the candidate whose match is being extended
    reg [9:0] dd;
    // Index of the byte pair being compared while extending a match
    reg [4:0] ei;
    // Match length found so far for the current candidate
    reg [4:0] lcur;
    // Best match length so far
    reg [4:0] best_len;
    // Distance of the best match so far
    reg [9:0] best_d;
    // Token bits, left-aligned (bit 13 goes out first)
    reg [13:0] tok;
    // Token bits still to shift out
    reg [3:0] tcnt;
    // Number of input bytes the current token covers
    reg [4:0] adv;
    // Bit position inside the output byte being assembled
    reg [2:0] bitc;
    // Output byte being assembled
    reg [7:0] sh;
    // Number of finished output bytes
    reg [6:0] on;
    // Index of the output byte being sent
    reg [6:0] txi;
    // The current request is a decode (the reply comes from the window instead of the output RAM)
    reg       dmode;
    // Number of compressed bytes in the block being decoded
    reg [6:0] dn;
    // Number of valid bits in the compressed block (8 * dn)
    reg [9:0] nbits;
    // Index of the next bit to read from the compressed block
    reg [9:0] bp;
    // Bits still to read for the current field
    reg [3:0] rk;
    // Bits of the current field, collected most significant first
    reg [12:0] acc;
    // Which field is being read: 0 flag, 1 literal byte, 2 distance, 3 length
    reg [1:0] dphase;
    // Distance of the match being copied
    reg [9:0] doff;
    // Bytes of the match still to copy
    reg [4:0] dlen;
    // Literal byte decoded
    reg [7:0] dwd;
    // New clocks-per-bit value, applied after the acknowledge has been sent
    reg [7:0] cpb_new;
    // Stream mode: 0 = single block requests, 1 = compress stream, 2 = decode stream
    reg [1:0] smode;
    // Stream bytes still to come (raw bytes for a compress stream, compressed bytes for a decode stream)
    reg [15:0] srem;
    // Low byte of the stream length while the high byte is awaited
    reg [7:0] slo;

    // ------------------------------------------------------------ address and strobe logic
    // Copy A reads the byte being coded, or byte ei of it while a match is extended
    assign ra  = (st == S_EXTRD || st == S_EXTCMP) ? (pa + {5'b0, ei}) : ((st == S_TXA && dmode) ? (pa + {3'b0, txi}) : pa);
    // Copy B reads the candidate at distance di while scanning, or byte ei of the candidate at distance dd while extending
    assign rb  = (st == S_SCAN) ? (pa - di) : ((st == S_DCPA || st == S_DCPB) ? (wptr - doff) : (pa + {5'b0, ei} - dd));
    // Copy C reads the candidate at distance di + 1 while scanning (the address is unused in other states)
    assign rc  = pa - di - 10'd1;
    // Bytes are written into the window while receiving
    assign we  = ((st == S_RECV) && rx_valid) || (st == S_DWR) || (st == S_DCPB);
    // The byte written: the received byte, the decoded literal, or the copied byte
    assign wd  = (st == S_RECV) ? rx_data : ((st == S_DWR) ? dwd : q_b);
    // An output byte is complete when the eighth bit is shifted in
    assign owe = ((st == S_SER || st == S_PAD) && (bitc == 3'd7)) || ((st == S_DRECV) && rx_valid);
    // The output RAM is written at the compressed-byte index while receiving a block to decode, otherwise at the finished-byte count
    assign owa = (st == S_DRECV) ? rcnt : on;
    // The completed output byte: seven earlier bits plus the bit shifted in now (zero while padding)
    assign owd = (st == S_DRECV) ? rx_data : {sh[6:0], (st == S_SER) ? tok[13] : 1'b0};
    // The output RAM is read at the index of the byte being sent
    assign ora = (st == S_DRD || st == S_DBIT) ? bp[9:3] : txi;

    // Idle timeout counter (declared here so the width follows the parameter)
    reg [IDLE_BITS-1:0] idle;
    // Bits left in the compressed block
    wire [9:0] dleft = nbits - bp;
    // Remaining bytes of the block from the current token on
    wire [6:0] rem  = len - off;
    // Sum of the history length and the bytes this token covers
    wire [9:0] avail_next = avail + {5'b0, adv};
    // The byte pair being compared is equal
    wire       eq   = (q_a == q_b);
    // Match length after this comparison
    wire [4:0] lnew = eq ? (lcur + 5'd1) : lcur;

    // ------------------------------------------------------------ main state machine
    // Main always block: receive a block, code it token by token, then send the result
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset: wait for a command, empty history, nothing to send
            st       <= S_CMD;
            tx_valid <= 1'b0;
            avail    <= 10'd0;
            base     <= 10'd0;
            bitc     <= 3'd0;
            on       <= 7'd0;
            sv       <= 1'b0;
            dmode    <= 1'b0;
            smode    <= 2'd0;
            cpb      <= CPB_DEFAULT;
            idle     <= {IDLE_BITS{1'b0}};
        end else begin
            case (st)
                // Wait for a command byte: 0 resets the history, 1..64 is a block length
                S_CMD: if (rx_valid) begin
                    if (rx_data == 8'd0) begin
                        // Forget the history and acknowledge with a zero byte
                        base  <= 10'd0;
                        wptr  <= 10'd0;
                        avail <= 10'd0;
                        on    <= 7'd0;
                        dmode <= 1'b0;
                        st    <= S_TXC;
                    end else if (rx_data == 8'h7D || rx_data == 8'h7C) begin
                        // Stream request: 0x7D compresses, 0x7C decodes; the 16-bit length follows
                        smode <= (rx_data == 8'h7D) ? 2'd1 : 2'd2;
                        st    <= S_SLO;
                    end else if (rx_data == 8'h7E) begin
                        // Baud change: the next byte is the new clocks-per-bit value
                        st <= S_BAUD;
                    end else if (rx_data[7]) begin
                        // Decode request: the low seven bits are the number of compressed bytes that follow
                        dmode <= 1'b1;
                        dn    <= rx_data[6:0];
                        rcnt  <= 7'd0;
                        on    <= 7'd0;
                        // A length of zero has nothing to decode: answer with a zero count
                        st    <= (rx_data[6:0] == 7'd0) ? S_TXC : S_DRECV;
                    end else begin
                        // Clip the block length to 64 and start receiving after the history
                        dmode <= 1'b0;
                        len  <= (rx_data > 8'd64) ? 7'd64 : rx_data[6:0];
                        rcnt <= 7'd0;
                        wptr <= base;
                        st   <= S_RECV;
                    end
                end
                // Receive the block bytes (the window RAMs are written by the we strobe)
                S_RECV: if (rx_valid) begin
                    // Advance the write address and the byte count
                    wptr <= wptr + 10'd1;
                    rcnt <= rcnt + 7'd1;
                    // After the last byte start coding the block from its first byte
                    if (rcnt + 7'd1 == len) begin
                        off  <= 7'd0;
                        pa   <= base;
                        on   <= 7'd0;
                        bitc <= 3'd0;
                        sh   <= 8'd0;
                        st   <= S_TOK;
                    end
                end
                // Start a token, or finish the block when every byte is coded
                S_TOK: begin
                    if (off == len) begin
                        // The next block starts after this one
                        base <= base + {3'b0, len};
                        // Pad the last byte if it is partly filled, then send
                        st   <= (bitc != 3'd0) ? S_PAD : S_TXC;
                    end else begin
                        // Longest match allowed here: not past the block end, at most 18 bytes
                        maxl     <= (rem > MAXLEN) ? MAXLEN : rem[4:0];
                        best_len <= 5'd0;
                        best_d   <= 10'd0;
                        st       <= S_C0A;
                    end
                end
                // The address of the byte being coded is on ra this clock
                S_C0A: st <= S_C0B;
                // Capture the first byte; search only if a match of at least 3 bytes is possible and there is history
                S_C0B: begin
                    cur0 <= q_a;
                    if (maxl < 5'd3 || avail == 10'd0) begin
                        st <= S_EMIT;
                    end else begin
                        di <= 10'd1;
                        sv <= 1'b0;
                        st <= S_SCAN;
                    end
                end
                // Scan candidate distances nearest first: one read issued per clock, compared one clock later
                S_SCAN: begin
                    if (sv && q_b == cur0) begin
                        // The first byte matches at distance dc: extend this candidate byte by byte
                        dd   <= dc;
                        ei   <= 5'd1;
                        lcur <= 5'd1;
                        sv   <= 1'b0;
                        st   <= S_EXTRD;
                    end else if (sv && v1 && q_c == cur0) begin
                        // The first byte matches at distance dc + 1 (the nearer one did not match): extend it
                        dd   <= dc + 10'd1;
                        ei   <= 5'd1;
                        lcur <= 5'd1;
                        sv   <= 1'b0;
                        st   <= S_EXTRD;
                    end else if (di <= avail) begin
                        // Issue the reads of the next two distances (di on copy B, di + 1 on copy C)
                        dc <= di;
                        v1 <= (di + 10'd1 <= avail);
                        di <= di + 10'd2;
                        sv <= 1'b1;
                    end else begin
                        // All distances issued; once the last compare is done, code the token
                        sv <= 1'b0;
                        if (!sv) st <= S_EMIT;
                    end
                end
                // The addresses of byte pair ei are on ra and rb this clock
                S_EXTRD: st <= S_EXTCMP;
                // Compare the byte pair: keep extending while equal, otherwise judge this candidate
                S_EXTCMP: begin
                    if (eq && lnew != maxl) begin
                        // Equal and not yet at the longest allowed length: next byte pair
                        lcur <= lnew;
                        ei   <= ei + 5'd1;
                        st   <= S_EXTRD;
                    end else begin
                        // This candidate is finished: keep it only if strictly longer (nearest distance wins ties)
                        if (lnew > best_len) begin
                            best_len <= lnew;
                            best_d   <= dd;
                        end
                        if (lnew == maxl) begin
                            // Nothing can beat the longest allowed match
                            st <= S_EMIT;
                        end else begin
                            // Resume the scan with the next distance
                            di <= dd + 10'd1;
                            sv <= 1'b0;
                            st <= S_SCAN;
                        end
                    end
                end
                // Build the token: a match of at least 3 bytes, otherwise a literal
                S_EMIT: begin
                    if (best_len >= 5'd3) begin
                        tok  <= {1'b1, best_d[8:0] - 9'd1, best_len[3:0] - 4'd3};
                        tcnt <= 4'd14;
                        adv  <= best_len;
                    end else begin
                        tok  <= {1'b0, cur0, 5'b0};
                        tcnt <= 4'd9;
                        adv  <= 5'd1;
                    end
                    st <= S_SER;
                end
                // Shift the token out one bit per clock; every eighth bit completes an output byte
                S_SER: begin
                    tok  <= {tok[12:0], 1'b0};
                    sh   <= {sh[6:0], tok[13]};
                    bitc <= bitc + 3'd1;
                    tcnt <= tcnt - 4'd1;
                    // A completed byte was written by the owe strobe: count it
                    if (bitc == 3'd7) on <= on + 7'd1;
                    // After the last bit move on to the next token
                    if (tcnt == 4'd1) begin
                        off   <= off + {2'b0, adv};
                        pa    <= pa + {5'b0, adv};
                        avail <= (avail_next > 10'd512) ? 10'd512 : avail_next;
                        st    <= S_TOK;
                    end
                end
                // Shift zero bits in until the output byte is full
                S_PAD: begin
                    sh   <= {sh[6:0], 1'b0};
                    bitc <= bitc + 3'd1;
                    if (bitc == 3'd7) begin
                        on <= on + 7'd1;
                        st <= S_TXC;
                    end
                end
                // Send the number of output bytes first (zero for the reset acknowledge)
                S_TXC: begin
                    tx_data  <= {1'b0, on};
                    tx_valid <= 1'b1;
                    txi      <= 7'd0;
                    st       <= S_TXW;
                end
                // The address of the output byte is on ora this clock
                S_TXA: st <= S_TXB;
                // Hand the output byte to the transmitter
                S_TXB: begin
                    tx_data  <= dmode ? q_a : oq;
                    tx_valid <= 1'b1;
                    txi      <= txi + 7'd1;
                    st       <= S_TXW;
                end
                // Wait until the transmitter takes the byte, then send the next one or finish
                S_TXW: if (tx_ready) begin
                    tx_valid <= 1'b0;
                    // After the last byte go on with the stream (if any) or wait for a command
                    st       <= (txi == on) ? ((smode != 2'd0) ? S_NXT : S_CMD) : S_TXA;
                end
                // Receive the compressed bytes of a block into the output RAM (written by the owe strobe)
                S_DRECV: if (rx_valid) begin
                    rcnt <= rcnt + 7'd1;
                    // After the last byte start decoding: bit 0, output goes after the history
                    if (rcnt + 7'd1 == dn) begin
                        bp    <= 10'd0;
                        nbits <= {dn, 3'b000};
                        wptr  <= base;
                        pa    <= base;
                        on    <= 7'd0;
                        st    <= S_DTOK;
                    end
                end
                // Start a token, or finish when fewer than 9 bits remain (only padding is left; the shortest token has 9 bits)
                S_DTOK: begin
                    if (dleft < 10'd9) begin
                        st <= S_DFIN;
                    end else begin
                        // First read the one-bit flag
                        dphase <= 2'd0;
                        rk     <= 4'd1;
                        acc    <= 13'd0;
                        st     <= S_DRD;
                    end
                end
                // The address of the compressed byte holding bit bp is on ora this clock
                S_DRD: st <= S_DBIT;
                // Take bit bp out of the byte (most significant bit first) and shift it into the field
                S_DBIT: begin
                    acc <= {acc[11:0], oq[3'd7 - bp[2:0]]};
                    bp  <= bp + 10'd1;
                    rk  <= rk - 4'd1;
                    st  <= (rk == 4'd1) ? S_DFLD : S_DRD;
                end
                // A field is complete: the flag chooses literal or match, then the fields are used in turn
                S_DFLD: begin
                    case (dphase)
                        // Flag: 0 = literal (8 bits follow), 1 = match (9 bits distance, 4 bits length follow)
                        2'd0: begin
                            dphase <= acc[0] ? 2'd2 : 2'd1;
                            rk     <= acc[0] ? 4'd9 : 4'd8;
                            acc    <= 13'd0;
                            st     <= S_DRD;
                        end
                        // Literal byte complete: store it
                        2'd1: begin
                            dwd <= acc[7:0];
                            st  <= S_DWR;
                        end
                        // Distance complete: read the 4 length bits
                        2'd2: begin
                            doff   <= {1'b0, acc[8:0]} + 10'd1;
                            dphase <= 2'd3;
                            rk     <= 4'd4;
                            acc    <= 13'd0;
                            st     <= S_DRD;
                        end
                        // Length complete: copy the bytes
                        default: begin
                            dlen <= {1'b0, acc[3:0]} + 5'd3;
                            st   <= S_DCPA;
                        end
                    endcase
                end
                // Store the literal (written by the we strobe) and count it
                S_DWR: begin
                    wptr <= wptr + 10'd1;
                    on   <= on + 7'd1;
                    st   <= S_DTOK;
                end
                // The address of the byte to copy (wptr - distance) is on rb this clock
                S_DCPA: st <= S_DCPB;
                // Store the copied byte (written by the we strobe); copy byte by byte so overlapping matches work
                S_DCPB: begin
                    wptr <= wptr + 10'd1;
                    on   <= on + 7'd1;
                    dlen <= dlen - 5'd1;
                    st   <= (dlen == 5'd1) ? S_DTOK : S_DCPA;
                end
                // The block is decoded: the next block continues after it; send the count and the bytes
                S_DFIN: begin
                    base <= wptr;
                    st   <= S_TXC;
                end
                // Receive the new clocks-per-bit value (values below 8 are refused and the default is kept)
                S_BAUD: if (rx_valid) begin
                    cpb_new <= (rx_data < 8'd8) ? CPB_DEFAULT : rx_data;
                    st      <= S_BAK1;
                end
                // Present the acknowledge byte, still at the old rate
                S_BAK1: begin
                    tx_data  <= 8'h7E;
                    tx_valid <= 1'b1;
                    st       <= S_BAK2;
                end
                // Wait until the transmitter takes the acknowledge
                S_BAK2: if (tx_ready) begin
                    tx_valid <= 1'b0;
                    st       <= S_BAK3;
                end
                // Wait until the acknowledge has fully left the wire (the transmitter is idle again), then use the new rate
                S_BAK3: if (tx_ready) begin
                    cpb <= cpb_new;
                    st  <= S_CMD;
                end
                // Receive the low byte of the stream length
                S_SLO: if (rx_valid) begin
                    slo <= rx_data;
                    st  <= S_SHI;
                end
                // Receive the high byte of the stream length
                S_SHI: if (rx_valid) begin
                    srem <= {rx_data, slo};
                    st   <= S_NXT;
                end
                // Next block of the stream: a compress stream cuts 64 bytes (or what is left) and receives them; a decode stream reads the next block length
                S_NXT: begin
                    if (srem == 16'd0) begin
                        // Stream finished
                        smode <= 2'd0;
                        st    <= S_CMD;
                    end else if (smode == 2'd1) begin
                        dmode <= 1'b0;
                        len   <= (srem > 16'd64) ? 7'd64 : srem[6:0];
                        srem  <= srem - ((srem > 16'd64) ? 16'd64 : {9'b0, srem[6:0]});
                        rcnt  <= 7'd0;
                        wptr  <= base;
                        st    <= S_RECV;
                    end else begin
                        st <= S_DHD;
                    end
                end
                // Decode stream: the next byte is the length of the compressed block
                S_DHD: if (rx_valid) begin
                    dmode <= 1'b1;
                    dn    <= rx_data[6:0];
                    srem  <= (srem > {9'b0, rx_data[6:0]}) ? (srem - {9'b0, rx_data[6:0]} - 16'd1) : 16'd0;
                    rcnt  <= 7'd0;
                    on    <= 7'd0;
                    st    <= (rx_data[6:0] == 7'd0) ? S_TXC : S_DRECV;
                end
                // Any other state value: recover
                default: st <= S_CMD;
            endcase
            // Idle timeout: while waiting for the host (command, block bytes, new rate) count silent clocks; any byte or other activity clears the count
            if (rx_valid || !(st == S_CMD || st == S_RECV || st == S_DRECV || st == S_BAUD || st == S_SLO || st == S_SHI || st == S_DHD)) idle <= {IDLE_BITS{1'b0}};
            else idle <= idle + 1'b1;
            // After a long silence give up any half-received request and return the link to the default rate
            if (idle[IDLE_BITS-1]) begin
                st   <= S_CMD;
                smode <= 2'd0;
                cpb  <= CPB_DEFAULT;
                idle <= {IDLE_BITS{1'b0}};
            end
        end
    end

endmodule
