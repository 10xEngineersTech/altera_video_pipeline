`timescale 1 ns / 1 ps

module frame_controller #(
    parameter IMG_H   = 1080,
    parameter IMG_W   = 1920,
    parameter IS_FULL = 1,     // 1: Full mode, 0: Lite mode
    // Real hardware rows to capture-but-discard at the start of every frame,
    // before the IMG_H visible rows. Used by PIP: the mixer has a one-time
    // settling artifact on the very first row it composites in a field; the
    // caller configures SKIP_ROWS hidden guard rows above the real content
    // (background canvas + offset both grown by SKIP_ROWS) so the glitchy
    // row is never part of what gets written out.
    parameter SKIP_ROWS = 0
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [23:0] tdata,
    input  wire        tvalid,
    input  wire        ready,
    input  wire        last,
    input  wire [2:0]  tuser,

    output wire        write_flag,
    output reg         frame_done,
    output reg         error
);

    reg [15:0] pixel_count;
    reg [15:0] line_count;
    reg        sof;

    // Transaction handshake
    wire transfer_active = tvalid && ready;

    // SOF detection
    // Full mode: tuser[0]=SOF, tuser[1]=metapacket (skip metapackets)
    // Lite mode: tuser[0]=SOF
    wire is_metapacket  = (IS_FULL == 1) && tuser[1];
    wire start_of_frame = transfer_active && tuser[0] && !is_metapacket;

    // Active when inside a valid frame (not a metapacket)
    wire frame_active = transfer_active && sof && !frame_done && !is_metapacket;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_count <= 0;
            line_count  <= 0;
            frame_done  <= 1'b0;
            sof         <= 1'b0;
            error       <= 1'b0;
        end else begin
            error <= 1'b0;

            if (start_of_frame) begin
                // Auto-reset on every SOF - handles flush frames cleanly.
                // pixel_count=0 so SOF pixel IS captured by write_flag.
                sof         <= 1'b1;
                frame_done  <= 1'b0;
					 pixel_count <= 0;
					 line_count  <= 0;
					 
					 if(pixel_count != 0 || line_count != 0) error <= 1'b1;
            end else if (frame_active) begin
                if (last) begin
                    pixel_count <= 0;
                    if (line_count == (IMG_H + SKIP_ROWS - 1)) begin
                        frame_done <= 1'b1;
                        sof        <= 1'b0;
                        // MUST reset: without it line_count stays at IMG_H-1
                        // into the next frame's SOF, where the sanity check
                        // below reads it as a broken frame and raises `error`.
                        // make_file's error handler reopens the capture file
                        // with "w", truncating away the pixel just written -
                        // which silently corrupted every frame after the first.
                        line_count <= 0;
                    end else begin
                        line_count <= line_count + 1;
                    end
                end else begin
                    pixel_count <= pixel_count + 1;
                end
            end
        end
    end

    // write_flag: capture pixel when handshake active, inside frame,
    // not done, within bounds, not a metapacket, and past the discarded
    // SKIP_ROWS guard rows at the top of the frame.
    // start_of_frame must OVERRIDE frame_done. frame_done is still set from the
    // PREVIOUS frame on the SOF cycle - it is cleared by a non-blocking
    // assignment that only lands next cycle - so gating the SOF pixel on
    // !frame_done silently dropped the first pixel of every frame after the
    // first. That shifted the whole raster by one pixel and cost the last
    // pixel of the frame, which showed up as visibly offset/clipped images.
    assign write_flag = ((frame_active && !frame_done) || start_of_frame) &&
                        (pixel_count < IMG_W) &&
                        (line_count  >= SKIP_ROWS) &&
                        (line_count  < (IMG_H + SKIP_ROWS));

endmodule
