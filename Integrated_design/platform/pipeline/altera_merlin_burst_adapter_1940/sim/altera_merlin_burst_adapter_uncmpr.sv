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


// (C) 2001-2012 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other
// software and tools, and its AMPP partner logic functions, and any output
// files any of the foregoing (including device programming or simulation
// files), and any associated documentation or information are expressly subject
// to the terms and conditions of the Altera Program License Subscription
// Agreement, Altera MegaCore Function License Agreement, or other applicable
// license agreement, including, without limitation, that your use is for the
// sole purpose of programming logic devices manufactured by Altera and sold by
// Altera or its authorized distributors.  Please refer to the applicable
// agreement for further details.


// $Id: //acds/main/ip/merlin/altera_merlin_burst_adapter/altera_merlin_burst_adapter.sv#68 $
// $Revision: #68 $
// $Date: 2014/01/23 $

`timescale 1 ns / 1 ns

// -------------------------------------------------------
// Adapter for uncompressed transactions only. This adapter will
// typically be used to adapt burst length for non-bursting 
// wide to narrow Avalon links.
// -------------------------------------------------------
module altera_merlin_burst_adapter_uncompressed_only
#(
    parameter 
    PKT_BYTE_CNT_H  = 5,
    PKT_BYTE_CNT_L  = 0,
    PKT_BYTEEN_H    = 83,
    PKT_BYTEEN_L    = 80,
    ST_DATA_W       = 84,
    ST_CHANNEL_W    = 8
)
(
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                           sink0_valid,
    input  [ST_DATA_W-1 : 0]        sink0_data,
    input  [ST_CHANNEL_W-1 : 0]     sink0_channel,
    input                           sink0_startofpacket,
    input                           sink0_endofpacket,
    output reg                      sink0_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output reg                      source0_valid,
    output reg [ST_DATA_W-1    : 0] source0_data,
    output reg [ST_CHANNEL_W-1 : 0] source0_channel,
    output reg                      source0_startofpacket,
    output reg                      source0_endofpacket,
    input                           source0_ready
);
    localparam
        PKT_BYTE_CNT_W = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
        NUM_SYMBOLS    = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;

    wire [PKT_BYTE_CNT_W - 1 : 0] num_symbols_sig = NUM_SYMBOLS[PKT_BYTE_CNT_W - 1 : 0];

    always_comb begin : source0_data_assignments
        source0_valid         = sink0_valid;
        source0_channel       = sink0_channel;
        source0_startofpacket = sink0_startofpacket;
        source0_endofpacket   = sink0_endofpacket;

        source0_data          = sink0_data;
        source0_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L] = num_symbols_sig;

        sink0_ready = source0_ready;
    end

endmodule



`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2drP+sazgX0dFgvJXkad//JE7EoPB7Z9a/l/nmbWjjvOJ1vTyAej+27pfC9dUizmcVmwGHLzebopS/IoT2mM0rDIBTeOSaYKTz3KdEH/h9XSkHdjtfp4aGXYu6ARXLVobymCLGNQ20gkA0gDGGsYTHUMlIaJZSSNKBSNue4fOjBo+OUtfL1cAmu3nXseSTP9lXqepLK9DxyLdom6TcCWNQ1dGjNWd/UaIN8XTqFQX9cat9Z720mWfrj8gcW8MF0ARJMbyNPkGPul6APXjJ34QL/TIwhjsofzbBZ7A46eD3lQfg8C/6SBG33Zr1VoA8HT0n2JeIwQlP3QMNeQSAW+b8fxIeM/IoE24AjNlNWUhJVaHrtSRjnNl2gUR4+N9Y6fUji+5kJVefBRs8jYlzbH33WaBv9zJpkMaySxhqxUwL1ocJxhqwPZf2XvGJxYy8wYRKz1+451tMBE3mFjuIO8OBkhslzKLA1Yqc3sTRXRSrSJ2a4gHS2/TJiv/Fon9Yvjf+MQBcAdE3GwuQ/G4NUfM/eUfAOUgCYTHniu1UrcMv91TYoWoYsZIBi3nakYH+2dt+I1spoAepCJygzZ+cOrtO7cST9rz4a2rpyT8+8yKotKCUUPXFmywjRRndMNbAc47kEEDL7sjjSKS2f+bv2XNceJYtzt8DSEXCZVYFMjt1STr7mo/QBhjhGQQwZ7Nxa+MQcO10qncX2Z2pxkJPddx2r7eEcKXcIR9MLugq7Mz5WLkoM/1KwHAfOMPhzJfCExWDAfOGn3r8vr0RHV26GehlKQN5HxcC0caQ1lQvRvEYCO56UceCM+zG3dTNxaBWpTc5dzMACbtam/PDw3c9sh163DV2U/lwP+AU9rwOucoqFKsInDzRJqyygYwli5E3UUrTeHB1C8LfOvyDhGJCxnRW9c7Nm9Y357lEyL3sygsc0CPZ+E9+KUExbHk+KZbWsevHluDxLBc1VFlm2HgcukzST3jrr3JGz8fOSPLF6D46GBXemcZMeYtcofUEWH/9bx"
`endif