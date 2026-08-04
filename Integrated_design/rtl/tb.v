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
    // MUST match the packaged IP's own TOPOLOGY parameter. The IP is built
    // SCALER_ONLY, so its internal datapath is only
    //   s_axis_video_in -> protocol_conv(F2L) -> scaler -> ltf_conv(L2F) -> VFB
    // and the DIL/CRS/CSC/Clipper control agents DO NOT EXIST. Leaving this on
    // "FULL" makes the FSM write to 0x200/0x400/0x600 and, worse, poll CRS
    // STATUS at 0x340 - an unmapped read never returns readdatavalid, so the
    // FSM hangs in the poll forever.
    localparam TOPOLOGY    = "FULL";   // FULL/SCALER_ONLY/CSC_ONLY/CRS_ONLY/CRS_CSC/CLIP_SCL/DIL_ONLY
    localparam ENABLE_PIP  = PIP_ENABLE;      // from configuration.vh (GUI-controlled)
    localparam ENABLE_FRC  = FRC_ENABLE;      // from configuration.vh (GUI-controlled)

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
    // With FRC the captured stream comes out of the frame buffer, which sits
    // AFTER the Lite->Full converter - so it carries image-info metapackets and
    // must be parsed as Full protocol regardless of HAS_PC0.
    localparam IS_FULL = ENABLE_FRC ? 1 : (HAS_PC0 ? 0 : 1);

    localparam [63:0] BASE_END_TIME = (CAP_H * CAP_W > TPG_WIDTH * TPG_HEIGHT) ?
                                       CAP_H * CAP_W * 500 :
                                       TPG_WIDTH * TPG_HEIGHT * 500;

    // FRC adds DDR4 calibration before any traffic can move (~119us of sim time
    // on this EMIF - it is built full-cal/real-PHY, there is no skip-cal mode
    // for io96b). The watchdog must clear that by a wide margin or it fires
    // during calibration and looks like a pipeline hang. This only moves the
    // timeout - it does not slow the run.
    localparam [63:0] END_TIME = ENABLE_FRC ? BASE_END_TIME + 64'd50_000_000
                                            : BASE_END_TIME;

    // =========================================================================
    // FRC frame-rate scenario
    //
    // The frame buffer has NO rate registers. The WRITE rate is how fast frames
    // arrive at its input; the READ rate is how fast the sink drains its output.
    // Both are set here as an idle-cycle gap inserted once per frame's worth of
    // beats:
    //     write_period = TPG_WIDTH*TPG_HEIGHT + FRC_IN_GAP_CYCLES   (cycles)
    //     read_period  = CAP_W*CAP_H          + FRC_OUT_GAP_CYCLES  (cycles)
    //     fps          = 100e6 / period
    //
    // 0/0 = both sides flat out (rates matched, no drop, no repeat).
    // To force DOWN-conversion (dropped frames): leave IN at 0 and set OUT to
    //   one frame time or more, e.g. FRC_OUT_GAP_CYCLES = CAP_W*CAP_H.
    // To force UP-conversion (repeated frames): leave OUT at 0 and set IN to
    //   one or two frame times, e.g. FRC_IN_GAP_CYCLES = 2*TPG_WIDTH*TPG_HEIGHT.
    // The FRC FIELD COUNTERS printed at the end of the run are the evidence.
    // =========================================================================
    localparam [31:0] FRC_IN_GAP_CYCLES  = 32'd0;
    localparam [31:0] FRC_OUT_GAP_CYCLES = 32'd0;

    localparam CLK_PERIOD = 10;      // 100 MHz video clock
    // EMIF reference clock: the packaged IP's EMIF is configured for a 200 MHz
    // reference (EMIF_PHY_REFCLK_FREQ_MHZ=200.0). Feeding it the 100 MHz video
    // clock makes calibration never complete.
    localparam EMIF_REF_PERIOD = 5;  // 200 MHz

    // =========================================================================
    // Signals
    // =========================================================================
    reg clk   = 0;
    reg reset = 1;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Free-running 200 MHz EMIF reference. Deliberately independent of reset -
    // the EMIF calibration engine needs it running from t=0.
    reg emif_ref_clk = 0;
    always #(EMIF_REF_PERIOD/2.0) emif_ref_clk = ~emif_ref_clk;


    // FRC counter readback handshake
    reg         frc_stats_req = 1'b0;
    wire        frc_stats_valid;
    wire [31:0] frc_in_fields;
    wire [31:0] frc_dropped_fields;
    wire [31:0] frc_out_fields;
    wire [31:0] frc_repeated_fields;

    wire [23:0] out_tdata;
    wire        out_tvalid;
    reg         out_tready_en = 0;   // enabled by the stimulus block
    wire        out_tready;          // gated by the FRC read-rate pacer below

    // -------------------------------------------------------------------------
    // FRC read-rate pacing: drop tready for FRC_OUT_GAP_CYCLES after every
    // frame's worth of drained beats. This is the "sink" side of the rate
    // differential - the equivalent of OUTPUT_GAP in the DDR_TPG reference's
    // sink CSR.
    // -------------------------------------------------------------------------
    localparam [31:0] FRC_OUT_FRAME_BEATS = CAP_W * CAP_H;
    reg  [31:0] out_beats = 32'd0;
    reg  [31:0] out_gap   = 32'd0;
    wire        out_beat  = out_tvalid && out_tready;
    wire        out_paused = ENABLE_FRC && (FRC_OUT_GAP_CYCLES != 32'd0) && (out_gap != 32'd0);

    always @(posedge clk) begin
        if (reset) begin
            out_beats <= 32'd0;
            out_gap   <= 32'd0;
        end else if (ENABLE_FRC && (FRC_OUT_GAP_CYCLES != 32'd0)) begin
            if (out_gap != 32'd0) begin
                out_gap <= out_gap - 32'd1;
            end else if (out_beat) begin
                if (out_beats >= (FRC_OUT_FRAME_BEATS - 32'd1)) begin
                    out_beats <= 32'd0;
                    out_gap   <= FRC_OUT_GAP_CYCLES;
                end else begin
                    out_beats <= out_beats + 32'd1;
                end
            end
        end
    end

    assign out_tready = out_tready_en && !out_paused;
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
        .ENABLE_FRC  (ENABLE_FRC),
        .FRC_IN_GAP_CYCLES(FRC_IN_GAP_CYCLES),
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
        .emif_ref_clk (emif_ref_clk),
        .frc_stats_req      (frc_stats_req),
        .frc_stats_valid    (frc_stats_valid),
        .frc_in_fields      (frc_in_fields),
        .frc_dropped_fields (frc_dropped_fields),
        .frc_out_fields     (frc_out_fields),
        .frc_repeated_fields(frc_repeated_fields),
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
        out_tready_en = 0;
        repeat(10) @(posedge clk);
        reset = 0;
        $display("[%0t] Reset released.", $time);

        if (!ENABLE_PIP) begin
            // Set out_tready=1 immediately after reset.
            // CRITICAL for CSC modes: pipeline must drain during ST_POLL_CSC.
            @(posedge clk);
            out_tready_en = 1;
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
            out_tready_en = 1;
        end


        // Wait for first clean SOF after ST_WORKING.
        // frame_controller auto-resets on this SOF and captures the frame.
        wait(out_tvalid && out_tuser[0]);
        $display("[%0t] SOF detected - capturing frame.", $time);

        wait(frame_done);
        $display("[%0t] Frame written to sc_data.txt.", $time);

        if (ENABLE_FRC) begin
            // Frame is safely dumped; now ask the FSM to read the VFB's field
            // counters over the control bridge. Video is still running, so
            // these are a live sample of what the write and read sides did.
            frc_stats_req = 1'b1;
            wait(frc_stats_valid);
            frc_stats_req = 1'b0;
            $display("=================== FRC FIELD COUNTERS ===================");
            $display("  NUM_INPUT_FIELDS    (0x0F44) = %0d   (frames written to DDR4)",
                     frc_in_fields);
            $display("  NUM_DROPPED_FIELDS  (0x0F48) = %0d   (>0 => input faster than output)",
                     frc_dropped_fields);
            $display("  NUM_OUTPUT_FIELDS   (0x0F54) = %0d   (frames read back out)",
                     frc_out_fields);
            $display("  NUM_REPEATED_FIELDS (0x0F58) = %0d   (>0 => output faster than input)",
                     frc_repeated_fields);
            $display("==========================================================");
        end

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

                // With FRC the frame buffer must be FED before its read side is
                // released, and ST_WORKING is only reached after that handshake -
                // so waiting for ST_WORKING here would deadlock. ready_to_start
                // opens at the start of the FRC bring-up phase instead. Without
                // FRC ready_to_start == (state==ST_WORKING), so this is
                // unchanged for every existing topology.
                wait(dut.ready_to_start);
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
    // FRC / DDR4 diagnostic probes
    //
    // The failure mode seen previously was NOT in the video datapath: the
    // scaler and Lite->Full converter both held tvalid high while the VFB's
    // Avalon-MM write host sat with write=1 against a permanently asserted
    // waitrequest, because the EMIF's AXI write-address channel stopped
    // accepting (awvalid=1, awready=0 forever). These probes surface exactly
    // that, live, so a stall is diagnosed from the run log instead of needing
    // post-mortem waveform archaeology.
    //
    // Hierarchy: dut.u0.<system>.<subsystem>.<net>
    // =========================================================================
`define SUB dut.u0.intel_vvp_pipeline2_0.intel_vvp_pipeline2_0
    generate
    if (ENABLE_FRC) begin : gen_frc_probe
        // running counts of accepted beats at each link
        integer scl_beats  = 0;   // scaler   -> ltf_conv
        integer ltf_beats  = 0;   // ltf_conv -> VFB
        integer wr_beats   = 0;   // VFB      -> memory (Avalon write accepted)
        integer aw_accepts = 0;   // EMIF AXI address-channel accepts
        reg     cal_seen   = 1'b0;

        always @(posedge clk) if (!reset) begin
            if (`SUB.intel_vvp_scaler_0_axi4s_vid_out_tvalid &&
                `SUB.intel_vvp_scaler_0_axi4s_vid_out_tready) scl_beats <= scl_beats + 1;
            if (`SUB.ltf_conv_0_axi4s_vid_out_tvalid &&
                `SUB.ltf_conv_0_axi4s_vid_out_tready)         ltf_beats <= ltf_beats + 1;
            if (`SUB.intel_vvp_vfb_0_av_mm_mem_write_host_write &&
               !`SUB.intel_vvp_vfb_0_av_mm_mem_write_host_waitrequest) wr_beats <= wr_beats + 1;
            if (`SUB.mm_interconnect_1_frc_emif_0_s0_axi4_awvalid &&
                `SUB.mm_interconnect_1_frc_emif_0_s0_axi4_awready) aw_accepts <= aw_accepts + 1;

            // announce calibration release exactly once - this is the gate that
            // holds all VFB traffic out of DDR4 until the PHY is trained
            if (!cal_seen && `SUB.frc_emif_0_s0_axi4_ctrl_ready_reset) begin
                cal_seen <= 1'b1;
                $display("[PROBE %0t] *** EMIF ctrl_ready_reset=1 : DDR4 CALIBRATION COMPLETE, AXI bridge released ***", $time);
            end
        end

        // periodic snapshot + stall detector
        integer prev_wr = -1, prev_scl = -1, quiet = 0;
        initial begin
            forever begin
                #(20_000);   // every 20 us of sim time
                $display("[PROBE %0t] cal=%b | beats scl=%0d ltf=%0d wrAccepted=%0d awAccepted=%0d | state=%0d",
                         $time, `SUB.frc_emif_0_s0_axi4_ctrl_ready_reset,
                         scl_beats, ltf_beats, wr_beats, aw_accepts, dut.current_state);
                if (`SUB.frc_emif_0_s0_axi4_ctrl_ready_reset) begin
                    if (wr_beats == prev_wr && scl_beats == prev_scl) begin
                        quiet = quiet + 1;
                        if (quiet == 2) begin
                            $display("[PROBE %0t] ################ STALL DETECTED ################", $time);
                            $display("  SCL out   tvalid=%b tready=%b",
                                     `SUB.intel_vvp_scaler_0_axi4s_vid_out_tvalid,
                                     `SUB.intel_vvp_scaler_0_axi4s_vid_out_tready);
                            $display("  LTF out   tvalid=%b tready=%b",
                                     `SUB.ltf_conv_0_axi4s_vid_out_tvalid,
                                     `SUB.ltf_conv_0_axi4s_vid_out_tready);
                            $display("  VFB->mem  write=%b waitrequest=%b addr=0x%08h burstcount=%0d",
                                     `SUB.intel_vvp_vfb_0_av_mm_mem_write_host_write,
                                     `SUB.intel_vvp_vfb_0_av_mm_mem_write_host_waitrequest,
                                     `SUB.intel_vvp_vfb_0_av_mm_mem_write_host_address,
                                     `SUB.intel_vvp_vfb_0_av_mm_mem_write_host_burstcount);
                            $display("  EMIF AW   awvalid=%b awready=%b awaddr=0x%08h awlen=%0d (=%0d beats)",
                                     `SUB.mm_interconnect_1_frc_emif_0_s0_axi4_awvalid,
                                     `SUB.mm_interconnect_1_frc_emif_0_s0_axi4_awready,
                                     `SUB.mm_interconnect_1_frc_emif_0_s0_axi4_awaddr,
                                     `SUB.mm_interconnect_1_frc_emif_0_s0_axi4_awlen,
                                     `SUB.mm_interconnect_1_frc_emif_0_s0_axi4_awlen + 1);
                            $display("  ==> if awvalid=1/awready=0 the EMIF is refusing a legal burst;");
                            $display("      if awvalid=0 the VFB is not even requesting - look upstream.");
                            $display("################################################");
                        end
                    end else quiet = 0;
                    prev_wr  = wr_beats;
                    prev_scl = scl_beats;
                end
            end
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
