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

module rd_response_mem_cwyib4q #(
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

rd_sipo_plus_cwyib4q #(
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


rd_comp_sel_cwyib4q #(
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

rd_demux_cwyib4q demux ( .index(sel_index), .demuxed(demuxed)  );

generate 
genvar i;
    for (i=0;i<1;i++) begin : MY_LABEL_0
        assign demuxed_valid[i] = demuxed[i] & rsp_valid & rsp_ready;
    end
endgenerate 
rd_mux_cwyib4q #(
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

module rd_demux_cwyib4q (
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


module rd_mux_cwyib4q #(
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02Syy+yg1a6vwR6XRwXfH9PiK8tXeW78zdHVhBU17clZBeIVD9wcZfa2uVNpMYyGqX9bkqGschTZ8Dm49WiPM2h1GKXZ3/B/jq3XLJtRnvXSIKlzW92V7c2IY6CxtYxc5SbfEXAmCHL6IDNZoJPuBn5U4/oRQfQURNZ5E9tXuwciiGLcOKW/ogg9/3Piey30d4O4wlZhliFVbaZsnZd2++J+PW7VykEKRYdiOCxcfBKWkLUWaB6kg54CFORf7+ltfgOp2aE3Fnm7ApxCfY5jYQZCuCRLhXqBOBAJfV+PJu+W1mcrApALW7+2Aw64kBFcOtxLMkJO4MSPvd7YAh5Ji1b2fd9FsmbjRJfsmRVDcmr9BZ5hgCurn/u3oaU0l7YLHBZsnGEsIt2wrgjZRpx0zYV+Vln/bo2mlY98Z8JtnUcwvzoRj7VnEpqFHXodPFpKtR3cCyhqEAPv14JuWwxbEaiLxebGElHYUI98nDcVgs/hQ1v2ljU61pxV419CmXPlZXlJKp1p7wcPTDTk06QcSpAveTcqJqHc/nXuU2/0f2FTmg7j5EgmPyYiUuD3JBtmXmkr0PbZUjt4TL6VesS5sfZcaUBQ7lgIdr4d6XmoTEl2UeZZ8vtzsG8k8Uwprn/0+6NGBshoVOJ7UOX5Hd9O3aXzK0th8E6vR1p/+GOcQ/LHGv0WGq+m61uGYHuJYR/a0A8+98vX5wShmlSBpmZ1qZEdBQExZcne9GfwoUEhhH1fwWqkyYNha8rgX/Sl9ixutUSXIIziIZYwwIR9Bp7bfBaPl"
`endif