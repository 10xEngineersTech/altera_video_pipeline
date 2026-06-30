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

module altera_avalon_jtag_uart_scfifo_w #(
  parameter FIFO_WIDTH = 8,
  parameter WR_WIDTHU = 6,
  parameter write_le = "ON",
  parameter writeBufferDepth = 64,
  parameter printingMethod = 0
  ) (
  // inputs:
   clk,
   fifo_clear,
   fifo_wdata,
   fifo_wr,
   rd_wfifo,

  // outputs:
   fifo_FF,
   r_dat,
   wfifo_empty,
   wfifo_used
    )
;

  output                    fifo_FF;
  output  [FIFO_WIDTH-1: 0] r_dat;
  output                    wfifo_empty;
  output  [WR_WIDTHU-1: 0]  wfifo_used;
  input                     clk;
  input                     fifo_clear;
  input   [FIFO_WIDTH-1: 0] fifo_wdata;
  input                     fifo_wr;
  input                     rd_wfifo;


wire                      fifo_FF;
wire    [FIFO_WIDTH-1: 0] r_dat;
wire                      wfifo_empty;
wire    [WR_WIDTHU-1: 0]  wfifo_used;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  altera_avalon_jtag_uart_sim_scfifo_w
    #(
      .FIFO_WIDTH       (FIFO_WIDTH),
      .WR_WIDTHU        (WR_WIDTHU),
      .printingMethod   (printingMethod)
     )
altera_avalon_jtag_uart_sim_scfifo_w
    (
      .clk         (clk),
      .fifo_FF     (fifo_FF),
      .fifo_wdata  (fifo_wdata),
      .fifo_wr     (fifo_wr),
      .rst_n       (rst_n),
      .r_dat       (r_dat),
      .wfifo_empty (wfifo_empty),
      .wfifo_used  (wfifo_used)
    );


//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on
//synthesis read_comments_as_HDL on
//  scfifo wfifo
//    (
//      .aclr (fifo_clear),
//      .sclr (1'b0),
//      .clock (clk),
//      .data (fifo_wdata),
//      .empty (wfifo_empty),
//      .full (fifo_FF),
//      .q (r_dat),
//      .rdreq (rd_wfifo),
//      .usedw (wfifo_used),
//      .wrreq (fifo_wr)
//    );
//
//  defparam wfifo.lpm_hint = "RAM_BLOCK_TYPE=AUTO",
//           wfifo.lpm_numwords = writeBufferDepth,
//           wfifo.lpm_showahead = "OFF",
//           wfifo.lpm_type = "scfifo",
//           wfifo.lpm_width = FIFO_WIDTH,
//           wfifo.lpm_widthu = WR_WIDTHU,
//           wfifo.overflow_checking = "OFF",
//           wfifo.underflow_checking = "OFF",
//           wfifo.use_eab = write_le;
//
//synthesis read_comments_as_HDL off

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SdgU9W/I3Un6mG6zxE4tpLSApCrsI97qN+aYYN4ywNrs4nnUSll4ckaRTU3FRIiEd9MllZ6mJdvi990RtsSB8FE2yrbcspPnDCWzh6v+WDKIcw2hM9759RKXg2QdHGMdjMF1upE6hGueC5zC1QyfItkC8S+1BIbhfbj5mNjROFu7aSecOjFmwUX8iIcYJFHDN4xQKpcAAy8AIHvTqsu/RqI9WBL/1cAlK7jqy9ZpuNUCoyhaqT2pWZPPn69nNTBJxt5Ff1pT4Kj0cGU2JFk/2AaJh5z3gvg8+J4bVtxzzm7jU5mCYBAXOKsLQ3lmnuiMPIarjiJVjNh98SlBs/Yd4VVuHIaqsky+CXEknL0lIT03nWzqfOW9unwPIHQ49ZAakzRre9jNswPCUnNgEvU95gsYWOIPcyNGRsAPgHg0527I9VVLSRN8c/SGUQazivFn26A+1nOj6TjEvMetAtuzUpcgZX2TtDr9Hbgv2XiPCncyuUJtgSokEBdqYiXnjNy5XSGcdYcxQYQ7PZqvLgodRnip6LxIyM5tRaS/wxsvMKae59eagr8g4kf3HuMfsQ+As2jtxdW/GR2tpQ2mTKKc/3e5DlgNV1T9q1jPLm8XpDBN5HbJM4oTyuHqcQyFEyJFAn5S8aFfvswLKvBVvkBVB0aAx/AuWVrGUBaCCGbdJMWaBFtDyQuKeHVXeDEYhCN/FH395WWHtSwJVtWmTKhVsSUudPF+SmMIapBEMx2FJPoZJFBcWJTJExoFYg5CzUvyPqNO42N2ubcRfDJRoYxVx/kitRs3NnYa/E4A/50c4XdWbu3gJVVqJslLMF9fdCuCv1GUad3jS1AM5EmJE8hL7JoCY7x2sOy6DKdkDvgSxvuFfNDMMJYNVhpxYAoo5k2idAkFyjI+LbHEZSOn8RNalSYYQX32nfaDLX1tEm4+ztqqDpWEFeZKj54sh2c4hJI0x0f9HIsWPpaBUWGUBXK8E9dXKOCPoKVRKxyhqJQBHgW7l1rsbf0sbKDyyWGbMYWI"
`endif