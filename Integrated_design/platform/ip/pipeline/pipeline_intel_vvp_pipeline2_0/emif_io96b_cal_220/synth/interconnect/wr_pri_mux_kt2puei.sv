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


module wr_pri_mux_kt2puei (
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SwUPYkz+1IU9bk8EHemtAzo4tCjqRj4nVi3kQ7kWobmMAVmQ/6TWNNYn2gkFb/3gZQj5jGc8ikKH6AZF+M1rXQMPDH7TQgfIIpzE+uulGGWbmH/tTWMdjGvNj552ZpdW/UBjo3NRyvHKsPMsnYhPKOT5f5GpL69xhm/j5rfy3o3cBKpuaFXiRfCR+bqnZ4+InBztTwBVeAUo8TgG/Uukf0AMBeqNLvv2UFmCf79IAsAqS+F0jfAaHm5kRfNB+31FT5CJ5wxWvcWX/UJshHtWef3U5iIaHm5bfxuJotMEu2FSpNr2C/pKUU/wBJJkYElcMkSfENCdQvCLvLTbOLOp4ETaMXHGBYKtJjo1WTlL6hYQlhhW6KTvzPdcm8WIiSq8Z7QYqbHp6TK+WHX1A3jebh5xW5TSbTN/BHE4gELjN5DMW+vT7MDhBuPVytbqR5jX/AjKVBQi+K6Sr0oTPdl7e3sXLn9EgYgFSLUi/6YLuBu4qsnIn4kncKfSsJ7LPr6xMUybpXcuGWNpPCL8WRC/BPYKN46nINjnfg7EjXelS63E+C0C21EgxBPL7g48mQqHtKQHii2Rx7EAKfkQhjmOGxMx/u56rjZKgRxkfxmDJm3x/I8sGHapbmCXm8+wfK6f/VCL9U1mj9l3jNN0CjubDwfqYAgsAfwPitftC2Hc4bNeOzWsdUzsuFOjeeIjHtGpCNIULS1T2VeJSfiIpxpmsKGBZExOdI4wLP0jIJ5rp50FsMl9vEjAg/FFwK34jsL7ddEC2tbRpCXOgaHqLdON7La"
`endif