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

module compare_eq #(
    parameter WIDTH=10
) (
    input [WIDTH-1:0]  in_a,
    input [WIDTH-1:0]  in_b,
    output             equal
);

assign equal = (in_a==in_b);

endmodule 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2drP+sazgX0dFgvJXkad//JE7EoPB7Z9a/l/nmbWjjvOJ1vTyAej+27pfC9dUizmcVmwGHLzebopS/IoT2mM0rDIBTeOSaYKTz3KdEH/h9XSkHdjtfp4aGXYu6ARXLVobymCLGNQ20gkA0gDGGsYTHUMlIaJZSSNKBSNue4fOjBo+OUtfL1cAmu3nXseSTP9lXqepLK9DxyLdom6TcCWNQ1dGjNWd/UaIN8XTqFQX9e3qrrFaC6VWwyWKPRMgKgguJwUjdgeSldokERYI4cvJK6DBukJpEdsnNmAiRFh82M5fd+wyi90IIPuafdPMwz7Wmi/FDfcoS9iOdJVYI+rspB5W9v5EWKNiHhMkBGDnh/MyeYAvU2gkX3TNOi9FdbriiwDjzBPg0cGRcuwV3yxv5tvkCboK2uWhDmMi72e2FYA5g6APlwXWKo7OBpDCmozKT/QJIpj6KAw8BauxGCP4IN8ZIb6RGVeBqOL4ZeH6Fbs901tYUCaK+4H2fLqndoPauNkq9PmzIFD8IMe95+pTD+GWXkZJmymY/nOP/0H573efPiaJgXelyHdREj4UGTfWziQn4N4kLjKRWFv5LacE/aix+wPO7sFM/MjsraTPrjQDiddTJsAOz6UBpZa5z/eqbXpnI0eHeHPMEBpSmUBIU2yUVk2GAA3PM4/XOPrx/7NKp036dyonRYyNfwiLGLfgjqD1v/1va5dBin6U5RJoCsU3hWPKoeXdknmtXFbIbVUuo/JtOzyRXwX4nBo12RJxL/g8q9wveSLSY4CJ1FG6E0ImK7ueuSVwdhUP5LEPlWpNGO4Aq8N0rEaJInjmVbXzrCRo73CtDCkBfthZBrqGRoQTgP9J+j13tEgFghXtQiMTOVReEDbl4YcogqwWgqdr8hmxWbx+r4LhH/TFoDIyKWW+DyRVcUNVvCBg0+aA3AmrXQCn2CfpUhc01v9FgqbauI3zf87oEgm9cr8p3OsncUsHlHVoBsc4RPwtBVwRuN22vpnAigxPyY+Wcmmfon6"
`endif