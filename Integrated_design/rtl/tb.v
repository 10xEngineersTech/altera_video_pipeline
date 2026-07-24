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
    localparam TOPOLOGY    = "FULL";   // FULL/SCALER_ONLY/CSC_ONLY/CRS_ONLY/CRS_CSC/CLIP_SCL/DIL_ONLY

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

    // =========================================================================
    // Topology-derived constants
    // =========================================================================
    localparam HAS_SCL = (TOPOLOGY=="FULL"||TOPOLOGY=="SCALER_ONLY"||TOPOLOGY=="CLIP_SCL") ? 1 : 0;
    localparam HAS_PC0 = HAS_SCL;

    localparam CAP_W   = HAS_SCL ? SCALER_OUT_W : IMG_WIDTH;
    localparam CAP_H   = HAS_SCL ? SCALER_OUT_H : IMG_HEIGHT;
    // FRC build: m_axis_video_out is the VFB frame read, which is Full protocol
    // (the ltf_conv re-inserts image-info metapackets), so the frame_controller
    // must run in Full mode to skip metapackets. Non-FRC scaler output is Lite.
    localparam IS_FULL = FRC_ENABLE ? 1 : (HAS_PC0 ? 0 : 1);

    // Base watchdog: ~500 clocks per pixel of the larger of the input/output frame.
    localparam [63:0] BASE_END = (CAP_H * CAP_W > TPG_WIDTH * TPG_HEIGHT) ?
                                  CAP_H * CAP_W * 500 :
                                  TPG_WIDTH * TPG_HEIGHT * 500;
    // FRC build must wait for DDR4 calibration (~1 ms sim) before the VFB read
    // side emits the first frame, so extend the timeout generously. END_TIME is
    // only a ceiling - the sim ends at frame_done, well before this, once the
    // frame read completes.
    // Skip-cal EMIF calibration completes ~150 us of sim; a working FRC frame
    // round-trip finishes shortly after. Cap a broken run at ~2 ms sim (~minutes
    // wall) instead of hours - the handshake, not this timer, ends a good run.
    localparam [63:0] END_TIME = FRC_ENABLE ? (BASE_END + 64'd2_000_000)
                                            : BASE_END;

    localparam CLK_PERIOD = 10;

    // =========================================================================
    // Signals
    // =========================================================================
    reg clk   = 0;
    reg reset = 1;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Dedicated EMIF reference clock: 200 MHz (period 5 ns), free-running from
    // t=0, independent of the 100 MHz video clock. The io96b EMIF PHY is built
    // for a 200 MHz refclk; without it calibration never completes and the VFB
    // write side stays gated (frame never reaches DDR4).
    reg emif_ref_clk = 0;
    always #2.5 emif_ref_clk = ~emif_ref_clk;

    wire [23:0] out_tdata;
    wire        out_tvalid;
    reg         out_tready = 0;
    wire        out_tlast;
    wire [2:0]  out_tuser;
    wire        frame_done;

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
        //.FILE_NAME("../../../../app/crs_yuv422.txt")
        .FILE_NAME("../../../../app/sc_data.txt")
    ) scaler_out (
        .clk       (clk),
        .reset     (reset),
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
        .IMG_WIDTH   (IMG_WIDTH),
        .IMG_HEIGHT  (IMG_HEIGHT),
        .IMG_L_OFF   (IMG_L_OFF),
        .IMG_T_OFF   (IMG_T_OFF),
        .IMG_R_OFF   (IMG_R_OFF),
        .IMG_B_OFF   (IMG_B_OFF),
        .SCALER_OUT_W(SCALER_OUT_W),
        .SCALER_OUT_H(SCALER_OUT_H),
        .TPG_MODE    (TPG_COLORSPACE),
        .VID_PLANES  (VID_PLANES),
        .FRC_ENABLE  (FRC_ENABLE)
    ) dut (
        .clk          (clk),
        .emif_ref_clk (emif_ref_clk),
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

        // Set out_tready=1 immediately after reset.
        // CRITICAL for CSC modes: pipeline must drain during ST_POLL_CSC.
        @(posedge clk);
        out_tready = 1;

        // Wait for FSM to complete configuration (includes CSC poll for TPG)
        wait(dut.current_state == dut.ST_WORKING);
        $display("[%0t] ST_WORKING - pipeline configured.", $time);


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

                // Start feeding once the pipeline gates video in. For an FRC build
                // this is the write phase (ST_FRC_WR_WAIT), which is BEFORE
                // ST_WORKING - the VFB write side needs frames to fill DDR4 first.
                // For non-FRC, ready_to_start == ST_WORKING (unchanged behaviour).
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
    // State trace
    // =========================================================================
    reg [4:0] last_state = 5'h1F;
    always @(posedge clk) begin
        if (!reset && dut.current_state !== last_state) begin
            $display("[%0t] STATE %0d->%0d cfg_step=%0d",
                     $time, last_state, dut.current_state, dut.cfg_step);
            last_state <= dut.current_state;
        end
    end

    // =========================================================================
    // FRC round-trip milestone trace (proof the frame goes through DDR4)
    //   write phase  -> VFB writes scaler frames into the DDR4 memory model
    //   ST_FRC_GO    -> NUM_INPUT_FIELDS != 0, i.e. a COMPLETE frame is in DDR4
    //   ST_WORKING   -> VFB read side started; frame read-back drains to output
    // Correlate these timestamps with the mem-model "[...]: Writing/Reading data"
    // lines to see the full Scaler -> FB write -> EMIF -> mem -> EMIF -> FB read path.
    // =========================================================================
    initial begin
        if (FRC_ENABLE) begin
            @(posedge clk);
            wait(dut.current_state == dut.ST_FRC_WR_WAIT);
            $display("[%0t] [FRC] WRITE PHASE: VFB writing scaler frames to DDR4 model (awaiting a complete frame; EMIF calibration must finish first).", $time);
            wait(dut.current_state == dut.ST_FRC_GO);
            $display("[%0t] [FRC] COMPLETE FRAME WRITTEN TO DDR4 (NUM_INPUT_FIELDS!=0). Starting VFB read side (GO).", $time);
            wait(dut.current_state == dut.ST_WORKING);
            $display("[%0t] [FRC] READ BACK: VFB read side running, frame read from DDR4 now draining to output.", $time);
        end
    end

    // =========================================================================
    // Diagnostic probes - pinpoint why the VFB never completes a frame write.
    // Paths reach into the generated pipeline subsystem (kept accessible by the
    // -voptargs=+acc used in runProject.py). Three first-seen events answer it:
    //   cal_done : EMIF calibration finished (AXI bridge to the VFB released)
    //   vfb_vid  : video actually reached the VFB stream input (ltf -> vfb)
    //   vfb_wr   : VFB issued a memory write to the EMIF (frame -> DDR4)
    // =========================================================================
`define SUBSYS dut.u0.intel_vvp_pipeline2_0.intel_vvp_pipeline2_0
    reg     cal_done_seen = 1'b0;
    reg     f2l_out_seen  = 1'b0;   // video out of the Full->Lite conv (= scaler input)
    reg     scl_out_seen  = 1'b0;   // video out of the scaler
    reg     vfb_vid_seen  = 1'b0;   // video out of the L2F conv (= VFB input)
    reg     vfb_wr_seen   = 1'b0;   // VFB memory write to EMIF
    integer vid_in_beats  = 0;
    integer scl_out_beats = 0;
    always @(posedge clk) begin
        if (!reset) begin
            if (dut.vid_in_tvalid && dut.vid_in_tready)
                vid_in_beats = vid_in_beats + 1;
            if (`SUBSYS.intel_vvp_scaler_0_axi4s_vid_out_tvalid &&
                `SUBSYS.intel_vvp_scaler_0_axi4s_vid_out_tready)
                scl_out_beats = scl_out_beats + 1;
            if (!cal_done_seen && `SUBSYS.frc_emif_0_s0_axi4_ctrl_ready_reset) begin
                cal_done_seen <= 1'b1;
                $display("[%0t] [PROBE] EMIF calibration DONE - AXI bridge to VFB released.", $time);
            end
            if (!f2l_out_seen && `SUBSYS.intel_vvp_protocol_conv_0_axi4s_vid_out_tvalid) begin
                f2l_out_seen <= 1'b1;
                $display("[%0t] [PROBE] Video reached SCALER input (F2L conv output tvalid=1).", $time);
            end
            if (!scl_out_seen && `SUBSYS.intel_vvp_scaler_0_axi4s_vid_out_tvalid) begin
                scl_out_seen <= 1'b1;
                $display("[%0t] [PROBE] SCALER produced OUTPUT (scaler axi4s_vid_out tvalid=1).", $time);
            end
            if (!vfb_vid_seen && `SUBSYS.ltf_conv_0_axi4s_vid_out_tvalid) begin
                vfb_vid_seen <= 1'b1;
                $display("[%0t] [PROBE] Video REACHED VFB input (L2F ltf_conv -> vfb tvalid=1).", $time);
            end
            if (!vfb_wr_seen && `SUBSYS.intel_vvp_vfb_0_av_mm_mem_write_host_write) begin
                vfb_wr_seen <= 1'b1;
                $display("[%0t] [PROBE] VFB issued FIRST MEMORY WRITE to EMIF (frame heading to DDR4).", $time);
            end
        end
    end
    // Heartbeat every 20 us: full per-stage snapshot to localize the stall.
    //   scl_out(tv/tr): scaler output handshake ; vfbin_tr: VFB accepting L2F output
    initial forever begin
        #20000;
        $display("[%0t] [HB] st=%0d vin_beats=%0d scl_out_beats=%0d cal=%0b f2l=%0b scl=%0b vfbvid=%0b vfbwr=%0b | vin(tv=%0b tr=%0b) scl_out(tv=%0b tr=%0b) vfbin_tr=%0b out_tv=%0b",
                 $time, dut.current_state, vid_in_beats, scl_out_beats, cal_done_seen,
                 f2l_out_seen, scl_out_seen, vfb_vid_seen, vfb_wr_seen,
                 dut.vid_in_tvalid, dut.vid_in_tready,
                 `SUBSYS.intel_vvp_scaler_0_axi4s_vid_out_tvalid,
                 `SUBSYS.intel_vvp_scaler_0_axi4s_vid_out_tready,
                 `SUBSYS.ltf_conv_0_axi4s_vid_out_tready, out_tvalid);
    end

    // =========================================================================
    // Timeout watchdog - DISABLED (per request): the FRC path must run until the
    // frame is actually written to and read back from the DDR4 memory model, no
    // matter how long calibration takes. Completion is event-driven only, via
    // `wait(frame_done); $finish;` in the stimulus block above. Re-enable this
    // block if you ever need a hard ceiling to catch a genuine hang.
    // =========================================================================
    // initial begin
    //     #(END_TIME);
    //     $display("ERROR: Timeout! state=%0d cfg_step=%0d bridge_wait=%b pc1_wait=%b",
    //              dut.current_state, dut.cfg_step,
    //              dut.bridge_wait, dut.pc1_wait);
    //     $finish;
    // end

endmodule
