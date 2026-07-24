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
module ed_synth_dut_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_7ekoqry #(
		parameter SYMBOLS_PER_BEAT    = 1,
		parameter BITS_PER_SYMBOL     = 4,
		parameter FIFO_DEPTH          = 6,
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
		input  wire       clk,       
		input  wire       reset,     
		input  wire [3:0] in_data,   
		input  wire       in_valid,  
		output wire       in_ready,  
		output wire [3:0] out_data,  
		output wire       out_valid, 
		input  wire       out_ready  
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
	) my_altera_avalon_sc_fifo_dest_id_fifo (
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02Sxs0yU8GUJTsPcydf15U6Bx3AA6xcGbQzEhjIgz34BgSgUp21OFpjubD+oMZ9E8AyuRVq/38QVC102SUH4lVqNOItvJp7EirU3THGzSrslCWvSQLGZKcS0u84zvw86GigPlUHCSJ2Ya0D2ijlm+8flMssnrcoYc9WJ96I2mLfHCv+1gxaa5lktTV7GGcrpYcRv/ZfTWg35RwwsYxqhuXKioXpn509mx/8Z0nDrsrUOzMGWlfFSmHsLYjMCINh/Q5LHOkyfckH+s7LnhZmKgW+/6MlqV4g0jf2UjEBTrB07LcdOMCbBgSV070EBcXnfuExiDb/59aXFT7bCyDSG+w0zEo1ExJ5v8G045BVGpND/vzDS+kRVeK50tVPDaa4a72rEeQbiAfscuEyy2TM1Pc6UHHpas5HZEyrUoMzKHPswwklQVGS39+82XiYC3rICQ/PxCfx7Jyz7EKTxeJE//6DUGsHmv9+5ovj79tVSC3ySTq9RrEp6U1BUQdef3Y4Cpz296L5PbKYfSOUQFeG/XSOv6h5EnijzGAnNp2V2db2gB/z7Q1tECsntQNpw0S6N92K1jgJoaissV8TFe0tVGxWGwFG60rTSQvDhBqxBcumM07Erw6nJRBKPV8f5ttFFo31c9AK671CfT97L43wiAawatF2lBj/4WCeRt9GaStYv59BjcuQM3oqrrvT3Ki7lKMTQnct1DaS7Iw1HLcGL6IQreoM1JmUNmfzwLa72F/YSObStc2Yl5p5WOU0HTWUXssxrz2Kc9TuHYquCKMrid2MSr"
`endif