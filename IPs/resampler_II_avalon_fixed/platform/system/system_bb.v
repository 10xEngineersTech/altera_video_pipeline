module system (
		output wire [47:0] alt_vip_cl_crs_0_dout_data,          // alt_vip_cl_crs_0_dout.data
		output wire        alt_vip_cl_crs_0_dout_valid,         //                      .valid
		output wire        alt_vip_cl_crs_0_dout_startofpacket, //                      .startofpacket
		output wire        alt_vip_cl_crs_0_dout_endofpacket,   //                      .endofpacket
		output wire [2:0]  alt_vip_cl_crs_0_dout_empty,         //                      .empty
		input  wire        alt_vip_cl_crs_0_dout_ready,         //                      .ready
		input  wire        clk_clk,                             //                   clk.clk
		input  wire        reset_reset                          //                 reset.reset
	);
endmodule

