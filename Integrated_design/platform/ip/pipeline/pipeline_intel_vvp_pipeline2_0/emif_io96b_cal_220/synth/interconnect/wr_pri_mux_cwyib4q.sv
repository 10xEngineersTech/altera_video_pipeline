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


module wr_pri_mux_cwyib4q (
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SwCmF7yj0VBUvGhyfryekTnMTr1fbnArRi0TWUmFTIL9VTsocfGZ1DtuLhRgWiDYIs/LuLl8KzTQWuL4ySpkYnrHAa51CZl4a8i9QR7Kr/0jvz7BWy1PcwITO+dmDIHYlf1cSGUxukPswz9xc7soDwba9hxizxmUk/6rKsNjVvALoKVfgg1wmJ+0isr8U3tyuabVoPpVPU3lc9B8C0mKX6Cs7SAxJdgCAP+5iNEb2uTdOVE6GAv8RdksuOb9P7QcI8IuQehI8+cTfZAc8IrBPTbPTlCUl0X41a6R5xM1GKLeBJ+RGJgeqs6NbHt0v5DG28pIwFuIhwxEiu/pD0ZIj9FXRUjKidV8Mks98Hm84pFVp7NIo9i8lF6zD3UHK/fUaoyi1KObecHuLJcBfHzR6xnUhy7pewoc7z6+PIk0oVOjsS8sSDzBvaBu66uKYSa17UUdGGJ8ATfE8db7SU/vGE7wSNGR/ppC7Y4Vlj9Ajre3ebhVUAGdg8UYz1Nd2rnt6t3YuWtHLwv3RX6LB/H4NJs4Tf0mE/rqihTaKgKpdVQMcm/VRQTRiF0gsTrT0HRLQes0cIh7w353ukxEqXs21QXgGjblGYcDmpB+WGhNpfJdevqSLGbssnVYy1cGx5fyRa2ZLoQU/QTcTdqt3kTfebmCw/b4iNpu91Kuoe/Ktk5AeyvM8sqMRpwwsBc5PjJx3Gv1Kl7OPqZfZ7vlMOqEXTz6oq34AI5wC/YlzqXpI18ucz0vckCa/eGYYrrG4/7v93IEx8dM4DDNsLi3vNAF7Ac"
`endif