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
module ed_synth_dut_altera_merlin_demultiplexer_1921_rcor4va
(
    input  [1-1      : 0]   sink_valid,
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
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwKe9Lscoqwc+SQfsWspCxN882Fyi/j+oQGV99cIdqtFhbg8zdjEUWeNpzQxl7BAKuhE0kBryUECxv4u/agH0XFZYJDmATo6xkEOz3hdCV1xb4V5UT7WGm5ASPGggnzx84mFNckMABGAx7eTKEhLBePLq/N7FJqUCgpLizDZscIIjKFqkSXqhp5OWFuL/cNCW0UMcZYf2Eo4b5m0YX24/Tov+iigMv0OIGHbJ1uD80lNa964TlF2dsa/978fkIBXMkyia4BSotKnTZCV/Ta955fyUrNHcLLkd+WQBrY0wMmQWoo2PeRMIv+EEFfOoSOF4Cwy0jDtMmlDTheCr+ei6RVJ2fb9fmzbU6sB5imXhHlSxN9uYKA1AULQhoamScuzfpEBjKs81VXZjYfcEa2on/bNG6mF/Qh7eR6nddezh9UmIa3XV89t2vMpM/kqSgKUnNEKzkYKWsH0MAa3ALayIppb/v8yOD2w4UHTWZPVljktWKECHDfQz+uSCU++eQebf6aIj7boW8Zx9pRAEaugPVDjY9KJHM4jhR1sVh3WRhJmiuKPf/yB+ex3we5XEPB1VuBRhXs6kqIHedFKLHBUirTmYwUnjTjeOSEVgZEBYBK9WhsV8BUYGhbLZ4tNdBL2OxqyiJAFiXYg39+qrC2uXpsKDIeH7OOozImxUJngT9pguzaLGg62E3xzr6uxtWMnOuOltAPL4+GXJlOhn6r2FRR/pV4pLWkDdR8qj3dQqlDrd3zEuan08w/2PfH6ud77MxYGLduHFkq2X5SZemkn5H44"
`endif