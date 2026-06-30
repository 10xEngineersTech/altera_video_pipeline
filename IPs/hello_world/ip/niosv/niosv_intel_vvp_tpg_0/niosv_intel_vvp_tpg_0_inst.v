	niosv_intel_vvp_tpg_0 u0 (
		.main_clock_clk                    (_connected_to_main_clock_clk_),                    //   input,   width = 1,          main_clock.clk
		.main_reset_reset                  (_connected_to_main_reset_reset_),                  //   input,   width = 1,          main_reset.reset
		.axi4s_vid_out_tdata               (_connected_to_axi4s_vid_out_tdata_),               //  output,  width = 24,       axi4s_vid_out.tdata
		.axi4s_vid_out_tvalid              (_connected_to_axi4s_vid_out_tvalid_),              //  output,   width = 1,                    .tvalid
		.axi4s_vid_out_tready              (_connected_to_axi4s_vid_out_tready_),              //   input,   width = 1,                    .tready
		.axi4s_vid_out_tlast               (_connected_to_axi4s_vid_out_tlast_),               //  output,   width = 1,                    .tlast
		.axi4s_vid_out_tuser               (_connected_to_axi4s_vid_out_tuser_),               //  output,   width = 3,                    .tuser
		.av_mm_control_agent_address       (_connected_to_av_mm_control_agent_address_),       //   input,   width = 7, av_mm_control_agent.address
		.av_mm_control_agent_write         (_connected_to_av_mm_control_agent_write_),         //   input,   width = 1,                    .write
		.av_mm_control_agent_byteenable    (_connected_to_av_mm_control_agent_byteenable_),    //   input,   width = 4,                    .byteenable
		.av_mm_control_agent_writedata     (_connected_to_av_mm_control_agent_writedata_),     //   input,  width = 32,                    .writedata
		.av_mm_control_agent_read          (_connected_to_av_mm_control_agent_read_),          //   input,   width = 1,                    .read
		.av_mm_control_agent_readdata      (_connected_to_av_mm_control_agent_readdata_),      //  output,  width = 32,                    .readdata
		.av_mm_control_agent_readdatavalid (_connected_to_av_mm_control_agent_readdatavalid_), //  output,   width = 1,                    .readdatavalid
		.av_mm_control_agent_waitrequest   (_connected_to_av_mm_control_agent_waitrequest_)    //  output,   width = 1,                    .waitrequest
	);

