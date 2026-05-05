`timescale 1ns/10ps

module top
		(input clk,
		 input reset,
		 output [23:0] m_axis_tdata,
		 output 			m_axis_tvalid,
		 input 			m_axis_tready,
		 output 			m_axis_tlast,
		 output [2:0]	m_axis_tuser);
    
	 
	 
	 pl_sys u0 (
        .clk_clk              (clk),              	//   input,   width = 1,           clk.clk
        .axi4s_vid_out_tdata  (m_axis_tdata),  		//  output,  width = 24, axi4s_vid_out.tdata
        .axi4s_vid_out_tvalid (m_axis_tvalid), 		//  output,   width = 1,              .tvalid
        .axi4s_vid_out_tready (m_axis_tready), 		//   input,   width = 1,              .tready
        .axi4s_vid_out_tlast  (m_axis_tlast),  		//  output,   width = 1,              .tlast
        .axi4s_vid_out_tuser  (m_axis_tuser),  		//  output,   width = 3,              .tuser
        .reset_reset          (reset)           	//   input,   width = 1,         reset.reset
    );

	
endmodule