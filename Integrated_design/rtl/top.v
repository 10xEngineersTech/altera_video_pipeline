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
    parameter        TOPOLOGY        = "SCALER_ONLY",
    parameter [0:0]  INPUT_SEL       = 1'b0,
    parameter [0:0]  ENABLE_PIP      = 1'b0,

    // Frame Rate Conversion. When 1 the packaged IP carries the video frame
    // buffer (VFB) writing through the internal DDR4 EMIF to the external
    // memory model and reading back out. Adds the Lite->Full converter
    // configuration + the VFB output-side GO handshake, and widens the
    // control bridge to 28 bits (the EMIF's AXI4-Lite CSR at 0x0800_0000
    // forces ADDRESS_WIDTH=28 on the generated s0 port - see note at
    // bridge_addr below).
    parameter [0:0]  ENABLE_FRC      = 1'b0,


    parameter [31:0] IMG_WIDTH       = 32'd640,
    parameter [31:0] IMG_HEIGHT      = 32'd480,

    parameter [31:0] IMG_L_OFF       = 32'd0,
    parameter [31:0] IMG_T_OFF       = 32'd0,
    parameter [31:0] IMG_R_OFF       = 32'd0,
    parameter [31:0] IMG_B_OFF       = 32'd0,

    // Scaler output
    parameter [31:0] SCALER_OUT_W    = 32'd640,
    parameter [31:0] SCALER_OUT_H    = 32'd480,

    // PIP: background canvas size (the whole picture the inset video sits
    // inside of) and the inset's position within that canvas. Independent
    // of the pipeline's own output size (SCALER_OUT_W/H or IMG_WIDTH/HEIGHT)
    // so the inset can be smaller than the background. Only used when
    // ENABLE_PIP=1; defaults match the pipeline's own output size with a
    // zero offset (full-frame overlay, no inset) for backward compatibility.
    parameter [31:0] PIP_BG_WIDTH   = 32'd0,  // 0 = default to pipeline output size
    parameter [31:0] PIP_BG_HEIGHT  = 32'd0,  // 0 = default to pipeline output size
    parameter [31:0] PIP_H_OFFSET   = 32'd0,
    parameter [31:0] PIP_V_OFFSET   = 32'd0,
    parameter [1:0]  PIP_BG_COLOR   = 2'd2,  // 0=Red, 1=Green, 2=Blue (VPSS R/G/B convention)

    // CRS output mode: 0=420, 2=422, 3=444
    parameter [31:0] CRS_OUTPUT_MODE =                                                                                                                                                                                                                                                        32'd3,

    // CSC mode: 0=passthrough, 1=RGB->YCbCrHD, 2=YCbCrHD->RGB,
    //           3=RGB->YCbCrSD, 4=YCbCrSD->RGB
    parameter [2:0]  CSC_MODE =                                                                                                                                                                                                                  3'd0,
    parameter [31:0] CSC_COLOR_SPACE = 32'd2,
	 
	 
	 parameter [31:0] TPG_MODE = 32'd1,
	 parameter [31:0] TPG_INTERLACED = 32'd0,

    // Number of color planes on the scaler datapath (must match the generated
    // pipeline IP's NUMBER_OF_COLOR_PLANES): 3 for RGB/4:4:4, 2 for 4:2:2/4:2:0.
    parameter [31:0] VID_PLANES = 32'd3
)(
    input  wire        clk,
    input  wire        reset,

    // EMIF reference clock - MUST be 200 MHz (the packaged IP's EMIF is
    // configured EMIF_PHY_REFCLK_FREQ_MHZ=200.0). Only meaningful when
    // ENABLE_FRC=1; tie low otherwise. Feeding it the 100 MHz video clock
    // makes DDR4 calibration never complete.
    input  wire        emif_ref_clk,

    // FRC statistics readback (ENABLE_FRC only). Pulse frc_stats_req once the
    // captured frame is safely out; the FSM then reads the VFB's four field
    // counters over the same control bridge and raises frc_stats_valid.
    // These are how write-rate vs read-rate behaviour is measured: dropped
    // fields prove down-conversion, repeated fields prove up-conversion.
    input  wire        frc_stats_req,
    output reg         frc_stats_valid,
    output reg  [31:0] frc_in_fields,
    output reg  [31:0] frc_dropped_fields,
    output reg  [31:0] frc_out_fields,
    output reg  [31:0] frc_repeated_fields,

    // Output frame period in clock cycles, for the output timing generator
    // below. output_fps = clk_hz / otg_period_cycles. Set 0 to disable
    // throttling (output runs flat out - the pre-existing behaviour).
    // Runtime-settable on purpose: drive from a CSR / JTAG-to-Avalon master /
    // board switches on hardware, or a localparam in simulation.
    input  wire [31:0] otg_period_cycles,

    // FRC WRITE (input) frame rate control - idle cycles inserted after each
    // frame's worth of accepted input beats, backpressuring the source.
    //   input_frame_period = frc_in_period_cycles  (absolute)
    // A runtime INPUT (not a parameter) for the same reason as
    // otg_period_cycles: the testbench measures the natural period first and
    // sets this afterwards, and on hardware it comes from a CSR/JTAG.
    // 0 = no gap = source runs at its natural maximum rate.
    input  wire [31:0] frc_in_period_cycles,

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
    localparam DO_CSC_TOPO = (TOPOLOGY=="FULL"||TOPOLOGY=="CSC_ONLY"||TOPOLOGY=="CRS_CSC") ? 1 : 0;
    // Packaged IP skips CSC entirely (see csc_active in intel_vvp_pipeline2_hw.tcl)
    // whenever CRS precedes it (FULL/CRS_CSC) and this build's VID_PLANES is 2 -
    // CSC's ports are hardwired to 3 planes, so a genuine 2-plane build can't
    // carry it in the chain. Must mirror that condition here or this FSM would
    // try to configure a CSC register block that was never generated.
    localparam DO_CSC  = DO_CSC_TOPO && (!DO_CRS || VID_PLANES == 32'd3);
    // For the same genuine-2-plane build (VID_PLANES==2), the packaged IP's
    // CRS is generated with its output support narrowed to a single fixed
    // format (4:2:2 only) - CRS's own core then automatically disables its
    // runtime-control interface (nothing to select at runtime with only one
    // possible output), so this FSM must skip writing any CRS registers at
    // all in that case, or it would stall waiting on a bridge_wait/readdata
    // response from a control interface that no longer exists.
    localparam DO_CRS_MM = DO_CRS && (VID_PLANES == 32'd3);
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

    // --- PIP: Mixer base = 0x1000 (13-bit byte address, only reachable once
    // bridge_addr is widened - see below). Word offsets from Intel's
    // intel_vvp_mixer_regs.h (RT_BASE=0x50), byte = word*4.
    // No global mixer "GO": output flows once layer 1 (pipeline video) is
    // ENABLEd. LITE_MODE must be read at runtime - the register-file RTL is
    // IP-Protect encrypted so it can't be confirmed statically.
    localparam [12:0] MIX_BASE       = 13'h1000;
    localparam [12:0] MIX_LITE_MODE  = MIX_BASE | 13'h008;  // 0x1008 RO
    localparam [12:0] MIX_STATUS     = MIX_BASE | 13'h140;  // 0x1140 RO, bit1=pending commit
    localparam [12:0] MIX_COMMIT     = MIX_BASE | 13'h144;  // 0x1144 WO, full mode only
    localparam [12:0] MIX_L1_MODE    = MIX_BASE | 13'h148;  // 0x1148 bit0=ENABLE
    localparam [12:0] MIX_L1_BLEND   = MIX_BASE | 13'h14C;  // 0x114C
    localparam [12:0] MIX_L1_ALPHA   = MIX_BASE | 13'h150;  // 0x1150
    localparam [12:0] MIX_L1_H_OFF   = MIX_BASE | 13'h154;  // 0x1154
    localparam [12:0] MIX_L1_V_OFF   = MIX_BASE | 13'h158;  // 0x1158

    // --- PIP: Lite->Full protocol converter base = 0x0C00. Inserted by the
    // packager whenever the main chain's last stage outputs Lite protocol
    // (true for FULL/SCALER_ONLY/CLIP_SCL, whose last stage is the scaler)
    // and PIP/FRC is enabled - the mixer only accepts Full protocol. It has
    // no width/height setter (derives geometry from the incoming stream);
    // it only needs its GO bit set to start passing data through.
    localparam [12:0] LTFCONV_BASE      = 13'h0C00;
    localparam [12:0] LTFCONV_IMG_WIDTH = LTFCONV_BASE | 13'h120;  // 0x0D20 expected width  (Lite input, RW)
    localparam [12:0] LTFCONV_IMG_HEIGHT= LTFCONV_BASE | 13'h124;  // 0x0D24 expected height (Lite input, RW)
    localparam [12:0] LTFCONV_STATUS    = LTFCONV_BASE | 13'h140;  // 0x0D40 bit0=RUNNING (diagnostic)
    localparam [12:0] LTFCONV_VIP_WIDTH = LTFCONV_BASE | 13'h148;  // 0x0D48 (diagnostic readback)
    localparam [12:0] LTFCONV_CTRL      = LTFCONV_BASE | 13'h154;  // 0x0D54 bit0=GO

    // FRC path additionally programs the rest of the IMG_INFO block before GO.
    // The Lite->Full converter re-inserts the image-info metapacket the VFB
    // needs downstream, so these fields are what the frame buffer (and
    // everything after it) sees as the stream's declared geometry/format.
    // Offsets are IMG_INFO base word 0x48 (=byte 0x120), byte = word*4:
    // width 0x48, height 0x49, interlace 0x4A, colorspace 0x4C, subsampling 0x4D.
    localparam [12:0] LTFCONV_IMG_INTL  = LTFCONV_BASE | 13'h128;  // 0x0D28 interlace
    localparam [12:0] LTFCONV_IMG_BPS   = LTFCONV_BASE | 13'h12C;  // 0x0D2C bits per sample
    localparam [12:0] LTFCONV_IMG_CS    = LTFCONV_BASE | 13'h130;  // 0x0D30 colorspace
    localparam [12:0] LTFCONV_IMG_SS    = LTFCONV_BASE | 13'h134;  // 0x0D34 subsampling
    localparam [12:0] LTFCONV_IMG_COS   = LTFCONV_BASE | 13'h138;  // 0x0D38 cositing

    // The IMG_INFO block is EIGHT registers (intel_vvp_core_regs.h,
    // INTEL_VVP_CORE_IMG_INFO_BASE_REG = word 72 = 0x48):
    //   +0 WIDTH  +1 HEIGHT  +2 INTERLACE  +3 BPS
    //   +4 COLORSPACE  +5 SUBSAMPLING  +6 COSITING  +7 FIELD_COUNT (RO)
    // All but FIELD_COUNT must be written on a Lite->Full converter, because it
    // SYNTHESIZES the image-info metapacket from these registers - and the frame
    // buffer downstream has NO geometry registers of its own (its only writable
    // register is OUTPUT_CONTROL.GO), so it derives bytes-per-line and field
    // size entirely from that metapacket. Leaving BPS unwritten therefore makes
    // the VFB compute a wrong field size: the field never completes,
    // NUM_INPUT_FIELDS stays 0, and the memory bursts it does issue are the
    // wrong shape.
    localparam [31:0] LTF_BPS      = 32'd8;  // packaged IP datapath is 8 bits/sample
    localparam [31:0] LTF_COSITING = 32'd0;  // irrelevant for 4:4:4; 0 = defined default

    // Colorspace enum (CSC regs): 0=RGB, 1=YCC, 2=YCC_SD, 3=YCC_HD.
    // Subsampling enum (CRS regs): 0=4:2:0, 2=4:2:2, 3=4:4:4 - CRS_OUTPUT_MODE
    // already uses exactly this encoding, so it passes straight through.
    localparam [31:0] LTF_COLORSPACE  = ((CSC_MODE == 3'd2) || (CSC_MODE == 3'd4)) ? 32'd0 : 32'd1;
    localparam [31:0] LTF_SUBSAMPLING = DO_CRS ? CRS_OUTPUT_MODE : 32'd3;

    // --- FRC: video frame buffer base = 0x0E00 ---
    // Word offsets from intel_vvp_vfb_regs.h: COMPILE_TIME_BASE=word 2,
    // RT_BASE=word 0x50. byte = word*4. The VFB has NO frame-rate registers -
    // its only writable runtime register is OUTPUT_CONTROL.GO. Write rate and
    // read rate are set by how fast the source supplies and the sink consumes;
    // these counters are how you observe the result.
    localparam [12:0] VFB_BASE          = 13'h0E00;
    localparam [12:0] VFB_MAX_WIDTH     = VFB_BASE | 13'h010;  // 0x0E10 RO compile-time
    localparam [12:0] VFB_MAX_HEIGHT    = VFB_BASE | 13'h014;  // 0x0E14 RO compile-time
    localparam [12:0] VFB_DROP_EN       = VFB_BASE | 13'h018;  // 0x0E18 RO compile-time
    localparam [12:0] VFB_REPEAT_EN     = VFB_BASE | 13'h01C;  // 0x0E1C RO compile-time
    localparam [12:0] VFB_IN_STATUS     = VFB_BASE | 13'h140;  // 0x0F40 RO bit0=RUNNING
    localparam [12:0] VFB_IN_FIELDS     = VFB_BASE | 13'h144;  // 0x0F44 RO write-side count
    localparam [12:0] VFB_DROP_FIELDS   = VFB_BASE | 13'h148;  // 0x0F48 RO dropped (down-convert)
    localparam [12:0] VFB_INVAL_FIELDS  = VFB_BASE | 13'h14C;  // 0x0F4C RO invalid/broken
    localparam [12:0] VFB_OUT_STATUS    = VFB_BASE | 13'h150;  // 0x0F50 RO bit0=RUNNING
    localparam [12:0] VFB_OUT_FIELDS    = VFB_BASE | 13'h154;  // 0x0F54 RO read-side count
    localparam [12:0] VFB_RPT_FIELDS    = VFB_BASE | 13'h158;  // 0x0F58 RO repeated (up-convert)
    localparam [12:0] VFB_OUT_CTRL      = VFB_BASE | 13'h15C;  // 0x0F5C WO bit0=GO

    // --- PIP: background TPG base = 0x1400 (same core/regmap as intel_vvp_tpg_1,
    // reached through the shared bridge instead of its own dedicated port).
    localparam [12:0] PIPTPG_BASE    = 13'h1400;
    localparam [12:0] PIPTPG_WIDTH   = PIPTPG_BASE | 13'h120;  // 0x1520
    localparam [12:0] PIPTPG_HEIGHT  = PIPTPG_BASE | 13'h124;  // 0x1524
    localparam [12:0] PIPTPG_INTL    = PIPTPG_BASE | 13'h128;  // 0x1528
    localparam [12:0] PIPTPG_STATUS  = PIPTPG_BASE | 13'h140;  // 0x1540
    localparam [12:0] PIPTPG_CONTROL = PIPTPG_BASE | 13'h148;  // 0x1548
    localparam [12:0] PIPTPG_COMMIT  = PIPTPG_BASE | 13'h14C;  // 0x154C
    localparam [12:0] PIPTPG_PATTERN = PIPTPG_BASE | 13'h150;  // 0x1550
    localparam [12:0] PIPTPG_C0      = PIPTPG_BASE | 13'h15C;  // 0x155C - Cb
    localparam [12:0] PIPTPG_C1      = PIPTPG_BASE | 13'h160;  // 0x1560 - Y
    localparam [12:0] PIPTPG_C2      = PIPTPG_BASE | 13'h164;  // 0x1564 - Cr
    localparam [12:0] PIPTPG_BAR_SEL = PIPTPG_BASE | 13'h168;  // 0x1568

    // PIP background color, selected by PIP_BG_COLOR (matches AMD/Xilinx
    // VPSS's R/G/B-only convention). This core outputs YCbCr (confirmed by
    // the un-configured default Y=Cb=Cr=0 rendering green) using the same
    // studio-range, 75%-amplitude color-bar values the TPG's own built-in
    // pattern generator uses - extracted directly from its actual output
    // (White/Yellow/Cyan/Green/Magenta/Red/Blue/Black bars) so the
    // background matches the TPG's own red/green/blue exactly, not an
    // independently-computed full-range approximation.
    //
    // When the TPG runs in RGB mode (TPG_MODE==0), its RGB bars go through
    // CSC (RGB->YCbCr SD/BT.601) before reaching the mixer, which lands on
    // slightly different YCbCr values than the native YCbCr generator's own
    // fixed bars (different quantization path) - confirmed by direct capture
    // of the mixer's own output (e.g. native Red = Y65/Cb100/Cr212, but the
    // same nominal red bar sourced via RGB+CSC lands at Y72/Cb104/Cr200).
    // Using the native-calibrated constants for RGB mode produced a visibly
    // different shade than the TPG's own bar, so select per TPG_MODE.
    //
    // A third case: when CSC converts the main video YCbCr->RGB (CSC_MODE 2
    // or 4), the stream reaching the mixer is genuinely RGB, not YCbCr - a
    // fixed-YCbCr-calibrated background would show as a wrong color (e.g.
    // Blue's YCbCr bytes 0x72/0x23/0xd4 read as literal RGB are a violet
    // shade, not blue). This core is a constant-color pattern - its "C0/C1/
    // C2 -> Cb/Y/Cr" labeling is only a convention for the YCbCr case; for
    // this case the same three registers instead hold literal B/G/R bytes
    // directly (matching the {R,G,B} packing convert_rgb() expects), with
    // no YCbCr math applied at all. Values are the BT.709 studio-range RGB
    // equivalents of the TPG's own native Red/Green/Blue bars (confirmed by
    // direct capture: e.g. native Blue Y35/Cb212/Cr114 -> CSC's own output
    // (0,12,200), matched here exactly) so the background is seamless with
    // the post-CSC video regardless of what TPG variant feeds it.
    localparam [0:0]  PIP_BG_IS_RGB_SRC     = (TPG_MODE == 32'd0);
    localparam [0:0]  PIP_BG_IS_YCBCR_TO_RGB = (CSC_MODE == 3'd2) || (CSC_MODE == 3'd4);
    localparam [31:0] PIP_BG_Y  = PIP_BG_IS_YCBCR_TO_RGB ?
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd18  :  // Red   G (YCbCr->RGB)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd161 :  // Green G (YCbCr->RGB)
                                                              32'd12) : // Blue  G (YCbCr->RGB)
                                   PIP_BG_IS_RGB_SRC ?
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd72  :  // Red (RGB+CSC)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd112 :  // Green (RGB+CSC)
                                                              32'd46) : // Blue (RGB+CSC)
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd65  :  // Red (native YUV)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd112 :  // Green (native YUV)
                                                              32'd35);  // Blue (native YUV)
    localparam [31:0] PIP_BG_CB = PIP_BG_IS_YCBCR_TO_RGB ?
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd0   :  // Red   B (YCbCr->RGB)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd0   :  // Green B (YCbCr->RGB)
                                                              32'd200) : // Blue  B (YCbCr->RGB)
                                   PIP_BG_IS_RGB_SRC ?
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd104 :  // Red (RGB+CSC)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd80  :  // Green (RGB+CSC)
                                                              32'd200) : // Blue (RGB+CSC)
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd100 :  // Red (native YUV)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd72  :  // Green (native YUV)
                                                              32'd212); // Blue (native YUV)
    localparam [31:0] PIP_BG_CR = PIP_BG_IS_YCBCR_TO_RGB ?
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd208 :  // Red   R (YCbCr->RGB)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd0   :  // Green R (YCbCr->RGB)
                                                              32'd0) : // Blue  R (YCbCr->RGB)
                                   PIP_BG_IS_RGB_SRC ?
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd200 :  // Red (RGB+CSC)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd68  :  // Green (RGB+CSC)
                                                              32'd116) : // Blue (RGB+CSC)
                                   ((PIP_BG_COLOR == 2'd0) ? 32'd212 :  // Red (native YUV)
                                    (PIP_BG_COLOR == 2'd1) ? 32'd58  :  // Green (native YUV)
                                                              32'd114); // Blue (native YUV)

    // pip_bg_tpg_0's compiled cores (see intel_vvp_pipeline2_hw.tcl): the
    // VID_PLANES==2 build only ever has core 0 (locked to 4:2:2, its only
    // possible format). The VID_PLANES==3 build compiles all three chroma
    // formats as separate cores (0=4:4:4, 1=4:2:2, 2=4:2:0) so the runtime-
    // selected one can always match whatever CRS_OUTPUT_MODE actually is
    // (assumes CSC stays in passthrough - a build with CSC actively
    // converting to RGB needs a dedicated RGB-only build instead).
    localparam [31:0] PIP_BG_CORE_SEL = (VID_PLANES == 32'd2) ? 32'd0 :
                                         (CRS_OUTPUT_MODE == 32'd0) ? 32'd2 :  // 4:2:0 -> core 2
                                         (CRS_OUTPUT_MODE == 32'd2) ? 32'd1 :  // 4:2:2 -> core 1
                                                                       32'd0;  // 4:4:4 -> core 0
    // The background's own Cb/Cr line-role alternation runs one line out of
    // phase relative to the main video's whenever it's genuine 4:2:0
    // (confirmed by direct capture - see PIP_BG_IS_420 usage below), so C0/
    // C2 must be swapped specifically for that core.
    localparam [0:0]  PIP_BG_IS_420 = (VID_PLANES == 32'd3) && (CRS_OUTPUT_MODE == 32'd0);

    // Foreground (layer 1) geometry = the pipeline's own actual output frame
    // size. ltf_conv_0 needs this - not the background size - to find line
    // boundaries in the real incoming Lite stream.
    localparam [31:0] PIP_FG_W = DO_SCL ? SCALER_OUT_W : IMG_WIDTH;
    localparam [31:0] PIP_FG_H = DO_SCL ? SCALER_OUT_H : IMG_HEIGHT;

    // Background layer (layer 0) canvas geometry - independent of the
    // foreground size so the inset can be smaller than the background.
    localparam [31:0] PIP_BG_W = (PIP_BG_WIDTH  != 0) ? PIP_BG_WIDTH  : PIP_FG_W;
    localparam [31:0] PIP_BG_H = (PIP_BG_HEIGHT != 0) ? PIP_BG_HEIGHT : PIP_FG_H;

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
    localparam [5:0]
        ST_IDLE        = 6'd20,
        ST_CONFIG_CLIP = 6'd21,
        ST_CONFIG_SCL  = 6'd22,
        ST_CONFIG_CRS  = 6'd23,
        ST_POLL_CRS    = 6'd24,
        ST_CONFIG_CSC  = 6'd25,
        ST_POLL_CSC    = 6'd26,
        ST_CONFIG_PC1  = 6'd27,
        ST_WORKING     = 6'd28,
        ST_WAIT_CRS    = 6'd29,

		  // TPG (own Avalon port)
        ST_TPG_CTRL_1    = 6'd0,
        ST_TPG_WR_INTL   = 6'd1,
        ST_TPG_WR_W      = 6'd2,
        ST_TPG_WR_H      = 6'd3,
        ST_TPG_WR_PAT_T  = 6'd4,
        ST_TPG_WR_PAT_S  = 6'd5,
        ST_TPG_WR_CMT    = 6'd6,
        ST_TPG_CTRL_2    = 6'd7,
        ST_TPG_POLL_ISS  = 6'd8,
        ST_TPG_POLL_W    = 6'd9,
        ST_TPG_IP_RST    = 6'd10,
        ST_TPG_CTRL_3    = 6'd11,

        // PIP: background TPG config (mirrors ST_TPG_* above, over bridge_*)
        ST_PIPTPG_CTRL_1   = 6'd30,
        ST_PIPTPG_WR_INTL  = 6'd31,
        ST_PIPTPG_WR_W     = 6'd32,
        ST_PIPTPG_WR_H     = 6'd33,
        ST_PIPTPG_WR_PAT_T = 6'd34,
        ST_PIPTPG_WR_PAT_S = 6'd35,
        ST_PIPTPG_WR_C0    = 6'd54,
        ST_PIPTPG_WR_C1    = 6'd55,
        ST_PIPTPG_WR_C2    = 6'd51,
        ST_PIPTPG_WR_CMT   = 6'd36,
        ST_PIPTPG_CTRL_2   = 6'd37,
        ST_PIPTPG_POLL_ISS = 6'd38,
        ST_PIPTPG_POLL_W   = 6'd39,
        ST_PIPTPG_CTRL_3   = 6'd40,
        ST_PIPTPG_GAP      = 6'd52,

        // PIP: Mixer layer-1 (pipeline video) config
        ST_CONFIG_MIXER_LITE   = 6'd41,
        ST_CONFIG_MIXER_HOFF   = 6'd42,
        ST_CONFIG_MIXER_VOFF   = 6'd43,
        ST_CONFIG_MIXER_BLEND  = 6'd44,
        ST_CONFIG_MIXER_MODE   = 6'd45,
        ST_CONFIG_MIXER_COMMIT = 6'd46,
        ST_CONFIG_MIXER_ALPHA  = 6'd53,

        // PIP: start the Lite->Full converter ahead of the mixer (harmless
        // no-op write if this particular topology's chain is already Full
        // and the converter wasn't instantiated - unmapped bridge writes
        // are silently absorbed by the interconnect's default responder).
        // It needs its expected frame WIDTH/HEIGHT (so it can find line
        // boundaries in the incoming Lite stream) before GO.
        ST_CONFIG_LTFCONV_W    = 6'd49,
        ST_CONFIG_LTFCONV_H    = 6'd50,
        ST_CONFIG_LTFCONV      = 6'd48,

        // FRC: rest of the Lite->Full converter's IMG_INFO block (PIP gets by
        // without these; the frame buffer needs a fully-declared stream).
        ST_CONFIG_LTFCONV_INTL = 6'd12,
        ST_CONFIG_LTFCONV_BPS  = 6'd56,
        ST_CONFIG_LTFCONV_CS   = 6'd13,
        ST_CONFIG_LTFCONV_SS   = 6'd14,
        ST_CONFIG_LTFCONV_COS  = 6'd57,

        // FRC: the write->read handshake. The VFB write side auto-runs (no GO)
        // but stalls until DDR4 calibration completes, so poll NUM_INPUT_FIELDS
        // until a whole field has actually landed in memory before releasing
        // the read side. Starting the read side early makes it read a buffer
        // that was never written.
        ST_FRC_WR_WAIT         = 6'd15,
        ST_FRC_GO              = 6'd16,

        // FRC: counter readback (write rate vs read rate evidence).
        ST_FRC_RD_IN           = 6'd17,
        ST_FRC_RD_DROP         = 6'd18,
        ST_FRC_RD_OUT          = 6'd19,
        ST_FRC_RD_RPT          = 6'd47;

    // When ENABLE_PIP=0 (default) this is the constant ST_WORKING - every
    // "topology config done, go live" transition below is then bit-for-bit
    // identical to the pre-PIP behavior.
    // Where every topology-config-done transition lands. PIP and FRC both hang
    // extra bring-up off the end of the main chain; FRC's starts at the same
    // Lite->Full converter PIP uses (it sits right after the scaler either way),
    // then continues into the VFB GO handshake instead of the background TPG.
    localparam [5:0] POST_TOPOLOGY_STATE = ENABLE_PIP ? ST_CONFIG_MIXER_LITE :
                                           ENABLE_FRC ? ST_CONFIG_LTFCONV_W  : ST_WORKING;

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
    reg [5:0]  current_state;
    reg [3:0]  cfg_step;
    reg [15:0] wait_counter;

    reg [6:0]  pc1_addr;
    reg        pc1_write;
    reg [31:0] pc1_wdata;

    // bridge_addr MUST match the generated pipeline's s0_address width exactly.
    // The packaged IP sets ADDRESS_WIDTH = frc_emif_int ? 28 : (do_frc||do_pip ? 13 : 12),
    // so including the internal EMIF forces 28 bits (its AXI4-Lite CSR sits at
    // 0x0800_0000 = bit 27). Driving a narrower reg into the 28-bit port gives
    // vsim-3015 "Port size does not match connection size" and leaves the upper
    // bits at X - the interconnect then decodes garbage and EVERY register write
    // silently goes nowhere. All offsets actually used here are <= 0x1FFF, so the
    // high bits simply drive 0.
    localparam integer S0_AW = ENABLE_FRC ? 28 : 13;

    reg [S0_AW-1:0] bridge_addr;
    reg [31:0] bridge_wdata;
    reg        bridge_write;
    reg        bridge_read;
    reg        mixer_lite_mode;

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
            mixer_lite_mode <= 1'b0;
            frc_stats_valid     <= 1'b0;
            frc_in_fields       <= 32'd0;
            frc_dropped_fields  <= 32'd0;
            frc_out_fields      <= 32'd0;
            frc_repeated_fields <= 32'd0;
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
                    end else if (DO_CRS_MM) begin
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
                        current_state <= POST_TOPOLOGY_STATE;
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
                            if (DO_CRS_MM) begin
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
                                current_state <= POST_TOPOLOGY_STATE;
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
												current_state <= POST_TOPOLOGY_STATE;
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
                            current_state <= POST_TOPOLOGY_STATE;
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
                                current_state <= POST_TOPOLOGY_STATE;
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
                                current_state <= POST_TOPOLOGY_STATE;
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
                            current_state <= POST_TOPOLOGY_STATE;
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
                // PIP: configure the Mixer's layer 1 (pipeline video) FIRST,
                // before any source is started - mirrors the working
                // reference exactly (mixer layers configured + committed,
                // THEN TPGs configured/started). LITE_MODE is read first
                // since it can't be determined statically; only full mode
                // needs COMMIT (fire-and-forget, matching the reference,
                // which never polls STATUS after the mixer commit).
                // --------------------------------------------------------------
                ST_CONFIG_MIXER_LITE: begin
                    if (cfg_step == 4'd0) begin
                        bridge_read <= 1'b1;
                        bridge_addr <= MIX_LITE_MODE;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else begin
                        if (bridge_readdatavalid) begin
                            cfg_step        <= 4'd0;
                            mixer_lite_mode <= bridge_readdata[0];
                            bridge_addr     <= MIX_L1_H_OFF;
                            bridge_wdata    <= PIP_H_OFFSET;
                            current_state   <= ST_CONFIG_MIXER_HOFF;
                        end
                    end
                end

                ST_CONFIG_MIXER_HOFF: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        bridge_addr   <= MIX_L1_V_OFF;
                        bridge_wdata  <= PIP_V_OFFSET;
                        current_state <= ST_CONFIG_MIXER_VOFF;
                    end
                end

                ST_CONFIG_MIXER_VOFF: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        bridge_addr   <= MIX_L1_BLEND;
                        bridge_wdata  <= 32'h1;  // OPAQUE overlay
                        current_state <= ST_CONFIG_MIXER_BLEND;
                    end
                end

                ST_CONFIG_MIXER_BLEND: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        bridge_addr   <= MIX_L1_ALPHA;
                        bridge_wdata  <= 32'd255;  // fully opaque
                        current_state <= ST_CONFIG_MIXER_ALPHA;
                    end
                end

                ST_CONFIG_MIXER_ALPHA: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        bridge_addr   <= MIX_L1_MODE;
                        // Soft-start (bit2=1): per the Mixer UG, hard-start slaves
                        // the mixer's OUTPUT timing to whenever layer 1 happens to
                        // become ready - valid only for a single unstallable source,
                        // and empirically deadlocks for any offset but exact center
                        // since our layer 1 (scaler + protocol converter chain) is
                        // stallable. Soft-start keeps output on the base layer's own
                        // timing and lets layer 1 align at each field boundary -
                        // confirmed via simulation to correctly composite arbitrary
                        // offsets (tested near-center and extreme top-left corner,
                        // both landing pixel-exact with no deadlock) under FULL
                        // topology. Do not revert to hard-start (32'h1).
                        bridge_wdata  <= 32'h5;  // ENABLE | SOFT_START
                        current_state <= ST_CONFIG_MIXER_MODE;
                    end
                end

                ST_CONFIG_MIXER_MODE: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write <= 1'b0;
                        if (mixer_lite_mode) begin
                            current_state <= ST_CONFIG_LTFCONV_W;
                        end else begin
                            bridge_addr   <= MIX_COMMIT;
                            bridge_wdata  <= 32'h1;
                            current_state <= ST_CONFIG_MIXER_COMMIT;
                        end
                    end
                end

                ST_CONFIG_MIXER_COMMIT: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        // Fire-and-forget: matches the working reference's own
                        // ST_MIX_COMMIT exactly - it never polls STATUS after
                        // committing, it just moves straight on to configuring
                        // the sources.
                        current_state <= ST_CONFIG_LTFCONV_W;
                    end
                end

                // --------------------------------------------------------------
                // PIP: start the Lite->Full converter (layer 1 / overlay
                // source), now that the mixer is configured and committed.
                // Its input is Lite protocol (no embedded metapackets), so it
                // must be told the expected frame WIDTH/HEIGHT before GO or it
                // can't find line boundaries in the incoming stream.
                // --------------------------------------------------------------
                ST_CONFIG_LTFCONV_W: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= LTFCONV_IMG_WIDTH;
                    // PIP feeds the mixer's overlay layer (inset geometry); FRC
                    // feeds the frame buffer, whose stream is the scaler output.
                    bridge_wdata <= ENABLE_PIP ? PIP_FG_W : SCALER_OUT_W;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_CONFIG_LTFCONV_H;
                    end
                end

                ST_CONFIG_LTFCONV_H: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= LTFCONV_IMG_HEIGHT;
                    bridge_wdata <= ENABLE_PIP ? PIP_FG_H : SCALER_OUT_H;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        // PIP works with width/height alone; the frame buffer
                        // needs the full IMG_INFO block declared.
                        current_state <= ENABLE_PIP ? ST_CONFIG_LTFCONV
                                                    : ST_CONFIG_LTFCONV_INTL;
                    end
                end

                ST_CONFIG_LTFCONV_INTL: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= LTFCONV_IMG_INTL;
                    bridge_wdata <= 32'd0;  // progressive
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_CONFIG_LTFCONV_BPS;
                    end
                end

                // Bits per sample. Without this the synthesized metapacket
                // declares the reset value, and the frame buffer sizes its
                // fields from that - see the IMG_INFO note above.
                ST_CONFIG_LTFCONV_BPS: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= LTFCONV_IMG_BPS;
                    bridge_wdata <= LTF_BPS;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_CONFIG_LTFCONV_CS;
                    end
                end

                ST_CONFIG_LTFCONV_CS: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= LTFCONV_IMG_CS;
                    bridge_wdata <= LTF_COLORSPACE;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_CONFIG_LTFCONV_SS;
                    end
                end

                ST_CONFIG_LTFCONV_SS: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= LTFCONV_IMG_SS;
                    bridge_wdata <= LTF_SUBSAMPLING;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_CONFIG_LTFCONV_COS;
                    end
                end

                ST_CONFIG_LTFCONV_COS: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= LTFCONV_IMG_COS;
                    bridge_wdata <= LTF_COSITING;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_CONFIG_LTFCONV;
                    end
                end

                ST_CONFIG_LTFCONV: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= LTFCONV_CTRL;
                    bridge_wdata <= 32'h1;  // GO
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ENABLE_PIP ? ST_PIPTPG_CTRL_1
                                                    : ST_FRC_WR_WAIT;
                    end
                end

                // --------------------------------------------------------------
                // FRC write->read handshake.
                //
                // The VFB write side needs no GO - it starts buffering as soon
                // as video arrives - but it cannot actually reach DDR4 until the
                // EMIF finishes calibration (the AXI bridge to the EMIF is held
                // in reset until cal_done, ~119us of sim time). So poll
                // NUM_INPUT_FIELDS until a complete field has genuinely landed
                // in the memory model, and only then release the read side.
                //
                // Video MUST be flowing while we sit here or the counter never
                // moves - see frc_video_phase in ready_to_start below.
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
                            if (bridge_readdata != 32'd0) begin
                                frc_in_fields <= bridge_readdata;
                                current_state <= ST_FRC_GO;
                            end
                            // else: nothing buffered yet, re-poll
                        end
                    end
                end

                ST_FRC_GO: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= VFB_OUT_CTRL;
                    bridge_wdata <= 32'h1;  // GO - start the read side
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_WORKING;
                    end
                end

                // --------------------------------------------------------------
                // FRC counter readback, on request from the testbench once the
                // frame has been captured. This is the measurement that shows
                // what the write rate and read rate actually did:
                //   dropped  > 0  -> input was faster than output (down-convert)
                //   repeated > 0  -> output was faster than input (up-convert)
                //   in == out, both 0 -> rates matched, pure pass-through
                // --------------------------------------------------------------
                ST_FRC_RD_IN: begin
                    if (cfg_step == 4'd0) begin
                        bridge_read <= 1'b1;
                        bridge_addr <= VFB_IN_FIELDS;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else if (bridge_readdatavalid) begin
                        frc_in_fields <= bridge_readdata;
                        cfg_step      <= 4'd0;
                        current_state <= ST_FRC_RD_DROP;
                    end
                end

                ST_FRC_RD_DROP: begin
                    if (cfg_step == 4'd0) begin
                        bridge_read <= 1'b1;
                        bridge_addr <= VFB_DROP_FIELDS;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else if (bridge_readdatavalid) begin
                        frc_dropped_fields <= bridge_readdata;
                        cfg_step           <= 4'd0;
                        current_state      <= ST_FRC_RD_OUT;
                    end
                end

                ST_FRC_RD_OUT: begin
                    if (cfg_step == 4'd0) begin
                        bridge_read <= 1'b1;
                        bridge_addr <= VFB_OUT_FIELDS;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else if (bridge_readdatavalid) begin
                        frc_out_fields <= bridge_readdata;
                        cfg_step       <= 4'd0;
                        current_state  <= ST_FRC_RD_RPT;
                    end
                end

                ST_FRC_RD_RPT: begin
                    if (cfg_step == 4'd0) begin
                        bridge_read <= 1'b1;
                        bridge_addr <= VFB_RPT_FIELDS;
                        if (bridge_read && !bridge_wait) begin
                            bridge_read <= 1'b0;
                            cfg_step    <= 4'd1;
                        end
                    end else if (bridge_readdatavalid) begin
                        frc_repeated_fields <= bridge_readdata;
                        frc_stats_valid     <= 1'b1;
                        cfg_step            <= 4'd0;
                        current_state       <= ST_WORKING;
                    end
                end

                // --------------------------------------------------------------
                // PIP: configure+start the internal background TPG (layer 0 /
                // base), started LAST - mirrors the working reference exactly
                // (base TPG configured/started after all overlays, and after
                // the mixer is already committed). Mirrors the proven
                // ST_TPG_* sequence above, retargeted to bridge_addr/
                // bridge_write/bridge_read (shared-bridge handshake, like
                // CRS/CSC/CLIP/SCL) instead of the dedicated TPG port. The
                // pending-commit poll after CTRL_2 genuinely does clear here
                // (confirmed in the reference) - it does not depend on
                // downstream tready.
                // --------------------------------------------------------------
                ST_PIPTPG_CTRL_1: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_CONTROL;
                    bridge_wdata <= 32'h0;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_INTL;
                    end
                end

                ST_PIPTPG_WR_INTL: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_INTL;
                    bridge_wdata <= 32'h0;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_W;
                    end
                end

                ST_PIPTPG_WR_W: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_WIDTH;
                    bridge_wdata <= PIP_BG_W;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_H;
                    end
                end

                ST_PIPTPG_WR_H: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_HEIGHT;
                    bridge_wdata <= PIP_BG_H;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_PAT_T;
                    end
                end

                ST_PIPTPG_WR_PAT_T: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_BAR_SEL;
                    bridge_wdata <= 32'h0;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_PAT_S;
                    end
                end

                ST_PIPTPG_WR_PAT_S: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_PATTERN;
                    // pip_bg_tpg_0's cores (see intel_vvp_pipeline2_hw.tcl):
                    // VID_PLANES==2 build has only core 0 (4:2:2-only, matches
                    // that build's sole possible format). VID_PLANES==3 build
                    // has 3 cores (0=4:4:4, 1=4:2:2, 2=4:2:0) - select the one
                    // matching CRS's actual runtime OUTPUT_MODE so the PIP
                    // background always matches the foreground's real format.
                    bridge_wdata <= PIP_BG_CORE_SEL;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_C0;
                    end
                end

                // Fixed background color (blue, matching AMD/Xilinx VPSS's
                // R/G/B-only PIP convention). Core outputs YCbCr: C0=Cb, C1=Y, C2=Cr -
                // except when PIP_BG_IS_420, where C0/C2 are swapped (see param doc).
                ST_PIPTPG_WR_C0: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_C0;
                    bridge_wdata <= PIP_BG_IS_420 ? PIP_BG_CR : PIP_BG_CB;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_C1;
                    end
                end

                ST_PIPTPG_WR_C1: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_C1;
                    bridge_wdata <= PIP_BG_Y;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_C2;
                    end
                end

                ST_PIPTPG_WR_C2: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_C2;
                    bridge_wdata <= PIP_BG_IS_420 ? PIP_BG_CB : PIP_BG_CR;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_WR_CMT;
                    end
                end

                ST_PIPTPG_WR_CMT: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_COMMIT;
                    bridge_wdata <= 32'h1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_CTRL_2;
                    end
                end

                ST_PIPTPG_CTRL_2: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_CONTROL;
                    bridge_wdata <= 32'h1;  // GO
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_PIPTPG_POLL_ISS;
                    end
                end

                ST_PIPTPG_POLL_ISS: begin
                    bridge_read <= 1'b1;
                    bridge_addr <= PIPTPG_STATUS;
                    if (bridge_read && !bridge_wait) begin
                        bridge_read   <= 1'b0;
                        current_state <= ST_PIPTPG_POLL_W;
                    end
                end

                ST_PIPTPG_POLL_W: begin
                    if (bridge_readdatavalid) begin
                        if (bridge_readdata[1] == 1'b0) begin
                            wait_counter  <= 16'd0;
                            current_state <= ST_PIPTPG_GAP;
                        end else begin
                            current_state <= ST_PIPTPG_POLL_ISS;
                        end
                    end
                end

                ST_PIPTPG_GAP: begin
                    wait_counter <= wait_counter + 1'b1;
                    if (wait_counter == 16'h7)
                        current_state <= ST_PIPTPG_CTRL_3;
                end

                ST_PIPTPG_CTRL_3: begin
                    bridge_write <= 1'b1;
                    bridge_addr  <= PIPTPG_CONTROL;
                    bridge_wdata <= 32'h1;
                    if (bridge_write && !bridge_wait) begin
                        bridge_write  <= 1'b0;
                        current_state <= ST_WORKING;
                    end
                end

                ST_WORKING: begin
                    pc1_write    <= 1'b0;
                    bridge_write <= 1'b0;
                    bridge_read  <= 1'b0;
                    // FRC counter readback, RE-ARMABLE so a measurement WINDOW
                    // can be taken: pulse frc_stats_req, read the snapshot, drop
                    // the request, run N frames, pulse again. Deltas between the
                    // two snapshots are what actually prove conversion - absolute
                    // counts are polluted by startup, because the write side
                    // auto-runs through DDR4 calibration while the read side
                    // waits for GO, so the writer legitimately gets ~2 frames
                    // ahead and the triple buffer sheds one.
                    // Video keeps flowing throughout (frc_video_phase covers the
                    // ST_FRC_RD_* states), so counters are sampled live.
                    if (ENABLE_FRC && frc_stats_req && !frc_stats_valid)
                        current_state <= ST_FRC_RD_IN;
                    else if (!frc_stats_req)
                        frc_stats_valid <= 1'b0;   // re-arm for the next window
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
    // FRC: the VFB write side must be fed BEFORE the read side can be released,
    // so video has to flow during the Lite->Full config states and the whole
    // ST_FRC_WR_WAIT poll - not just at ST_WORKING. Gating on ST_WORKING alone
    // deadlocks: NUM_INPUT_FIELDS stays 0 forever and the poll never exits.
    // Also held through the ST_FRC_RD_* readback so the counters are sampled on
    // a live stream. This override applies to EVERY branch below - an earlier
    // version only patched the scaler/image branches and FULL topology (which
    // takes gen_rts_csc) silently stayed gated.
    wire frc_video_phase = (current_state == ST_CONFIG_LTFCONV_W)    ||
                           (current_state == ST_CONFIG_LTFCONV_H)    ||
                           (current_state == ST_CONFIG_LTFCONV_INTL) ||
                           (current_state == ST_CONFIG_LTFCONV_BPS)  ||
                           (current_state == ST_CONFIG_LTFCONV_CS)   ||
                           (current_state == ST_CONFIG_LTFCONV_SS)   ||
                           (current_state == ST_CONFIG_LTFCONV_COS)  ||
                           (current_state == ST_CONFIG_LTFCONV)      ||
                           (current_state == ST_FRC_WR_WAIT)         ||
                           (current_state == ST_FRC_GO)              ||
                           (current_state == ST_FRC_RD_IN)           ||
                           (current_state == ST_FRC_RD_DROP)         ||
                           (current_state == ST_FRC_RD_OUT)          ||
                           (current_state == ST_FRC_RD_RPT)          ||
                           (current_state == ST_WORKING);

    wire ready_to_start_raw;
    generate
        if (DO_PC1) begin : gen_rts_image
            // Image: only start when fully configured
            assign ready_to_start_raw = ENABLE_FRC ? frc_video_phase
                                               : (current_state == ST_WORKING);
        end else if (DO_CSC) begin : gen_rts_csc
            // Combined CRS+CSC: both committed with no live data; start at WORKING.
            // CSC_ONLY: start at ST_CONFIG_CSC (first frame absorbs commit).
            // With PIP enabled the numeric ">=" would also match the PIP config
            // states (encoded above ST_CONFIG_CSC), so always require the exact
            // ST_WORKING match once PIP is in the picture.
            assign ready_to_start_raw = ENABLE_FRC ? frc_video_phase :
                                    (ENABLE_PIP || DO_CRS) ? (current_state == ST_WORKING) : (current_state >= ST_CONFIG_CSC);
        end else if (DO_SCL) begin : gen_rts_scl
            assign ready_to_start_raw = ENABLE_FRC ? frc_video_phase
                                               : (current_state == ST_WORKING);
        end else if (DO_CRS) begin : gen_rts_crs
            // CRS_ONLY: wait for full settling (ST_WAIT_CRS counts 32k cycles).
            assign ready_to_start_raw = ENABLE_FRC ? frc_video_phase
                                               : (current_state == ST_WORKING);
        end else begin : gen_rts_default
            assign ready_to_start_raw = ENABLE_FRC ? frc_video_phase
                                               : (current_state == ST_WORKING);
        end
    endgenerate

    // -------------------------------------------------------------------------

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

    // FRC write-rate pacing - PERIOD based, symmetric with the output timing
    // generator.
    //
    // This replaces an earlier ADDITIVE design (natural_period + gap) that was
    // measurably wrong: the natural frame period is not constant. Throttling the
    // output reduces DDR4 contention on the write side, so the natural period
    // shrinks, and a fixed additive gap then lands at the wrong absolute period.
    // Measured: a requested 2.000 ratio came out as 2.250 because nat fell from
    // 545 to ~454 cycles once the output was throttled.
    //
    // An absolute period is immune to that - one input frame per
    // frc_in_period_cycles regardless of what the pipeline's natural rate does.
    // Same SOF-delimited structure as the OTG: open at the period boundary, shut
    // when a SECOND SOF appears (that frame belongs to the next period).
    // 0 = no throttling, source runs at its natural maximum rate.
    // -------------------------------------------------------------------------
    // raw (pre-gate) source handshake, so the gate cannot feed back on itself
    wire        src_tvalid_raw = INPUT_SEL ? pc1_tvalid : tpg_tvalid;
    wire [2:0]  src_tuser_raw  = INPUT_SEL ? pc1_tuser  :
                                 (TPG_MODE == 32'd2) ? {1'b0, tpg_tuser[1:0]} : tpg_tuser;

    reg  [31:0] frc_in_phase;
    reg         frc_in_sof_seen;
    wire        frc_in_enabled = ENABLE_FRC && (frc_in_period_cycles != 32'd0);
    wire        frc_in_is_sof  = src_tvalid_raw && src_tuser_raw[0];
    wire        frc_in_hold    = frc_in_sof_seen && frc_in_is_sof;
    wire        frc_in_allow   = !frc_in_enabled || !frc_in_hold;

    wire ready_to_start = ready_to_start_raw && frc_in_allow;

    // Width-generalized video mux. TPG and PC1 sources are always 24-bit; for
    // 2-plane formats (4:2:2 / 4:2:0) the meaningful samples occupy the low 16
    // bits, so a single low-slice to VID_BITS handles every format with no
    // per-format special case (this also fixes 4:2:0, which the old ch hack
    // only handled for 4:2:2).
    wire [23:0] vid_in_tdata  = INPUT_SEL  ? pc1_tdata  : (TPG_MODE == 32'd2) ? {8'b0,tpg_tdata[15:0]} : tpg_tdata;
    wire        vid_in_tvalid = (INPUT_SEL ? pc1_tvalid : tpg_tvalid) & ready_to_start;
    wire        vid_in_tlast  = INPUT_SEL  ? pc1_tlast  : tpg_tlast;
    wire [2:0]  vid_in_tuser  = INPUT_SEL  ? pc1_tuser  : (TPG_MODE == 32'd2) ? {1'b0,tpg_tuser[1:0]} : tpg_tuser;

    // FRC input pacer state update (samples the gated input handshake).
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            frc_in_phase    <= 32'd0;
            frc_in_sof_seen <= 1'b0;
        end else if (frc_in_enabled) begin
            if (frc_in_phase >= (frc_in_period_cycles - 32'd1)) begin
                frc_in_phase    <= 32'd0;
                frc_in_sof_seen <= 1'b0;      // new period: release the next frame
            end else begin
                frc_in_phase <= frc_in_phase + 32'd1;
                if (vid_in_tvalid && vid_in_tready && vid_in_tuser[0])
                    frc_in_sof_seen <= 1'b1;
            end
        end else begin
            frc_in_phase    <= 32'd0;
            frc_in_sof_seen <= 1'b0;
        end
    end


    // Output datapath width mirrors the input-side narrowing above: for a
    // 2-plane build (VID_PLANES==2) the packaged pipeline's actual
    // m_axis_video_out ports are genuinely 16-bit/2-bit (not 24-bit/3-bit),
    // since NUMBER_OF_COLOR_PLANES now really is 2 all the way to the
    // exported interface. Connecting that narrower real output straight to
    // the fixed 24-bit/3-bit out_tdata/out_tuser ports leaves their upper
    // bits permanently undriven (X) - previously harmless because the build
    // was always genuinely 3-plane, so the widths already matched. Widen
    // explicitly here instead of relying on the simulator's port-size-
    // mismatch handling.
    localparam OUT_TDATA_BITS = (VID_PLANES == 32'd2) ? 16 : 24;
    localparam OUT_TUSER_BITS = (VID_PLANES == 32'd2) ? 2  : 3;
    wire [OUT_TDATA_BITS-1:0] pl_out_tdata;
    wire [OUT_TUSER_BITS-1:0] pl_out_tuser;
    assign out_tdata = {{(24-OUT_TDATA_BITS){1'b0}}, pl_out_tdata};
    assign out_tuser = {{(3-OUT_TUSER_BITS){1'b0}},  pl_out_tuser};
    wire pl_out_tvalid;
    wire pl_out_tlast;
    wire pl_out_tready;

    // =========================================================================
    // OUTPUT TIMING GENERATOR (OTG)  -  sets the frame buffer's READ frame rate
    //
    // This is the synthesizable replacement for the testbench's old
    // FRC_OUT_GAP_CYCLES gating of out_tready. It lives in the DESIGN so that
    // simulation and hardware exercise the same logic.
    //
    // Why it is needed at all: the frame buffer has no rate registers, so its
    // read rate is purely "how fast the sink drains m_axis_video_out". With
    // nothing throttling that, the read side runs flat out, read rate always
    // exceeds write rate, and you can only ever observe REPEAT (up-conversion) -
    // controlled DOWN-conversion is impossible. This block is what makes the
    // output rate settable, and therefore what makes down-conversion testable
    // on real hardware and not just in a testbench.
    //
    // Model: a free-running frame-period counter plus a per-period beat budget.
    //   - phase counts 0..otg_period_cycles-1 and wraps  => one frame period
    //   - at most OTG_FRAME_BEATS output beats are let through per period
    //   - the gate is then shut for the remainder of the period (blanking)
    // So:  output_fps = clk_hz / otg_period_cycles
    //
    // otg_period_cycles is an INPUT, not a parameter, so the rate is settable at
    // run time: drive it from a CSR / JTAG-to-Avalon master / switches on
    // hardware, or straight from a testbench localparam in simulation. A value
    // of 0 (or anything <= OTG_FRAME_BEATS) disables throttling and the output
    // runs at maximum rate, which is the pre-existing behaviour.
    //
    // The gate blocks tvalid and tready TOGETHER, which is the only safe way to
    // throttle an AXI4-Stream link - no beat is ever lost or duplicated.
    // =========================================================================
    // One frame per period, delimited by Start-Of-Frame (tuser[0]).
    //
    // A plain beat budget would be wrong: the payload is SCALER_OUT_W*H beats
    // but the Full protocol adds a variable-length image-info metapacket, so any
    // fixed budget either truncates a frame or spills into the next one, leaving
    // frames straddling period boundaries and stalling mid-frame. Counting SOFs
    // instead is exact and needs no knowledge of the metapacket length: let beats
    // through from the start of the period, and shut the gate the moment a SECOND
    // SOF appears - that is the next frame arriving, and it belongs to the next
    // period. This mirrors how a display consumes exactly one frame per vertical
    // period, with the remainder of the period being blanking.
    //
    // A frame shorter than the period therefore completes and then waits; a
    // period shorter than a frame means the gate never shuts and the output runs
    // at full rate (which is what otg_enabled already guards against).
    localparam [31:0] OTG_FRAME_BEATS = SCALER_OUT_W * SCALER_OUT_H;

    reg  [31:0] otg_phase;
    reg         otg_sof_seen;     // a frame has started in this period
    wire        otg_enabled  = (otg_period_cycles > OTG_FRAME_BEATS);

    // SOF currently being offered by the pipeline
    wire        otg_is_sof   = pl_out_tvalid && pl_out_tuser[0];
    // second SOF of the period => start of the NEXT frame => hold it back
    wire        otg_hold     = otg_sof_seen && otg_is_sof;
    wire        otg_allow    = !otg_enabled || !otg_hold;
    wire        otg_accepted = out_tvalid && out_tready;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            otg_phase    <= 32'd0;
            otg_sof_seen <= 1'b0;
        end else if (otg_enabled) begin
            if (otg_phase >= (otg_period_cycles - 32'd1)) begin
                otg_phase    <= 32'd0;
                otg_sof_seen <= 1'b0;   // new period: release the next frame
            end else begin
                otg_phase <= otg_phase + 32'd1;
                // latch that this period's frame has begun
                if (otg_accepted && pl_out_tuser[0])
                    otg_sof_seen <= 1'b1;
            end
        end else begin
            otg_phase    <= 32'd0;
            otg_sof_seen <= 1'b0;
        end
    end

    // Pipeline-side output handshake, gated by the OTG. Blocking tvalid and
    // tready together is the only safe way to throttle an AXI4-Stream link.
    assign out_tvalid    = pl_out_tvalid & otg_allow;
    assign out_tlast     = pl_out_tlast;
    assign pl_out_tready = out_tready    & otg_allow;

    assign tpg_tready = INPUT_SEL ? 1'b1 : (vid_in_tready & ready_to_start);
    assign pc1_tready = INPUT_SEL ? (vid_in_tready & ready_to_start) : 1'b1;

    // =========================================================================
    // Platform Designer instantiation
    // =========================================================================
    pipeline u0 (
        .clk_clk                           (clk),
        .reset_reset                       (reset),
        .intel_vvp_pipeline2_0_reset_reset (reset),

        // 200 MHz EMIF reference clock. Exported to the boundary by
        // pipeline.qsys (interface "emif_ref_clk" -> intel_vvp_pipeline2_0
        // .frc_emif_ref_clk); the DDR4 memory model does NOT supply it.
        .emif_ref_clk_clk                  (emif_ref_clk),

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

        .m_axis_video_out_tdata  (pl_out_tdata),
        .m_axis_video_out_tvalid (pl_out_tvalid),
        .m_axis_video_out_tready (pl_out_tready),
        .m_axis_video_out_tlast  (pl_out_tlast),
        .m_axis_video_out_tuser  (pl_out_tuser),

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
