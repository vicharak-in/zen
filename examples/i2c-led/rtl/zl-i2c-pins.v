// zl-i2c-pins.v - Zen Link to I2C wires adapter: the RP2350 drives and reads SCL and SDA of an unchanged I2C slave core through two Zen Link registers.
// The I2C lines are open drain: a set "pull low" bit holds the line low, a clear bit releases it. The slave core may also pull SDA low (slave_sda_oe).
//
// Registers on the Zen Link user bus (BASE = 0x100):
//   BASE+0  LINES   write: bit0 = pull SCL low, bit1 = pull SDA low (0 releases the line).  read: bit0 = SCL level, bit1 = SDA level (what the slave sees)
// Reset releases both lines.

module zl_i2c_pins #(
    parameter [15:0] BASE = 16'h0100   // Register address on the user bus
) (
    input  wire        clk,           // Zen Link clock
    input  wire        rst_n,         // Reset, active low
    input  wire [15:0] usr_addr,      // Zen Link user bus address
    input  wire        usr_wr,        // Write strobe
    input  wire [7:0]  usr_wdata,     // Write data
    input  wire        usr_rd,        // Read strobe (unused)
    output reg  [7:0]  usr_rdata,     // Read data (combinational from usr_addr)
    output wire        scl,           // SCL line level, to the slave core
    output wire        sda,           // SDA line level, to the slave core
    input  wire        slave_sda_oe   // The slave core pulls SDA low when high
);

    // Master pulls
    reg scl_low = 1'b0, sda_low = 1'b0;
    // Register hit
    wire hit = (usr_addr == BASE);

    // Open-drain lines: low if anybody pulls low
    assign scl = ~scl_low;
    assign sda = ~(sda_low | slave_sda_oe);

    // Register write
    always @(posedge clk) begin
        if (!rst_n) begin
            scl_low <= 1'b0;
            sda_low <= 1'b0;
        end else if (usr_wr && hit) begin
            scl_low <= usr_wdata[0];
            sda_low <= usr_wdata[1];
        end
    end

    // Read multiplexer
    always @* begin
        usr_rdata = 8'd0;
        if (hit) usr_rdata = {6'd0, sda, scl};
    end

endmodule
