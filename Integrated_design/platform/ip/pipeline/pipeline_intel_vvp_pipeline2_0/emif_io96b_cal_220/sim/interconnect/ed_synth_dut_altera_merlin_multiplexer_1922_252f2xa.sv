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



module ed_synth_dut_altera_merlin_multiplexer_1922_252f2xa
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
    localparam PIPELINE_ARB     = 0;
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
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwLjWkwdLpzywWiW1t7MOVlzuNpqyaQE4aoTTXAKOP6Mdzm2eeUTzdOuxzi9AaaRzguiOigh6amLcWMgCntmCcSIwPxnq4Uph7aq9+5C0QOVhqH96+y7O6Mk1dQ8ieFcHQ5GWFj8/xENbNRJ5MylgsfOxON0nh1Ql8UVI+FHWs5ObuMYba/7Dx18Eg6SuPqfxprZbVzh6kt4Rpa2xDyNeJ2TXo/S8I6DAUEOLxXtW35C5EW0cz8Od7hzM7/TXuCI6pFzIc9Odul9d3H65N14EVwRca1IZDejNmVeC5alupYgy46z61gh9VoQA0RpVh49aWTfVLQweS1LZ97srwBRN070gvnwMmKvfvjhAxiG+kU4aQ2OhgzxbYNZFduI+OkxhQS5AM1vi6RDBXr511AAJf9i7VaZgAWtd3KWjtMPb7qcLGh9px8lVMKzhiSzrQelOHN4gOYCNeJdXsyqhLjGdGCcMXcuGYyN+Ia+Un5H9HlPhY5yYn696CyfLy2mrAdk4NOnyVMxXZTY3ovthTIH5vSbGe5agaxum8p+5Q5fiorsBtyit0fglr0+FK3jgbmduzd/ILNsU7h7PUr6208t2ELiV4GhOssjeOg//gLcLPa8+p0EalsqdybSqHy6hEyOGdecddSpeoJ5OHr5LaR21WLclQzYGA5Kzan+LXThlLTP24FPqQYb7AYNGKvIqZxp2TTufEKc/kEl7I8ecqqmfBJFa5eo3fWJVmjfiQg6CPQdhO3cAXDq35z72UWdyuepHy7J1Y7c9W2vKBtA/0Qxtzr7"
`endif