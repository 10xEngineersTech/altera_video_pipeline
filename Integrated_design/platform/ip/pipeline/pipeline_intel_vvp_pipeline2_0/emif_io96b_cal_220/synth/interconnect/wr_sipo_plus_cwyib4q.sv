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

module wr_sipo_plus_cwyib4q #(
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SwaC4lrx0vCE2gYj2POEz6dSBJf8l5w+QiEEmyVfKiVQwZCgrxEfD399ep3PsRJRuuSyRVAPHqUu7VzyapMeHGv6Zry7wpgkR5VUm9DQ42V7DRI6sOgD22EW8ZNlnndHbuiN08RM6YSez4EozLZF84LeS+tZCNWQXcieuJrD83s4uvF++Vt5lxMgCNXA2WgfGvaqEhRysz0qW4aSI/6lpuceUWeFQwSMiitNu2onlXl+aosCE13w3UPGrviEQmx6XTYzAH4l7+5wO3cNwwhvju/IC0f27O30vOWIDm8icxtBFeWHyJzTv4WAlEBK5MCSXQdK7+i8tLPQrs6g2UT+tG3JxPOZ7Ne7QjTEZ/IpSnUBsQAM26GxuTgTkoTfAd2C10b4WhxnPcgyEvj6S9nN1N++YRCzn1qDeUm4bR9C5rHjVvsosxqXDG5XTrlODgZqxslRgfi19o+1aUgGH0iu/mNpzHjIhVt3eKcheMf007deRhpl5mS5nf3pEY15LBJYpIXF3NO5Go578HqBqhgVLfolbRVk67z5TVe8c6ci7S3Urmk8t3biO7YolXTh8rxPho/Y7l7z1bpe3dm14UKOzrQposlzpmIrfCAGlVwnajnvwCZRZDaES51fXvjGgYguL8FLTArLMWG3WnL0jmLPntfwWsanI27oQk8IUoYefFqD5Dvm2WarXUvaWtAwGBmZ5nKI1uZrict3VV9bBzx25TgcxCc2FbeEDMRYX1Wh6IECMYxrlulYRnvrMr0HjDhVdS1v6BIAO61FEIK+S8RL848"
`endif