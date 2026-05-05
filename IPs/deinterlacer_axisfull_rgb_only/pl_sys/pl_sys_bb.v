module pl_sys (
		input  wire        clk_clk,              //           clk.clk
		output wire [23:0] axi4s_vid_out_tdata,  // axi4s_vid_out.tdata
		output wire        axi4s_vid_out_tvalid, //              .tvalid
		input  wire        axi4s_vid_out_tready, //              .tready
		output wire        axi4s_vid_out_tlast,  //              .tlast
		output wire [2:0]  axi4s_vid_out_tuser,  //              .tuser
		input  wire        reset_reset           //         reset.reset
	);
endmodule

