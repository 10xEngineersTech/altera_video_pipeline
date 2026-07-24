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





 


`timescale 1ns / 100ps



// altera message_off 13469

module ed_synth_dut_channel_adapter_1921_fkajlia 
(
 output reg         in_ready,
 input              in_valid,
 input     [8-1: 0] in_data,
 input              in_startofpacket,
 input              in_endofpacket,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 output reg [8-1: 0] out_channel,
 output reg          out_startofpacket,
 output reg          out_endofpacket,
 input              clk,
 input              reset_n
 
 
);

    wire in_channel;
    assign in_channel =0 ;

   always @* begin
      in_ready = out_ready;
      out_valid = in_valid;
      out_data = in_data;
      out_startofpacket = in_startofpacket;
      out_endofpacket = in_endofpacket;

      out_channel = 0;
      out_channel = in_channel;

   end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02Sz8nuquOpIkhLdpbRPz+tC1QnflHiuBaPw6ti6CloYAI71o457tBHS/A6Tvq7qfN5ITu8tjMxFClw8/f+SNLc9a22KadHTwBttPzcWGzbj1XUVgbpTtkBNMDWRjfZ7Jao00bNN4XMoIapc8va9jrTzWjngjwTWUIOcljFqdDdcbAtD5lRXdQcVPPTScYkEp5BPot4gJ9mfIiDAfk0UnCdk0JYqiS7qf+feUO2akDeBm3slvloUnInSh9eTLDc+iZOQg7HCulODR9T+wQWkeFkrGECzz9HQO57uVrz+nkpX6GcxzbHJ6run7U4I8nO4/IE6KNFG/9wBEDIPhKQmOiGNAQnTtSW4R4q8jzOqgDyM1kV+UcbiktFkvDzX/tTEW0nYbYKMjHmv+8vxPWClgncbL6IBCSbBMTgwVAQt6n3IpwVKnHJxuPhkgOO1rgmZ8MySeeLDUHkRCsdtLnOHTQQi9poNDlz3VmOk6ouWJz2Wo0cbvxrsgPFXzignf6/M9mkV1lHr9VgX+z6xbw+LsONrjQ6UwqiUY2FTFaHK+Co/leXdIe31s7L25cl6O3e6FFWiMp90IqUXvItZiarsSXclue6z57YtkDD4yLOOSA26vcdvT5kyVKN+XsGiuGrvzJR5M+cWtdXH6YS/gqEqnCwMIqvDu5RF6mNt1sdDlID1iNSUZhko9AtfZ0A1jNHmcVEWhepZZtjEW6z2EJRBvM3qCb7kBS1LS7Qy+r1UOuZ0kgXNqu4iNeIs4Lk7wuU6ELkST7MSY5wVBpSgWxja63Ol2"
`endif