// uart-tx.v - simple 8N1 UART transmitter (Shrike example, logic unchanged). The reset is asynchronous and active low.
// Initial values were added on the registers so the line idles high from configuration on.

 
module uart_tx #(
    parameter CLKS_PER_BIT = 434)
(
    input       rst,
    input       clk,
    input       i_TX_DV,
    input [7:0] i_TX_Byte, 
    output reg  o_TX_Active = 1'b0,
    output reg  o_TX_Serial = 1'b1,
    output reg  o_TX_Done = 1'b0
);

localparam IDLE         = 3'b000;
localparam TX_START_BIT = 3'b001;
localparam TX_DATA_BITS = 3'b010;
localparam TX_STOP_BIT  = 3'b011;
localparam CLEANUP      = 3'b100;

reg [2:0] state = 3'b000;
reg [$clog2(CLKS_PER_BIT):0] clk_cnt = 0;
reg [2:0] bit_index_cnt = 3'd0;
reg [7:0] r_TX_Data = 8'd0;


// Purpose: Control TX state machine
always @(posedge clk or negedge rst) begin
    if (~rst) begin
        state <= 3'b000;
    end else begin
        o_TX_Done <= 1'b0; // default assignment

        case (state)
            IDLE : begin
                o_TX_Serial   <= 1'b1; // Drive Line High for Idle
                clk_cnt <= 0;
                bit_index_cnt   <= 0;

                if (i_TX_DV == 1'b1) begin
                    o_TX_Active <= 1'b1;
                    r_TX_Data   <= i_TX_Byte;
                    state   <= TX_START_BIT;
                end else begin
                    state <= IDLE;
                end
            end

            // Send out Start Bit. Start bit = 0
            TX_START_BIT : begin
                o_TX_Serial <= 1'b0;

                // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
                if (clk_cnt < CLKS_PER_BIT-1) begin
                    clk_cnt <= clk_cnt + 1;
                    state     <= TX_START_BIT;
                end else begin
                    clk_cnt <= 0;
                    state     <= TX_DATA_BITS;
                end
            end

            // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
            TX_DATA_BITS : begin
                o_TX_Serial <= r_TX_Data[bit_index_cnt];

                if (clk_cnt < CLKS_PER_BIT-1) begin
                    clk_cnt <= clk_cnt + 1;
                    state     <= TX_DATA_BITS;
                end else begin
                    clk_cnt <= 0;

                    // Check if we have sent out all bits
                    if (bit_index_cnt < 7) begin
                        bit_index_cnt <= bit_index_cnt + 1;
                        state   <= TX_DATA_BITS;
                    end else begin
                        bit_index_cnt <= 0;
                        state   <= TX_STOP_BIT;
                    end
                end
            end

            // Send out Stop bit.  Stop bit = 1
            TX_STOP_BIT : begin
                o_TX_Serial <= 1'b1;

                // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if (clk_cnt < CLKS_PER_BIT-1) begin
                    clk_cnt <= clk_cnt + 1;
                    state     <= TX_STOP_BIT;
                end else begin
                    o_TX_Done     <= 1'b1;
                    clk_cnt <= 0;
                    state     <= CLEANUP;
                    o_TX_Active   <= 1'b0;
                end
            end

            // Stay here 1 clock
            CLEANUP : begin
                state <= IDLE;
            end

            default : begin
                state <= IDLE;
            end
        endcase
    end
end

endmodule