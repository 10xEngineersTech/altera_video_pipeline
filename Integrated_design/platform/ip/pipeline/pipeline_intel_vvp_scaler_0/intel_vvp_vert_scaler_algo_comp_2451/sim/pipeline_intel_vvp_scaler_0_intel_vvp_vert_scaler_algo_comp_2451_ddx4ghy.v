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


module pipeline_intel_vvp_scaler_0_intel_vvp_vert_scaler_algo_comp_2451_ddx4ghy

   (  clk,
      rst,
      
      
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
   
   
   input    wire                             axi_st_cmd_tvalid;
   output   wire                             axi_st_cmd_tready;
   input    wire  [55 : 0]           axi_st_cmd_tdata;

   input    wire                             axi_st_data_in_tvalid;
   input    wire                             axi_st_data_in_tlast;
   input    wire  [17 : 0]          axi_st_data_in_tuser;
   input    wire  [143 : 0]          axi_st_data_in_tdata;
   output   wire                             axi_st_data_in_tready;

   output   wire                             axi_st_data_out_tvalid;
   output   wire                             axi_st_data_out_tlast;
   output   wire  [7 : 0]         axi_st_data_out_tuser;
   output   wire  [63 : 0]         axi_st_data_out_tdata;
   input    wire                             axi_st_data_out_tready;
   
   intel_vvp_vert_scaler_algo_comp # (
      .BPS                       (8),
      .NUMBER_OF_COLOR_PLANES    (3),
      .PIXELS_IN_PARALLEL        (1),
      .ALGORITHM                 ("POLYPHASE"),
      .NUM_TAPS                  (6),
      .NUM_PHASES                (64),
      .NUM_BANKS                 (1),
      .COEFF_SIGNED              (1),
      .COEFF_INT_BITS            (1),
      .COEFF_FRAC_BITS           (6),
      .RUNTIME_LOAD              (0),
      .MEM_INIT                  (1),
      .INIT_FILE                 ("pipeline_intel_vvp_scaler_0_intel_vvp_vert_scaler_algo_comp_2451_ddx4ghy_coeff.mif"),
      .DEVICE_FAMILY             ("Agilex 5"),
      .PIPELINE_READY            (0),
      .NO_BLANKING               (1),
      .ENABLE_420                (0),
      .EDGE_MIRROR               (0)
   ) scl_v_core_inst (  
      .clk                       (clk),
      .rst                       (rst),
      .coeff_clk                 (1'b0),
      .coeff_rst                 (1'b0),
      .axi_st_coeff_tvalid       (1'b0),
      .axi_st_coeff_tready       (),
      .axi_st_coeff_tlast        (1'b0),
      .axi_st_coeff_tuser        (2'b00),
      .axi_st_coeff_tdata        (16'h0000),
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
