module system (
		input  wire        clk_clk,                                             //                                   clk.clk
		output wire [23:0] intel_vvp_mixer_0_axi4s_vid_out_tdata,               //       intel_vvp_mixer_0_axi4s_vid_out.tdata
		output wire        intel_vvp_mixer_0_axi4s_vid_out_tvalid,              //                                      .tvalid
		input  wire        intel_vvp_mixer_0_axi4s_vid_out_tready,              //                                      .tready
		output wire        intel_vvp_mixer_0_axi4s_vid_out_tlast,               //                                      .tlast
		output wire [2:0]  intel_vvp_mixer_0_axi4s_vid_out_tuser,               //                                      .tuser
		input  wire [7:0]  intel_vvp_mixer_0_av_mm_control_agent_address,       // intel_vvp_mixer_0_av_mm_control_agent.address
		input  wire        intel_vvp_mixer_0_av_mm_control_agent_write,         //                                      .write
		input  wire [3:0]  intel_vvp_mixer_0_av_mm_control_agent_byteenable,    //                                      .byteenable
		input  wire [31:0] intel_vvp_mixer_0_av_mm_control_agent_writedata,     //                                      .writedata
		input  wire        intel_vvp_mixer_0_av_mm_control_agent_read,          //                                      .read
		output wire [31:0] intel_vvp_mixer_0_av_mm_control_agent_readdata,      //                                      .readdata
		output wire        intel_vvp_mixer_0_av_mm_control_agent_readdatavalid, //                                      .readdatavalid
		output wire        intel_vvp_mixer_0_av_mm_control_agent_waitrequest,   //                                      .waitrequest
		input  wire [6:0]  intel_vvp_tpg_0_av_mm_control_agent_address,         //   intel_vvp_tpg_0_av_mm_control_agent.address
		input  wire        intel_vvp_tpg_0_av_mm_control_agent_write,           //                                      .write
		input  wire [3:0]  intel_vvp_tpg_0_av_mm_control_agent_byteenable,      //                                      .byteenable
		input  wire [31:0] intel_vvp_tpg_0_av_mm_control_agent_writedata,       //                                      .writedata
		input  wire        intel_vvp_tpg_0_av_mm_control_agent_read,            //                                      .read
		output wire [31:0] intel_vvp_tpg_0_av_mm_control_agent_readdata,        //                                      .readdata
		output wire        intel_vvp_tpg_0_av_mm_control_agent_readdatavalid,   //                                      .readdatavalid
		output wire        intel_vvp_tpg_0_av_mm_control_agent_waitrequest,     //                                      .waitrequest
		input  wire [6:0]  intel_vvp_tpg_1_av_mm_control_agent_address,         //   intel_vvp_tpg_1_av_mm_control_agent.address
		input  wire        intel_vvp_tpg_1_av_mm_control_agent_write,           //                                      .write
		input  wire [3:0]  intel_vvp_tpg_1_av_mm_control_agent_byteenable,      //                                      .byteenable
		input  wire [31:0] intel_vvp_tpg_1_av_mm_control_agent_writedata,       //                                      .writedata
		input  wire        intel_vvp_tpg_1_av_mm_control_agent_read,            //                                      .read
		output wire [31:0] intel_vvp_tpg_1_av_mm_control_agent_readdata,        //                                      .readdata
		output wire        intel_vvp_tpg_1_av_mm_control_agent_readdatavalid,   //                                      .readdatavalid
		output wire        intel_vvp_tpg_1_av_mm_control_agent_waitrequest,     //                                      .waitrequest
		input  wire [6:0]  intel_vvp_tpg_2_av_mm_control_agent_address,         //   intel_vvp_tpg_2_av_mm_control_agent.address
		input  wire        intel_vvp_tpg_2_av_mm_control_agent_write,           //                                      .write
		input  wire [3:0]  intel_vvp_tpg_2_av_mm_control_agent_byteenable,      //                                      .byteenable
		input  wire [31:0] intel_vvp_tpg_2_av_mm_control_agent_writedata,       //                                      .writedata
		input  wire        intel_vvp_tpg_2_av_mm_control_agent_read,            //                                      .read
		output wire [31:0] intel_vvp_tpg_2_av_mm_control_agent_readdata,        //                                      .readdata
		output wire        intel_vvp_tpg_2_av_mm_control_agent_readdatavalid,   //                                      .readdatavalid
		output wire        intel_vvp_tpg_2_av_mm_control_agent_waitrequest,     //                                      .waitrequest
		input  wire [6:0]  intel_vvp_tpg_3_av_mm_control_agent_address,         //   intel_vvp_tpg_3_av_mm_control_agent.address
		input  wire        intel_vvp_tpg_3_av_mm_control_agent_write,           //                                      .write
		input  wire [3:0]  intel_vvp_tpg_3_av_mm_control_agent_byteenable,      //                                      .byteenable
		input  wire [31:0] intel_vvp_tpg_3_av_mm_control_agent_writedata,       //                                      .writedata
		input  wire        intel_vvp_tpg_3_av_mm_control_agent_read,            //                                      .read
		output wire [31:0] intel_vvp_tpg_3_av_mm_control_agent_readdata,        //                                      .readdata
		output wire        intel_vvp_tpg_3_av_mm_control_agent_readdatavalid,   //                                      .readdatavalid
		output wire        intel_vvp_tpg_3_av_mm_control_agent_waitrequest,     //                                      .waitrequest
		input  wire [6:0]  intel_vvp_tpg_4_av_mm_control_agent_address,         //   intel_vvp_tpg_4_av_mm_control_agent.address
		input  wire        intel_vvp_tpg_4_av_mm_control_agent_write,           //                                      .write
		input  wire [3:0]  intel_vvp_tpg_4_av_mm_control_agent_byteenable,      //                                      .byteenable
		input  wire [31:0] intel_vvp_tpg_4_av_mm_control_agent_writedata,       //                                      .writedata
		input  wire        intel_vvp_tpg_4_av_mm_control_agent_read,            //                                      .read
		output wire [31:0] intel_vvp_tpg_4_av_mm_control_agent_readdata,        //                                      .readdata
		output wire        intel_vvp_tpg_4_av_mm_control_agent_readdatavalid,   //                                      .readdatavalid
		output wire        intel_vvp_tpg_4_av_mm_control_agent_waitrequest,     //                                      .waitrequest
		input  wire [6:0]  intel_vvp_tpg_5_av_mm_control_agent_address,         //   intel_vvp_tpg_5_av_mm_control_agent.address
		input  wire        intel_vvp_tpg_5_av_mm_control_agent_write,           //                                      .write
		input  wire [3:0]  intel_vvp_tpg_5_av_mm_control_agent_byteenable,      //                                      .byteenable
		input  wire [31:0] intel_vvp_tpg_5_av_mm_control_agent_writedata,       //                                      .writedata
		input  wire        intel_vvp_tpg_5_av_mm_control_agent_read,            //                                      .read
		output wire [31:0] intel_vvp_tpg_5_av_mm_control_agent_readdata,        //                                      .readdata
		output wire        intel_vvp_tpg_5_av_mm_control_agent_readdatavalid,   //                                      .readdatavalid
		output wire        intel_vvp_tpg_5_av_mm_control_agent_waitrequest,     //                                      .waitrequest
		input  wire [6:0]  intel_vvp_tpg_6_av_mm_control_agent_address,         //   intel_vvp_tpg_6_av_mm_control_agent.address
		input  wire        intel_vvp_tpg_6_av_mm_control_agent_write,           //                                      .write
		input  wire [3:0]  intel_vvp_tpg_6_av_mm_control_agent_byteenable,      //                                      .byteenable
		input  wire [31:0] intel_vvp_tpg_6_av_mm_control_agent_writedata,       //                                      .writedata
		input  wire        intel_vvp_tpg_6_av_mm_control_agent_read,            //                                      .read
		output wire [31:0] intel_vvp_tpg_6_av_mm_control_agent_readdata,        //                                      .readdata
		output wire        intel_vvp_tpg_6_av_mm_control_agent_readdatavalid,   //                                      .readdatavalid
		output wire        intel_vvp_tpg_6_av_mm_control_agent_waitrequest,     //                                      .waitrequest
		input  wire [6:0]  intel_vvp_tpg_7_av_mm_control_agent_address,         //   intel_vvp_tpg_7_av_mm_control_agent.address
		input  wire        intel_vvp_tpg_7_av_mm_control_agent_write,           //                                      .write
		input  wire [3:0]  intel_vvp_tpg_7_av_mm_control_agent_byteenable,      //                                      .byteenable
		input  wire [31:0] intel_vvp_tpg_7_av_mm_control_agent_writedata,       //                                      .writedata
		input  wire        intel_vvp_tpg_7_av_mm_control_agent_read,            //                                      .read
		output wire [31:0] intel_vvp_tpg_7_av_mm_control_agent_readdata,        //                                      .readdata
		output wire        intel_vvp_tpg_7_av_mm_control_agent_readdatavalid,   //                                      .readdatavalid
		output wire        intel_vvp_tpg_7_av_mm_control_agent_waitrequest,     //                                      .waitrequest
		input  wire        reset_reset                                          //                                 reset.reset
	);
endmodule

