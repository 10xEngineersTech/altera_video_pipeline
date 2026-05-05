	system u0 (
		.alt_vip_cl_crs_0_dout_data          (_connected_to_alt_vip_cl_crs_0_dout_data_),          //  output,  width = 48, alt_vip_cl_crs_0_dout.data
		.alt_vip_cl_crs_0_dout_valid         (_connected_to_alt_vip_cl_crs_0_dout_valid_),         //  output,   width = 1,                      .valid
		.alt_vip_cl_crs_0_dout_startofpacket (_connected_to_alt_vip_cl_crs_0_dout_startofpacket_), //  output,   width = 1,                      .startofpacket
		.alt_vip_cl_crs_0_dout_endofpacket   (_connected_to_alt_vip_cl_crs_0_dout_endofpacket_),   //  output,   width = 1,                      .endofpacket
		.alt_vip_cl_crs_0_dout_empty         (_connected_to_alt_vip_cl_crs_0_dout_empty_),         //  output,   width = 3,                      .empty
		.alt_vip_cl_crs_0_dout_ready         (_connected_to_alt_vip_cl_crs_0_dout_ready_),         //   input,   width = 1,                      .ready
		.clk_clk                             (_connected_to_clk_clk_),                             //   input,   width = 1,                   clk.clk
		.reset_reset                         (_connected_to_reset_reset_)                          //   input,   width = 1,                 reset.reset
	);

