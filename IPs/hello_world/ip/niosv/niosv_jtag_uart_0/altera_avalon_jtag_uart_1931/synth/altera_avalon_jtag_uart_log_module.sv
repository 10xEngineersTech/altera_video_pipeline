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

module altera_avalon_jtag_uart_log_module #(
  parameter FIFO_WIDTH = 8
  ) (
  // inputs:
   clk,
   data,
   strobe,
   valid
    )
;

  input                     clk;
  input   [FIFO_WIDTH-1: 0] data;
  input                     strobe;
  input                     valid;



//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
   reg [31:0] text_handle; // for $fopen
   initial text_handle = $fopen ("altera_avalon_jtag_uart_output_stream.dat");

   always @(posedge clk) begin
      if (valid && strobe) begin
	 // Send \n (linefeed) instead of \r (^M, Carriage Return)...
         $fwrite (text_handle, "%s", ((data == 8'hd) ? 8'ha : data));
	 // non-standard; poorly documented; required to get real data stream.
	 $fflush (text_handle);
      end
   end // clk


//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SdgU9W/I3Un6mG6zxE4tpLSApCrsI97qN+aYYN4ywNrs4nnUSll4ckaRTU3FRIiEd9MllZ6mJdvi990RtsSB8FE2yrbcspPnDCWzh6v+WDKIcw2hM9759RKXg2QdHGMdjMF1upE6hGueC5zC1QyfItkC8S+1BIbhfbj5mNjROFu7aSecOjFmwUX8iIcYJFHDN4xQKpcAAy8AIHvTqsu/RqI9WBL/1cAlK7jqy9ZpuNXRuecAJ7FnlrBn5ZY3+8jdOAcimzB4zUzC9uzC9nPQtw8GfAbNUthjqxAw2sb0Ex3N5z1CNsB+EZg2TfXumowi+LqZUJiGhlZ24VQA2IaykmIKdt4p8e3ku4+uGVVBtnhca8C3rCzlfO0kJQOaYOloym6MdULOWSiNrwNlE3ytgZ24852owttQKQJ8zvUKbZUVlsB1PeLHKJ+eoaQsttuDYKyg7Wju1LVrMQPmS928Sdo0OLj9VOUALaaSSseZaDbZAsUsuld9GaE1J1z++G3kbcILbCsOiHMfGZXONiw3Tt5/Vuo18QD+xy6BzhAUBh1uTL6k5966P6lZI0iobuUuGaCyhPb+OWXEZ4VATS4uAu+NBmVFxAGhBv2HggHq2YGd3UlRAMXqcFCzwp/WAHQiIOWiN7t5mI2XpQ5oVKAB0CiBwS8g+u+hKHLWEBqtyVMSmLMXxSVwbs8VmIgyg3hrIzO7o34mj5XYzDQA4sNgPxZ8GQKMiP35jVBYC5GZT0RQfoz9gteYTHccjtccFQzqKO0QuMAPtwJeB6+5pfGk/paa7H55dXBNCAhD8j2pyO5krsRBXbChbBg9MWja0XhEfySbX9/TtupV3DCck5Ypx+jIbFIxycQ4y3lWhGvz6tmSgP1onllPCzRek0D3dC62n5uzMM3nzU9nBz+/3hQtUmarOVIHIM9XgS/mRZE4eyCd4B0J+576Q1kKRZ9L/iUBe72VjQBeKl9rXK1O3SznLAShvBAeHhLB84YKxYV5cTj5P1xaxzILPSch4XPquAhV"
`endif