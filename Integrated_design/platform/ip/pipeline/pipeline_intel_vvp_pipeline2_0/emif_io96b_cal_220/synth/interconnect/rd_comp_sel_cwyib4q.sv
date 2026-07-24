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

module rd_comp_sel_cwyib4q #(
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

rd_pri_mux_cwyib4q pri_mux (
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SyAUzKux8SxNX3/Qp+5+RsWyGb4vJ/KNRLazQCueAeLgOg2q6f16GKD2Ca8xXjqWZzHxTnZy/WMb2Yvy1n7aFUasM9AVnAGaRg/Ui0CrwZgWdXDM4vE92jzDY8U3Me9d58kC0A8uRJKAAr4LizhnvuvLJv+tkskLZnkqB7PwOgXQYXroGt0PFeOWXP2K764/ZoFOY861Bfx/MhqNdw8HtyaNTsVhcfg6dczLavCURxl4L5pxq2ciSphgdp0lNc4CNRZMcodhoFVvwI4OelA0RTniePw8uJS1WdzgB0n0T8wfzD9uNI2Bcf5hb9JZMx7Zq4DXuyhtxA1QjrvAu1hvMg1vT2ajCJp6Jj19gnJzQpKmx4CjRYKNP7jr69HupRM3PFJTDGeifvnE1wWZ1YkTFBFAhR+A0/8W0FYhyLO2wbryEJPsdz+Ig3nE7MWWowFU4BAnyvzJTllZbF+2nHjFdTaM+05Fu0B+hs4L/cmKyXiaHcri2eninrRTVNO86p+P3nWpE/K+G7huRijg54RK3my3MvxFm4Uhc6fsgh/xBOL1ojMczj2f3AukFn7jHfF8/klZ4tun5ZrMMyOYkjOA7HuhB1bYSP0jgVGWXGCPkiTCS1uVd/iHqkcgq8fZRL5iQjTeGpJFQVBGSPraurxiLa/vqwguD/EDXNyjP9J6V1pBwZml3wAscspMnlW2f6VgA8gjhhfXdKkz0583bd9/bfzm7b5f+jyHeiCdl5rbTgdYiCt6Y9H2fbhaYMMYbyCYBJox2Tt4amXQ0idcngc6QQi"
`endif