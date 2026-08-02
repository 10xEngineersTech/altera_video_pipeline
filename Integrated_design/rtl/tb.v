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
    localparam TOPOLOGY    = "SCALER_ONLY";   // FULL/SCALER_ONLY/CSC_ONLY/CRS_ONLY/CRS_CSC/CLIP_SCL/DIL_ONLY
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
    //     read_period  = OTG_PERIOD_CYCLES  (set in the DESIGN, see top.v OTG)
    //     fps          = 100e6 / period
    //
    // 0/0 = both sides flat out (rates matched, no drop, no repeat).
    // To force DOWN-conversion (dropped frames): leave IN at 0 and set OUT to
    //   OTG_PERIOD_CYCLES = 2*CAP_W*CAP_H (half the read rate).
    // To force UP-conversion (repeated frames): leave OUT at 0 and set IN to
    //   one or two frame times, e.g. FRC_IN_GAP_CYCLES = 2*TPG_WIDTH*TPG_HEIGHT.
    // The FRC FIELD COUNTERS printed at the end of the run are the evidence.
    // =========================================================================
    // Rates come from the GUI (Source/Sink frame rate fields) via
    // configuration.vh, which precomputes the cycle counts. Falls back to
    // flat-out if an older configuration.vh has no FRC_* rate parameters.
    // Rates are applied at RUN TIME, after the natural frame period has been
    // measured - see frc_calibrate below. They start disabled so the
    // calibration pass runs unthrottled.
    reg [31:0] frc_in_period_r = 32'd0;
    reg [31:0] otg_period_r  = 32'd0;
    integer    nat_period;        // measured cycles per frame, unthrottled
    integer    per_in, per_out;   // absolute frame periods we will impose

    // READ rate is now set by the DESIGN's output timing generator, not by the
    // testbench. output_fps = 100e6 / OTG_PERIOD_CYCLES. A frame is
    // CAP_W*CAP_H beats, so any period at or below that runs flat out.
    //   0                      -> no throttling (max read rate)
    //   2*CAP_W*CAP_H          -> half rate   (e.g. 60->30 down-conversion)
    //   CAP_W*CAP_H*12/10      -> 5/6 rate    (e.g. 60->50 down-conversion)
    // This same register drives the rate on real hardware.


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

    // Free-running cycle count. Deliberately NOT $time: assigned to an integer,
    // $time returns the MODULE's timescale units (ns here) while %0t displays
    // simulation precision (fs) - mixing the two silently produced nat_period=0.
    // Counting clocks is unambiguous and is also what the period registers use.
    reg [63:0] cyc = 64'd0;
    always @(posedge clk) cyc <= cyc + 64'd1;

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

    // Read-rate pacing now lives in the design (top.v output timing
    // generator), driven by OTG_PERIOD_CYCLES below - so simulation and
    // hardware use the same logic. The testbench just presents a sink that is
    // always ready.
    assign out_tready = out_tready_en;
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
    // FRC tests need every output frame kept, not just the first: with a
    // per-frame tag in the video the file sequence shows exactly which input
    // frames were dropped or repeated.
    localparam MULTI_FRAME = ENABLE_FRC ? 1 : 0;
    localparam MAX_FRAMES  = 64;
    wire [31:0] frames_captured;

    make_file #(
        .IMG_H    (CAP_H),
        .IMG_W    (CAP_W),
        .IS_FULL  (IS_FULL),
        .SKIP_ROWS(PIP_ROW_GUARD),
        .MULTI_FRAME(MULTI_FRAME),
        .OUT_DIR    ("../../../../app/frames"),
        .MAX_FRAMES (MAX_FRAMES),
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
        .frame_done(frame_done),
        .frames_captured(frames_captured)
    );
	 

    // =========================================================================
    // DUT
    // =========================================================================
    top #(
        .TOPOLOGY    (TOPOLOGY),
        .INPUT_SEL   (INPUT_SEL),
        .ENABLE_PIP  (ENABLE_PIP),
        .ENABLE_FRC  (ENABLE_FRC),
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
        .otg_period_cycles(otg_period_r),
        .frc_in_period_cycles(frc_in_period_r),
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

        if (!ENABLE_FRC) begin
            $finish;
        end else begin
            // =================================================================
            // FRC MEASUREMENT WINDOW
            //
            // Absolute counter values cannot prove conversion: the write side
            // auto-runs through the ~120us DDR4 calibration while the read side
            // waits for GO, so the writer gets ~2 frames ahead and the triple
            // buffer legitimately sheds one. A run at MATCHED rates really does
            // report dropped=1 from a single early sample - which would read as
            // down-conversion that is not happening.
            //
            // So: settle, snapshot, run a known number of output frames,
            // snapshot again, and judge only the DELTAS.
            // =================================================================
            frc_calibrate;
            frc_measure;
            frc_report;
            $finish;
        end
    end

    // ---------------------------------------------------------------------
    // Measurement window state
    // ---------------------------------------------------------------------
    localparam integer FRC_SETTLE_FRAMES = 2;    // discard startup transient
    localparam integer FRC_WINDOW_FRAMES = 16;   // 16 sink frames (expect 32 source frames in)

    integer a_in, a_drop, a_out, a_rpt;          // snapshot A (window start)
    integer b_in, b_drop, b_out, b_rpt;          // snapshot B (window end)
    integer d_in, d_drop, d_out, d_rpt;          // deltas
    integer exp_drop, exp_rpt, win_frames;
    reg     pass_dir, pass_mag, pass_inv, pass_all, pass_rate;
    integer req_r, ach_r;   // requested / achieved ratio, x1000

    task automatic frc_snapshot(output integer i, output integer dr,
                                output integer o, output integer rp);
        begin
            frc_stats_req = 1'b1;
            wait(frc_stats_valid);
            i  = frc_in_fields;
            dr = frc_dropped_fields;
            o  = frc_out_fields;
            rp = frc_repeated_fields;
            frc_stats_req = 1'b0;
            @(posedge clk);           // let the FSM re-arm
        end
    endtask

    // Wait until the VFB's OWN output-field counter has advanced by n.
    //
    // Deliberately NOT based on make_file's frames_captured: that is a
    // testbench-side count driven by frame_controller's frame_done, and it
    // proved unreliable (frame_done is a latched level, so a burst of spurious
    // increments raced the counter ahead and closed the window after a single
    // real output frame). NUM_OUTPUT_FIELDS is the frame buffer's own hardware
    // count of frames it actually emitted - the authoritative number, and the
    // same one available over JTAG on hardware.
    task automatic frc_wait_out(input integer n, output integer i,
                                output integer dr, output integer o,
                                output integer rp);
        integer o0, guard;
        begin
            frc_snapshot(i, dr, o, rp);
            o0    = o;
            guard = 0;
            while ((o - o0) < n && guard < 20000) begin
                repeat (200) @(posedge clk);      // ~1 output frame period
                frc_snapshot(i, dr, o, rp);
                guard = guard + 1;
            end
            if ((o - o0) < n)
                $display("[FRC] WARNING: only %0d of %0d output frames arrived before guard limit",
                         o - o0, n);
        end
    endtask

    // ---------------------------------------------------------------------
    // CALIBRATION: measure the natural (unthrottled) frame period.
    //
    // The previous run failed because the requested periods were derived from
    // W*H payload beats (100 cycles at 10x10), but a frame actually takes ~500
    // cycles to move through the frame buffer and DDR4 - memory latency,
    // bursts, refresh and the metapacket add ~5x. Any period BELOW that floor
    // is a no-op: the gate never gets a chance to shut, both sides free-run,
    // and the requested ratio is silently not applied.
    //
    // So measure the floor first, then derive both periods from it. This also
    // adapts automatically to frame size, where the fixed overhead amortises
    // differently.
    // ---------------------------------------------------------------------
    task automatic frc_calibrate;
        integer i0, dr0, o0, rp0, i1, dr1, o1, rp1;
        reg [63:0] c0, c1;
        integer basis, fastest;
        begin
            frc_in_period_r = 32'd0;   // unthrottled for the measurement
            otg_period_r = 32'd0;

            frc_wait_out(2, i0, dr0, o0, rp0);   // let it reach steady state
            frc_snapshot(i0, dr0, o0, rp0);
            c0 = cyc;
            frc_wait_out(4, i1, dr1, o1, rp1);
            frc_snapshot(i1, dr1, o1, rp1);
            c1 = cyc;

            if ((o1 - o0) > 0)
                nat_period = (c1 - c0) / (o1 - o0);
            else
                nat_period = CAP_W * CAP_H;      // fallback, should not happen

            $display("[FRC] natural frame period measured: %0d cycles (%0d frames in %0d cycles)",
                     nat_period, o1 - o0, c1 - c0);

            // Derive absolute periods from the measured floor, with headroom so
            // both sides are genuinely throttled rather than sitting at the floor.
            basis   = (nat_period * 3) / 2;
            fastest = (FRC_SRC_FPS > FRC_SINK_FPS) ? FRC_SRC_FPS : FRC_SINK_FPS;
            per_in  = (basis * fastest) / FRC_SRC_FPS;
            per_out = (basis * fastest) / FRC_SINK_FPS;

            if (per_in <= nat_period)
                $display("[FRC] WARNING: input period %0d <= natural floor %0d - source will NOT be throttled",
                         per_in, nat_period);
            frc_in_period_r = per_in;                 // pacer is now ABSOLUTE

            if (per_out <= nat_period)
                $display("[FRC] WARNING: output period %0d <= natural floor %0d - sink will NOT be throttled",
                         per_out, nat_period);
            otg_period_r = per_out;                   // OTG is absolute

            $display("[FRC] applying rates: in_period=%0d  out_period=%0d  -> ratio %0d.%0d%0d",
                     per_in, per_out, per_out / per_in,
                     (((per_out * 100) / per_in) / 10) % 10, ((per_out * 100) / per_in) % 10);

            // let the new rates take effect before measuring
            frc_wait_out(2, i1, dr1, o1, rp1);
        end
    endtask

    task automatic frc_measure;
        integer t_i, t_dr, t_o, t_rp;
        begin
            // settle: let the startup transient pass (the write side auto-runs
            // through DDR4 calibration while the read side waits for GO, so the
            // writer starts ~2 frames ahead - that is not conversion)
            frc_wait_out(FRC_SETTLE_FRAMES, t_i, t_dr, t_o, t_rp);
            frc_snapshot(a_in, a_drop, a_out, a_rpt);
            $display("[%0t] FRC window OPEN : in=%0d drop=%0d out=%0d rpt=%0d",
                     $time, a_in, a_drop, a_out, a_rpt);

            // measure a known number of OUTPUT frames
            frc_wait_out(FRC_WINDOW_FRAMES, b_in, b_drop, b_out, b_rpt);
            $display("[%0t] FRC window CLOSE: in=%0d drop=%0d out=%0d rpt=%0d",
                     $time, b_in, b_drop, b_out, b_rpt);

            d_in   = b_in   - a_in;
            d_drop = b_drop - a_drop;
            d_out  = b_out  - a_out;
            d_rpt  = b_rpt  - a_rpt;
        end
    endtask

    // ---------------------------------------------------------------------
    // Verdict + machine-readable result for the GUI popup
    // ---------------------------------------------------------------------
    task automatic frc_report;
        integer fd;
        integer tol;
        begin
            win_frames = d_out;
            // expected drop/repeat from the configured rates
            // expected from what the rates ACHIEVED (the ratio check separately
            // verifies the rates matched the request) - otherwise a small rate
            // drift is counted twice, once here and once in the ratio check
            if (FRC_SRC_FPS > FRC_SINK_FPS) exp_drop = d_in - d_out;
            else exp_drop = 0;
            if (FRC_SINK_FPS > FRC_SRC_FPS)
                exp_rpt  = (d_out * (FRC_SINK_FPS - FRC_SRC_FPS)) / FRC_SINK_FPS;
            else exp_rpt = 0;

            // allow +/-2 frames for frame-boundary phasing
            tol = 2;

            // 1. direction
            if (FRC_SRC_FPS > FRC_SINK_FPS)      pass_dir = (d_drop >  0) && (d_rpt == 0);
            else if (FRC_SRC_FPS < FRC_SINK_FPS) pass_dir = (d_rpt  >  0) && (d_drop == 0);
            else                                 pass_dir = (d_drop == 0) && (d_rpt == 0);
            // 2. magnitude
            pass_mag = ((d_drop >= exp_drop - tol) && (d_drop <= exp_drop + tol) &&
                        (d_rpt  >= exp_rpt  - tol) && (d_rpt  <= exp_rpt  + tol));
            // 3. invariant: unique frames delivered must agree on both sides
            // +/-1: the four counters are read as four separate bus
            // transactions, so they are not a coherent snapshot - the input
            // side can advance between reading IN and reading OUT. A one-frame
            // skew is a sampling artifact, not a hardware inconsistency.
            pass_inv = (((d_in - d_drop) - (d_out - d_rpt)) <=  1) &&
                       (((d_in - d_drop) - (d_out - d_rpt)) >= -1);
            // ratios x1000 for integer display
            req_r = (FRC_SRC_FPS * 1000) / FRC_SINK_FPS;
            ach_r = (d_out > 0) ? (d_in * 1000) / d_out : 0;
            // achieved must be within 15% of requested, else the rates never
            // took effect and the drop/repeat numbers are meaningless
            pass_rate = (ach_r * 100 >= req_r * 85) && (ach_r * 100 <= req_r * 115);
            pass_all = pass_dir && pass_mag && pass_inv && pass_rate && (d_out > 0);

            $display("=========== FRC RESULT: %0d -> %0d fps ===========",
                     FRC_SRC_FPS, FRC_SINK_FPS);
            $display("  window          : %0d output frames", d_out);
            $display("  dIN=%0d  dDROPPED=%0d  dOUT=%0d  dREPEATED=%0d",
                     d_in, d_drop, d_out, d_rpt);
            $display("  direction       : %s", pass_dir ? "PASS" : "FAIL");
            $display("  magnitude       : drop %0d (exp ~%0d), rpt %0d (exp ~%0d) : %s",
                     d_drop, exp_drop, d_rpt, exp_rpt, pass_mag ? "PASS" : "FAIL");
            $display("  invariant       : %0d-%0d=%0d vs %0d-%0d=%0d : %s",
                     d_in, d_drop, d_in-d_drop, d_out, d_rpt, d_out-d_rpt,
                     pass_inv ? "PASS" : "FAIL");
            // Requested vs ACHIEVED ratio. Without this a rate that was never
            // applied looks identical to a broken conversion mechanism - which
            // is exactly how the previous run was misread.
            $display("  ratio           : requested %0d.%0d%0d%0d, achieved %0d.%0d%0d%0d%s",
                     req_r/1000, (req_r/100)%10, (req_r/10)%10, req_r%10,
                     ach_r/1000, (ach_r/100)%10, (ach_r/10)%10, ach_r%10,
                     pass_rate ? "" : "   <-- RATES NOT APPLIED");
            $display("  natural period  : %0d cycles/frame (measured); in=%0d out=%0d imposed",
                     nat_period, per_in, per_out);
            $display("================ FRC: %s ================",
                     pass_all ? "PASS" : "FAIL");

            // key=value file the app parses for its popup
            fd = $fopen("../../../../app/frc_result.txt", "w");
            if (fd != 0) begin
                $fwrite(fd, "verdict=%s\n", pass_all ? "PASS" : "FAIL");
                $fwrite(fd, "src_fps=%0d\n", FRC_SRC_FPS);
                $fwrite(fd, "sink_fps=%0d\n", FRC_SINK_FPS);
                $fwrite(fd, "window_frames=%0d\n", d_out);
                $fwrite(fd, "d_in=%0d\n", d_in);
                $fwrite(fd, "d_dropped=%0d\n", d_drop);
                $fwrite(fd, "d_out=%0d\n", d_out);
                $fwrite(fd, "d_repeated=%0d\n", d_rpt);
                $fwrite(fd, "exp_dropped=%0d\n", exp_drop);
                $fwrite(fd, "exp_repeated=%0d\n", exp_rpt);
                $fwrite(fd, "pass_direction=%0d\n", pass_dir);
                $fwrite(fd, "pass_magnitude=%0d\n", pass_mag);
                $fwrite(fd, "pass_invariant=%0d\n", pass_inv);
                $fwrite(fd, "pass_rate=%0d\n", pass_rate);
                $fwrite(fd, "requested_ratio=%0d.%0d%0d%0d\n",
                        req_r/1000, (req_r/100)%10, (req_r/10)%10, req_r%10);
                $fwrite(fd, "achieved_ratio=%0d.%0d%0d%0d\n",
                        ach_r/1000, (ach_r/100)%10, (ach_r/10)%10, ach_r%10);
                $fwrite(fd, "natural_period=%0d\n", nat_period);
                $fwrite(fd, "period_in=%0d\n", per_in);
                $fwrite(fd, "period_out=%0d\n", per_out);
                $fwrite(fd, "frames_captured=%0d\n", frames_captured);
                $fclose(fd);
                $display("[FRC] wrote app/frc_result.txt");
            end
        end
    endtask

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
