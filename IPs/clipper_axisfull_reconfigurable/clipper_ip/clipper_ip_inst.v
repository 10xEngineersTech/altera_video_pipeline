	clipper_ip u0 (
		.clk_clk                                               (_connected_to_clk_clk_),                                               //   input,   width = 1,                                     clk.clk
		.intel_vvp_clipper_0_axi4s_vid_out_tdata               (_connected_to_intel_vvp_clipper_0_axi4s_vid_out_tdata_),               //  output,  width = 24,       intel_vvp_clipper_0_axi4s_vid_out.tdata
		.intel_vvp_clipper_0_axi4s_vid_out_tvalid              (_connected_to_intel_vvp_clipper_0_axi4s_vid_out_tvalid_),              //  output,   width = 1,                                        .tvalid
		.intel_vvp_clipper_0_axi4s_vid_out_tready              (_connected_to_intel_vvp_clipper_0_axi4s_vid_out_tready_),              //   input,   width = 1,                                        .tready
		.intel_vvp_clipper_0_axi4s_vid_out_tlast               (_connected_to_intel_vvp_clipper_0_axi4s_vid_out_tlast_),               //  output,   width = 1,                                        .tlast
		.intel_vvp_clipper_0_axi4s_vid_out_tuser               (_connected_to_intel_vvp_clipper_0_axi4s_vid_out_tuser_),               //  output,   width = 3,                                        .tuser
		.intel_vvp_clipper_0_av_mm_control_agent_address       (_connected_to_intel_vvp_clipper_0_av_mm_control_agent_address_),       //   input,   width = 7, intel_vvp_clipper_0_av_mm_control_agent.address
		.intel_vvp_clipper_0_av_mm_control_agent_write         (_connected_to_intel_vvp_clipper_0_av_mm_control_agent_write_),         //   input,   width = 1,                                        .write
		.intel_vvp_clipper_0_av_mm_control_agent_byteenable    (_connected_to_intel_vvp_clipper_0_av_mm_control_agent_byteenable_),    //   input,   width = 4,                                        .byteenable
		.intel_vvp_clipper_0_av_mm_control_agent_writedata     (_connected_to_intel_vvp_clipper_0_av_mm_control_agent_writedata_),     //   input,  width = 32,                                        .writedata
		.intel_vvp_clipper_0_av_mm_control_agent_read          (_connected_to_intel_vvp_clipper_0_av_mm_control_agent_read_),          //   input,   width = 1,                                        .read
		.intel_vvp_clipper_0_av_mm_control_agent_readdata      (_connected_to_intel_vvp_clipper_0_av_mm_control_agent_readdata_),      //  output,  width = 32,                                        .readdata
		.intel_vvp_clipper_0_av_mm_control_agent_readdatavalid (_connected_to_intel_vvp_clipper_0_av_mm_control_agent_readdatavalid_), //  output,   width = 1,                                        .readdatavalid
		.intel_vvp_clipper_0_av_mm_control_agent_waitrequest   (_connected_to_intel_vvp_clipper_0_av_mm_control_agent_waitrequest_),   //  output,   width = 1,                                        .waitrequest
		.reset_reset                                           (_connected_to_reset_reset_)                                            //   input,   width = 1,                                   reset.reset
	);

