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

module wr_comp_sel_ehw7rrq #(
    parameter WIDTH=10,
    parameter PIPELINE_OUT=0,
    parameter PIPELINE_CMP=0
) (
    input           clk,
input [WIDTH:0] in_0, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_1, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_2, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_3, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_4, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_5, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_6, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_7, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_8, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_9, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_10, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_11, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_12, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_13, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_14, // MSB=valid, WIDTH-1:0=ID
input [WIDTH:0] in_15, // MSB=valid, WIDTH-1:0=ID

    input [WIDTH-1:0] base,
    input [16-1:0] shift_occurred, // indicates certain data shift shifted
    input [16-1:0] clr,    
    output logic sel,
    output logic [4-1:0] sel_index
);
logic [16-1:0] equal,equal_reg;
logic sel_int;
logic [4-1:0] sel_index_int;
logic [16-1:0] shift_occurred_reg;


compare_eq #( .WIDTH (WIDTH) ) com0 ( .in_a(in_0[WIDTH-1:0]), .in_b(base), .equal(equal[0]) );
compare_eq #( .WIDTH (WIDTH) ) com1 ( .in_a(in_1[WIDTH-1:0]), .in_b(base), .equal(equal[1]) );
compare_eq #( .WIDTH (WIDTH) ) com2 ( .in_a(in_2[WIDTH-1:0]), .in_b(base), .equal(equal[2]) );
compare_eq #( .WIDTH (WIDTH) ) com3 ( .in_a(in_3[WIDTH-1:0]), .in_b(base), .equal(equal[3]) );
compare_eq #( .WIDTH (WIDTH) ) com4 ( .in_a(in_4[WIDTH-1:0]), .in_b(base), .equal(equal[4]) );
compare_eq #( .WIDTH (WIDTH) ) com5 ( .in_a(in_5[WIDTH-1:0]), .in_b(base), .equal(equal[5]) );
compare_eq #( .WIDTH (WIDTH) ) com6 ( .in_a(in_6[WIDTH-1:0]), .in_b(base), .equal(equal[6]) );
compare_eq #( .WIDTH (WIDTH) ) com7 ( .in_a(in_7[WIDTH-1:0]), .in_b(base), .equal(equal[7]) );
compare_eq #( .WIDTH (WIDTH) ) com8 ( .in_a(in_8[WIDTH-1:0]), .in_b(base), .equal(equal[8]) );
compare_eq #( .WIDTH (WIDTH) ) com9 ( .in_a(in_9[WIDTH-1:0]), .in_b(base), .equal(equal[9]) );
compare_eq #( .WIDTH (WIDTH) ) com10 ( .in_a(in_10[WIDTH-1:0]), .in_b(base), .equal(equal[10]) );
compare_eq #( .WIDTH (WIDTH) ) com11 ( .in_a(in_11[WIDTH-1:0]), .in_b(base), .equal(equal[11]) );
compare_eq #( .WIDTH (WIDTH) ) com12 ( .in_a(in_12[WIDTH-1:0]), .in_b(base), .equal(equal[12]) );
compare_eq #( .WIDTH (WIDTH) ) com13 ( .in_a(in_13[WIDTH-1:0]), .in_b(base), .equal(equal[13]) );
compare_eq #( .WIDTH (WIDTH) ) com14 ( .in_a(in_14[WIDTH-1:0]), .in_b(base), .equal(equal[14]) );
compare_eq #( .WIDTH (WIDTH) ) com15 ( .in_a(in_15[WIDTH-1:0]), .in_b(base), .equal(equal[15]) );



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

wr_pri_mux_ehw7rrq pri_mux (
.in0             (equal_reg[0] && in_0[WIDTH]),
.in1             (equal_reg[1] && in_1[WIDTH]),
.in2             (equal_reg[2] && in_2[WIDTH]),
.in3             (equal_reg[3] && in_3[WIDTH]),
.in4             (equal_reg[4] && in_4[WIDTH]),
.in5             (equal_reg[5] && in_5[WIDTH]),
.in6             (equal_reg[6] && in_6[WIDTH]),
.in7             (equal_reg[7] && in_7[WIDTH]),
.in8             (equal_reg[8] && in_8[WIDTH]),
.in9             (equal_reg[9] && in_9[WIDTH]),
.in10             (equal_reg[10] && in_10[WIDTH]),
.in11             (equal_reg[11] && in_11[WIDTH]),
.in12             (equal_reg[12] && in_12[WIDTH]),
.in13             (equal_reg[13] && in_13[WIDTH]),
.in14             (equal_reg[14] && in_14[WIDTH]),
.in15             (equal_reg[15] && in_15[WIDTH]),

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

