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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_1971_o34766q #(
		parameter SYMBOLS_PER_BEAT    = 1,
		parameter BITS_PER_SYMBOL     = 125,
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
		input  wire [124:0] in_data,   
		input  wire         in_valid,  
		output wire         in_ready,  
		output wire [124:0] out_data,  
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
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwLIxPUH7x9V6DDbW7jUk8REp1o6/4Yg2Qj3KQ5638dBuVs/WMRnIxPXEfOcPofEATbRilK6CAD8ONYhY7XjgkF50auLyaJe+BTN3yNTcLpglfxmSwYKDkhPYYocD9yfmeKtdyxwai88O7yDRAC39Uthts/eI5NxcpNBUZsdLfgH/zDGHAOfhmdA3H3TRL7HTjyMRu8nOHVFGZZat6a91j7cMtYr1uEFKCq4rlNYt28v/NbGKU+RnNzt4FkZ+o+Ilkj/8NmUJl9LPWycFH6JP97Xt+rkKFoPvGV0K/o2d8DhtyBJ91q3o0lKE1upz9MKeVcirwOWlv5p3hnqysx+5oMiK6TIJ2UHZt6ZV2N/Y25wVlGMob34mKlMp3HbjrY1AuotlTvQvngf8q4kQ8El5XjPRnqDCyHJOjpJg2pYjMrjn7z3v5BFOP9cq70/EY6+y0AXL86FRcpCVcgL7xC3I2auDFS0HqacGZuJUKGsEt5WvDpcQi9NwKrkHK0zZVs+pk9kzE66yOVfrPhJPt0GfS6VQc5k+mDq1dnidzNxgoIqF4FAr5+lr+ZKYPyXA9ruP7CWw++yjs4L8bBsHmo0eoh4qDdjpPOCv/izH5pqm/pclaTcgdf1mUrmMdeq8b8gM5TwRdxC7nrTzq8TXkCR9kQC0PR5I6mEO0onWJznoRKTG95Uo2PZkv9iAEm/l3ProjvExB8cCyxO2KDnP0JznnUZ2bS5eN46y2UYxVXJwZCELQ7TyiraHduO53J6Ai2R+5HEmhIYIJz3nIc9f9eU9+j/"
`endif