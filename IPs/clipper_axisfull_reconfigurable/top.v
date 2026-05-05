`timescale 1 ps / 1 ps

module clipper_wrapper (
    input  wire        clk,
    input  wire        reset,
    
    // AXI4-Stream Video Output
    output wire [23:0] axi_st_out_tdata,
    output wire        axi_st_out_tvalid,
    input  wire        axi_st_out_tready,
    output wire        axi_st_out_tlast,
    output wire [2:0]  axi_st_out_tuser
);

    // -------------------------------------------------------------------------
    // State Machine & Control Signals
    // -------------------------------------------------------------------------
    localparam STATE_CONFIG  = 2'd0;
    localparam STATE_VERIFY  = 2'd1;
    localparam STATE_WORKING = 2'd2;

    reg [1:0]  current_state;
    reg [3:0]  cfg_step;

    // Register Addresses (Byte Addr >> 2)
    localparam CLIP_IN_WIDTH_ADDR  = 7'h48; // 0x120
    localparam CLIP_IN_HEIGHT_ADDR = 7'h49; // 0x124
    localparam CLIP_IN_COLOR_ADDR  = 7'h4C; // 0x130
    localparam CLIP_IN_SUBSAMPLING = 7'h4D; // 0x134
    localparam CLIP_COMMIT_ADDR    = 7'h51; // 0x144
    localparam CLIP_LEFT_OFF_ADDR  = 7'h52; // 0x148
    localparam CLIP_TOP_OFF_ADDR   = 7'h53; // 0x14C
    localparam CLIP_RIGHT_OFF_ADDR = 7'h54; // 0x150
    localparam CLIP_BOT_OFF_ADDR   = 7'h55; // 0x154

    // Avalon-MM Control Signals
    reg [6:0]   clip_av_addr;
    reg         clip_av_write;
    reg         clip_av_read;
    reg [31:0]  clip_av_wdata;
    wire [31:0] clip_av_readdata;
    wire        clip_av_wait;
    
    // Signal to help monitor read results in simulation
    reg [31:0]  read_val_reg;

    // -------------------------------------------------------------------------
    // Configuration & Verification Logic
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= STATE_CONFIG;
            cfg_step      <= 4'd0;
            clip_av_write <= 1'b0;
            clip_av_read  <= 1'b0;
            clip_av_addr  <= 7'h0;
            clip_av_wdata <= 32'h0;
            read_val_reg  <= 32'h0;
        end else begin
            case (current_state)
                // --- STEP 1: WRITE OFFSETS AND COMMIT ---
                STATE_CONFIG: begin
                    clip_av_read <= 1'b0;
                    case (cfg_step)
                        4'd0: begin // Write Left Offset
                            clip_av_write <= 1'b1; clip_av_addr <= CLIP_LEFT_OFF_ADDR; clip_av_wdata <= 32'd4;
                            if (!clip_av_wait) cfg_step <= 4'd1;
                        end
                        4'd1: begin // Write Top Offset
                            clip_av_write <= 1'b1; clip_av_addr <= CLIP_TOP_OFF_ADDR; clip_av_wdata <= 32'd4;
                            if (!clip_av_wait) cfg_step <= 4'd2;
                        end
                        4'd2: begin // Write Right Offset
                            clip_av_write <= 1'b1; clip_av_addr <= CLIP_RIGHT_OFF_ADDR; clip_av_wdata <= 32'd4;
                            if (!clip_av_wait) cfg_step <= 4'd3;
                        end
                        4'd3: begin // Write Bottom Offset
                            clip_av_write <= 1'b1; clip_av_addr <= CLIP_BOT_OFF_ADDR; clip_av_wdata <= 32'd4;
                            if (!clip_av_wait) cfg_step <= 4'd4;
                        end
                        4'd4: begin // Commit Changes
                            clip_av_write <= 1'b1; clip_av_addr <= CLIP_COMMIT_ADDR; clip_av_wdata <= 32'h1;
                            if (!clip_av_wait) begin
                                clip_av_write <= 1'b0;
                                cfg_step      <= 4'd0; // Reset step for Read phase
                                current_state <= STATE_VERIFY;
                            end
                        end
                    endcase
                end

                // --- STEP 2: READ ALL REGS (INPUT PARAMS + OFFSETS) ---
                STATE_VERIFY: begin
                    clip_av_write <= 1'b0;
                    clip_av_read  <= 1'b1;
                    case (cfg_step)
                        4'd0: begin // Read Input Width
                            clip_av_addr <= CLIP_IN_WIDTH_ADDR;
                            if (!clip_av_wait) begin read_val_reg <= clip_av_readdata; cfg_step <= 4'd1; end
                        end
                        4'd1: begin // Read Input Height
                            clip_av_addr <= CLIP_IN_HEIGHT_ADDR;
                            if (!clip_av_wait) begin read_val_reg <= clip_av_readdata; cfg_step <= 4'd2; end
                        end
                        4'd2: begin // Read Color Format
                            clip_av_addr <= CLIP_IN_COLOR_ADDR;
                            if (!clip_av_wait) begin read_val_reg <= clip_av_readdata; cfg_step <= 4'd3; end
                        end
                        4'd3: begin // Read Subsampling
                            clip_av_addr <= CLIP_IN_SUBSAMPLING;
                            if (!clip_av_wait) begin read_val_reg <= clip_av_readdata; cfg_step <= 4'd4; end
                        end
                        4'd4: begin // Verify Left Offset (Should be 4)
                            clip_av_addr <= CLIP_LEFT_OFF_ADDR;
                            if (!clip_av_wait) begin read_val_reg <= clip_av_readdata; cfg_step <= 4'd5; end
                        end
                        4'd5: begin // Verify Top Offset (Should be 4)
                            clip_av_addr <= CLIP_TOP_OFF_ADDR;
                            if (!clip_av_wait) begin read_val_reg <= clip_av_readdata; cfg_step <= 4'd6; end
                        end
                        4'd6: begin // Verify Right Offset (Should be 4)
                            clip_av_addr <= CLIP_RIGHT_OFF_ADDR;
                            if (!clip_av_wait) begin read_val_reg <= clip_av_readdata; cfg_step <= 4'd7; end
                        end
                        4'd7: begin // Verify Bottom Offset (Should be 4)
                            clip_av_addr <= CLIP_BOT_OFF_ADDR;
                            if (!clip_av_wait) begin 
                                read_val_reg  <= clip_av_readdata; 
                                current_state <= STATE_WORKING; 
                            end
                        end
                    endcase
                end

                STATE_WORKING: begin
                    clip_av_write <= 1'b0;
                    clip_av_read  <= 1'b0;
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // IP Instantiation
    // -------------------------------------------------------------------------
    clipper_ip u_clipper_ip_inst (
        .clk_clk                                            (clk),
        .reset_reset                                        (reset),
      
        .intel_vvp_clipper_0_axi4s_vid_out_tdata            (axi_st_out_tdata),
        .intel_vvp_clipper_0_axi4s_vid_out_tvalid           (axi_st_out_tvalid),
        .intel_vvp_clipper_0_axi4s_vid_out_tready           (axi_st_out_tready),
        .intel_vvp_clipper_0_axi4s_vid_out_tlast            (axi_st_out_tlast),
        .intel_vvp_clipper_0_axi4s_vid_out_tuser            (axi_st_out_tuser),
        
        .intel_vvp_clipper_0_av_mm_control_agent_address    (clip_av_addr),
        .intel_vvp_clipper_0_av_mm_control_agent_write      (clip_av_write),
        .intel_vvp_clipper_0_av_mm_control_agent_read       (clip_av_read),
        .intel_vvp_clipper_0_av_mm_control_agent_byteenable (4'hF),
        .intel_vvp_clipper_0_av_mm_control_agent_writedata  (clip_av_wdata),
        .intel_vvp_clipper_0_av_mm_control_agent_readdata   (clip_av_readdata),
        .intel_vvp_clipper_0_av_mm_control_agent_waitrequest(clip_av_wait)
    );

endmodule