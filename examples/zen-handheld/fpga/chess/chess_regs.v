// chess_regs.v - register map the RP2350 reads over the Zen Link (user bus, read only)
//   0x140                      buttons        bit0 = btn1, bit1 = btn2 (1 = pressed)
//   0x141                      game ID        10 = Chess (the launcher checks it after loading)
//   0x150..0x1527     game state     40 bytes, laid out like pack() of model/chess_game.py
//   0x150+40           {seq[6:0], busy}  changes after every tick: read it before and after a block read to detect a torn frame
// One read_block(0x150, 41 bytes) returns everything in one transfer; the MCU turns it into a line for the display

`default_nettype none

module chess_regs (
    input  wire [15:0]  addr,      // user bus address
    input  wire [1:0]   buttons,   // {btn2, btn1} pressed
    input  wire [40*8-1:0] state,    // game state bytes
    input  wire [6:0]   seq,       // tick counter
    input  wire         busy,      // core busy
    input  wire [31:0]  svc,       // service status {mv_p, mv_t, mv_f, flags}
    output reg  [7:0]   rdata      // read data, combinational from addr
);
    // Byte index of the address inside the state
    wire [15:0] off = addr - 16'h0150;

    // This block selects the byte for the address; unmapped addresses read zero
    always @* begin
        rdata = 8'd0;                                                    // default
        if (addr == 16'h0140) rdata = {6'd0, buttons};                   // buttons
        if (addr == 16'h0141) rdata = 8'd10;                         // game ID
        if (addr >= 16'h01A8 && addr < 16'h01AC) rdata = svc[8*(addr[1:0]) +: 8];   // service status: flags, move from, to, promotion
        if (addr >= 16'h0150 && addr < 16'h0150 + 40) rdata = state[8*off[7:0] +: 8];   // game state
        if (addr == 16'h0150 + 40) rdata = {seq, busy};          // consistency check
    end
endmodule

`default_nettype wire
