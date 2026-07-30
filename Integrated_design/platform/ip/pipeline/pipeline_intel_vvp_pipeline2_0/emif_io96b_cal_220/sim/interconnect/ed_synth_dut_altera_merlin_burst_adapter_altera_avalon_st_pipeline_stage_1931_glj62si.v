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
module ed_synth_dut_altera_merlin_burst_adapter_altera_avalon_st_pipeline_stage_1931_glj62si #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 188,
		parameter USE_PACKETS      = 1,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 2,
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
		input  wire [1:0]   in_channel,        
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [187:0] out_data,          
		output wire [1:0]   out_channel        
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
	) my_altera_avalon_st_pipeline_stage (
		.clk               (clk),               
		.reset             (reset),             
		.in_ready          (in_ready),          
		.in_valid          (in_valid),          
		.in_startofpacket  (in_startofpacket),  
		.in_endofpacket    (in_endofpacket),    
		.in_data           (in_data),           
		.in_channel        (in_channel),        
		.out_ready         (out_ready),         
		.out_valid         (out_valid),         
		.out_startofpacket (out_startofpacket), 
		.out_endofpacket   (out_endofpacket),   
		.out_data          (out_data),          
		.out_channel       (out_channel),       
		.in_empty          (1'b0),              
		.out_empty         (),                  
		.out_error         (),                  
		.in_error          (1'b0)               
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwLd4NPAEnUL+zV/ldykfmAdKvJR738U6NV/FU388kg0K+iTQ4WiDErn/EgyzH/+gf/JF8g6zlq61hE/rbT6n+FVVXdIaayGpT6jdpROV98jbApW0vgyzWjQgnBhwu6DGaexP7XQUNxwnv3V4lZT97Y8hY9VyBrJACh1rg0G4rQLBF0hqfuh9w+LBasSmfPqX6QUg/Aq0q0+WzM6dQVDHWc8swY9+RE9U0DxLjwBpkJ34lBuXKXSciutwO9CaZDL5maJt8xgoX7qkUvXQVPOpPIC04vP2ezddyraK67Md2f/k5Q3mvzZU31KMfdYKwRhvGl2zls87ckFgPjDLY0ofX5y3fxelW0HeP7inJSke93Hnr2WVVdAcxh0wuFbHzb+JCkCCqwm1K4HhHn71CWG+2YiAlOBrDhF47Cslzpidh6mlm+3SwG7hITLLSRvk76P3atGoxtgIQfe7GykHye5DYTnGy7HNhw92eiwAE1BEzI3Iv5Fic8+OLto/9WYnrS5vFCOQR/dIaabFg+EO0u09oJdP0ujqKhTw0DcAG5bO9OxEPolUQbG99XGFtilT/8KGU6Qfe0TZVTGUQ9zLxCZVpX6NuGpwCK+w7wVYjXFe7+QoHLhKWQpAJHmvRjMe/MFzFkfqkY/O56hxtCzynfiAfGHU1JO1MTY6Eiz8N9WMZJ7Dfa29Ofrhwf2EfRSdspNqCZDkbyn6//99LVtUQlVPrMbLlLU3jj2/aiUfJnWyKSRoJOq9eJLvB0J3aXy3Ol8gpQiSW+NmovEZL6ujAmbSBK/"
`endif