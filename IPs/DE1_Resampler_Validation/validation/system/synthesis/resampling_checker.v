`timescale 1 ps / 1 ps
`include "config.vh"

//------------------------------------------------------------------------------
// resampling_checker  (SEQUENTIAL mode: 1 symbol/beat, 8-bit)
//
// Wraps the Platform Designer "system" (TPG 4:4:4 -> Chroma Resampler).  TPG dout
// is looped back into CRS din (the connection Qsys removes when both interfaces
// are exported), both ends are tapped, and an RTL golden model reconstructs the
// expected resampler output and compares it group-by-group, driving status_led.
//
// CONV_MODE selects the conversion under test and is forwarded to the per-config
// expected_group_model.  Two datapaths are provided; the input parser and output
// assembler fork on CONV_MODE while the alignment FIFO, compare and phase
// auto-resync controller are shared.
//
//   CONV_444_TO_444 : input 4:4:4 (Cb,Y,Cr per pixel), output 4:4:4
//                     (pass-through).  Expected group {Cb0, Y0, Cr0, Y1}.
//                     Single-line transform.
//
//   CONV_444_TO_420 : input 4:4:4 (Cb,Cr,Y per pixel), output 4:2:0.
//                     Confirmed CRS output format: 2 bytes per pixel,
//                     4-byte group per pixel-pair {Y0, Cb0, Y1, Cr0}:
//                       even pixel [Y, Cb]  —  odd pixel [Y, Cr]
//                     Both Cb and Cr appear in every line (horizontal
//                     2:1 subsampling only; chroma from even pixel).
//                     All four symbols are REGISTERED before FIFO write
//                     (push fires 1 cycle after six==5; absorbed by the
//                     depth-2048 alignment FIFO).
//
// PHASE AUTO-RESYNC (shared): in gate-level (.vo) cosim the tapped TPG->CRS
// handshake can momentarily miscount by one symbol at content transitions.  The
// status controller detects a sustained mismatch and rotates the input framing
// by one symbol (without flushing the FIFO) until it re-locks.  Only a genuine
// fault -- no framing locks after cycling all rotations -- latches the LED low.
//------------------------------------------------------------------------------
module resampling_checker #(
    parameter integer CONV_MODE = `CRS_CONV_MODE   // default from config.vh
)(
    input  wire        clk_clk,         // Clock
    output wire        status_led       // Status LED: 1 = resampler matches model
);

    localparam integer CONV_444_TO_444 = 0;
    localparam integer CONV_OTHER       = 1;
    localparam integer CONV_444_TO_420  = 2;

    localparam [3:0]   PKT_VIDEO = 4'h0; // Avalon-ST Video data-packet type nibble
    localparam integer PAIRS_PER_LINE = 960;  // 1920 px / 2 -> pixel-pairs per line

    //--------------------------------------------------------------------------
    // Power-on reset: hold reset for the first 32 clocks so the VIP cores init.
    //--------------------------------------------------------------------------
    reg [4:0] por_cnt     = 5'd0;
    reg       reset_reset = 1'b1;
    always @(posedge clk_clk) begin
        if (por_cnt != 5'h1f) por_cnt <= por_cnt + 1'b1;
        else                  reset_reset <= 1'b0;
    end

    //--------------------------------------------------------------------------
    // Interconnect / tap nets (8-bit, one symbol per beat).
    //--------------------------------------------------------------------------
    wire [7:0] tpg_data;
    wire       tpg_valid, tpg_sop, tpg_eop, tpg_ready;
    wire [7:0] crs_dout_data;
    wire       crs_dout_valid, crs_dout_startofpacket, crs_dout_endofpacket;
    wire       crs_dout_ready;
    assign     crs_dout_ready = 1'b1;   // always ready

    system dut (
        .clk_clk(clk_clk),
        .reset_reset_n(!reset_reset),
        // TPG source (out of system)
        .alt_vip_tpg_0_dout_data(tpg_data),
        .alt_vip_tpg_0_dout_valid(tpg_valid),
        .alt_vip_tpg_0_dout_startofpacket(tpg_sop),
        .alt_vip_tpg_0_dout_endofpacket(tpg_eop),
        .alt_vip_tpg_0_dout_ready(tpg_ready),
        // CRS sink (into system) -- driven by the TPG source above
        .alt_vip_crs_0_din_data(tpg_data),
        .alt_vip_crs_0_din_valid(tpg_valid),
        .alt_vip_crs_0_din_startofpacket(tpg_sop),
        .alt_vip_crs_0_din_endofpacket(tpg_eop),
        .alt_vip_crs_0_din_ready(tpg_ready),
        // CRS source (out of system)
        .alt_vip_crs_0_dout_data(crs_dout_data),
        .alt_vip_crs_0_dout_valid(crs_dout_valid),
        .alt_vip_crs_0_dout_startofpacket(crs_dout_startofpacket),
        .alt_vip_crs_0_dout_endofpacket(crs_dout_endofpacket),
        .alt_vip_crs_0_dout_ready(crs_dout_ready)
    );

    //--------------------------------------------------------------------------
    // Datapath interface (driven inside the CONV_MODE generate branches).
    //   exp_group / push_group : expected group + write strobe (input side)
    //   act_group / out_done   : assembled actual group + complete strobe (out)
    //   rotate_tgl / rotate_ack: one-symbol input-frame rotation handshake
    //--------------------------------------------------------------------------
    wire [31:0] exp_group;
    wire        push_group;
    wire [31:0] act_group;
    wire        out_done;
    reg         rotate_tgl = 1'b0;      // driven by the status controller below

    // Shared input qualifiers.
    wire in_is_sop  = tpg_valid && tpg_sop;
    wire out_is_sop = crs_dout_valid && crs_dout_startofpacket;

    //==========================================================================
    // INPUT side -- build the expected group stream.
    //==========================================================================
    generate
    if (CONV_MODE == CONV_444_TO_420) begin : GEN_IN_420
        // 4:4:4 input parsed as mod-6 per pixel-pair.
        // Altera VIP TPG sequential YUV444 output order: Cb, Y, Cr per pixel.
        //   six=0: Cb0  → cb_e
        //   six=1: Y0   → y0_e   (NOT Cr — TPG sends Y second)
        //   six=2: Cr0  → cr_e   (NOT Y  — TPG sends Cr third)
        //   six=3: Cb1  → drop   (odd pixel, horizontal 2:1 subsampling)
        //   six=4: Y1   → y1_e   (MUST capture — was wrongly dropped before)
        //   six=5: Cr1  → drop; push {Y0,Cb0,Y1,Cr0} with all stored values
        //
        // CRS YUV420 output (confirmed): 2 bytes per pixel
        //   even pixel k=2n:   [Y_k , Cb_n]
        //   odd  pixel k=2n+1: [Y_k , Cr_n]
        // 4-byte group per pixel pair: {Y0, Cb0, Y1, Cr0}
        //
        // All four symbols are REGISTERED into grp_reg at the six==5 edge.
        // push_reg fires the FIFO write one cycle later, so the FIFO always
        // sees fully-settled, glitch-free data.

        reg        in_video   = 1'b0;
        reg  [2:0] six        = 3'd0;
        reg  [7:0] cb_e       = 8'd0;    // Cb of even pixel
        reg  [7:0] cr_e       = 8'd0;    // Cr of even pixel
        reg  [7:0] y0_e       = 8'd0;    // Y  of even pixel
        reg  [7:0] y1_e       = 8'd0;    // Y  of odd  pixel
        reg [31:0] grp_reg    = 32'd0;   // fully-registered expected group
        reg        push_reg   = 1'b0;    // one-cycle-delayed FIFO write strobe
        reg        rotate_ack = 1'b0;

        wire       rotate_pending = (rotate_tgl != rotate_ack);
        wire       in_pixel = tpg_valid && tpg_ready && in_video && !tpg_sop;

        // Deliver fully-registered group and strobe to the shared FIFO.
        assign exp_group  = grp_reg;
        assign push_group = push_reg;

        always @(posedge clk_clk) begin
            push_reg <= 1'b0;   // default: no push this cycle
            if (reset_reset) begin
                in_video <= 1'b0; six <= 3'd0; rotate_ack <= 1'b0;
                grp_reg  <= 32'd0;
            end else if (in_is_sop) begin
                in_video   <= (tpg_data[3:0] == PKT_VIDEO);
                six        <= 3'd0;
                rotate_ack <= rotate_tgl;
            end else if (in_pixel) begin
                if (rotate_pending) begin
                    rotate_ack <= rotate_tgl;
                end else begin
                    case (six)
                        3'd0: cb_e <= tpg_data;   // Cb0
                        3'd1: y0_e <= tpg_data;   // Y0  (TPG: Cb,Y,Cr order)
                        3'd2: cr_e <= tpg_data;   // Cr0
                        // 3'd3: Cb1 — drop
                        3'd4: y1_e <= tpg_data;   // Y1 — capture (was wrongly dropped)
                        3'd5: begin               // Cr1 arrives — push with all stored
                            grp_reg  <= {y0_e, cb_e, y1_e, cr_e}; // {Y0,Cb0,Y1,Cr0}
                            push_reg <= 1'b1;
                        end
                        default: ;
                    endcase
                    six <= (six == 3'd5) ? 3'd0 : six + 1'b1;
                end
            end
        end
    end else begin : GEN_IN_444
        // 4:4:4 -> 4:4:4 pass-through: mod-6 pixel-pair, expected group {Cb0, Y0, Cr0, Y1}.
        reg        in_video = 1'b0;
        reg  [2:0] six      = 3'd0;
        reg  [7:0] cb0      = 8'd0;
        reg  [7:0] cr0      = 8'd0;
        reg  [7:0] y0       = 8'd0;
        reg        rotate_ack = 1'b0;

        wire       rotate_pending = (rotate_tgl != rotate_ack);
        wire       in_pixel = tpg_valid && tpg_ready && in_video && !tpg_sop;

        expected_group_model #(.CONV_MODE(CONV_MODE)) u_exp_model (
            .cb0(cb0), .cr0(cr0), .y0(y0), .y1(tpg_data), .c(8'h00),
            .exp_group(exp_group)
        );

        assign push_group = in_pixel && !rotate_pending && (six == 3'd5);

        always @(posedge clk_clk) begin
            if (reset_reset) begin
                in_video <= 1'b0; six <= 3'd0; rotate_ack <= 1'b0;
            end else if (in_is_sop) begin
                in_video   <= (tpg_data[3:0] == PKT_VIDEO);
                six        <= 3'd0;
                rotate_ack <= rotate_tgl;
            end else if (in_pixel) begin
                if (rotate_pending) begin
                    rotate_ack <= rotate_tgl;
                end else begin
                    case (six)
                        3'd0: cb0 <= tpg_data;
                        3'd1: cr0 <= tpg_data;
                        3'd2: y0  <= tpg_data;
                        default: ;
                    endcase
                    six <= (six == 3'd5) ? 3'd0 : six + 1'b1;
                end
            end
        end
    end
    endgenerate

    //==========================================================================
    // OUTPUT side -- assemble the actual group from the resampler output stream.
    //==========================================================================
    generate
    if (CONV_MODE == CONV_444_TO_420) begin : GEN_OUT_420
        // 4:2:0 output confirmed format: 2 bytes/pixel, 4-byte group per pixel-pair.
        //   beat 4k+0 : Y0  (even pixel luma)
        //   beat 4k+1 : Cb0 (shared Cb for the pair)
        //   beat 4k+2 : Y1  (odd pixel luma)
        //   beat 4k+3 : Cr0 (shared Cr for the pair)
        // 1920 pixels/line × 2 bytes = 3840 symbols/line = 960 groups of 4.
        // Phase free-runs across line boundaries (3840 / 4 = 960, exactly).
        reg        out_video = 1'b0;
        reg  [1:0] out_phase = 2'd0;     // 0:Y0  1:Cb  2:Y1  3:Cr
        reg  [7:0] o_y0      = 8'd0;
        reg  [7:0] o_cb      = 8'd0;
        reg  [7:0] o_y1      = 8'd0;
        wire       out_pixel = crs_dout_valid && crs_dout_ready && out_video && !crs_dout_startofpacket;

        assign out_done  = out_pixel && (out_phase == 2'd3);
        assign act_group = {o_y0, o_cb, o_y1, crs_dout_data};  // {Y0,Cb,Y1,Cr}

        always @(posedge clk_clk) begin
            if (reset_reset) begin
                out_video <= 1'b0; out_phase <= 2'd0;
            end else if (out_is_sop) begin
                out_video <= (crs_dout_data[3:0] == PKT_VIDEO);
                out_phase <= 2'd0;
            end else if (out_pixel) begin
                case (out_phase)
                    2'd0: o_y0 <= crs_dout_data;
                    2'd1: o_cb <= crs_dout_data;
                    2'd2: o_y1 <= crs_dout_data;
                    default: ;
                endcase
                out_phase <= (out_phase == 2'd3) ? 2'd0 : out_phase + 1'b1;
            end
        end
    end else begin : GEN_OUT_444
        // 4:4:4 output (pass-through): 4-phase group {Cb,Y0,Cr,Y1}.
        reg        out_video = 1'b0;
        reg  [1:0] out_phase = 2'd0;     // 0:Cb 1:Y0 2:Cr 3:Y1
        reg  [7:0] o_cb       = 8'd0;
        reg  [7:0] o_y0       = 8'd0;
        reg  [7:0] o_cr       = 8'd0;
        wire       out_pixel  = crs_dout_valid && crs_dout_ready && out_video && !crs_dout_startofpacket;

        assign out_done  = out_pixel && (out_phase == 2'd3);
        assign act_group = {o_cb, o_y0, o_cr, crs_dout_data};

        always @(posedge clk_clk) begin
            if (reset_reset) begin
                out_video <= 1'b0; out_phase <= 2'd0;
            end else if (out_is_sop) begin
                out_video <= (crs_dout_data[3:0] == PKT_VIDEO);
                out_phase <= 2'd0;
            end else if (out_pixel) begin
                case (out_phase)
                    2'd0: o_cb <= crs_dout_data;
                    2'd1: o_y0 <= crs_dout_data;
                    2'd2: o_cr <= crs_dout_data;
                    default: ;
                endcase
                out_phase <= (out_phase == 2'd3) ? 2'd0 : out_phase + 1'b1;
            end
        end
    end
    endgenerate

    //==========================================================================
    // Latency-alignment FIFO (shared): queue expected groups, dequeue per output
    // group.  The 420 input model fires push_reg one cycle AFTER six==5, adding
    // 1 extra group of latency vs the 444 path, which is well within the
    // depth-2048 (FIFO_AW=11) FIFO used in 420 mode.
    //==========================================================================
    localparam integer FIFO_AW    = (CONV_MODE == CONV_444_TO_420) ? 11 : 8;
    localparam integer FIFO_DEPTH = (1 << FIFO_AW);

    reg  [31:0]        fifo_mem [0:FIFO_DEPTH-1];
    reg  [FIFO_AW-1:0] wr_ptr     = {FIFO_AW{1'b0}};
    reg  [FIFO_AW-1:0] rd_ptr     = {FIFO_AW{1'b0}};
    reg  [FIFO_AW:0]   fifo_count = {(FIFO_AW+1){1'b0}};

    wire wr_en      = push_group;
    wire fifo_empty = (fifo_count == 0);
    wire do_rd      = out_done && !fifo_empty;
    wire [31:0] fifo_rd_data = fifo_mem[rd_ptr];

    always @(posedge clk_clk) begin
        if (reset_reset) begin
            wr_ptr <= {FIFO_AW{1'b0}}; rd_ptr <= {FIFO_AW{1'b0}};
            fifo_count <= {(FIFO_AW+1){1'b0}};
        end else begin
            if (wr_en) begin
                fifo_mem[wr_ptr] <= exp_group;
                wr_ptr           <= wr_ptr + 1'b1;
            end
            if (do_rd) rd_ptr <= rd_ptr + 1'b1;
            case ({wr_en, do_rd})
                2'b10:   fifo_count <= fifo_count + 1'b1;
                2'b01:   fifo_count <= fifo_count - 1'b1;
                default: fifo_count <= fifo_count;
            endcase
        end
    end

    //==========================================================================
    // Status + phase auto-resync controller (shared).
    //==========================================================================
    localparam [2:0] MIS_THRESH = 3'd3;   // mismatches before a rotate
    localparam [3:0] LOCK_RUN   = 4'd8;   // matches to declare locked
    localparam [3:0] MAX_TRIES  = 4'd9;   // rotate attempts before declaring fault

    reg [2:0]  mis_run     = 3'd0;
    reg [3:0]  lock_run    = 4'd0;
    reg [3:0]  tries       = 4'd0;
    reg        err_latched = 1'b0;

    // Simulation-only diagnostic counters (synthesised away on FPGA).
    `ifdef SIMULATION
    integer grp_total   = 0;   // groups compared so far
    integer grp_match_n = 0;   // groups that matched
    integer grp_mis_n   = 0;   // groups that mismatched
    `endif

    wire grp_match = (act_group == fifo_rd_data);

    always @(posedge clk_clk) begin
        if (reset_reset) begin
            mis_run <= 3'd0; lock_run <= 4'd0; tries <= 4'd0;
            err_latched <= 1'b0; rotate_tgl <= 1'b0;
        end else if (do_rd) begin
            // ------------------------------------------------------------------
            // Simulation diagnostics: print every mismatch.
            // ------------------------------------------------------------------
            `ifdef SIMULATION
            grp_total = grp_total + 1;
            if (grp_match) begin
                grp_match_n = grp_match_n + 1;
            end else begin
                grp_mis_n = grp_mis_n + 1;
                $display("[CHECKER] t=%0t  MISMATCH #%0d (grp %0d)",
                         $time, grp_mis_n, grp_total);
                $display("  ACT: Y0=%02X Cb=%02X Y1=%02X Cr=%02X  (raw=%08X)",
                         act_group[31:24], act_group[23:16],
                         act_group[15: 8], act_group[ 7: 0], act_group);
                $display("  EXP: Y0=%02X Cb=%02X Y1=%02X Cr=%02X  (raw=%08X)",
                         fifo_rd_data[31:24], fifo_rd_data[23:16],
                         fifo_rd_data[15: 8], fifo_rd_data[ 7: 0], fifo_rd_data);
            end
            `endif

            // ------------------------------------------------------------------
            // RTL state machine (match/rotate/fault).
            // ------------------------------------------------------------------
            if (grp_match) begin
                mis_run <= 3'd0;
                if (lock_run >= LOCK_RUN) tries <= 4'd0;
                else                      lock_run <= lock_run + 1'b1;
            end else begin
                lock_run <= 4'd0;
                if (mis_run >= (MIS_THRESH - 1'b1)) begin
                    mis_run    <= 3'd0;
                    rotate_tgl <= ~rotate_tgl;
                    `ifdef SIMULATION
                    $display("[CHECKER] t=%0t  rotating input phase (try %0d/%0d)",
                             $time, tries+1, MAX_TRIES);
                    `endif
                    if (tries >= MAX_TRIES) begin
                        err_latched <= 1'b1;
                        `ifdef SIMULATION
                        $display("[CHECKER] t=%0t  FAULT LATCHED: status_led=0  matched=%0d  mismatched=%0d",
                                 $time, grp_match_n, grp_mis_n);
                        `endif
                    end else begin
                        tries <= tries + 1'b1;
                    end
                end else begin
                    mis_run <= mis_run + 1'b1;
                end
            end
        end
    end

    `ifdef SIMULATION
    // Print a running match summary every 960 groups (one output line).
    localparam integer REPORT_INTERVAL = 960;
    always @(posedge clk_clk) begin
        if (!reset_reset && do_rd && (grp_total % REPORT_INTERVAL == 0) && grp_total > 0)
            $display("[CHECKER] t=%0t  line done: total=%0d  match=%0d  mismatch=%0d  err=%0b",
                     $time, grp_total, grp_match_n, grp_mis_n, err_latched);
    end
    `endif

    assign status_led = !err_latched;

endmodule

