module tpg_ip_intel_vvp_tpg_0 (
		input  wire        main_clock_clk,                    //          main_clock.clk,          Clock Input
		input  wire        main_reset_reset,                  //          main_reset.reset
		output wire [23:0] axi4s_vid_out_tdata,               //       axi4s_vid_out.tdata
		output wire        axi4s_vid_out_tvalid,              //                    .tvalid
		input  wire        axi4s_vid_out_tready,              //                    .tready
		output wire        axi4s_vid_out_tlast,               //                    .tlast
		output wire [2:0]  axi4s_vid_out_tuser,               //                    .tuser
		input  wire [6:0]  av_mm_control_agent_address,       // av_mm_control_agent.address
		input  wire        av_mm_control_agent_write,         //                    .write
		input  wire [3:0]  av_mm_control_agent_byteenable,    //                    .byteenable
		input  wire [31:0] av_mm_control_agent_writedata,     //                    .writedata
		input  wire        av_mm_control_agent_read,          //                    .read
		output wire [31:0] av_mm_control_agent_readdata,      //                    .readdata
		output wire        av_mm_control_agent_readdatavalid, //                    .readdatavalid
		output wire        av_mm_control_agent_waitrequest    //                    .waitrequest
	);
endmodule

