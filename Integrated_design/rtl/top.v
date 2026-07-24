`timescale 1 ps / 1 ps

// =============================================================================
// top.v  -  Universal Daddy Controller (Packaged IP)
//
// Supports topologies: FULL, SCALER_ONLY, CSC_ONLY, CRS_ONLY,
//                      CRS_CSC, CLIP_SCL, DIL_ONLY
// Supports input:      INPUT_SEL=0 (TPG), INPUT_SEL=1 (image/PC1)
//
// MM Bridge address map (12-bit byte addressed, inside intel_vvp_pipeline2):
//   DIL  -> 0x000   CRS  -> 0x200   CSC  -> 0x400
//   CLIP -> 0x600   SCL  -> 0x800
//
// Register addresses verified against UG-20344 (2026.03.03).
//
// CLIPPER (Full protocol input):
//   IMG_INFO_* (0x620-0x634) are READ-ONLY in Full protocol mode.
//   Only write: 0x644 COMMIT, 0x648 LEFT, 0x64C TOP,
//               0x650 RIGHT_OFFSET or CLIP_WIDTH,
//               0x654 BOTTOM_OFFSET or CLIP_HEIGHT
//
// SCALER (Lite mode, SC_EXTERNAL_MODE=1):
//   0x920 IMG_INFO_WIDTH  (Lite RW) = input width
//   0x924 IMG_INFO_HEIGHT (Lite RW) = input height
//   0x948 OUTPUT_WIDTH    = output width
//   0x94C OUTPUT_HEIGHT   = output height
//   No COMMIT in Lite mode.
//
// CRS (Full mode, CRS_EXTERNAL_MODE=0):
//   0x344 COMMIT, 0x348 OUTPUT_MODE (0=420, 2=422, 3=444)
//
// CSC (Full mode, CSC_EXTERNAL_MODE=0):
//   0x544 COMMIT, 0x548-0x578 coefficients + output color space
//
// CSC frame strategy (matches flat design exactly):
//   TPG mode:
//     ready_to_start fires at ST_CONFIG_CSC -> TPG data flows WHILE
//     CSC registers are being written. First frame through CSC uses
//     default coefficients (harmless, output not captured yet).
//     After COMMIT, poll STATUS bit[1] until clear, then ST_WORKING.
//     out_tready=1 from reset so pipeline drains freely during poll.
//     tb captures first SOF after ST_WORKING - no discard needed.
//   Image mode:
//     Configure CSC, skip poll, go to ST_CONFIG_PC1 -> ST_WORKING.
//     Image data only flows at ST_WORKING, so first frame is clean.
//
// FSM config order:
//   FULL:        CLIP->SCL->CRS->CSC->[POLL_CSC(TPG)]->[ PC1]->WORKING
//   SCALER_ONLY: SCL->[PC1]->WORKING
//   CSC_ONLY:    CSC->[POLL_CSC(TPG)]->[PC1]->WORKING
//   CRS_ONLY:    CRS->[PC1]->WORKING
//   CRS_CSC:     CRS->CSC->[POLL_CSC(TPG)]->[PC1]->WORKING
//   CLIP_SCL:    CLIP->SCL->[PC1]->WORKING
//   DIL_ONLY:    [PC1]->WORKING
// =============================================================================

module top #(
    parameter        TOPOLOGY        = "FULL",
    parameter [0:0]  INPUT_SEL       = 1'b0,

    parameter [31:0] IMG_WIDTH       = 32'd640,
    parameter [31:0] IMG_HEIGHT      = 32'd480,

    parameter [31:0] IMG_L_OFF       = 32'd0,
    parameter [31:0] IMG_T_OFF       = 32'd0,
    parameter [31:0] IMG_R_OFF       = 32'd0,
    parameter [31:0] IMG_B_OFF       = 32'd0,

    // Scaler output
    parameter [31:0] SCALER_OUT_W    = 32'd640,
    parameter [31:0] SCALER_OUT_H    = 32'd480,

    // CRS output mode: 0=420, 2=422, 3=444
    parameter [31:0] CRS_OUTPUT_MODE =                                                                                                                       32'd3,

    // CSC mode: 0=passthrough, 1=RGB->YCbCrHD, 2=YCbCrHD->RGB,
    //           3=RGB->YCbCrSD, 4=YCbCrSD->RGB
    parameter [2:0]  CSC_MODE =                                                                                                                       3'd0,
    parameter [31:0] CSC_COLOR_SPACE = 32'd2,
	 
	 
	 parameter [31:0] TPG_MODE = 32'd1,
	 parameter [31:0] TPG_INTERLACED = 32'd0,

    // Number of color planes on the scaler datapath (must match the generated
    // pipeline IP's NUMBER_OF_COLOR_PLANES): 3 for RGB/4:4:4, 2 for 4:2:2/4:2:0.
    parameter [31:0] VID_PLANES = 32'd3,

    // Frame Rate Conversion select. Mirrors the packaged-IP build:
    //   1 = build INCLUDES the VFB frame buffer (SCL->ltf->VFB->out). The FSM
    //       must start the VFB read side (OUTPUT_CONTROL GO) or nothing is
    //       emitted; m_axis_video_out then carries the FRAME READ from DDR4.
    //   0 = build has NO VFB; the scaler output goes straight to
    //       m_axis_video_out (original behaviour, no VFB register writes).
    // Driven from app/configuration.vh via tb.v. No platform-design change:
    // the top-level Qsys wiring is identical for both builds.
    parameter [0:0]  FRC_ENABLE = 1'b0
)(
    input  wire        clk,
    input  wire        reset,

    // Dedicated EMIF reference clock (must be 200 MHz - the io96b EMIF PHY is
    // built for a 200 MHz refclk; feeding it the 100 MHz video clock stalls
    // calibration so the VFB never writes). Separate from the video clock.
    input  wire        emif_ref_clk,

    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser,

    // PC1 image input (used when INPUT_SEL=1)
    input  wire [23:0] pc1_in_tdata,
    input  wire        pc1_in_tvalid,
    output wire        pc1_in_tready,
    input  wire        pc1_in_tlast,
    input  wire [2:0]  pc1_in_tuser
);

    
	 // =========================================================================
    // Topology flags
    // =========================================================================
    localparam DO_DIL  = (TOPOLOGY=="FULL"||TOPOLOGY=="DIL_ONLY")                        ? 1 : 0;
    localparam DO_CRS  = (TOPOLOGY=="FULL"||TOPOLOGY=="CRS_CSC"||TOPOLOGY=="CRS_ONLY")   ? 1 : 0;
    localparam DO_CSC  = (TOPOLOGY=="FULL"||TOPOLOGY=="CSC_ONLY"||TOPOLOGY=="CRS_CSC")   ? 1 : 0;
    localparam DO_CLIP = (TOPOLOGY=="FULL"||TOPOLOGY=="CLIP_SCL")                        ? 1 : 0;
    localparam DO_SCL  = (TOPOLOGY=="FULL"||TOPOLOGY=="SCALER_ONLY"||TOPOLOGY=="CLIP_SCL") ? 1 : 0;
    localparam DO_PC1  = (INPUT_SEL==1'b1) ? 1 : 0;

    // =========================================================================
    // Derived clipper output dimensions
    // =========================================================================
    localparam [31:0] CLIP_OUT_W = IMG_WIDTH  - IMG_L_OFF - IMG_R_OFF;
    localparam [31:0] CLIP_OUT_H = IMG_HEIGHT - IMG_T_OFF - IMG_B_OFF;

    // Scaler input = clipper output if clip active, else full image
    localparam [31:0] SCL_IN_W = DO_CLIP ? CLIP_OUT_W : IMG_WIDTH;
    localparam [31:0] SCL_IN_H = DO_CLIP ? CLIP_OUT_H : IMG_HEIGHT;

    // =========================================================================
    // MM Bridge register addresses (12-bit byte addressed)
    // =========================================================================

    // --- CRS base = 0x200 ---
    localparam [11:0] CRS_BASE        = 12'h200;
    localparam [11:0] CRS_STATUS_ADDR = CRS_BASE | 12'h140;  // 0x340
    localparam [11:0] CRS_COMMIT_ADDR = CRS_BASE | 12'h144;  // 0x344
    localparam [11:0] CRS_OUT_MODE    = CRS_BASE | 12'h148;  // 0x348


    // --- CSC base = 0x400 ---
    localparam [11:0] CSC_BASE        = 12'h400;
    localparam [11:0] CSC_STATUS      = CSC_BASE | 12'h140;  // 0x540
    localparam [11:0] CSC_COMMIT_ADDR = CSC_BASE | 12'h144;  // 0x544
    localparam [11:0] CSC_COEFF_A0    = CSC_BASE | 12'h148;  // 0x548
    localparam [11:0] CSC_COEFF_B0    = CSC_BASE | 12'h14C;  // 0x54C
    localparam [11:0] CSC_COEFF_C0    = CSC_BASE | 12'h150;  // 0x550
    localparam [11:0] CSC_COEFF_A1    = CSC_BASE | 12'h154;  // 0x554
    localparam [11:0] CSC_COEFF_B1    = CSC_BASE | 12'h158;  // 0x558
    localparam [11:0] CSC_COEFF_C1    = CSC_BASE | 12'h15C;  // 0x55C
    localparam [11:0] CSC_COEFF_A2    = CSC_BASE | 12'h160;  // 0x560
    localparam [11:0] CSC_COEFF_B2    = CSC_BASE | 12'h164;  // 0x564
    localparam [11:0] CSC_COEFF_C2    = CSC_BASE | 12'h168;  // 0x568
    localparam [11:0] CSC_SUMMAND_S0  = CSC_BASE | 12'h16C;  // 0x56C
    localparam [11:0] CSC_SUMMAND_S1  = CSC_BASE | 12'h170;  // 0x570
    localparam [11:0] CSC_SUMMAND_S2  = CSC_BASE | 12'h174;  // 0x574
    localparam [11:0] CSC_OUT_CS      = CSC_BASE | 12'h178;  // 0x578

    // --- CLIPPER base = 0x600 ---
    // In Full protocol mode IMG_INFO_* are RO for CRS/CSC.
    // But for Clipper, the flat design writes these to set expected input dims.
    localparam [11:0] CLIP_BASE       = 12'h600;
    localparam [11:0] CLIP_COMMIT     = CLIP_BASE | 12'h144;
    localparam [11:0] CLIP_LEFT       = CLIP_BASE | 12'h148;
    localparam [11:0] CLIP_TOP        = CLIP_BASE | 12'h14C;
    localparam [11:0] CLIP_R_OR_W     = CLIP_BASE | 12'h150;
    localparam [11:0] CLIP_B_OR_H     = CLIP_BASE | 12'h154;

    // --- SCALER base = 0x800 (Lite mode) ---
    localparam [11:0] SCL_BASE        = 12'h800;
    localparam [11:0] SCL_IN_WIDTH    = SCL_BASE | 12'h120;  // 0x920 IMG_INFO_WIDTH  (Lite RW)
    localparam [11:0] SCL_IN_HEIGHT   = SCL_BASE | 12'h124;  // 0x924 IMG_INFO_HEIGHT (Lite RW)
    localparam [11:0] SCL_OUT_WIDTH   = SCL_BASE | 12'h148;  // 0x948 OUTPUT_WIDTH
    localparam [11:0] SCL_OUT_HEIGHT  = SCL_BASE | 12'h14C;  // 0x94C OUTPUT_HEIGHT

    // --- VFB / Frame Rate Converter base = 0xE00 (last datapath stage) ---
    // Register offsets are word<<2 | base over the s0 bridge.
    //   OUTPUT_CONTROL word 87 -> 0xF5C, bit0 = GO (start read side)
    //   OUTPUT_STATUS  word 84 -> 0xF50, bit0 = RUNNING (read side active)
    localparam [11:0] VFB_BASE        = 12'hE00;
    localparam [11:0] VFB_IN_FIELDS   = VFB_BASE | 12'h144;  // 0xF44 NUM_INPUT_FIELDS (write side)
    localparam [11:0] VFB_OUT_CTRL    = VFB_BASE | 12'h15C;  // 0xF5C OUTPUT_CONTROL bit0=GO
    localparam [11:0] VFB_OUT_STATUS  = VFB_BASE | 12'h150;  // 0xF50 OUTPUT_STATUS  bit0=RUNNING

    // --- L2F (Lite->Full) protocol converter ltf_conv_0, base = 0xC00 ---
    // Sits between scaler (Lite out) and VFB (Full in); it needs its image-info
    // programmed + GO set or it swallows one beat and stalls (scaler backs up).
    // Same VVP protocol-converter regmap as PC1: word<<2 | base.
    //   IMG_INFO width 0x48 / height 0x49 / interlace 0x4A / colorspace 0x4C /
    //   subsampling 0x4D ; CTRL 0x55 bit0 = GO.
    localparam [11:0] LTF_BASE        = 12'hC00;
    localparam [11:0] LTF_WIDTH       = LTF_BASE | 12'h120;  // 0xD20 IMG_INFO width
    localparam [11:0] LTF_HEIGHT      = LTF_BASE | 12'h124;  // 0xD24 IMG_INFO height
    localparam [11:0] LTF_INTERLACE   = LTF_BASE | 12'h128;  // 0xD28 IMG_INFO interlace
    localparam [11:0] LTF_COLORSPACE  = LTF_BASE | 12'h130;  // 0xD30 IMG_INFO colorspace
    localparam [11:0] LTF_SUBSAMP     = LTF_BASE | 12'h134;  // 0xD34 IMG_INFO subsampling
    localparam [11:0] LTF_CTRL        = LTF_BASE | 12'h154;  // 0xD54 CTRL bit0=GO

    // --- PC1 (7-bit word addressed, own Avalon port) ---
    localparam [6:0] PC1_ADDR_WIDTH       = 7'h48;
    localparam [6:0] PC1_ADDR_HEIGHT      = 7'h49;
    localparam [6:0] PC1_ADDR_INTERLACE   = 7'h4A;
    localparam [6:0] PC1_ADDR_COLORSPACE  = 7'h4C;
    localparam [6:0] PC1_ADDR_SUBSAMPLING = 7'h4D;
    localparam [6:0] PC1_ADDR_CTRL        = 7'h55;

	 // --- TPG (own port, 7-bit word address) ---
    localparam [6:0] TPG_ADDR_WIDTH     = 7'h48;
    localparam [6:0] TPG_ADDR_HEIGHT    = 7'h49;
    localparam [6:0] TPG_ADDR_INTERLACE = 7'h4A;
    localparam [6:0] TPG_ADDR_STATUS    = 7'h50;
    localparam [6:0] TPG_ADDR_CONTROL   = 7'h52;
    localparam [6:0] TPG_ADDR_COMMIT    = 7'h53;
    localparam [6:0] TPG_ADDR_PATTERN   = 7'h54;
    localparam [6:0] TPG_ADDR_BAR_SEL   = 7'h5A;
	 
    // =========================================================================
    // State encoding
    // =========================================================================
    localparam [4:0]
        ST_IDLE        = 5'd20,
        ST_CONFIG_CLIP = 5'd21,
        ST_CONFIG_SCL  = 5'd22,
        ST_CONFIG_CRS  = 5'd23,
        ST_POLL_CRS    = 5'd24,
        ST_CONFIG_CSC  = 5'd25,
        ST_POLL_CSC    = 5'd26,
        ST_CONFIG_PC1  = 5'd27,
        ST_WORKING     = 5'd28,
        ST_WAIT_CRS    = 5'd29,
        ST_FRC_WR_WAIT = 5'd30,   // FRC: let write side fill DDR4; poll NUM_INPUT_FIELDS
        ST_FRC_GO      = 5'd31,   // FRC: full frame written -> start VFB read (GO)
        ST_CONFIG_LTF  = 5'd19,   // FRC: program the L2F (ltf_conv) after the scaler

		  // TPG (own Avalon port)
        ST_TPG_CTRL_1    = 5'd0,
        ST_TPG_WR_INTL   = 5'd1,
        ST_TPG_WR_W      = 5'd2,
        ST_TPG_WR_H      = 5'd3,
        ST_TPG_WR_PAT_T  = 5'd4,
        ST_TPG_WR_PAT_S  = 5'd5,
        ST_TPG_WR_CMT    = 5'd6,
        ST_TPG_CTRL_2    = 5'd7,
        ST_TPG_POLL_ISS  = 5'd8,
        ST_TPG_POLL_W    = 5'd9,
        ST_TPG_IP_RST    = 5'd10,
        ST_TPG_CTRL_3    = 5'd11;

    // Where the config FSM goes once the datapath is set up. In an FRC build we
    // first program the L2F converter (ST_CONFIG_LTF), then let the write side
    // fill DDR4 (ST_FRC_WR_WAIT) and start the read once a full frame is in
    // memory (ST_FRC_GO); otherwise we go straight to ST_WORKING.
    localparam [4:0] POST_CFG = FRC_ENABLE ? ST_CONFIG_LTF : ST_WORKING;

    // =========================================================================
    // CSC coefficient ROMs
    // =========================================================================
    localparam signed [31:0] PT_A0=32'sh00200000,PT_A1=32'sh00000000,PT_A2=32'sh00000000;
    localparam signed [31:0] PT_B0=32'sh00000000,PT_B1=32'sh00200000,PT_B2=32'sh00000000;
    localparam signed [31:0] PT_C0=32'sh00000000,PT_C1=32'sh00000000,PT_C2=32'sh00200000;
    localparam signed [31:0] PT_S0=32'sh00000000,PT_S1=32'sh00000000,PT_S2=32'sh00000000;

    localparam signed [31:0] RH_A0=32'sh000E0C4A,RH_A1=32'sh0001FBE7,RH_A2=32'shFFFEB852;
    localparam signed [31:0] RH_B0=32'shFFF52F1B,RH_B1=32'sh0013A5E3,RH_B2=32'shFFF33B64;
    localparam signed [31:0] RH_C0=32'shFFFCC49C,RH_C1=32'sh0005DB23,RH_C2=32'sh000E0C4A;
    localparam signed [31:0] RH_S0=32'sh10000000,RH_S1=32'sh02000000,RH_S2=32'sh10000000;

    localparam signed [31:0] HR_A0=32'sh0043AE14,HR_A1=32'shFFF92F1B,HR_A2=32'sh00000000;
    localparam signed [31:0] HR_B0=32'sh00253F7D,HR_B1=32'sh00253F7D,HR_B2=32'sh00253F7D;
    localparam signed [31:0] HR_C0=32'sh00000000,HR_C1=32'shFFEEE979,HR_C2=32'sh00396042;
    localparam signed [31:0] HR_S0=32'shDBD4FDF4,HR_S1=32'sh099FBE77,HR_S2=32'shE0FBE00D;

    localparam signed [31:0] RS_A0=32'sh000E0C4A,RS_A1=32'sh000322D1,RS_A2=32'shFFFDBA5E;
    localparam signed [31:0] RS_B0=32'shFFF6B021,RS_B1=32'sh001020C5,RS_B2=32'shFFF43958;
    localparam signed [31:0] RS_C0=32'shFFFB4396,RS_C1=32'sh00083958,RS_C2=32'sh000E0C4A;
    localparam signed [31:0] RS_S0=32'sh10000000,RS_S1=32'sh02000000,RS_S2=32'sh10000000;

    localparam signed [31:0] SR_A0=32'sh003A1CAC,SR_A1=32'shFFFA24DD,SR_A2=32'sh00000000;
    localparam signed [31:0] SR_B0=32'sh00200000,SR_B1=32'sh00200000,SR_B2=32'sh00200000;
    localparam signed [31:0] SR_C0=32'sh00000000,SR_C1=32'shFFF14FDF,SR_C2=32'sh003147AE;
    localparam signed [31:0] SR_S0=32'shE2F1A9FC,SR_S1=32'sh0A45A1CB,SR_S2=32'shE75C20C5;

    wire signed [31:0] csc_a0=(CSC_MODE==3'd1)?RH_A0:(CSC_MODE==3'd2)?HR_A0:(CSC_MODE==3'd3)?RS_A0:(CSC_MODE==3'd4)?SR_A0:PT_A0;
    wire signed [31:0] csc_a1=(CSC_MODE==3'd1)?RH_A1:(CSC_MODE==3'd2)?HR_A1:(CSC_MODE==3'd3)?RS_A1:(CSC_MODE==3'd4)?SR_A1:PT_A1;
    wire signed [31:0] csc_a2=(CSC_MODE==3'd1)?RH_A2:(CSC_MODE==3'd2)?HR_A2:(CSC_MODE==3'd3)?RS_A2:(CSC_MODE==3'd4)?SR_A2:PT_A2;
    wire signed [31:0] csc_b0=(CSC_MODE==3'd1)?RH_B0:(CSC_MODE==3'd2)?HR_B0:(CSC_MODE==3'd3)?RS_B0:(CSC_MODE==3'd4)?SR_B0:PT_B0;
    wire signed [31:0] csc_b1=(CSC_MODE==3'd1)?RH_B1:(CSC_MODE==3'd2)?HR_B1:(CSC_MODE==3'd3)?RS_B1:(CSC_MODE==3'd4)?SR_B1:PT_B1;
    wire signed [31:0] csc_b2=(CSC_MODE==3'd1)?RH_B2:(CSC_MODE==3'd2)?HR_B2:(CSC_MODE==3'd3)?RS_B2:(CSC_MODE==3'd4)?SR_B2:PT_B2;
    wire signed [31:0] csc_c0=(CSC_MODE==3'd1)?RH_C0:(CSC_MODE==3'd2)?HR_C0:(CSC_MODE==3'd3)?RS_C0:(CSC_MODE==3'd4)?SR_C0:PT_C0;
    wire signed [31:0] csc_c1=(CSC_MODE==3'd1)?RH_C1:(CSC_MODE==3'd2)?HR_C1:(CSC_MODE==3'd3)?RS_C1:(CSC_MODE==3'd4)?SR_C1:PT_C1;
    wire signed [31:0] csc_c2=(CSC_MODE==3'd1)?RH_C2:(CSC_MODE==3'd2)?HR_C2:(CSC_MODE==3'd3)?RS_C2:(CSC_MODE==3'd4)?SR_C2:PT_C2;
    wire signed [31:0] csc_s0=(CSC_MODE==3'd1)?RH_S0:(CSC_MODE==3'd2)?HR_S0:(CSC_MODE==3'd3)?RS_S0:(CSC_MODE==3'd4)?SR_S0:PT_S0;
    wire signed [31:0] csc_s1=(CSC_MODE==3'd1)?RH_S1:(CSC_MODE==3'd2)?HR_S1:(CSC_MODE==3'd3)?RS_S1:(CSC_MODE==3'd4)?SR_S1:PT_S1;
    wire signed [31:0] csc_s2=(CSC_MODE==3'd1)?RH_S2:(CSC_MODE==3'd2)?HR_S2:(CSC_MODE==3'd3)?RS_S2:(CSC_MODE==3'd4)?SR_S2:PT_S2;
    wire [31:0] csc_out_cs = ((CSC_MODE==3'd1)||(CSC_MODE==3'd3)) ? 32'd1 :
                              (CSC_MODE==3'd0) ? CSC_COLOR_SPACE : 32'd0;

    // =========================================================================
    // Registers
    // =========================================================================
    reg [4:0]  current_state;
    reg [3:0]  cfg_step;
    reg [15:0] wait_counter;

    reg [6:0]  pc1_addr;
    reg        pc1_write;
    reg [31:0] pc1_wdata;

    // The pipeline's s0 control bus widens when the internal EMIF is present:
    // its AXI4-Lite calibration/status CSR sits on the bridge at 0x0800_0000
    // (27-bit span), so s0_address grows to 28-bit for the FRC/EMIF build; the
    // non-FRC build keeps the original 12-bit (4KB) control map. All register
    // offsets used below are <= 0xFFF, so the high bits are simply driven to 0.
    localparam integer S0_AW = FRC_ENABLE ? 28 : 12;

    reg [S0_AW-1:0] bridge_addr;
    reg [31:0] bridge_wdata;
    reg        bridge_write;
    reg        bridge_read;

    wire        pc1_wait;
    wire [31:0] pc1_readdata;
    wire        pc1_readdatavalid;
    wire [31:0] bridge_readdata;
    wire        bridge_readdatavalid;
    wire        bridge_wait;

	 // Avalon-MM response wires
    wire [31:0] tpg_readdata;
    wire        tpg_readdatavalid;
    wire        tpg_wait;
	 reg [6:0]  tpg_addr;   reg        tpg_write,  tpg_read;   reg [31:0] tpg_wdata;
	 
    // =========================================================================
    // Configuration FSM
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_TPG_CTRL_1;
            pc1_write     <= 1'b0;
            bridge_write  <= 1'b0;
            bridge_read   <= 1'b0;
            cfg_step      <= 4'd0;
            wait_counter  <= 16'd0;
        end else begin
            case (current_state)

                // ??????????????????????????????????????????????????????????????????
                // TPG configuration (own Avalon port)
                // ??????????????????????????????????????????????????????????????????
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
                    tpg_wdata <= TPG_INTERLACED;
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
                    tpg_wdata <= TPG_MODE;
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
                            current_state <= ST_TPG_CTRL_3;
                        else
                            current_state <= ST_TPG_POLL_ISS;
                    end
                end

                ST_TPG_IP_RST: begin
                    cfg_step <= cfg_step + 1'b1;
                    if (cfg_step == 8'h07) current_state <= ST_TPG_CTRL_3;
                end

                ST_TPG_CTRL_3: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_CONTROL;
                    tpg_wdata <= 32'h1;
                    if (!tpg_wait) begin
                        tpg_write     <= 1'b0;
                        cfg_step      <= 4'd0;
                        current_state <= ST_IDLE;
                    end
                end
					 
					 // --------------------------------------------------------------
                ST_IDLE: begin
                    cfg_step <= 4'd0;
                    if (DO_CLIP) begin
                        bridge_addr   <= CLIP_LEFT;
                        bridge_wdata  <= IMG_L_OFF;
                        current_state <= ST_CONFIG_CLIP;
                    end else if (DO_SCL) begin
                        bridge_addr   <= SCL_IN_WIDTH;
                        bridge_wdata  <= SCL_IN_W;
                        current_state <= ST_CONFIG_SCL;
                    end else if (DO_CRS) begin
                        bridge_addr   <= CRS_OUT_MODE;
                        bridge_wdata  <= CRS_OUTPUT_MODE;
                        current_state <= ST_CONFIG_CRS;
                    end else if (DO_CSC) begin
                        bridge_addr   <= CSC_COEFF_A0;
                        bridge_wdata  <= csc_a0;
                        current_state <= ST_CONFIG_CSC;
                    end else if (DO_PC1) begin
                        pc1_addr      <= PC1_ADDR_WIDTH;
                        pc1_wdata     <= IMG_WIDTH;
                        current_state <= ST_CONFIG_PC1;
                    end else begin
                        current_state <= POST_CFG;
                    end
                end

                // --------------------------------------------------------------
                // CLIPPER: write LEFT, TOP, R_OR_W, B_OR_H, COMMIT
                // Full protocol mode - IMG_INFO_* are RO, never write them.
                // RECTANGLE: 0x650=CLIP_WIDTH,   0x654=CLIP_HEIGHT
                // OFFSETS:   0x650=RIGHT_OFFSET, 0x654=BOTTOM_OFFSET
                // --------------------------------------------------------------
                // CLIPPER: exact register write order from working flat design
                // Step 0: LEFT (preloaded in ST_IDLE)
                // Step 1: TOP
                // Step 2: RIGHT  (offset from right edge, 0 = no clip)
                // Step 3: BOTTOM (offset from bottom edge, 0 = no clip)
                // Step 4: COMMIT
                // Note: uses OFFSETS registers always - clipper calculates
                // output dims from input dims minus offsets automatically.
                // --------------------------------------------------------------
                ST_CONFIG_CLIP: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd4) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            bridge_addr   <= SCL_IN_WIDTH;
                            bridge_wdata  <= SCL_IN_W;
                            current_state <= ST_CONFIG_SCL;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr <= CLIP_TOP;    bridge_wdata <= IMG_T_OFF;  end
                                4'd2: begin bridge_addr <= CLIP_R_OR_W; bridge_wdata <= IMG_R_OFF; end
                                4'd3: begin bridge_addr <= CLIP_B_OR_H; bridge_wdata <= IMG_B_OFF; end
                                4'd4: begin bridge_addr <= CLIP_COMMIT; bridge_wdata <= 32'h1;      end
                                default: ;
                            endcase
                        end
                    end
                end

                // --------------------------------------------------------------
                // SCALER: Lite mode
                //   0x920 = input width  (IMG_INFO_WIDTH,  Lite RW)
                //   0x924 = input height (IMG_INFO_HEIGHT, Lite RW)
                //   0x948 = output width
                //   0x94C = output height
                //   No COMMIT needed in Lite mode.
                // --------------------------------------------------------------
                ST_CONFIG_SCL: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd3) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            if (DO_CRS) begin
                                bridge_addr   <= CRS_OUT_MODE;
                                bridge_wdata  <= CRS_OUTPUT_MODE;
                                current_state <= ST_CONFIG_CRS;
                            end else if (DO_CSC) begin
                                bridge_addr   <= CSC_COEFF_A0;
                                bridge_wdata  <= csc_a0;
                                current_state <= ST_CONFIG_CSC;
                            end else if (DO_PC1) begin
                                pc1_addr      <= PC1_ADDR_WIDTH;
                                pc1_wdata     <= IMG_WIDTH;
                                current_state <= ST_CONFIG_PC1;
                            end else begin
                                current_state <= POST_CFG;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr <= SCL_IN_HEIGHT;  bridge_wdata <= SCL_IN_H;    end
                                4'd2: begin bridge_addr <= SCL_OUT_WIDTH;  bridge_wdata <= SCALER_OUT_W; end
                                4'd3: begin bridge_addr <= SCL_OUT_HEIGHT; bridge_wdata <= SCALER_OUT_H; end
                                default: ;
                            endcase
                        end
                    end
                end

                // --------------------------------------------------------------
                // CRS: write OUTPUT_MODE then COMMIT
                // Full mode - IMG_INFO_* are RO, dimensions from metapackets.
                // --------------------------------------------------------------
                ST_CONFIG_CRS: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd1) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            if (DO_CSC) begin
                                // Combined: skip CRS poll, go to CSC config.
                                bridge_addr   <= CSC_COEFF_A0;
                                bridge_wdata  <= csc_a0;
                                current_state <= ST_CONFIG_CSC;
                            end else begin
                                // CRS_ONLY 422: wait 32,000 cycles for 422 path to settle.
                                current_state <= ST_WAIT_CRS;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr <= CRS_COMMIT_ADDR; bridge_wdata <= 32'h1; end
                                default: ;
                            endcase
                        end
                    end
                end

					 ST_POLL_CRS: begin
                    if (cfg_step == 4'd0) begin
                        bridge_read <= 1'b1;
                        bridge_addr <= CRS_STATUS_ADDR;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else begin
                        if (bridge_readdatavalid) begin
                            cfg_step <= 4'd0;
                            if (bridge_readdata[1] == 1'b0) begin
										  if (DO_CSC) begin
												bridge_addr   <= CSC_COEFF_A0;
												bridge_wdata  <= csc_a0;
												current_state <= ST_CONFIG_CSC;
										  end else if (DO_PC1) begin
												pc1_addr      <= PC1_ADDR_WIDTH;
												pc1_wdata     <= IMG_WIDTH;
												current_state <= ST_CONFIG_PC1;
										  end else begin
												current_state <= POST_CFG;
										  end
                            end
                            // else: pending still set, re-poll
                        end
                    end
                end
					 
                // --------------------------------------------------------------
                // CRS_ONLY 422 settling: count 32,000 cycles (~320µs @ 100MHz)
                // after CRS commit before starting data. Mirrors the natural
                // delay provided by 13 CSC writes in CRS_CSC mode.
                // --------------------------------------------------------------
                ST_WAIT_CRS: begin
                    if (wait_counter == 16'd32000) begin
                        wait_counter  <= 16'd0;
                        if (DO_PC1) begin
                            pc1_addr      <= PC1_ADDR_WIDTH;
                            pc1_wdata     <= IMG_WIDTH;
                            current_state <= ST_CONFIG_PC1;
                        end else begin
                            current_state <= POST_CFG;
                        end
                    end else begin
                        wait_counter <= wait_counter + 1'b1;
                    end
                end

                // --------------------------------------------------------------
                // CSC: write A0 B0 C0 A1 B1 C1 A2 B2 C2 S0 S1 S2 OUT_CS COMMIT
                // By the time we get here (TPG mode), TPG data is already
                // flowing (ready_to_start fired at ST_CONFIG_CSC). The first
                // frame through CSC uses default coefficients which is fine
                // because tb hasn't enabled capture yet. After COMMIT is
                // written, we poll STATUS bit[1] until clear.
                // Image mode: skip poll, go straight to PC1/WORKING.
                // --------------------------------------------------------------
                ST_CONFIG_CSC: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd13) begin
                            bridge_write <= 1'b0;
                            cfg_step     <= 4'd0;
                            if (DO_PC1) begin
                                pc1_addr      <= PC1_ADDR_WIDTH;
                                pc1_wdata     <= IMG_WIDTH;
                                current_state <= ST_CONFIG_PC1;
                            end else if (DO_CRS) begin
                                // Combined: no data flowing, CSC applies immediately.
                                // Skip STATUS poll, go straight to WORKING.
                                current_state <= POST_CFG;
                            end else begin
                                current_state <= ST_POLL_CSC;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1:  begin bridge_addr <= CSC_COEFF_B0;    bridge_wdata <= csc_b0;       end
                                4'd2:  begin bridge_addr <= CSC_COEFF_C0;    bridge_wdata <= csc_c0;       end
                                4'd3:  begin bridge_addr <= CSC_COEFF_A1;    bridge_wdata <= csc_a1;       end
                                4'd4:  begin bridge_addr <= CSC_COEFF_B1;    bridge_wdata <= csc_b1;       end
                                4'd5:  begin bridge_addr <= CSC_COEFF_C1;    bridge_wdata <= csc_c1;       end
                                4'd6:  begin bridge_addr <= CSC_COEFF_A2;    bridge_wdata <= csc_a2;       end
                                4'd7:  begin bridge_addr <= CSC_COEFF_B2;    bridge_wdata <= csc_b2;       end
                                4'd8:  begin bridge_addr <= CSC_COEFF_C2;    bridge_wdata <= csc_c2;       end
                                4'd9:  begin bridge_addr <= CSC_SUMMAND_S0;  bridge_wdata <= csc_s0;       end
                                4'd10: begin bridge_addr <= CSC_SUMMAND_S1;  bridge_wdata <= csc_s1;       end
                                4'd11: begin bridge_addr <= CSC_SUMMAND_S2;  bridge_wdata <= csc_s2;       end
                                4'd12: begin bridge_addr <= CSC_OUT_CS;      bridge_wdata <= csc_out_cs;   end
                                4'd13: begin bridge_addr <= CSC_COMMIT_ADDR; bridge_wdata <= 32'hFFFFFFFF; end
                                default: ;
                            endcase
                        end
                    end
                end

                // --------------------------------------------------------------
                // Poll CSC STATUS until pending bit[1] clears (TPG mode only).
                // CRITICAL: out_tready must be 1 during this state so the
                // pipeline drains freely. If the output is stalled, CSC never
                // finishes its frame and the pending bit never clears (deadlock).
                // tb.v sets out_tready=1 right after reset to ensure this.
                // --------------------------------------------------------------
                ST_POLL_CSC: begin
                    if (cfg_step == 4'd0) begin
                        bridge_read <= 1'b1;
                        bridge_addr <= CSC_STATUS;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else begin
                        if (bridge_readdatavalid) begin
                            cfg_step <= 4'd0;
                            if (bridge_readdata[1] == 1'b0) begin
                                current_state <= POST_CFG;
                            end
                            // else: pending still set, re-poll
                        end
                    end
                end

                // --------------------------------------------------------------
                // PC1: configure protocol converter (image input source)
                // --------------------------------------------------------------
                ST_CONFIG_PC1: begin
                    pc1_write <= 1'b1;
                    if (pc1_write && !pc1_wait) begin
                        if (cfg_step == 4'd5) begin
                            pc1_write     <= 1'b0;
                            cfg_step      <= 4'd0;
                            current_state <= POST_CFG;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin pc1_addr <= PC1_ADDR_HEIGHT;      pc1_wdata <= IMG_HEIGHT; end
                                4'd2: begin pc1_addr <= PC1_ADDR_INTERLACE;   pc1_wdata <= 32'h0;      end
                                4'd3: begin pc1_addr <= PC1_ADDR_COLORSPACE;  pc1_wdata <= 32'h0;      end
                                4'd4: begin pc1_addr <= PC1_ADDR_SUBSAMPLING; pc1_wdata <= 32'h3;      end
                                4'd5: begin pc1_addr <= PC1_ADDR_CTRL;        pc1_wdata <= 32'h1;      end
                                default: ;
                            endcase
                        end
                    end
                end

                // --------------------------------------------------------------
                // Program the L2F (ltf_conv_0) converter after the scaler.
                // It converts the scaler's Lite output to Full for the VFB, but
                // it needs its image-info written and GO set or it stalls after
                // one beat (backpressuring the scaler). Video is gated here
                // (frc_video_phase excludes this state), so we configure with the
                // pipeline idle, then open the gate at ST_FRC_WR_WAIT.
                // Regs (base 0xC00): width/height = scaler output, subsampling
                // = 3 (4:4:4), colorspace = 1 (YCbCr), then CTRL GO = 1 last.
                // --------------------------------------------------------------
                ST_CONFIG_LTF: begin
                    bridge_write <= 1'b1;
                    case (cfg_step)
                        4'd0: begin bridge_addr <= LTF_WIDTH;      bridge_wdata <= SCALER_OUT_W; end
                        4'd1: begin bridge_addr <= LTF_HEIGHT;     bridge_wdata <= SCALER_OUT_H; end
                        4'd2: begin bridge_addr <= LTF_INTERLACE;  bridge_wdata <= 32'h0;        end
                        4'd3: begin bridge_addr <= LTF_COLORSPACE; bridge_wdata <= 32'h1;        end
                        4'd4: begin bridge_addr <= LTF_SUBSAMP;    bridge_wdata <= 32'h3;        end
                        4'd5: begin bridge_addr <= LTF_CTRL;       bridge_wdata <= 32'h1;        end
                        default: ;
                    endcase
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd5) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            current_state <= ST_FRC_WR_WAIT;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                        end
                    end
                end

                // --------------------------------------------------------------
                // FRC write phase (FRC build only, entered via POST_CFG).
                // Video is already flowing here (ready_to_start covers this state)
                // so the VFB write side stores incoming frames into the DDR4
                // memory model. The write side auto-runs (no GO); it stalls until
                // DDR4 calibration completes, then writes. We poll NUM_INPUT_FIELDS
                // (0xF44) and only advance once a full field/frame has been written
                // to memory (counter != 0). This is an event-driven handshake -
                // "write a complete frame, THEN read" - not a fixed timer.
                // --------------------------------------------------------------
                ST_FRC_WR_WAIT: begin
                    if (cfg_step == 4'd0) begin
                        bridge_read <= 1'b1;
                        bridge_addr <= VFB_IN_FIELDS;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else begin
                        if (bridge_readdatavalid) begin
                            cfg_step <= 4'd0;
                            // A complete input field has been written to DDR4.
                            if (bridge_readdata != 32'd0)
                                current_state <= ST_FRC_GO;
                            // else: nothing written yet (still calibrating), re-poll
                        end
                    end
                end

                // --------------------------------------------------------------
                // FRC read start: a full frame is now in memory, so start the VFB
                // read side. Single 32-bit write of GO=1 to OUTPUT_CONTROL (0xF5C).
                // The VFB scheduler only hands completed buffers to the reader, so
                // m_axis_video_out now carries the frame read back from DDR4.
                // --------------------------------------------------------------
                ST_FRC_GO: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= VFB_OUT_CTRL;
                    bridge_wdata <= 32'h00000001;   // OUTPUT_CONTROL.GO = 1
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_WORKING;
                    end
                end

                ST_WORKING: begin
                    pc1_write    <= 1'b0;
                    bridge_write <= 1'b0;
                    bridge_read  <= 1'b0;
                end

                default: current_state <= ST_IDLE;
            endcase
        end
    end

    // =========================================================================
    // ready_to_start - gates input video into the pipeline
    //
    // Matches flat design exactly:
    //   TPG + CSC:    start at ST_CONFIG_CSC so first frame flows while CSC
    //                 registers are being written. Poll clears before WORKING.
    //   TPG + no CSC: start at first config state (SCL or CRS or WORKING)
    //   Image mode:   always wait for ST_WORKING
    // =========================================================================
    wire ready_to_start;
    // FRC build: video must keep flowing through the write phase so the VFB write
    // side can fill DDR4 (ST_FRC_WR_WAIT/ST_FRC_GO) and on through ST_WORKING.
    wire frc_video_phase = (current_state == ST_FRC_WR_WAIT) ||
                           (current_state == ST_FRC_GO)      ||
                           (current_state == ST_WORKING);
    generate
        if (DO_PC1) begin : gen_rts_image
            // Image: only start when fully configured (or, FRC, once the write
            // phase begins so frames reach the VFB write side).
            assign ready_to_start = FRC_ENABLE ? frc_video_phase
                                               : (current_state == ST_WORKING);
        end else if (DO_CSC) begin : gen_rts_csc
            // Combined CRS+CSC: both committed with no live data; start at WORKING.
            // CSC_ONLY: start at ST_CONFIG_CSC (first frame absorbs commit).
            assign ready_to_start = FRC_ENABLE ? frc_video_phase
                                    : (DO_CRS ? (current_state == ST_WORKING) : (current_state >= ST_CONFIG_CSC));
        end else if (DO_SCL) begin : gen_rts_scl
            assign ready_to_start = FRC_ENABLE ? frc_video_phase
                                               : (current_state == ST_WORKING);
        end else if (DO_CRS) begin : gen_rts_crs
            // CRS_ONLY: wait for full settling (ST_WAIT_CRS counts 32k cycles).
            assign ready_to_start = FRC_ENABLE ? frc_video_phase : (current_state == ST_WORKING);
        end else begin : gen_rts_default
            assign ready_to_start = FRC_ENABLE ? frc_video_phase : (current_state == ST_WORKING);
        end
    endgenerate

    // =========================================================================
    // Video wires (all 24-bit/3-bit - TPG configured for 444 YCbCr)
    // =========================================================================
    wire [23:0] tpg_tdata;
    wire        tpg_tvalid;
    wire        tpg_tready;
    wire        tpg_tlast;
    wire [2:0]  tpg_tuser;

    wire [23:0] pc1_tdata;
    wire        pc1_tvalid;
    wire        pc1_tready;
    wire        pc1_tlast;
    wire [2:0]  pc1_tuser;

    wire        vid_in_tready;

    // Width-generalized video mux. TPG and PC1 sources are always 24-bit; for
    // 2-plane formats (4:2:2 / 4:2:0) the meaningful samples occupy the low 16
    // bits, so a single low-slice to VID_BITS handles every format with no
    // per-format special case (this also fixes 4:2:0, which the old ch hack
    // only handled for 4:2:2).
    wire [23:0] vid_in_tdata  = INPUT_SEL  ? pc1_tdata  : (TPG_MODE == 32'd2) ? {8'b0,tpg_tdata[15:0]} : tpg_tdata;
    wire        vid_in_tvalid = (INPUT_SEL ? pc1_tvalid : tpg_tvalid) & ready_to_start;
    wire        vid_in_tlast  = INPUT_SEL  ? pc1_tlast  : tpg_tlast;
    wire [2:0]  vid_in_tuser  = INPUT_SEL  ? pc1_tuser  : (TPG_MODE == 32'd2) ? {1'b0,tpg_tuser[1:0]} : tpg_tuser;
	 
//	 // Video datapath width = color planes * 8 bits/sample (16 or 24).
//    localparam VID_BITS = (CRS_OUTPUT_MODE == 32'd2) ? 32'd15 : 32'd23;
//    wire [VID_BITS:0] pl_out_tdata;
//    assign out_tdata = pl_out_tdata;   // narrower RHS zero-extends to [23:0]

    assign tpg_tready = INPUT_SEL ? 1'b1 : (vid_in_tready & ready_to_start);
    assign pc1_tready = INPUT_SEL ? (vid_in_tready & ready_to_start) : 1'b1;

    // =========================================================================
    // Platform Designer instantiation
    // =========================================================================
    pipeline u0 (
        .clk_clk                           (clk),
        .emif_ref_clk_clk                  (emif_ref_clk),
        .reset_reset                       (reset),
        .intel_vvp_pipeline2_0_reset_reset (reset),

        .s0_address       (bridge_addr),
        .s0_write         (bridge_write),
        .s0_read          (bridge_read),
        .s0_byteenable    (4'hF),
        .s0_burstcount    (1'b1),
        .s0_debugaccess   (1'b0),
        .s0_writedata     (bridge_wdata),
        .s0_readdata      (bridge_readdata),
        .s0_readdatavalid (bridge_readdatavalid),
        .s0_waitrequest   (bridge_wait),

        .s_axis_video_in_tdata  (vid_in_tdata),
        .s_axis_video_in_tvalid (vid_in_tvalid),
        .s_axis_video_in_tready (vid_in_tready),
        .s_axis_video_in_tlast  (vid_in_tlast),
        .s_axis_video_in_tuser  (vid_in_tuser),

        .m_axis_video_out_tdata  (out_tdata),
        .m_axis_video_out_tvalid (out_tvalid),
        .m_axis_video_out_tready (out_tready),
        .m_axis_video_out_tlast  (out_tlast),
        .m_axis_video_out_tuser  (out_tuser),

        .axi4s_vid_in_tdata  (pc1_in_tdata),
        .axi4s_vid_in_tvalid (pc1_in_tvalid),
        .axi4s_vid_in_tready (pc1_in_tready),
        .axi4s_vid_in_tlast  (pc1_in_tlast),
        .axi4s_vid_in_tuser  (pc1_in_tuser),

        .axi4s_vid_out_1_tdata  (pc1_tdata),
        .axi4s_vid_out_1_tvalid (pc1_tvalid),
        .axi4s_vid_out_1_tready (pc1_tready),
        .axi4s_vid_out_1_tlast  (pc1_tlast),
        .axi4s_vid_out_1_tuser  (pc1_tuser),

        .av_mm_control_agent_address       (pc1_addr),
        .av_mm_control_agent_write         (pc1_write),
        .av_mm_control_agent_read          (1'b0),
        .av_mm_control_agent_byteenable    (4'hF),
        .av_mm_control_agent_writedata     (pc1_wdata),
        .av_mm_control_agent_readdata      (pc1_readdata),
        .av_mm_control_agent_readdatavalid (pc1_readdatavalid),
        .av_mm_control_agent_waitrequest   (pc1_wait),

        .axi4s_vid_out_tdata  (tpg_tdata),
        .axi4s_vid_out_tvalid (tpg_tvalid),
        .axi4s_vid_out_tready (tpg_tready),
        .axi4s_vid_out_tlast  (tpg_tlast),
        .axi4s_vid_out_tuser  (tpg_tuser),
		  
		  // ----- TPG Avalon-MM control (own port) -----
        .intel_vvp_tpg_1_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_1_av_mm_control_agent_write         (tpg_write),
        .intel_vvp_tpg_1_av_mm_control_agent_read          (tpg_read),
        .intel_vvp_tpg_1_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_1_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_1_av_mm_control_agent_readdata      (tpg_readdata),
        .intel_vvp_tpg_1_av_mm_control_agent_readdatavalid (tpg_readdatavalid),
        .intel_vvp_tpg_1_av_mm_control_agent_waitrequest   (tpg_wait)
    );

endmodule
