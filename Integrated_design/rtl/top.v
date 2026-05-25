`timescale 1 ps / 1 ps

// =============================================================================
// top.v ? Image Input Mode (PC1: AXI4-S Lite ? Full ? Scaler)
//
// Platform Designer (pipeline.qsys):
//   - PC1: Altera SV Lite input, Full output
//   - PC1.axi4s_vid_out ? pipeline2_0.s_axis_video_in (internal)
//   - pipeline2_0: Input protocol = Altera SV Full
//
// Exported ports:
//   clk, reset
//   s0_*                  ? scaler MM bridge
//   axi4s_vid_in_*        ? PC1 AXI4-S Lite video input
//   av_mm_control_agent_* ? PC1 MM control
//   m_axis_video_out_*    ? scaler output
//
// MM bridge address map:
//   SCL ? 0x800?0x9FF
//
// PC1 MM registers (word addressed, Lite input mode):
//   0x48 IMG_INFO_WIDTH
//   0x49 IMG_INFO_HEIGHT
//   0x4A IMG_INFO_INTERLACE
//   0x4C IMG_INFO_COLORSPACE
//   0x4D IMG_INFO_SUBSAMPLING
//   0x55 CTRL (bit0=start)
// =============================================================================

module top #(
    parameter [31:0] IMG_WIDTH    = 32'd640,
    parameter [31:0] IMG_HEIGHT   = 32'd480,
    parameter [31:0] SCALER_OUT_W = 32'd64,
    parameter [31:0] SCALER_OUT_H = 32'd48
)(
    input  wire        clk,
    input  wire        reset,

    // Scaler output
    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser,

    // AXI4-S Lite video input (from image player in tb)
    input  wire [23:0] img_tdata,
    input  wire        img_tvalid,
    output wire        img_tready,
    input  wire        img_tlast,
    input  wire [2:0]  img_tuser
);

    // =========================================================================
    // MM bridge scaler addresses (byte addressed)
    // =========================================================================
    localparam [11:0] SCL_BASE       = 12'h800;
    localparam [11:0] SCL_IN_WIDTH   = SCL_BASE | 12'h120;
    localparam [11:0] SCL_IN_HEIGHT  = SCL_BASE | 12'h124;
    localparam [11:0] SCL_OUT_WIDTH  = SCL_BASE | 12'h148;
    localparam [11:0] SCL_OUT_HEIGHT = SCL_BASE | 12'h14C;

    // PC1 MM registers (7-bit word addressed)
    localparam [6:0] PC1_ADDR_WIDTH       = 7'h48;
    localparam [6:0] PC1_ADDR_HEIGHT      = 7'h49;
    localparam [6:0] PC1_ADDR_INTERLACE   = 7'h4A;
    localparam [6:0] PC1_ADDR_COLORSPACE  = 7'h4C;
    localparam [6:0] PC1_ADDR_SUBSAMPLING = 7'h4D;
    localparam [6:0] PC1_ADDR_CTRL        = 7'h55;

    // =========================================================================
    // State encoding
    // =========================================================================
    localparam [3:0]
        ST_IDLE    = 4'd0,
        ST_CFG_SCL = 4'd1,
        ST_CFG_PC1 = 4'd2,
        ST_WORKING = 4'd3;

    // =========================================================================
    // Registers
    // =========================================================================
    reg [3:0]  current_state;
    reg [3:0]  cfg_step;

    // Scaler MM bridge
    reg [11:0] bridge_addr;
    reg [31:0] bridge_wdata;
    reg        bridge_write;
    wire       bridge_wait;
    wire [31:0] bridge_readdata;
    wire        bridge_readdatavalid;

    // PC1 MM control
    reg [6:0]  pc1_addr;
    reg [31:0] pc1_wdata;
    reg        pc1_write;
    wire       pc1_wait;
    wire [31:0] pc1_readdata;
    wire        pc1_readdatavalid;

    // =========================================================================
    // FSM
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            bridge_write  <= 1'b0;
            pc1_write     <= 1'b0;
            cfg_step      <= 4'd0;
        end else begin
            case (current_state)

                // ?? Preload scaler step 0 ????????????????????????????????????
                ST_IDLE: begin
                    cfg_step     <= 4'd0;
                    bridge_addr  <= SCL_IN_WIDTH;
                    bridge_wdata <= IMG_WIDTH;
                    current_state <= ST_CFG_SCL;
                end

                // ?? Configure Scaler (4 writes) ??????????????????????????????
                ST_CFG_SCL: begin
                    bridge_write <= 1'b1;
                    if (bridge_write && !bridge_wait) begin
                        if (cfg_step == 4'd3) begin
                            bridge_write  <= 1'b0;
                            cfg_step      <= 4'd0;
                            pc1_addr      <= PC1_ADDR_WIDTH;
                            pc1_wdata     <= IMG_WIDTH;
                            current_state <= ST_CFG_PC1;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                            case (cfg_step + 1'b1)
                                4'd1: begin bridge_addr <= SCL_IN_HEIGHT;  bridge_wdata <= IMG_HEIGHT;   end
                                4'd2: begin bridge_addr <= SCL_OUT_WIDTH;  bridge_wdata <= SCALER_OUT_W; end
                                4'd3: begin bridge_addr <= SCL_OUT_HEIGHT; bridge_wdata <= SCALER_OUT_H; end
                                default: ;
                            endcase
                        end
                    end
                end

                // ?? Configure PC1 (6 writes) ?????????????????????????????????
                // Step 0: WIDTH
                // Step 1: HEIGHT
                // Step 2: INTERLACE = 0 (progressive)
                // Step 3: COLORSPACE = 0 (RGB)
                // Step 4: SUBSAMPLING = 3 (4:4:4)
                // Step 5: CTRL = 1 (start)
                ST_CFG_PC1: begin
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

                // ?? Working ??????????????????????????????????????????????????
                ST_WORKING: begin
                    bridge_write <= 1'b0;
                    pc1_write    <= 1'b0;
                end

                default: current_state <= ST_IDLE;

            endcase
        end
    end

    wire ready_to_start = (current_state == ST_WORKING);

    // =========================================================================
    // Platform Designer instantiation
    // =========================================================================
    pipeline u0 (
        .clk_clk    (clk),
        .reset_reset(reset),

        // Scaler MM bridge
        .s0_address       (bridge_addr),
        .s0_write         (bridge_write),
        .s0_read          (1'b0),
        .s0_byteenable    (4'hF),
        .s0_burstcount    (1'b1),
        .s0_debugaccess   (1'b0),
        .s0_writedata     (bridge_wdata),
        .s0_readdata      (bridge_readdata),
        .s0_readdatavalid (bridge_readdatavalid),
        .s0_waitrequest   (bridge_wait),

        // Scaler video output
        .m_axis_video_out_tdata  (out_tdata),
        .m_axis_video_out_tvalid (out_tvalid),
        .m_axis_video_out_tready (out_tready),
        .m_axis_video_out_tlast  (out_tlast),
        .m_axis_video_out_tuser  (out_tuser),

        // PC1 AXI4-S Lite video input
        .axi4s_vid_in_tdata  (img_tdata),
        .axi4s_vid_in_tvalid (img_tvalid & ready_to_start),
        .axi4s_vid_in_tready (img_tready),
        .axi4s_vid_in_tlast  (img_tlast),
        .axi4s_vid_in_tuser  (img_tuser),

        // PC1 MM control
        .av_mm_control_agent_address       (pc1_addr),
        .av_mm_control_agent_write         (pc1_write),
        .av_mm_control_agent_read          (1'b0),
        .av_mm_control_agent_byteenable    (4'hF),
        .av_mm_control_agent_writedata     (pc1_wdata),
        .av_mm_control_agent_readdata      (pc1_readdata),
        .av_mm_control_agent_readdatavalid (pc1_readdatavalid),
        .av_mm_control_agent_waitrequest   (pc1_wait)
    );

endmodule
