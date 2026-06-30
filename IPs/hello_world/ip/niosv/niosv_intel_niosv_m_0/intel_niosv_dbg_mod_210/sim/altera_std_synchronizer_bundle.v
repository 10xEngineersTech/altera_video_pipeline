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


// $Id: //acds/rel/25.1.1/ip/iconnect/pd_components/altera_std_synchronizer/altera_std_synchronizer_bundle.v#1 $
// $Revision: #1 $
// $Date: 2025/04/24 $
//----------------------------------------------------------------
//
// File: altera_std_synchronizer_bundle.v
//
// Abstract: Bundle of bit synchronizers. 
//           WARNING: only use this to synchronize a bundle of 
//           *independent* single bit signals or a Gray encoded 
//           bus of signals. Also remember that pulses entering 
//           the synchronizer will be swallowed upon a metastable
//           condition if the pulse width is shorter than twice
//           the synchronizing clock period.
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//----------------------------------------------------------------

module altera_std_synchronizer_bundle(
				     clk,
				     reset_n,
				     din,
				     dout
				     );
   parameter width = 1;
   parameter depth = 3;   
   
   input clk;
   input reset_n;
   input [width-1:0] din;
   output [width-1:0] dout;
   
   generate
      genvar i;
      for (i=0; i<width; i=i+1)
	begin : sync
	   altera_std_synchronizer #(.depth(depth))
                                   u (
				      .clk(clk), 
				      .reset_n(reset_n), 
				      .din(din[i]), 
				      .dout(dout[i])
				      );
	end
   endgenerate
   
endmodule 

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "rWMiGoTs8VipLHcQ295l12Rj5YrR9FwefxZUQ1isKPPswd3zmQFN9FaY8+/n0g+iEq7UaHtBRlrdpH7W/Mou5FJZO7Y9AzKYnK4BKq6FbOYRNNW3YOr3jFlUHCYaTr74eszEIc6FbdCnaf2xZnJ9Qwcff70et1ccd8BmeaYGjnBlRQDZSPIROBVQiiEI+W+bZ5ISTJ5MZu6XwEZpEGVnO9tbt7qDimITy6qQLO7Yk6in3EpisdWT4AdQ/i/FXJIOttbwsLGoDlUZ3IfXG1uxaQuyW5C4cTUD7LeZwfR2dotp5Cj5u1MT0AsIKoK5/YwdMDeQtSsR0OjAEbBPqCDX5Y1kn9TZdatRo7FO0hBS92GwtQVMVJ5tJKZAfkOwHKqdV68+lHTxnL6g5Y2J5Bj15e0GUUhCAzYVr2lAtgDPf3rJCqIQPGbi4n5QuJoGBiKU1d4+ZJJK4BxntJqL5HXLu5TFZuNcAmORjiEOaIaSD/Ou6iGzXVfRxYJZ67noj0IoZ8ioBnH2DFqZGe9fU+cFWaIS5RiK0qt3qgySQqnOZVXk0pJcQCAVPbFnSNFeKiyEcPQ2gp3VbtGaNG4l71JAtqSw6YRUDKPAE8Uldv3a0gqB0kQMKXKhPOb4G2rQXEPYpXAszQntSl8OTIe4BUx01TYqxMecDpryTVP8UlTlgR27CGdgBQ/iJnal4dXLgGeJ4ACewDPOdeR0ZHxlQgDrnfKk47tyCA/rE9+B4Ss2Os+jAAnDadcxv6Rj14iG9RpF9TYnc2e7vTvoqOmCltiPrSOaXlQmwXErLczF8RWkdWNEWswloZDHgbIxyXzYOPm5SHM/efjEyx36nahC4LnUjkQfVNXeZWVs36JaIcDnK+5iozonTE4kGNi6RQnzvzf7NISm/SxGednsKJ9i23gG7j6WjCafYVIIjzXOPQYP+4iB78CKiwer3RiAbHNSZRyNQYhluzod3XmtUbcHAm0FKWokFYX1xoLF9St9OIHAIrIRr1qk19cIC5XXdhyLZ3QQ"
`endif