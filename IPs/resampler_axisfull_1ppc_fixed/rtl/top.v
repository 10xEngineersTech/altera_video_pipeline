`timescale 1 ps / 1 ps

module top (
    input  wire clk_clk,
    input  wire reset_reset,
    output wire status_led
);

    // TPG signals (Exported)
    wire [23:0] tpg_out_tdata;
    wire        tpg_out_tvalid;
    wire        tpg_out_tready;
    wire        tpg_out_tlast;
    wire [2:0]  tpg_out_tuser;

    // Resampler In (Exported)
    wire [23:0] crs_in_tdata;
    wire        crs_in_tvalid;
    wire        crs_in_tready;
    wire        crs_in_tlast;
    wire [2:0]  crs_in_tuser;

    // Resampler Out (Exported)
    wire [23:0] crs_out_tdata;
    wire        crs_out_tvalid;
    wire        crs_out_tready;
    wire        crs_out_tlast;
    wire [2:0]  crs_out_tuser;

    // Connections: TPG -> Resampler
    assign crs_in_tdata  = tpg_out_tdata;
    assign crs_in_tvalid = tpg_out_tvalid;
    assign crs_in_tlast  = tpg_out_tlast;
    assign crs_in_tuser  =  tpg_out_tuser;
    assign tpg_out_tready = crs_in_tready;

    assign crs_out_tready = 1'b1; // checker is always ready

    // ----- DUT Instance (System) -----
    system u_dut (
        .clk_clk                                           (clk_clk),
        .reset_reset                                       (reset_reset),

        // TPG Out
        .intel_vvp_tpg_0_axi4s_vid_out_tdata               (tpg_out_tdata),
        .intel_vvp_tpg_0_axi4s_vid_out_tvalid              (tpg_out_tvalid),
        .intel_vvp_tpg_0_axi4s_vid_out_tready              (tpg_out_tready),
        .intel_vvp_tpg_0_axi4s_vid_out_tlast               (tpg_out_tlast),
        .intel_vvp_tpg_0_axi4s_vid_out_tuser               (tpg_out_tuser),

        // Resampler In
        .intel_vvp_crs_0_axi4s_vid_in_tdata                (crs_in_tdata),
        .intel_vvp_crs_0_axi4s_vid_in_tvalid               (crs_in_tvalid),
        .intel_vvp_crs_0_axi4s_vid_in_tready               (crs_in_tready),
        .intel_vvp_crs_0_axi4s_vid_in_tlast                (crs_in_tlast),
        .intel_vvp_crs_0_axi4s_vid_in_tuser                (crs_in_tuser),

        // Resampler Out
        .intel_vvp_crs_0_axi4s_vid_out_tdata               (crs_out_tdata),
        .intel_vvp_crs_0_axi4s_vid_out_tvalid              (crs_out_tvalid),
        .intel_vvp_crs_0_axi4s_vid_out_tready              (crs_out_tready),
        .intel_vvp_crs_0_axi4s_vid_out_tlast               (crs_out_tlast),
        .intel_vvp_crs_0_axi4s_vid_out_tuser               (crs_out_tuser)
    );

    // ----- Resampling Checker Instance -----
    resampling_checker u_checker (
        .clk_clk(clk_clk),
        .reset_reset(reset_reset),
        .status_led(status_led),
        
        // Connect to exported signals
        .crs_out_tdata(crs_out_tdata),
        .crs_out_tvalid(crs_out_tvalid),
        .crs_out_tuser(crs_out_tuser),
        
        .tpg_out_tdata(tpg_out_tdata),
        .tpg_out_tvalid(tpg_out_tvalid),
        .tpg_out_tuser(tpg_out_tuser)
    );

endmodule
