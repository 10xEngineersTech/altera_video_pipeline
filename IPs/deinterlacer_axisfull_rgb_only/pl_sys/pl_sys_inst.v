	pl_sys u0 (
		.clk_clk              (_connected_to_clk_clk_),              //   input,   width = 1,           clk.clk
		.axi4s_vid_out_tdata  (_connected_to_axi4s_vid_out_tdata_),  //  output,  width = 24, axi4s_vid_out.tdata
		.axi4s_vid_out_tvalid (_connected_to_axi4s_vid_out_tvalid_), //  output,   width = 1,              .tvalid
		.axi4s_vid_out_tready (_connected_to_axi4s_vid_out_tready_), //   input,   width = 1,              .tready
		.axi4s_vid_out_tlast  (_connected_to_axi4s_vid_out_tlast_),  //  output,   width = 1,              .tlast
		.axi4s_vid_out_tuser  (_connected_to_axi4s_vid_out_tuser_),  //  output,   width = 3,              .tuser
		.reset_reset          (_connected_to_reset_reset_)           //   input,   width = 1,         reset.reset
	);

