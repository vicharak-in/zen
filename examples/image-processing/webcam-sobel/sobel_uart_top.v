// sobel_uart_top.v - Sobel filter over a UART with the picture size chosen per frame.
// Frame from the host: 0xA5, width (2 bytes, little endian), height (2 bytes), then width*height gray bytes row by row.
// Bytes after the frame are ignored until the next 0xA5 header. Allowed sizes: 3 <= width <= MAXW, 3 <= height <= 1023.
// Result: width*height bytes: the 1-pixel border is 0, inner pixels are min(255, |Gx| + |Gy|).
// If a header or frame stalls for TIMEOUT clocks half way, it is dropped (and any pending result bytes) so the host can resend.
// The result lags the input by one line, so after the last input byte the design feeds itself W+1 zero pixels.

`default_nettype none

module sobel_uart_top #(
    parameter MAXW         = 640,           // widest picture
    parameter CLKS_PER_BIT = 8,             // clock / baud (25 MHz / 3.125 Mbaud)
    parameter TIMEOUT      = 2500000        // clocks of silence that drop a half-sent frame (100 ms at 25 MHz)
) (
    input  wire clk,                        // clock
    input  wire rst,                        // synchronous reset, active high
    input  wire rx,                         // UART input from the host
    output wire tx,                         // UART output to the host
    output wire frame_done,                 // one-clock pulse: the last pixel of a frame was processed
    output wire rx_seen                     // one-clock pulse: a byte was received
);

    // Width of the column counter in the core.
    localparam AW = $clog2(MAXW);

    // Byte from the receiver.
    wire [7:0]  rx_data;
    // One-clock pulse from the receiver.
    wire        rx_valid;
    // The Sobel core accepts a step.
    wire        core_ready;
    // The next pixel is the last one of the frame.
    wire        core_last;
    // Result byte pulse from the Sobel core.
    wire        core_valid;
    // Result byte from the Sobel core.
    wire [7:0]  core_data;
    // The transmitter is sending a byte.
    wire        tx_busy;
    // Header state: 0 wait for 0xA5, 1 width low, 2 width high, 3 height low, 4 height high.
    reg  [2:0]  hst;
    // Picture width of the current frame.
    reg  [15:0] wreg;
    // Picture height of the current frame.
    reg  [15:0] hreg;
    // Receiving the pixels of a frame.
    reg         in_frame;
    // One-clock start pulse for the core (the cycle after the header is accepted).
    reg         start_r;
    // Feeding zeros to push out the last results.
    reg         flushing;
    // Zero pixels still to feed.
    reg  [15:0] flush_left;
    // Clocks of silence in a half-sent header or frame.
    reg  [23:0] tmo;
    // Result FIFO storage.
    reg  [7:0]  fifo [0:31];
    // FIFO write pointer.
    reg  [4:0]  wp;
    // FIFO read pointer.
    reg  [4:0]  rp;
    // FIFO fill level.
    reg  [5:0]  cnt;

    // Height as it would be once the last header byte arrives.
    wire [15:0] hnew     = {rx_data, hreg[7:0]};
    // The announced size is allowed.
    wire        dims_ok  = (wreg >= 16'd3) && (wreg <= MAXW) && (hnew >= 16'd3) && (hnew <= 16'd1023);
    // Room for more results (the FIFO is far from full).
    wire        fifo_room = (cnt < 6'd16);
    // A received byte is a header byte.
    wire        hdr_step = rx_valid & ~in_frame & ~flushing;
    // A received pixel goes into the core.
    wire        rx_step  = rx_valid & in_frame;
    // A zero pixel goes into the core while flushing, paced by the FIFO room.
    wire        fl_step  = flushing & (flush_left != 16'd0) & core_ready & fifo_room;
    // Any step.
    wire        step     = rx_step | fl_step;
    // The pixel for this step.
    wire [7:0]  pix      = flushing ? 8'd0 : rx_data;
    // All zero pixels were fed and the core is finished: the frame is complete.
    wire        fin      = flushing & (flush_left == 16'd0) & core_ready;
    // A header or frame stalled half way for too long.
    wire        abort    = ~flushing & (in_frame | (hst != 3'd0)) & (tmo == TIMEOUT);
    // Pop a result byte whenever the transmitter is free.
    wire        pop      = ~tx_busy & (cnt != 6'd0);

    // Report the end of a frame.
    assign frame_done = fin;
    // Report received bytes.
    assign rx_seen    = rx_valid;

    // Frame control: parse the header, count the flush, drop stalled frames.
    always @(posedge clk) begin
        // The start pulse lasts one clock.
        start_r <= 1'b0;
        // Reset.
        if (rst) begin
            // Waiting for a header.
            hst        <= 3'd0;
            // No frame.
            in_frame   <= 1'b0;
            // Not flushing.
            flushing   <= 1'b0;
            // Nothing to flush.
            flush_left <= 16'd0;
            // No silence yet.
            tmo        <= 24'd0;
        end else if (fin | abort) begin
            // Waiting for a header.
            hst        <= 3'd0;
            // No frame.
            in_frame   <= 1'b0;
            // Done flushing.
            flushing   <= 1'b0;
            // No silence yet.
            tmo        <= 24'd0;
        end else begin
            // Count the silence inside a header or frame.
            if ((in_frame | (hst != 3'd0)) & ~flushing & ~rx_valid) tmo <= tmo + 24'd1;
            // A byte arrived: silence restarts.
            if (rx_valid) tmo <= 24'd0;
            // Header bytes.
            if (hdr_step) begin
                // Header state dispatch.
                case (hst)
                    // Wait for the sync byte.
                    3'd0: if (rx_data == 8'hA5) hst <= 3'd1;
                    // Width low byte.
                    3'd1: begin wreg[7:0]  <= rx_data; hst <= 3'd2; end
                    // Width high byte.
                    3'd2: begin wreg[15:8] <= rx_data; hst <= 3'd3; end
                    // Height low byte.
                    3'd3: begin hreg[7:0]  <= rx_data; hst <= 3'd4; end
                    // Height high byte: accept the frame if the size is allowed.
                    default: begin
                        // Keep the height.
                        hreg[15:8] <= rx_data;
                        // Back to waiting for a header.
                        hst        <= 3'd0;
                        // Allowed size: start the frame.
                        if (dims_ok) begin
                            // Receive pixels now.
                            in_frame <= 1'b1;
                            // Tell the core.
                            start_r  <= 1'b1;
                        end
                    end
                endcase
            end
            // The last pixel of the frame arrived: start the flush.
            if (rx_step && core_last) begin
                // No more pixels from the host.
                in_frame   <= 1'b0;
                // Feed zeros.
                flushing   <= 1'b1;
                // One line plus one pixel of zeros.
                flush_left <= wreg + 16'd1;
            end
            // One zero pixel fed.
            if (fl_step) flush_left <= flush_left - 16'd1;
        end
    end

    // Result FIFO: the core pushes, the UART transmitter pops. A stalled frame also empties it.
    always @(posedge clk) begin
        // Reset or drop.
        if (rst | abort) begin
            // Empty.
            wp  <= 5'd0;
            rp  <= 5'd0;
            cnt <= 6'd0;
        end else begin
            // Store a new result.
            if (core_valid) begin
                // Write the byte.
                fifo[wp] <= core_data;
                // Next slot.
                wp <= wp + 5'd1;
            end
            // Take a byte out.
            if (pop) rp <= rp + 5'd1;
            // Update the fill level.
            cnt <= cnt + core_valid - pop;
        end
    end

    // This contains the instantiation for uart_rx
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk   (clk),
        .rst   (rst),
        .rx    (rx),
        .data  (rx_data),
        .valid (rx_valid)
    );

    // This contains the instantiation for sobel_core
    sobel_core #(.MAXW(MAXW)) u_core (
        .clk       (clk),
        .rst       (rst),
        .start     (start_r),
        .step      (step),
        .pix_in    (pix),
        .w_m1      (wreg[AW-1:0] - 1'b1),
        .h_m1      (hreg - 16'd1),
        .ready     (core_ready),
        .last      (core_last),
        .out_valid (core_valid),
        .out_data  (core_data)
    );

    // This contains the instantiation for uart_tx
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk  (clk),
        .rst  (rst),
        .data (fifo[rp]),
        .send (pop),
        .tx   (tx),
        .busy (tx_busy)
    );

endmodule

`default_nettype wire
