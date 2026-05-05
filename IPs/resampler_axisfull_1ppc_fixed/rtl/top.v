`timescale 1 ps / 1 ps

module top (
    input  wire clk_clk,
    input  wire reset_reset,
    output wire status_led
);

    // AXIS signals from DUT for checker
    wire [23:0] crs_out_tdata;
    wire        crs_out_tvalid;
    wire        crs_out_tready;
    wire        crs_out_tlast;
    wire [2:0]  crs_out_tuser;

    assign crs_out_tready = 1'b1; // always ready

    // ----- DUT Instance (System) -----
    // Using library-qualified name to resolve "Module not defined" error
    system u_dut (
        .clk_clk                                           (clk_clk),
        .reset_reset                                       (reset_reset),
        // AXIS Out
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
        
        // Connect to DUT outputs
        .crs_out_tdata(crs_out_tdata),
        .crs_out_tvalid(crs_out_tvalid),
        .crs_out_tuser(crs_out_tuser),
        
        // Connect to DUT internal TPG signals (Hierarchical Access)
        .tpg_out_tdata(u_dut.intel_vvp_tpg_0_axi4s_vid_out_tdata),
        .tpg_out_tvalid(u_dut.intel_vvp_tpg_0_axi4s_vid_out_tvalid),
        .tpg_out_tuser(u_dut.intel_vvp_tpg_0_axi4s_vid_out_tuser)
    );

endmodule
