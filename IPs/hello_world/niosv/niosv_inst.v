	niosv u0 (
		.clk_clk                                 (_connected_to_clk_clk_),                                 //   input,   width = 1,                              clk.clk
		.intel_vvp_scaler_0_axi4s_vid_out_tdata  (_connected_to_intel_vvp_scaler_0_axi4s_vid_out_tdata_),  //  output,  width = 24, intel_vvp_scaler_0_axi4s_vid_out.tdata
		.intel_vvp_scaler_0_axi4s_vid_out_tvalid (_connected_to_intel_vvp_scaler_0_axi4s_vid_out_tvalid_), //  output,   width = 1,                                 .tvalid
		.intel_vvp_scaler_0_axi4s_vid_out_tready (_connected_to_intel_vvp_scaler_0_axi4s_vid_out_tready_), //   input,   width = 1,                                 .tready
		.intel_vvp_scaler_0_axi4s_vid_out_tlast  (_connected_to_intel_vvp_scaler_0_axi4s_vid_out_tlast_),  //  output,   width = 1,                                 .tlast
		.intel_vvp_scaler_0_axi4s_vid_out_tuser  (_connected_to_intel_vvp_scaler_0_axi4s_vid_out_tuser_)   //  output,   width = 3,                                 .tuser
	);

