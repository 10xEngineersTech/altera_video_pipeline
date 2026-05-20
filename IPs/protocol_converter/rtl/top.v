`timescale 1 ps / 1 ps

// Top-level wrapper.
// protocol_converter_0  : AXIS Lite  -> AXIS Full  (Lite-to-Full, mode 4)
// protocol_converter_1  : AXIS Full  -> AXIS Lite  (Full-to-Lite, mode 5)
// The Full stream between them is wired internally.
// Only converter_0 has an Avalon-MM control agent (for register config).

module top (
    input  wire        clk_clk,
    input  wire        reset_reset,

    // Input  : AXIS Lite -> protocol_converter_0
    input  wire [23:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    input  wire [2:0]  s_axis_tuser,

    // Output : AXIS Lite <- protocol_converter_1
    output wire [23:0] m_axis_tdata,
    output wire        m_axis_tvalid,
    input  wire        m_axis_tready,
    output wire        m_axis_tlast,
    output wire [2:0]  m_axis_tuser,

    // Avalon-MM control agent for protocol_converter_0
    input  wire [6:0]  av_mm_conv0_address,
    input  wire        av_mm_conv0_write,
    input  wire [3:0]  av_mm_conv0_byteenable,
    input  wire [31:0] av_mm_conv0_writedata,
    input  wire        av_mm_conv0_read,
    output wire [31:0] av_mm_conv0_readdata,
    output wire        av_mm_conv0_readdatavalid,
    output wire        av_mm_conv0_waitrequest
);

    // Internal AXIS Full bus: converter_0 output -> converter_1 input
    wire [23:0] full_tdata;
    wire        full_tvalid;
    wire        full_tready;
    wire        full_tlast;
    wire [2:0]  full_tuser;

    system u_sys (
        .clk_clk   (clk_clk),
        .reset_reset (reset_reset),

        // --- protocol_converter_0 input (AXIS Lite) ---
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tdata  (s_axis_tdata),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tvalid (s_axis_tvalid),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tready (s_axis_tready),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tlast  (s_axis_tlast),
        .intel_vvp_protocol_conv_0_axi4s_vid_in_tuser  (s_axis_tuser),

        // --- protocol_converter_0 output (AXIS Full) -> converter_1 input ---
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tdata  (full_tdata),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tvalid (full_tvalid),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tready (full_tready),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tlast  (full_tlast),
        .intel_vvp_protocol_conv_0_axi4s_vid_out_tuser  (full_tuser),

        // --- protocol_converter_1 input (AXIS Full from converter_0) ---
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tdata  (full_tdata),
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tvalid (full_tvalid),
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tready (full_tready),
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tlast  (full_tlast),
        .intel_vvp_protocol_conv_1_axi4s_vid_in_tuser  (full_tuser),

        // --- protocol_converter_1 output (AXIS Lite) ---
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tdata  (m_axis_tdata),
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tvalid (m_axis_tvalid),
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tready (m_axis_tready),
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tlast  (m_axis_tlast),
        .intel_vvp_protocol_conv_1_axi4s_vid_out_tuser  (m_axis_tuser),

        // --- Avalon-MM control for protocol_converter_0 ---
        .intel_vvp_protocol_conv_0_av_mm_control_agent_address       (av_mm_conv0_address),
        .intel_vvp_protocol_conv_0_av_mm_control_agent_write         (av_mm_conv0_write),
        .intel_vvp_protocol_conv_0_av_mm_control_agent_byteenable    (av_mm_conv0_byteenable),
        .intel_vvp_protocol_conv_0_av_mm_control_agent_writedata     (av_mm_conv0_writedata),
        .intel_vvp_protocol_conv_0_av_mm_control_agent_read          (av_mm_conv0_read),
        .intel_vvp_protocol_conv_0_av_mm_control_agent_readdata      (av_mm_conv0_readdata),
        .intel_vvp_protocol_conv_0_av_mm_control_agent_readdatavalid (av_mm_conv0_readdatavalid),
        .intel_vvp_protocol_conv_0_av_mm_control_agent_waitrequest   (av_mm_conv0_waitrequest)
    );

endmodule
