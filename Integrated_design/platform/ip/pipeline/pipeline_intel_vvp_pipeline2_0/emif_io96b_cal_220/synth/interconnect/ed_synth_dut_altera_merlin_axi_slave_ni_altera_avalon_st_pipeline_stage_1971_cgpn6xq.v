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




`timescale 1 ps / 1 ps
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_cgpn6xq #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 188,
		parameter USE_PACKETS      = 1,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
		parameter PACKET_WIDTH     = 2,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 1,
		parameter SYNC_RESET       = 0
	) (
		input  wire         clk,               
		input  wire         reset,             
		output wire         in_ready,          
		input  wire         in_valid,          
		input  wire         in_startofpacket,  
		input  wire         in_endofpacket,    
		input  wire [187:0] in_data,           
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [187:0] out_data           
	);

	ed_synth_dut_altera_avalon_st_pipeline_stage_1930_bv2ucky #(
		.SYMBOLS_PER_BEAT (SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL  (BITS_PER_SYMBOL),
		.USE_PACKETS      (USE_PACKETS),
		.USE_EMPTY        (USE_EMPTY),
		.EMPTY_WIDTH      (EMPTY_WIDTH),
		.CHANNEL_WIDTH    (CHANNEL_WIDTH),
		.PACKET_WIDTH     (PACKET_WIDTH),
		.ERROR_WIDTH      (ERROR_WIDTH),
		.PIPELINE_READY   (PIPELINE_READY),
		.SYNC_RESET       (SYNC_RESET)
	) my_altera_avalon_st_pipeline_stage_rp (
		.clk               (clk),               
		.reset             (reset),             
		.in_ready          (in_ready),          
		.in_valid          (in_valid),          
		.in_startofpacket  (in_startofpacket),  
		.in_endofpacket    (in_endofpacket),    
		.in_data           (in_data),           
		.out_ready         (out_ready),         
		.out_valid         (out_valid),         
		.out_startofpacket (out_startofpacket), 
		.out_endofpacket   (out_endofpacket),   
		.out_data          (out_data),          
		.in_empty          (1'b0),              
		.out_empty         (),                  
		.out_error         (),                  
		.in_error          (1'b0),              
		.out_channel       (),                  
		.in_channel        (1'b0)               
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwIfhUcmcFMyooOzMMqD5XZ1LBug6TZrVPmx9BLBfTH9pMN71vLb/zSzp6UBolA1gW4mhTAp02l6XYyPa1tW0Kf+GMbrf/Hmapwhtcvqj7jBBEkYCTgNR+9n9m0ULuadHKG6EbNQ0iG5CNrIf+BHv9f8goe8aZpEIe2iHz++RmzUl8t+2yL6iRutGcc8oxTi/YEZ6OLrU3lZDChKS39VnMz+MQb6v/q74d8USpRIrJfpie1wdzd0d450jR9U5LzPFrWZLYJ/yklAY/ch2zKLTz1w8odW/uDGcXxBFJ11RIEqQ0x69gKnh2/apNnKQnDUk8OFnNlbeykT77XO/DRLJohTshlPXQf868AuCvcQRWSpTgneeOpkmi1sCwJBs6ggfxpPP7S42DS01r1DDAebsSaUSmlGiusPLmxZzdvqCU1ey1o96WbRQfGJxjm2++y9vaQnue+xR1gqH0dr8Wa/RTMYM2rFh2J/2v4mOZkTkRatFudDD6bflyCVHNTKfoKRjSL2K3l9mbOHjDgn8TbMBTP+jwL2knpK/ef3WFJDXJwJF8Q/4d96MWGLyPdd/NUuRiPZwWk0AimHK59p331b1KKgF10gezo2kcdWlI0qigoZS8JNQD4Oux+qFSLFrjBhp2TTlt+5K3FpUb9RJ9bHW4GeSgrWw3cAJl8lDKfoazJxpclJL8NypM/Yn5yvSWs4NNQGVpFoLcpx8lB2vFrCgNHqw1S1pnlx1TceFTfAF9iyA1O+5tn87QGztzB91K1f0PzX5FBKrmjSF9DEkn5Gj4ou"
`endif