// tetris_regs.v - register map the RP2350 reads over the Zen Link (user bus, read only)
//   0x140        buttons        bit0 = btn1, bit1 = btn2 (1 = pressed) - for button_test.py
//   0x141        game ID        2 = Tetris (the launcher checks it after loading)
//   0x150..0x168 locked board   25 bytes, cell i = row * 10 + column is bit (i % 8) of byte (i / 8)
//   0x169..0x16A piece mask     16-bit mask of the falling piece's 4x4 box, bit (row * 4 + column), low byte first
//   0x16B        piece x        two's complement, 5 bits
//   0x16C        piece y
//   0x16D..0x16F score          low byte first
//   0x170..0x171 lines          low byte first
//   0x172        level
//   0x173        game over      bit0
//   0x174        {seq[6:0], busy}  changes after every event: read it before and after a block read to detect a torn frame
// One read_block(0x150, 37 bytes) returns everything above in one transfer; the MCU draws the piece onto the board (mcu/frame.py)

`default_nettype none

module tetris_regs (
    input  wire [15:0]  addr,      // user bus address
    input  wire [1:0]   buttons,   // {btn2, btn1} pressed
    input  wire [199:0] board,     // locked cells
    input  wire [15:0]  mask,      // falling piece mask
    input  wire [4:0]   px,        // falling piece column
    input  wire [4:0]   py,        // falling piece row
    input  wire [23:0]  score,     // score
    input  wire [15:0]  lines,     // lines cleared
    input  wire [7:0]   level,     // level
    input  wire         over,      // game over
    input  wire [6:0]   seq,       // event counter
    input  wire         busy,      // core busy
    output reg  [7:0]   rdata      // read data, combinational from addr
);
    // Byte index inside the board
    wire [15:0] foff = addr - 16'h0150;

    // This block selects the byte for the address; unmapped addresses read zero
    always @* begin
        rdata = 8'd0;                                          // default
        if (addr == 16'h0140) rdata = {6'd0, buttons};         // buttons
        if (addr == 16'h0141) rdata = 8'd2;                    // game ID
        if (addr >= 16'h0150 && addr <= 16'h0168)
            rdata = board[8*foff[4:0] +: 8];                   // board byte
        if (addr == 16'h0169) rdata = mask[7:0];               // falling piece
        if (addr == 16'h016A) rdata = mask[15:8];
        if (addr == 16'h016B) rdata = {3'd0, px};
        if (addr == 16'h016C) rdata = {3'd0, py};
        if (addr == 16'h016D) rdata = score[7:0];              // score
        if (addr == 16'h016E) rdata = score[15:8];
        if (addr == 16'h016F) rdata = score[23:16];
        if (addr == 16'h0170) rdata = lines[7:0];              // lines
        if (addr == 16'h0171) rdata = lines[15:8];
        if (addr == 16'h0172) rdata = level;                   // level
        if (addr == 16'h0173) rdata = {7'd0, over};            // game over
        if (addr == 16'h0174) rdata = {seq, busy};             // consistency check
    end
endmodule

`default_nettype wire
