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


// $Id: //acds/rel/25.1.1/ip/iconnect/pd_components/altera_std_synchronizer/altera_std_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2025/04/24 $
// $Author: psgswbuild $
//-----------------------------------------------------------------------------
//
// File: altera_std_synchronizer.v
//
// Abstract: Single bit clock domain crossing synchronizer. 
//           Composed of two or more flip flops connected in series.
//           Random metastable condition is simulated when the 
//           __ALTERA_STD__METASTABLE_SIM macro is defined.
//           Use +define+__ALTERA_STD__METASTABLE_SIM argument 
//           on the Verilog simulator compiler command line to 
//           enable this mode. In addition, dfine the macro
//           __ALTERA_STD__METASTABLE_SIM_VERBOSE to get console output 
//           with every metastable event generated in the synchronizer.
//
// Copyright (C) Altera Corporation 2009, All Rights Reserved
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_std_synchronizer (
				clk, 
				reset_n, 
				din, 
				dout
				);

   parameter depth = 3; // This value must be >= 2 !
     
   input   clk;
   input   reset_n;    
   input   din;
   output  dout;

   // QuartusII synthesis directives:
   //     1. Preserve all registers ie. do not touch them.
   //     2. Do not merge other flip-flops with synchronizer flip-flops.
   // QuartusII TimeQuest directives:
   //     1. Identify all flip-flops in this module as members of the synchronizer 
   //        to enable automatic metastability MTBF analysis.
   //     2. Cut all timing paths terminating on data input pin of the first flop din_s1.

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]\" "} *) reg din_s1;

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [depth-2:0] dreg;    
   
   //synthesis translate_off
   initial begin
      if (depth <2) begin
	 $display("%m: Error: synchronizer length: %0d less than 2.", depth);
      end
   end

   // the first synchronizer register is either a simple D flop for synthesis
   // and non-metastable simulation or a D flop with a method to inject random
   // metastable events resulting in random delay of [0,1] cycles
   
`ifdef __ALTERA_STD__METASTABLE_SIM

   reg[31:0]  RANDOM_SEED = 123456;      
   wire  next_din_s1;
   wire  dout;
   reg   din_last;
   reg 	 random;
   event metastable_event; // hook for debug monitoring

   initial begin
      $display("%m: Info: Metastable event injection simulation mode enabled");
   end
   
   always @(posedge clk) begin
      if (reset_n == 0)
	random <= $random(RANDOM_SEED);
      else
	random <= $random;
   end

   assign next_din_s1 = (din_last ^ din) ? random : din;   

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_last <= 1'b0;
       else
	 din_last <= din;
   end

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_s1 <= 1'b0;
       else
	 din_s1 <= next_din_s1;
   end
   
`else 

   //synthesis translate_on   
   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
	 din_s1 <= 1'b0;
       else
	 din_s1 <= din;
   end
   //synthesis translate_off      

`endif

`ifdef __ALTERA_STD__METASTABLE_SIM_VERBOSE
   always @(*) begin
      if (reset_n && (din_last != din) && (random != din)) begin
	 $display("%m: Verbose Info: metastable event @ time %t", $time);
	 ->metastable_event;
      end
   end      
`endif

   //synthesis translate_on

   // the remaining synchronizer registers form a simple shift register
   // of length depth-1
   generate
      if (depth < 3) begin
	 always @(posedge clk or negedge reset_n) begin
	    if (reset_n == 0) 
	      dreg <= {depth-1{1'b0}};	    
	    else
	      dreg <= din_s1;
	 end	 
      end else begin
	 always @(posedge clk or negedge reset_n) begin
	    if (reset_n == 0) 
	      dreg <= {depth-1{1'b0}};
	    else
	      dreg <= {dreg[depth-3:0], din_s1};
	 end
      end
   endgenerate

   assign dout = dreg[depth-2];
   
endmodule 


			
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "rWMiGoTs8VipLHcQ295l12Rj5YrR9FwefxZUQ1isKPPswd3zmQFN9FaY8+/n0g+iEq7UaHtBRlrdpH7W/Mou5FJZO7Y9AzKYnK4BKq6FbOYRNNW3YOr3jFlUHCYaTr74eszEIc6FbdCnaf2xZnJ9Qwcff70et1ccd8BmeaYGjnBlRQDZSPIROBVQiiEI+W+bZ5ISTJ5MZu6XwEZpEGVnO9tbt7qDimITy6qQLO7Yk6hlbNRcafMggcCToVCLzivfqcYtXOG0F90gTqb99Sy7Zs4OuxfwSrUaX9xvAQ0ApfbTms1E3ttERbCXQzt+EWx1btuO2uX2SbqDCykoHsAXasUpcIAcRNA/1pDOXAj8zt+USmKntnz7XBatY5F+Vp7P54QjNGx5krp3QjI7zxLIlB6TXl4WA2Pr/DGvp0H+JgfvQY5WO/JGwB/k4w5MOL/R19l6cLwvWGnyqOPhDehIbpEWXmb/HgrwETdPXI0H6xQnUtiPe/jeI6UEAiDO1hHVoYYF49fELnOjjMpKe6EU4hTrrqAf5CAIwDL2lEjgMseuEAjxMw8VP0LiU7TE6/AnE9N8drVih5J19U/q5p7rHyK0DYRXpyae6pu8Bg5iOne/sY3JDR9HVXP6tewEOB8rHrUMiz1pklTkktO4OItejXPcHlgsWc0laKHJA4iZutRC61gSC3wRD+kdxLS2oEFFriE5zWHQGeFm9rv1tacR2geIgLWeGZfTknQLNXjsbySFlulCRvjJAcirsY758IgTp9eP6FYxb8LTdfdeaKo6BvWV3KSADhidb73q48tAadJBeDuLSUchrIflEmPzzApMA3oQEDnUpYGZneLriu41aWVBNsjBMsxhb5KQWK6Jfd8pPe6iQeJwyGN21jy9nD3yCGJizvca7jX5ioTtPLcvgmXliV8T/78gKe5S48BJnI4xrG67kS/zRy/XBMyrgLG7u4OXUTN4t4SpArUU10SuT/gETrFwjG9bitXI2ikWQgHu8XDtnj+Z/8uRa9vV3vZ6"
`endif