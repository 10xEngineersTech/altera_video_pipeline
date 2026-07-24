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

module rd_comp_sel_kt2puei #(
    parameter WIDTH=10,
    parameter PIPELINE_OUT=0,
    parameter PIPELINE_CMP=0
) (
    input           clk,
input [WIDTH:0] in_0, 

    input [WIDTH-1:0] base,
    input [1-1:0] shift_occurred, 
    input [1-1:0] clr,    
    output logic sel,
    output logic [1-1:0] sel_index
);
logic [1-1:0] equal,equal_reg;
logic sel_int;
logic [1-1:0] sel_index_int;
logic [1-1:0] shift_occurred_reg;


compare_eq #( .WIDTH (WIDTH) ) com0 ( .in_a(in_0[WIDTH-1:0]), .in_b(base), .equal(equal[0]) );



generate 
    if (PIPELINE_CMP) begin : PIPELINE_CMP_OUT
        always @ (posedge clk) begin
            equal_reg <= equal;
            shift_occurred_reg <= shift_occurred;
        end
    end
    else begin : NO_PIPELINE_CMP_OUT
        assign equal_reg = equal;
        assign shift_occurred_reg = shift_occurred;
    end
endgenerate

rd_pri_mux_kt2puei pri_mux (
.in0             (equal_reg[0] && in_0[WIDTH]),

    .shift_index_out (shift_occurred_reg),
    .sel             (sel_int),
    .sel_index       (sel_index_int),
    .clr             (clr)

);

generate
    if (PIPELINE_OUT) begin
        always @ (posedge clk) begin
            sel       <= sel_int;
            sel_index <= sel_index_int;
        end
    end
    else begin
        assign sel = sel_int;
        assign sel_index = sel_index_int;
    end
endgenerate 
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SwPjz5sz1LTa7JVlajxvWa0u7rshIMNRChW/I887SFa39Ctw7iuc0qbHjtyuY6JZwYs4InCRF2eTNdG9yYrsLkPUL5MVorfLuWdDgmZYictAaSEH+TY5gTJmt/sVVd9xKhMjDt3Sqj88rG7Hp+cxGo4P/xCdQUqr6Qe/Z2obEtzZvg70az8MeGNz40nioDU/MDSyTX2yqDy5qM6XLmxLGdSXB4WsZ6ONvlXXepouRyvgUmMHJd3KJIhWf17ZI+DQdrS04T3EonTb0v9vpmZTqMX9aBq1zwXe8Howub8yLHHWEMbyMo3iVv0zT1ugg1TRMFyo8dnE31TZNpAPwxlS0LOqkMng6z/8Kh3YAUKFytUUxz87rdrpN52ZhUfRnU719tN+xnpQaOv6DocS4/ALal+ML37mmZfC+Q3nZs8EYu5yLOaACT+M8eLR7kFjckWQG7Yo5DSjcIp7uId6J7kde9tmO96AEYDPSJLyOFzonRb5irAFFJTZsUMAkq5hpzuJQ9nrW2U9DFHPu+VQp+zS3rhMFpKRgAR98dpoyzURd5k9o565Gjd2rWsmDWYfl4+hSNMMa9nkPenUnoMTdUUy2ZbO7JgxAMRtVk8CNZenUzFKnzGPP6YlDJ6jsoWTa2W+7V9GFPMOoDTYOx53id3zR8GRa5p0r4BrAZ/kmZi3qRF/t8NkkTMAfE9ZaK6mSu3vesOfc1fiR75xTtC3R5sgl6SItKk+Gr0mphX/Zs/r1YLeiYSmHzJjjqnE0TivTacFBaIN69NjP90ioUwxn1eW3io"
`endif