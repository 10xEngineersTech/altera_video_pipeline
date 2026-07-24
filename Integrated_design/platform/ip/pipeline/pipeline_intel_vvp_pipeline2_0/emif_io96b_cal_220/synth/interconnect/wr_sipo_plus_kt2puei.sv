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

module wr_sipo_plus_kt2puei #(
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SzHuWn2f1wVLsBCKiaU1Wap1+/w0t8IIS0om6uEFNiYUlpUYZRIQLV4GTVDAxItw0YeWnrXjP5tgxW7UgYmfshPtqnj2HhIp6Ap9KO+lN8qsA3/IS2LCiWlM4gMGVIbj+whdqBl1jAf4fgXzetCJq7iUh/JX5HuxTmOM1/0B5410iEx+l+uY580EmEpXidGM7PtftcQZewQazicBgPOTV9Pm72ohJ6MF4a/Z3LmmSQVMpIOv47FyA0CuCYunP44tanWcD62IRJ/G+ya8Lvr3wmNwY1qvQujwmgxj6s8bYly3/ByRtuvmFhHfWSRe6YToXSG9EVZmMyFHhzz0IvfkmidWe02RRWPNtEET3uzA3f++K2qm0y7M51bb7K/ukbAlDdZg3okZ6PydPhooS8/MvSaRTnjK3Jivi1s4N0vy+q0xWq2FfSSpZNiAP86XDNtGqg337AdmSR1lOh+4mhF+McRtEN4Zjjy9rUBSSXSlviil3vuUXkzF2YRchHtr9Oo+WQFZeGQl4kdhtGUz5cyESpATnd8nHxvZQxmrqhuAeAAOvDJxI1yg4X9vkRG6XwYl9tJG5BoB3FeavRKuxtldzJ327VhgM7vUVxZT8BdwpQtA6wvZAT9w34dcSXHbD7Sew0ElDF+a0FoOw9P+BoHEM1j75JvAiqdS8kV5yUXTMh5qfP9HCzhq3pkS/clB1FD8kaKQydM5qKxbdHNyX+52BlH9368i8S7IRLcbdPC/T/Hdo86daRmOXc3NSF2sqiExenS6JiZ+JpX7Zx4/VCvZwi0"
`endif