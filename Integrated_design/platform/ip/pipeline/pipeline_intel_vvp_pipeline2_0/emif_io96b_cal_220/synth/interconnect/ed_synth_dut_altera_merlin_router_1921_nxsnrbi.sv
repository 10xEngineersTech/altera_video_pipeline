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


module ed_synth_dut_altera_merlin_router_1921_nxsnrbi_default_decode
  #(
     parameter DEFAULT_CHANNEL = 0,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 0 
   )
  (output [404 - 404 : 0] default_destination_id,
   output [2-1 : 0] default_wr_channel,
   output [2-1 : 0] default_rd_channel,
   output [2-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[404 - 404 : 0];

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


module ed_synth_dut_altera_merlin_router_1921_nxsnrbi
(
    input clk,
    input reset,

    input                       sink_valid,
    input  [440-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    output                          src_valid,
    output reg [440-1    : 0] src_data,
    output reg [2-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    localparam PKT_ADDR_H = 319;
    localparam PKT_ADDR_L = 288;
    localparam PKT_DEST_ID_H = 404;
    localparam PKT_DEST_ID_L = 404;
    localparam PKT_PROTECTION_H = 414;
    localparam PKT_PROTECTION_L = 412;
    localparam ST_DATA_W = 440;
    localparam ST_CHANNEL_W = 2;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 322;
    localparam PKT_TRANS_READ  = 323;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    localparam ADDR_RANGE = 64'h8000000;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;


    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [2-1 : 0] default_src_channel;




    wire write_transaction;
    assign write_transaction = sink_data[PKT_TRANS_WRITE];


    ed_synth_dut_altera_merlin_router_1921_nxsnrbi_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

           
         if (write_transaction) begin
          src_channel = 2'b1;
          src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
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
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02Syfae97YPldbfKjCk14sIGLHs+Hns5tvswxRRk6gvW1sL2sQfO1Ki97oHVDRlH9/4HkJqqGwEW6Syfp/gSIhBfNGX4chgxePbEVsvFD11IA2PNEcHq7tgCHqcj0Ru+4SvLtOSUFq2MrFIEXMtrc/B7wzBQJxtXS6E5ZHVx1hgk4y6miWpYVurm2lOK+U0PvmbTw0fLhxCD4sTuhkqrKGGpMKl5wt3gXg/0JZxliDlfKKoMm7qHmqOjFcYWfzLevwW83LZDOHEdRkmCARfZsC25kJrl7VJDUPRkLne+1rCAStQmsgpAfcds/1+h2L+z//UKcwYjb2GZEcG19d1acf7CELiutfi5P6lpwE/19izFfMIasf+agjQG17qkVOsoK5LQ2j+N2Jds9FCRxMMX2Y099Qjd2WnRqWr6D6KADTrqThVDsu1HWgMFvDb0nsqKPlcxPfajcd7iRw1dGQkcxq7gZj1LQVYfUgx+301LWHiLXUpBORSjs7Hc6aJ6TMl1+Lw87NQ8wXETl07CE2+xt+1qZPyWnhZvX1UN7feDT2y7uxyoGR9wm1Ec16B/+w9UbUPC4kjQYbQ3f00mlZlMSChpmmPUu0aK4Y8NPW44sZxz5M5RzSDQH471LqSf/p80OBuy/L7SVDUhS3Bkr3row18L0BmdvnHRU8ZeFidOf5HTwjXMN890nonxdhvf4L0cqHnV+kpaGrxcIYKvsUUu2rJWS3O6e4IS+nq2mJlyOT9rR1CJWWDA2sfj7FcZCKQk0xE+H5INKswRifKEtR2C1alLc"
`endif