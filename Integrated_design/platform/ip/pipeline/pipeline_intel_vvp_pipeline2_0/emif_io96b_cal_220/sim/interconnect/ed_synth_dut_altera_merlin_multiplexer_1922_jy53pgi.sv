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








// altera message_off 13448

`timescale 1 ns / 1 ns



module ed_synth_dut_altera_merlin_multiplexer_1922_jy53pgi
(
    input                       sink0_valid,
    input [440-1   : 0]  sink0_data,
    input [2-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,


    output reg                  src_valid,
    output [440-1    : 0] src_data,
    output [2-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    input clk,
    input reset
);
    localparam PAYLOAD_W        = 440 + 2 + 2;
    localparam NUM_INPUTS       = 1;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 1;
    localparam ST_DATA_W        = 440;
    localparam ST_CHANNEL_W     = 2;
    localparam PKT_TRANS_LOCK   = 324;
    localparam SYNC_RESET       = 0;

    assign	src_valid			=  sink0_valid;
    assign	src_data			=  sink0_data;
    assign	src_channel			=  sink0_channel;
    assign	src_startofpacket  	        =  sink0_startofpacket;
    assign	src_endofpacket		        =  sink0_endofpacket;
    assign	sink0_ready			=  src_ready;
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwKG11kUpq+AF1+OSgNmbdLTBLBqjYnQLI9c5fMDpoTILU0BDtX6n6Fyvbguk5R92rhXOyXvztz9IrOZpYRRD1bO7UWwqrBOa1gVTvqpZIJ6bIFI3hXhoyrSK8O8NKqt0ULEG+mt8rbHrIRl02QcUXNHibTT79E2M7efKebNr7Fg2lNJ2d2HPEjOWMq6BXq2lX2g7M1/+32pLplDOunFPvI5OMxYq7bhjEA7TgHDCHdMfoZRg+7atYL8Tt+dc/SocxrJewO6cwDOVpMt8oKGWrnduilZSptcU/XXHGB2stL2tKBkyGCkR1qcPgwCMBXniZps3JuZh0j3hYb/CyqkElKuj+Gax6RRZa++pj7Cv1LPw8ujMkKcd3Ca0b6qvEJT4wxrfQzBGYy0gJ9z6FWZMDJoVm0LiWfnj7RwGgUFLMXJy0MJ4wScOf0lMFe/xMfwGDQM5kF8t41IDA2Ic7rf4d0DB3XnKbpnfACKQonovt/BUGKvuv9gmjAZkqVJ+g2p+5Qlv9KHT6LMPPN8CkQWgLLyaUHjjN0Rvnmm/ais1JNtORgn2E11+EdBxMgWauduqeJ/SEVE64xDkCa4oOJoaqeihTjnfFCf/QosSnbOfW4n4Lxw7xyjO9ZVu3acCFoPeiQsssyWIXm0aG5yhHx5zPWmmk7XmI1P72hqeBYG4PR0ybian0otDM7aOhnflgA4OTDLAEIVi40BsAGPOvq8swRqDf6mxYTiFvoJBrEKCMj1YUvUEBtZa29Wxw8R3BTqDOz+4o+RiI4LXKu/hRjzqJH4"
`endif