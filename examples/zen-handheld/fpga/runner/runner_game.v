// runner_game.v - the platformer core plus its timers: one game tick every 33 ms (30 per second), a pause after the start, the restart after game over

`default_nettype none

module runner_game #(
    parameter NC = 20            // number of coins (same as the core)
) (
    input  wire          clk,        // fabric clock
    input  wire          rst,        // synchronous reset
    input  wire          tick,       // one-clock pulse every millisecond
    input  wire          a_held,     // button A held (jump)
    input  wire          b_held,     // button B held (stand still)
    output wire          busy,       // core busy
    output wire          over,       // game over
    output wire          won,        // the flag was reached
    output wire [10:0]   hero_x,
    output wire [7:0]    hero_y,
    output wire          ground,
    output wire [43:0]   ex,
    output wire [3:0]    alive,
    output wire [NC-1:0] coin,
    output wire [23:0]   score,
    output wire [1:0]    lives,
    output wire [7:0]    coins
);
    // Pulses into the core
    reg  ev_tick = 1'b0;
    reg  restart = 1'b0;
    // Core pulse back
    wire reset_p;
    // Milliseconds since the last game tick, remaining pause and the game over time
    reg [5:0]  tcnt = 6'd0;
    reg [10:0] hold = 11'd1000;
    reg [11:0] ocnt = 12'd0;
    // One game tick lasts 33 ms (about 30 per second)
    localparam [5:0] TICK_MS = 6'd33;
    // A pause of one second at the start and after every lost life, so the player can see the start
    localparam [10:0] HOLD_MS = 11'd1000;
    // Game over lasts 3 seconds, then a new game starts
    localparam [11:0] OVER_MS = 12'd3000;

    // This block counts milliseconds for the tick, the pause and the restart
    always @(posedge clk) begin
        ev_tick <= 1'b0;                                   // pulses are one clock long
        restart <= 1'b0;
        if (rst || restart) begin
            tcnt <= 6'd0; hold <= HOLD_MS; ocnt <= 12'd0;
        end else begin
            if (reset_p) hold <= HOLD_MS;                  // pause after a lost life
            if (tick) begin
                if (hold != 11'd0) begin
                    hold <= hold - 11'd1;                  // paused: nothing moves
                    tcnt <= 6'd0;
                end else if (tcnt + 6'd1 >= TICK_MS) begin
                    tcnt <= 6'd0;
                    ev_tick <= 1'b1;                       // one game tick
                end else begin
                    tcnt <= tcnt + 6'd1;
                end
                if (over) begin
                    if (ocnt == OVER_MS - 12'd1) begin ocnt <= 12'd0; restart <= 1'b1; end else ocnt <= ocnt + 12'd1;
                end else begin
                    ocnt <= 12'd0;
                end
            end
        end
    end

    // This contains the instantiation for the platformer core
    runner_core #(.NC(NC)) u_core (
        .clk(clk), .rst(rst), .restart(restart), .ev_tick(ev_tick), .a_in(a_held), .b_in(b_held),
        .busy(busy), .over(over), .won(won), .hero_x(hero_x), .hero_y(hero_y), .ground(ground),
        .ex_o(ex), .alive_o(alive), .coin_o(coin), .score(score), .lives(lives), .coins(coins), .reset_p(reset_p)
    );
endmodule

`default_nettype wire
