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


module ed_synth_dut_altera_merlin_router_1921_irryw4q_default_decode
  #(
     parameter DEFAULT_CHANNEL = 0,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 0 
   )
  (output [152 - 152 : 0] default_destination_id,
   output [2-1 : 0] default_wr_channel,
   output [2-1 : 0] default_rd_channel,
   output [2-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[152 - 152 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 2'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 2'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 2'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module ed_synth_dut_altera_merlin_router_1921_irryw4q
(
    input clk,
    input reset,

    input                       sink_valid,
    input  [188-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    output                          src_valid,
    output reg [188-1    : 0] src_data,
    output reg [2-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    localparam PKT_ADDR_H = 67;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 152;
    localparam PKT_DEST_ID_L = 152;
    localparam PKT_PROTECTION_H = 162;
    localparam PKT_PROTECTION_L = 160;
    localparam ST_DATA_W = 188;
    localparam ST_CHANNEL_W = 2;
    localparam DECODER_TYPE = 1;

    localparam PKT_TRANS_WRITE = 70;
    localparam PKT_TRANS_READ  = 71;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    localparam ADDR_RANGE = 64'h0;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

    reg [PKT_DEST_ID_W-1 : 0] destid;

    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [2-1 : 0] default_src_channel;




    wire write_transaction;
    assign write_transaction = sink_data[PKT_TRANS_WRITE];


    ed_synth_dut_altera_merlin_router_1921_irryw4q_default_decode the_default_decode(
      .default_destination_id (),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;

        destid      = sink_data[PKT_DEST_ID_H : PKT_DEST_ID_L];



        if (destid == 0  && write_transaction) begin
            src_channel = 2'b1;
        end

    end


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


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02SzTMpIgmf3nOdrhPvGVnOhawiNmkEgxFRwdcnX1r3bWHO+1Ehgr3hMeUbX7OQ7C/ZdpQKM9Q+kboTq8sYibadjgqBGlSk0HWnxFm+8JvZxj7lh5a7kiMKdefpTRkwcTt01ownrqPh200731SFfPbGG15Y2CWwr58FJvid1lRjZW1grlc+zmW30P05sqh9CwGAPhWjRepd7g+1YNyNP825UJMRhpa9klYDYHa/b85bZAW9oNnxUTRcGU5ioLOn+AoK9xoRcgWMMeb3LB5EIGIWMa+bMS5iCp/ps0STp85WaytlaZKH/RK14UAHNm9/zt7T2Flkgr8gzisnYWkqcPcyww93QFWSGt4BeMmkqFQ8fgzBSgDtwHu3hmb73Eyu7xjMKU0nBKwLmKgNzUUy/qp/Pwc7QJvu7ObwWitxYcaDBGDE3r9g2v8GwQOo+giR6MHyEr9N/7pD5ZIdWEde0PVE/lvgL0YU31cDqfmMu98W3seJylUn/MZAkp6aYc4k6hA9+wdLkWczRRtD7TCfKjOUY8Ep0he8cG8+zvFcz9sHyVhEIxJuPD9f/CajBoUa8EA/HdWaYYTlxnMKFqvbuzSvByh+yfqeNWEUvxEBh1rCKbB3MqzOGmDfHe3kD1Ln19cmIatj0D4HbA6n5GMxjHPEeVjSuJFY7fQYf0QYsqq8Zy0BnuHoikV8geaxPLk8+h3XWOgY6ZFgsirNx2B9AfCHRJB/dnYF2yySrgSnxIl6MkxanJUrKfeQ6ZkIahP7gl8x05dZfekdYQsT2Txvk2gw5M"
`endif