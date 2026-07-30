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

module ed_synth_dut_channel_adapter_1921_5wnzrci 
(
 output reg         in_ready,
 input              in_valid,
 input     [8-1: 0] in_data,
 input [8-1: 0] in_channel,
 input              in_startofpacket,
 input              in_endofpacket,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 output reg          out_startofpacket,
 output reg          out_endofpacket,
 input              clk,
 input              reset_n
 
 
);

    reg out_channel;

   always @* begin
      in_ready = out_ready;
      out_valid = in_valid;
      out_data = in_data;
      out_startofpacket = in_startofpacket;
      out_endofpacket = in_endofpacket;

      out_channel = in_channel; 

      if (in_channel > 0) begin
         out_valid = 0;
      end
   end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SyaZe6pGhHMX6B3MfkXEPvKZ5xGKKPAgdaxxuihsM2T0pvjlliSAjVENCF0kgMHAQ8aFSMTvHmWXgpQu6VAYzw+WTKaZuLndwJwS9wnUZWDm7E9IOIpDax8Wm76gUPvu1HFqVov2Hlt9Ad2PKkC/9UT9De0Zxc2r+kP5Ef4QZP1L0IgB9m8PiKt8AIBX35N/JBa7Noerxs8fPTRcTPGcgbpkKDbXio6f17I/LS7wtqYgaVptyLqWnkkkpvFredM0In4TgNsaW+XylOg8fJ7TjsZMQj0uR/GaW7LbOsSRDaBqRcv/f1PxhdDGZSR+i6iSkTfoVfk1bvcjdDVRH3ERJfqCS6ZdO8XcFHXqn7mE/LbAGuU7qUOSED0CJ0m75koZxIk5Vvrrj3vd4YJc0R+abctP7/JHK0AsM7q59QOTd8LbQxSfkjOiAFZ78RrZtn70fW/fYjXiU/VfQlTPqZf5A1XWS4cKSDHsiBjBA7ng9us2l671KHxH0BPRQsAJ6n4jkbaW3qdlKkkJmCFZf6/iyMwBoI2dm4TBXJ285oK9TGjJ7p24VV5tgHB+kAzvd0D4wJX997AZ9ZtI4YMLOzME4EoJoP1LvaFI9ebLAza4UvLHbwH23IyEoL0q4w3w/WKAu8V3AO13MftAoUW2c2KvhuGarPbXzDab5vMkxJ8RQ76GWKYmMmSJaSppaPy1rwPmPW6kP9wUmL8w/6lXD7Fzw4u5LRBoh1x6VurfBnHWaOr2tapE5GHMEB545nAH2WZexZXhXx7oJnwC9C5QhP2oJJQ"
`endif