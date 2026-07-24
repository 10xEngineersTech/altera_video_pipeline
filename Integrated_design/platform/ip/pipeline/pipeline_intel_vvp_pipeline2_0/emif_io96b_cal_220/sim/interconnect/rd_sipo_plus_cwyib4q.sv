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

module rd_sipo_plus_cwyib4q #(
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SzijIe/y9v8S/5NVo/A5HOmQb5BnJoTaOfl96ffcAmhSmoTSKAdWNx9MsVUW9FCUwNmsIc9i5WSrz85HsvmnA/i7jFZJOo0yF2gvqo9rGGPe6Nc9neyfZJxnQYPEK8LlZBOTc89oOD2dHffOh8FcW7aIxbrtdDHA8dWEM7g9dhqWf1lKdgObHg7BAY2uGbcAYnP84Dh8T3wqE4boLlvLDy4X5+oIPKjlgFzNByeGBETeYxHgb6mA0lBaEdWdqsP0l80GiHcSEEz9UslLX6rWlfTAvvQJfOe892jMFUtZ6SIUhAcdVaFinBmKLJN3LTvnXoioLE/x5VrB0VIPjAjDA7lFAUJhvEJ9xWzMbbwhy8u8m61+7VCCOrwIa0xRAMvVTA4zhSus5eCPfq2AZhoTebdssQe8gLVxpQM/R7upQlDPNKMlM2qeM/LYjM9ZuS0Y3sX2Mr8PFXi6pBJoJepH2hF3sgdB4v2LtPwKYQHu6Uc949+ZKVRgQKvG8OaGCLCdFq1GP56Z2OkFzgYl7ZTn2QBiNmVOaUH93wLD2DO0o6wJBhFxL+YR9Je4rCxiQqIHQQwphonAY+sOXfym0xph/1QIx6kcKtNVTJ+ADIn2Fac9zszvMDgXhDFHWmLXS/70MgI6i1dZrBcmM/NtrjZXoM7tEpAEnIFcEPFFsgTBgx9MoxmbvjwuJ9Ph/39kmSTZ6NOIM91YNZpQklhsUYn051a4a+vjvLOv80pflo7EbH8IoozVCwovcMSgW2NKpgRu/1I7s12YiEgi9HyX15wp0/h"
`endif