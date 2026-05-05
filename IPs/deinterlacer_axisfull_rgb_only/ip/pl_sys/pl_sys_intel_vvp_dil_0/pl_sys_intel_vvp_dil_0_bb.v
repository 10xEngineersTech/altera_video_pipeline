module pl_sys_intel_vvp_dil_0 (
		input  wire        main_clock_clk,       //    main_clock.clk,   Clock Input
		input  wire        main_reset_reset,     //    main_reset.reset
		input  wire [23:0] axi4s_vid_in_tdata,   //  axi4s_vid_in.tdata
		input  wire        axi4s_vid_in_tvalid,  //              .tvalid
		output wire        axi4s_vid_in_tready,  //              .tready
		input  wire        axi4s_vid_in_tlast,   //              .tlast
		input  wire [2:0]  axi4s_vid_in_tuser,   //              .tuser
		output wire [23:0] axi4s_vid_out_tdata,  // axi4s_vid_out.tdata
		output wire        axi4s_vid_out_tvalid, //              .tvalid
		input  wire        axi4s_vid_out_tready, //              .tready
		output wire        axi4s_vid_out_tlast,  //              .tlast
		output wire [2:0]  axi4s_vid_out_tuser   //              .tuser
	);
endmodule

