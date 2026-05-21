`timescale 1ns/1ps
// =============================================================================
// top.v - DUT wrapper for intel_vvp_pipeline2 SCALER_ONLY test
// Chain: TPG(Full) -> s_axis_in -> pconv(Full->Lite) -> scaler(Lite) -> m_axis_out
// State machine configures scaler via MM bridge before video flows
// MM bridge word addresses - scaler at base 0x0000:
//   IN_WIDTH   = 0x48
//   IN_HEIGHT  = 0x49
//   OUT_WIDTH  = 0x52
//   OUT_HEIGHT = 0x53
// =============================================================================
module top #(
    parameter SCALER_IN_W  = 64,
    parameter SCALER_IN_H  = 64,
    parameter SCALER_OUT_W = 128,
    parameter SCALER_OUT_H = 122
)(
    input  wire        clk,
    input  wire        rst,
    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser,
    output wire        cfg_done
);

    // -------------------------------------------------------------------------
    // State machine states
    // -------------------------------------------------------------------------
    localparam STATE_IDLE  = 2'd0;
    localparam STATE_WRITE = 2'd1;
    localparam STATE_WAIT  = 2'd2;
    localparam STATE_DONE  = 2'd3;

    // Scaler word addresses
    localparam [10:0] SCL_IN_WIDTH   = 11'h48;
    localparam [10:0] SCL_IN_HEIGHT  = 11'h49;
    localparam [10:0] SCL_OUT_WIDTH  = 11'h52;
    localparam [10:0] SCL_OUT_HEIGHT = 11'h53;

    reg [1:0]  state    = STATE_IDLE;
    reg [2:0]  reg_idx  = 0;
    reg [12:0] idle_cnt = 0;

    reg [10:0] mm_addr      = 0;
    reg        mm_write     = 0;
    reg [3:0]  mm_be        = 4'hF;
    reg [31:0] mm_wdata     = 0;
    reg        mm_read      = 0;
    reg        mm_burstcount = 1;
    reg        mm_debug     = 0;
    wire [31:0] mm_rdata;
    wire        mm_rdv;
    wire        mm_wait;

    assign cfg_done = (state == STATE_DONE);

    // Register table
    reg [10:0] reg_addrs [0:4];
    reg [31:0] reg_datas [0:4];

    localparam [10:0] SCL_COMMIT = 11'h51;

    initial begin
        reg_addrs[0] = SCL_IN_WIDTH;
        reg_addrs[1] = SCL_IN_HEIGHT;
        reg_addrs[2] = SCL_OUT_WIDTH;
        reg_addrs[3] = SCL_OUT_HEIGHT;
        reg_datas[0] = SCALER_IN_W;
        reg_datas[1] = SCALER_IN_H;
        reg_datas[2] = SCALER_OUT_W;
        reg_datas[3] = SCALER_OUT_H;
        reg_addrs[4] = SCL_COMMIT;
        reg_datas[4] = 32'h1;
    end

    // -------------------------------------------------------------------------
    // Configuration state machine
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            state    <= STATE_IDLE;
            reg_idx  <= 0;
            idle_cnt <= 0;
            mm_write <= 0;
            mm_addr  <= 0;
            mm_wdata <= 0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    mm_write <= 0;
                    if (idle_cnt == 13'd5000) begin
                        state   <= STATE_WRITE;
                        reg_idx <= 0;
                    end else
                        idle_cnt <= idle_cnt + 1;
                end
                STATE_WRITE: begin
                    mm_write <= 1'b1;
                    mm_addr  <= reg_addrs[reg_idx];
                    mm_wdata <= reg_datas[reg_idx];
                    state    <= STATE_WAIT;
                end
                STATE_WAIT: begin
                    if (!mm_wait) begin
                        mm_write <= 1'b0;
                        if (reg_idx == 3'd4)
                            state <= STATE_DONE;
                        else begin
                            reg_idx <= reg_idx + 1;
                            state   <= STATE_WRITE;
                        end
                    end
                end
                STATE_DONE: begin
                    mm_write <= 0;
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Debug
    // -------------------------------------------------------------------------
    reg [1:0] prev_state = 0;
    always @(posedge clk) begin
        prev_state <= state;
        if (mm_write)
            $display("[SM][%0t] addr=0x%03h data=0x%08h wait=%b",
                     $time, mm_addr, mm_wdata, mm_wait);
        if (state == STATE_DONE && prev_state != STATE_DONE)
            $display("[SM] CONFIG DONE - all 4 registers written");
    end

    // -------------------------------------------------------------------------
    // TPG wires
    // -------------------------------------------------------------------------
    wire [23:0] tpg_tdata;
    wire        tpg_tvalid;
    wire        tpg_tready;
    wire        tpg_tlast;
    wire [2:0]  tpg_tuser;

    // -------------------------------------------------------------------------
    // System instantiation
    // -------------------------------------------------------------------------
    system u_system (
        .clk_clk                     (clk),
        .reset_reset                 (rst),

        // MM control
        .av_mm_control_address       (mm_addr),
        .av_mm_control_write         (mm_write),
        .av_mm_control_byteenable    (mm_be),
        .av_mm_control_writedata     (mm_wdata),
        .av_mm_control_read          (mm_read),
        .av_mm_control_readdata      (mm_rdata),
        .av_mm_control_readdatavalid (mm_rdv),
        .av_mm_control_waitrequest   (mm_wait),
        .av_mm_control_burstcount    (mm_burstcount),
        .av_mm_control_debugaccess   (mm_debug),

        // TPG output -> pipeline input (loopback)
        .axi4s_vid_out_tdata         (tpg_tdata),
        .axi4s_vid_out_tvalid        (tpg_tvalid),
        .axi4s_vid_out_tready        (1'b1),      // TPG always runs
        .axi4s_vid_out_tlast         (tpg_tlast),
        .axi4s_vid_out_tuser         (tpg_tuser),

        .s_axis_video_in_tdata       (tpg_tdata),
        .s_axis_video_in_tvalid      (tpg_tvalid & cfg_done),
        .s_axis_video_in_tready      (tpg_tready),
        .s_axis_video_in_tlast       (tpg_tlast),
        .s_axis_video_in_tuser       (tpg_tuser),

        // Pipeline output
        .m_axis_video_out_tdata      (out_tdata),
        .m_axis_video_out_tvalid     (out_tvalid),
        .m_axis_video_out_tready     (out_tready),
        .m_axis_video_out_tlast      (out_tlast),
        .m_axis_video_out_tuser      (out_tuser)
    );

endmodule
