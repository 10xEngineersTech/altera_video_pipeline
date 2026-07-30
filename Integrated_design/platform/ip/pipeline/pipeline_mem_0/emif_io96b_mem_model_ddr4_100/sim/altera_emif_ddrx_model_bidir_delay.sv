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


module altera_emif_ddrx_model_bidir_delay
#(
   parameter DELAY = 2.0
) (
   inout porta,
   inout portb
);
   timeunit 1ps;
   timeprecision 1ps;

   reg porta_dly;
   reg portb_dly;

   initial begin
      porta_dly = 1'bz;
      portb_dly = 1'bz;
   end

   always @(porta) begin
      if (portb_dly === 1'bz || porta === 1'bz) begin
         porta_dly <= #DELAY porta;
      end
   end

   always @(portb) begin
      if (porta_dly === 1'bz || portb === 1'bz) begin
         portb_dly <= #DELAY portb;
      end
   end

   assign porta = portb_dly;
   assign portb = porta_dly;
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "k1LH1RcWqBqQ76v8cfULmmlV9sW1nnbJaS2wcLgqGwqBhLWK73DmouWbV7pbibS7IH130sZk+lXZ9U2UpRjei+a4GXqGhMMc9IMzMkgIDLbmlHj0N0nMSI9TMo4z5CKT4okwkd1gkpoJ98r//fD7kKG+O0v6X7LJGK2BQC+3s5gBj2lSsro8UaDW99uGAXd1ozPUFOiI9DO+P2Bl903Ke20T6b0d5clKKvtf117o8GmJ21yxRoiP6kMguUZ1YN0XUFT0JdfzmEYt5pIMSdjYv+KkgjjSa5PE+xsiwn4FuoVce/vsLf65JU9B2ZLfRudxjZkRAOQgkzSIVbb47eNllWK1oIcdAgkuceMmIGo08e+060IVmxH00UdyGw1MehISfhIEGsExaGMHsVoh67AOakzPZAt4m+Il2jQGAKPculllJWSNtieMgamJWPlRcxkWKvJIIvrbxEADw/UxBwKPzldF+XYjwdvKyhLpFmyExe06nlbt1S/PHXTQ7ZEidd9pXPh9VOJAw5livkae++UqyShMORgi1OCLDb9TIwvq45tdp3QLW6QF/wwFhjts9okrQvv3ejv6MaSk0Z2sAcAeFSfviTB1f08a8jiPXw7ZgsbOaYAKOL5INCL7Lo2fthkvJN6Sd1gsXL2Z4zMEO/gffzV7NKWlk/9AG+8DNcj3Cbr5dvWlXPV2SWjQsdGQj5ntPhIt2b5E1JszHkQnk5bFG6vwjLYzwNFZ79W9KxIt/ir2JDTY7Z5IkqfAzwIl7z24Dh6u3DtmCIfQs9qq/oE9yGJ+GwTVlK52xOCLnvYEFuc6LLZxaAbvemYEOgQmG8x8WKwtaimAVkWTlHFDzhhkYV4mJjchgtNPVV3lH2u2NtOVqTM5oPSt8vepLH85PanuZ19EI2woQ+nHmXFBSSia6odiFWFo3udkRQ2Mya619whksB8LhkWklKoFjxfiTLe982mo63S+uTT/ms+L1i5lqBMG7l9pwJTjobJR/4rlaLLMinsdN5h4Btos2WnxCS6q"
`endif