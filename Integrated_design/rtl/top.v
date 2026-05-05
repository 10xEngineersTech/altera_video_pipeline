`timescale 1 ps / 1 ps

module top #(
    // Pipeline configuration parameters
    parameter IMG_WIDTH      = 32'd32,
    parameter IMG_HIGHT      = 32'd32,
    parameter IMG_COLOR      = 32'd1, //color space
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
	 
	 localparam SCALER_IN_W  = IMG_WIDTH[31:0] - IMG_R_OFF[31:0] - IMG_L_OFF[31:0];
	 localparam SCALER_IN_H  = IMG_HIGHT[31:0] - IMG_T_OFF[31:0] - IMG_B_OFF[31:0];
    // --- State Machine States ---
    localparam STATE_CONFIG_CLIP   = 2'd0;
    localparam STATE_CONFIG_SCALER = 2'd1;
    localparam STATE_WORKING       = 2'd2;

    reg [1:0] current_state;
    reg [3:0] cfg_step;

    // --- Avalon-MM Register Addresses ---
    localparam CLIP_IN_WIDTH_ADDR  = 7'h48; 
    localparam CLIP_IN_HEIGHT_ADDR = 7'h49; 
    localparam CLIP_IN_COLOR_ADDR  = 7'h4C; 
    localparam CLIP_IN_SUBSAMPLING = 7'h4D; 
    localparam CLIP_COMMIT_ADDR    = 7'h51; 
    localparam CLIP_LEFT_OFF_ADDR  = 7'h52; 
    localparam CLIP_TOP_OFF_ADDR   = 7'h53; 
    localparam CLIP_RIGHT_OFF_ADDR = 7'h54; 
    localparam CLIP_BOT_OFF_ADDR   = 7'h55; 

    localparam SCL_IN_WIDTH_ADDR   = 7'h48;
    localparam SCL_IN_HEIGHT_ADDR  = 7'h49;
    localparam SCL_OUT_WIDTH_ADDR  = 7'h52;
    localparam SCL_OUT_HEIGHT_ADDR = 7'h53;

    // --- Internal AXI-Stream: TPG to Clipper ---
    wire [23:0] tpg_tdata;
    wire        tpg_tvalid;
    wire        tpg_tready;
    wire        tpg_tlast;
    wire [2:0]  tpg_tuser;

    // --- Avalon-MM Control Signals ---
    reg  [6:0]  clip_addr;
    reg         clip_write;
    reg  [31:0] clip_wdata;
    wire        clip_wait;

    reg  [6:0]  scl_addr;
    reg         scl_write;
    reg  [31:0] scl_wdata;
    wire        scl_wait;

    // -------------------------------------------------------------------------
    // Configuration State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= STATE_CONFIG_CLIP;
            cfg_step      <= 4'd0;
            clip_write    <= 1'b0;
            scl_write     <= 1'b0;
            clip_addr     <= 7'h0;
            scl_addr      <= 7'h0;
        end else begin
            case (current_state)
                
                STATE_CONFIG_CLIP: begin
                    case (cfg_step)
                        4'd0: begin clip_write <= 1'b1; clip_addr <= CLIP_IN_HEIGHT_ADDR[6:0]; clip_wdata <= IMG_WIDTH[31:0]; if(!clip_wait) cfg_step <= 4'd1; end
								4'd1: begin clip_write <= 1'b1; clip_addr <= CLIP_IN_WIDTH_ADDR[6:0];  clip_wdata <= IMG_HIGHT[31:0]; if(!clip_wait) cfg_step <= 4'd2; end
                        4'd2: begin clip_write <= 1'b1; clip_addr <= CLIP_IN_COLOR_ADDR[6:0];  clip_wdata <= IMG_COLOR[31:0]; if(!clip_wait) cfg_step <= 4'd3; end
                        4'd3: begin clip_write <= 1'b1; clip_addr <= CLIP_IN_SUBSAMPLING[6:0]; clip_wdata <= IMG_CR_SM[31:0]; if(!clip_wait) cfg_step <= 4'd4; end
                        4'd4: begin clip_write <= 1'b1; clip_addr <= CLIP_LEFT_OFF_ADDR[6:0];  clip_wdata <= IMG_L_OFF[31:0]; if(!clip_wait) cfg_step <= 4'd5; end
                        4'd5: begin clip_write <= 1'b1; clip_addr <= CLIP_TOP_OFF_ADDR[6:0];   clip_wdata <= IMG_T_OFF[31:0]; if(!clip_wait) cfg_step <= 4'd6; end
                        4'd6: begin clip_write <= 1'b1; clip_addr <= CLIP_RIGHT_OFF_ADDR[6:0]; clip_wdata <= IMG_R_OFF[31:0]; if(!clip_wait) cfg_step <= 4'd7; end
                        4'd7: begin clip_write <= 1'b1; clip_addr <= CLIP_BOT_OFF_ADDR[6:0];   clip_wdata <= IMG_B_OFF[31:0]; if(!clip_wait) cfg_step <= 4'd8; end
                        4'd8: begin 
                            clip_write <= 1'b1; clip_addr <= CLIP_COMMIT_ADDR; clip_wdata <= 32'h1; 
                            if(!clip_wait) begin
                                clip_write    <= 1'b0;
                                cfg_step      <= 4'd0;
                                current_state <= STATE_CONFIG_SCALER;
                            end
                        end
                    endcase
                end

                STATE_CONFIG_SCALER: begin
                    case (cfg_step)
                        // Input to scaler is the output of the clipper (Original - Offsets)
								4'd0: begin scl_write <= 1'b1; scl_addr <= SCL_IN_WIDTH_ADDR[6:0];   scl_wdata <= SCALER_IN_W[31:0]; if(!scl_wait) cfg_step <= 4'd1; end
                        4'd1: begin scl_write <= 1'b1; scl_addr <= SCL_IN_HEIGHT_ADDR[6:0];  scl_wdata <= SCALER_IN_H[31:0]; if(!scl_wait) cfg_step <= 4'd2; end
                        4'd2: begin scl_write <= 1'b1; scl_addr <= SCL_OUT_WIDTH_ADDR[6:0];  scl_wdata <= SCALER_OUT_W[31:0]; if(!scl_wait) cfg_step <= 4'd3; end
                        4'd3: begin scl_write <= 1'b1; scl_addr <= SCL_OUT_HEIGHT_ADDR[6:0]; scl_wdata <= SCALER_OUT_H[31:0];
                            if(!scl_wait) begin
                                scl_write     <= 1'b0;
                                cfg_step      <= 4'd0;
										  current_state <= STATE_WORKING;
                            end
                        end
                    endcase
                end

                STATE_WORKING: begin
                    clip_write <= 1'b0;
                    scl_write  <= 1'b0;
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // AXI-Stream Gating: Only flow when configuration is complete
    // -------------------------------------------------------------------------
    wire ready_to_start = (current_state == STATE_WORKING);

    wire gated_clipper_ready; 
    wire tpg_to_clipper_valid = tpg_tvalid && ready_to_start;

    // -------------------------------------------------------------------------
    // System Pipeline Instance
    // -------------------------------------------------------------------------
    pipeline u_pipeline_inst (
        .clk_clk                                       (clk),
        .reset_reset                                   (reset),

        // 1. Internal TPG Output
        .intel_vvp_tpg_0_axi4s_vid_out_tdata           (tpg_tdata),
        .intel_vvp_tpg_0_axi4s_vid_out_tvalid          (tpg_tvalid),
        .intel_vvp_tpg_0_axi4s_vid_out_tready          (tpg_tready),
        .intel_vvp_tpg_0_axi4s_vid_out_tlast           (tpg_tlast),
        .intel_vvp_tpg_0_axi4s_vid_out_tuser           (tpg_tuser),

        // 2. Clipper Input (Connected to TPG with gating)
        .intel_vvp_clipper_0_axi4s_vid_in_tdata        (tpg_tdata),
        .intel_vvp_clipper_0_axi4s_vid_in_tvalid       (tpg_to_clipper_valid),
        .intel_vvp_clipper_0_axi4s_vid_in_tready       (gated_clipper_ready),
        .intel_vvp_clipper_0_axi4s_vid_in_tlast        (tpg_tlast),
        .intel_vvp_clipper_0_axi4s_vid_in_tuser        (tpg_tuser),

        // 3. Clipper Control Agent
        .intel_vvp_clipper_0_av_mm_control_agent_address       (clip_addr),
        .intel_vvp_clipper_0_av_mm_control_agent_write         (clip_write),
        .intel_vvp_clipper_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_clipper_0_av_mm_control_agent_writedata     (clip_wdata),
        .intel_vvp_clipper_0_av_mm_control_agent_read          (1'b0),
        .intel_vvp_clipper_0_av_mm_control_agent_readdata      (),
        .intel_vvp_clipper_0_av_mm_control_agent_readdatavalid (),
        .intel_vvp_clipper_0_av_mm_control_agent_waitrequest   (clip_wait),

        // 4. Scaler Control Agent
        .intel_vvp_scaler_0_av_mm_control_agent_address        (scl_addr),
        .intel_vvp_scaler_0_av_mm_control_agent_write          (scl_write),
        .intel_vvp_scaler_0_av_mm_control_agent_byteenable     (4'hF),
        .intel_vvp_scaler_0_av_mm_control_agent_writedata      (scl_wdata),
        .intel_vvp_scaler_0_av_mm_control_agent_read           (1'b0),
        .intel_vvp_scaler_0_av_mm_control_agent_readdata       (),
        .intel_vvp_scaler_0_av_mm_control_agent_readdatavalid  (),
        .intel_vvp_scaler_0_av_mm_control_agent_waitrequest    (scl_wait),

        // 5. External Scaler Output (Module Ports)
        .intel_vvp_scaler_0_axi4s_vid_out_tdata        (out_tdata),
        .intel_vvp_scaler_0_axi4s_vid_out_tvalid       (out_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_out_tready       (out_tready),
        .intel_vvp_scaler_0_axi4s_vid_out_tlast        (out_tlast),
        .intel_vvp_scaler_0_axi4s_vid_out_tuser        (out_tuser)
    );

    // Provide backpressure to TPG if pipeline is not ready or config is not done
    assign tpg_tready = gated_clipper_ready && ready_to_start;

endmodule
