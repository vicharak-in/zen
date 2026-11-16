// chess_game.v - the Chess core plus its timers: one game tick every 33 ms, a pause after the start (and after a lost life), the restart after game over

`default_nettype none

module chess_game (
    input  wire         clk,        // fabric clock
    input  wire         rst,        // synchronous reset
    input  wire         tick,       // one-clock pulse every millisecond
    input  wire         a_held,     // button A held
    input  wire         b_held,     // button B held
    output wire         busy,       // core busy
    output wire         over,       // game over
    output wire [40*8-1:0] state,  // state bytes for the register map
    input  wire         u_wr,       // user bus write strobe
    input  wire [15:0]  u_addr,     // user bus address
    input  wire [7:0]   u_wdata,    // user bus write data
    output wire [31:0]  svc_o       // service status for the RP2350
);
    // Pulses into the core
    reg  ev_tick = 1'b0;
    reg  restart = 1'b0;
    // Core pulse back: a pause is wanted (lost life)
    wire hold_p;
    // Milliseconds since the last game tick, remaining pause and the game over time
    reg [6:0]  tcnt = 7'd0;
    reg [10:0] hold = 11'd1000;
    reg [11:0] ocnt = 12'd0;
    // One game tick lasts 33 ms
    localparam [6:0] TICK_MS = 7'd33;
    // A pause of one second at the start and after every lost life, so the player can see the start
    localparam [10:0] HOLD_MS = 11'd1000;
    // Game over lasts 3 seconds, then a new game starts
    localparam [11:0] OVER_MS = 12'd3000;

    // This block counts milliseconds for the tick, the pause and the restart
    always @(posedge clk) begin
        ev_tick <= 1'b0;                                   // pulses are one clock long
        restart <= 1'b0;
        if (rst || restart) begin
            tcnt <= 7'd0; hold <= HOLD_MS; ocnt <= 12'd0;
        end else begin
            if (hold_p) hold <= HOLD_MS;                   // pause after a lost life
            if (tick) begin
                if (hold != 11'd0) begin
                    hold <= hold - 11'd1;                  // paused: nothing moves
                    tcnt <= 7'd0;
                end else if (tcnt + 7'd1 >= TICK_MS) begin
                    tcnt <= 7'd0;
                    ev_tick <= 1'b1;                       // one game tick
                end else begin
                    tcnt <= tcnt + 7'd1;
                end
                if (over) begin
                    if (ocnt == OVER_MS - 12'd1) begin ocnt <= 12'd0; restart <= 1'b1; end else ocnt <= ocnt + 12'd1;
                end else begin
                    ocnt <= 12'd0;
                end
            end
        end
    end

    // This contains the instantiation for the Chess core
    chess_core u_core (
        .clk(clk), .rst(rst), .restart(restart), .ev_tick(ev_tick), .a_in(a_held), .b_in(b_held),
        .busy(busy), .over(over), .hold_p(hold_p), .state_o(state),
        .u_wr(u_wr), .u_addr(u_addr), .u_wdata(u_wdata), .svc_o(svc_o)
    );
endmodule

`default_nettype wire
