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

module rd_sipo_plus_kt2puei #(
    parameter DEPTH = 1, 
    parameter TOTAL_W = 35,
    parameter ID_W    =10
) (
    input clk,
    input rst,
    input in_valid,
    input [TOTAL_W-2:0] in_data, 
    output in_ready,
    input [DEPTH-1:0] clr, 
    output [DEPTH-1:0] shift_occurred, 
    output [TOTAL_W-1:0] dout0

);

logic [TOTAL_W-1:0] mem[DEPTH-1:0];




logic shift_in;



assign shift_in  = in_ready & in_valid;




always @ (posedge clk) begin
    if (shift_in)
        mem[1-1][TOTAL_W-2:0] <= in_data[TOTAL_W-2:0];

end

always @ (posedge clk) begin

    if (rst)
        mem[0][TOTAL_W-1] <= 0;
    else if (shift_in)
        mem[0][TOTAL_W-1] <= 1 & (! clr[0]);
    else if (clr[0])
        mem[0][TOTAL_W-1] <= 0;

end

assign in_ready = !(  mem[0][TOTAL_W-1]  );

assign dout0 = mem[0];

endmodule
    


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SxV7wriDyNrE16n5t7T0KKd1SMFpBXdmGl6UMAUXAqBkmS8BZHuy+HY9ZEiOdJFUa/SuZXC9s0GCSFzP0gsmEu87+0D+iN0F+AZ5Xe2F/NSf7IgsnMRQ8aKWiBsE6xiZdtkOB11Y6wEi2yVCEhfB9RWmNDoSf7JD6IV8FoQuYS8Mp0XFYmnh3B6TyeOhfyFWhgvm4ulvx/Sw5m9DnC8zku2FzkKdITxiS0j7wEPDgqGBf8zAJ2duOVpJdi5cRX2Qd3aD6sS4rax8mE4+5NseyN4cfk5PEq95+EViIXRJYsRJaPezw8VWtZ1sJ/uOGMao/WJo1akr1+E5Vn2a1AQZirBywbHpOcKW/LlNYKxB3TgHDt+RFUy/zmO+C25xjvG4Fudzm1SIS3UOglc4zqpy3FiN3MO+KN2bjE/sxj4X69XsC1z9B4p2n+XoLse4y9ACZ7w4dvzlGKSTYD09m4TeBiqusbf52w/qOO0EiuIXgO2R0/1avyxjOuZSQ2wxsMlNWlv85XboP4EPVAkz+SnnhlcEg7z/9RYJZ+cTIExO+cdxc2u+vE9hLghDM9vMOCHArxQJQzg23+U0qIOu0E25TNKNEAkkTEJQXGdwUQBJ/csM13gufOXtX+wLjf72cps32FhFROkasyHkdCBf3GSeEMYfvT/D8+27TvlmZ89gDuVcmnfBZRyZ0GpR+ALr3/FswejSgefe2XeHudjnR6UEkYiUNUqwgj1tdoNajY1Nbt93Fr8ZVZYwUU8v64asEfv+yt1TSjFi3ZMqXDEOBB1c9gf"
`endif