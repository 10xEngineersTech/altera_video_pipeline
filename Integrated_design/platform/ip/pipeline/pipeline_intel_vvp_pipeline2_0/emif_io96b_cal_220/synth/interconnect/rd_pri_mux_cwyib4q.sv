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


module rd_pri_mux_cwyib4q (
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SxjhNdfTUCgfEwltj2tHAGqnT2yOcISHo/4N/Pvo+C5HGnoCHipXuVPqJtvdYZK3n2HKsyTwY4y2BhIRg905Uzedoa2t15nVlbn3Kpr64mVnZuP3nJ+6I0qC22G+mcwmnN/8UEX07gfGPFp/k2nGmLNotG41TC0PD8lHBWk9JlWwvQkLe+FvYE0Lcvcj+qvKqm8yYRo5Qca24xm4zt2XLWWiL5dxQ880/hbYfGsWKq2tXcqeH/E2iMQxDa+tQv6e4cjkfUvVorKoh0G1PzBtAW3KHPksRrrpVwo9wAAMGWNFJW5ezXvqdQ9gFzEkW/IvRFczi9Ckjgr0WXqetf7Ywer2/H0DKmJYzP6LzeA7qo8cWUAO3hkFbvz8wUL7JDD9wD7FRSZtCKBLnwUwyblQxA4TBfXNmkgEspRHSVv16tCATjesa/kh0KjL/o8KT2dtPWNqMAGVTmykrYdgnQDXlIpMcqSmwgqqFC1EXxLwoeafaha5lEnUZAwdKT3YBtgiROF0LhaocHKUOmf/9xRWdpUGyMCg8qbjEyx+TKgUW23840zcSWbObr6RGRv9oo7yTgVWRsbKcHwDA+zj9rS39Y/qeYgSKAke3Cf2yIMGFEnXYQtGUS+6G635EI4AJ8jzSkjnCL5FGYvkVpwxEQfrnt4Lcir6KO9cPbxy8Pd9EG8GAZGm/al/Y4IkaQFFatbt/1M4yWgglMXGT2BfeE173wlEX4E9Cel0E2nSu7WQftUKph0YJn8gRSgkMb3VCAfu3QdZDqoKGnlWJ2joi3LJw5o"
`endif