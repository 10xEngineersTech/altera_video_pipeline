`timescale 1 ps / 1 ps

// =============================================================================
// top.v  ?  Pipeline Top-Level Controller (Platform Designer MM Bridge version)
//
// Pipeline topology (all internal to pipeline.v):
//   TPG ? DIL ? CRS ? CSC ? Clipper ? PC0 ? Scaler
//
// Unified MM Bridge:
//   Platform Designer's mm_bridge_0 exposes a single Avalon-MM slave port
//   's0' (11-bit address) that internally routes to all 4 pipeline IPs:
//
//   s0 address map (byte addresses):
//     CRS     ? 0x0000 - 0x01FF   (word addr << 2)
//     CSC     ? 0x0200 - 0x03FF
//     Scaler  ? 0x0400 - 0x05FF
//     Clipper ? 0x0600 - 0x07FF
//
//   TPG and PC1 retain dedicated Avalon-MM ports (not connected to mm_bridge).
//
// Configuration order:
//   1. TPG     ? dedicated port
//   2. Clipper ? via s0
//   3. Scaler  ? via s0
//   4. CRS     ? via s0
//   5. CSC     ? via s0, then poll status (TPG mode only)
//   6. PC1     ? dedicated port (INPUT_SEL=1 only)
//   7. WORKING ? pipeline live
// =============================================================================

module top #(
    parameter [31:0] IMG_WIDTH       = 32'd1920,
    parameter [31:0] IMG_HEIGHT      = 32'd1080,
    parameter [31:0] IMG_COLOR       = 32'd1,
    parameter [31:0] IMG_CR_SM       = 32'd1,
    parameter [31:0] IMG_L_OFF       = 32'd4,
    parameter [31:0] IMG_T_OFF       = 32'd4,
    parameter [31:0] IMG_R_OFF       = 32'd4,
    parameter [31:0] IMG_B_OFF       = 32'd4,
    parameter [31:0] SCALER_OUT_W    = 32'd1280,
    parameter [31:0] SCALER_OUT_H    = 32'd720,
    parameter [31:0] CRS_OUTPUT_MODE = 32'd3,
    parameter [2:0]  CSC_MODE        = 3'd0,
    parameter [31:0] CSC_COLOR_SPACE = 32'd0,
    parameter [0:0]  INPUT_SEL       = 1'b0
)(
    input  wire        clk,
    input  wire        reset,

    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser,

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
    // s0 base addresses (byte addresses from Platform Designer address map)
    // =========================================================================
    localparam [10:0] CRS_BASE  = 11'h000;
    localparam [10:0] CSC_BASE  = 11'h200;
    localparam [10:0] SCL_BASE  = 11'h400;
    localparam [10:0] CLIP_BASE = 11'h600;

    // =========================================================================
    // Per-IP register byte offsets (word_addr << 2)
    // =========================================================================

    // --- Clipper ---
    localparam [8:0] CLIP_IN_HEIGHT    = 9'h49 << 2;   // 0x124
    localparam [8:0] CLIP_IN_WIDTH     = 9'h48 << 2;   // 0x120
    localparam [8:0] CLIP_IN_COLOR     = 9'h4C << 2;   // 0x130
    localparam [8:0] CLIP_IN_SUBSAMPLE = 9'h4D << 2;   // 0x134
    localparam [8:0] CLIP_COMMIT       = 9'h51 << 2;   // 0x144
    localparam [8:0] CLIP_LEFT_OFF     = 9'h52 << 2;   // 0x148
    localparam [8:0] CLIP_TOP_OFF      = 9'h53 << 2;   // 0x14C
    localparam [8:0] CLIP_RIGHT_OFF    = 9'h54 << 2;   // 0x150
    localparam [8:0] CLIP_BOT_OFF      = 9'h55 << 2;   // 0x154

    // --- Scaler ---
    localparam [8:0] SCL_IN_WIDTH      = 9'h48 << 2;   // 0x120
    localparam [8:0] SCL_IN_HEIGHT     = 9'h49 << 2;   // 0x124
    localparam [8:0] SCL_OUT_WIDTH     = 9'h52 << 2;   // 0x148
    localparam [8:0] SCL_OUT_HEIGHT    = 9'h53 << 2;   // 0x14C

    // --- CRS ---
    localparam [8:0] CRS_OUT_MODE      = 9'h52 << 2;   // 0x148
    localparam [8:0] CRS_COMMIT        = 9'h51 << 2;   // 0x144

    // --- CSC ---
    localparam [8:0] CSC_STATUS        = 9'h50 << 2;   // 0x140
    localparam [8:0] CSC_COMMIT        = 9'h51 << 2;   // 0x144
    localparam [8:0] CSC_COEFF_A0      = 9'h52 << 2;   // 0x148
    localparam [8:0] CSC_COEFF_A1      = 9'h53 << 2;
    localparam [8:0] CSC_COEFF_A2      = 9'h54 << 2;
    localparam [8:0] CSC_COEFF_B0      = 9'h55 << 2;
    localparam [8:0] CSC_COEFF_B1      = 9'h56 << 2;
    localparam [8:0] CSC_COEFF_B2      = 9'h57 << 2;
    localparam [8:0] CSC_COEFF_C0      = 9'h58 << 2;
    localparam [8:0] CSC_COEFF_C1      = 9'h59 << 2;
    localparam [8:0] CSC_COEFF_C2      = 9'h5A << 2;
    localparam [8:0] CSC_SUMMAND_S0    = 9'h5B << 2;
    localparam [8:0] CSC_SUMMAND_S1    = 9'h5C << 2;
    localparam [8:0] CSC_SUMMAND_S2    = 9'h5D << 2;
    localparam [8:0] CSC_OUT_CS        = 9'h5E << 2;

    // --- TPG dedicated register addresses (word addresses) ---
    localparam [6:0] TPG_ADDR_WIDTH     = 7'h48;
    localparam [6:0] TPG_ADDR_HEIGHT    = 7'h49;
    localparam [6:0] TPG_ADDR_INTERLACE = 7'h4A;
    localparam [6:0] TPG_ADDR_STATUS    = 7'h50;
    localparam [6:0] TPG_ADDR_CONTROL   = 7'h52;
    localparam [6:0] TPG_ADDR_COMMIT    = 7'h53;
    localparam [6:0] TPG_ADDR_PATTERN   = 7'h54;
    localparam [6:0] TPG_ADDR_BAR_SEL   = 7'h5A;

    // --- PC1 dedicated register addresses (word addresses) ---
    localparam [6:0] PC1_ADDR_WIDTH       = 7'h48;
    localparam [6:0] PC1_ADDR_HEIGHT      = 7'h49;
    localparam [6:0] PC1_ADDR_INTERLACE   = 7'h4A;
    localparam [6:0] PC1_ADDR_COLORSPACE  = 7'h4C;
    localparam [6:0] PC1_ADDR_SUBSAMPLING = 7'h4D;
    localparam [6:0] PC1_ADDR_CTRL        = 7'h55;

    // =========================================================================
    // State encoding ? identical to original
    // =========================================================================
    localparam [4:0]
        ST_IDLE          = 5'd0,
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
        ST_CONFIG_CLIP   = 5'd13,
        ST_CONFIG_SCL    = 5'd14,
        ST_CONFIG_CRS    = 5'd15,
        ST_CONFIG_CSC    = 5'd16,
        ST_POLL_CSC      = 5'd17,
        ST_WORKING       = 5'd18,
        ST_CONFIG_PC1    = 5'd19;

    // =========================================================================
    // CSC coefficient ROMs (Q10.21 signed, 32-bit)
    // =========================================================================
    localparam signed [31:0] PT_A0=32'sh00200000, PT_A1=32'sh00000000, PT_A2=32'sh00000000;
    localparam signed [31:0] PT_B0=32'sh00000000, PT_B1=32'sh00200000, PT_B2=32'sh00000000;
    localparam signed [31:0] PT_C0=32'sh00000000, PT_C1=32'sh00000000, PT_C2=32'sh00200000;
    localparam signed [31:0] PT_S0=32'sh00000000, PT_S1=32'sh00000000, PT_S2=32'sh00000000;

    localparam signed [31:0] RH_A0=32'sh000E0C4A, RH_A1=32'sh0001FBE7, RH_A2=32'shFFFEB852;
    localparam signed [31:0] RH_B0=32'shFFF52F1B, RH_B1=32'sh0013A5E3, RH_B2=32'shFFF33B64;
    localparam signed [31:0] RH_C0=32'shFFFCC49C, RH_C1=32'sh0005DB23, RH_C2=32'sh000E0C4A;
    localparam signed [31:0] RH_S0=32'sh10000000, RH_S1=32'sh02000000, RH_S2=32'sh10000000;

    localparam signed [31:0] HR_A0=32'sh0043AE14, HR_A1=32'shFFF92F1B, HR_A2=32'sh00000000;
    localparam signed [31:0] HR_B0=32'sh00253F7D, HR_B1=32'sh00253F7D, HR_B2=32'sh00253F7D;
    localparam signed [31:0] HR_C0=32'sh00000000, HR_C1=32'shFFEEE979, HR_C2=32'sh00396042;
    localparam signed [31:0] HR_S0=32'shDBD4FDF4, HR_S1=32'sh099FBE77, HR_S2=32'shE0FBE00D;

    localparam signed [31:0] RS_A0=32'sh000E0C4A, RS_A1=32'sh000322D1, RS_A2=32'shFFFDBA5E;
    localparam signed [31:0] RS_B0=32'shFFF6B021, RS_B1=32'sh001020C5, RS_B2=32'shFFF43958;
    localparam signed [31:0] RS_C0=32'shFFFB4396, RS_C1=32'sh00083958, RS_C2=32'sh000E0C4A;
    localparam signed [31:0] RS_S0=32'sh10000000, RS_S1=32'sh02000000, RS_S2=32'sh10000000;

    localparam signed [31:0] SR_A0=32'sh003A1CAC, SR_A1=32'shFFFA24DD, SR_A2=32'sh00000000;
    localparam signed [31:0] SR_B0=32'sh00200000, SR_B1=32'sh00200000, SR_B2=32'sh00200000;
    localparam signed [31:0] SR_C0=32'sh00000000, SR_C1=32'shFFF14FDF, SR_C2=32'sh003147AE;
    localparam signed [31:0] SR_S0=32'shE2F1A9FC, SR_S1=32'sh0A45A1CB, SR_S2=32'shE75C20C5;

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

    // --- s0 unified MM bus (Platform Designer mm_bridge) ---
    reg  [10:0] s0_address;
    reg         s0_write;
    reg         s0_read;
    reg  [31:0] s0_writedata;
    wire [31:0] s0_readdata;
    wire        s0_readdatavalid;
    wire        s0_waitrequest;

    // --- TPG dedicated port ---
    reg  [6:0]  tpg_addr;
    reg         tpg_write, tpg_read;
    reg  [31:0] tpg_wdata;
    wire [31:0] tpg_readdata;
    wire        tpg_readdatavalid;
    wire        tpg_wait;

    // --- PC1 dedicated port ---
    reg  [6:0]  pc1_addr;
    reg         pc1_write;
    reg  [31:0] pc1_wdata;
    wire        pc1_wait;

    // =========================================================================
    // Configuration State Machine
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            s0_write      <= 1'b0;
            s0_read       <= 1'b0;
            tpg_write     <= 1'b0;
            tpg_read      <= 1'b0;
            pc1_write     <= 1'b0;
            cfg_step      <= 4'd0;
            cycle_count   <= 8'h0;
        end else begin
            case (current_state)

                ST_IDLE: current_state <= ST_TPG_CTRL_1;

                // ==============================================================
                // TPG ? dedicated port, same as original
                // ==============================================================
                ST_TPG_CTRL_1: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_CONTROL; tpg_wdata <= 32'h0;
                    if (!tpg_wait) begin tpg_write <= 1'b0; current_state <= ST_TPG_WR_INTL; end
                end
                ST_TPG_WR_INTL: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_INTERLACE; tpg_wdata <= 32'h0;
                    if (!tpg_wait) begin tpg_write <= 1'b0; current_state <= ST_TPG_WR_W; end
                end
                ST_TPG_WR_W: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_WIDTH; tpg_wdata <= IMG_WIDTH;
                    if (!tpg_wait) begin tpg_write <= 1'b0; current_state <= ST_TPG_WR_H; end
                end
                ST_TPG_WR_H: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_HEIGHT; tpg_wdata <= IMG_HEIGHT;
                    if (!tpg_wait) begin tpg_write <= 1'b0; current_state <= ST_TPG_WR_PAT_T; end
                end
                ST_TPG_WR_PAT_T: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_BAR_SEL; tpg_wdata <= 32'h0;
                    if (!tpg_wait) begin tpg_write <= 1'b0; current_state <= ST_TPG_WR_PAT_S; end
                end
                ST_TPG_WR_PAT_S: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_PATTERN; tpg_wdata <= 32'h0;
                    if (!tpg_wait) begin tpg_write <= 1'b0; current_state <= ST_TPG_WR_CMT; end
                end
                ST_TPG_WR_CMT: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_COMMIT; tpg_wdata <= 32'h1;
                    if (!tpg_wait) begin tpg_write <= 1'b0; current_state <= ST_TPG_CTRL_2; end
                end
                ST_TPG_CTRL_2: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_CONTROL; tpg_wdata <= 32'h1;
                    if (!tpg_wait) begin tpg_write <= 1'b0; current_state <= ST_TPG_POLL_ISS; end
                end
                ST_TPG_POLL_ISS: begin
                    tpg_read <= 1'b1; tpg_addr <= TPG_ADDR_STATUS;
                    if (!tpg_wait) begin tpg_read <= 1'b0; current_state <= ST_TPG_POLL_W; end
                end
                ST_TPG_POLL_W: begin
                    if (tpg_readdatavalid) begin
                        if (tpg_readdata[1] == 1'b0) current_state <= ST_TPG_IP_RST;
                        else                          current_state <= ST_TPG_POLL_ISS;
                    end
                end
                ST_TPG_IP_RST: begin
                    cycle_count <= cycle_count + 1'b1;
                    if (cycle_count == 8'h07) current_state <= ST_TPG_CTRL_3;
                end
                ST_TPG_CTRL_3: begin
                    tpg_write <= 1'b1; tpg_addr <= TPG_ADDR_CONTROL; tpg_wdata <= 32'h1;
                    if (!tpg_wait) begin
                        tpg_write    <= 1'b0;
                        cfg_step     <= 4'd0;
                        s0_address   <= CLIP_BASE | CLIP_IN_HEIGHT;
                        s0_writedata <= IMG_HEIGHT;
                        current_state <= ST_CONFIG_CLIP;
                    end
                end

                // ==============================================================
                // Clipper ? 9 writes via s0
                // ==============================================================
                ST_CONFIG_CLIP: begin
                    s0_write <= 1'b1;
                    if (s0_write && !s0_waitrequest) begin
                        if (cfg_step == 4'd8) begin
                            s0_write      <= 1'b0;
                            cfg_step      <= 4'd0;
                            s0_address    <= SCL_BASE | SCL_IN_WIDTH;
                            s0_writedata  <= SCALER_IN_W;
                            current_state <= ST_CONFIG_SCL;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin s0_address <= CLIP_BASE | CLIP_IN_WIDTH;     s0_writedata <= IMG_WIDTH;  end
                                4'd2: begin s0_address <= CLIP_BASE | CLIP_IN_COLOR;     s0_writedata <= IMG_COLOR;  end
                                4'd3: begin s0_address <= CLIP_BASE | CLIP_IN_SUBSAMPLE; s0_writedata <= IMG_CR_SM;  end
                                4'd4: begin s0_address <= CLIP_BASE | CLIP_LEFT_OFF;     s0_writedata <= IMG_L_OFF;  end
                                4'd5: begin s0_address <= CLIP_BASE | CLIP_TOP_OFF;      s0_writedata <= IMG_T_OFF;  end
                                4'd6: begin s0_address <= CLIP_BASE | CLIP_RIGHT_OFF;    s0_writedata <= IMG_R_OFF;  end
                                4'd7: begin s0_address <= CLIP_BASE | CLIP_BOT_OFF;      s0_writedata <= IMG_B_OFF;  end
                                4'd8: begin s0_address <= CLIP_BASE | CLIP_COMMIT;       s0_writedata <= 32'h1;      end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                // Scaler ? 4 writes via s0
                // ==============================================================
                ST_CONFIG_SCL: begin
                    s0_write <= 1'b1;
                    if (s0_write && !s0_waitrequest) begin
                        if (cfg_step == 4'd3) begin
                            s0_write      <= 1'b0;
                            cfg_step      <= 4'd0;
                            s0_address    <= CRS_BASE | CRS_OUT_MODE;
                            s0_writedata  <= CRS_OUTPUT_MODE;
                            current_state <= ST_CONFIG_CRS;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin s0_address <= SCL_BASE | SCL_IN_HEIGHT;  s0_writedata <= SCALER_IN_H;  end
                                4'd2: begin s0_address <= SCL_BASE | SCL_OUT_WIDTH;  s0_writedata <= SCALER_OUT_W; end
                                4'd3: begin s0_address <= SCL_BASE | SCL_OUT_HEIGHT; s0_writedata <= SCALER_OUT_H; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                // CRS ? 2 writes via s0
                // ==============================================================
                ST_CONFIG_CRS: begin
                    s0_write <= 1'b1;
                    if (s0_write && !s0_waitrequest) begin
                        if (cfg_step == 4'd1) begin
                            s0_write      <= 1'b0;
                            cfg_step      <= 4'd0;
                            s0_address    <= CSC_BASE | CSC_COEFF_A0;
                            s0_writedata  <= csc_a0;
                            current_state <= ST_CONFIG_CSC;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin s0_address <= CRS_BASE | CRS_COMMIT; s0_writedata <= 32'h1; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                // CSC ? 14 writes via s0
                // ==============================================================
                ST_CONFIG_CSC: begin
                    s0_write <= 1'b1;
                    if (s0_write && !s0_waitrequest) begin
                        if (cfg_step == 4'd13) begin
                            s0_write  <= 1'b0;
                            cfg_step  <= 4'd0;
                            if (INPUT_SEL) begin
                                pc1_addr      <= PC1_ADDR_WIDTH;
                                pc1_wdata     <= IMG_WIDTH;
                                current_state <= ST_CONFIG_PC1;
                            end else begin
                                //current_state <= ST_POLL_CSC;
                                  current_state <= ST_WORKING;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1:  begin s0_address <= CSC_BASE | CSC_COEFF_A1;   s0_writedata <= csc_a1;       end
                                4'd2:  begin s0_address <= CSC_BASE | CSC_COEFF_A2;   s0_writedata <= csc_a2;       end
                                4'd3:  begin s0_address <= CSC_BASE | CSC_COEFF_B0;   s0_writedata <= csc_b0;       end
                                4'd4:  begin s0_address <= CSC_BASE | CSC_COEFF_B1;   s0_writedata <= csc_b1;       end
                                4'd5:  begin s0_address <= CSC_BASE | CSC_COEFF_B2;   s0_writedata <= csc_b2;       end
                                4'd6:  begin s0_address <= CSC_BASE | CSC_COEFF_C0;   s0_writedata <= csc_c0;       end
                                4'd7:  begin s0_address <= CSC_BASE | CSC_COEFF_C1;   s0_writedata <= csc_c1;       end
                                4'd8:  begin s0_address <= CSC_BASE | CSC_COEFF_C2;   s0_writedata <= csc_c2;       end
                                4'd9:  begin s0_address <= CSC_BASE | CSC_SUMMAND_S0; s0_writedata <= csc_s0;       end
                                4'd10: begin s0_address <= CSC_BASE | CSC_SUMMAND_S1; s0_writedata <= csc_s1;       end
                                4'd11: begin s0_address <= CSC_BASE | CSC_SUMMAND_S2; s0_writedata <= csc_s2;       end
                                4'd12: begin s0_address <= CSC_BASE | CSC_OUT_CS;     s0_writedata <= csc_out_cs;   end
                                4'd13: begin s0_address <= CSC_BASE | CSC_COMMIT;     s0_writedata <= 32'hFFFFFFFF; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                // Poll CSC STATUS bit[1] until 0 ? TPG mode only
                // ==============================================================
                ST_POLL_CSC: begin
                    if (cfg_step == 4'd0) begin
                        s0_read    <= 1'b1;
                        s0_address <= CSC_BASE | CSC_STATUS;
                        if (!s0_waitrequest) begin
                            s0_read  <= 1'b0;
                            cfg_step <= 4'd1;
                        end
                    end else begin
                        if (s0_readdatavalid) begin
                            cfg_step <= 4'd0;
                            if (s0_readdata[1] == 1'b0)
                                current_state <= ST_WORKING;
                            // else re-poll
                        end
                    end
                end

                // ==============================================================
                // PC1 ? dedicated port, INPUT_SEL=1 only
                // ==============================================================
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
                                4'd4: begin pc1_addr <= PC1_ADDR_SUBSAMPLING; pc1_wdata <= 32'h3;      end
                                4'd5: begin pc1_addr <= PC1_ADDR_CTRL;        pc1_wdata <= 32'h1;      end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                ST_WORKING: begin
                    s0_write  <= 1'b0; s0_read   <= 1'b0;
                    tpg_write <= 1'b0; tpg_read  <= 1'b0;
                    pc1_write <= 1'b0;
                end

                default: current_state <= ST_IDLE;

            endcase
        end
    end

    // =========================================================================
    // Data gate
    // =========================================================================
    //wire ready_to_start = INPUT_SEL ? (current_state == ST_WORKING)
       //                             : (current_state >= ST_CONFIG_CSC);
    wire ready_to_start = (current_state == ST_WORKING);
    wire [23:0] tpg_out_tdata;  wire tpg_out_tvalid, tpg_out_tlast; wire [2:0] tpg_out_tuser;
    wire [23:0] pc1_out_tdata;  wire pc1_out_tvalid, pc1_out_tlast; wire [2:0] pc1_out_tuser;

    wire [23:0] dil_in_tdata  = INPUT_SEL ? pc1_out_tdata  : tpg_out_tdata;
    wire        dil_in_tvalid = (INPUT_SEL ? pc1_out_tvalid : tpg_out_tvalid) & ready_to_start;
    wire        dil_in_tready;
    wire        dil_in_tlast  = INPUT_SEL ? pc1_out_tlast  : tpg_out_tlast;
    wire [2:0]  dil_in_tuser  = INPUT_SEL ? pc1_out_tuser  : tpg_out_tuser;

    wire tpg_out_tready = INPUT_SEL ? 1'b1 : (dil_in_tready & ready_to_start);

    wire [23:0] dil_out_tdata;  wire dil_out_tvalid,  dil_out_tready,  dil_out_tlast;  wire [2:0] dil_out_tuser;
    wire [23:0] crs_out_tdata;  wire crs_out_tvalid,  crs_out_tready,  crs_out_tlast;  wire [2:0] crs_out_tuser;
    wire [23:0] csc_out_tdata;  wire csc_out_tvalid,  csc_out_tready,  csc_out_tlast;  wire [2:0] csc_out_tuser;
    wire [23:0] clip_out_tdata; wire clip_out_tvalid, clip_out_tready, clip_out_tlast; wire [2:0] clip_out_tuser;
    wire [23:0] pc_out_tdata;   wire pc_out_tvalid,   pc_out_tready,   pc_out_tlast;   wire [2:0] pc_out_tuser;

    // =========================================================================
    // Pipeline instantiation
    // =========================================================================
    pipeline u_pipeline (
        .clk_clk     (clk),
        .reset_reset (reset),

        // TPG output
        .intel_vvp_tpg_0_axi4s_vid_out_tdata  (tpg_out_tdata),
        .intel_vvp_tpg_0_axi4s_vid_out_tvalid (tpg_out_tvalid),
        .intel_vvp_tpg_0_axi4s_vid_out_tready (tpg_out_tready),
        .intel_vvp_tpg_0_axi4s_vid_out_tlast  (tpg_out_tlast),
        .intel_vvp_tpg_0_axi4s_vid_out_tuser  (tpg_out_tuser),

        // DIL input
        .intel_vvp_dil_0_axi4s_vid_in_tdata   (dil_in_tdata),
        .intel_vvp_dil_0_axi4s_vid_in_tvalid  (dil_in_tvalid),
        .intel_vvp_dil_0_axi4s_vid_in_tready  (dil_in_tready),
        .intel_vvp_dil_0_axi4s_vid_in_tlast   (dil_in_tlast),
        .intel_vvp_dil_0_axi4s_vid_in_tuser   (dil_in_tuser),

        // DIL output ? CRS input
        .intel_vvp_dil_0_axi4s_vid_out_tdata  (dil_out_tdata),
        .intel_vvp_dil_0_axi4s_vid_out_tvalid (dil_out_tvalid),
        .intel_vvp_dil_0_axi4s_vid_out_tready (dil_out_tready),
        .intel_vvp_dil_0_axi4s_vid_out_tlast  (dil_out_tlast),
        .intel_vvp_dil_0_axi4s_vid_out_tuser  (dil_out_tuser),

        .intel_vvp_crs_0_axi4s_vid_in_tdata   (dil_out_tdata),
        .intel_vvp_crs_0_axi4s_vid_in_tvalid  (dil_out_tvalid),
        .intel_vvp_crs_0_axi4s_vid_in_tready  (dil_out_tready),
        .intel_vvp_crs_0_axi4s_vid_in_tlast   (dil_out_tlast),
        .intel_vvp_crs_0_axi4s_vid_in_tuser   (dil_out_tuser),

        // CRS output ? CSC input
        .intel_vvp_crs_0_axi4s_vid_out_tdata  (crs_out_tdata),
        .intel_vvp_crs_0_axi4s_vid_out_tvalid (crs_out_tvalid),
        .intel_vvp_crs_0_axi4s_vid_out_tready (crs_out_tready),
        .intel_vvp_crs_0_axi4s_vid_out_tlast  (crs_out_tlast),
        .intel_vvp_crs_0_axi4s_vid_out_tuser  (crs_out_tuser),

        .intel_vvp_csc_0_axi4s_vid_in_tdata   (crs_out_tdata),
        .intel_vvp_csc_0_axi4s_vid_in_tvalid  (crs_out_tvalid),
        .intel_vvp_csc_0_axi4s_vid_in_tready  (crs_out_tready),
        .intel_vvp_csc_0_axi4s_vid_in_tlast   (crs_out_tlast),
        .intel_vvp_csc_0_axi4s_vid_in_tuser   (crs_out_tuser),

        // CSC output ? Clipper input
        .intel_vvp_csc_0_axi4s_vid_out_tdata  (csc_out_tdata),
        .intel_vvp_csc_0_axi4s_vid_out_tvalid (csc_out_tvalid),
        .intel_vvp_csc_0_axi4s_vid_out_tready (csc_out_tready | (current_state == ST_POLL_CSC)),
        .intel_vvp_csc_0_axi4s_vid_out_tlast  (csc_out_tlast),
        .intel_vvp_csc_0_axi4s_vid_out_tuser  (csc_out_tuser),

        .intel_vvp_clipper_0_axi4s_vid_in_tdata   (csc_out_tdata),
        .intel_vvp_clipper_0_axi4s_vid_in_tvalid  (csc_out_tvalid),
        .intel_vvp_clipper_0_axi4s_vid_in_tready  (csc_out_tready),
        .intel_vvp_clipper_0_axi4s_vid_in_tlast   (csc_out_tlast),
        .intel_vvp_clipper_0_axi4s_vid_in_tuser   (csc_out_tuser),

        // Clipper output ? PC0 ? Scaler
        .intel_vvp_clipper_0_axi4s_vid_out_tdata  (clip_out_tdata),
        .intel_vvp_clipper_0_axi4s_vid_out_tvalid (clip_out_tvalid),
        .intel_vvp_clipper_0_axi4s_vid_out_tready (clip_out_tready),
        .intel_vvp_clipper_0_axi4s_vid_out_tlast  (clip_out_tlast),
        .intel_vvp_clipper_0_axi4s_vid_out_tuser  (clip_out_tuser),

        .intel_vvp_protocol_conv_0_axi4s_vid_in_tdata   (clip_out_tdata),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tvalid  (clip_out_tvalid),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tready  (clip_out_tready),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tlast   (clip_out_tlast),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tuser   (clip_out_tuser),

        .intel_vvp_protocol_conv_0_axi4s_vid_out_tdata  (pc_out_tdata),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tvalid (pc_out_tvalid),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tready (pc_out_tready),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tlast  (pc_out_tlast),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tuser  (pc_out_tuser),

        .intel_vvp_scaler_0_axi4s_vid_in_tdata  (pc_out_tdata),
        .intel_vvp_scaler_0_axi4s_vid_in_tvalid (pc_out_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_in_tready (pc_out_tready),
        .intel_vvp_scaler_0_axi4s_vid_in_tlast  (pc_out_tlast),
        .intel_vvp_scaler_0_axi4s_vid_in_tuser  (pc_out_tuser),

        .intel_vvp_scaler_0_axi4s_vid_out_tdata  (out_tdata),
        .intel_vvp_scaler_0_axi4s_vid_out_tvalid (out_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_out_tready (out_tready),
        .intel_vvp_scaler_0_axi4s_vid_out_tlast  (out_tlast),
        .intel_vvp_scaler_0_axi4s_vid_out_tuser  (out_tuser),

        // TPG Avalon-MM ? dedicated
        .intel_vvp_tpg_0_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_0_av_mm_control_agent_write         (tpg_write),
        .intel_vvp_tpg_0_av_mm_control_agent_read          (tpg_read),
        .intel_vvp_tpg_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_0_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdata      (tpg_readdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdatavalid (tpg_readdatavalid),
        .intel_vvp_tpg_0_av_mm_control_agent_waitrequest   (tpg_wait),

        // PC1 Avalon-MM ? dedicated
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

        .intel_vvp_protocol_conv_1_av_mm_control_agent_address       (pc1_addr),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_write         (pc1_write),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_read          (1'b0),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_writedata     (pc1_wdata),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_readdata      (),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_readdatavalid (),
        .intel_vvp_protocol_conv_1_av_mm_control_agent_waitrequest   (pc1_wait),

        // s0 ? unified MM bridge (Platform Designer mm_bridge_0)
        .s0_address      (s0_address),
        .s0_write        (s0_write),
        .s0_read         (s0_read),
        .s0_writedata    (s0_writedata),
        .s0_readdata     (s0_readdata),
        .s0_readdatavalid(s0_readdatavalid),
        .s0_waitrequest  (s0_waitrequest),
        .s0_byteenable   (4'hF),
        .s0_burstcount   (1'b1),
        .s0_debugaccess  (1'b0)
    );

endmodule
