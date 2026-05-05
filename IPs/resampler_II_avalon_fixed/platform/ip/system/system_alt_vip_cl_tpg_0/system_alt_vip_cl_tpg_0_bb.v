module system_alt_vip_cl_tpg_0 (
		input  wire        main_clock,         // main_clock.clk,          Clock Input
		input  wire        main_reset,         // main_reset.reset,        Reset Input
		output wire [31:0] dout_data,          //       dout.data
		output wire        dout_valid,         //           .valid
		output wire        dout_startofpacket, //           .startofpacket
		output wire        dout_endofpacket,   //           .endofpacket
		output wire [1:0]  dout_empty,         //           .empty
		input  wire        dout_ready          //           .ready
	);
endmodule

