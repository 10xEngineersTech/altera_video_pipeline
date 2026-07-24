`timescale 1 ns / 1 ps

// =============================================================================
// tb.v - Universal Testbench
//
// out_tready=1 set immediately after reset so pipeline drains freely
// during ST_POLL_CSC (prevents CSC deadlock in packaged design).
//
// frame_controller now auto-resets on every SOF so no cap_reset needed.
// First SOF after ST_WORKING is always a clean capture.
//
// Output protocol:
//   IS_FULL=0 (Lite): FULL, SCALER_ONLY, CLIP_SCL  (have PC0)
//   IS_FULL=1 (Full): CSC_ONLY, CRS_ONLY, CRS_CSC, DIL_ONLY (no PC0)
// =============================================================================

module tb();
    `include "../app/configuration.vh"

    // =========================================================================
    // Change these per test
    // =========================================================================
    localparam TOPOLOGY    = "CRS_ONLY";   // FULL/SCALER_ONLY/CSC_ONLY/CRS_ONLY/CRS_CSC/CLIP_SCL/DIL_ONLY
    localparam ENABLE_PIP  = PIP_ENABLE;      // from configuration.vh (GUI-controlled)

    // =========================================================================
    // Geometry from configuration.vh
    // =========================================================================
    localparam IMG_WIDTH    = TPG_WIDTH;
    localparam IMG_HEIGHT   = TPG_HEIGHT;
    localparam IMG_L_OFF    = CLIPPER_LEFT;
    localparam IMG_T_OFF    = CLIPPER_TOP;
    localparam IMG_R_OFF    = CLIPPER_RIGHT;
    localparam IMG_B_OFF    = CLIPPER_BOTTOM;
    localparam SCALER_OUT_W = SCALER_WIDTH;
    localparam SCALER_OUT_H = SCALER_HEIGHT;

    // PIP: background canvas bigger than the pipeline's own output, so the
    // pipeline video shows as a smaller inset instead of fully covering the
    // background. Size, color and position all come from configuration.vh
    // (GUI-controlled) - position is an explicit pixel offset, not auto-centered.
    localparam PIP_BG_WIDTH  = ENABLE_PIP ? PIP_BG_W : 32'd0;
    localparam PIP_BG_HEIGHT = ENABLE_PIP ? PIP_BG_H : 32'd0;
    localparam PIP_H_OFFSET  = ENABLE_PIP ? PIP_H_OFF : 32'd0;
    localparam PIP_V_OFFSET  = ENABLE_PIP ? PIP_V_OFF : 32'd0;

    // The mixer has a confirmed one-time settling artifact on the very first
    // row it composites in a field (proven NOT to be a capture/reset-timing
    // race - see PIP_ROW_GUARD usage below). Grow the REAL hardware canvas by
    // one hidden row above the visible one and push both the real background
    // height and the real V offset down by that same guard row, so the
    // glitchy row always lands in the hidden guard row - never in the
    // visible image - regardless of what V offset the user actually wants
    // (including 0, flush at the very top).
    localparam [31:0] PIP_ROW_GUARD  = ENABLE_PIP ? 32'd1 : 32'd0;
    localparam        REAL_BG_HEIGHT = PIP_BG_HEIGHT + PIP_ROW_GUARD;
    localparam        REAL_V_OFFSET  = PIP_V_OFFSET  + PIP_ROW_GUARD;

    // =========================================================================
    // Topology-derived constants
    // =========================================================================
    localparam HAS_SCL = (TOPOLOGY=="FULL"||TOPOLOGY=="SCALER_ONLY"||TOPOLOGY=="CLIP_SCL") ? 1 : 0;
    localparam HAS_PC0 = HAS_SCL;

    // Capture geometry: when PIP is enabled, the mixer's output is the full
    // background canvas, not the pipeline's own (smaller, inset) output size.
    localparam CAP_W   = ENABLE_PIP ? PIP_BG_WIDTH  : (HAS_SCL ? SCALER_OUT_W : IMG_WIDTH);
    localparam CAP_H   = ENABLE_PIP ? PIP_BG_HEIGHT : (HAS_SCL ? SCALER_OUT_H : IMG_HEIGHT);
    localparam IS_FULL = HAS_PC0 ? 0 : 1;

    localparam [63:0] END_TIME = (CAP_H * CAP_W > TPG_WIDTH * TPG_HEIGHT) ?
                                  CAP_H * CAP_W * 500 :
                                  TPG_WIDTH * TPG_HEIGHT * 500;

    localparam CLK_PERIOD = 10;

    // =========================================================================
    // Signals
    // =========================================================================
    reg clk   = 0;
    reg reset = 1;
    always #(CLK_PERIOD/2) clk = ~clk;

    wire [23:0] out_tdata;
    wire        out_tvalid;
    reg         out_tready = 0;
    wire        out_tlast;
    wire [2:0]  out_tuser;
    wire        frame_done;

    // PIP: the mixer's first output cycle after out_tready goes high is a
    // one-time startup transient (confirmed via waveform inspection - every
    // cycle after the first is a clean, complete frame, repeating forever).
    // Hold the capture module in reset through that first cycle so its
    // first-ever SOF sighting lands in a clean frame, not the glitchy one.
    localparam [31:0] PIP_SETTLE_CYCLES = (CAP_W * CAP_H * 3);
    reg         cap_reset = 1'b1;
    reg  [31:0] pip_settle_count = 32'd0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cap_reset        <= 1'b1;
            pip_settle_count <= 32'd0;
        end else if (!ENABLE_PIP) begin
            cap_reset <= 1'b0;
        end else if (out_tready) begin
            if (pip_settle_count < PIP_SETTLE_CYCLES)
                pip_settle_count <= pip_settle_count + 1'b1;
            else
                cap_reset <= 1'b0;
        end
    end

    reg  [23:0] pc1_in_tdata  = 24'h0;
    reg         pc1_in_tvalid = 1'b0;
    wire        pc1_in_tready;
    reg         pc1_in_tlast  = 1'b0;
    reg  [2:0]  pc1_in_tuser  = 3'b000;

    // =========================================================================
    // Output capture
    // frame_controller auto-resets on every SOF so no special gating needed.
    // It will capture whichever complete frame arrives first after ST_WORKING.
    // =========================================================================
    make_file #(
        .IMG_H    (CAP_H),
        .IMG_W    (CAP_W),
        .IS_FULL  (IS_FULL),
        .SKIP_ROWS(PIP_ROW_GUARD),
        //.FILE_NAME("../../../../app/crs_yuv422.txt")
        .FILE_NAME("../../../../app/sc_data.txt")
    ) scaler_out (
        .clk       (clk),
        .reset     (cap_reset),
        .tdata     (out_tdata),
        .tvalid    (out_tvalid),
        .tready    (out_tready & (dut.current_state == dut.ST_WORKING)),
        .tlast     (out_tlast),
        .tuser     (out_tuser),
        .frame_done(frame_done)
    );
	 

    // =========================================================================
    // DUT
    // =========================================================================
    top #(
        .TOPOLOGY    (TOPOLOGY),
        .INPUT_SEL   (INPUT_SEL),
        .ENABLE_PIP  (ENABLE_PIP),
        .IMG_WIDTH   (IMG_WIDTH),
        .IMG_HEIGHT  (IMG_HEIGHT),
        .IMG_L_OFF   (IMG_L_OFF),
        .IMG_T_OFF   (IMG_T_OFF),
        .IMG_R_OFF   (IMG_R_OFF),
        .IMG_B_OFF   (IMG_B_OFF),
        .SCALER_OUT_W(SCALER_OUT_W),
        .SCALER_OUT_H(SCALER_OUT_H),
        .PIP_BG_WIDTH (PIP_BG_WIDTH),
        .PIP_BG_HEIGHT(REAL_BG_HEIGHT),
        .PIP_H_OFFSET (PIP_H_OFFSET),
        .PIP_V_OFFSET (REAL_V_OFFSET),
        .PIP_BG_COLOR (PIP_BG_COLOR),
        .TPG_MODE    (TPG_COLORSPACE),
        .VID_PLANES  (VID_PLANES)
    ) dut (
        .clk          (clk),
        .reset        (reset),
        .out_tdata    (out_tdata),
        .out_tvalid   (out_tvalid),
        .out_tready   (out_tready),
        .out_tlast    (out_tlast),
        .out_tuser    (out_tuser),
        .pc1_in_tdata (pc1_in_tdata),
        .pc1_in_tvalid(pc1_in_tvalid),
        .pc1_in_tready(pc1_in_tready),
        .pc1_in_tlast (pc1_in_tlast),
        .pc1_in_tuser (pc1_in_tuser)
    );

    // =========================================================================
    // Stimulus
    // =========================================================================
    initial begin
        reset      = 1;
        out_tready = 0;
        repeat(10) @(posedge clk);
        reset = 0;
        $display("[%0t] Reset released.", $time);

        if (!ENABLE_PIP) begin
            // Set out_tready=1 immediately after reset.
            // CRITICAL for CSC modes: pipeline must drain during ST_POLL_CSC.
            @(posedge clk);
            out_tready = 1;
        end

        // Wait for FSM to complete configuration (includes CSC poll for TPG)
        wait(dut.current_state == dut.ST_WORKING);
        $display("[%0t] ST_WORKING - pipeline configured.", $time);

        if (ENABLE_PIP) begin
            // Matches the working mixer reference: don't assert ready until
            // config is fully complete - the mixer's own output must never
            // see "ready" while its layer/blend/offset registers are still
            // being written, or it can latch onto an inconsistent internal
            // state that never recovers.
            out_tready = 1;
        end


        // Wait for first clean SOF after ST_WORKING.
        // frame_controller auto-resets on this SOF and captures the frame.
        wait(out_tvalid && out_tuser[0]);
        $display("[%0t] SOF detected - capturing frame.", $time);

        wait(frame_done);
        $display("[%0t] Frame written to sc_data.txt.", $time);
        $finish;
    end

    // =========================================================================
    // Image player (INPUT_SEL=1 only)
    // =========================================================================
    generate
        if (INPUT_SEL == 1'b1) begin : gen_img
            reg [23:0] img_mem [0 : TPG_WIDTH * TPG_HEIGHT - 1];
            integer px, py;

            initial begin
                $readmemh("../../../../app/image_data.txt", img_mem);
                $display("[IMG] Loaded %0dx%0d image.", TPG_WIDTH, TPG_HEIGHT);

                wait(dut.current_state == dut.ST_WORKING);
                repeat(5) @(posedge clk);

                $display("[IMG] Sending image...");
                @(posedge clk); #1;

                for (py = 0; py < TPG_HEIGHT; py = py + 1) begin
                    for (px = 0; px < TPG_WIDTH; px = px + 1) begin
                        pc1_in_tdata  = img_mem[py * TPG_WIDTH + px];
                        pc1_in_tvalid = 1'b1;
                        pc1_in_tuser  = (px==0 && py==0) ? 3'b001 : 3'b000;
                        pc1_in_tlast  = (px==TPG_WIDTH-1) ? 1'b1 : 1'b0;

                        @(posedge clk);
                        while (!pc1_in_tready) @(posedge clk);
                        #1;
                    end
                end

                pc1_in_tvalid = 1'b0;
                pc1_in_tlast  = 1'b0;
                pc1_in_tuser  = 3'b000;
                $display("[IMG] Image sent.");
            end
        end
    endgenerate

    // =========================================================================
    // State trace
    // =========================================================================
    reg [5:0] last_state = 6'h3F;
    always @(posedge clk) begin
        if (!reset && dut.current_state !== last_state) begin
            $display("[%0t] STATE %0d->%0d cfg_step=%0d",
                     $time, last_state, dut.current_state, dut.cfg_step);
            last_state <= dut.current_state;
        end
    end

    // =========================================================================
    // Timeout watchdog
    // =========================================================================
    initial begin
        #(END_TIME);
        $display("ERROR: Timeout! state=%0d cfg_step=%0d bridge_wait=%b pc1_wait=%b",
                 dut.current_state, dut.cfg_step,
                 dut.bridge_wait, dut.pc1_wait);
        $finish;
    end

endmodule
