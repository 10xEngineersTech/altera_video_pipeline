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



module ed_synth_dut_timing_adapter_1940_5ju4ddy #(parameter SYNC_RESET = 0)
(  
 input               in_valid,
 input     [8-1: 0]  in_data,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 input              clk,
 input              reset_n

 /*AUTOARG*/);

   
   reg [8-1:0]   in_payload;
   reg [8-1:0]   out_payload;
   reg [1-1:0]   ready;   
   reg           in_ready;
   // synthesis translate_off
   always @(negedge in_ready) begin
      $display("%m: The downstream component is backpressuring by deasserting ready, but the upstream component can't be backpressured.");
   end
   // synthesis translate_on   

   always @* begin
     in_payload = {in_data};
     {out_data} = out_payload;
   end

   always_comb begin
     ready[0]    = out_ready;
     out_valid = in_valid;
     out_payload = in_payload;
     in_ready    = ready[0];
   end

generate if(SYNC_RESET == 0) begin

end
else begin
reg internal_sclr;
always @ (posedge clk) begin
internal_sclr <= reset_n;
end

end
endgenerate

endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02Sy99+Chcf7cenFuBUZGYxOF2BXuLPHGT1rddvb6a9n/bz9FeYVMDcwkcAhTXYdJ9VEjvgiFaPfld20p/m5/6s1c8SRuId/gT1AYNu4uKlLJ3N7thx5bQbsIdxe2LlFrpSYG3Nkg8pI8avCKRiH/x10xOJGNjOcxb5/qYKRrAliLXNate8dsmWG9MxsOTpVwUQTU4/MwWVw/uS4N5k9wsVsVNbEPdEw+R87vs3mhhsV69hYLNAyCWY5j6PohWsomZHaC5gk2qj3C6E8gqbPiDUVb9lxbqHc9ZGSrK7qViuG++SqBdkfi/G/SefIWqN5VH35PfCPmOk9I+Ih1ZA2aqYiSNDQtzNZcXfrBsrZLuAKi9KjhuCWs5ro+xuHOZNXinV4z0u2QOiJAxVPd8BDSli8sLc+0zuqvMHYuE4SlUZ0aFa8Co4qA1jcKvVVJtPdvYFRuLSO9T3gMR9rLB3WZSrSVXtupU+m3rxfF+s8bQO/MOgpQvAHVHKmTF3CoYPrS5lJup9UJyVhH1vNySEbx5YZYvo6rSalO/aiCcqcz+qiVCn/2bh3g1jO3UQpirgvQnO+qEjMzaUWUqXiQlqxaHBskqyoqsJcYE2kqEYcksgm03Fip7H//MWk+A9sRj95yvgGGjnAzPWWfxtZLgZP/PorUgmqY9JX+7bWPwk0HdebdEiprOQR5KD64waV9ZbOswSb8xc1bwLofoO3eckR4dFCy6AArTgbd8i/b7Z/maZET44v6kwM96XJCfZ0k4By+5WHYE8bZw3CB40SK+C3En0lm"
`endif