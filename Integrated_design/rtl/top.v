`timescale 1 ps / 1 ps

// =============================================================================
// top.v  ?  Pipeline Top-Level Controller (Unified MM Bridge version)
//
// Pipeline topology (all internal to pipeline.v):
//   TPG ? DIL ? CRS ? CSC ? Clipper ? PC0 ? Scaler
//
// Unified MM Bridge address map (bits [8:7] select slave):
//   0x000 - 0x07F  ?  Clipper
//   0x080 - 0x0FF  ?  Scaler
//   0x100 - 0x17F  ?  CRS
//   0x180 - 0x1FF  ?  CSC
//
// TPG and PC1 keep their own dedicated Avalon-MM ports (outside pipeline).
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
    parameter [31:0] CRS_OUTPUT_MODE = 32'd3,    // 2=YUV422, 3=YUV444
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
    // Unified MM bridge ? base addresses (bits [8:7] = slave select)
    // =========================================================================
    localparam [8:0] CLIP_BASE = 9'h000;
    localparam [8:0] SCL_BASE  = 9'h080;
    localparam [8:0] CRS_BASE  = 9'h100;
    localparam [8:0] CSC_BASE  = 9'h180;

    // --- Clipper register offsets ---
    localparam [6:0] CLIP_IN_WIDTH     = 7'h48;
    localparam [6:0] CLIP_IN_HEIGHT    = 7'h49;
    localparam [6:0] CLIP_IN_COLOR     = 7'h4C;
    localparam [6:0] CLIP_IN_SUBSAMPLE = 7'h4D;
    localparam [6:0] CLIP_COMMIT       = 7'h51;
    localparam [6:0] CLIP_LEFT_OFF     = 7'h52;
    localparam [6:0] CLIP_TOP_OFF      = 7'h53;
    localparam [6:0] CLIP_RIGHT_OFF    = 7'h54;
    localparam [6:0] CLIP_BOT_OFF      = 7'h55;

    // --- Scaler register offsets ---
    localparam [6:0] SCL_IN_WIDTH      = 7'h48;
    localparam [6:0] SCL_IN_HEIGHT     = 7'h49;
    localparam [6:0] SCL_OUT_WIDTH     = 7'h52;
    localparam [6:0] SCL_OUT_HEIGHT    = 7'h53;

    // --- CRS register offsets ---
    localparam [6:0] CRS_OUT_MODE      = 7'h52;
    localparam [6:0] CRS_COMMIT        = 7'h51;

    // --- CSC register offsets ---
    localparam [6:0] CSC_STATUS        = 7'h50;
    localparam [6:0] CSC_COMMIT        = 7'h51;
    localparam [6:0] CSC_COEFF_A0      = 7'h52;
    localparam [6:0] CSC_COEFF_A1      = 7'h53;
    localparam [6:0] CSC_COEFF_A2      = 7'h54;
    localparam [6:0] CSC_COEFF_B0      = 7'h55;
    localparam [6:0] CSC_COEFF_B1      = 7'h56;
    localparam [6:0] CSC_COEFF_B2      = 7'h57;
    localparam [6:0] CSC_COEFF_C0      = 7'h58;
    localparam [6:0] CSC_COEFF_C1      = 7'h59;
    localparam [6:0] CSC_COEFF_C2      = 7'h5A;
    localparam [6:0] CSC_SUMMAND_S0    = 7'h5B;
    localparam [6:0] CSC_SUMMAND_S1    = 7'h5C;
    localparam [6:0] CSC_SUMMAND_S2    = 7'h5D;
    localparam [6:0] CSC_OUT_CS        = 7'h5E;

    // --- TPG register addresses (dedicated port) ---
    localparam [6:0] TPG_ADDR_WIDTH     = 7'h48;
    localparam [6:0] TPG_ADDR_HEIGHT    = 7'h49;
    localparam [6:0] TPG_ADDR_INTERLACE = 7'h4A;
    localparam [6:0] TPG_ADDR_STATUS    = 7'h50;
    localparam [6:0] TPG_ADDR_CONTROL   = 7'h52;
    localparam [6:0] TPG_ADDR_COMMIT    = 7'h53;
    localparam [6:0] TPG_ADDR_PATTERN   = 7'h54;
    localparam [6:0] TPG_ADDR_BAR_SEL   = 7'h5A;

    // --- PC1 register addresses (dedicated port) ---
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
    // Unified MM bus registers (single master driving mm_bridge)
    // =========================================================================
    reg  [8:0]  mm_address;
    reg         mm_write;
    reg         mm_read;
    reg  [31:0] mm_writedata;
    wire [31:0] mm_readdata;
    wire        mm_readdatavalid;
    wire        mm_waitrequest;

    // =========================================================================
    // TPG dedicated Avalon-MM registers
    // =========================================================================
    reg  [6:0]  tpg_addr;
    reg         tpg_write, tpg_read;
    reg  [31:0] tpg_wdata;
    wire [31:0] tpg_readdata;
    wire        tpg_readdatavalid;
    wire        tpg_wait;

    // =========================================================================
    // PC1 dedicated Avalon-MM registers
    // =========================================================================
    reg  [6:0]  pc1_addr;
    reg         pc1_write;
    reg  [31:0] pc1_wdata;
    wire        pc1_wait;

    // =========================================================================
    // mm_bridge slave-side wires (bridge ? pipeline ports)
    // =========================================================================
    wire [6:0]  clip_address;
    wire        clip_write_w, clip_read_w;
    wire [31:0] clip_writedata, clip_readdata;
    wire        clip_readdatavalid, clip_waitrequest;

    wire [6:0]  scl_address;
    wire        scl_write_w, scl_read_w;
    wire [31:0] scl_writedata, scl_readdata;
    wire        scl_readdatavalid, scl_waitrequest;

    wire [6:0]  crs_address;
    wire        crs_write_w, crs_read_w;
    wire [31:0] crs_writedata, crs_readdata;
    wire        crs_readdatavalid, crs_waitrequest;

    wire [6:0]  csc_address;
    wire        csc_write_w, csc_read_w;
    wire [31:0] csc_writedata, csc_readdata;
    wire        csc_readdatavalid, csc_waitrequest;

    // =========================================================================
    // mm_bridge instantiation
    // =========================================================================
    mm_bridge u_mm_bridge (
        .clk                  (clk),
        .reset                (reset),
        .master_address       (mm_address),
        .master_write         (mm_write),
        .master_read          (mm_read),
        .master_byteenable    (4'hF),
        .master_writedata     (mm_writedata),
        .master_readdata      (mm_readdata),
        .master_readdatavalid (mm_readdatavalid),
        .master_waitrequest   (mm_waitrequest),

        .clip_address         (clip_address),
        .clip_write           (clip_write_w),
        .clip_read            (clip_read_w),
        .clip_byteenable      (),
        .clip_writedata       (clip_writedata),
        .clip_readdata        (clip_readdata),
        .clip_readdatavalid   (clip_readdatavalid),
        .clip_waitrequest     (clip_waitrequest),

        .scl_address          (scl_address),
        .scl_write            (scl_write_w),
        .scl_read             (scl_read_w),
        .scl_byteenable       (),
        .scl_writedata        (scl_writedata),
        .scl_readdata         (scl_readdata),
        .scl_readdatavalid    (scl_readdatavalid),
        .scl_waitrequest      (scl_waitrequest),

        .crs_address          (crs_address),
        .crs_write            (crs_write_w),
        .crs_read             (crs_read_w),
        .crs_byteenable       (),
        .crs_writedata        (crs_writedata),
        .crs_readdata         (crs_readdata),
        .crs_readdatavalid    (crs_readdatavalid),
        .crs_waitrequest      (crs_waitrequest),

        .csc_address          (csc_address),
        .csc_write            (csc_write_w),
        .csc_read             (csc_read_w),
        .csc_byteenable       (),
        .csc_writedata        (csc_writedata),
        .csc_readdata         (csc_readdata),
        .csc_readdatavalid    (csc_readdatavalid),
        .csc_waitrequest      (csc_waitrequest)
    );

    // =========================================================================
    // Configuration State Machine
    // =========================================================================
    reg [3:0] cfg_step;
    reg [7:0] cycle_count;
    reg [4:0] current_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            mm_write      <= 1'b0;
            mm_read       <= 1'b0;
            tpg_write     <= 1'b0;
            tpg_read      <= 1'b0;
            pc1_write     <= 1'b0;
            cfg_step      <= 4'd0;
            cycle_count   <= 8'h0;
        end else begin
            case (current_state)

                ST_IDLE: current_state <= ST_TPG_CTRL_1;

                // ==============================================================
                // TPG configuration ? dedicated port, unchanged from original
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
                        tpg_write     <= 1'b0;
                        cfg_step      <= 4'd0;
                        mm_address    <= CLIP_BASE | CLIP_IN_HEIGHT;
                        mm_writedata  <= IMG_HEIGHT;
                        current_state <= ST_CONFIG_CLIP;
                    end
                end

                // ==============================================================
                // Clipper ? 9 writes via unified mm_bridge
                // ==============================================================
                ST_CONFIG_CLIP: begin
                    mm_write <= 1'b1;
                    if (mm_write && !mm_waitrequest) begin
                        if (cfg_step == 4'd8) begin
                            mm_write      <= 1'b0;
                            cfg_step      <= 4'd0;
                            mm_address    <= SCL_BASE | SCL_IN_WIDTH;
                            mm_writedata  <= SCALER_IN_W;
                            current_state <= ST_CONFIG_SCL;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin mm_address <= CLIP_BASE | CLIP_IN_WIDTH;     mm_writedata <= IMG_WIDTH;   end
                                4'd2: begin mm_address <= CLIP_BASE | CLIP_IN_COLOR;     mm_writedata <= IMG_COLOR;   end
                                4'd3: begin mm_address <= CLIP_BASE | CLIP_IN_SUBSAMPLE; mm_writedata <= IMG_CR_SM;   end
                                4'd4: begin mm_address <= CLIP_BASE | CLIP_LEFT_OFF;     mm_writedata <= IMG_L_OFF;   end
                                4'd5: begin mm_address <= CLIP_BASE | CLIP_TOP_OFF;      mm_writedata <= IMG_T_OFF;   end
                                4'd6: begin mm_address <= CLIP_BASE | CLIP_RIGHT_OFF;    mm_writedata <= IMG_R_OFF;   end
                                4'd7: begin mm_address <= CLIP_BASE | CLIP_BOT_OFF;      mm_writedata <= IMG_B_OFF;   end
                                4'd8: begin mm_address <= CLIP_BASE | CLIP_COMMIT;       mm_writedata <= 32'h1;       end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                // Scaler ? 4 writes via unified mm_bridge
                // ==============================================================
                ST_CONFIG_SCL: begin
                    mm_write <= 1'b1;
                    if (mm_write && !mm_waitrequest) begin
                        if (cfg_step == 4'd3) begin
                            mm_write      <= 1'b0;
                            cfg_step      <= 4'd0;
                            mm_address    <= CRS_BASE | CRS_OUT_MODE;
                            mm_writedata  <= CRS_OUTPUT_MODE;
                            current_state <= ST_CONFIG_CRS;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin mm_address <= SCL_BASE | SCL_IN_HEIGHT;  mm_writedata <= SCALER_IN_H;  end
                                4'd2: begin mm_address <= SCL_BASE | SCL_OUT_WIDTH;  mm_writedata <= SCALER_OUT_W; end
                                4'd3: begin mm_address <= SCL_BASE | SCL_OUT_HEIGHT; mm_writedata <= SCALER_OUT_H; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                // CRS ? 2 writes via unified mm_bridge
                // ==============================================================
                ST_CONFIG_CRS: begin
                    mm_write <= 1'b1;
                    if (mm_write && !mm_waitrequest) begin
                        if (cfg_step == 4'd1) begin
                            mm_write      <= 1'b0;
                            cfg_step      <= 4'd0;
                            mm_address    <= CSC_BASE | CSC_COEFF_A0;
                            mm_writedata  <= csc_a0;
                            current_state <= ST_CONFIG_CSC;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin mm_address <= CRS_BASE | CRS_COMMIT; mm_writedata <= 32'h1; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                // CSC ? 14 writes via unified mm_bridge
                // ==============================================================
                ST_CONFIG_CSC: begin
                    mm_write <= 1'b1;
                    if (mm_write && !mm_waitrequest) begin
                        if (cfg_step == 4'd13) begin
                            mm_write      <= 1'b0;
                            cfg_step      <= 4'd0;
                            //current_state <= ST_POLL_CSC;
                               if (INPUT_SEL) begin
       			 pc1_addr      <= PC1_ADDR_WIDTH;
        			pc1_wdata     <= IMG_WIDTH;
        			current_state <= ST_CONFIG_PC1;
    				end else begin
        			current_state <= ST_POLL_CSC;
    				end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1:  begin mm_address <= CSC_BASE | CSC_COEFF_A1;   mm_writedata <= csc_a1;       end
                                4'd2:  begin mm_address <= CSC_BASE | CSC_COEFF_A2;   mm_writedata <= csc_a2;       end
                                4'd3:  begin mm_address <= CSC_BASE | CSC_COEFF_B0;   mm_writedata <= csc_b0;       end
                                4'd4:  begin mm_address <= CSC_BASE | CSC_COEFF_B1;   mm_writedata <= csc_b1;       end
                                4'd5:  begin mm_address <= CSC_BASE | CSC_COEFF_B2;   mm_writedata <= csc_b2;       end
                                4'd6:  begin mm_address <= CSC_BASE | CSC_COEFF_C0;   mm_writedata <= csc_c0;       end
                                4'd7:  begin mm_address <= CSC_BASE | CSC_COEFF_C1;   mm_writedata <= csc_c1;       end
                                4'd8:  begin mm_address <= CSC_BASE | CSC_COEFF_C2;   mm_writedata <= csc_c2;       end
                                4'd9:  begin mm_address <= CSC_BASE | CSC_SUMMAND_S0; mm_writedata <= csc_s0;       end
                                4'd10: begin mm_address <= CSC_BASE | CSC_SUMMAND_S1; mm_writedata <= csc_s1;       end
                                4'd11: begin mm_address <= CSC_BASE | CSC_SUMMAND_S2; mm_writedata <= csc_s2;       end
                                4'd12: begin mm_address <= CSC_BASE | CSC_OUT_CS;     mm_writedata <= csc_out_cs;   end
                                4'd13: begin mm_address <= CSC_BASE | CSC_COMMIT;     mm_writedata <= 32'hFFFFFFFF; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ==============================================================
                // Poll CSC STATUS bit[1] until 0 (commit absorbed)
                // ==============================================================
                ST_POLL_CSC: begin
                    if (cfg_step == 4'd0) begin
                        mm_read    <= 1'b1;
                        mm_address <= CSC_BASE | CSC_STATUS;
                        if (!mm_waitrequest) begin
                            mm_read  <= 1'b0;
                            cfg_step <= 4'd1;
                        end
                    end else begin
                        if (mm_readdatavalid) begin
                            cfg_step <= 4'd0;
                            if (mm_readdata[1] == 1'b0) begin
                                if (INPUT_SEL) begin
                                    pc1_addr      <= PC1_ADDR_WIDTH;
                                    pc1_wdata     <= IMG_WIDTH;
                                    current_state <= ST_CONFIG_PC1;
                                end else begin
                                    current_state <= ST_WORKING;
                                end
                            end
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
                    mm_write  <= 1'b0; mm_read   <= 1'b0;
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
    //wire ready_to_start = (current_state >= ST_CONFIG_CSC);
    wire ready_to_start = INPUT_SEL ? (current_state == ST_WORKING) : (current_state >= ST_CONFIG_CSC);
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
    // Pipeline instantiation ? identical to original top.v
    // =========================================================================
    pipeline u_pipeline (
        .clk_clk     (clk),
        .reset_reset (reset),

        .intel_vvp_tpg_0_axi4s_vid_out_tdata  (tpg_out_tdata),
        .intel_vvp_tpg_0_axi4s_vid_out_tvalid (tpg_out_tvalid),
        .intel_vvp_tpg_0_axi4s_vid_out_tready (tpg_out_tready),
        .intel_vvp_tpg_0_axi4s_vid_out_tlast  (tpg_out_tlast),
        .intel_vvp_tpg_0_axi4s_vid_out_tuser  (tpg_out_tuser),

        .intel_vvp_dil_0_axi4s_vid_in_tdata   (dil_in_tdata),
        .intel_vvp_dil_0_axi4s_vid_in_tvalid  (dil_in_tvalid),
        .intel_vvp_dil_0_axi4s_vid_in_tready  (dil_in_tready),
        .intel_vvp_dil_0_axi4s_vid_in_tlast   (dil_in_tlast),
        .intel_vvp_dil_0_axi4s_vid_in_tuser   (dil_in_tuser),

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

        // TPG Avalon-MM ? dedicated port
        .intel_vvp_tpg_0_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_0_av_mm_control_agent_write         (tpg_write),
        .intel_vvp_tpg_0_av_mm_control_agent_read          (tpg_read),
        .intel_vvp_tpg_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_0_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdata      (tpg_readdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdatavalid (tpg_readdatavalid),
        .intel_vvp_tpg_0_av_mm_control_agent_waitrequest   (tpg_wait),

        // Clipper Avalon-MM ? via mm_bridge
        .intel_vvp_clipper_0_av_mm_control_agent_address       (clip_address),
        .intel_vvp_clipper_0_av_mm_control_agent_write         (clip_write_w),
        .intel_vvp_clipper_0_av_mm_control_agent_read          (clip_read_w),
        .intel_vvp_clipper_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_clipper_0_av_mm_control_agent_writedata     (clip_writedata),
        .intel_vvp_clipper_0_av_mm_control_agent_readdata      (clip_readdata),
        .intel_vvp_clipper_0_av_mm_control_agent_readdatavalid (clip_readdatavalid),
        .intel_vvp_clipper_0_av_mm_control_agent_waitrequest   (clip_waitrequest),

        // CRS Avalon-MM ? via mm_bridge
        .intel_vvp_crs_0_av_mm_control_agent_address       (crs_address),
        .intel_vvp_crs_0_av_mm_control_agent_write         (crs_write_w),
        .intel_vvp_crs_0_av_mm_control_agent_read          (crs_read_w),
        .intel_vvp_crs_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_crs_0_av_mm_control_agent_writedata     (crs_writedata),
        .intel_vvp_crs_0_av_mm_control_agent_readdata      (crs_readdata),
        .intel_vvp_crs_0_av_mm_control_agent_readdatavalid (crs_readdatavalid),
        .intel_vvp_crs_0_av_mm_control_agent_waitrequest   (crs_waitrequest),

        // CSC Avalon-MM ? via mm_bridge
        .intel_vvp_csc_0_av_mm_control_agent_address       (csc_address),
        .intel_vvp_csc_0_av_mm_control_agent_write         (csc_write_w),
        .intel_vvp_csc_0_av_mm_control_agent_read          (csc_read_w),
        .intel_vvp_csc_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_csc_0_av_mm_control_agent_writedata     (csc_writedata),
        .intel_vvp_csc_0_av_mm_control_agent_readdata      (csc_readdata),
        .intel_vvp_csc_0_av_mm_control_agent_readdatavalid (csc_readdatavalid),
        .intel_vvp_csc_0_av_mm_control_agent_waitrequest   (csc_waitrequest),

        // Scaler Avalon-MM ? via mm_bridge
        .intel_vvp_scaler_0_av_mm_control_agent_address       (scl_address),
        .intel_vvp_scaler_0_av_mm_control_agent_write         (scl_write_w),
        .intel_vvp_scaler_0_av_mm_control_agent_read          (scl_read_w),
        .intel_vvp_scaler_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_scaler_0_av_mm_control_agent_writedata     (scl_writedata),
        .intel_vvp_scaler_0_av_mm_control_agent_readdata      (scl_readdata),
        .intel_vvp_scaler_0_av_mm_control_agent_readdatavalid (scl_readdatavalid),
        .intel_vvp_scaler_0_av_mm_control_agent_waitrequest   (scl_waitrequest),

        // PC1 Avalon-MM ? dedicated port
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
        .intel_vvp_protocol_conv_1_av_mm_control_agent_waitrequest   (pc1_wait)
    );

endmodule
