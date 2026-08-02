`timescale 1 ps / 1 ps

// =============================================================================
// make_file.v - captures output video frames to hex text files
//
// SIMULATION ONLY. This module uses $fopen/$fwrite/$system and is NOT
// synthesizable - it is the testbench's observation path, not part of the
// design that goes to hardware. On hardware the equivalent job is done by a
// real video sink (display controller) or by reading frames back over JTAG.
//
// Two modes:
//   MULTI_FRAME=0 (default, legacy) - one frame into FILE_NAME, file closed on
//       frame_done. Existing single-frame flows are unchanged.
//   MULTI_FRAME=1 - creates OUT_DIR and writes EVERY captured frame to its own
//       file OUT_DIR/frame_0000.txt, frame_0001.txt, ... up to MAX_FRAMES.
//       This is what a frame-rate-conversion test needs: with a per-frame tag
//       in the video, the sequence of files directly shows which input frames
//       were dropped (missing tags) or repeated (duplicated tags).
// =============================================================================

module make_file #(
    parameter IMG_H       = 1080,
    parameter IMG_W       = 1920,
    parameter IS_FULL     = 1,      // 1: Full mode, 0: Lite mode
    parameter SKIP_ROWS   = 0,      // hidden guard rows discarded at top of frame
    parameter FILE_NAME   = "output_data.txt",
    parameter MULTI_FRAME = 0,      // 1 = one file per frame in OUT_DIR
    parameter OUT_DIR     = "frames",
    parameter MAX_FRAMES  = 32      // stop opening new files past this many
)(
    input wire        clk,
    input wire        reset,

    input wire        tready,
    input wire [23:0] tdata,
    input wire        tvalid,
    input wire        tlast,
    input wire [2:0]  tuser,

    output wire       frame_done,
    output reg [31:0] frames_captured
);

    wire write_flag, error;

    // --- Instantiate Frame Controller ---
    frame_controller #(
        .IMG_H(IMG_H),
        .IMG_W(IMG_W),
        .IS_FULL(IS_FULL),
        .SKIP_ROWS(SKIP_ROWS)
    ) controller (
        .clk        (clk),
        .reset      (reset),

        .tdata      (tdata),
        .tvalid     (tvalid),
        .ready      (tready),
        .last       (tlast),
        .tuser      (tuser),

        .frame_done (frame_done),
        .write_flag (write_flag),
        .error      (error)
    );

    integer fd;

    // Build "<OUT_DIR>/frame_NNNN.txt" for a given index.
    function automatic string frame_path(int idx);
        // NB: "%04d" SPACE-pads in Questa ("frame_   0.txt"), so pad by hand.
        return $sformatf("%s/frame_%0d%0d%0d%0d.txt", OUT_DIR,
                         (idx/1000)%10, (idx/100)%10, (idx/10)%10, idx%10);
    endfunction

    initial begin
        frames_captured = 32'd0;
        if (MULTI_FRAME) begin
            // $fopen cannot create directories, so make it first. Clear any
            // frames from a previous run so a short run cannot be misread as a
            // long one by leaving stale files behind.
            $system($sformatf("rm -rf %s && mkdir -p %s", OUT_DIR, OUT_DIR));
            fd = $fopen(frame_path(0), "w");
            if (fd == 0) begin
                $display("Error: could not open %s for writing.", frame_path(0));
                $finish;
            end
            $display("[MODULE] Multi-frame capture -> %s/frame_NNNN.txt (max %0d)",
                     OUT_DIR, MAX_FRAMES);
        end else begin
            fd = $fopen(FILE_NAME, "w");
            if (fd == 0) begin
                $display("Error: Could not open file %s for writing.", FILE_NAME);
                $finish;
            end
        end
    end

    // --- File Writing Logic ---
    always @(posedge clk) begin
        if (write_flag && fd != 0) begin
            $fwrite(fd, "%h ", tdata);
            if (tlast) $fwrite(fd, "\n");
        end
    end

    // --- Housekeeping on frame completion ---
    // frame_done is a LATCHED LEVEL in frame_controller (set when the frame
    // completes, cleared only at the next SOF) - NOT a pulse. Triggering on the
    // level fires every clock it is high, which creates a burst of empty files
    // and inflates frames_captured. Edge-detect it.
    reg frame_done_d;
    always @(posedge clk) frame_done_d <= frame_done;
    wire frame_done_rise = frame_done && !frame_done_d;

    always @(posedge clk) begin
        if (frame_done_rise) begin
            if (fd != 0) $fclose(fd);
            fd = 0;
            frames_captured = frames_captured + 1;

            if (!MULTI_FRAME) begin
                $display("[MODULE] Frame Done detected for %s. Closing file.", FILE_NAME);
            end else begin
                $display("[MODULE] Captured frame %0d -> %s",
                         frames_captured - 1, frame_path(frames_captured - 1));
                if (frames_captured < MAX_FRAMES) begin
                    fd = $fopen(frame_path(frames_captured), "w");
                    if (fd == 0)
                        $display("Error: could not open %s", frame_path(frames_captured));
                end else begin
                    $display("[MODULE] MAX_FRAMES=%0d reached - stopping capture.", MAX_FRAMES);
                end
            end
        end
    end

    // --- Broken/short frame: discard what was written and restart this frame ---
    always @(posedge clk) begin
        if (error) begin
            $display("Error %s. Restarting current frame file.",
                     MULTI_FRAME ? frame_path(frames_captured) : FILE_NAME);
            if (fd != 0) $fclose(fd);
            fd = $fopen(MULTI_FRAME ? frame_path(frames_captured) : FILE_NAME, "w");
            if (fd == 0) begin
                $display("Error: Could not reopen capture file for writing.");
                $finish;
            end
            $fwrite(fd, "%h ", tdata);
        end
    end

endmodule
