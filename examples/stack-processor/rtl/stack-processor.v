// stack-processor.v - small stack machine, from the Shrike stack_processor example. Every byte the RP2350 sends is one instruction:
//   0x00 nop | 0x1X push the nibble X | 0x20 pop (result returned with the next byte) | 0x30/31/32 push A/B/C | 0x33/34/35 pop into A/B/C | 0xC0..C6 C = A+B, A-B, A*B, A/B, A<<B, A>>B, A asr 1
// The reply to a byte is {empty, full, 2'b00, last popped nibble}, as loaded by the previous pop.
// Ported from the Shrike example (module "top"): the SPI target is replaced by the Zen Link byte port in the board top (rx_data / rx_valid come in, tx_data goes out), the Forge BRAM pads are gone
// (lifo_bram has the RAM inside), and the A, B and C registers are cleared by the reset (they were left undefined in the original).

module stack_processor (
    input  wire       clk,          // Fabric clock
    input  wire       rst_n,        // Reset, active low
    input  wire [7:0] rx_data,      // Instruction byte from the RP2350
    input  wire       rx_valid,     // One clock when rx_data is new
    output reg  [7:0] tx_data,      // Reply for the next byte
    output wire       stack_empty,  // Stack empty flag (for the LED)
    output wire       stack_full    // Stack full flag
);

    // LIFO signals
    reg  [3:0] lifo_din;
    reg        lifo_we;
    reg        lifo_re;
    wire [3:0] lifo_dout;
    wire       lifo_full;
    wire       lifo_empty;
    assign stack_empty = lifo_empty;
    assign stack_full  = lifo_full;

    // This contains the instantiation for the LIFO
    lifo_bram lifo_inst (
        .clk(clk), .nReset(rst_n), .DIN(lifo_din), .WE(lifo_we), .RE(lifo_re), .DOUT(lifo_dout), .LIFO_full(lifo_full), .LIFO_empty(lifo_empty));

    reg rx_valid_d;
    wire spi_rx_pulse;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rx_valid_d <= 1'b0;
        else
            rx_valid_d <= rx_valid;
    end
    assign spi_rx_pulse = rx_valid & ~rx_valid_d;

    // -----------------------------------------------------------------
    // Processor Logic
    // -----------------------------------------------------------------
    
    reg [2:0] cnt;
    reg [7:0] A, B, C;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lifo_we      <= 1'b0;
            lifo_re      <= 1'b0;
            lifo_din     <= 4'b0;
            tx_data  <= 8'b0;
            cnt <= 0;
            A <= 8'd0;
            B <= 8'd0;
            C <= 8'd0;
        end else begin
            lifo_we      <= 1'b0;
            lifo_re      <= 1'b0;

            if (spi_rx_pulse) begin
                casez (rx_data)
                    8'b0000_0000: C <= C; 

                    8'b0001_????: begin
                        lifo_din <= rx_data[3:0];
                        lifo_we <= 1'b1;
                    end

                    8'b0010_0000: begin 
                        cnt <= 3'b1;
                        lifo_re <= 1'b1;
                    end

                    8'b0011_0000: begin
                        lifo_din <= A[3:0];
                        lifo_we <= 1'b1;
                    end

                    8'b0011_0001: begin
                        lifo_din <= B[3:0];
                        lifo_we <= 1'b1;
                    end

                    8'b0011_0010: begin
                        lifo_din <= C[3:0];
                        lifo_we <= 1'b1;
                    end

                    8'b0011_0011: begin 
                        cnt <= 3'b1;
                        lifo_re <= 1'b1;
                    end

                    8'b0011_0100: begin 
                        cnt <= 3'b1;
                        lifo_re <= 1'b1;
                    end

                    8'b0011_0101: begin 
                        cnt <= 3'b1;
                        lifo_re <= 1'b1;
                    end

                    8'b1100_0000: C <= A + B;
                    8'b1100_0001: C <= A - B;
                    8'b1100_0010: C <= A * B;
                    8'b1100_0011: C <= A / B;
                    8'b1100_0100: C <= A << B;
                    8'b1100_0101: C <= A >> B;
                    8'b1100_0110: C <= {A[7], A[7:1]};

                    default: C <= C;
                endcase
            end

            if (cnt != 3'b000) begin
                cnt <= cnt + 1;
                if (cnt == 3'b100) begin 
                    case (rx_data)
                        8'b0010_0000 : tx_data <= {lifo_empty, lifo_full, 2'b00, lifo_dout};
                        8'b0011_0011 : A <= {4'b0000, lifo_dout}; 
                        8'b0011_0100 : B <= {4'b0000, lifo_dout}; 
                        8'b0011_0101 : C <= {4'b0000, lifo_dout}; 
                        default: tx_data <= {lifo_empty, lifo_full, 2'b00, lifo_dout};
                    endcase    
                    cnt <= 3'b0;
                end
            end
        end
    end
  
endmodule
