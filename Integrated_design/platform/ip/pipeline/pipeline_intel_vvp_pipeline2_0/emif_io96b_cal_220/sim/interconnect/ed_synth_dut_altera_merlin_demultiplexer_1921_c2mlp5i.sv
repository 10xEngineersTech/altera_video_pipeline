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






`timescale 1 ns / 1 ns



// altera message_off 16753
module ed_synth_dut_altera_merlin_demultiplexer_1921_c2mlp5i
(
    input  [1-1      : 0]   sink_valid,
    input  [440-1    : 0]   sink_data, 
    input  [2-1 : 0]   sink_channel, 
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    output reg                      src0_valid,
    output reg [440-1    : 0] src0_data, 
    output reg [2-1 : 0] src0_channel, 
    output reg                      src0_startofpacket,
    output reg                      src0_endofpacket,
    input                           src0_ready,


    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input reset

);

    localparam NUM_OUTPUTS = 1;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;

    always @* begin
        src0_data          = sink_data;
        src0_startofpacket = sink_startofpacket;
        src0_endofpacket   = sink_endofpacket;
        src0_channel       = sink_channel >> NUM_OUTPUTS;

        src0_valid         = sink_channel[0] && sink_valid;

    end

    assign ready_vector[0] = src0_ready;

    assign sink_ready = |(sink_channel & {{1{1'b0}},{ready_vector[NUM_OUTPUTS - 1 : 0]}});

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwIUNy5lNE4C0m/sDjMUJKS72nGlYMPNVDm3Hl0+4ALKVB90p7P2Y7a/Rl+xhqB1YOO20O/I9XVoTxJ4u9NYETbc6QT7eA82N+JIgdeQLgcxhZ9RiYE35rJKRpycncTAA0X7vZcRbjKSkGb3MENdQRGR9oV/KDvLhBTReoNMU1hHsmRcwKy17Q2cWjqNsLyZo4IxxSwZSkdEnQ2XCd0Htg3WLJUZO7q5gxKOnRnm9fsIDjhmUsv7cdkpdd7fj6Z3hxCDABM4i8qetqqOUffBqF84KF6gNJMklXAT/tahuW+RhZQCg2dm5mCYGFt1Q/HGxm3mLLi3bu/Z1YbQyyCgMRbmWFlQBjCsNmAsP32aMVrIeId08HMFAssueDQYMVgFRYcK6FZFDvXtZEWnQziYYbEETAlrAmmJMcOZ5MKSyuN/KwlSF/QfUrBXHexIVI6pj7MeZyrMKitI9S+zChzvRo5JoRdyAcCOgg7h/+iKXVDOSuI3H2sME2beUU0Xq9za7ukByiQUibiJuVIDfIrDa+aLdXJq/e/e9EEEAsE4NfmEpeINwTkJTnlFGoX3s5V+Q3N6GrJM3/h1eLGO+g+WQY9atAuWzXxkEEmQbje0Yzzr55XoJLOzf405/czIVGthVRS4Zlis/eFiArQQWlUt6NEPzRKeNC9upl+FA9zrKk3F7FZoTjtpcEZX4iFE0Gl42Si03MPHfSMMZ0yk0C2/0SZAzs7xFEAVVsvhvpGb4GIkvtsdwZUHpVH+RebCrDCwpHUdOpls44++IciY+tmR26Nu"
`endif