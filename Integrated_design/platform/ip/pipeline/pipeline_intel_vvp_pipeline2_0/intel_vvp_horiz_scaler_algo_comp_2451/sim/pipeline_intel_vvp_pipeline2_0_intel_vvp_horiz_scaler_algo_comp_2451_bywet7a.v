// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module pipeline_intel_vvp_pipeline2_0_intel_vvp_horiz_scaler_algo_comp_2451_bywet7a
   
   (  clk,
      rst,
      
      coeff_clk,
      coeff_rst,
      
      axi_st_coeff_tvalid,
      axi_st_coeff_tready,
      axi_st_coeff_tlast,
      axi_st_coeff_tuser,
      axi_st_coeff_tdata,
      
      axi_st_cmd_tvalid,
      axi_st_cmd_tready,
      axi_st_cmd_tdata,
      
      axi_st_data_in_tvalid,
      axi_st_data_in_tlast,
      axi_st_data_in_tuser,
      axi_st_data_in_tdata,
      axi_st_data_in_tready,
      
      axi_st_data_out_tvalid,
      axi_st_data_out_tlast,
      axi_st_data_out_tuser,
      axi_st_data_out_tdata,
      axi_st_data_out_tready
   );
   
   input    wire                             clk;
   input    wire                             rst;
   
   input    wire                             coeff_clk;
   input    wire                             coeff_rst;
   
   input    wire                             axi_st_coeff_tvalid;
   output   wire                             axi_st_coeff_tready;
   input    wire                             axi_st_coeff_tlast;
   input    wire  [4 : 0]       axi_st_coeff_tuser;
   input    wire  [39 : 0]       axi_st_coeff_tdata;
   
   input    wire                             axi_st_cmd_tvalid;
   output   wire                             axi_st_cmd_tready;
   input    wire  [119 : 0]           axi_st_cmd_tdata;

   input    wire                             axi_st_data_in_tvalid;
   input    wire                             axi_st_data_in_tlast;
   input    wire  [6 : 0]          axi_st_data_in_tuser;
   input    wire  [55 : 0]          axi_st_data_in_tdata;
   output   wire                             axi_st_data_in_tready;

   output   wire                             axi_st_data_out_tvalid;
   output   wire                             axi_st_data_out_tlast;
   output   wire  [2 : 0]         axi_st_data_out_tuser;
   output   wire  [23 : 0]         axi_st_data_out_tdata;
   input    wire                             axi_st_data_out_tready;
   
   intel_vvp_horiz_scaler_algo_comp #(
      .BPS_IN                    (17),
      .BPS_OUT                   (8),
      .SIGNED_IN                 (1),
      .FRAC_BITS_IN              (6),
      .NUMBER_OF_COLOR_PLANES    (3),
      .PIXELS_IN_PARALLEL        (1),
      .PARTIAL_IMAGE_SCALING     (0),
      .SCALER_MAX_WIDTH          (2047),
      .ALGORITHM                 ("POLYPHASE"),
      .NUM_TAPS                  (4),
      .NUM_PHASES                (16),
      .NUM_BANKS                 (1),
      .COEFF_SIGNED              (1),
      .COEFF_INT_BITS            (2),
      .COEFF_FRAC_BITS           (6),
      .RUNTIME_LOAD              (1),
      .MEM_INIT                  (1),
      .INIT_FILE                 ("pipeline_intel_vvp_pipeline2_0_intel_vvp_horiz_scaler_algo_comp_2451_bywet7a_coeff.mif"),
      .DEVICE_FAMILY             ("Agilex 5"),
      .PIPELINE_READY            (0),
      .EDGE_MIRROR               (0)
   ) scl_h_core_inst (  
      .clk                       (clk),
      .rst                       (rst),
      .coeff_clk                 (coeff_clk),
      .coeff_rst                 (coeff_rst),
      .axi_st_coeff_tvalid       (axi_st_coeff_tvalid),
      .axi_st_coeff_tready       (axi_st_coeff_tready),
      .axi_st_coeff_tlast        (axi_st_coeff_tlast),
      .axi_st_coeff_tuser        (axi_st_coeff_tuser),
      .axi_st_coeff_tdata        (axi_st_coeff_tdata),
      .axi_st_cmd_tvalid         (axi_st_cmd_tvalid),
      .axi_st_cmd_tready         (axi_st_cmd_tready),
      .axi_st_cmd_tdata          (axi_st_cmd_tdata),
      .axi_st_data_in_tvalid     (axi_st_data_in_tvalid),
      .axi_st_data_in_tlast      (axi_st_data_in_tlast),
      .axi_st_data_in_tuser      (axi_st_data_in_tuser),
      .axi_st_data_in_tdata      (axi_st_data_in_tdata),
      .axi_st_data_in_tready     (axi_st_data_in_tready),
      .axi_st_data_out_tvalid    (axi_st_data_out_tvalid),
      .axi_st_data_out_tlast     (axi_st_data_out_tlast),
      .axi_st_data_out_tuser     (axi_st_data_out_tuser),
      .axi_st_data_out_tdata     (axi_st_data_out_tdata),
      .axi_st_data_out_tready    (axi_st_data_out_tready)
   );
   
endmodule
