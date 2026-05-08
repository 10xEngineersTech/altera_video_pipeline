`timescale 1 ps / 1 ps

module top #(
    // Pipeline configuration parameters
    parameter IMG_WIDTH      = 32'd32,
    parameter IMG_HIGHT      = 32'd32,
    parameter IMG_COLOR      = 32'd1, // color space
    parameter IMG_CR_SM      = 32'd3, // chroma sampling     
    parameter IMG_L_OFF      = 32'd4,
    parameter IMG_T_OFF      = 32'd4,
    parameter IMG_R_OFF      = 32'd4,
    parameter IMG_B_OFF      = 32'd4,
    
    parameter SCALER_OUT_W   = 32'd8,
    parameter SCALER_OUT_H   = 32'd8
)(
    input  wire        clk,
    input  wire        reset,

    // Final Pipeline Output (Scaler Output)
    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser
);
    
    // --- Constant Calculations ---
    localparam SCALER_IN_W  = IMG_WIDTH - IMG_R_OFF - IMG_L_OFF;
    localparam SCALER_IN_H  = IMG_HIGHT - IMG_T_OFF - IMG_B_OFF;

    // --- State Machine States (TPG + Clipper + Scaler) ---
    localparam [3:0]
        ST_IDLE          = 4'd0,
        ST_TPG_CTRL_1    = 4'd1,
        ST_TPG_WR_INTL   = 4'd2,
        ST_TPG_WR_W      = 4'd3,
        ST_TPG_WR_H      = 4'd4,
        ST_TPG_WR_PAT_T  = 4'd5,
        ST_TPG_WR_PAT_S  = 4'd6,
        ST_TPG_WR_CMT    = 4'd7,
        ST_TPG_CTRL_2    = 4'd8,
        ST_TPG_POLL_ISS  = 4'd9,
        ST_TPG_POLL_W    = 4'd10,
        ST_TPG_IP_RST    = 4'd11,
        ST_TPG_CTRL_3    = 4'd12,
        ST_CONFIG_CLIP   = 4'd13,
        ST_CONFIG_SCL    = 4'd14,
        ST_WORKING       = 4'd15;

    // --- Register Addresses ---
    // TPG
    localparam [6:0] TPG_ADDR_WIDTH      = 7'h48;
    localparam [6:0] TPG_ADDR_HEIGHT     = 7'h49;
    localparam [6:0] TPG_ADDR_INTERLACE  = 7'h4A;
    localparam [6:0] TPG_ADDR_STATUS     = 7'h50;
    localparam [6:0] TPG_ADDR_CONTROL    = 7'h52;
    localparam [6:0] TPG_ADDR_COMMIT     = 7'h53;
    localparam [6:0] TPG_ADDR_PATTERN    = 7'h54;
    localparam [6:0] TPG_ADDR_BAR_SEL    = 7'h5A;

    // Clipper
    localparam [6:0] CLIP_IN_WIDTH_ADDR  = 7'h48; 
    localparam [6:0] CLIP_IN_HEIGHT_ADDR = 7'h49; 
    localparam [6:0] CLIP_IN_COLOR_ADDR  = 7'h4C; 
    localparam [6:0] CLIP_IN_SUBSAMPLING = 7'h4D; 
    localparam [6:0] CLIP_COMMIT_ADDR    = 7'h51; 
    localparam [6:0] CLIP_LEFT_OFF_ADDR  = 7'h52; 
    localparam [6:0] CLIP_TOP_OFF_ADDR   = 7'h53; 
    localparam [6:0] CLIP_RIGHT_OFF_ADDR = 7'h54; 
    localparam [6:0] CLIP_BOT_OFF_ADDR   = 7'h55; 

    // Scaler
    localparam [6:0] SCL_IN_WIDTH_ADDR   = 7'h48;
    localparam [6:0] SCL_IN_HEIGHT_ADDR  = 7'h49;
    localparam [6:0] SCL_OUT_WIDTH_ADDR  = 7'h52;
    localparam [6:0] SCL_OUT_HEIGHT_ADDR = 7'h53;

    // --- Internal Registers ---
    reg [3:0]  current_state;
    reg [3:0]  cfg_step;
    reg [7:0]  cycle_count;
    reg [6:0]  mm_addr;
    reg        mm_write, mm_read;
    reg [31:0] mm_wdata;

    // --- Internal Signals ---
    wire [31:0] tpg_readdata;
    wire        tpg_readdatavalid;
    wire        tpg_wait, clip_wait, scl_wait;

    // --- AXI-Stream Internal Connections ---
    wire [15:0] tpg_tdata; wire tpg_tvalid, tpg_tready, tpg_tlast; wire [1:0] tpg_tuser;
    wire [23:0] dil_tdata; wire dil_tvalid, dil_tready, dil_tlast; wire [2:0] dil_tuser;
    wire [23:0] crs_tdata; wire crs_tvalid, crs_tready, crs_tlast; wire [2:0] crs_tuser;
    wire dil_in_ready, crs_in_ready, gated_clipper_ready;

    // -------------------------------------------------------------------------
    // Integrated Control State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            mm_write      <= 1'b0;
            mm_read       <= 1'b0;
            cfg_step      <= 4'd0;
            cycle_count   <= 8'h0;
        end else begin
            case (current_state)
                ST_IDLE: current_state <= ST_TPG_CTRL_1;

                // TPG Sequence
                ST_TPG_CTRL_1: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_CONTROL; mm_wdata <= 32'h0;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_TPG_WR_INTL; end
                end
                ST_TPG_WR_INTL: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_INTERLACE; mm_wdata <= 32'h0;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_TPG_WR_W; end
                end
                ST_TPG_WR_W: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_WIDTH; mm_wdata <= IMG_WIDTH;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_TPG_WR_H; end
                end
                ST_TPG_WR_H: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_HEIGHT; mm_wdata <= IMG_HIGHT;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_TPG_WR_PAT_T; end
                end
                ST_TPG_WR_PAT_T: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_BAR_SEL; mm_wdata <= 32'h0;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_TPG_WR_PAT_S; end
                end
                ST_TPG_WR_PAT_S: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_PATTERN; mm_wdata <= 32'd0;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_TPG_WR_CMT; end
                end
                ST_TPG_WR_CMT: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_COMMIT; mm_wdata <= 32'h1;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_TPG_CTRL_2; end
                end
                ST_TPG_CTRL_2: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_CONTROL; mm_wdata <= 32'h1;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_TPG_POLL_ISS; end
                end
                ST_TPG_POLL_ISS: begin
                    mm_read <= 1'b1; mm_addr <= TPG_ADDR_STATUS;
                    if (!tpg_wait) begin mm_read <= 1'b0; current_state <= ST_TPG_POLL_W; end
                end
                ST_TPG_POLL_W: begin
                    if (tpg_readdatavalid) begin
                        if (tpg_readdata[1] == 1'b0) current_state <= ST_TPG_IP_RST;
                        else current_state <= ST_TPG_POLL_ISS;
                    end
                end
                ST_TPG_IP_RST: begin
                    cycle_count <= cycle_count + 1'b1;
                    if (cycle_count == 8'h07) current_state <= ST_TPG_CTRL_3;
                end
                ST_TPG_CTRL_3: begin
                    mm_write <= 1'b1; mm_addr <= TPG_ADDR_CONTROL; mm_wdata <= 32'h1;
                    if (!tpg_wait) begin mm_write <= 1'b0; current_state <= ST_CONFIG_CLIP; cfg_step <= 4'd0; end
                end

                // Clipper Sequence
                ST_CONFIG_CLIP: begin
                    case (cfg_step)
                        4'd0: begin mm_write <= 1'b1; mm_addr <= CLIP_IN_HEIGHT_ADDR; mm_wdata <= IMG_HIGHT; if(!clip_wait) cfg_step <= 4'd1; end
                        4'd1: begin mm_write <= 1'b1; mm_addr <= CLIP_IN_WIDTH_ADDR;  mm_wdata <= IMG_WIDTH; if(!clip_wait) cfg_step <= 4'd2; end
                        4'd2: begin mm_write <= 1'b1; mm_addr <= CLIP_IN_COLOR_ADDR;  mm_wdata <= IMG_COLOR; if(!clip_wait) cfg_step <= 4'd3; end
                        4'd3: begin mm_write <= 1'b1; mm_addr <= CLIP_IN_SUBSAMPLING; mm_wdata <= IMG_CR_SM; if(!clip_wait) cfg_step <= 4'd4; end
                        4'd4: begin mm_write <= 1'b1; mm_addr <= CLIP_LEFT_OFF_ADDR;  mm_wdata <= IMG_L_OFF; if(!clip_wait) cfg_step <= 4'd5; end
                        4'd5: begin mm_write <= 1'b1; mm_addr <= CLIP_TOP_OFF_ADDR;   mm_wdata <= IMG_T_OFF; if(!clip_wait) cfg_step <= 4'd6; end
                        4'd6: begin mm_write <= 1'b1; mm_addr <= CLIP_RIGHT_OFF_ADDR; mm_wdata <= IMG_R_OFF; if(!clip_wait) cfg_step <= 4'd7; end
                        4'd7: begin mm_write <= 1'b1; mm_addr <= CLIP_BOT_OFF_ADDR;   mm_wdata <= IMG_B_OFF; if(!clip_wait) cfg_step <= 4'd8; end
                        4'd8: begin mm_write <= 1'b1; mm_addr <= CLIP_COMMIT_ADDR;    mm_wdata <= 32'h1; 
                              if(!clip_wait) begin mm_write <= 1'b0; cfg_step <= 4'd0; current_state <= ST_CONFIG_SCL; end end
                    endcase
                end

                // Scaler Sequence
                ST_CONFIG_SCL: begin
                    case (cfg_step)
                        4'd0: begin mm_write <= 1'b1; mm_addr <= SCL_IN_WIDTH_ADDR;   mm_wdata <= SCALER_IN_W;  if(!scl_wait) cfg_step <= 4'd1; end
                        4'd1: begin mm_write <= 1'b1; mm_addr <= SCL_IN_HEIGHT_ADDR;  mm_wdata <= SCALER_IN_H;  if(!scl_wait) cfg_step <= 4'd2; end
                        4'd2: begin mm_write <= 1'b1; mm_addr <= SCL_OUT_WIDTH_ADDR;  mm_wdata <= SCALER_OUT_W; if(!scl_wait) cfg_step <= 4'd3; end
                        4'd3: begin mm_write <= 1'b1; mm_addr <= SCL_OUT_HEIGHT_ADDR; mm_wdata <= SCALER_OUT_H; 
                              if(!scl_wait) begin mm_write <= 1'b0; cfg_step <= 4'd0; current_state <= ST_WORKING; end end
                    endcase
                end

                ST_WORKING: begin mm_write <= 1'b0; mm_read <= 1'b0; end
            endcase
        end
    end

    // --- Pipeline Gating Logic ---
    wire ready_to_start = (current_state == ST_WORKING);

    // --- Pipeline Instantiation ---
    pipeline u_pipeline_inst (
        .clk_clk                                               (clk),
        .reset_reset                                           (reset),

        // TPG Control & Data
        .intel_vvp_tpg_0_av_mm_control_agent_address           (mm_addr),
        .intel_vvp_tpg_0_av_mm_control_agent_write             (mm_write && (current_state <= ST_TPG_CTRL_3)),
        .intel_vvp_tpg_0_av_mm_control_agent_read              (mm_read),
        .intel_vvp_tpg_0_av_mm_control_agent_byteenable        (4'hF),
        .intel_vvp_tpg_0_av_mm_control_agent_writedata         (mm_wdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdata          (tpg_readdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdatavalid     (tpg_readdatavalid),
        .intel_vvp_tpg_0_av_mm_control_agent_waitrequest       (tpg_wait),
        
        .intel_vvp_tpg_0_axi4s_vid_out_tdata                   (tpg_tdata),
        .intel_vvp_tpg_0_axi4s_vid_out_tvalid                  (tpg_tvalid),
        .intel_vvp_tpg_0_axi4s_vid_out_tready                  (tpg_tready),
        .intel_vvp_tpg_0_axi4s_vid_out_tlast                   (tpg_tlast),
        .intel_vvp_tpg_0_axi4s_vid_out_tuser                   (tpg_tuser),

        // DIL
        .intel_vvp_dil_0_axi4s_vid_in_tdata                    ({8'h0, tpg_tdata}),
        .intel_vvp_dil_0_axi4s_vid_in_tvalid                   (tpg_tvalid && ready_to_start),
        .intel_vvp_dil_0_axi4s_vid_in_tready                   (dil_in_ready),
        .intel_vvp_dil_0_axi4s_vid_in_tlast                    (tpg_tlast),
        .intel_vvp_dil_0_axi4s_vid_in_tuser                    ({1'b0, tpg_tuser}),
        .intel_vvp_dil_0_axi4s_vid_out_tdata                   (dil_tdata),
        .intel_vvp_dil_0_axi4s_vid_out_tvalid                  (dil_tvalid),
        .intel_vvp_dil_0_axi4s_vid_out_tready                  (dil_tready),
        .intel_vvp_dil_0_axi4s_vid_out_tlast                   (dil_tlast),
        .intel_vvp_dil_0_axi4s_vid_out_tuser                   (dil_tuser),

        // CRS
        .intel_vvp_crs_0_axi4s_vid_in_tdata                    (dil_tdata[15:0]),
        .intel_vvp_crs_0_axi4s_vid_in_tvalid                   (dil_tvalid),
        .intel_vvp_crs_0_axi4s_vid_in_tready                   (crs_in_ready),
        .intel_vvp_crs_0_axi4s_vid_in_tlast                    (dil_tlast),
        .intel_vvp_crs_0_axi4s_vid_in_tuser                    (dil_tuser[1:0]),
        .intel_vvp_crs_0_axi4s_vid_out_tdata                   (crs_tdata),
        .intel_vvp_crs_0_axi4s_vid_out_tvalid                  (crs_tvalid),
        .intel_vvp_crs_0_axi4s_vid_out_tready                  (crs_tready),
        .intel_vvp_crs_0_axi4s_vid_out_tlast                   (crs_tlast),
        .intel_vvp_crs_0_axi4s_vid_out_tuser                   (crs_tuser),

        // Clipper
        .intel_vvp_clipper_0_axi4s_vid_in_tdata                (crs_tdata),
        .intel_vvp_clipper_0_axi4s_vid_in_tvalid               (crs_tvalid),
        .intel_vvp_clipper_0_axi4s_vid_in_tready               (gated_clipper_ready),
        .intel_vvp_clipper_0_axi4s_vid_in_tlast                (crs_tlast),
        .intel_vvp_clipper_0_axi4s_vid_in_tuser                (crs_tuser),
        .intel_vvp_clipper_0_av_mm_control_agent_address       (mm_addr),
        .intel_vvp_clipper_0_av_mm_control_agent_write         (mm_write && (current_state == ST_CONFIG_CLIP)),
        .intel_vvp_clipper_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_clipper_0_av_mm_control_agent_writedata     (mm_wdata),
        .intel_vvp_clipper_0_av_mm_control_agent_read          (1'b0),
        .intel_vvp_clipper_0_av_mm_control_agent_waitrequest   (clip_wait),

        // Scaler
        .intel_vvp_scaler_0_axi4s_vid_out_tdata                (out_tdata),
        .intel_vvp_scaler_0_axi4s_vid_out_tvalid               (out_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_out_tready               (out_tready),
        .intel_vvp_scaler_0_axi4s_vid_out_tlast                (out_tlast),
        .intel_vvp_scaler_0_axi4s_vid_out_tuser                (out_tuser),
        .intel_vvp_scaler_0_av_mm_control_agent_address        (mm_addr),
        .intel_vvp_scaler_0_av_mm_control_agent_write         (mm_write && (current_state == ST_CONFIG_SCL)),
        .intel_vvp_scaler_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_scaler_0_av_mm_control_agent_writedata     (mm_wdata),
        .intel_vvp_scaler_0_av_mm_control_agent_read          (1'b0),
        .intel_vvp_scaler_0_av_mm_control_agent_waitrequest   (scl_wait)
    );

    // Backpressure logic
    assign tpg_tready = dil_in_ready && ready_to_start;
    assign dil_tready = crs_in_ready;
    assign crs_tready = gated_clipper_ready;

endmodule