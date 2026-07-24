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


// $File: //acds/rel/25.1.1/ip/iconnect/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv $
// $Revision: #1 $
// $Date: 2025/04/24 $
// $Author: psgswbuild $
//------------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_st_pipeline_stage #(
    parameter 
      USE_FIFO_IP = 0, // unsued at moment
      SYMBOLS_PER_BEAT = 1,
      BITS_PER_SYMBOL = 8,
      USE_PACKETS = 0,
      USE_EMPTY = 0,
      PIPELINE_READY = 1,
      SYNC_RESET     = 0,
      // Optional ST signal widths.  Value "0" means no such port.
      CHANNEL_WIDTH = 0,
      ERROR_WIDTH = 0,

      // Derived parameters
      DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL,
      PACKET_WIDTH = 0,
      EMPTY_WIDTH = 0
  )
  (
    input clk,
    input reset,

    output in_ready,
    input in_valid,
    input [DATA_WIDTH - 1 : 0] in_data,
    input [(CHANNEL_WIDTH ? (CHANNEL_WIDTH - 1) : 0) : 0] in_channel,
    input [(ERROR_WIDTH ? (ERROR_WIDTH - 1) : 0) : 0] in_error,
    input in_startofpacket,
    input in_endofpacket,
    input [(EMPTY_WIDTH ? (EMPTY_WIDTH - 1) : 0) : 0] in_empty,

    input out_ready,
    output out_valid,
    output [DATA_WIDTH - 1 : 0] out_data,
    output [(CHANNEL_WIDTH ? (CHANNEL_WIDTH - 1) : 0) : 0] out_channel,
    output [(ERROR_WIDTH ? (ERROR_WIDTH - 1) : 0) : 0] out_error,
    output out_startofpacket,
    output out_endofpacket,
    output [(EMPTY_WIDTH ? (EMPTY_WIDTH - 1) : 0) : 0] out_empty
);
  localparam 
    PAYLOAD_WIDTH = 
      DATA_WIDTH +
      PACKET_WIDTH +
      CHANNEL_WIDTH +
      EMPTY_WIDTH +
      ERROR_WIDTH;

  wire [PAYLOAD_WIDTH - 1: 0] in_payload;
  wire [PAYLOAD_WIDTH - 1: 0] out_payload;

  // Assign in_data and other optional in_* interface signals to in_payload.
  assign in_payload[DATA_WIDTH - 1 : 0] = in_data;
  generate
    // optional packet inputs
    if (PACKET_WIDTH) begin
      assign in_payload[
        DATA_WIDTH + PACKET_WIDTH - 1 : 
        DATA_WIDTH
      ] = {in_startofpacket, in_endofpacket};
    end
    // optional channel input
    if (CHANNEL_WIDTH) begin
      assign in_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH
      ] = in_channel;
    end
    // optional empty input
    if (EMPTY_WIDTH) begin
      assign in_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH
      ] = in_empty;
    end
    // optional error input
    if (ERROR_WIDTH) begin
      assign in_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH + ERROR_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH
      ] = in_error;
    end
  endgenerate

  localparam NUM_128BIT_SLOTS = (PAYLOAD_WIDTH / 128) + (((PAYLOAD_WIDTH % 128) == 0) ? 0 : 1);
  localparam LAST_PAYLOAD_W = ((PAYLOAD_WIDTH % 128) == 0) ? 128 : (PAYLOAD_WIDTH % 128); 
  genvar i;
  generate 
  for (i = 0; i < NUM_128BIT_SLOTS; i = i + 1) begin : gen_inst
      if (i == NUM_128BIT_SLOTS - 1) begin
         altera_avalon_st_pipeline_base #(
           .SYMBOLS_PER_BEAT (LAST_PAYLOAD_W),
           .BITS_PER_SYMBOL (1),
           .PIPELINE_READY (PIPELINE_READY),
           .SYNC_RESET (SYNC_RESET)
          ) core (
            .clk (clk),
            .reset (reset),
            .in_ready (in_ready),
            .in_valid (in_valid),
            .in_data (in_payload[(i*128)+LAST_PAYLOAD_W-1:i*128]),
            .out_ready (out_ready),
           .out_valid (out_valid),
           .out_data (out_payload[(i*128)+LAST_PAYLOAD_W-1:i*128])
	  );
      end
      else begin
         altera_avalon_st_pipeline_base #(
           .SYMBOLS_PER_BEAT (128),
           .BITS_PER_SYMBOL (1),
           .PIPELINE_READY (PIPELINE_READY),
           .SYNC_RESET (SYNC_RESET)
         ) core (
           .clk (clk),
           .reset (reset),
           .in_ready (),
           .in_valid (in_valid),
           .in_data (in_payload[(i+1)*128-1:i*128]),
           .out_ready (out_ready),
           .out_valid (),
           .out_data (out_payload[(i+1)*128-1:i*128])
         );
      end
  end
  endgenerate

  // Assign out_data and other optional out_* interface signals from out_payload.
  assign out_data = out_payload[DATA_WIDTH - 1 : 0];
  generate
    // optional packet outputs
    if (PACKET_WIDTH) begin
      assign {out_startofpacket, out_endofpacket} = 
        out_payload[DATA_WIDTH + PACKET_WIDTH - 1 : DATA_WIDTH];
    end else begin
      // Avoid a "has no driver" warning.
      assign {out_startofpacket, out_endofpacket} = 2'b0;
    end

    // optional channel output
    if (CHANNEL_WIDTH) begin
      assign out_channel = out_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH
      ];
    end else begin
      // Avoid a "has no driver" warning.
      assign out_channel = 1'b0;
    end
    // optional empty output
    if (EMPTY_WIDTH) begin
      assign out_empty = out_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH
      ];
    end else begin
      // Avoid a "has no driver" warning.
      assign out_empty = 1'b0;
    end
    // optional error output
    if (ERROR_WIDTH) begin
      assign out_error = out_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH + ERROR_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH
      ];
    end else begin
      // Avoid a "has no driver" warning.
      assign out_error = 1'b0;
    end
  endgenerate

endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "wQtgtvKqJWgrzDkwk9GAB3thpTs1dbdVeXyagZEhYTY0TMU8uc8IINKw+JyOf/7B8h8x4eAHQa1nQuclXFA1+de6umTnjzgDN7g0Vp7/b+0JZRjeFjZ29eSUCyTa4mf28hxqY5qEFP2+jg3PI70fs5Wkg+PZ005d8LkvRNfNZpGJPIH6A/rnn76qg5DXUAcXqp/MHAFYqQimdC2Ohgkg3svZ3yq0mcf7iSWH62kEwydjnFIA7u7ANf5e6W6DedyPygCtwFhhIw57axRPsOQbdgDRuVbOHhmG0EtjYDuZRJZk+1gTETO6NjbW4LrQ9a1GEcJEphA9Moknthgw+uvx+nS4enS2wmY9zENVZ1vAKedbu/Ny4vZpJJLWETjIVzMHr7zqx7JL2rIPu8cS1D28h2maBoCc2gWsYwbs9ois6Tt2NneGw8odIXbIiMjc+i00yWnrIc0FJFwLPFQ7rMYcOja4n3sSIa0b+Zb1vpSbYLw6RJjDJJAyWiBrlrXOhdQsEWN9kBRi0vhXxWEznOczXatuahgnbLvuQPbK+MJ/+wS3IdYT0MtThulhCjLF5ftIXEOYuvWfl9tR4wswEPKQ9I3yN1dlUniXRDND7zhdm2n8UYzJO1P3jzeceHgd5t3+tHCaKtk627RytsAf8EwADDmGiBwka3On1IzOTRhpU9uw/FkIFRlr/Rh+2aAE6k6AhKQRb5H08fUu4rKrXqFImZUum2H0v/mLf+Kqm55Gja/dmblRbxTotJMe1nKzcSMaaAK3pVQ5uq5JgcJYW/xw9S+rmFA3TDNc7QrmYmARhUrVHIXpGXNoG79eXvDzxMDBZuiip4dhosKitqg6b+NXb43u9QPwPu0UvY4iJidWUv7w+i81cbIRyZmSeNzICRhtkPJ6mNa5d/HSEZ+lXdLTHUbkGv0KyBb++g0hnHaTxUknqr34svATICYWebUxkZM2GZoqZGAc77zEiPdF3gWKjg3dxje42dXhbOT1BYlMK61jtVg46JVv0O/Oafkoww8L"
`endif