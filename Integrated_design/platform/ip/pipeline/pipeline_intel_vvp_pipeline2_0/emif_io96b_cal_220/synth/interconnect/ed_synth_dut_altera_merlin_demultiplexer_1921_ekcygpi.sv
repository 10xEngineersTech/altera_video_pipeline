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
module ed_synth_dut_altera_merlin_demultiplexer_1921_ekcygpi
(
    input  [2-1      : 0]   sink_valid,
    input  [124-1    : 0]   sink_data, 
    input  [2-1 : 0]   sink_channel, 
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    output reg                      src0_valid,
    output reg [124-1    : 0] src0_data, 
    output reg [2-1 : 0] src0_channel, 
    output reg                      src0_startofpacket,
    output reg                      src0_endofpacket,
    input                           src0_ready,

    output reg                      src1_valid,
    output reg [124-1    : 0] src1_data, 
    output reg [2-1 : 0] src1_channel, 
    output reg                      src1_startofpacket,
    output reg                      src1_endofpacket,
    input                           src1_ready,


    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input reset

);

    localparam NUM_OUTPUTS = 2;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;

    always @* begin
        src0_data          = sink_data;
        src0_startofpacket = sink_startofpacket;
        src0_endofpacket   = sink_endofpacket;
        src0_channel       = sink_channel >> NUM_OUTPUTS;

        src0_valid         = sink_channel[0] && sink_valid[0];

        src1_data          = sink_data;
        src1_startofpacket = sink_startofpacket;
        src1_endofpacket   = sink_endofpacket;
        src1_channel       = sink_channel >> NUM_OUTPUTS;

        src1_valid         = sink_channel[1] && sink_valid[1];

    end

    assign ready_vector[0] = src0_ready;
    assign ready_vector[1] = src1_ready;

    assign sink_ready = |(sink_channel & ready_vector);

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwI0OSeJL4dgu+LAjWZtJBoYOJB2+YNwP/Mxf8g6y/Y37ysUNo/4irUD1erefZW9qw+QIQsW/7nKR6IYqVtkGExE4hHx8oZ2WsEgLLZQtsZWzPnaYtzWUYE6pkV+nzh7dy1AwhQFRFfd6MeTt+Idvc0kQmthkKmLR736rF4CXTvzSA5PchWCRbqDevNu/NmAO/zXnsBis+CCdB7c+XrNY+Xrr0ZN4dUrXc6t3fIv6fNDX/xmTdfXKl2xTTKZwYcMUXr/jSk3hr6p72ZUN7fMaglK3V1YGnOEm8q7B9/O0v3yB+9fiAZGlmeLw4BnKKAYGiSyvJt+0Nd1o9q65GHUEMvFkeh+tQdU90A1c8SJr4yqoXtptJiAFaUN2k8ZZJ8DUnloX9bZCeq77TxnftwfyHFANa1he+kdtuueLkTPwstPJdOC0+ysFJ5WzXRKHNlq3ldwOcjK0PyoDyDffJup+VDJfox1T8DiVJZCYH1W3JAFpLNj43YKCu93thWoRuiy+fEfRvqc62TF7L/MFgaE0OEC02ftVQiD+OpHpfder1ck2lEZSzIhProBfkZEWJeYbSNQ+66VCLN0FzOBQn+VCV6QNd3PKtKQevHKHn4RYBkN3k8ae6tGVe11Ooq0LZRAb8eu+kjvK2vl/IrRfAAcnHxAnBQAmwivfZCtXUvwUgqNaspy+0FhD/5gDhqaRjJ5LwDnKkI85MyiEqyNqtx8HBCMxHZRm0u8xxoGpf/HXyueQdUeEqQmZPYTNvyKeHP+Z1PhGUB1ftCMjarQOl7JEFPZ"
`endif