	system_alt_vip_cl_tpg_0 u0 (
		.main_clock         (_connected_to_main_clock_),         //   input,   width = 1, main_clock.clk
		.main_reset         (_connected_to_main_reset_),         //   input,   width = 1, main_reset.reset
		.dout_data          (_connected_to_dout_data_),          //  output,  width = 32,       dout.data
		.dout_valid         (_connected_to_dout_valid_),         //  output,   width = 1,           .valid
		.dout_startofpacket (_connected_to_dout_startofpacket_), //  output,   width = 1,           .startofpacket
		.dout_endofpacket   (_connected_to_dout_endofpacket_),   //  output,   width = 1,           .endofpacket
		.dout_empty         (_connected_to_dout_empty_),         //  output,   width = 2,           .empty
		.dout_ready         (_connected_to_dout_ready_)          //   input,   width = 1,           .ready
	);

