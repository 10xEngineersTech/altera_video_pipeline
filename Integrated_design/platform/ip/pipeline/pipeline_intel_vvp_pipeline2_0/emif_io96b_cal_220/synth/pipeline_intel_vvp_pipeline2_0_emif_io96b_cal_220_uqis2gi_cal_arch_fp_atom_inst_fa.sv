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



module stdfn_inst_fa_c2p_ssm #(
   parameter IS_USED  = 0,

   parameter SSM_C2P_DATA_MODE                               = "SSM_C2P_DATA_MODE_BYPASS",
   parameter FA_CORE_PERIPH_CLK_SEL_DATA_MODE                = "FA_CORE_PERIPH_CLK_SEL_DATA_MODE_UNUSED",
   parameter SSM_P2C_DATA_MODE                               = "SSM_P2C_DATA_MODE_BYPASS",
   localparam PORT_I_SSM_C2P_WIDTH                            = 40,
   localparam PORT_O_SSM_C2P_WIDTH                            = 40,
   localparam PORT_I_SSM_P2C_WIDTH                            = 20,
   localparam PORT_O_SSM_P2C_WIDTH                            = 20
) (
   input                                                      i_core_clk,
   input [PORT_I_SSM_C2P_WIDTH-1:0]                           i_ssm_c2p,
   output [PORT_O_SSM_C2P_WIDTH-1:0]                           o_ssm_c2p,
   input                                                      i_phy_clk_fr,
   input                                                      i_phy_clk_sync,
   input [PORT_I_SSM_P2C_WIDTH-1:0]                           i_ssm_p2c,
   output [PORT_O_SSM_P2C_WIDTH-1:0]                           o_ssm_p2c
);
   timeunit 1ns;
   timeprecision 1ps;

   tennm_ssm_c2p_fabric_adaptor # (
      .ssm_c2p_data_mode                                    (SSM_C2P_DATA_MODE),
      .fa_core_periph_clk_sel_data_mode                     (FA_CORE_PERIPH_CLK_SEL_DATA_MODE)
   ) fa_c2p_ssm (
      .i_core_clk                                           (i_core_clk),
      .i_phy_clk_fr                                         (i_phy_clk_fr),
      .i_phy_clk_sync                                       (i_phy_clk_sync),
      .i_ssm_c2p                                            (i_ssm_c2p),
      .o_ssm_c2p                                            (o_ssm_c2p)
   );
   tennm_ssm_p2c_fabric_adaptor # (
      .ssm_p2c_data_mode                                    (SSM_P2C_DATA_MODE),
      .fa_core_periph_clk_sel_data_mode                     (FA_CORE_PERIPH_CLK_SEL_DATA_MODE)
   ) fa_p2c_ssm (
      .i_core_clk                                           (i_core_clk),
      .i_phy_clk_fr                                         (i_phy_clk_fr),
      .i_phy_clk_sync                                       (i_phy_clk_sync),
      .i_ssm_p2c                                            (i_ssm_p2c),
      .o_ssm_p2c                                            (o_ssm_p2c)
   );

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwKa2u8iCjjBQgFGuZmt9gqDa3i1AYpmlPJIjz0F0jcRltyCtE+O4VnQVbfnOeGkqEWXdfChSr6nnuWeXX7ZSAe5+OxQxoc9v79V/B26M2W1eqhAcFrdsFhKlwhyswUXuFRyt9IJ7Okoa4FC3hntLWFjWNFg2DovF5jVKCv8LckgyJ2sX1eO5+nKo45s4q+2QprbdX+mRop/P4xgeb+62h+hoDh4lTw/Fdo5crwZelMXAAlcdNXpzsYIDsvQBUvn/jCVjjmues/NHRUJQKCCQj0eXV2s6qVuC5VpJ89n2Pm4pZ6iB8xOj52tNFU9eyMlu8NMg1m9y/PbU48B3MaWtfiXrxyWtXlLuorPyGKTU9PRtOrjSw4Ri6bzJknXD9oDqxiFONDXHUxnkC6LagAcp2kbpVOxPytVQSt0H5xsAlkt+D2e3zQ9L8Ao0HBe4qrWWIQ2t7/Awr40zqraCsRG4/lRXkI+sk67P9sfUdUaQnYVmuU1aVrk9dCRfoB0JVCb+xOcGu6RlosQZSPL7KKSBUwKRHqsqLqxqiufCW1l7VJNAIF0Bh5jinz+8n9XpK6YFBs9+8/JI7rBEgzXy5LGEgxuHqEGXdkinGQMVZWe42R1AXlrSQ/JYyvTj1NdgNr9z/ir27cyYpsNskw+bGn1nE6EbngL20dC73CQcRbb4DWEn2gEUNhUPhSFasXFNftDzRYrJyA1aLiL6IioG1q323RyjF9DEjUjnAJZYzN8ocAls2uMxiGSenV9NluhO8XpVKKcc04eZygo1Lz6XFIrnWVu"
`endif