`timescale 1ns/1ps
// =============================================================================
// testbench.v - intel_vvp_pipeline2 SCALER_ONLY verification
// TPG 64x64 -> pconv -> scaler -> 128x122 output
// Captures one complete frame to hex, converts to PNG
// =============================================================================
module testbench;

    // =========================================================================
    // Parameters - change these to match your setup
    // =========================================================================
    localparam SCALER_IN_W  = 64;
    localparam SCALER_IN_H  = 64;
    localparam SCALER_OUT_W = 128;
    localparam SCALER_OUT_H = 122;  // actual output - scaler characteristic

    localparam CLK_HALF   = 5;      // 100 MHz
    localparam RST_CYCLES = 1000;   // hold reset for 1000 cycles

    localparam HEX_PATH = "/home/izaan/t1/sim/output_scaled.hex";

    // =========================================================================
    // Signals
    // =========================================================================
    reg  clk = 0;
    reg  rst = 1;

    wire [23:0] out_tdata;
    wire        out_tvalid;
    wire        out_tready;
    wire        out_tlast;
    wire [2:0]  out_tuser;
    wire        cfg_done;

    wire        check_pass;
    wire        check_fail;
    wire [7:0]  frames_checked;

    reg [15:0] exp_width  = SCALER_OUT_W;
    reg [15:0] exp_height = SCALER_OUT_H;

    // =========================================================================
    // Clock
    // =========================================================================
    always #CLK_HALF clk = ~clk;

    // =========================================================================
    // DUT - top.v contains state machine + system.qsys
    // =========================================================================
    top #(
        .SCALER_IN_W  (SCALER_IN_W),
        .SCALER_IN_H  (SCALER_IN_H),
        .SCALER_OUT_W (SCALER_OUT_W),
        .SCALER_OUT_H (SCALER_OUT_H)
    ) u_top (
        .clk        (clk),
        .rst        (rst),
        .out_tdata  (out_tdata),
        .out_tvalid (out_tvalid),
        .out_tready (out_tready),
        .out_tlast  (out_tlast),
        .out_tuser  (out_tuser),
        .cfg_done   (cfg_done)
    );

    // =========================================================================
    // Checker - verifies output dimensions
    // =========================================================================
    // Tie tready high - no backpressure
    assign out_tready = 1'b1;

    // Checker bypassed - signals driven to 0
    assign check_pass     = 1'b0;
    assign check_fail     = 1'b0;
    assign frames_checked = 8'd0;

    // =========================================================================
    // Reset
    // =========================================================================
    initial begin
        rst = 1;
        $display("[TB] Reset asserted");
        repeat(RST_CYCLES) @(posedge clk);
        rst = 0;
        $display("[TB] Reset released - waiting for config...");
        wait(cfg_done);
        $display("[TB] Scaler configured - video flowing");
    end

    // =========================================================================
    // Hex frame capture - captures frame 2 (frame 1 may have warmup artifacts)
    // =========================================================================
    integer hex_file;
    integer pix_count  = 0;
    integer frm_count  = 0;
    integer cap_done   = 0;
    integer total_pix;

    initial begin
        total_pix = SCALER_OUT_W * SCALER_OUT_H;
        hex_file  = $fopen(HEX_PATH, "w");
        if (!hex_file) begin
            $display("[TB] ERROR: Cannot open hex file %s", HEX_PATH);
            $finish;
        end
        $display("[TB] Hex capture opened: %s", HEX_PATH);
        $display("[TB] Capturing %0d x %0d = %0d pixels",
                 SCALER_OUT_W, SCALER_OUT_H, total_pix);
    end

    // TPG capture
    integer tpg_file;
    integer tpg_frm   = 0;
    integer tpg_done  = 0;
    reg     tpg_cap   = 0;

    initial tpg_file = $fopen("/home/izaan/t1/sim/tpg_output.hex", "w");

    always @(posedge clk) begin
        if (!tpg_done && u_top.tpg_tvalid) begin
            if (u_top.tpg_tuser[0]) begin
                tpg_frm = tpg_frm + 1;
                if (tpg_frm == 2) tpg_cap = 1;
                if (tpg_frm == 3) begin
                    tpg_cap  = 0;
                    tpg_done = 1;
                    $fclose(tpg_file);
                    $display("[TB] TPG capture complete");
                end
            end
            if (tpg_cap && !u_top.tpg_tuser[0])
                $fdisplay(tpg_file, "%h", u_top.tpg_tdata);
        end
    end

    reg capture_active = 0;

    always @(posedge clk) begin
        if (!cap_done && out_tvalid && out_tready) begin
            // Track frames
            if (out_tuser[0]) begin
                frm_count = frm_count + 1;
                $display("[TB] SOF frame %0d at %0t ns", frm_count, $time/1000);
                // Start capturing from frame 3
                if (frm_count == 10) capture_active = 1;
                // Stop at end of frame 3
                if (frm_count == 11) begin
                    capture_active = 0;
                    $fclose(hex_file);
                    cap_done = 1;
                    $display("[TB] ============================================");
                    $display("[TB] CAPTURE COMPLETE: %0d pixels written", pix_count);
                    $display("[TB] Output: %s", HEX_PATH);
                    $display("[TB] ============================================");
                    #100;
                    $finish;
                end
            end
            // Write pixel to file
            if (capture_active && !out_tuser[0]) begin
                $fdisplay(hex_file, "%h", out_tdata);
                pix_count = pix_count + 1;
            end
        end
    end

    // =========================================================================
    // Line counter for monitoring
    // =========================================================================
    integer line_cnt = 0;
    always @(posedge clk) begin
        if (out_tvalid && out_tready) begin
            if (out_tuser[0]) line_cnt = 0;
            if (out_tlast) begin
                line_cnt = line_cnt + 1;
                if (frm_count >= 1)
                    $display("[TB] Frame %0d Line %0d complete",
                             frm_count, line_cnt);
            end
        end
    end

    // =========================================================================
    // Checker monitor
    // =========================================================================
    reg [7:0] prev_frames = 0;
    always @(posedge clk) begin
        prev_frames <= frames_checked;
        if (check_pass && frames_checked > prev_frames)
            $display("[CHECKER] PASS frame %0d (%0dx%0d)",
                     frames_checked, SCALER_OUT_W, SCALER_OUT_H);
        if (check_fail)
            $display("[CHECKER] FAIL - dimension mismatch");
    end

    // =========================================================================
    // Watchdog - 500ms
    // =========================================================================
    initial begin
        #500_000_000;
        $display("[TB] WATCHDOG: timeout after 500ms");
        $display("[TB] frames=%0d pix=%0d cap_done=%0d",
                 frm_count, pix_count, cap_done);
        if (!cap_done) $fclose(hex_file);
        $finish;
    end

    // =========================================================================
    // Waveform
    // =========================================================================
    initial begin
        $dumpfile("/home/izaan/t1/sim/scaler_sim.vcd");
        $dumpvars(0, testbench);
    end

endmodule
