`timescale 1 ps / 1 ps

// =============================================================================
// top.v — Color Space Converter Controller
//
// Parameter: MODE selects the CSC coefficient set loaded at startup.
//   0 = CSC_PASSTHROUGH       (RGB → RGB, identity)
//   1 = CSC_RGB_TO_YCBCRHD    (RGB → YCbCr HD / BT.709)
//   2 = CSC_YCBCRHD_TO_RGB    (YCbCr HD → RGB)
//   3 = CSC_RGB_TO_YCBCRSD    (RGB → YCbCr SD / BT.601)
//   4 = CSC_YCBCRSD_TO_RGB    (YCbCr SD → RGB)
//
// Fixed-point format: Q10.21 signed (1 sign + 10 integer + 21 fractional bits)
// =============================================================================

module top #(
    parameter [2:0] MODE = 3'd0   // Select coefficient set (0–4)
) (
    input  wire        clk_clk,
    input  wire        reset_reset,

    // AXI4-Stream Video Output from the pipeline
    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser
);

    // -------------------------------------------------------------------------
    // Local Parameters & Register Offsets
    // -------------------------------------------------------------------------
    // Addresses are word-aligned (Byte Address >> 2)
    localparam [8:0] ADDR_CSC_STATUS     = 9'h50; // 0x0140
    localparam [8:0] ADDR_CSC_COMMIT     = 9'h51; // 0x0144
    localparam [8:0] ADDR_CSC_COEFF_A0   = 9'h52; // 0x0148
    localparam [8:0] ADDR_CSC_COEFF_B0   = 9'h53; // 0x014C
    localparam [8:0] ADDR_CSC_COEFF_C0   = 9'h54; // 0x0150
    localparam [8:0] ADDR_CSC_COEFF_A1   = 9'h55; // 0x0154
    localparam [8:0] ADDR_CSC_COEFF_B1   = 9'h56; // 0x0158
    localparam [8:0] ADDR_CSC_COEFF_C1   = 9'h57; // 0x015C
    localparam [8:0] ADDR_CSC_COEFF_A2   = 9'h58; // 0x0160
    localparam [8:0] ADDR_CSC_COEFF_B2   = 9'h59; // 0x0164
    localparam [8:0] ADDR_CSC_COEFF_C2   = 9'h5A; // 0x0168
    localparam [8:0] ADDR_CSC_SUMMAND_S0 = 9'h5B; // 0x016C
    localparam [8:0] ADDR_CSC_SUMMAND_S1 = 9'h5C; // 0x0170
    localparam [8:0] ADDR_CSC_SUMMAND_S2 = 9'h5D; // 0x0174
    localparam [8:0] ADDR_CSC_OUT_CS     = 9'h5E; // 0x0178

    // State Encoding
    localparam [3:0]
        ST_IDLE        = 4'd0,
        ST_WR_COEFF_A  = 4'd1,
        ST_WR_COEFF_B  = 4'd2,
        ST_WR_COEFF_C  = 4'd3,
        ST_WR_SUMMANDS = 4'd4,
        ST_WR_OUT_CS   = 4'd5,
        ST_WR_COMMIT   = 4'd6,
        ST_POLL_STATUS = 4'd7,
        ST_OPERATIONAL = 4'd8;

    // =========================================================================
    // Coefficient ROMs  (Q10.21 signed, 32-bit)
    //
    // Row layout per mode: [A0, A1, A2, B0, B1, B2, C0, C1, C2, S0, S1, S2]
    // Indices            :  [0]  [1]  [2]  [3]  [4]  [5]  [6]  [7]  [8]  [9] [10] [11]
    // =========================================================================

    // ----- MODE 0 : PASSTHROUGH -----
    // Identity matrix, zero offsets
    localparam signed [31:0] PT_A0 = 32'sh00200000; // +1.000
    localparam signed [31:0] PT_A1 = 32'sh00000000; // +0.000
    localparam signed [31:0] PT_A2 = 32'sh00000000; // +0.000
    localparam signed [31:0] PT_B0 = 32'sh00000000; // +0.000
    localparam signed [31:0] PT_B1 = 32'sh00200000; // +1.000
    localparam signed [31:0] PT_B2 = 32'sh00000000; // +0.000
    localparam signed [31:0] PT_C0 = 32'sh00000000; // +0.000
    localparam signed [31:0] PT_C1 = 32'sh00000000; // +0.000
    localparam signed [31:0] PT_C2 = 32'sh00200000; // +1.000
    localparam signed [31:0] PT_S0 = 32'sh00000000; // +0.000
    localparam signed [31:0] PT_S1 = 32'sh00000000; // +0.000
    localparam signed [31:0] PT_S2 = 32'sh00000000; // +0.000

    // ----- MODE 1 : RGB → YCbCr HD (BT.709) -----
    localparam signed [31:0] RH_A0 = 32'sh000E0C4A; // +0.439
    localparam signed [31:0] RH_A1 = 32'sh0001FBE7; // +0.062
    localparam signed [31:0] RH_A2 = 32'shFFFEB852; // -0.040
    localparam signed [31:0] RH_B0 = 32'shFFF52F1B; // -0.338
    localparam signed [31:0] RH_B1 = 32'sh0013A5E3; // +0.614
    localparam signed [31:0] RH_B2 = 32'shFFF33B64; // -0.399
    localparam signed [31:0] RH_C0 = 32'shFFFCC49C; // -0.101
    localparam signed [31:0] RH_C1 = 32'sh0005DB23; // +0.183
    localparam signed [31:0] RH_C2 = 32'sh000E0C4A; // +0.439
    localparam signed [31:0] RH_S0 = 32'sh10000000; // +128.000
    localparam signed [31:0] RH_S1 = 32'sh02000000; //  +16.000
    localparam signed [31:0] RH_S2 = 32'sh10000000; // +128.000

    // ----- MODE 2 : YCbCr HD (BT.709) → RGB -----
    localparam signed [31:0] HR_A0 = 32'sh0043AE14; // +2.115
    localparam signed [31:0] HR_A1 = 32'shFFF92F1B; // -0.213
    localparam signed [31:0] HR_A2 = 32'sh00000000; // +0.000
    localparam signed [31:0] HR_B0 = 32'sh00253F7D; // +1.164
    localparam signed [31:0] HR_B1 = 32'sh00253F7D; // +1.164
    localparam signed [31:0] HR_B2 = 32'sh00253F7D; // +1.164
    localparam signed [31:0] HR_C0 = 32'sh00000000; // +0.000
    localparam signed [31:0] HR_C1 = 32'shFFEEE979; // -0.534
    localparam signed [31:0] HR_C2 = 32'sh00396042; // +1.793
    localparam signed [31:0] HR_S0 = 32'shDBD4FDF4; //  -289.344
    localparam signed [31:0] HR_S1 = 32'sh099FBE77; //   +76.992
    localparam signed [31:0] HR_S2 = 32'shE0FBE00D; //  -248.129

    // ----- MODE 3 : RGB → YCbCr SD (BT.601) -----
    localparam signed [31:0] RS_A0 = 32'sh000E0C4A; // +0.439
	 localparam signed [31:0] RS_A1 = 32'sh000322D1; // +0.098
    localparam signed [31:0] RS_A2 = 32'shFFFDBA5E; // -0.071
    localparam signed [31:0] RS_B0 = 32'shFFF6B021; // -0.291
    localparam signed [31:0] RS_B1 = 32'sh001020C5; // +0.504
    localparam signed [31:0] RS_B2 = 32'shFFF43958; // -0.368
    localparam signed [31:0] RS_C0 = 32'shFFFB4396; // -0.148
    localparam signed [31:0] RS_C1 = 32'sh00083958; // +0.257
    localparam signed [31:0] RS_C2 = 32'sh000E0C4A; // +0.439
    localparam signed [31:0] RS_S0 = 32'sh10000000; // +128.000
    localparam signed [31:0] RS_S1 = 32'sh02000000; //  +16.000
    localparam signed [31:0] RS_S2 = 32'sh10000000; // +128.000

    // ----- MODE 4 : YCbCr SD (BT.601) → RGB -----
    localparam signed [31:0] SR_A0 = 32'sh003A1CAC; // +1.816
    localparam signed [31:0] SR_A1 = 32'shFFFA24DD; // -0.183
    localparam signed [31:0] SR_A2 = 32'sh00000000; // +0.000
    localparam signed [31:0] SR_B0 = 32'sh00200000; // +1.000
    localparam signed [31:0] SR_B1 = 32'sh00200000; // +1.000
    localparam signed [31:0] SR_B2 = 32'sh00200000; // +1.000
    localparam signed [31:0] SR_C0 = 32'sh00000000; // +0.000
    localparam signed [31:0] SR_C1 = 32'shFFF14FDF; // -0.459
    localparam signed [31:0] SR_C2 = 32'sh003147AE; // +1.540
    localparam signed [31:0] SR_S0 = 32'shE2F1A9FC; // -232.448
    localparam signed [31:0] SR_S1 = 32'sh0A45A1CB; //  +82.176
    localparam signed [31:0] SR_S2 = 32'shE75C20C5; // -197.121

    // =========================================================================
    // Mux: select coefficients based on MODE parameter (resolved at synthesis)
    // =========================================================================
    wire signed [31:0] coeff_a0, coeff_a1, coeff_a2;
    wire signed [31:0] coeff_b0, coeff_b1, coeff_b2;
    wire signed [31:0] coeff_c0, coeff_c1, coeff_c2;
    wire signed [31:0] coeff_s0, coeff_s1, coeff_s2;
    wire        [31:0] csc_out_cs; // color-space metadata written to OUT_CS register

    assign coeff_a0   = (MODE == 3'd1) ? RH_A0 :
                        (MODE == 3'd2) ? HR_A0 :
                        (MODE == 3'd3) ? RS_A0 :
                        (MODE == 3'd4) ? SR_A0 : PT_A0;

    assign coeff_a1   = (MODE == 3'd1) ? RH_A1 :
                        (MODE == 3'd2) ? HR_A1 :
                        (MODE == 3'd3) ? RS_A1 :
                        (MODE == 3'd4) ? SR_A1 : PT_A1;

    assign coeff_a2   = (MODE == 3'd1) ? RH_A2 :
                        (MODE == 3'd2) ? HR_A2 :
                        (MODE == 3'd3) ? RS_A2 :
                        (MODE == 3'd4) ? SR_A2 : PT_A2;

    assign coeff_b0   = (MODE == 3'd1) ? RH_B0 :
                        (MODE == 3'd2) ? HR_B0 :
                        (MODE == 3'd3) ? RS_B0 :
                        (MODE == 3'd4) ? SR_B0 : PT_B0;

    assign coeff_b1   = (MODE == 3'd1) ? RH_B1 :
                        (MODE == 3'd2) ? HR_B1 :
                        (MODE == 3'd3) ? RS_B1 :
                        (MODE == 3'd4) ? SR_B1 : PT_B1;

    assign coeff_b2   = (MODE == 3'd1) ? RH_B2 :
                        (MODE == 3'd2) ? HR_B2 :
                        (MODE == 3'd3) ? RS_B2 :
                        (MODE == 3'd4) ? SR_B2 : PT_B2;

    assign coeff_c0   = (MODE == 3'd1) ? RH_C0 :
                        (MODE == 3'd2) ? HR_C0 :
                        (MODE == 3'd3) ? RS_C0 :
                        (MODE == 3'd4) ? SR_C0 : PT_C0;

    assign coeff_c1   = (MODE == 3'd1) ? RH_C1 :
                        (MODE == 3'd2) ? HR_C1 :
                        (MODE == 3'd3) ? RS_C1 :
                        (MODE == 3'd4) ? SR_C1 : PT_C1;

    assign coeff_c2   = (MODE == 3'd1) ? RH_C2 :
                        (MODE == 3'd2) ? HR_C2 :
                        (MODE == 3'd3) ? RS_C2 :
                        (MODE == 3'd4) ? SR_C2 : PT_C2;

    assign coeff_s0   = (MODE == 3'd1) ? RH_S0 :
                        (MODE == 3'd2) ? HR_S0 :
                        (MODE == 3'd3) ? RS_S0 :
                        (MODE == 3'd4) ? SR_S0 : PT_S0;

    assign coeff_s1   = (MODE == 3'd1) ? RH_S1 :
                        (MODE == 3'd2) ? HR_S1 :
                        (MODE == 3'd3) ? RS_S1 :
                        (MODE == 3'd4) ? SR_S1 : PT_S1;

    assign coeff_s2   = (MODE == 3'd1) ? RH_S2 :
                        (MODE == 3'd2) ? HR_S2 :
                        (MODE == 3'd3) ? RS_S2 :
                        (MODE == 3'd4) ? SR_S2 : PT_S2;

    // OUT_CS metadata: 0 = RGB, 1 = YCbCr
    // Modes 1 and 3 convert TO YCbCr; all others output RGB.
    assign csc_out_cs = ((MODE == 3'd1) || (MODE == 3'd3)) ? 32'd1 : 32'd0;

    // =========================================================================
    // Control Signals
    // =========================================================================
    reg [3:0]  current_state;
    reg [1:0]  sub_step;
    reg [8:0]  mgmt_addr;
    reg        mgmt_write, mgmt_read;
    reg [31:0] mgmt_wdata;

    wire [31:0] mgmt_readdata;
    wire        mgmt_readdatavalid;
    wire        mgmt_waitrequest;

    // =========================================================================
    // Configuration State Machine
    // =========================================================================
    always @(posedge clk_clk or posedge reset_reset) begin
        if (reset_reset) begin
            current_state <= ST_IDLE;
            mgmt_write    <= 1'b0;
            mgmt_read     <= 1'b0;
            sub_step      <= 2'd0;
        end else begin
            case (current_state)

                // ── Kick off immediately after reset ──────────────────────────
                ST_IDLE: current_state <= ST_WR_COEFF_A;

                // ── Write A0, A1, A2 ─────────────────────────────────────────
                ST_WR_COEFF_A: begin
                    mgmt_write <= 1'b1;
                    case (sub_step)
                        2'd0: begin mgmt_addr <= ADDR_CSC_COEFF_A0; mgmt_wdata <= coeff_a0; end
                        2'd1: begin mgmt_addr <= ADDR_CSC_COEFF_A1; mgmt_wdata <= coeff_a1; end
                        2'd2: begin mgmt_addr <= ADDR_CSC_COEFF_A2; mgmt_wdata <= coeff_a2; end
                        default: ;
                    endcase
                    if (!mgmt_waitrequest) begin
                        if (sub_step == 2'd2) begin
                            sub_step      <= 2'd0;
                            current_state <= ST_WR_COEFF_B;
                        end else
                            sub_step <= sub_step + 1'b1;
                    end
                end

                // ── Write B0, B1, B2 ─────────────────────────────────────────
                ST_WR_COEFF_B: begin
                    mgmt_write <= 1'b1;
                    case (sub_step)
                        2'd0: begin mgmt_addr <= ADDR_CSC_COEFF_B0; mgmt_wdata <= coeff_b0; end
                        2'd1: begin mgmt_addr <= ADDR_CSC_COEFF_B1; mgmt_wdata <= coeff_b1; end
                        2'd2: begin mgmt_addr <= ADDR_CSC_COEFF_B2; mgmt_wdata <= coeff_b2; end
                        default: ;
                    endcase
                    if (!mgmt_waitrequest) begin
                        if (sub_step == 2'd2) begin
                            sub_step      <= 2'd0;
                            current_state <= ST_WR_COEFF_C;
                        end else
                            sub_step <= sub_step + 1'b1;
                    end
                end

                // ── Write C0, C1, C2 ─────────────────────────────────────────
                ST_WR_COEFF_C: begin
                    mgmt_write <= 1'b1;
                    case (sub_step)
                        2'd0: begin mgmt_addr <= ADDR_CSC_COEFF_C0; mgmt_wdata <= coeff_c0; end
                        2'd1: begin mgmt_addr <= ADDR_CSC_COEFF_C1; mgmt_wdata <= coeff_c1; end
                        2'd2: begin mgmt_addr <= ADDR_CSC_COEFF_C2; mgmt_wdata <= coeff_c2; end
                        default: ;
                    endcase
                    if (!mgmt_waitrequest) begin
                        if (sub_step == 2'd2) begin
                            sub_step      <= 2'd0;
                            current_state <= ST_WR_SUMMANDS;
                        end else
                            sub_step <= sub_step + 1'b1;
                    end
                end

                // ── Write S0, S1, S2 ─────────────────────────────────────────
                ST_WR_SUMMANDS: begin
                    mgmt_write <= 1'b1;
                    case (sub_step)
                        2'd0: begin mgmt_addr <= ADDR_CSC_SUMMAND_S0; mgmt_wdata <= coeff_s0; end
                        2'd1: begin mgmt_addr <= ADDR_CSC_SUMMAND_S1; mgmt_wdata <= coeff_s1; end
                        2'd2: begin mgmt_addr <= ADDR_CSC_SUMMAND_S2; mgmt_wdata <= coeff_s2; end
                        default: ;
                    endcase
                    if (!mgmt_waitrequest) begin
                        if (sub_step == 2'd2) begin
                            sub_step      <= 2'd0;
                            current_state <= ST_WR_OUT_CS;
                        end else
                            sub_step <= sub_step + 1'b1;
                    end
                end

                // ── Write output color-space metadata ────────────────────────
                ST_WR_OUT_CS: begin
                    mgmt_write <= 1'b1;
                    mgmt_addr  <= ADDR_CSC_OUT_CS;
                    mgmt_wdata <= csc_out_cs;
                    if (!mgmt_waitrequest) begin
                        mgmt_write    <= 1'b0;
                        current_state <= ST_WR_COMMIT;
                    end
                end

                // ── Commit all registers ──────────────────────────────────────
                ST_WR_COMMIT: begin
                    mgmt_write <= 1'b1;
                    mgmt_addr  <= ADDR_CSC_COMMIT;
                    mgmt_wdata <= 32'hFFFFFFFF;
                    if (!mgmt_waitrequest) begin
                        mgmt_write    <= 1'b0;
                        current_state <= ST_POLL_STATUS;
                    end
                end

                // ── Poll status until commit has been absorbed ────────────────
                ST_POLL_STATUS: begin
                    if (sub_step == 2'd0) begin
                        mgmt_read <= 1'b1;
                        mgmt_addr <= ADDR_CSC_STATUS;
                        if (!mgmt_waitrequest) begin
                            mgmt_read <= 1'b0;
                            sub_step  <= 2'd1;
                        end
                    end else begin
                        if (mgmt_readdatavalid) begin
                            sub_step <= 2'd0;
                            if (mgmt_readdata[1] == 1'b0)
                                current_state <= ST_OPERATIONAL;
                        end
                    end
                end

                // ── Done — hold here ──────────────────────────────────────────
                ST_OPERATIONAL: begin
                    mgmt_write <= 1'b0;
                    mgmt_read  <= 1'b0;
                end

                default: current_state <= ST_IDLE;

            endcase
        end
    end

    // =========================================================================
    // Platform Designer Instance
    // =========================================================================
    color_space csc_inst (
        .clk_clk                              (clk_clk),
        .reset_reset                          (reset_reset),

        // Video Output (External)
        .intel_vvp_csc_0_axi4s_vid_out_tdata  (out_tdata),
        .intel_vvp_csc_0_axi4s_vid_out_tvalid (out_tvalid),
        .intel_vvp_csc_0_axi4s_vid_out_tready (out_tready),
        .intel_vvp_csc_0_axi4s_vid_out_tlast  (out_tlast),
        .intel_vvp_csc_0_axi4s_vid_out_tuser  (out_tuser),

        // Management Interface (Connected to State Machine)
        .intel_vvp_csc_0_av_mm_control_agent_address      (mgmt_addr),
        .intel_vvp_csc_0_av_mm_control_agent_write        (mgmt_write),
        .intel_vvp_csc_0_av_mm_control_agent_read         (mgmt_read),
        .intel_vvp_csc_0_av_mm_control_agent_writedata    (mgmt_wdata),
        .intel_vvp_csc_0_av_mm_control_agent_readdata     (mgmt_readdata),
        .intel_vvp_csc_0_av_mm_control_agent_readdatavalid(mgmt_readdatavalid),
        .intel_vvp_csc_0_av_mm_control_agent_waitrequest  (mgmt_waitrequest),
        .intel_vvp_csc_0_av_mm_control_agent_byteenable   (4'hF)
    );

endmodule