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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_h6wexfa #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 4,
		parameter USE_PACKETS      = 0,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
		parameter PACKET_WIDTH     = 0,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 0,
		parameter SYNC_RESET       = 0
	) (
		input  wire       clk,       
		input  wire       reset,     
		output wire       in_ready,  
		input  wire       in_valid,  
		input  wire [3:0] in_data,   
		input  wire       out_ready, 
		output wire       out_valid, 
		output wire [3:0] out_data   
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
	) my_altera_avalon_st_pipeline_stage_wr (
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
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwIYenQ3ABZwjBb47Fr2nyJwpeIZeRjYhvdqEbkdFBbcIDfZIc+8rb6pGm5so4Cy2fmXc+RjnOPXYZu0Qp+CImIvHy5/ul3hysext15d1DSaKlxw9L93+zlgGdtUAfsMucfWwXzQDFefATnKd/JQupQLW0029w5qpe8vP9/6b9CQiskc7D34QPETig9A8/jgeS39bCNOfsA5Pl1cV+g9dKRUgN7RtHH8jjVjy60j98uPtXP4GrA5DVWYgTCp4SOE92M9qaaiFA8WgAnWVL88LTzyDtnf41VBzFAR1bwvaJc+z+mulW5Sn7LYWYGZvuafKbR1a6iktz7u2BVhW4Hk2PLMzOjAsQ7pl2p3vN47m8o5dzhKwx9eRs2PlXnhW2TP22pYn/tkQNIXUn+MgF95UKCpfrXUSPVFkPOF0HtuYY7a4ywXCFrYLb0bdac1yoB97Jza0I2lCkDZNCe4jNjRIO6FsBxqqiVBe6vxnL808y9pFEBoYGdID3AdPQ7Zp4w8g34J/SKxM1Z71Culy7o/1W/rYHlLXw7v9zcmUIKNGLCNmTxz/GcJqxKVntAWRkndp+RBBFDjHDfe/xJmu3/gfIEa+LX9cuyrK3VHFqyVDLf0oth+mBmBquffoMyIYjIpab6XaLkiBtIj8YKslDf/cOfy6axCq8+zGAL37gUBAZaiECEWgbsI+hnXeC9oxCmuyZydZCEqGb8/9xsrduK+qTPBVPuFuLl7FR3gQnhDsW/J+/rXi2DBoAusw0sSMW8NEDXN5/ZXt2fzEvP6rIhTAXdR"
`endif