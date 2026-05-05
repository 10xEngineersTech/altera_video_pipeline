module system_alt_vip_cl_crs_0 (
		input  wire        main_clock,         // main_clock.clk,          Clock Input
		input  wire        main_reset,         // main_reset.reset,        Reset Input
		input  wire [31:0] din_data,           //        din.data
		input  wire        din_valid,          //           .valid
		input  wire        din_startofpacket,  //           .startofpacket
		input  wire        din_endofpacket,    //           .endofpacket
		input  wire [1:0]  din_empty,          //           .empty
		output wire        din_ready,          //           .ready
		output wire [47:0] dout_data,          //       dout.data
		output wire        dout_valid,         //           .valid
		output wire        dout_startofpacket, //           .startofpacket
		output wire        dout_endofpacket,   //           .endofpacket
		output wire [2:0]  dout_empty,         //           .empty
		input  wire        dout_ready          //           .ready
	);
endmodule

