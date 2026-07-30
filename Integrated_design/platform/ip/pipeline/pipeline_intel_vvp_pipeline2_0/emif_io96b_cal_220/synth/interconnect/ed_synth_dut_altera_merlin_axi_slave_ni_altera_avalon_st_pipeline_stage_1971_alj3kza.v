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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_alj3kza #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 37,
		parameter USE_PACKETS      = 0,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
		parameter PACKET_WIDTH     = 0,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 0,
		parameter SYNC_RESET       = 0
	) (
		input  wire        clk,       
		input  wire        reset,     
		output wire        in_ready,  
		input  wire        in_valid,  
		input  wire [36:0] in_data,   
		input  wire        out_ready, 
		output wire        out_valid, 
		output wire [36:0] out_data   
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
	) my_altera_avalon_st_pipeline_stage_rd (
		.clk               (clk),       
		.reset             (reset),     
		.in_ready          (in_ready),  
		.in_valid          (in_valid),  
		.in_data           (in_data),   
		.out_ready         (out_ready), 
		.out_valid         (out_valid), 
		.out_data          (out_data),  
		.in_startofpacket  (1'b0),      
		.in_endofpacket    (1'b0),      
		.out_startofpacket (),          
		.out_endofpacket   (),          
		.in_empty          (1'b0),      
		.out_empty         (),          
		.out_error         (),          
		.in_error          (1'b0),      
		.out_channel       (),          
		.in_channel        (1'b0)       
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwLedzsfsTFYZm2hnPnMZFrlIsJ1wNffiCek0a4pm/yhIBOQu4vpU6f/K2+2ayQapMXiibkKicHVhHahZW9eZLwiSCNLWZ7Yw9Zx18BFP8q7ZY9LJWqWFUJCCKyrqqTfdpf3hShH/oY1ZoyusCBFLYC/eMUt+KhOJlXZAfTtx5Sl8QeAkMCoFA9vITLzG6lWSH5h9EwOE28W+PHuFHjucq8+JmsgpqEEKclKtIe7AL4nm4yksX6OaQ1zwePPiSKpbWp6qyQ8br3DFSA6seBs6Enk8Ee0uJ2u7zb0CMoEvwBbnmkX50WOFWMfR7KFroD7IJ3cX+zLoj4jHDTVRizd36IDK0xu5RPGogXAoxN4KcWTTuXKim++f9RvTBW1bPDyswxa3wfttklGCw6IdZ06MgSZmHzmQRwULmWc8iyChZ6/bx//sS2hYzxfT2AKsS2XZzCJt9lbjD6TskS8jPDTw+AB1o4oJBbSUV1NXXGcSPQX/4Q63JwhYbe6SabM9FvIW2TnlVIk4Fl5ziD9W/mFaXRJesuiGuf+3ywhKZwJbUXNr5jkF94Mefi/j5239IVe5Npq7Yfpuql/g9q9UNvw93+6oLJCeUP3hIvSVPf7uzRxm1KkuYRhXM0ZVG5YEslCHPSMKCqRs4hVLjVc7qjRAqqL+R/mll6QmNtilYud0p0lxygtxGIdJwtEb60Kq2krcjUEMI0Vo5/k8jKVepfMuUOIYzOqcpOxkfHuNNUilRiDh9tK6fqZF1ntmVN5HLdtnvdmicdq+xpmQ4OaU1B8eL3L"
`endif