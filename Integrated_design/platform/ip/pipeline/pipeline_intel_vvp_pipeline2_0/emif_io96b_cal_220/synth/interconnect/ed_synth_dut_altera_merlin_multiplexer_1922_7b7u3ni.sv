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



module ed_synth_dut_altera_merlin_multiplexer_1922_7b7u3ni
(
    input                       sink0_valid,
    input [124-1   : 0]  sink0_data,
    input [2-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,


    output reg                  src_valid,
    output [124-1    : 0] src_data,
    output [2-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    input clk,
    input reset
);
    localparam PAYLOAD_W        = 124 + 2 + 2;
    localparam NUM_INPUTS       = 1;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 1;
    localparam ST_DATA_W        = 124;
    localparam ST_CHANNEL_W     = 2;
    localparam PKT_TRANS_LOCK   = 72;
    localparam SYNC_RESET       = 0;

    assign	src_valid			=  sink0_valid;
    assign	src_data			=  sink0_data;
    assign	src_channel			=  sink0_channel;
    assign	src_startofpacket  	        =  sink0_startofpacket;
    assign	src_endofpacket		        =  sink0_endofpacket;
    assign	sink0_ready			=  src_ready;
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwJew64KunF1XvgVQuKgh5KrdFwmXIAjvpMntgQ9sxy1PEL+VkwgYKhz6OAEo7/REMJ2HyrAiBH/PFgqkeB99w8HSRvbISWzfVl6BGe6AUiHFsQp0myewjohKqTn0Hw+59v0jFgA0lxEU9+Q1fEhP/OW9qZrWktz9ZJVoDjuJM0/BuLDK6bYNt2yyq3LsJm/23CmWaXlUJAeC0teXX4eXAmbYlkuwnYUMFAIpgx7+2stBRoRcWVItT8EEFfvBUGWb278ui31jeoSJORPAnmfKWOAcWcXzEBxkYGKL1Jxs08/r0g1SEe3/EEgV2yjSTFe77+K4qM2HjjWqi2mW+td6HEXNRUzhmYT7xoy5nt8NXGqvsjPOeELXi6Rqq+Uz9Eza079RETaPGBuKV89PscyBvAY1f8qw/hU1VfWdAPV8ZN8SSFlrjZ+MAxzwMwRrYMH/HDjmwXV8lnU3a1dxh2SOQb8Au0G1cxQ+yC+Yq0NEnURAhhpu9Y3vQeMjQLW0BHC4tMjntA42gp0fxhHd2ULdAMXfMOGcF9FjKm+JOho6e5KZGeSdjjhqpa2i/nTh1bhgroNtApEUOgtJTU2+i1vt/BQCVA9i//l/o2/UcT9tkCMjsWy8mJsixtfETXJ5SCD2nZWOoYHnoxarID7UZNCGlAHy4jpSISNV/RQaTL4LtmYIkjL5BHNbsX2wowDHclH1qh2AGvjBExQGiyUy7E0+Q8zSh9QvMxBn5YD0EauGVwTVc4j+DCJRB2SnOV9ZWwqwQy6cAru3fSHbJZXsfdMouh8"
`endif