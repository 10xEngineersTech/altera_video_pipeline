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


// a generic clock divider to be used in simulation
module clk_div #(
  parameter RATIO = 2
) (
  input wire clk_input,
  output wire clk_output
);
  localparam WIDTH = $clog2(RATIO);
  logic [WIDTH-1:0] r_reg;

  initial r_reg = 0;

  always @(posedge clk_input)
    r_reg <= r_reg + 1;

  assign clk_output = r_reg[WIDTH-1];
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SzOYSWFzsXBahxRtgQWsfvI8Hj9tII4t+Tt1wVEFGAeeRMGpkTZWtl5ZnnUCKkJimJDmC0pOjWuBaku3T8jAqmuQRvmhaHhsojxYMzjUSNcItF84elIeI93AVmUxzwEp03LckTIni/s3D3O2FTsuPVN68WYAxdYeYqSe4qpnQrzGtqm+QIB059SzM0yKqu2JmqHi4eaqfFf9K44T/iqrhVU2+b/Fcx+/xa5zFWtfgMfbUT7NWFD4c+9SlGOgLWQzNQLoMZ2Ka0+odmClEetmA6kfDjr31vCf0Cc0H9H00CVLHbHz4zh1VHSoxOfcNX2ct32y7NdptH4qYI194JvRhExNBy7oo6ucOWYFNaR5U4xNPD/xgVrA3iah20+sD8UjEozGrjFldi4HRpaEG+c0QiF7qkD/cb7+wLx2bDhWaJEX27ObVtADMVkXUlvOnlz286S+O/pQtAc/zf81jMdHef7oH4pduzVlLAoNHYr1bNFJr7Qxt6pr8fZrY64uxi2wwxb7n6WC/cyoYx+CSd3QLanLMu7kZjbi1OLUoRkO5xODE9Gi9cSFhPMQ5sd1GCyzj8alLCAlwuBuMYER8JbLJbFHRZgBNM1qOpNdqDs3lyn3RhkXq4eTObUczGwH3yO7RCjGB0NfoR2iN9MYej85agqmoF5uysaCVO2b4lfkfq5RR4ib3GI8mYy6gZNDO1Z0W+bL5hETg9QHY0eQmId1AfvePDt1FUDx+/GTU8lLuej6/XD9J2hGs2lcJAACLdYJ5Cf1oxzB66/VnPLdaGWav4h"
`endif