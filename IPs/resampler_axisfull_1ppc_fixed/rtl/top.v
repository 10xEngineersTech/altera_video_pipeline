`timescale 1 ps / 1 ps

module top (
    input  wire clk_clk,
    input  wire reset_reset,

    // Avalon-MM Control Interface for Resampler
    input  wire [6:0]  av_mm_control_agent_address,
    input  wire        av_mm_control_agent_write,
    input  wire [3:0]  av_mm_control_agent_byteenable,
    input  wire [31:0] av_mm_control_agent_writedata,
    input  wire        av_mm_control_agent_read,
    output wire [31:0] av_mm_control_agent_readdata,
    output wire        av_mm_control_agent_readdatavalid,
    output wire        av_mm_control_agent_waitrequest
);

    // Resampler Out (Exported)
    wire [23:0] crs_out_tdata;
    wire        crs_out_tvalid;
    wire        crs_out_tready;
    wire        crs_out_tlast;
    wire [2:0]  crs_out_tuser;

    // Sink is always ready to accept CRS output
    assign crs_out_tready = 1'b1;

    // ----- DUT Instance (System) -----
    // TPG -> CRS connection is internal to the system module.
    // Only CRS output and Avalon-MM control are exported.
    system u_dut (
        .clk_clk                                           (clk_clk),
        .reset_reset                                       (reset_reset),

        // Resampler Out
        .intel_vvp_crs_0_axi4s_vid_out_tdata               (crs_out_tdata),
        .intel_vvp_crs_0_axi4s_vid_out_tvalid              (crs_out_tvalid),
        .intel_vvp_crs_0_axi4s_vid_out_tready              (crs_out_tready),
        .intel_vvp_crs_0_axi4s_vid_out_tlast               (crs_out_tlast),
        .intel_vvp_crs_0_axi4s_vid_out_tuser               (crs_out_tuser),

        // Avalon-MM Control for Resampler
        .intel_vvp_crs_0_av_mm_control_agent_address       (av_mm_control_agent_address),
        .intel_vvp_crs_0_av_mm_control_agent_write         (av_mm_control_agent_write),
        .intel_vvp_crs_0_av_mm_control_agent_byteenable    (av_mm_control_agent_byteenable),
        .intel_vvp_crs_0_av_mm_control_agent_writedata     (av_mm_control_agent_writedata),
        .intel_vvp_crs_0_av_mm_control_agent_read          (av_mm_control_agent_read),
        .intel_vvp_crs_0_av_mm_control_agent_readdata      (av_mm_control_agent_readdata),
        .intel_vvp_crs_0_av_mm_control_agent_readdatavalid (av_mm_control_agent_readdatavalid),
        .intel_vvp_crs_0_av_mm_control_agent_waitrequest   (av_mm_control_agent_waitrequest)
    );

endmodule
