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


module rd_pri_mux_kt2puei (
input in0,
input [1-1:0] clr, 
input [1-1:0] shift_index_out, 
output logic sel,
output logic [1-1:0] sel_index
);

always @ * begin
    if (in0 && !clr[0]) begin
        sel = in0;
        sel_index=0;
    end
end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SxIjON93wIaKCJmbyHUaa1oy6nKB/9HDqAzysbp1b7FVKUuy2zv/V0dc5nwQhnoDnoP30y8bQTgi0WS4dQMwOZ4Bx4c+v2HqsieNsMMnnLE+YSwheD9mC+LZ01iyweP2GjOiCKpFYiMddyfBovtkBK5r8mtKodxlAWM0Ur2pHERS3GhxmFOVzZrOWlw0cbfQ8UtqNpwhoAXZrlna9qudo1yR9L30JVo4skr5264YHIacXpwMrpp7x2xjScf1NTH/C06XCfAxyTR7VpvfPFqsrLBoZqdivTJmntb2l4xzAQX/QvdIsuXtwFF6/AgvMV+ub2UyBg22Y1LyX0jl7Zjn8Rgxytf3p2/KtmIUbvg+FCCqg4miCyGA8+b8+WCfx1d7lNfC/cN9RSckamjoXEdy5wcPQ5QgkKL1igvoeX6Sex6Vs0FkdLxR6Vp9I+YNI9I5jjyUyt7bdpRwAoPH6UcxAHfuvEEdChl3vCVdU491Feh3a1xAX+iVvbM1uH33B9zUgGVzBXPU4Olmc9ROqjO/5dlyfDuhI7atT+2G6GSwwt5ihZJC30ApLSXQRzHH6SeQ5aMr7HmT+l7ILPw3FeBt8Kcz5DzKcTZux76Rw2tlwuJLScLz6pXdFRYqoOxIZtaJm5h1oZPoTPCqvCNq8/if5IvavV1buHDEqJ1itQC1oDrGKPSU3NemmtBhANdbHnw5Wg4M5K0S3vaM9A85oi/HS5EDTgeXzrxQZkIRQxA8kuf1EtRmrP3OoFOFyVfibffgWPsTv6i4//SVYSbPgm8n2RC"
`endif