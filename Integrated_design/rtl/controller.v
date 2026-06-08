`timescale 1 ns / 1 ps

module frame_controller #(
    parameter IMG_H   = 1080,
    parameter IMG_W   = 1920,
    parameter IS_FULL = 1      // 1: Full mode, 0: Lite mode
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
            end else if (frame_active) begin
                if (last) begin
                    pixel_count <= 0;
                    if (line_count == (IMG_H - 1)) begin
                        frame_done <= 1'b1;
                        sof        <= 1'b0;
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
    // not done, within bounds, not a metapacket
    assign write_flag = (frame_active || start_of_frame) && !frame_done &&
                        (pixel_count < IMG_W) &&
                        (line_count  < IMG_H);

endmodule
