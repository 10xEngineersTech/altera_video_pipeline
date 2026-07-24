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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_1971_ysgnmwa #(
		parameter SYMBOLS_PER_BEAT    = 1,
		parameter BITS_PER_SYMBOL     = 189,
		parameter FIFO_DEPTH          = 1,
		parameter CHANNEL_WIDTH       = 0,
		parameter ERROR_WIDTH         = 0,
		parameter USE_PACKETS         = 0,
		parameter USE_FILL_LEVEL      = 0,
		parameter EMPTY_LATENCY       = 1,
		parameter USE_MEMORY_BLOCKS   = 0,
		parameter USE_STORE_FORWARD   = 0,
		parameter USE_ALMOST_FULL_IF  = 0,
		parameter USE_ALMOST_EMPTY_IF = 0,
		parameter EMPTY_WIDTH         = 1,
		parameter SYNC_RESET          = 0
	) (
		input  wire         clk,       
		input  wire         reset,     
		input  wire [188:0] in_data,   
		input  wire         in_valid,  
		output wire         in_ready,  
		output wire [188:0] out_data,  
		output wire         out_valid, 
		input  wire         out_ready  
	);

	generate
		if (EMPTY_WIDTH != 1)
		begin
		// synthesis translate_off
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
		//  synthesis translate_on
			instantiated_with_wrong_parameters_error_see_comment_above
					empty_width_check ( .error(1'b1) );
		end
		if (SYNC_RESET != 0)
		begin
		//  synthesis translate_off
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
		//  synthesis translate_on
			instantiated_with_wrong_parameters_error_see_comment_above
					sync_reset_check ( .error(1'b1) );
		end
	endgenerate

	ed_synth_dut_altera_avalon_sc_fifo_1931_fzgstwy #(
		.SYMBOLS_PER_BEAT    (SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL     (BITS_PER_SYMBOL),
		.FIFO_DEPTH          (FIFO_DEPTH),
		.CHANNEL_WIDTH       (CHANNEL_WIDTH),
		.ERROR_WIDTH         (ERROR_WIDTH),
		.USE_PACKETS         (USE_PACKETS),
		.USE_FILL_LEVEL      (USE_FILL_LEVEL),
		.EMPTY_LATENCY       (EMPTY_LATENCY),
		.USE_MEMORY_BLOCKS   (USE_MEMORY_BLOCKS),
		.USE_STORE_FORWARD   (USE_STORE_FORWARD),
		.USE_ALMOST_FULL_IF  (USE_ALMOST_FULL_IF),
		.USE_ALMOST_EMPTY_IF (USE_ALMOST_EMPTY_IF),
		.EMPTY_WIDTH         (1),
		.SYNC_RESET          (0)
	) my_altera_avalon_sc_fifo_wr (
		.clk               (clk),                                  
		.reset             (reset),                                
		.in_data           (in_data),                              
		.in_valid          (in_valid),                             
		.in_ready          (in_ready),                             
		.out_data          (out_data),                             
		.out_valid         (out_valid),                            
		.out_ready         (out_ready),                            
		.csr_address       (2'b00),                                
		.csr_read          (1'b0),                                 
		.csr_write         (1'b0),                                 
		.csr_readdata      (),                                     
		.csr_writedata     (32'b00000000000000000000000000000000), 
		.almost_full_data  (),                                     
		.almost_empty_data (),                                     
		.in_startofpacket  (1'b0),                                 
		.in_endofpacket    (1'b0),                                 
		.out_startofpacket (),                                     
		.out_endofpacket   (),                                     
		.in_empty          (1'b0),                                 
		.out_empty         (),                                     
		.in_error          (1'b0),                                 
		.out_error         (),                                     
		.in_channel        (1'b0),                                 
		.out_channel       ()                                      
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwJGmJGIv4u61MrNG0ezjdpHBE9e1rtEiHP1+8pdajha4l43jSeoq8EuBXgxJt8XAOIGm2qCRhGAM+OEvTnmSa3l73Znpnjjdt5SimT877afejVCTTHwlzWZlhAnv00uMfGDCDvgR7kdqyGz28JRtaxg+QSjbAy30eZ/2ztWECSnnWHxUTUl7lc+wD1klyWnyDzhFqmilOKwkSAZuHfIfMhqZPqSnlt08KEj7wLezzAqgftOu2kU3qJ//hh8j1ByBXObASQOpxjHpaZ1LCQcyu3GW9mafOL7y4oONcM2VaCNOAYToAwoaSkvRhHmqrOkEXeqgZNuDB0GOHQNfC9c7xVLBhODL/2J6BinJfvGeyf4K8tU/ZqJ9lV7QrW0Tdj7D+Tt5hyDq0F+sAcwXC0J2YGfUfzlXAnW0EMUxQEJQnAXzK7DdnqcqPg1+KmpteIcjha/K7fPhfidgT36GmzMXgyw/sRhwqq0Os64IX2OmqboIJ9QY+Ojn3twnyn5WhU0PUqlH6RejM9qKSkuwoHCs/Ae4vmvErQwOF0xiURwiQVl21+3SobdK8WgbFThxKLeqG3z1TvXQszwD21WROVvvr/UUVZeJUCkLepUU2gDHmf+2MM1vHQVyZS5OFbqbUHx6Pi7HoCjhO82Qw8agjA1s2cmChSLN82mFsBn5rU8Yi1M1S93dBSNTx/LpfL+ISJpZxzKPvytC6gAFEbBYNXW37CspAs++WbExBv4i/vmUr+9tjA0n9UNTnG/RM07fj1F6vLQQdpdGGC5VK5D4xNJuzni"
`endif