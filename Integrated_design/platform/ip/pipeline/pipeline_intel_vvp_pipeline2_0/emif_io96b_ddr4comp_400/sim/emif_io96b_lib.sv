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




module emif_ph2_gen_ff_init_1 (
    input wire clk,
    input wire d,
    output reg q 
    );
    
    initial
        q <= 1'b1;
        
    always @(posedge clk)
        q <= d;
    
    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SwpRnvPB6I7ZWFKsXoMxjiQ22FENYLkERywE7tMDTjKLRfejF+kVVEw3o+EqR0IjSQKE7R+aPHjpoYLb785XgNUTF8m1fXvLK8QXPWGzCcYWGjRsKl+ZuWPCmqyCBtIow2/EPMQKzjjGa4A9o2kjIYhQpFpYj8b3rOOd1noBdw3GFYTPIWBMRYwGF51D59ANjy0rOSFMqC+3UfdAJuDsb+tphceFblY+95La2aIhYOBXQCD3FcafOu2Fn0UCTEEMEmHp8AUcC4wzjwU2kVkKgEPG2Vm4FE5nAY63eCsfAoU+c9HUOrYokrJp6olM3ONzursFG+2kEEs5D1eB0gEl9kDmWSyzCCGEKB5snRU7RCIS/moDfzEynKw9IG74ZYW8CARfqyHijr1Ugn2MYwi2fwoCXzfj9ynXdc+o98iSFsWvQwgl6axHqxDSRV+lvvd7G+8IdmyNryzuPRvXwytxSFonXeqRagUsNGBwNSNC6K80YOATaT50RRvq/ofPajtO8BkryEK9MIeNgvV9wydFXxA6xO62ZULPWUdWcyvP1wY5sYNDLNU0hDGIpbtO7T6mLqW0VjRhrv7FNveSaIi/8xcbUwWmquS8cYPdzIfCHyz5TiOr1p1jx7Q1gV+bXc4V5NdNWROsOujI9m3sJuEMA8vwiLpKQ3fZIFRK3oItkpPEsxV3w8QEFJ+ScEoSyE6GnS0lq+KvuMz7qy8w+oYcEOlflsKTFUuVt0a2Shc0XSGkfrWwLnvbkEk792xivhViBo58yzP87KAJZ6e2TWmX8AZ"
`endif