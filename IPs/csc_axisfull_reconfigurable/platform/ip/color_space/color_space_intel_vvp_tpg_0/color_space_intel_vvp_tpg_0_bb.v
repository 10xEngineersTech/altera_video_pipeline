module color_space_intel_vvp_tpg_0 (
		input  wire        main_clock_clk,       //    main_clock.clk,   Clock Input
		input  wire        main_reset_reset,     //    main_reset.reset
		output wire [23:0] axi4s_vid_out_tdata,  // axi4s_vid_out.tdata
		output wire        axi4s_vid_out_tvalid, //              .tvalid
		input  wire        axi4s_vid_out_tready, //              .tready
		output wire        axi4s_vid_out_tlast,  //              .tlast
		output wire [2:0]  axi4s_vid_out_tuser   //              .tuser
	);
endmodule

