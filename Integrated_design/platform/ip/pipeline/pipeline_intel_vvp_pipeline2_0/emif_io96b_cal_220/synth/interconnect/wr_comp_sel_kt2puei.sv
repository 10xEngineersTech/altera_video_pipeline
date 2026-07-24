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

module wr_comp_sel_kt2puei #(
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

wr_pri_mux_kt2puei pri_mux (
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SzpRpzJuZ64EyEF9ATsHdL70d/Zu29jJLKV7nQFiUN/wO9JHIBb7NCBb43N/8hUeUak6OfpdvLAf5sSyj0bOzHlgdW6sVTJi4wfWZCB4Imu5MiOMJ44YlG1QcbcvF+DSXWV+8bjNGd32PI1udrpBQmxyJnXA+/cuH0+t0ghyjQ+BHp8coePooF5Y5bAwEqhVKg8sWe/ygG5kVS96/FlLSvgC6Nsrk/bZo8jw76lh0pzGjYlQQV+sHkzo9OJKODpKERkk8a3RGtGRV7MU3G1NbXlg6sigBJBQUELiMqjmaxJwrLfYP0LXJrMvmv0UKW39JArKsJkcAigHJ7ycyfSsgKGeI4vT9mFsvkbpZ0mBgSFoOSYuv9CfiXrUBJwgH4ai2f8iPjWx9VADJErWOMRbZeM+Qw53yIOWI7Sx0M4BeosgH9a3C0h3xXEwcQc3h2cAAvTjWWCLkcF/zuc7JnpMbozQ/P76n71vXT4LO/NU6X1PJCBqyqw9U7i3gIRmuqMjCCIIlK0N5fBYg1WporixiBuZ++nVDtWUm02SsnIyrC5ftzsYIa+7S+16c6c642QeppYLZ5UYlgsBClTSp4mPwvSQeNSe2VHeoG3yt3jqZRWg/LtDpCGkRXz+JF4A1FtG6SX2LeaDs/AmzyGG85F+FyVFfGJQr5/eB3htDTv/dxNUQ3Qmv+fEFSYRzLj1+3mo26A0EUY12GjBjgcPP3XW0CN2yZEnDHhUUfE/kjkbatShleX/M2V2MztLnwxicp+zmGt7bZiWaf7086CAWSUHqOi"
`endif