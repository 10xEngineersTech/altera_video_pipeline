`timescale 1 ps / 1 ps

// =============================================================================
// top.v ? Universal Daddy Controller (Packaged IP)
//
// Supports all TOPOLOGY modes: FULL, SCALER_ONLY, CSC_ONLY, CRS_CSC,
//                               CLIP_SCL, DIL_ONLY
// Supports both input sources:  INPUT_SEL=0 (TPG), INPUT_SEL=1 (image/PC1)
//
// Platform Designer (pipeline.qsys) contains:
//   - intel_vvp_tpg_0              (TPG, no MM control ? fixed resolution)
//   - intel_vvp_protocol_conv_0    (PC1: Lite?Full, MM control exported)
//   - intel_vvp_pipeline2_0        (packaged IP, all modes)
//
// Port mapping:
//   axi4s_vid_out_*   = TPG output
//   axi4s_vid_out_1_* = PC1 output
//   axi4s_vid_in_*    = PC1 image input (from tb)
//   av_mm_control_agent_* = PC1 MM control
//   s_axis_video_in_* = pipeline2_0 input (muxed from TPG or PC1)
//   m_axis_video_out_* = pipeline2_0 output
//   s0_*              = MM bridge slave
//
// MM bridge address map (packaged IP, 12-bit byte addressed):
//   DIL  ? 0x0000  CRS  ? 0x0200  CSC  ? 0x0400
//   CLIP ? 0x0600  SCL  ? 0x0800
//
// FSM config order per topology:
//   FULL:        CLIP?SCL?CRS?CSC?[PC1]?WORKING
//   SCALER_ONLY: SCL?[PC1]?WORKING
//   CSC_ONLY:    CSC?[PC1]?WORKING
//   CRS_CSC:     CRS?CSC?[PC1]?WORKING
//   CLIP_SCL:    CLIP?SCL?[PC1]?WORKING
//   DIL_ONLY:    [PC1]?WORKING
// =============================================================================

module top #(
    parameter        TOPOLOGY      = "SCALER_ONLY",
    parameter [0:0]  INPUT_SEL     = 1'b0,

    parameter [31:0] IMG_WIDTH     = 32'd640,
    parameter [31:0] IMG_HEIGHT    = 32'd480,
    parameter [31:0] IMG_COLOR     = 32'd0,
    parameter [31:0] IMG_CR_SM     = 32'd3,
    parameter [31:0] IMG_L_OFF     = 32'd0,
    parameter [31:0] IMG_T_OFF     = 32'd0,
    parameter [31:0] IMG_R_OFF     = 32'd0,
    parameter [31:0] IMG_B_OFF     = 32'd0,

    parameter [31:0] SCALER_OUT_W  = 32'd640,
    parameter [31:0] SCALER_OUT_H  = 32'd480,

    parameter [31:0] CRS_OUTPUT_MODE = 32'd3,

    parameter [2:0]  CSC_MODE      = 3'd0,
    parameter [31:0] CSC_COLOR_SPACE = 32'd0
)(
    input  wire        clk,
    input  wire        reset,

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
    localparam DO_CLIP = (TOPOLOGY=="FULL"||TOPOLOGY=="CLIP_SCL") ? 1 : 0;
    localparam DO_SCL  = (TOPOLOGY=="FULL"||TOPOLOGY=="SCALER_ONLY"||TOPOLOGY=="CLIP_SCL") ? 1 : 0;
    localparam DO_CRS  = (TOPOLOGY=="FULL"||TOPOLOGY=="CRS_CSC") ? 1 : 0;
    localparam DO_CSC  = (TOPOLOGY=="FULL"||TOPOLOGY=="CSC_ONLY"||TOPOLOGY=="CRS_CSC") ? 1 : 0;
    localparam DO_PC1  = (INPUT_SEL==1'b1) ? 1 : 0;

    // =========================================================================
    // Derived constants
    // =========================================================================
    localparam [31:0] CLIP_OUT_W  = IMG_WIDTH  - IMG_L_OFF - IMG_R_OFF;
    localparam [31:0] CLIP_OUT_H  = IMG_HEIGHT - IMG_T_OFF - IMG_B_OFF;
    localparam [31:0] SCALER_IN_W = DO_CLIP ? CLIP_OUT_W : IMG_WIDTH;
    localparam [31:0] SCALER_IN_H = DO_CLIP ? CLIP_OUT_H : IMG_HEIGHT;

    // =========================================================================
    // MM bridge addresses (12-bit byte addressed)
    // =========================================================================
    localparam [11:0] CRS_BASE  = 12'h200;
    localparam [11:0] CSC_BASE  = 12'h400;
    localparam [11:0] CLIP_BASE = 12'h600;
    localparam [11:0] SCL_BASE  = 12'h800;

    // Clipper (Full protocol ? clipping spec registers only)
    localparam [11:0] CLIP_COMMIT = CLIP_BASE | 12'h144;
    localparam [11:0] CLIP_LEFT   = CLIP_BASE | 12'h148;
    localparam [11:0] CLIP_TOP    = CLIP_BASE | 12'h14C;
    localparam [11:0] CLIP_WIDTH  = CLIP_BASE | 12'h150;
    localparam [11:0] CLIP_HEIGHT = CLIP_BASE | 12'h154;

    // Scaler
    localparam [11:0] SCL_IN_WIDTH   = SCL_BASE | 12'h120;
    localparam [11:0] SCL_IN_HEIGHT  = SCL_BASE | 12'h124;
    localparam [11:0] SCL_OUT_WIDTH  = SCL_BASE | 12'h148;
    localparam [11:0] SCL_OUT_HEIGHT = SCL_BASE | 12'h14C;

    // CRS
    localparam [11:0] CRS_OUT_MODE = CRS_BASE | 12'h148;
    localparam [11:0] CRS_COMMIT   = CRS_BASE | 12'h144;

    // CSC
    localparam [11:0] CSC_STATUS     = CSC_BASE | 12'h140;
    localparam [11:0] CSC_COMMIT     = CSC_BASE | 12'h144;
    localparam [11:0] CSC_COEFF_A0   = CSC_BASE | 12'h148;
    localparam [11:0] CSC_COEFF_A1   = CSC_BASE | 12'h14C;
    localparam [11:0] CSC_COEFF_A2   = CSC_BASE | 12'h150;
    localparam [11:0] CSC_COEFF_B0   = CSC_BASE | 12'h154;
    localparam [11:0] CSC_COEFF_B1   = CSC_BASE | 12'h158;
    localparam [11:0] CSC_COEFF_B2   = CSC_BASE | 12'h15C;
    localparam [11:0] CSC_COEFF_C0   = CSC_BASE | 12'h160;
    localparam [11:0] CSC_COEFF_C1   = CSC_BASE | 12'h164;
    localparam [11:0] CSC_COEFF_C2   = CSC_BASE | 12'h168;
    localparam [11:0] CSC_SUMMAND_S0 = CSC_BASE | 12'h16C;
    localparam [11:0] CSC_SUMMAND_S1 = CSC_BASE | 12'h170;
    localparam [11:0] CSC_SUMMAND_S2 = CSC_BASE | 12'h174;
    localparam [11:0] CSC_OUT_CS     = CSC_BASE | 12'h178;

    // PC1 registers (7-bit word addressed)
    localparam [6:0] PC1_ADDR_WIDTH       = 7'h48;
    localparam [6:0] PC1_ADDR_HEIGHT      = 7'h49;
    localparam [6:0] PC1_ADDR_INTERLACE   = 7'h4A;
    localparam [6:0] PC1_ADDR_COLORSPACE  = 7'h4C;
    localparam [6:0] PC1_ADDR_SUBSAMPLING = 7'h4D;
    localparam [6:0] PC1_ADDR_CTRL        = 7'h55;

    // =========================================================================
    // State encoding
    // =========================================================================
    localparam [4:0]
        ST_IDLE        = 5'd0,
        ST_CONFIG_CLIP = 5'd1,
        ST_CONFIG_SCL  = 5'd2,
        ST_CONFIG_CRS  = 5'd3,
        ST_CONFIG_CSC  = 5'd4,
        ST_POLL_CSC    = 5'd5,
        ST_CONFIG_PC1  = 5'd6,
        ST_WORKING     = 5'd7;

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
    wire        [31:0] csc_out_cs=((CSC_MODE==3'd1)||(CSC_MODE==3'd3))?32'd1:(CSC_MODE==3'd0)?CSC_COLOR_SPACE:32'd0;

    // =========================================================================
    // Registers
    // =========================================================================
    reg [4:0]  current_state;
    reg [3:0]  cfg_step;

    reg [6:0]  pc1_addr;  reg pc1_write;  reg [31:0] pc1_wdata;
    reg [11:0] bridge_addr;
    reg [31:0] bridge_wdata;
    reg        bridge_write, bridge_read;

    wire        pc1_wait;
    wire [31:0] pc1_readdata;
    wire        pc1_readdatavalid;
    wire [31:0] bridge_readdata;
    wire        bridge_readdatavalid;
    wire        bridge_wait;

    // =========================================================================
    // FSM task: transition to next active config state
    // =========================================================================
    // After CLIP ? SCL ? CRS ? CSC ? PC1 ? WORKING
    // Each state skips to the next active one

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            pc1_write    <= 1'b0;
            bridge_write <= 1'b0;
            bridge_read  <= 1'b0;
            cfg_step     <= 4'd0;
        end else begin
            case (current_state)

                // ?? IDLE: jump to first needed config state ???????????????????
                ST_IDLE: begin
                    cfg_step <= 4'd0;
                    if (DO_CLIP) begin
                        bridge_addr  <= CLIP_LEFT;
                        bridge_wdata <= IMG_L_OFF;
                        current_state <= ST_CONFIG_CLIP;
                    end else if (DO_SCL) begin
                        bridge_addr  <= SCL_IN_WIDTH;
                        bridge_wdata <= SCALER_IN_W;
                        current_state <= ST_CONFIG_SCL;
                    end else if (DO_CRS) begin
                        bridge_addr  <= CRS_OUT_MODE;
                        bridge_wdata <= CRS_OUTPUT_MODE;
                        current_state <= ST_CONFIG_CRS;
                    end else if (DO_CSC) begin
                        bridge_addr  <= CSC_COEFF_A0;
                        bridge_wdata <= csc_a0;
                        current_state <= ST_CONFIG_CSC;
                    end else if (DO_PC1) begin
                        pc1_addr  <= PC1_ADDR_WIDTH;
                        pc1_wdata <= IMG_WIDTH;
                        current_state <= ST_CONFIG_PC1;
                    end else begin
                        current_state <= ST_WORKING; // DIL_ONLY TPG
                    end
                end

                // ?? Clipper ???????????????????????????????????????????????????
                // Step 0: LEFT (preloaded)
                // Step 1: TOP
                // Step 2: CLIP_WIDTH
                // Step 3: CLIP_HEIGHT
                // Step 4: COMMIT
                ST_CONFIG_CLIP: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd4) begin
                            bridge_write <= 1'b0;
                            cfg_step     <= 4'd0;
                            bridge_addr  <= SCL_IN_WIDTH;
                            bridge_wdata <= SCALER_IN_W;
                            current_state <= ST_CONFIG_SCL; // CLIP always followed by SCL
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr<=CLIP_TOP;    bridge_wdata<=IMG_T_OFF;  end
                                4'd2: begin bridge_addr<=CLIP_WIDTH;  bridge_wdata<=CLIP_OUT_W; end
                                4'd3: begin bridge_addr<=CLIP_HEIGHT; bridge_wdata<=CLIP_OUT_H; end
                                4'd4: begin bridge_addr<=CLIP_COMMIT; bridge_wdata<=32'h1;      end
                                default:;
                            endcase
                        end
                    end
                end

                // ?? Scaler ???????????????????????????????????????????????????
                // Step 0: IN_WIDTH (preloaded)
                // Step 1: IN_HEIGHT
                // Step 2: OUT_WIDTH
                // Step 3: OUT_HEIGHT
                ST_CONFIG_SCL: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd3) begin
                            bridge_write <= 1'b0;
                            cfg_step     <= 4'd0;
                            if (DO_CRS) begin
                                bridge_addr  <= CRS_OUT_MODE;
                                bridge_wdata <= CRS_OUTPUT_MODE;
                                current_state <= ST_CONFIG_CRS;
                            end else if (DO_CSC) begin
                                bridge_addr  <= CSC_COEFF_A0;
                                bridge_wdata <= csc_a0;
                                current_state <= ST_CONFIG_CSC;
                            end else if (DO_PC1) begin
                                pc1_addr  <= PC1_ADDR_WIDTH;
                                pc1_wdata <= IMG_WIDTH;
                                current_state <= ST_CONFIG_PC1;
                            end else begin
                                current_state <= ST_WORKING;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr<=SCL_IN_HEIGHT;  bridge_wdata<=SCALER_IN_H;  end
                                4'd2: begin bridge_addr<=SCL_OUT_WIDTH;  bridge_wdata<=SCALER_OUT_W; end
                                4'd3: begin bridge_addr<=SCL_OUT_HEIGHT; bridge_wdata<=SCALER_OUT_H; end
                                default:;
                            endcase
                        end
                    end
                end

                // ?? CRS ??????????????????????????????????????????????????????
                // Step 0: OUTPUT_MODE (preloaded)
                // Step 1: COMMIT
                ST_CONFIG_CRS: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd1) begin
                            bridge_write <= 1'b0;
                            cfg_step     <= 4'd0;
                            if (DO_CSC) begin
                                bridge_addr  <= CSC_COEFF_A0;
                                bridge_wdata <= csc_a0;
                                current_state <= ST_CONFIG_CSC;
                            end else if (DO_PC1) begin
                                pc1_addr  <= PC1_ADDR_WIDTH;
                                pc1_wdata <= IMG_WIDTH;
                                current_state <= ST_CONFIG_PC1;
                            end else begin
                                current_state <= ST_WORKING;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr<=CRS_COMMIT; bridge_wdata<=32'h1; end
                                default:;
                            endcase
                        end
                    end
                end

                // ?? CSC ??????????????????????????????????????????????????????
                // Steps 0-12: coefficients + OUT_CS
                // Step 13: COMMIT
                ST_CONFIG_CSC: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd13) begin
                            bridge_write <= 1'b0;
                            cfg_step     <= 4'd0;
                            if (DO_PC1) begin
                                pc1_addr  <= PC1_ADDR_WIDTH;
                                pc1_wdata <= IMG_WIDTH;
                                current_state <= ST_CONFIG_PC1;
                            end else begin
                                current_state <= ST_POLL_CSC;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1:  begin bridge_addr<=CSC_COEFF_A1;   bridge_wdata<=csc_a1;     end
                                4'd2:  begin bridge_addr<=CSC_COEFF_A2;   bridge_wdata<=csc_a2;     end
                                4'd3:  begin bridge_addr<=CSC_COEFF_B0;   bridge_wdata<=csc_b0;     end
                                4'd4:  begin bridge_addr<=CSC_COEFF_B1;   bridge_wdata<=csc_b1;     end
                                4'd5:  begin bridge_addr<=CSC_COEFF_B2;   bridge_wdata<=csc_b2;     end
                                4'd6:  begin bridge_addr<=CSC_COEFF_C0;   bridge_wdata<=csc_c0;     end
                                4'd7:  begin bridge_addr<=CSC_COEFF_C1;   bridge_wdata<=csc_c1;     end
                                4'd8:  begin bridge_addr<=CSC_COEFF_C2;   bridge_wdata<=csc_c2;     end
                                4'd9:  begin bridge_addr<=CSC_SUMMAND_S0; bridge_wdata<=csc_s0;     end
                                4'd10: begin bridge_addr<=CSC_SUMMAND_S1; bridge_wdata<=csc_s1;     end
                                4'd11: begin bridge_addr<=CSC_SUMMAND_S2; bridge_wdata<=csc_s2;     end
                                4'd12: begin bridge_addr<=CSC_OUT_CS;     bridge_wdata<=csc_out_cs; end
                                4'd13: begin bridge_addr<=CSC_COMMIT;     bridge_wdata<=32'hFFFFFFFF; end
                                default:;
                            endcase
                        end
                    end
                end

                // ?? Poll CSC ?????????????????????????????????????????????????
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
                            if (bridge_readdata[1] == 1'b0)
                                current_state <= ST_WORKING;
                        end
                    end
                end

                // ?? PC1 ??????????????????????????????????????????????????????
                // Step 0: WIDTH (preloaded)
                // Step 1: HEIGHT
                // Step 2: INTERLACE=0
                // Step 3: COLORSPACE=0
                // Step 4: SUBSAMPLING=3
                // Step 5: CTRL=1
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
                                4'd1: begin pc1_addr<=PC1_ADDR_HEIGHT;      pc1_wdata<=IMG_HEIGHT; end
                                4'd2: begin pc1_addr<=PC1_ADDR_INTERLACE;   pc1_wdata<=32'h0;      end
                                4'd3: begin pc1_addr<=PC1_ADDR_COLORSPACE;  pc1_wdata<=32'h0;      end
                                4'd4: begin pc1_addr<=PC1_ADDR_SUBSAMPLING; pc1_wdata<=32'h3;      end
                                4'd5: begin pc1_addr<=PC1_ADDR_CTRL;        pc1_wdata<=32'h1;      end
                                default:;
                            endcase
                        end
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
    // Input mux: TPG or PC1 ? pipeline2_0.s_axis_video_in
    // =========================================================================
    wire ready_to_start = (current_state == ST_WORKING);

    // TPG video output wires
    wire [23:0] tpg_tdata;
    wire        tpg_tvalid;
    wire        tpg_tready;
    wire        tpg_tlast;
    wire [2:0]  tpg_tuser;

    // PC1 video output wires
    wire [23:0] pc1_tdata;
    wire        pc1_tvalid;
    wire        pc1_tready;
    wire        pc1_tlast;
    wire [2:0]  pc1_tuser;

    // Mux
    wire [23:0] vid_in_tdata  = INPUT_SEL ? pc1_tdata  : tpg_tdata;
    wire        vid_in_tvalid = (INPUT_SEL ? pc1_tvalid : tpg_tvalid) & ready_to_start;
    wire        vid_in_tready;
    wire        vid_in_tlast  = INPUT_SEL ? pc1_tlast  : tpg_tlast;
    wire [2:0]  vid_in_tuser  = INPUT_SEL ? pc1_tuser  : tpg_tuser;

    // Drain TPG when image mode, drain PC1 when TPG mode
    assign tpg_tready = INPUT_SEL ? 1'b1 : (vid_in_tready & ready_to_start);
    assign pc1_tready = INPUT_SEL ? (vid_in_tready & ready_to_start) : 1'b1;

    // =========================================================================
    // Platform Designer instantiation
    // =========================================================================
    pipeline u0 (
        .clk_clk    (clk),
        .reset_reset(reset),

        // MM bridge
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

        // pipeline2_0 video input (muxed)
        .s_axis_video_in_tdata  (vid_in_tdata),
        .s_axis_video_in_tvalid (vid_in_tvalid),
        .s_axis_video_in_tready (vid_in_tready),
        .s_axis_video_in_tlast  (vid_in_tlast),
        .s_axis_video_in_tuser  (vid_in_tuser),

        // pipeline2_0 video output
        .m_axis_video_out_tdata  (out_tdata),
        .m_axis_video_out_tvalid (out_tvalid),
        .m_axis_video_out_tready (out_tready),
        .m_axis_video_out_tlast  (out_tlast),
        .m_axis_video_out_tuser  (out_tuser),

        // PC1 image input (from tb)
        .axi4s_vid_in_tdata  (pc1_in_tdata),
        .axi4s_vid_in_tvalid (pc1_in_tvalid),
        .axi4s_vid_in_tready (pc1_in_tready),
        .axi4s_vid_in_tlast  (pc1_in_tlast),
        .axi4s_vid_in_tuser  (pc1_in_tuser),

        // PC1 video output ? mux
        .axi4s_vid_out_1_tdata  (pc1_tdata),
        .axi4s_vid_out_1_tvalid (pc1_tvalid),
        .axi4s_vid_out_1_tready (pc1_tready),
        .axi4s_vid_out_1_tlast  (pc1_tlast),
        .axi4s_vid_out_1_tuser  (pc1_tuser),

        // PC1 MM control
        .av_mm_control_agent_address       (pc1_addr),
        .av_mm_control_agent_write         (pc1_write),
        .av_mm_control_agent_read          (1'b0),
        .av_mm_control_agent_byteenable    (4'hF),
        .av_mm_control_agent_writedata     (pc1_wdata),
        .av_mm_control_agent_readdata      (pc1_readdata),
        .av_mm_control_agent_readdatavalid (pc1_readdatavalid),
        .av_mm_control_agent_waitrequest   (pc1_wait),

        // TPG video output ? mux
        .axi4s_vid_out_tdata  (tpg_tdata),
        .axi4s_vid_out_tvalid (tpg_tvalid),
        .axi4s_vid_out_tready (tpg_tready),
        .axi4s_vid_out_tlast  (tpg_tlast),
        .axi4s_vid_out_tuser  (tpg_tuser)
    );

endmodule
