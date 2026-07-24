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

module wr_comp_sel_cwyib4q #(
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

wr_pri_mux_cwyib4q pri_mux (
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SxIl/ZYvsmbh/ymQLFJc85ToLtfnU172pblxEo1GjtBssEMT/bpRFFylCGP0JF8jhxEE/cIR84ugXl6DKNwDtPmP5L4vWV0PzTn549SbEr0HM3x22Ys1ZvN5+Uk6ca4BGQ0EApcDnr6vsX+EmoP8KxbdnXjJInNDfjXx5QUpiJVZLeknL6fWRqAAC6lL+KoBtoO7o067MERPnfoZwPaEnGpryzjA9iECFXPidLT6D7gZbjgmYcMY1P7qvPIMrxmhhEc71HQGd1vnQbvzaZyPyn5NQMTBUXICNWD3bkxmr1BbtHfoCDNL/wFKo47q3rov+SFUb2JUjvYzusRWoQLuzrecCeIkjtiv1C+6ecvKsdPEb/5UnXEjBQCgZpZPaSZ64rj7yzDcyCvI0UGXQ4d4cyd2YENTkTiX8sywQ2JE6Oc6POICtL10nbuDYbLNGKueDp4gymmJghukRLjHzNHpC9gwIj5W8hEwoWPftTeKCrINB139KXZwuyRGVd7BJVZvgTbeYAilj/QVPtKivxo8cZaTlyTt2JNn1U9/uYKfv0O+gbHGacMgK9y5FbcJtQedLxdQefxzDhGGNwUjok6qJee2USscbNbC1sJ2V+sWOCLJVz4GShSYfa8Ob7fN1uaKaf7w4jpnX8oUbmhl2b2RD1Pg0HHTHT6LLbnqhdbAw4EOiaQvbENFkOcJoQq22pVqWYhwsS6XOC2OOGZTAJAVQBdWetgxwRXrbYk+/iMm8XtLbRynV6oNZm17nuwyes1sWQO3drqV29hBoFQdlu+Nowu"
`endif