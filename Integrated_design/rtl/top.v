`timescale 1 ps / 1 ps

// =============================================================================
// top.v  —  Pipeline Top-Level Controller
//
// Pipeline topology (all internal to pipeline.v):
//   TPG → DIL → CRS → CSC → Clipper → ProtocolConv → Scaler
//
// External AXI4-S ports on pipeline.v:
//   TPG out → (gated here) → DIL in   (TPG and DIL are NOT internally connected
//                                       in pipeline.v; this top bridges them)
//   OUT : intel_vvp_scaler_0_axi4s_vid_out
//
// Each IP has its own dedicated Avalon-MM control port exposed at top level.
//
// Configuration order:
//   1. TPG    — set resolution, pattern, commit, enable
//   2. Clipper — set input size, color space, subsampling, offsets, commit
//   3. Scaler  — set input/output sizes
//   4. CRS     — set output mode, commit
//   5. CSC     — write coefficients, commit, poll status
//   6. WORKING — all IPs live
//
// Parameters:
//   IMG_WIDTH / IMG_HEIGHT  — TPG / Clipper input frame size
//   IMG_COLOR               — Clipper color-space register value
//   IMG_CR_SM               — Clipper chroma-subsampling register value
//   IMG_L/T/R/B_OFF         — Clipper crop offsets
//   SCALER_OUT_W/H          — Scaler output resolution
//   CRS_OUTPUT_MODE         — Resampler output: 2=YUV422, 3=YUV444
//   CSC_MODE                — Coefficient set (see below)
//       0 = Passthrough (RGB → RGB)
//       1 = RGB → YCbCr HD (BT.709)
//       2 = YCbCr HD → RGB
//       3 = RGB → YCbCr SD (BT.601)
//       4 = YCbCr SD → RGB
//   CSC_COLOR_SPACE         — Value written to CSC OUT_CS register
//                             (only used when CSC_MODE == 0)
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
    parameter [31:0] CSC_COLOR_SPACE = 32'd1
)(
    input  wire        clk,
    input  wire        reset,

    // Final pipeline output (Scaler output)
    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser
);

    // =========================================================================
    // Derived constants
    // =========================================================================
    localparam [31:0] SCALER_IN_W = IMG_WIDTH  - IMG_R_OFF - IMG_L_OFF;
    localparam [31:0] SCALER_IN_H = IMG_HEIGHT - IMG_T_OFF - IMG_B_OFF;

    // =========================================================================
    // Register addresses
    // =========================================================================

    // --- TPG ---
    localparam [6:0] TPG_ADDR_WIDTH     = 7'h48;
    localparam [6:0] TPG_ADDR_HEIGHT    = 7'h49;
    localparam [6:0] TPG_ADDR_INTERLACE = 7'h4A;
    localparam [6:0] TPG_ADDR_STATUS    = 7'h50;
    localparam [6:0] TPG_ADDR_CONTROL   = 7'h52;
    localparam [6:0] TPG_ADDR_COMMIT    = 7'h53;
    localparam [6:0] TPG_ADDR_PATTERN   = 7'h54;
    localparam [6:0] TPG_ADDR_BAR_SEL   = 7'h5A;

    // --- Clipper ---
    localparam [6:0] CLIP_IN_WIDTH_ADDR  = 7'h48;
    localparam [6:0] CLIP_IN_HEIGHT_ADDR = 7'h49;
    localparam [6:0] CLIP_IN_COLOR_ADDR  = 7'h4C;
    localparam [6:0] CLIP_IN_SUBSAMPLING = 7'h4D;
    localparam [6:0] CLIP_COMMIT_ADDR    = 7'h51;
    localparam [6:0] CLIP_LEFT_OFF_ADDR  = 7'h52;
    localparam [6:0] CLIP_TOP_OFF_ADDR   = 7'h53;
    localparam [6:0] CLIP_RIGHT_OFF_ADDR = 7'h54;
    localparam [6:0] CLIP_BOT_OFF_ADDR   = 7'h55;

    // --- Scaler ---
    localparam [6:0] SCL_IN_WIDTH_ADDR   = 7'h48;
    localparam [6:0] SCL_IN_HEIGHT_ADDR  = 7'h49;
    localparam [6:0] SCL_OUT_WIDTH_ADDR  = 7'h52;
    localparam [6:0] SCL_OUT_HEIGHT_ADDR = 7'h53;

    // --- CRS (Resampler) ---
    localparam [6:0] CRS_OUTPUT_MODE_ADDR = 7'h52;
    localparam [6:0] CRS_COMMIT_ADDR      = 7'h51;

    // --- CSC (Color Space Converter) — word-addressed ---
    // Full byte address = word_addr << 2; base of CSC block = 0x0140
    localparam [8:0] ADDR_CSC_STATUS     = 9'h50;
    localparam [8:0] ADDR_CSC_COMMIT     = 9'h51;
    localparam [8:0] ADDR_CSC_COEFF_A0   = 9'h52;
    localparam [8:0] ADDR_CSC_COEFF_B0   = 9'h53;
    localparam [8:0] ADDR_CSC_COEFF_C0   = 9'h54;
    localparam [8:0] ADDR_CSC_COEFF_A1   = 9'h55;
    localparam [8:0] ADDR_CSC_COEFF_B1   = 9'h56;
    localparam [8:0] ADDR_CSC_COEFF_C1   = 9'h57;
    localparam [8:0] ADDR_CSC_COEFF_A2   = 9'h58;
    localparam [8:0] ADDR_CSC_COEFF_B2   = 9'h59;
    localparam [8:0] ADDR_CSC_COEFF_C2   = 9'h5A;
    localparam [8:0] ADDR_CSC_SUMMAND_S0 = 9'h5B;
    localparam [8:0] ADDR_CSC_SUMMAND_S1 = 9'h5C;
    localparam [8:0] ADDR_CSC_SUMMAND_S2 = 9'h5D;
    localparam [8:0] ADDR_CSC_OUT_CS     = 9'h5E;

    // =========================================================================
    // State encoding
    // =========================================================================
    localparam [4:0]
        ST_IDLE          = 5'd0,

        // TPG
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

        // Clipper / Scaler / CRS / CSC
        ST_CONFIG_CLIP   = 5'd13,
        ST_CONFIG_SCL    = 5'd14,
        ST_CONFIG_CRS    = 5'd15,
        ST_CONFIG_CSC    = 5'd16,
        ST_POLL_CSC      = 5'd17,

        ST_WORKING       = 5'd18;

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

    // Per-IP write buses (each IP has its own port on the new pipeline)
    reg [6:0]  tpg_addr;   reg        tpg_write,  tpg_read;   reg [31:0] tpg_wdata;
    reg [6:0]  clip_addr;  reg        clip_write;              reg [31:0] clip_wdata;
    reg [6:0]  scl_addr;   reg        scl_write;               reg [31:0] scl_wdata;
    reg [6:0]  crs_addr;   reg        crs_write;               reg [31:0] crs_wdata;
    reg [6:0]  csc_addr_r; reg        csc_write,  csc_read_r;  reg [31:0] csc_wdata;
    // Note: CSC address bus is 7-bit wide on the pipeline port (av_mm_control_agent)
    // but the CSC register map uses 9-bit word addresses; the lower 7 bits are
    // sufficient for all registers used here (max addr = 0x5E = 7'h5E).

    // Avalon-MM response wires
    wire [31:0] tpg_readdata;
    wire        tpg_readdatavalid;
    wire        tpg_wait;
    wire        clip_wait;
    wire        scl_wait;
    wire        crs_wait;
    wire [31:0] csc_readdata;
    wire        csc_readdatavalid;
    wire        csc_wait;

    // =========================================================================
    // Configuration State Machine
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            tpg_write     <= 1'b0;
            tpg_read      <= 1'b0;
            clip_write    <= 1'b0;
            scl_write     <= 1'b0;
            crs_write     <= 1'b0;
            csc_write     <= 1'b0;
            csc_read_r    <= 1'b0;
            cfg_step      <= 4'd0;
            cycle_count   <= 8'h0;
        end else begin
            case (current_state)

                // ------------------------------------------------------------------
                ST_IDLE: current_state <= ST_TPG_CTRL_1;

                // ══════════════════════════════════════════════════════════════════
                // TPG configuration
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
                        current_state <= ST_CONFIG_CLIP;
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // Clipper configuration
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_CLIP: begin
                    clip_write <= 1'b1;
                    case (cfg_step)
                        4'd0: begin clip_addr <= CLIP_IN_HEIGHT_ADDR;  clip_wdata <= IMG_HEIGHT; end
                        4'd1: begin clip_addr <= CLIP_IN_WIDTH_ADDR;   clip_wdata <= IMG_WIDTH;  end
                        4'd2: begin clip_addr <= CLIP_IN_COLOR_ADDR;   clip_wdata <= IMG_COLOR;  end
                        4'd3: begin clip_addr <= CLIP_IN_SUBSAMPLING;  clip_wdata <= IMG_CR_SM;  end
                        4'd4: begin clip_addr <= CLIP_LEFT_OFF_ADDR;   clip_wdata <= IMG_L_OFF;  end
                        4'd5: begin clip_addr <= CLIP_TOP_OFF_ADDR;    clip_wdata <= IMG_T_OFF;  end
                        4'd6: begin clip_addr <= CLIP_RIGHT_OFF_ADDR;  clip_wdata <= IMG_R_OFF;  end
                        4'd7: begin clip_addr <= CLIP_BOT_OFF_ADDR;    clip_wdata <= IMG_B_OFF;  end
                        4'd8: begin clip_addr <= CLIP_COMMIT_ADDR;     clip_wdata <= 32'h1;      end
                        default: ;
                    endcase
                    if (!clip_wait) begin
                        if (cfg_step == 4'd8) begin
                            clip_write    <= 1'b0;
                            cfg_step      <= 4'd0;
                            current_state <= ST_CONFIG_SCL;
                        end else
                            cfg_step <= cfg_step + 1'b1;
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // Scaler configuration
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_SCL: begin
                    scl_write <= 1'b1;
                    case (cfg_step)
                        4'd0: begin scl_addr <= SCL_IN_WIDTH_ADDR;   scl_wdata <= SCALER_IN_W;  end
                        4'd1: begin scl_addr <= SCL_IN_HEIGHT_ADDR;  scl_wdata <= SCALER_IN_H;  end
                        4'd2: begin scl_addr <= SCL_OUT_WIDTH_ADDR;  scl_wdata <= SCALER_OUT_W; end
                        4'd3: begin scl_addr <= SCL_OUT_HEIGHT_ADDR; scl_wdata <= SCALER_OUT_H; end
                        default: ;
                    endcase
                    if (!scl_wait) begin
                        if (cfg_step == 4'd3) begin
                            scl_write     <= 1'b0;
                            cfg_step      <= 4'd0;
                            current_state <= ST_CONFIG_CRS;
                        end else
                            cfg_step <= cfg_step + 1'b1;
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // CRS (Resampler) configuration
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_CRS: begin
                    crs_write <= 1'b1;
                    case (cfg_step)
                        4'd0: begin crs_addr <= CRS_OUTPUT_MODE_ADDR; crs_wdata <= CRS_OUTPUT_MODE; end
                        4'd1: begin crs_addr <= CRS_COMMIT_ADDR;      crs_wdata <= 32'h1;           end
                        default: ;
                    endcase
                    if (!crs_wait) begin
                        if (cfg_step == 4'd1) begin
                            crs_write     <= 1'b0;
                            cfg_step      <= 4'd0;
                            current_state <= ST_CONFIG_CSC;
                        end else
                            cfg_step <= cfg_step + 1'b1;
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // CSC configuration  (12 coefficient/summand registers + OUT_CS + COMMIT)
                // ══════════════════════════════════════════════════════════════════
                ST_CONFIG_CSC: begin
                    csc_write <= 1'b1;
                    case (cfg_step)
                        4'd0:  begin csc_addr_r <= ADDR_CSC_COEFF_A0[6:0];   csc_wdata <= csc_a0;     end
                        4'd1:  begin csc_addr_r <= ADDR_CSC_COEFF_A1[6:0];   csc_wdata <= csc_a1;     end
                        4'd2:  begin csc_addr_r <= ADDR_CSC_COEFF_A2[6:0];   csc_wdata <= csc_a2;     end
                        4'd3:  begin csc_addr_r <= ADDR_CSC_COEFF_B0[6:0];   csc_wdata <= csc_b0;     end
                        4'd4:  begin csc_addr_r <= ADDR_CSC_COEFF_B1[6:0];   csc_wdata <= csc_b1;     end
                        4'd5:  begin csc_addr_r <= ADDR_CSC_COEFF_B2[6:0];   csc_wdata <= csc_b2;     end
                        4'd6:  begin csc_addr_r <= ADDR_CSC_COEFF_C0[6:0];   csc_wdata <= csc_c0;     end
                        4'd7:  begin csc_addr_r <= ADDR_CSC_COEFF_C1[6:0];   csc_wdata <= csc_c1;     end
                        4'd8:  begin csc_addr_r <= ADDR_CSC_COEFF_C2[6:0];   csc_wdata <= csc_c2;     end
                        4'd9:  begin csc_addr_r <= ADDR_CSC_SUMMAND_S0[6:0]; csc_wdata <= csc_s0;     end
                        4'd10: begin csc_addr_r <= ADDR_CSC_SUMMAND_S1[6:0]; csc_wdata <= csc_s1;     end
                        4'd11: begin csc_addr_r <= ADDR_CSC_SUMMAND_S2[6:0]; csc_wdata <= csc_s2;     end
                        4'd12: begin csc_addr_r <= ADDR_CSC_OUT_CS[6:0];     csc_wdata <= csc_out_cs; end
                        4'd13: begin csc_addr_r <= ADDR_CSC_COMMIT[6:0];     csc_wdata <= 32'hFFFFFFFF; end
                        default: ;
                    endcase
                    if (!csc_wait) begin
                        if (cfg_step == 4'd13) begin
                            csc_write     <= 1'b0;
                            cfg_step      <= 4'd0;
                            current_state <= ST_POLL_CSC;
                        end else
                            cfg_step <= cfg_step + 1'b1;
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // Poll CSC status until commit is absorbed
                // ══════════════════════════════════════════════════════════════════
                ST_POLL_CSC: begin
                    if (cfg_step == 4'd0) begin
                        csc_read_r  <= 1'b1;
                        csc_addr_r  <= ADDR_CSC_STATUS[6:0];
                        if (!csc_wait) begin
                            csc_read_r <= 1'b0;
                            cfg_step   <= 4'd1;
                        end
                    end else begin
                        if (csc_readdatavalid) begin
                            cfg_step <= 4'd0;
                            if (csc_readdata[1] == 1'b0)
                                current_state <= ST_WORKING;
                            // else re-poll
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════════════
                // All IPs configured — pipeline running
                // ══════════════════════════════════════════════════════════════════
                ST_WORKING: begin
                    tpg_write  <= 1'b0; tpg_read   <= 1'b0;
                    clip_write <= 1'b0;
                    scl_write  <= 1'b0;
                    crs_write  <= 1'b0;
                    csc_write  <= 1'b0; csc_read_r <= 1'b0;
                end

                default: current_state <= ST_IDLE;

            endcase
        end
    end

    // =========================================================================
    // TPG → DIL gating
    // =========================================================================
    // pipeline.v does NOT wire TPG output to DIL input internally.
    // We bridge them here and gate tvalid so the DIL only sees frames once all
    // IPs have been configured (ST_WORKING).

    wire        ready_to_start;
	 
	 assign ready_to_start = (current_state >= ST_CONFIG_CSC);
	 //assign ready_to_start = 1'b1;

    // TPG output wires (driven by pipeline)
    wire [15:0] tpg_out_tdata;
    wire        tpg_out_tvalid;
    wire        tpg_out_tready;
    wire        tpg_out_tlast;
    wire [1:0]  tpg_out_tuser;

    // DIL input: tvalid gated; tready fed back to TPG; tdata/tlast/tuser pass through.
    // tuser: DIL expects [2:0]; TPG produces [1:0] — pad MSB with 0.
    wire [23:0] dil_in_tdata  = {8'h00, tpg_out_tdata};
    wire        dil_in_tvalid = tpg_out_tvalid & ready_to_start;
    wire        dil_in_tready;                          // driven by pipeline DIL port
    wire        dil_in_tlast  = tpg_out_tlast;
    wire [2:0]  dil_in_tuser  = {1'b0, tpg_out_tuser};

    assign tpg_out_tready = dil_in_tready & ready_to_start;

    // Inter-IP wires
    // DIL -> CRS
    wire [23:0] dil_out_tdata;
    wire        dil_out_tvalid;
    wire        dil_out_tready;
    wire        dil_out_tlast;
    wire [2:0]  dil_out_tuser;

    // CRS -> CSC
    wire [23:0] crs_out_tdata;
    wire        crs_out_tvalid;
    wire        crs_out_tready;
    wire        crs_out_tlast;
    wire [2:0]  crs_out_tuser;

    // CSC -> Clipper
    wire [23:0] csc_out_tdata;
    wire        csc_out_tvalid;
    wire        csc_out_tready;
    wire        csc_out_tlast;
    wire [2:0]  csc_out_tuser;

    // Clipper -> ProtocolConv
    wire [23:0] clip_out_tdata;
    wire        clip_out_tvalid;
    wire        clip_out_tready;
    wire        clip_out_tlast;
    wire [2:0]  clip_out_tuser;

    // ProtocolConv -> Scaler
    wire [23:0] pc_out_tdata;
    wire        pc_out_tvalid;
    wire        pc_out_tready;
    wire        pc_out_tlast;
    wire [2:0]  pc_out_tuser;

    pipeline u_pipeline (
        .clk_clk     (clk),
        .reset_reset (reset),

        // ----- TPG AXI4-S output (16-bit, 2-bit tuser) -----
        // Captured into tpg_out_* wires; gated & bridged to DIL input below.
        .intel_vvp_tpg_0_axi4s_vid_out_tdata  (tpg_out_tdata),
        .intel_vvp_tpg_0_axi4s_vid_out_tvalid (tpg_out_tvalid),
        .intel_vvp_tpg_0_axi4s_vid_out_tready (tpg_out_tready),
        .intel_vvp_tpg_0_axi4s_vid_out_tlast  (tpg_out_tlast),
        .intel_vvp_tpg_0_axi4s_vid_out_tuser  (tpg_out_tuser),

        // ----- DIL AXI4-S input — fed from gated TPG output -----
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

        // ----- Protocol Converter AXI4-S input -----
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tdata  (clip_out_tdata),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tvalid (clip_out_tvalid),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tready (clip_out_tready),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tlast  (clip_out_tlast),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tuser  (clip_out_tuser),

        // ----- Protocol Converter AXI4-S output -----
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tdata  (pc_out_tdata),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tvalid (pc_out_tvalid),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tready (pc_out_tready),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tlast  (pc_out_tlast),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tuser  (pc_out_tuser),

        // ----- Scaler AXI4-S input -----
        .intel_vvp_scaler_0_axi4s_vid_in_tdata  (pc_out_tdata),
        .intel_vvp_scaler_0_axi4s_vid_in_tvalid (pc_out_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_in_tready (pc_out_tready),
        .intel_vvp_scaler_0_axi4s_vid_in_tlast  (pc_out_tlast),
        .intel_vvp_scaler_0_axi4s_vid_in_tuser  (pc_out_tuser),

        // ----- Scaler output -----
        .intel_vvp_scaler_0_axi4s_vid_out_tdata  (out_tdata),
        .intel_vvp_scaler_0_axi4s_vid_out_tvalid (out_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_out_tready (out_tready),
        .intel_vvp_scaler_0_axi4s_vid_out_tlast  (out_tlast),
        .intel_vvp_scaler_0_axi4s_vid_out_tuser  (out_tuser),

        // ----- TPG Avalon-MM control -----
        .intel_vvp_tpg_0_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_0_av_mm_control_agent_write         (tpg_write),
        .intel_vvp_tpg_0_av_mm_control_agent_read          (tpg_read),
        .intel_vvp_tpg_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_0_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdata      (tpg_readdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdatavalid (tpg_readdatavalid),
        .intel_vvp_tpg_0_av_mm_control_agent_waitrequest   (tpg_wait),

        // ----- Clipper Avalon-MM control -----
        .intel_vvp_clipper_0_av_mm_control_agent_address       (clip_addr),
        .intel_vvp_clipper_0_av_mm_control_agent_write         (clip_write),
        .intel_vvp_clipper_0_av_mm_control_agent_read          (1'b0),
        .intel_vvp_clipper_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_clipper_0_av_mm_control_agent_writedata     (clip_wdata),
        .intel_vvp_clipper_0_av_mm_control_agent_readdata      (),
        .intel_vvp_clipper_0_av_mm_control_agent_readdatavalid (),
        .intel_vvp_clipper_0_av_mm_control_agent_waitrequest   (clip_wait),

        // ----- CRS Avalon-MM control -----
        .intel_vvp_crs_0_av_mm_control_agent_address       (crs_addr),
        .intel_vvp_crs_0_av_mm_control_agent_write         (crs_write),
        .intel_vvp_crs_0_av_mm_control_agent_read          (1'b0),
        .intel_vvp_crs_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_crs_0_av_mm_control_agent_writedata     (crs_wdata),
        .intel_vvp_crs_0_av_mm_control_agent_readdata      (),
        .intel_vvp_crs_0_av_mm_control_agent_readdatavalid (),
        .intel_vvp_crs_0_av_mm_control_agent_waitrequest   (crs_wait),

        // ----- CSC Avalon-MM control -----
        .intel_vvp_csc_0_av_mm_control_agent_address       (csc_addr_r),
        .intel_vvp_csc_0_av_mm_control_agent_write         (csc_write),
        .intel_vvp_csc_0_av_mm_control_agent_read          (csc_read_r),
        .intel_vvp_csc_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_csc_0_av_mm_control_agent_writedata     (csc_wdata),
        .intel_vvp_csc_0_av_mm_control_agent_readdata      (csc_readdata),
        .intel_vvp_csc_0_av_mm_control_agent_readdatavalid (csc_readdatavalid),
        .intel_vvp_csc_0_av_mm_control_agent_waitrequest   (csc_wait),

        // ----- Scaler Avalon-MM control -----
        .intel_vvp_scaler_0_av_mm_control_agent_address       (scl_addr),
        .intel_vvp_scaler_0_av_mm_control_agent_write         (scl_write),
        .intel_vvp_scaler_0_av_mm_control_agent_read          (1'b0),
        .intel_vvp_scaler_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_scaler_0_av_mm_control_agent_writedata     (scl_wdata),
        .intel_vvp_scaler_0_av_mm_control_agent_readdata      (),
        .intel_vvp_scaler_0_av_mm_control_agent_readdatavalid (),
        .intel_vvp_scaler_0_av_mm_control_agent_waitrequest   (scl_wait)
    );

endmodule