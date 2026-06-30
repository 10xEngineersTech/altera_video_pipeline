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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 13469 16735 16788 

module altera_avalon_jtag_uart_sim_scfifo_r #(
  parameter FIFO_WIDTH = 8,
  parameter RD_WIDTHU = 6,
  parameter HEX_READ_DEPTH_STR = 64
  ) (
  // inputs:
   clk,
   fifo_rd,
   rst_n,

  // outputs:
   fifo_EF,
   fifo_rdata,
   rfifo_full,
   rfifo_used
    )
;

  output                    fifo_EF;
  output  [FIFO_WIDTH-1: 0] fifo_rdata;
  output                    rfifo_full;
  output  [RD_WIDTHU-1: 0]  rfifo_used;
  input                     clk;
  input                     fifo_rd;
  input                     rst_n;


reg     [31: 0]           bytes_left;
wire                      fifo_EF;
reg                       fifo_rd_d;
wire    [FIFO_WIDTH-1: 0] fifo_rdata;
wire                      new_rom;
wire    [31: 0]           num_bytes;
wire    [RD_WIDTHU+1: 0]  rfifo_entries;
wire                      rfifo_full;
wire    [RD_WIDTHU-1: 0]  rfifo_used;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  // Generate rfifo_entries for simulation
  always @(posedge clk or negedge rst_n)
    begin
      if (rst_n == 0)
        begin
          bytes_left <= 32'h0;
          fifo_rd_d <= 1'b0;
        end
      else 
        begin
          fifo_rd_d <= fifo_rd;
          // decrement on read
          if (fifo_rd_d)
              bytes_left <= bytes_left - 1'b1;
          // catch new contents
          if (new_rom)
              bytes_left <= num_bytes;
        end
    end


  assign fifo_EF = bytes_left == 32'b0;
  assign rfifo_full = bytes_left > HEX_READ_DEPTH_STR;
  assign rfifo_entries = (rfifo_full) ? HEX_READ_DEPTH_STR : bytes_left;
  assign rfifo_used = rfifo_entries[RD_WIDTHU-1 : 0];
  assign new_rom = 1'b0;
  assign num_bytes = 32'b0;
  assign fifo_rdata = 8'b0;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SdgU9W/I3Un6mG6zxE4tpLSApCrsI97qN+aYYN4ywNrs4nnUSll4ckaRTU3FRIiEd9MllZ6mJdvi990RtsSB8FE2yrbcspPnDCWzh6v+WDKIcw2hM9759RKXg2QdHGMdjMF1upE6hGueC5zC1QyfItkC8S+1BIbhfbj5mNjROFu7aSecOjFmwUX8iIcYJFHDN4xQKpcAAy8AIHvTqsu/RqI9WBL/1cAlK7jqy9ZpuNXv4PA3Gb7EAsvz6ymNHg6IhGh0oCQJEXxddTcD/DtVvWyksQdZB4rvv1xplc6aRCQ5XDgG6A6Hw04mRG2GMbN7NVqYTGdhX/dst55cPCDQfyM25TvRmnCqfsdRupE0uBngs0SRAPln8mfkNt3zh4Jr9bxnsY7R5sXtYynoFdn6vmbMeiGg6wM//kNKiZpiApDyNVZhxWEkS9iVkCxpWdUirNoHG6z0HW+4xKG6h1Ln7e6hOSVuH//rIClZyLF0ZW/cPODvsKKQ7+gteU+7Nvsx8x+uw7FfbWRjXrQAwLRAq05i72ZkoMZMfj3QAtb3vC8dvREAWw79pyQY1fHhgxCGf4oJ1Yf29opg4R8K5q9ZwNMeb3IYQIWP7euN0MKziCYCWtzzJhV76dIGRQ4naO1O6bFf3VvhIZwjj+SIoRWkLA2QylK8TDbjRCIxnFjby+YfnZPupBtwtCmjGhX8Nxq81fJgjzqApglkniGOnTOkRX3kDF9mpUflUl7CNK20E1F/1rAMtbXVFbCqpbILUN7fGZhJ7rvqaX+CpdylVG19nuDzPQ67bfWPf3A2bHWN/Wof85Sj/879EdPoo7iAZQOxnj23YR4tlTMDCsJEToRATkQGhuhZif2kop3i02AWT0ldfJwjm6ahCGmLasto64MmXC2kXcHHkg/QGgqKDvZ64nh+ual8ZMxKLtodlI6MmAfy355tKkooJWJXCg/7rhTDuwgtp8oh8ltNsrlRxMa2mSqdaDHz8+8WKIh75NUHt+8V92D1lCZ/v0Ha5xBn7dg0"
`endif