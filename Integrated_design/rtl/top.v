`timescale 1 ps / 1 ps

// =============================================================================
// top.v  —  Pipeline Top-Level Controller
//
// Pipeline topology (all internal to pipeline.v):
//   TPG → DIL → CRS → CSC → Clipper → ProtocolConv → Scaler
//
// External AXI4-S ports on pipeline.v:
//   TPG out → (gated here) → DIL in
//   OUT : intel_vvp_scaler_0_axi4s_vid_out
//
// Control-bus topology (UG-20344 §5):
//   • TPG and protocol_conv_1 each expose their own Avalon-MM control agent
//     port at the pipeline boundary (unchanged).
//   • VFB / Converter / Scaler / Clipper / CRS / CSC are reached through an
//     Avalon Memory Mapped Pipeline Bridge ("mm_bridge_0") instantiated inside
//     pipeline.qsys. Only the bridge's slave port (mm_bridge_0_s0) is exposed
//     externally.
//
// Bridge slave port (mm_bridge_0_s0):
//   • 13-bit byte address, 32-bit data, burstcount=1
//   • Address map (per pipeline.html, §Connections):
//        0x000–0x1FF  →  VFB       (intel_vvp_vfb_0.av_mm_control_agent)
//        0x200–0x3FF  →  Converter (lite_to_full_converter.av_mm_control_agent)
//        0x400–0x5FF  →  Scaler    (intel_vvp_scaler_0.av_mm_control_agent)
//        0x600–0x7FF  →  Clipper   (intel_vvp_clipper_0.av_mm_control_agent)
//        0x800–0x9FF  →  CRS       (intel_vvp_crs_0.av_mm_control_agent)
//        0xA00–0xBFF  →  CSC       (intel_vvp_csc_0.av_mm_control_agent)
//   • Per-IP register addresses come from UG-20344 Table 7 as BYTE offsets
//     (e.g. IMG_INFO_WIDTH=0x0120). They are simply ORed with the slave base.
//
// Configuration order:
//   1. TPG     — set resolution, pattern, commit, enable        (own port)
//   2. Clipper — set input size, color space, subsampling, …    (bridge)
//   3. Scaler  — set input/output sizes                          (bridge)
//   4. CRS     — set output mode, commit                         (bridge)
//   5. CSC     — write coefficients, commit, poll status         (bridge)
//   6. CONV    — image info matching scaler output               (bridge)
//   7. VFB     — OUTPUT_CONTROL.GO to start frame output         (bridge)
//   8. PC1     — image-source dims/control (only if INPUT_SEL=1) (own port)
//   9. WORKING — all IPs live
// =============================================================================

module top #(
    // Frame geometry
    parameter [31:0] IMG_WIDTH      = 32'd1920,
    parameter [31:0] IMG_HEIGHT     = 32'd1080,
    parameter [31:0] IMG_COLOR      = 32'd1,     // Clipper: color space
    parameter [31:0] IMG_CR_SM      = 32'd1,     // Clipper: chroma sampling
    parameter [31:0] IMG_L_OFF      = 32'd4,
    parameter [31:0] IMG_T_OFF      = 32'd4,
    parameter [31:0] IMG_R_OFF      = 32'd4,
    parameter [31:0] IMG_B_OFF      = 32'd4,

    // Scaler output
    parameter [31:0] SCALER_OUT_W   = 32'd1280,
    parameter [31:0] SCALER_OUT_H   = 32'd720,

    // Resampler (CRS)
    parameter [31:0] CRS_OUTPUT_MODE = 32'd3,    // 2=YUV422, 3=YUV444

    // Color Space Converter (CSC)
    parameter [2:0]  CSC_MODE        = 3'd0,
    parameter [31:0] CSC_COLOR_SPACE = 32'd0,  // 0=RGB (kIntelVvpCsRgb)

    // Input source select: 0=TPG, 1=image.png via protocol_conv_1
    parameter [0:0]  INPUT_SEL       = 1'b0
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        emif_ref_clk,   // EMIF PHY reference clock (200 MHz)

    // Final pipeline output (Scaler output)
    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser,

    // protocol_conv_1 AXIS Lite input (image source; only driven when INPUT_SEL=1)
    input  wire [23:0] pc1_in_tdata,
    input  wire        pc1_in_tvalid,
    output wire        pc1_in_tready,
    input  wire        pc1_in_tlast,
    input  wire [2:0]  pc1_in_tuser
);

    // =========================================================================
    // Derived constants
    // =========================================================================
    localparam [31:0] SCALER_IN_W = IMG_WIDTH  - IMG_R_OFF - IMG_L_OFF;
    localparam [31:0] SCALER_IN_H = IMG_HEIGHT - IMG_T_OFF - IMG_B_OFF;

    // =========================================================================
    // Bridge address map — base byte address of each slave on mm_bridge_0.m0
    // (pipeline.html, §Connections). Each slave occupies 0x200 bytes.
    // =========================================================================
    localparam [12:0] VFB_BASE  = 13'h000;   // intel_vvp_vfb_0
    localparam [12:0] CONV_BASE = 13'h200;   // lite_to_full_converter
    localparam [12:0] SCL_BASE  = 13'h400;
    localparam [12:0] CLIP_BASE = 13'h600;
    localparam [12:0] CRS_BASE  = 13'h800;
    localparam [12:0] CSC_BASE  = 13'hA00;

    // =========================================================================
    // Per-IP register addresses
    //
    // TPG and PC1 still use 7-bit word-addressed Avalon ports (no bridge).
    // Clip/Scaler/CRS/CSC are reached over the bridge as BYTE offsets
    // (UG-20344 Table 7). Word_addr<<2 gives the byte offset, then we OR
    // with the slave's base.
    // =========================================================================

    // --- TPG (own port, 7-bit word address) ---
    localparam [6:0] TPG_ADDR_WIDTH     = 7'h48;
    localparam [6:0] TPG_ADDR_HEIGHT    = 7'h49;
    localparam [6:0] TPG_ADDR_INTERLACE = 7'h4A;
    localparam [6:0] TPG_ADDR_STATUS    = 7'h50;
    localparam [6:0] TPG_ADDR_CONTROL   = 7'h52;
    localparam [6:0] TPG_ADDR_COMMIT    = 7'h53;
    localparam [6:0] TPG_ADDR_PATTERN   = 7'h54;
    localparam [6:0] TPG_ADDR_BAR_SEL   = 7'h5A;

    // --- Clipper (bridge, byte address) ---
    localparam [12:0] CLIP_IN_WIDTH   = CLIP_BASE | 13'h120; // word 0x48
    localparam [12:0] CLIP_IN_HEIGHT  = CLIP_BASE | 13'h124; // word 0x49
    localparam [12:0] CLIP_IN_COLOR   = CLIP_BASE | 13'h130; // word 0x4C
    localparam [12:0] CLIP_IN_SUBSAMP = CLIP_BASE | 13'h134; // word 0x4D
    localparam [12:0] CLIP_COMMIT     = CLIP_BASE | 13'h144; // word 0x51
    localparam [12:0] CLIP_LEFT_OFF   = CLIP_BASE | 13'h148; // word 0x52
    localparam [12:0] CLIP_TOP_OFF    = CLIP_BASE | 13'h14C; // word 0x53
    localparam [12:0] CLIP_RIGHT_OFF  = CLIP_BASE | 13'h150; // word 0x54
    localparam [12:0] CLIP_BOT_OFF    = CLIP_BASE | 13'h154; // word 0x55

    // --- Scaler (bridge, byte address) ---
    localparam [12:0] SCL_IN_WIDTH    = SCL_BASE  | 13'h120; // word 0x48
    localparam [12:0] SCL_IN_HEIGHT   = SCL_BASE  | 13'h124; // word 0x49
    localparam [12:0] SCL_OUT_WIDTH   = SCL_BASE  | 13'h148; // word 0x52
    localparam [12:0] SCL_OUT_HEIGHT  = SCL_BASE  | 13'h14C; // word 0x53

    // --- CRS (bridge, byte address) ---
    localparam [12:0] CRS_OUTPUT_MODE_ADDR = CRS_BASE | 13'h148; // word 0x52
    localparam [12:0] CRS_COMMIT_ADDR      = CRS_BASE | 13'h144; // word 0x51

    // --- CSC (bridge, byte address) ---
    localparam [12:0] CSC_STATUS     = CSC_BASE | 13'h140; // word 0x50
    localparam [12:0] CSC_COMMIT     = CSC_BASE | 13'h144; // word 0x51
    localparam [12:0] CSC_COEFF_A0   = CSC_BASE | 13'h148; // word 0x52
    localparam [12:0] CSC_COEFF_B0   = CSC_BASE | 13'h14C; // word 0x53
    localparam [12:0] CSC_COEFF_C0   = CSC_BASE | 13'h150; // word 0x54
    localparam [12:0] CSC_COEFF_A1   = CSC_BASE | 13'h154; // word 0x55
    localparam [12:0] CSC_COEFF_B1   = CSC_BASE | 13'h158; // word 0x56
    localparam [12:0] CSC_COEFF_C1   = CSC_BASE | 13'h15C; // word 0x57
    localparam [12:0] CSC_COEFF_A2   = CSC_BASE | 13'h160; // word 0x58
    localparam [12:0] CSC_COEFF_B2   = CSC_BASE | 13'h164; // word 0x59
    localparam [12:0] CSC_COEFF_C2   = CSC_BASE | 13'h168; // word 0x5A
    localparam [12:0] CSC_SUMMAND_S0 = CSC_BASE | 13'h16C; // word 0x5B
    localparam [12:0] CSC_SUMMAND_S1 = CSC_BASE | 13'h170; // word 0x5C
    localparam [12:0] CSC_SUMMAND_S2 = CSC_BASE | 13'h174; // word 0x5D
    localparam [12:0] CSC_OUT_CS     = CSC_BASE | 13'h178; // word 0x5E

    // --- Protocol Converter 1 (own port, 7-bit word address) ---
    localparam [6:0] PC1_ADDR_WIDTH       = 7'h48;
    localparam [6:0] PC1_ADDR_HEIGHT      = 7'h49;
    localparam [6:0] PC1_ADDR_INTERLACE   = 7'h4A;
    localparam [6:0] PC1_ADDR_COLORSPACE  = 7'h4C;
    localparam [6:0] PC1_ADDR_SUBSAMPLING = 7'h4D;
    localparam [6:0] PC1_ADDR_CTRL        = 7'h55;

    // --- Lite-to-Full Converter (bridge, byte address; protocol_conv regmap) ---
    localparam [12:0] CONV_WIDTH_ADDR   = CONV_BASE | 13'h120; // word 0x48
    localparam [12:0] CONV_HEIGHT_ADDR  = CONV_BASE | 13'h124; // word 0x49
    localparam [12:0] CONV_INTL_ADDR    = CONV_BASE | 13'h128; // word 0x4A
    localparam [12:0] CONV_CS_ADDR      = CONV_BASE | 13'h130; // word 0x4C
    localparam [12:0] CONV_SUBSAMP_ADDR = CONV_BASE | 13'h134; // word 0x4D
    localparam [12:0] CONV_CTRL_ADDR    = CONV_BASE | 13'h154; // word 0x55

    // --- Video Frame Buffer (bridge, byte address) ---
    // From intel_vvp_vfb_regs.h: RT base = word 0x50,
    // OUTPUT_CONTROL = RT+7 = 0x57, bit0 = GO (read side won't emit until set)
    localparam [12:0] VFB_OUT_CTRL_ADDR = VFB_BASE | 13'h15C; // word 0x57

    // =========================================================================
    // State encoding
    // =========================================================================
    localparam [4:0]
        ST_IDLE          = 5'd0,

        // TPG (own Avalon port)
        ST_TPG_CTRL_1    = 5'd1,
        ST_TPG_WR_INTL   = 5'd2,
        ST_TPG_WR_W      = 5'd3,
        ST_TPG_WR_H      = 5'd4,
        ST_TPG_WR_PAT_T  = 5'd5,
        ST_TPG_WR_PAT_S  = 5'd6,
        ST_TPG_WR_CMT    = 5'd7,
        ST_TPG_CTRL_2    = 5'd8,
        ST_TPG_POLL_ISS  = 5'd9,
        ST_TPG_POLL_W    = 5'd10,
        ST_TPG_IP_RST    = 5'd11,
        ST_TPG_CTRL_3    = 5'd12,

        // Clipper / Scaler / CRS / CSC (via mm_bridge_0)
        ST_CONFIG_CLIP   = 5'd13,
        ST_CONFIG_SCL    = 5'd14,
        ST_CONFIG_CRS    = 5'd15,
        ST_CONFIG_CSC    = 5'd16,
        ST_POLL_CSC      = 5'd17,

        ST_WORKING       = 5'd18,

        // Protocol Converter 1 config (own Avalon port, INPUT_SEL=1 only)
        ST_CONFIG_PC1    = 5'd19,

        // Lite-to-Full Converter config (via mm_bridge_0)
        ST_CONFIG_CONV   = 5'd20,
        // Video Frame Buffer start (own Avalon port)
        ST_CONFIG_VFB    = 5'd21;

    // =========================================================================
    // CSC coefficient ROMs (Q10.21 signed, 32-bit)
    // =========================================================================

    // MODE 0 – Passthrough
    localparam signed [31:0] PT_A0=32'sh00200000, PT_A1=32'sh00000000, PT_A2=32'sh00000000;
    localparam signed [31:0] PT_B0=32'sh00000000, PT_B1=32'sh00200000, PT_B2=32'sh00000000;
    localparam signed [31:0] PT_C0=32'sh00000000, PT_C1=32'sh00000000, PT_C2=32'sh00200000;
    localparam signed [31:0] PT_S0=32'sh00000000, PT_S1=32'sh00000000, PT_S2=32'sh00000000;

    // MODE 1 – RGB → YCbCr HD (BT.709)
    localparam signed [31:0] RH_A0=32'sh000E0C4A, RH_A1=32'sh0001FBE7, RH_A2=32'shFFFEB852;
    localparam signed [31:0] RH_B0=32'shFFF52F1B, RH_B1=32'sh0013A5E3, RH_B2=32'shFFF33B64;
    localparam signed [31:0] RH_C0=32'shFFFCC49C, RH_C1=32'sh0005DB23, RH_C2=32'sh000E0C4A;
    localparam signed [31:0] RH_S0=32'sh10000000, RH_S1=32'sh02000000, RH_S2=32'sh10000000;

    // MODE 2 – YCbCr HD → RGB
    localparam signed [31:0] HR_A0=32'sh0043AE14, HR_A1=32'shFFF92F1B, HR_A2=32'sh00000000;
    localparam signed [31:0] HR_B0=32'sh00253F7D, HR_B1=32'sh00253F7D, HR_B2=32'sh00253F7D;
    localparam signed [31:0] HR_C0=32'sh00000000, HR_C1=32'shFFEEE979, HR_C2=32'sh00396042;
    localparam signed [31:0] HR_S0=32'shDBD4FDF4, HR_S1=32'sh099FBE77, HR_S2=32'shE0FBE00D;

    // MODE 3 – RGB → YCbCr SD (BT.601)
    localparam signed [31:0] RS_A0=32'sh000E0C4A, RS_A1=32'sh000322D1, RS_A2=32'shFFFDBA5E;
    localparam signed [31:0] RS_B0=32'shFFF6B021, RS_B1=32'sh001020C5, RS_B2=32'shFFF43958;
    localparam signed [31:0] RS_C0=32'shFFFB4396, RS_C1=32'sh00083958, RS_C2=32'sh000E0C4A;
    localparam signed [31:0] RS_S0=32'sh10000000, RS_S1=32'sh02000000, RS_S2=32'sh10000000;

    // MODE 4 – YCbCr SD → RGB
    localparam signed [31:0] SR_A0=32'sh003A1CAC, SR_A1=32'shFFFA24DD, SR_A2=32'sh00000000;
    localparam signed [31:0] SR_B0=32'sh00200000, SR_B1=32'sh00200000, SR_B2=32'sh00200000;
    localparam signed [31:0] SR_C0=32'sh00000000, SR_C1=32'shFFF14FDF, SR_C2=32'sh003147AE;
    localparam signed [31:0] SR_S0=32'shE2F1A9FC, SR_S1=32'sh0A45A1CB, SR_S2=32'shE75C20C5;

    // Mux coefficients
    wire signed [31:0] csc_a0 = (CSC_MODE==3'd1)?RH_A0:(CSC_MODE==3'd2)?HR_A0:(CSC_MODE==3'd3)?RS_A0:(CSC_MODE==3'd4)?SR_A0:PT_A0;
    wire signed [31:0] csc_a1 = (CSC_MODE==3'd1)?RH_A1:(CSC_MODE==3'd2)?HR_A1:(CSC_MODE==3'd3)?RS_A1:(CSC_MODE==3'd4)?SR_A1:PT_A1;
    wire signed [31:0] csc_a2 = (CSC_MODE==3'd1)?RH_A2:(CSC_MODE==3'd2)?HR_A2:(CSC_MODE==3'd3)?RS_A2:(CSC_MODE==3'd4)?SR_A2:PT_A2;
    wire signed [31:0] csc_b0 = (CSC_MODE==3'd1)?RH_B0:(CSC_MODE==3'd2)?HR_B0:(CSC_MODE==3'd3)?RS_B0:(CSC_MODE==3'd4)?SR_B0:PT_B0;
    wire signed [31:0] csc_b1 = (CSC_MODE==3'd1)?RH_B1:(CSC_MODE==3'd2)?HR_B1:(CSC_MODE==3'd3)?RS_B1:(CSC_MODE==3'd4)?SR_B1:PT_B1;
    wire signed [31:0] csc_b2 = (CSC_MODE==3'd1)?RH_B2:(CSC_MODE==3'd2)?HR_B2:(CSC_MODE==3'd3)?RS_B2:(CSC_MODE==3'd4)?SR_B2:PT_B2;
    wire signed [31:0] csc_c0 = (CSC_MODE==3'd1)?RH_C0:(CSC_MODE==3'd2)?HR_C0:(CSC_MODE==3'd3)?RS_C0:(CSC_MODE==3'd4)?SR_C0:PT_C0;
    wire signed [31:0] csc_c1 = (CSC_MODE==3'd1)?RH_C1:(CSC_MODE==3'd2)?HR_C1:(CSC_MODE==3'd3)?RS_C1:(CSC_MODE==3'd4)?SR_C1:PT_C1;
    wire signed [31:0] csc_c2 = (CSC_MODE==3'd1)?RH_C2:(CSC_MODE==3'd2)?HR_C2:(CSC_MODE==3'd3)?RS_C2:(CSC_MODE==3'd4)?SR_C2:PT_C2;
    wire signed [31:0] csc_s0 = (CSC_MODE==3'd1)?RH_S0:(CSC_MODE==3'd2)?HR_S0:(CSC_MODE==3'd3)?RS_S0:(CSC_MODE==3'd4)?SR_S0:PT_S0;
    wire signed [31:0] csc_s1 = (CSC_MODE==3'd1)?RH_S1:(CSC_MODE==3'd2)?HR_S1:(CSC_MODE==3'd3)?RS_S1:(CSC_MODE==3'd4)?SR_S1:PT_S1;
    wire signed [31:0] csc_s2 = (CSC_MODE==3'd1)?RH_S2:(CSC_MODE==3'd2)?HR_S2:(CSC_MODE==3'd3)?RS_S2:(CSC_MODE==3'd4)?SR_S2:PT_S2;
    wire        [31:0] csc_out_cs = ((CSC_MODE==3'd1)||(CSC_MODE==3'd3)) ? 32'd1 :
                                    (CSC_MODE==3'd0) ? CSC_COLOR_SPACE : 32'd0;

    // =========================================================================
    // State / control registers
    // =========================================================================
    reg [4:0]  current_state;
    reg [3:0]  cfg_step;
    reg [7:0]  cycle_count;

    // TPG and PC1 keep their own Avalon-MM control ports.
    reg [6:0]  tpg_addr;   reg        tpg_write,  tpg_read;   reg [31:0] tpg_wdata;
    reg [6:0]  pc1_addr;   reg        pc1_write;              reg [31:0] pc1_wdata;

    // Single bridge master into mm_bridge_0_s0
    // (drives vfb/converter/scaler/clipper/crs/csc).
    reg [12:0] bridge_addr;
    reg [31:0] bridge_wdata;
    reg        bridge_write;
    reg        bridge_read;

    // Avalon-MM response wires
    wire [31:0] tpg_readdata;
    wire        tpg_readdatavalid;
    wire        tpg_wait;
    wire        pc1_wait;
    wire [31:0] bridge_readdata;
    wire        bridge_readdatavalid;
    wire        bridge_wait;

    // =========================================================================
    // Configuration State Machine
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            tpg_write     <= 1'b0;
            tpg_read      <= 1'b0;
            pc1_write     <= 1'b0;
            bridge_write  <= 1'b0;
            bridge_read   <= 1'b0;
            cfg_step      <= 4'd0;
            cycle_count   <= 8'h0;
        end else begin
            case (current_state)

                // ------------------------------------------------------------------
                ST_IDLE: current_state <= ST_TPG_CTRL_1;

                // ══════════════════════════════════════════════════════════════════
                // TPG configuration (own Avalon port)
                // ══════════════════════════════════════════════════════════════════
                ST_TPG_CTRL_1: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_CONTROL;
                    tpg_wdata <= 32'h0;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        current_state <= ST_TPG_WR_INTL;
                    end
                end

                ST_TPG_WR_INTL: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_INTERLACE;
                    tpg_wdata <= 32'h0;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        current_state <= ST_TPG_WR_W;
                    end
                end

                ST_TPG_WR_W: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_WIDTH;
                    tpg_wdata <= IMG_WIDTH;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        current_state <= ST_TPG_WR_H;
                    end
                end

                ST_TPG_WR_H: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_HEIGHT;
                    tpg_wdata <= IMG_HEIGHT;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        current_state <= ST_TPG_WR_PAT_T;
                    end
                end

                ST_TPG_WR_PAT_T: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_BAR_SEL;
                    tpg_wdata <= 32'h0;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        current_state <= ST_TPG_WR_PAT_S;
                    end
                end

                ST_TPG_WR_PAT_S: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_PATTERN;
                    tpg_wdata <= 32'd0;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        current_state <= ST_TPG_WR_CMT;
                    end
                end

                ST_TPG_WR_CMT: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_COMMIT;
                    tpg_wdata <= 32'h1;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        current_state <= ST_TPG_CTRL_2;
                    end
                end

                ST_TPG_CTRL_2: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_CONTROL;
                    tpg_wdata <= 32'h1;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        current_state <= ST_TPG_POLL_ISS;
                    end
                end

                ST_TPG_POLL_ISS: begin
                    tpg_read <= 1'b1;
                    tpg_addr <= TPG_ADDR_STATUS;
                    if (!tpg_wait) begin
                        tpg_read      <= 1'b0;
                        current_state <= ST_TPG_POLL_W;
                    end
                end

                ST_TPG_POLL_W: begin
                    if (tpg_readdatavalid) begin
                        if (tpg_readdata[1] == 1'b0)
                            current_state <= ST_TPG_IP_RST;
                        else
                            current_state <= ST_TPG_POLL_ISS;
                    end
                end

                ST_TPG_IP_RST: begin
                    cycle_count <= cycle_count + 1'b1;
                    if (cycle_count == 8'h07) current_state <= ST_TPG_CTRL_3;
                end

                ST_TPG_CTRL_3: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_CONTROL;
                    tpg_wdata <= 32'h1;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        cfg_step      <= 4'd0;
                        // Pre-load Clipper step 0 (HEIGHT/IMG_HEIGHT) onto bridge.
                        bridge_addr   <= CLIP_IN_HEIGHT;
                        bridge_wdata  <= IMG_HEIGHT;
                        current_state <= ST_CONFIG_CLIP;
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // Clipper configuration (via mm_bridge_0)
                //
                // Avalon-MM rule: addr/data MUST be stable whenever waitrequest=1.
                // Pre-loader pattern: predecessor sets step 0. We only advance and
                // re-load when the current transaction is accepted (bridge_write=1
                // AND bridge_wait=0). On the very first clock of this state
                // bridge_write is still 0 (non-blocking takes effect next cycle),
                // so the guard prevents a spurious advance.
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_CLIP: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd8) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            // Pre-load Scaler step 0.
                            bridge_addr   <= SCL_IN_WIDTH;
                            bridge_wdata  <= SCALER_IN_W;
                            current_state <= ST_CONFIG_SCL;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            // Pre-load the NEXT clipper transaction atomically.
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr <= CLIP_IN_WIDTH;   bridge_wdata <= IMG_WIDTH; end
                                4'd2: begin bridge_addr <= CLIP_IN_COLOR;   bridge_wdata <= IMG_COLOR; end
                                4'd3: begin bridge_addr <= CLIP_IN_SUBSAMP; bridge_wdata <= IMG_CR_SM; end
                                4'd4: begin bridge_addr <= CLIP_LEFT_OFF;   bridge_wdata <= IMG_L_OFF; end
                                4'd5: begin bridge_addr <= CLIP_TOP_OFF;    bridge_wdata <= IMG_T_OFF; end
                                4'd6: begin bridge_addr <= CLIP_RIGHT_OFF;  bridge_wdata <= IMG_R_OFF; end
                                4'd7: begin bridge_addr <= CLIP_BOT_OFF;    bridge_wdata <= IMG_B_OFF; end
                                4'd8: begin bridge_addr <= CLIP_COMMIT;     bridge_wdata <= 32'h1;     end
                                default: ;
                            endcase
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // Scaler configuration (via mm_bridge_0)
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_SCL: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd3) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            // Pre-load CRS step 0.
                            bridge_addr   <= CRS_OUTPUT_MODE_ADDR;
                            bridge_wdata  <= CRS_OUTPUT_MODE;
                            current_state <= ST_CONFIG_CRS;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr <= SCL_IN_HEIGHT;  bridge_wdata <= SCALER_IN_H; end
                                4'd2: begin bridge_addr <= SCL_OUT_WIDTH;  bridge_wdata <= SCALER_OUT_W; end
                                4'd3: begin bridge_addr <= SCL_OUT_HEIGHT; bridge_wdata <= SCALER_OUT_H; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // CRS (Resampler) configuration (via mm_bridge_0)
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_CRS: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd1) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            // Pre-load first CSC transaction (COEFF_A0).
                            bridge_addr   <= CSC_COEFF_A0;
                            bridge_wdata  <= csc_a0;
                            current_state <= ST_CONFIG_CSC;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr <= CRS_COMMIT_ADDR; bridge_wdata <= 32'h1; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // CSC configuration (12 coefficient/summand registers + OUT_CS + COMMIT)
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_CSC: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd13) begin
                            bridge_write <= 1'b0;
                            cfg_step     <= 4'd0;
                            // INPUT_SEL=1: skip ST_POLL_CSC. The CSC "pending
                            // register updates" bit only clears at the next frame
                            // boundary after COMMIT, but no data flows until PC1
                            // is configured and the testbench releases data at
                            // ST_WORKING. Go straight to converter config.
                            if (INPUT_SEL) begin
                                bridge_addr   <= CONV_WIDTH_ADDR;
                                bridge_wdata  <= SCALER_OUT_W;
                                current_state <= ST_CONFIG_CONV;
                            end else begin
                                current_state <= ST_POLL_CSC;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1:  begin bridge_addr <= CSC_COEFF_A1;   bridge_wdata <= csc_a1;     end
                                4'd2:  begin bridge_addr <= CSC_COEFF_A2;   bridge_wdata <= csc_a2;     end
                                4'd3:  begin bridge_addr <= CSC_COEFF_B0;   bridge_wdata <= csc_b0;     end
                                4'd4:  begin bridge_addr <= CSC_COEFF_B1;   bridge_wdata <= csc_b1;     end
                                4'd5:  begin bridge_addr <= CSC_COEFF_B2;   bridge_wdata <= csc_b2;     end
                                4'd6:  begin bridge_addr <= CSC_COEFF_C0;   bridge_wdata <= csc_c0;     end
                                4'd7:  begin bridge_addr <= CSC_COEFF_C1;   bridge_wdata <= csc_c1;     end
                                4'd8:  begin bridge_addr <= CSC_COEFF_C2;   bridge_wdata <= csc_c2;     end
                                4'd9:  begin bridge_addr <= CSC_SUMMAND_S0; bridge_wdata <= csc_s0;     end
                                4'd10: begin bridge_addr <= CSC_SUMMAND_S1; bridge_wdata <= csc_s1;     end
                                4'd11: begin bridge_addr <= CSC_SUMMAND_S2; bridge_wdata <= csc_s2;     end
                                4'd12: begin bridge_addr <= CSC_OUT_CS;     bridge_wdata <= csc_out_cs; end
                                4'd13: begin bridge_addr <= CSC_COMMIT;     bridge_wdata <= 32'h1; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // Poll CSC STATUS register over the bridge until commit absorbed
                // ══════════════════════════════════════════════════════════════════
                ST_POLL_CSC: begin
                    if (cfg_step == 4'd0) begin
                        // Guard with `bridge_read &&` so the de-assert only
                        // fires once the read is actually in flight. The
                        // pipeline bridge holds waitrequest=0 when idle, so
                        // without this guard the two non-blocking assignments
                        // to bridge_read collapse to 0 and no read is issued.
                        bridge_read  <= 1'b1;
                        bridge_addr  <= CSC_STATUS;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else begin
                        if (bridge_readdatavalid) begin
                            cfg_step <= 4'd0;
                            if (bridge_readdata[1] == 1'b0) begin
                                // Pre-load first converter transaction (WIDTH).
                                bridge_addr   <= CONV_WIDTH_ADDR;
                                bridge_wdata  <= SCALER_OUT_W;
                                current_state <= ST_CONFIG_CONV;
                            end
                            // else re-poll
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // Lite-to-Full Converter config (via mm_bridge_0, base 0x000).
                // Same regmap as the protocol converters. Image info must match
                // the scaler output since the converter generates the in-band
                // image info packets consumed by the frame buffer.
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_CONV: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd5) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            // Pre-load the VFB start write (bridge, base 0x000).
                            bridge_addr   <= VFB_OUT_CTRL_ADDR;
                            bridge_wdata  <= 32'h1;
                            current_state <= ST_CONFIG_VFB;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr <= CONV_HEIGHT_ADDR;  bridge_wdata <= SCALER_OUT_H; end
                                4'd2: begin bridge_addr <= CONV_INTL_ADDR;    bridge_wdata <= 32'h0;        end
                                4'd3: begin bridge_addr <= CONV_CS_ADDR;      bridge_wdata <= 32'h0;        end
                                4'd4: begin bridge_addr <= CONV_SUBSAMP_ADDR; bridge_wdata <= 32'h3;        end
                                4'd5: begin bridge_addr <= CONV_CTRL_ADDR;    bridge_wdata <= 32'h1;        end
                                default: ;
                            endcase
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // Video Frame Buffer start (via mm_bridge_0):
                // set OUTPUT_CONTROL.GO so the read side starts emitting frames.
                // Address/data pre-loaded by ST_CONFIG_CONV.
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_VFB: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write <= 1'b0;
                        if (INPUT_SEL) begin
                            pc1_addr      <= PC1_ADDR_WIDTH;
                            pc1_wdata     <= IMG_WIDTH;
                            current_state <= ST_CONFIG_PC1;
                        end else begin
                            current_state <= ST_WORKING;
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // All IPs configured — pipeline running
                // ══════════════════════════════════════════════════════════════════
                ST_WORKING: begin
                    tpg_write    <= 1'b0; tpg_read <= 1'b0;
                    pc1_write    <= 1'b0;
                    bridge_write <= 1'b0; bridge_read <= 1'b0;
                end

                // ══════════════════════════════════════════════════════════════════
                // Protocol Converter 1 config (own Avalon port, INPUT_SEL=1 only)
                // Register map (7-bit word addresses):
                //   0x48 WIDTH, 0x49 HEIGHT, 0x4A INTERLACE,
                //   0x4C COLORSPACE, 0x4D SUBSAMPLING, 0x55 CTRL (bit0=start)
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_PC1: begin
                    pc1_write <= 1'b1;
                    if (pc1_write && !pc1_wait) begin
                        if (cfg_step == 4'd5) begin
                            pc1_write     <= 1'b0;
                            cfg_step      <= 4'd0;
                            current_state <= ST_WORKING;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin pc1_addr <= PC1_ADDR_HEIGHT;      pc1_wdata <= IMG_HEIGHT; end
                                4'd2: begin pc1_addr <= PC1_ADDR_INTERLACE;   pc1_wdata <= 32'h0;      end
                                4'd3: begin pc1_addr <= PC1_ADDR_COLORSPACE;  pc1_wdata <= 32'h0;      end
                                // SubSa code: 0=4:2:0, 2=4:2:2, 3=4:4:4
                                4'd4: begin pc1_addr <= PC1_ADDR_SUBSAMPLING; pc1_wdata <= 32'h3;      end
                                4'd5: begin pc1_addr <= PC1_ADDR_CTRL;        pc1_wdata <= 32'h1;      end
                                default: ;
                            endcase
                        end
                    end
                end

                default: current_state <= ST_IDLE;

            endcase
        end
    end

    // =========================================================================
    // Input source mux → DIL
    // =========================================================================
    // INPUT_SEL=0: TPG output gated to DIL
    // INPUT_SEL=1: protocol_conv_1 output (image.png) gated to DIL

    wire ready_to_start = (current_state >= ST_CONFIG_CSC);

    wire [23:0] tpg_out_tdata;
    wire        tpg_out_tvalid;
    wire        tpg_out_tlast;
    wire [2:0]  tpg_out_tuser;

    wire [23:0] pc1_out_tdata;
    wire        pc1_out_tvalid;
    wire        pc1_out_tlast;
    wire [2:0]  pc1_out_tuser;

    wire [23:0] dil_in_tdata  = INPUT_SEL ? pc1_out_tdata  : tpg_out_tdata;
    wire        dil_in_tvalid = (INPUT_SEL ? pc1_out_tvalid : tpg_out_tvalid) & ready_to_start;
    wire        dil_in_tready;
    wire        dil_in_tlast  = INPUT_SEL ? pc1_out_tlast  : tpg_out_tlast;
    wire [2:0]  dil_in_tuser  = INPUT_SEL ? pc1_out_tuser  : tpg_out_tuser;

    // Drain TPG when image source is selected.
    wire tpg_out_tready = INPUT_SEL ? 1'b1 : (dil_in_tready & ready_to_start);

    // Inter-IP AXIS wires
    wire [23:0] dil_out_tdata;  wire dil_out_tvalid; wire dil_out_tready;
    wire        dil_out_tlast;  wire [2:0] dil_out_tuser;

    wire [23:0] crs_out_tdata;  wire crs_out_tvalid; wire crs_out_tready;
    wire        crs_out_tlast;  wire [2:0] crs_out_tuser;

    wire [23:0] csc_out_tdata;  wire csc_out_tvalid; wire csc_out_tready;
    wire        csc_out_tlast;  wire [2:0] csc_out_tuser;

    wire [23:0] clip_out_tdata; wire clip_out_tvalid; wire clip_out_tready;
    wire        clip_out_tlast; wire [2:0] clip_out_tuser;

    wire [23:0] pc_out_tdata;   wire pc_out_tvalid;  wire pc_out_tready;
    wire        pc_out_tlast;   wire [2:0] pc_out_tuser;

    // Scaler to Converter (lite to full AXIS)
    wire [23:0] scaler_out_tdata;  wire scaler_out_tvalid;  wire scaler_out_tready;
    wire        scaler_out_tlast;  wire [2:0] scaler_out_tuser;

    // Converter to Frame Buffer (full AXIS)
    wire [23:0] converter_out_tdata;  wire converter_out_tvalid;  wire converter_out_tready;
    wire        converter_out_tlast;  wire [2:0] converter_out_tuser;

    // Frame Buffer output
    wire [23:0] vfb_out_tdata;  wire vfb_out_tvalid;  wire vfb_out_tready;
    wire        vfb_out_tlast;  wire [2:0] vfb_out_tuser;

    pipeline u_pipeline (
        .clock_in_in_clk_clk     (clk),
        .reset_in_in_reset_reset (reset),
        .emif_ref_clk_clk        (emif_ref_clk),

        // ----- TPG AXI4-S output -----
        .intel_vvp_tpg_0_axi4s_vid_out_tdata  (tpg_out_tdata),
        .intel_vvp_tpg_0_axi4s_vid_out_tvalid (tpg_out_tvalid),
        .intel_vvp_tpg_0_axi4s_vid_out_tready (tpg_out_tready),
        .intel_vvp_tpg_0_axi4s_vid_out_tlast  (tpg_out_tlast),
        .intel_vvp_tpg_0_axi4s_vid_out_tuser  (tpg_out_tuser),

        // ----- DIL AXI4-S input -----
        .intel_vvp_dil_0_axi4s_vid_in_tdata  (dil_in_tdata),
        .intel_vvp_dil_0_axi4s_vid_in_tvalid (dil_in_tvalid),
        .intel_vvp_dil_0_axi4s_vid_in_tready (dil_in_tready),
        .intel_vvp_dil_0_axi4s_vid_in_tlast  (dil_in_tlast),
        .intel_vvp_dil_0_axi4s_vid_in_tuser  (dil_in_tuser),

        // ----- DIL AXI4-S output -----
        .intel_vvp_dil_0_axi4s_vid_out_tdata  (dil_out_tdata),
        .intel_vvp_dil_0_axi4s_vid_out_tvalid (dil_out_tvalid),
        .intel_vvp_dil_0_axi4s_vid_out_tready (dil_out_tready),
        .intel_vvp_dil_0_axi4s_vid_out_tlast  (dil_out_tlast),
        .intel_vvp_dil_0_axi4s_vid_out_tuser  (dil_out_tuser),

        // ----- CRS AXI4-S input -----
        .intel_vvp_crs_0_axi4s_vid_in_tdata  (dil_out_tdata),
        .intel_vvp_crs_0_axi4s_vid_in_tvalid (dil_out_tvalid),
        .intel_vvp_crs_0_axi4s_vid_in_tready (dil_out_tready),
        .intel_vvp_crs_0_axi4s_vid_in_tlast  (dil_out_tlast),
        .intel_vvp_crs_0_axi4s_vid_in_tuser  (dil_out_tuser),

        // ----- CRS AXI4-S output -----
        .intel_vvp_crs_0_axi4s_vid_out_tdata  (crs_out_tdata),
        .intel_vvp_crs_0_axi4s_vid_out_tvalid (crs_out_tvalid),
        .intel_vvp_crs_0_axi4s_vid_out_tready (crs_out_tready),
        .intel_vvp_crs_0_axi4s_vid_out_tlast  (crs_out_tlast),
        .intel_vvp_crs_0_axi4s_vid_out_tuser  (crs_out_tuser),

        // ----- CSC AXI4-S input -----
        .intel_vvp_csc_0_axi4s_vid_in_tdata  (crs_out_tdata),
        .intel_vvp_csc_0_axi4s_vid_in_tvalid (crs_out_tvalid),
        .intel_vvp_csc_0_axi4s_vid_in_tready (crs_out_tready),
        .intel_vvp_csc_0_axi4s_vid_in_tlast  (crs_out_tlast),
        .intel_vvp_csc_0_axi4s_vid_in_tuser  (crs_out_tuser),

        // ----- CSC AXI4-S output -----
        // Force-drain CSC during ST_POLL_CSC so it doesn't stall the status read.
        .intel_vvp_csc_0_axi4s_vid_out_tdata  (csc_out_tdata),
        .intel_vvp_csc_0_axi4s_vid_out_tvalid (csc_out_tvalid),
        .intel_vvp_csc_0_axi4s_vid_out_tready (csc_out_tready | (current_state == ST_POLL_CSC)),
        .intel_vvp_csc_0_axi4s_vid_out_tlast  (csc_out_tlast),
        .intel_vvp_csc_0_axi4s_vid_out_tuser  (csc_out_tuser),

        // ----- Clipper AXI4-S input -----
        .intel_vvp_clipper_0_axi4s_vid_in_tdata  (csc_out_tdata),
        .intel_vvp_clipper_0_axi4s_vid_in_tvalid (csc_out_tvalid),
        .intel_vvp_clipper_0_axi4s_vid_in_tready (csc_out_tready),
        .intel_vvp_clipper_0_axi4s_vid_in_tlast  (csc_out_tlast),
        .intel_vvp_clipper_0_axi4s_vid_in_tuser  (csc_out_tuser),

        // ----- Clipper AXI4-S output -----
        .intel_vvp_clipper_0_axi4s_vid_out_tdata  (clip_out_tdata),
        .intel_vvp_clipper_0_axi4s_vid_out_tvalid (clip_out_tvalid),
        .intel_vvp_clipper_0_axi4s_vid_out_tready (clip_out_tready),
        .intel_vvp_clipper_0_axi4s_vid_out_tlast  (clip_out_tlast),
        .intel_vvp_clipper_0_axi4s_vid_out_tuser  (clip_out_tuser),

        // ----- Protocol Converter 0 AXI4-S (Clipper → Scaler) -----
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tdata  (clip_out_tdata),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tvalid (clip_out_tvalid),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tready (clip_out_tready),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tlast  (clip_out_tlast),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tuser  (clip_out_tuser),

        .intel_vvp_protocol_conv_0_axi4s_vid_out_tdata  (pc_out_tdata),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tvalid (pc_out_tvalid),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tready (pc_out_tready),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tlast  (pc_out_tlast),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tuser  (pc_out_tuser),

        // ----- Protocol Converter 1 AXI4-S (image source → DIL mux) -----
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tdata  (pc1_in_tdata),
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tvalid (pc1_in_tvalid),
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tready (pc1_in_tready),
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tlast  (pc1_in_tlast),
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tuser  (pc1_in_tuser),

        .intel_vvp_protocol_conv_1_axi4s_vid_out_tdata  (pc1_out_tdata),
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tvalid (pc1_out_tvalid),
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tready (INPUT_SEL ? (dil_in_tready & ready_to_start) : 1'b1),
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tlast  (pc1_out_tlast),
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tuser  (pc1_out_tuser),

        // ----- Protocol Converter 1 Avalon-MM control (own port) -----
        .intel_vvp_protocol_conv_1_av_mm_control_agent_address       (pc1_addr),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_write         (pc1_write),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_read          (1'b0),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_writedata     (pc1_wdata),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_readdata      (),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_readdatavalid (),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_waitrequest   (pc1_wait),

        // ----- Scaler AXI4-S input -----
        .intel_vvp_scaler_0_axi4s_vid_in_tdata  (pc_out_tdata),
        .intel_vvp_scaler_0_axi4s_vid_in_tvalid (pc_out_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_in_tready (pc_out_tready),
        .intel_vvp_scaler_0_axi4s_vid_in_tlast  (pc_out_tlast),
        .intel_vvp_scaler_0_axi4s_vid_in_tuser  (pc_out_tuser),

        // ----- Scaler AXI4-S output → Converter input -----
        .intel_vvp_scaler_0_axi4s_vid_out_tdata  (scaler_out_tdata),
        .intel_vvp_scaler_0_axi4s_vid_out_tvalid (scaler_out_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_out_tready (scaler_out_tready),
        .intel_vvp_scaler_0_axi4s_vid_out_tlast  (scaler_out_tlast),
        .intel_vvp_scaler_0_axi4s_vid_out_tuser  (scaler_out_tuser),

        // ----- Lite-to-Full Converter -----
        .lite_to_full_converter_axi4s_vid_in_tdata  (scaler_out_tdata),
        .lite_to_full_converter_axi4s_vid_in_tvalid (scaler_out_tvalid),
        .lite_to_full_converter_axi4s_vid_in_tready (scaler_out_tready),
        .lite_to_full_converter_axi4s_vid_in_tlast  (scaler_out_tlast),
        .lite_to_full_converter_axi4s_vid_in_tuser  (scaler_out_tuser),

        .lite_to_full_converter_axi4s_vid_out_tdata  (converter_out_tdata),
        .lite_to_full_converter_axi4s_vid_out_tvalid (converter_out_tvalid),
        .lite_to_full_converter_axi4s_vid_out_tready (converter_out_tready),
        .lite_to_full_converter_axi4s_vid_out_tlast  (converter_out_tlast),
        .lite_to_full_converter_axi4s_vid_out_tuser  (converter_out_tuser),

        // ----- Frame Buffer Video In (from converter) -----
        .intel_vvp_vfb_0_axi4s_vid_in_tdata  (converter_out_tdata),
        .intel_vvp_vfb_0_axi4s_vid_in_tvalid (converter_out_tvalid),
        .intel_vvp_vfb_0_axi4s_vid_in_tready (converter_out_tready),
        .intel_vvp_vfb_0_axi4s_vid_in_tlast  (converter_out_tlast),
        .intel_vvp_vfb_0_axi4s_vid_in_tuser  (converter_out_tuser),

        // ----- Frame Buffer Video Out (to testbench for capture) -----
        .intel_vvp_vfb_0_axi4s_vid_out_tdata  (vfb_out_tdata),
        .intel_vvp_vfb_0_axi4s_vid_out_tvalid (vfb_out_tvalid),
        .intel_vvp_vfb_0_axi4s_vid_out_tready (vfb_out_tready),
        .intel_vvp_vfb_0_axi4s_vid_out_tlast  (vfb_out_tlast),
        .intel_vvp_vfb_0_axi4s_vid_out_tuser  (vfb_out_tuser),

        // ----- TPG Avalon-MM control (own port) -----
        .intel_vvp_tpg_0_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_0_av_mm_control_agent_write         (tpg_write),
        .intel_vvp_tpg_0_av_mm_control_agent_read          (tpg_read),
        .intel_vvp_tpg_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_0_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdata      (tpg_readdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdatavalid (tpg_readdatavalid),
        .intel_vvp_tpg_0_av_mm_control_agent_waitrequest   (tpg_wait),

        // ----- Avalon-MM Pipeline Bridge slave (drives clipper/scaler/crs/csc) -----
        .mm_bridge_0_s0_address       (bridge_addr),
        .mm_bridge_0_s0_write         (bridge_write),
        .mm_bridge_0_s0_read          (bridge_read),
        .mm_bridge_0_s0_byteenable    (4'hF),
        .mm_bridge_0_s0_writedata     (bridge_wdata),
        .mm_bridge_0_s0_burstcount    (1'b1),
        .mm_bridge_0_s0_debugaccess   (1'b0),
        .mm_bridge_0_s0_readdata      (bridge_readdata),
        .mm_bridge_0_s0_readdatavalid (bridge_readdatavalid),
        .mm_bridge_0_s0_waitrequest   (bridge_wait)
    );

    // =========================================================================
    // Final pipeline output = Frame Buffer read side (frame round-trips
    // through OCM: converter -> VFB write host -> OCM -> VFB read host -> out)
    // =========================================================================
    assign out_tdata  = vfb_out_tdata;
    assign out_tvalid = vfb_out_tvalid;
    assign out_tlast  = vfb_out_tlast;
    assign out_tuser  = vfb_out_tuser;
    assign vfb_out_tready = out_tready;

endmodule
