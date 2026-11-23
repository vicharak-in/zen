// runner_regs.v - register map the RP2350 reads over the Zen Link (user bus, read only)
//   0x140        buttons        bit0 = btn1, bit1 = btn2 (1 = pressed)
//   0x141        game ID        4 = Chip Runner (the launcher checks it after loading)
//   0x150,0x151  hero x         low byte first (pixels, left edge of the box)
//   0x152        hero y         pixels, top edge of the box
//   0x153        flags          bit0 = on the ground, bit1 = game over, bit2 = won
//   0x154..0x156 score          low byte first
//   0x157        lives
//   0x158        coins collected
//   0x159..0x15C coin flags     32 bits, coin k = bit k of the four bytes (unused bits read 0)
//   0x15D..0x164 enemies        for enemy 0..3: x low byte, then x high bits [2:0] with bit 7 = alive
//   0x165        {seq[6:0], busy}  changes after every tick: read it before and after a block read to detect a torn frame
// One read_block(0x150, 22 bytes) returns everything above in one transfer; the MCU draws the picture (mcu/runner_view.py)

`default_nettype none

module runner_regs #(
    parameter NC = 20            // number of coins
) (
    input  wire [15:0]   addr,      // user bus address
    input  wire [1:0]    buttons,   // {btn2, btn1} pressed
    input  wire [10:0]   hero_x,
    input  wire [7:0]    hero_y,
    input  wire          ground,
    input  wire          over,
    input  wire          won,
    input  wire [23:0]   score,
    input  wire [1:0]    lives,
    input  wire [7:0]    coins,
    input  wire [NC-1:0] coin,
    input  wire [43:0]   ex,
    input  wire [3:0]    alive,
    input  wire [6:0]    seq,       // tick counter
    input  wire          busy,      // core busy
    output reg  [7:0]    rdata      // read data, combinational from addr
);
    // The coin flags padded to 32 bits
    wire [31:0] cp = {{(32-NC){1'b0}}, coin};

    // This block selects the byte for the address; unmapped addresses read zero
    always @* begin
        rdata = 8'd0;                                                    // default
        if (addr == 16'h0140) rdata = {6'd0, buttons};                   // buttons
        if (addr == 16'h0141) rdata = 8'd4;                              // game ID
        if (addr == 16'h0150) rdata = hero_x[7:0];                       // hero
        if (addr == 16'h0151) rdata = {5'd0, hero_x[10:8]};
        if (addr == 16'h0152) rdata = hero_y;
        if (addr == 16'h0153) rdata = {5'd0, won, over, ground};
        if (addr == 16'h0154) rdata = score[7:0];                        // score
        if (addr == 16'h0155) rdata = score[15:8];
        if (addr == 16'h0156) rdata = score[23:16];
        if (addr == 16'h0157) rdata = {6'd0, lives};                     // lives
        if (addr == 16'h0158) rdata = coins;                             // coins
        if (addr == 16'h0159) rdata = cp[7:0];                           // coin flags
        if (addr == 16'h015A) rdata = cp[15:8];
        if (addr == 16'h015B) rdata = cp[23:16];
        if (addr == 16'h015C) rdata = cp[31:24];
        if (addr == 16'h015D) rdata = ex[7:0];                           // enemy 0
        if (addr == 16'h015E) rdata = {alive[0], 4'd0, ex[10:8]};
        if (addr == 16'h015F) rdata = ex[18:11];                         // enemy 1
        if (addr == 16'h0160) rdata = {alive[1], 4'd0, ex[21:19]};
        if (addr == 16'h0161) rdata = ex[29:22];                         // enemy 2
        if (addr == 16'h0162) rdata = {alive[2], 4'd0, ex[32:30]};
        if (addr == 16'h0163) rdata = ex[40:33];                         // enemy 3
        if (addr == 16'h0164) rdata = {alive[3], 4'd0, ex[43:41]};
        if (addr == 16'h0165) rdata = {seq, busy};                       // consistency check
    end
endmodule

`default_nettype wire
