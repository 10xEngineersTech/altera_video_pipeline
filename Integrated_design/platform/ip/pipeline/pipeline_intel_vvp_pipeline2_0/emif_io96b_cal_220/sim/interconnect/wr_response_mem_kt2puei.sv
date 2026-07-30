// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.




`timescale 1ps/1ps

module wr_response_mem_kt2puei #(
    parameter ST_DATA_W = 35,
    parameter ID_W      = 10,
    parameter PIPELINE_OUT = 0,
    parameter PIPELINE_CMP = 0
) ( 
    input                 clk,
    input                 rst,
    input                 in_valid,
    input [ST_DATA_W-1:0] in_data,
    output                in_ready,
    output logic          out_valid,
    output[ST_DATA_W-1:0] out_data,
    input                 out_ready,
    output                cmd_valid,
    output [ID_W-1:0]     cmd_id,
    input                 cmd_ready,
    input                 rsp_valid,
    input [ID_W-1:0]      rsp_id,
    output logic          rsp_ready    
);

localparam PIPELINE_CNT = PIPELINE_OUT + PIPELINE_CMP ;


	  localparam [4:0] depth = 1;
	  localparam [4:0] depth_index = 1;


logic [ST_DATA_W:0] dout0;
logic [1-1:0] sel_index;
logic [1-1 :0] demuxed,demuxed_valid;
logic ready_out_mem;
logic [1 -1 :0] shift_occurred;

wr_sipo_plus_kt2puei #(
    .TOTAL_W (ST_DATA_W+1),
    .ID_W    (ID_W) 
) mem (
    .clk             (clk),
    .rst             (rst),
    .in_valid        (in_valid  & cmd_ready),
    .in_data         (in_data),
    .in_ready       (ready_out_mem),
    .clr             (demuxed_valid), 
    .shift_occurred  (shift_occurred),
    .dout0           (dout0)
);


wr_comp_sel_kt2puei #(
    .PIPELINE_OUT(PIPELINE_OUT),
    .PIPELINE_CMP(PIPELINE_CMP),
    .WIDTH       (ID_W)
) comp_sel (
    .clk            (clk),
    .in_0           ({dout0[ST_DATA_W],dout0[ID_W-1:0]}),
    .base           (rsp_id),
    .shift_occurred (shift_occurred),
    .sel            (),
    .sel_index      (sel_index),
    .clr            (demuxed_valid)
);

wr_demux_kt2puei demux ( .index(sel_index), .demuxed(demuxed)  );

generate 
genvar i;
    for (i=0;i<1;i++) begin : MY_LABEL_0
        assign demuxed_valid[i] = demuxed[i] & rsp_valid & rsp_ready;
    end
endgenerate 
wr_mux_kt2puei #(
    .DATA_W(ST_DATA_W)
) mux (
    .index (sel_index),
    .in0           (dout0[ST_DATA_W-1:0]),
    .muxed (out_data)
);

assign in_ready = ready_out_mem;
generate 
    if (PIPELINE_CMP==1) begin : PPL_1
        always @ (posedge clk) begin
            out_valid <= rsp_valid;
            rsp_ready    <= out_ready;
        end
    end
    else begin : PPL_0
        assign out_valid = rsp_valid;
        assign rsp_ready    = out_ready;
    end
endgenerate


assign cmd_valid = in_valid & in_ready;
assign cmd_id    = in_data[ID_W-1:0];

endmodule

module wr_demux_kt2puei (
    input  [1-1:0] index,
    output [1 -1 :0] demuxed
);

generate 
genvar i;
    for (i=0;i<1;i++) begin : MY_LABEL_1
        assign demuxed[i] = (i==index);
    end
endgenerate
endmodule


module wr_mux_kt2puei #(
    parameter DATA_W = 10
) (
    input [1-1:0] index,

    input  [DATA_W-1:0] in0,

    output logic [DATA_W-1:0] muxed
);
  
always @ * 
    case (index)
     default : muxed = in0;

    endcase

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02Sy+QNNtOUW1I6iNSIUmnDcav9933NhiBFFiw/FmuFBQwvDKrs4HzEjVDYt+s6oJRIZXIYEvmKh58jg9hLStre6wsLklbch3DvHZeSUTgUM2sJdC9lj5HtzSeCn3S/ZVxQLl+B3OOOWaElWKAPzemtOz/crFxfWoeA05NbICGabTWB/0E5HB7JTT0WMWtgLmVbYcurwWKFoGMB7CRT5ni7XN7/jamk80dD8fSVI8tdyHjzaLIBDDCb5Jj0oxfzJTAKWHRV2b5SNTT7wd8ScdUbfi8d+M+HHbxQnVVEYbzKW5VDmAz5EDsujyYneA7/dv2XXV3kCymitVuIXd1HruREEoAONhnHWOqe1hDm2UntzVJgWAPHvjDM1jba4UoOZ5VYLp577jetor/E2vSqGdGV2NVMZxRuoGkq/XbvVE6zQyizzm8SRJ9wlB2yiyLcmdUcZmkTRCQiIpvsvHeiCxvm6pNsKO4O4qFKlM9di9t89Bi+XQDpOBPho+zXSD0gRkDjiut1cpCmv4nnFfKwAs4r71at8BvQuZf5ziO/6Y1MtDxOr77q8MqUZQaF2U0DGkSnfLq3ZcvUGMVV/KCnyTlorrFlBJEGxTAaS5uzySAgYKfc1Aa7cmqgJrhWA/yV8dgkSQqlC/CXKSVIPtSyuz6rGJUUgM5cHa82fFfnuho10aOPIfccZORegNLHFzTqDBSM44OMzbh1rGJ++XienYgQ5AayVy8lbUMTlPTHCSlRNccNN4FzOmej0Oyt7HgwSeWdvpM9HQKt/lWHK2VU3wMr3i"
`endif