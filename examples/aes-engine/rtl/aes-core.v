// aes-core.v - AES-128 encrypt / decrypt core for one 128 bit block at a time.
// The key is written as four 32 bit words, expanded into 44 round key words in a block RAM,
// and then every block is processed with the straight (not "equivalent") inverse cipher.
// Byte order everywhere: byte i of a block sits at bits [8*i+7 : 8*i]; column c is bits [32*c+31 : 32*c].
// SB_LANES = number of S-box lookups per clock in SubBytes (Zen 4: 1, Zen 8: 4).
// MC_PAR   = number of MixColumns columns done per clock (Zen 4: 1, Zen 8: 4).

module aes_core #(
    parameter SB_LANES = 1, // S-box lookups per clock in SubBytes: 1, 2 or 4
    parameter MC_PAR   = 1  // MixColumns columns per clock: 1 or 4
) (
    input  wire        clk,        // Clock
    input  wire        rst,        // Synchronous reset, active high
    // ---- key interface
    input  wire        kw_clr,     // Pulse: restart the key word counter before writing a new key
    input  wire        kw_valid,   // Pulse: kw_data is the next key word (words 0..3 in order)
    input  wire [31:0] kw_data,    // Key word, byte 0 of the word in bits 7:0
    input  wire        ks_start,   // Pulse: expand the key (after the four words were written)
    output reg         ks_busy,    // High while the key is being expanded
    output reg         ks_done,    // Pulse when the key expansion has finished
    // ---- block interface
    input  wire        ld_valid,   // Pulse: shift ld_byte into the state (only while idle)
    input  wire [7:0]  ld_byte,    // Byte to shift in, the first byte of a block goes in first
    input  wire        unld_valid, // Pulse: drop the low state byte (only while idle)
    output wire [7:0]  st_byte,    // Low state byte, the first byte of a block comes out first
    input  wire        blk_start,  // Pulse: process the block in the state register
    input  wire        blk_dec,    // 0 = encrypt, 1 = decrypt (sampled with blk_start)
    output reg         blk_busy,   // High while a block is being processed
    output reg         blk_done    // Pulse when the block in the state register is finished
);

    // Number of SubBytes steps needed to cover all 16 bytes
    localparam NSTEP = 16 / SB_LANES;

    // Cipher state machine: idle, AddRoundKey, ShiftRows, SubBytes, MixColumns
    localparam C_IDLE = 3'd0;
    localparam C_ARK  = 3'd1;
    localparam C_SR   = 3'd2;
    localparam C_SB   = 3'd3;
    localparam C_MC   = 3'd4;

    // Key expansion state machine: idle, read old word, present S-box address, take S-box data, write new word
    localparam K_IDLE = 3'd0;
    localparam K_RD   = 3'd1;
    localparam K_SA   = 3'd2;
    localparam K_SB   = 3'd3;
    localparam K_WR   = 3'd4;

    // ------------------------------------------------------------------ helper functions

    // This function multiplies a byte by x in GF(2^8) (AES "xtime")
    function [7:0] xtime;
        input [7:0] b; // The byte to double
        begin
            xtime = {b[6:0], 1'b0} ^ (b[7] ? 8'h1b : 8'h00); // Shift left and reduce when the top bit fell out
        end
    endfunction

    // This function applies MixColumns (dec = 0) or InvMixColumns (dec = 1) to one 32 bit column
    function [31:0] mixcol;
        input        dec; // 1 selects the inverse transform
        input [31:0] c;   // The column, row 0 in bits 7:0
        reg [7:0] a0, a1, a2, a3; // The four input bytes (modified by the inverse pre-step)
        reg [7:0] u, v;           // Pre-step terms for the inverse transform
        reg [7:0] b0, b1, b2, b3; // The four output bytes
        begin
            a0 = c[7:0];   // Row 0
            a1 = c[15:8];  // Row 1
            a2 = c[23:16]; // Row 2
            a3 = c[31:24]; // Row 3
            if (dec) begin
                u = xtime(xtime(a0 ^ a2)); // Inverse pre-step: 4 * (a0 ^ a2)
                v = xtime(xtime(a1 ^ a3)); // Inverse pre-step: 4 * (a1 ^ a3)
                a0 = a0 ^ u;               // InvMixColumns equals MixColumns after this pre-step
                a2 = a2 ^ u;               // Same term on row 2
                a1 = a1 ^ v;               // Same term on row 1
                a3 = a3 ^ v;               // Same term on row 3
            end
            b0 = xtime(a0) ^ xtime(a1) ^ a1 ^ a2 ^ a3;            // 2*a0 + 3*a1 + a2 + a3
            b1 = a0 ^ xtime(a1) ^ xtime(a2) ^ a2 ^ a3;            // a0 + 2*a1 + 3*a2 + a3
            b2 = a0 ^ a1 ^ xtime(a2) ^ xtime(a3) ^ a3;            // a0 + a1 + 2*a2 + 3*a3
            b3 = xtime(a0) ^ a0 ^ a1 ^ a2 ^ xtime(a3);            // 3*a0 + a1 + a2 + 2*a3
            mixcol = {b3, b2, b1, b0};                            // Pack the column
        end
    endfunction

    // This function applies ShiftRows (dec = 0) or InvShiftRows (dec = 1) to the whole state
    function [127:0] shiftrows;
        input         dec; // 1 selects the inverse transform
        input [127:0] s;   // The state
        reg [127:0] t;     // The result under construction
        integer r, c, sc;  // Row, column and source column
        begin
            t = 128'd0; // Start clean
            for (c = 0; c < 4; c = c + 1) begin
                for (r = 0; r < 4; r = r + 1) begin
                    sc = dec ? ((c + 4 - r) % 4) : ((c + r) % 4);       // Row r moves left by r (right by r when inverse)
                    t[8*(r + 4*c) +: 8] = s[8*(r + 4*sc) +: 8];         // Copy the byte from its source column
                end
            end
            shiftrows = t; // Return the permuted state
        end
    endfunction

    // ------------------------------------------------------------------ registers and wires

    // The 128 bit state register
    reg [127:0] st;
    // Cipher state machine state
    reg [2:0]   cs;
    // Current round number (also the round key index for AddRoundKey)
    reg [3:0]   rnd;
    // Step counter inside a phase
    reg [4:0]   cnt;
    // Direction latched at blk_start
    reg         dec_r;

    // Key expansion state
    reg [2:0]   ks;
    // Index of the key word being produced (4..43)
    reg [5:0]   ks_i;
    // Round constant of the next RotWord word
    reg [7:0]   ks_rc;
    // Byte counter inside the SubWord step
    reg [1:0]   ks_j;
    // The word XORed onto the old word (previous word, or SubWord(RotWord) ^ Rcon)
    reg [31:0]  ks_t;
    // The previous key word (word i-1)
    reg [31:0]  prev;
    // Counts the key words written so far (0..3)
    reg [1:0]   kw_cnt;

    // Round key RAM: 44 words used, 64 allocated
    reg [31:0]  kmem [0:63];
    // Registered read data of the round key RAM
    reg [31:0]  rq;

    // Byte counter plus one, wraps inside 2 bits (used for RotWord)
    wire [1:0]  ks_jn = ks_j + 2'd1;
    // The previous word byte that RotWord moves to position ks_j
    wire [7:0]  ks_sbin = prev[8*ks_jn +: 8];
    // Read address of the round key RAM: old word during expansion, round key column otherwise
    wire [5:0]  kra = ks_busy ? (ks_i - 6'd4) : {rnd, cnt[1:0]};
    // Write enable of the round key RAM
    wire        kwe = kw_valid | (ks == K_WR);
    // Write address of the round key RAM
    wire [5:0]  kwa = kw_valid ? {4'd0, kw_cnt} : ks_i;
    // Write data of the round key RAM
    wire [31:0] kwd = kw_valid ? kw_data : (rq ^ ks_t);

    // S-box ROM addresses, one 9 bit address per lane
    wire [9*SB_LANES-1:0] rom_addr;
    // S-box ROM read data, one byte per lane
    wire [8*SB_LANES-1:0] rom_q;

    // The low state byte is the output byte
    assign st_byte = st[7:0];

    // ------------------------------------------------------------------ S-box ROMs

    // This generate loop builds one ROM and its address mux per lane
    genvar g;
    generate
        for (g = 0; g < SB_LANES; g = g + 1) begin : g_rom
            // State byte that this lane looks up in the current SubBytes step (0 outside the lookup steps)
            wire [7:0] sb_in = (cs == C_SB && cnt < NSTEP) ? st[8*(cnt*SB_LANES + g) +: 8] : 8'h00;
            // Address for the cipher: {inverse flag, byte}
            wire [8:0] a_c = {dec_r, sb_in};
            if (g == 0) begin : g_first
                // Lane 0 is shared with the key expansion SubWord step
                assign rom_addr[8:0] = ks_busy ? {1'b0, ks_sbin} : a_c;
            end else begin : g_other
                // The other lanes only serve the cipher
                assign rom_addr[9*g +: 9] = a_c;
            end
            // This contains the instantiation for the S-box ROM of this lane
            aes_sbox_rom u_rom (.clk(clk), .addr(rom_addr[9*g +: 9]), .q(rom_q[8*g +: 8]));
        end
    endgenerate

    // ------------------------------------------------------------------ round key RAM

    // This block is the round key RAM: one write port and one registered read port
    always @(posedge clk) begin
        if (kwe) kmem[kwa] <= kwd; // Write a key word
        rq <= kmem[kra];           // Read a key word, valid one clock later
    end

    // ------------------------------------------------------------------ key expansion

    // This block runs the key expansion: it stores words 0..3 and then makes words 4..43
    always @(posedge clk) begin
        ks_done <= 1'b0;                                              // Default: no done pulse
        if (rst) begin
            ks      <= K_IDLE;                                        // Back to idle
            ks_busy <= 1'b0;                                          // Not expanding
            kw_cnt  <= 2'd0;                                          // No key words written
        end else begin
            if (kw_clr) kw_cnt <= 2'd0;                               // Restart the word counter on request
            if (kw_valid) begin
                kw_cnt <= kw_cnt + 2'd1;                              // Count the key word being written
                if (kw_cnt == 2'd3) prev <= kw_data;                  // The last key word is word i-1 for the first new word
            end
            case (ks)
                K_IDLE: if (ks_start) begin
                    ks_i    <= 6'd4;                                  // First word to produce
                    ks_rc   <= 8'h01;                                 // First round constant
                    ks_busy <= 1'b1;                                  // Expansion running
                    kw_cnt  <= 2'd0;                                  // Ready for the next key
                    ks      <= K_RD;                                  // Start with the read
                end
                K_RD: begin
                    if (ks_i[1:0] == 2'd0) begin
                        ks_j <= 2'd0;                                 // Words 4, 8, ... need SubWord(RotWord)
                        ks   <= K_SA;                                 // Go look up the S-box bytes
                    end else begin
                        ks_t <= prev;                                 // Other words just XOR the previous word
                        ks   <= K_WR;                                 // Go write the word
                    end
                end
                K_SA: ks <= K_SB;                                     // The ROM address is presented this clock, the data comes next clock
                K_SB: begin
                    ks_t[8*ks_j +: 8] <= rom_q[7:0] ^ ((ks_j == 2'd0) ? ks_rc : 8'h00); // Store S-box byte, Rcon on byte 0
                    if (ks_j == 2'd3) begin
                        ks_rc <= xtime(ks_rc);                        // Next round constant
                        ks    <= K_WR;                                // All four bytes done
                    end else begin
                        ks_j <= ks_j + 2'd1;                          // Next byte
                        ks   <= K_SA;                                 // Look it up
                    end
                end
                K_WR: begin
                    prev <= rq ^ ks_t;                                // The new word is word i-1 for the next word
                    if (ks_i == 6'd43) begin
                        ks      <= K_IDLE;                            // That was the last word
                        ks_busy <= 1'b0;                              // Expansion finished
                        ks_done <= 1'b1;                              // Tell the user
                    end else begin
                        ks_i <= ks_i + 6'd1;                          // Next word
                        ks   <= K_RD;                                 // Read its old word
                    end
                end
                default: ks <= K_IDLE;                                // Safety net
            endcase
        end
    end

    // ------------------------------------------------------------------ cipher

    // Loop variable for the lane loops
    integer l;
    // Index of the state byte written back by a lane
    integer wi;
    // Column loop variable
    integer cc;

    // This block runs the cipher: load / unload bytes while idle, then the rounds
    always @(posedge clk) begin
        blk_done <= 1'b0;                                                         // Default: no done pulse
        if (rst) begin
            cs       <= C_IDLE;                                                   // Back to idle
            blk_busy <= 1'b0;                                                     // Not busy
        end else begin
            case (cs)
                C_IDLE: begin
                    if (ld_valid) st <= {ld_byte, st[127:8]};                     // Shift a new byte in at the top
                    else if (unld_valid) st <= {8'h00, st[127:8]};                // Shift the low byte out
                    if (blk_start) begin
                        dec_r    <= blk_dec;                                      // Remember the direction
                        rnd      <= blk_dec ? 4'd10 : 4'd0;                       // Decrypt starts with the last round key
                        cnt      <= 5'd0;                                         // First step
                        blk_busy <= 1'b1;                                         // Now busy
                        cs       <= C_ARK;                                        // First operation is AddRoundKey
                    end
                end
                C_ARK: begin
                    if (cnt >= 5'd1) st[32*(cnt - 1) +: 32] <= st[32*(cnt - 1) +: 32] ^ rq; // XOR the column read one clock ago
                    if (cnt == 5'd4) begin
                        cnt <= 5'd0;                                              // Next phase starts at step 0
                        if (!dec_r) begin
                            if (rnd == 4'd10) begin
                                cs       <= C_IDLE;                               // Encryption finished
                                blk_busy <= 1'b0;                                 // Not busy any more
                                blk_done <= 1'b1;                                 // Tell the user
                            end else begin
                                rnd <= rnd + 4'd1;                                // Next round
                                cs  <= C_SR;                                      // ShiftRows comes next
                            end
                        end else begin
                            if (rnd == 4'd0) begin
                                cs       <= C_IDLE;                               // Decryption finished
                                blk_busy <= 1'b0;                                 // Not busy any more
                                blk_done <= 1'b1;                                 // Tell the user
                            end else if (rnd == 4'd10) begin
                                rnd <= 4'd9;                                      // First decryption round has no InvMixColumns
                                cs  <= C_SR;                                      // InvShiftRows comes next
                            end else begin
                                cs <= C_MC;                                       // Rounds 9..1: InvMixColumns after the key
                            end
                        end
                    end else begin
                        cnt <= cnt + 5'd1;                                        // Next column
                    end
                end
                C_SR: begin
                    st  <= shiftrows(dec_r, st);                                  // Permute the rows in one clock
                    cnt <= 5'd0;                                                  // SubBytes starts at step 0
                    cs  <= C_SB;                                                  // SubBytes comes next
                end
                C_SB: begin
                    if (cnt != 5'd0) begin
                        for (l = 0; l < SB_LANES; l = l + 1) begin
                            wi = (cnt - 1) * SB_LANES + l;                        // Byte looked up one clock ago by lane l
                            st[8*wi +: 8] <= rom_q[8*l +: 8];                     // Write the substituted byte back
                        end
                    end
                    if (cnt == NSTEP) begin
                        cnt <= 5'd0;                                              // Next phase starts at step 0
                        if (!dec_r && rnd != 4'd10) cs <= C_MC;                   // Encryption: MixColumns except in the last round
                        else cs <= C_ARK;                                         // Otherwise AddRoundKey
                    end else begin
                        cnt <= cnt + 5'd1;                                        // Next lookup step
                    end
                end
                C_MC: begin
                    if (MC_PAR == 4) begin
                        for (cc = 0; cc < 4; cc = cc + 1) begin
                            st[32*cc +: 32] <= mixcol(dec_r, st[32*cc +: 32]);    // All four columns in one clock
                        end
                    end else begin
                        st[32*cnt[1:0] +: 32] <= mixcol(dec_r, st[32*cnt[1:0] +: 32]); // One column per clock
                    end
                    if (MC_PAR == 4 || cnt == 5'd3) begin
                        cnt <= 5'd0;                                              // Next phase starts at step 0
                        if (dec_r) begin
                            rnd <= rnd - 4'd1;                                    // Decryption: go on with the previous round
                            cs  <= C_SR;                                          // InvShiftRows comes next
                        end else begin
                            cs <= C_ARK;                                          // Encryption: AddRoundKey comes next
                        end
                    end else begin
                        cnt <= cnt + 5'd1;                                        // Next column
                    end
                end
                default: cs <= C_IDLE;                                            // Safety net
            endcase
        end
    end

endmodule
