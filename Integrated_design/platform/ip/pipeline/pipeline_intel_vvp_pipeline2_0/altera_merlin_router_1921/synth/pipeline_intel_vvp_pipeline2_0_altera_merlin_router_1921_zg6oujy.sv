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


// $Id: //acds/rel/25.1.1/ip/iconnect/merlin/altera_merlin_router/altera_merlin_router.sv.terp#1 $
// $Revision: #1 $
// $Date: 2025/04/24 $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// the address.
//
// Also sets the binary-encoded destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

// ------------------------------------------
// Generation parameters:
//    decoder_type            0 (address decoder)
//    default_channel         -1
//    default_destid          0
//    default_rd_channel      1
//    default_wr_channel      0
//    has_default_slave       0
//    memory_aliasing_decode  0
//    output_name             pipeline_intel_vvp_pipeline2_0_altera_merlin_router_1921_zg6oujy
//    pkt_addr_h              63
//    pkt_addr_l              36
//    pkt_dest_id_h           88
//    pkt_dest_id_l           86
//    pkt_protection_h        92
//    pkt_protection_l        90
//    pkt_trans_read          67
//    pkt_trans_write         66
//    slaves_info             4:000000100:0x0:0x200:both:1:0:0:1,2:000001000:0x200:0x400:both:1:0:0:1,3:000010000:0x400:0x600:both:1:0:0:1,1:000100000:0x600:0x800:both:1:0:0:1,5:001000000:0x800:0xa00:both:1:0:0:1,7:010000000:0xc00:0xe00:both:1:0:0:1,6:100000000:0xe00:0x1000:both:1:0:0:1,0:000000001:0x8000000:0x10000000:write:1:0:0:1,0:000000010:0x8000000:0x10000000:read:1:0:0:1
//    st_channel_w            9
//    st_data_w               156
// ------------------------------------------

module pipeline_intel_vvp_pipeline2_0_altera_merlin_router_1921_zg6oujy_default_decode
  #(
     parameter DEFAULT_CHANNEL = -1,
               DEFAULT_WR_CHANNEL = 0,
               DEFAULT_RD_CHANNEL = 1,
               DEFAULT_DESTID = 0 
   )
  (output [88 - 86 : 0] default_destination_id,
   output [9-1 : 0] default_wr_channel,
   output [9-1 : 0] default_rd_channel,
   output [9-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[88 - 86 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 9'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 9'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 9'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module pipeline_intel_vvp_pipeline2_0_altera_merlin_router_1921_zg6oujy
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [156-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [156-1    : 0] src_data,
    output reg [9-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 63;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 88;
    localparam PKT_DEST_ID_L = 86;
    localparam PKT_PROTECTION_H = 92;
    localparam PKT_PROTECTION_L = 90;
    localparam ST_DATA_W = 156;
    localparam ST_CHANNEL_W = 9;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 66;
    localparam PKT_TRANS_READ  = 67;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'h10000000;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [9-1 : 0] default_rd_channel;
    wire [9-1 : 0] default_wr_channel;




    // -------------------------------------------------------
    // Write and read transaction signals
    // -------------------------------------------------------
    wire write_transaction;
    assign write_transaction = sink_data[PKT_TRANS_WRITE];
    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    pipeline_intel_vvp_pipeline2_0_altera_merlin_router_1921_zg6oujy_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (default_wr_channel),
      .default_rd_channel   (default_rd_channel),
      .default_src_channel  ()
    );

    always @* begin
        src_data    = sink_data;
        src_channel = write_transaction ? default_wr_channel : default_rd_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

        // slave 0: [0x0, 0x200) : sel [27:9]
        if ( {address[27:9],{9 {1'b0}}} == 28'h0   ) begin
            src_channel = 9'b000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
        end

        // slave 1: [0x200, 0x400) : sel [27:9]
        if ( {address[27:9],{9 {1'b0}}} == 28'h200   ) begin
            src_channel = 9'b000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
        end

        // slave 2: [0x400, 0x600) : sel [27:9]
        if ( {address[27:9],{9 {1'b0}}} == 28'h400   ) begin
            src_channel = 9'b000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
        end

        // slave 3: [0x600, 0x800) : sel [27:9]
        if ( {address[27:9],{9 {1'b0}}} == 28'h600   ) begin
            src_channel = 9'b000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
        end

        // slave 4: [0x800, 0xa00) : sel [27:9]
        if ( {address[27:9],{9 {1'b0}}} == 28'h800   ) begin
            src_channel = 9'b001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
        end

        // slave 5: [0xc00, 0xe00) : sel [27:9]
        if ( {address[27:9],{9 {1'b0}}} == 28'hc00   ) begin
            src_channel = 9'b010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
        end

        // slave 6: [0xe00, 0x1000) : sel [27:9]
        if ( {address[27:9],{9 {1'b0}}} == 28'he00   ) begin
            src_channel = 9'b100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
        end

        // slave 7: [0x8000000, 0x10000000) : sel [27:27]
        if ( {address[27:27],{27 {1'b0}}} == 28'h8000000  && write_transaction  ) begin
            src_channel = 9'b000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
        end

        // slave 8: [0x8000000, 0x10000000) : sel [27:27]
        if ( {address[27:27],{27 {1'b0}}} == 28'h8000000  && read_transaction  ) begin
            src_channel = 9'b000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
        end
    end


    // --------------------------------------------------
    // Ceil(log2()) function
    // It's the 21st century. Consider using $clog2().
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


