module niosv (
		input  wire        clk_clk,                                 //                              clk.clk
		output wire [23:0] intel_vvp_scaler_0_axi4s_vid_out_tdata,  // intel_vvp_scaler_0_axi4s_vid_out.tdata
		output wire        intel_vvp_scaler_0_axi4s_vid_out_tvalid, //                                 .tvalid
		input  wire        intel_vvp_scaler_0_axi4s_vid_out_tready, //                                 .tready
		output wire        intel_vvp_scaler_0_axi4s_vid_out_tlast,  //                                 .tlast
		output wire [2:0]  intel_vvp_scaler_0_axi4s_vid_out_tuser   //                                 .tuser
	);
endmodule

