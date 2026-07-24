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

module rd_response_mem_kt2puei #(
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

rd_sipo_plus_kt2puei #(
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


rd_comp_sel_kt2puei #(
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

rd_demux_kt2puei demux ( .index(sel_index), .demuxed(demuxed)  );

generate 
genvar i;
    for (i=0;i<1;i++) begin : MY_LABEL_0
        assign demuxed_valid[i] = demuxed[i] & rsp_valid & rsp_ready;
    end
endgenerate 
rd_mux_kt2puei #(
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

module rd_demux_kt2puei (
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


module rd_mux_kt2puei #(
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02Sxt6AQJADW6AXFxOQvfXxM+KOzSJ9HO3LTXx3WPAcx910Ovd+/R/24xmBnIdIYcUzfcV0HuaNvUd5++AmLkgsxC8tKoCyyu6s1fPfC4bAPJOZDO6ObzzCfyouLUBvnYAKKO45nW39JrKfUfvsTOl8UCQpBkcx263ep+CTOyXDuaU/pWc3QLzuHEelo9AxHi/fTi9z7y8eVQAS05qaSrFvWSoMQcbkXd/NZ/CmjX7wCiwzQIj0pHscUk1Mj2kbgupL28H+PbcERsJuukvLAeIHaZWv5Cl+AD1EG8ufWwhdXfrM5Zn0pvFaeeAldUvLoO/BhpzCk0LgxaQ7+d9e3SHjV2aMZTyzyPxSyvnCBZkBwenwpWFHM3NCBq8/8uRjLUotuYGnWsT9zOhZRpEYXj33SHFmaadOmMs7z0b+ydFG3Jmk19rPjV9043WxX+QDgnKYvtPQTruK6xB6eXCjqn21xbpFtQQ2QGOEVNt1tDMiYNIQ9HY3Iaw86DUSCN+Hc75KkiGSgJdKBviQP9evFuh9P2aduJSjI//VGQW+SgMhqS90+9v5lNvuDSP8QiCWoxb6tgDC7qJch0duw+gfDH906wXWabflszWZHvbwmGP5pOkjSTZdxHCh48ThFrA4ArE3670DLYeDdS2ZblwiCHtHXen8WWncbRZJHePNyjp/jEkFQNaGj0Mn/+lg0KOYSM93+yF7hLt24lOJojqVk+RotWR+9jTce6Pum7p315vh6FzYw6mmr0hD3XtLG63rJnO5pKfXKOJfGDEqFJ4qswUD1P"
`endif