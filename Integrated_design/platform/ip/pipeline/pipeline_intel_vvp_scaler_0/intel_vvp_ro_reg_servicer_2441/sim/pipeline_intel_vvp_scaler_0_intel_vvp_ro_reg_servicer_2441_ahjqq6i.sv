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


`default_nettype none

module pipeline_intel_vvp_scaler_0_intel_vvp_ro_reg_servicer_2441_ahjqq6i
   (  clk,
      rst,
      
      av_mm_master_write,
      av_mm_master_read,
      av_mm_master_byteenable,
      av_mm_master_address,
      av_mm_master_writedata,
      av_mm_master_waitrequest,
      av_mm_master_readdata,
      av_mm_master_readdatavalid,
      
      av_mm_slave_write,
      av_mm_slave_read,
      av_mm_slave_byteenable,
      av_mm_slave_address,
      av_mm_slave_writedata,
      av_mm_slave_waitrequest,
      av_mm_slave_readdata,
      av_mm_slave_readdatavalid
   );

   parameter VVP_SLAVE_DATA_WIDTH      =  32;
   parameter P_VID_PID                 =  0;
   parameter P_VERSION_NUMBER          =  0;
   parameter P_AV_MM_SLAVE_ADDR_WIDTH  =  32;
   parameter P_AV_MM_MASTER_ADDR_WIDTH =  32;
   
   localparam P_BE_WIDTH               =  VVP_SLAVE_DATA_WIDTH / 8;
   
   input   logic                                      clk;
   input   logic                                      rst;

   output  logic                                      av_mm_master_write;
   output  logic                                      av_mm_master_read;
   output  logic  [P_BE_WIDTH - 1 : 0]                av_mm_master_byteenable;
   output  logic  [P_AV_MM_MASTER_ADDR_WIDTH - 1 : 0] av_mm_master_address;
   output  logic  [VVP_SLAVE_DATA_WIDTH - 1 : 0]      av_mm_master_writedata;
   input   logic                                      av_mm_master_waitrequest;
   input   logic  [VVP_SLAVE_DATA_WIDTH - 1 : 0]      av_mm_master_readdata;
   input   logic                                      av_mm_master_readdatavalid;
      
   input   logic                                      av_mm_slave_write;
   input   logic                                      av_mm_slave_read;
   input   logic  [P_BE_WIDTH - 1 : 0]                av_mm_slave_byteenable;
   input   logic  [P_AV_MM_SLAVE_ADDR_WIDTH - 1 : 0]  av_mm_slave_address;
   input   logic  [VVP_SLAVE_DATA_WIDTH - 1 : 0]      av_mm_slave_writedata;
   output  logic                                      av_mm_slave_waitrequest;
   output  logic  [VVP_SLAVE_DATA_WIDTH - 1 : 0]      av_mm_slave_readdata;
   output  logic                                      av_mm_slave_readdatavalid;
      
   // Up to 62 RO Register values (plus the 2 versioning registers) can be passed
   localparam P_RO_REG_COUNT = 26 + 2;

   localparam integer P_RO_PARAMS [0 : P_RO_REG_COUNT-1] =  '{ P_VID_PID, P_VERSION_NUMBER, 1, 0, 1, 16383, 16383, 2, 0, 1, 1, 6, 64, 1, 1, 1, 6, 1, 6, 64, 1, 1, 1, 6, 0, 0, 0, 0 };

   intel_vvp_ro_reg_servicer # (
      .P_AV_MM_SLAVE_ADDR_WIDTH         (P_AV_MM_SLAVE_ADDR_WIDTH),
      .P_AV_MM_MASTER_ADDR_WIDTH        (P_AV_MM_MASTER_ADDR_WIDTH),
      .P_RO_REG_COUNT                   (P_RO_REG_COUNT),
      .P_RO_PARAMS                      (P_RO_PARAMS)
   ) ro_reg_servicer_inst (
      .clk                        (clk),
      .rst                        (rst),

      .av_mm_master_write         (av_mm_master_write),
      .av_mm_master_read          (av_mm_master_read),
      .av_mm_master_byteenable    (av_mm_master_byteenable),
      .av_mm_master_address       (av_mm_master_address),
      .av_mm_master_writedata     (av_mm_master_writedata),
      .av_mm_master_readdata      (av_mm_master_readdata),
      .av_mm_master_readdatavalid (av_mm_master_readdatavalid),
      .av_mm_master_waitrequest   (av_mm_master_waitrequest),
             
      .av_mm_slave_write          (av_mm_slave_write),
      .av_mm_slave_read           (av_mm_slave_read),
      .av_mm_slave_byteenable     (av_mm_slave_byteenable),
      .av_mm_slave_address        (av_mm_slave_address),
      .av_mm_slave_writedata      (av_mm_slave_writedata),
      .av_mm_slave_readdata       (av_mm_slave_readdata),
      .av_mm_slave_readdatavalid  (av_mm_slave_readdatavalid),
      .av_mm_slave_waitrequest    (av_mm_slave_waitrequest)

   );

endmodule

`default_nettype wire

