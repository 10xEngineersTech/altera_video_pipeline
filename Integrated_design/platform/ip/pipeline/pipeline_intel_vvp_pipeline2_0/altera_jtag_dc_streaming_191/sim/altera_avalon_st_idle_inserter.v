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
//| Avalon ST Idle Inserter 
// --------------------------------------------------------------------------------

`timescale 1ns / 100ps
module altera_avalon_st_idle_inserter (

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
         if (in_valid & out_ready) begin
            if ((idle_char | escape_char) & ~received_esc & out_ready) begin
                 received_esc <= 1;
            end else begin
                 received_esc <= 0;
            end
         end
      end
   end

   always @* begin
      //we are always valid
      out_valid = 1'b1;
      in_ready = out_ready & (~in_valid | ((~idle_char & ~escape_char) | received_esc));
      out_data = (~in_valid) ? 8'h4a :    //if input is not valid, insert idle
                 (received_esc) ? in_data ^ 8'h20 : //escaped once, send data XOR'd
                 (idle_char | escape_char) ? 8'h4d : //input needs escaping, send escape_char
                 in_data; //send data
   end
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "wQtgtvKqJWgrzDkwk9GAB3thpTs1dbdVeXyagZEhYTY0TMU8uc8IINKw+JyOf/7B8h8x4eAHQa1nQuclXFA1+de6umTnjzgDN7g0Vp7/b+0JZRjeFjZ29eSUCyTa4mf28hxqY5qEFP2+jg3PI70fs5Wkg+PZ005d8LkvRNfNZpGJPIH6A/rnn76qg5DXUAcXqp/MHAFYqQimdC2Ohgkg3svZ3yq0mcf7iSWH62kEwyfhkW5RPL0303cb73D2LZb+cV1occ0s1ycLRHSpJ2on2fiR/gRxHBE/0g6G8Vlpcn8NDK+XKFDvOS5jTLOeC63ORI3OifIDbpa+cMaZzVL8qxOqiy7MYDIofxA6wJgVQ9iLsh5ykXq1Vobd2EL98mizVhBFRReyvtPmcwc8DBVANBo6pfnHaq1AtGC3hByZfYbTu2mBI/l2bqTQHIz6VkCzn9WPXDTbRo3B5RZLmgWFkMcDSn8aUrdD08bUrWhoZnU5jfCriFuTIMsS/HAIGHpHe4hOOAEqKzijyJ0wmVYFfUyc16FllWg3ZWD/7/i0RL8t7KvLg6SmJBIcvyy2W+mq0YO8fMJIN4rUn84a/X7khAyQoiQt/mYRJtY6+I73UGX96TAte/87Xj72z9TY5kN3J0z/Ybb6UXSgr+n7s/Mg0bi6Yn1pKAjN97uXjhgfZFTOoqkgt/TFzs9mMCJRih/OJBd8pqbyZJXXFD8XGQOiG9CnrO4pFPICCjcfCLDQhRFYC9FPCuPpTFR8zxNIw4I/3r4UpwgOTkjCEnQzXH44LC5A4JNuDqag4mL096GfS2cgMIqR4wRmEW01tRPPGvpbBqpl9+Bm5kf7R+LrMNLcYJ2wQqD8NRlFVbZhSVNvzRIeH6H/NeQsu/87zXXA8CiZKiq2xgItlXdoY1pDqkQzAUMkBpWJ/kpLVIU3zPrz/hZfgumy3QciRPbe+7hKUH/S7kM9hia5mkyAKxA7+FnQpL1P10/osH9hcz+c81C2671NX7eBGR8oQinEMk1oX7Ki"
`endif