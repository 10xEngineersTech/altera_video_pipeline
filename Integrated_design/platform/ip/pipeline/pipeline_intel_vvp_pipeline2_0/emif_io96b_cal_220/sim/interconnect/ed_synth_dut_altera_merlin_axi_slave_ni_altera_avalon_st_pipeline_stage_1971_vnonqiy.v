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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_vnonqiy #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 124,
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
		input  wire [123:0] in_data,           
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [123:0] out_data           
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
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwIjp7248z5a5jz2moLgXjc3B1gP4mlrymYDNmsjiDyVEnqn6kYdGxd0n6/1pFCzYyy4GDqUFqeMuinvlFjaFZkb/KWfpFIfSvnp+nuxxinLXKPh6ciWZjaDtWfKuVMggYZJJvxaWD0iDgaKDZVqFECX//DvLsOdubYDGEXFysbu0/EvWLf9x2/KJMlHQSj2zqaW7WkH5/q+duZnK2ryEiHiM9DaVDcnJneg+PESM3UsQcRwxMaMCJ5buGiABETdNlI087B6UjiXvOsUvfag+EyjjnZKW9JuhjdKabaSwPveKCMSLfZaXrA/Ef0blajx2OwXRYW4KRvQ23vNq+690JCTD8tzvg6/ceEIxKvv9/1GAkaJ5aKWgSpwUhKQHZBsPgPQXPDxyxbFOSu/omMJeuuWNyZ7phBOkxPQ0Dv9tiYUP4BugX9Kz6bqtXcSR/iUgVBZxw+//rF7Lxu0SQBnUhs7vHBr8HTzIIcLOEw10s18NCpDbTcfNcS4NuIdCf9zZV3Q4r0vJxxiytMI948DgGgTU6WQwkZfYrI/r8zSzmpPEeiLy896+aEXxVwkv5tWAUTEm3Whr1G8kmQXyDNMv382kqeDvIl5eE9mLlXeKw0lodx0rWvCtKkLy+tvsKSUz2MpvpEnlZysODQdosQIEO32n8pnRMEZUXN9dH3P1sW/2STJ6NGh9JKvfpWrdYRNvxxPogPdwttrbalBa8vzDj0WN6x6XOhLNucHYvYvXEsTQlXKv4oH4zZZ+tfAsm+m7uAV3+1oXNfVPZPdtjFzYJoL"
`endif