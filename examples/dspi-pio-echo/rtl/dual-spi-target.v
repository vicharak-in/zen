// dual-spi-target.v - Dual-SPI target FSM from the Shrike dspi_pio_echo example, unchanged: 4 clocks x 2 bits in, a turnaround clock, 4 clocks x 2 bits out.
// The SCK and chip-select inputs are synchronised inside; o_dual_oe is 2'b11 while the target drives the data lines.

module dual_spi_target (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_ss_n,
    input  wire       i_sck,
    
    input  wire [1:0] i_dual_rx,
    output reg  [1:0] o_dual_tx,
    output reg  [1:0] o_dual_oe,
    
    output reg  [7:0] o_rx_data,
    output reg        o_rx_data_valid,
    input  wire [7:0] i_tx_data
);

    localparam STATE_IDLE = 4'd0;
    localparam STATE_RX_1 = 4'd1;
    localparam STATE_RX_2 = 4'd2;
    localparam STATE_RX_3 = 4'd3;
    localparam STATE_RX_4 = 4'd4;
    localparam STATE_TURN = 4'd5;
    localparam STATE_TX_1 = 4'd6;
    localparam STATE_TX_2 = 4'd7;
    localparam STATE_TX_3 = 4'd8;
    localparam STATE_TX_4 = 4'd9;

    reg [3:0] state;

    reg [2:0] sck_sync, cs_sync;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            sck_sync <= 3'b000;
            cs_sync  <= 3'b111;
        end else begin
            sck_sync <= {sck_sync[1:0], i_sck};
            cs_sync  <= {cs_sync[1:0], i_ss_n};
        end
    end

    wire sck_rising = (sck_sync[2:1] == 2'b01);
    wire cs_active  = ~cs_sync[1]; 

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= STATE_IDLE;
            o_dual_oe <= 2'b00;
            o_rx_data <= 8'h00;
            o_rx_data_valid <= 1'b0;
            o_dual_tx <= 2'b00;
        end else begin
            o_rx_data_valid <= 1'b0; 

            if (!cs_active) begin
                state <= STATE_IDLE;
                o_dual_oe <= 2'b00; 
            end else if (sck_rising) begin
                case (state)
                    STATE_IDLE: begin state <= STATE_RX_1; o_rx_data[7:6] <= i_dual_rx; end
                    STATE_RX_1: begin state <= STATE_RX_2; o_rx_data[5:4] <= i_dual_rx; end
                    STATE_RX_2: begin state <= STATE_RX_3; o_rx_data[3:2] <= i_dual_rx; end
                    STATE_RX_3: begin state <= STATE_RX_4; o_rx_data[1:0] <= i_dual_rx; end
                    STATE_RX_4: begin
                        state <= STATE_TURN;
                        o_dual_oe <= 2'b11;        
                        o_rx_data_valid <= 1'b1;     
                    end
                    STATE_TURN: begin state <= STATE_TX_1; o_dual_tx <= i_tx_data[7:6]; end
                    STATE_TX_1: begin state <= STATE_TX_2; o_dual_tx <= i_tx_data[5:4]; end
                    STATE_TX_2: begin state <= STATE_TX_3; o_dual_tx <= i_tx_data[3:2]; end
                    STATE_TX_3: begin state <= STATE_TX_4; o_dual_tx <= i_tx_data[1:0]; end
                    STATE_TX_4: begin state <= STATE_IDLE; o_dual_oe <= 2'b00; end
                    default:    begin state <= STATE_IDLE; o_dual_oe <= 2'b00; end
                endcase
            end
        end
    end
endmodule