	color_space_intel_vvp_csc_0 u0 (
		.main_clock_clk       (_connected_to_main_clock_clk_),       //   input,   width = 1,    main_clock.clk
		.main_reset_reset     (_connected_to_main_reset_reset_),     //   input,   width = 1,    main_reset.reset
		.axi4s_vid_in_tdata   (_connected_to_axi4s_vid_in_tdata_),   //   input,  width = 24,  axi4s_vid_in.tdata
		.axi4s_vid_in_tvalid  (_connected_to_axi4s_vid_in_tvalid_),  //   input,   width = 1,              .tvalid
		.axi4s_vid_in_tready  (_connected_to_axi4s_vid_in_tready_),  //  output,   width = 1,              .tready
		.axi4s_vid_in_tlast   (_connected_to_axi4s_vid_in_tlast_),   //   input,   width = 1,              .tlast
		.axi4s_vid_in_tuser   (_connected_to_axi4s_vid_in_tuser_),   //   input,   width = 3,              .tuser
		.axi4s_vid_out_tdata  (_connected_to_axi4s_vid_out_tdata_),  //  output,  width = 24, axi4s_vid_out.tdata
		.axi4s_vid_out_tvalid (_connected_to_axi4s_vid_out_tvalid_), //  output,   width = 1,              .tvalid
		.axi4s_vid_out_tready (_connected_to_axi4s_vid_out_tready_), //   input,   width = 1,              .tready
		.axi4s_vid_out_tlast  (_connected_to_axi4s_vid_out_tlast_),  //  output,   width = 1,              .tlast
		.axi4s_vid_out_tuser  (_connected_to_axi4s_vid_out_tuser_)   //  output,   width = 3,              .tuser
	);

