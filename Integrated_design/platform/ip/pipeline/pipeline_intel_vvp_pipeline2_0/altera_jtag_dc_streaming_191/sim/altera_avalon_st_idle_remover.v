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


// --------------------------------------------------------------------------------
//| Avalon ST Idle Remover 
// --------------------------------------------------------------------------------

`timescale 1ns / 100ps
module altera_avalon_st_idle_remover (

      // Interface: clk
      input              clk,
      input              reset_n,
      // Interface: ST in
      output reg         in_ready,
      input              in_valid,
      input      [7: 0]  in_data,

      // Interface: ST out 
      input              out_ready,
      output reg         out_valid,
      output reg [7: 0]  out_data
);

   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------

   reg  received_esc;
   wire escape_char, idle_char;

   // ---------------------------------------------------------------------
   //| Thingofamagick
   // ---------------------------------------------------------------------

   assign idle_char = (in_data == 8'h4a);
   assign escape_char = (in_data == 8'h4d);

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         received_esc <= 0; 
      end else begin
         if (in_valid & in_ready) begin
            if (escape_char & ~received_esc) begin
                 received_esc <= 1;
            end else if (out_valid) begin
                 received_esc <= 0;
            end
         end
      end
   end

   always @* begin
      in_ready = out_ready;
      //out valid when in_valid.  Except when we get idle or escape
      //however, if we have received an escape character, then we are valid
      out_valid = in_valid & ~idle_char & (received_esc | ~escape_char);
      out_data = received_esc ? (in_data ^ 8'h20) : in_data;
   end
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "wQtgtvKqJWgrzDkwk9GAB3thpTs1dbdVeXyagZEhYTY0TMU8uc8IINKw+JyOf/7B8h8x4eAHQa1nQuclXFA1+de6umTnjzgDN7g0Vp7/b+0JZRjeFjZ29eSUCyTa4mf28hxqY5qEFP2+jg3PI70fs5Wkg+PZ005d8LkvRNfNZpGJPIH6A/rnn76qg5DXUAcXqp/MHAFYqQimdC2Ohgkg3svZ3yq0mcf7iSWH62kEwycEixcp1D6QqFf1q2yyAgDTjzh6lekGl1dtrd76AbY273BGjuqk4Q5RRuO8M7ckUOMO9jR3cdtpJO265ae0wOntNEKlfDB2V/KjZjyeLWc3gZfYLzV3pXcv+4bGRjL+bU9Wh0pObWSbOHjXbgUHrpJx2FNI4cdoD3fbM5lsMusnF3eizdkQvYz+YTdqlC7O0nKdTUVFuSaQXyRzJ1/GcjggKNaroYzPmpybkqhhG4rAvprScC5jte4s+glgoUshCBAtBY2szRs8dUcbIBBh0PNtFJ0x+wuDlD3EO2CaGSLhE0QTU7Xke212wwRPaq14tukl371khP6iAGmNln+i7Xy5ef75LWu8CTPhDry8/RZ23QFa8lOZui6JucKs9USnNZt4bijtUtE8N9pdNiGarp5vNXlF/cvvMXfyRaRxq2/zh9/4dxAekDbG191KLA+/DkgVfzI6cViCyPgIFUtlhQuKI8Xg5dnbfsReIeqaIjzPaG3/MB1ZvfkYO2u93kzuXj/MAGHH2DyoQ5DNUcp5xnFHoBPUqFC7mKAE/elpz8zqb3RIuX9QaIDWa960nvyRP0aV+Br0G8KpPrs632b+/pqSNF4chTUyJv+d0b7NordygSOg38ULH/Ae1Bb6LVSOLmrJCSbgZxYqvEwXLcHlFsRcI/Emf4jykqp3SVb6R8dIUoe5EhCDUsV/1+a5cqfNSzXb45+dSPyE/v0YSGtAM/qATFp/wVSStzpiAUkQ71VRaB2Vo8FzdoJXn1BtaljG/Vgdd1Sx8k5hof7+kxhSXWgx"
`endif