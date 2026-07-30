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





`timescale 1ns / 1ns

module altera_avalon_st_clock_crosser(
                                 in_clk,
                                 in_reset,
                                 in_ready,
                                 in_valid,
                                 in_data,
                                 out_clk,
                                 out_reset,
                                 out_ready,
                                 out_valid,
                                 out_data
                                );

  parameter  SYMBOLS_PER_BEAT    = 1;
  parameter  BITS_PER_SYMBOL     = 8;
  parameter  FORWARD_SYNC_DEPTH  = 2;
  parameter  BACKWARD_SYNC_DEPTH = 2;
  parameter  USE_OUTPUT_PIPELINE = 1;
  
  localparam  DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL;

  input                   in_clk;
  input                   in_reset;
  output                  in_ready;
  input                   in_valid;
  input  [DATA_WIDTH-1:0] in_data;

  input                   out_clk;
  input                   out_reset;
  input                   out_ready;
  output                  out_valid;
  output [DATA_WIDTH-1:0] out_data;

  (* altera_attribute = {"-name SUPPRESS_DA_RULE_INTERNAL \"D101,D102\""} *) reg [DATA_WIDTH-1:0] in_data_buffer;
  reg    [DATA_WIDTH-1:0] out_data_buffer;

  reg                     in_data_toggle;
  wire                    in_data_toggle_returned;
  wire                    out_data_toggle;
  reg                     out_data_toggle_flopped, out_data_toggle_1, out_data_toggle_flopped_n;

  wire                    take_in_data;
  wire                    out_data_taken;

  wire                    out_valid_internal;
  wire                    out_ready_internal;
  wire                    reset_merged;
  wire                    out_reset_merged;
  wire                    in_reset_merged;

  assign in_ready =  (in_data_toggle_returned ^ in_data_toggle);
  assign take_in_data = in_valid & in_ready;
  assign out_valid_internal = out_data_toggle_1 ^ out_data_toggle_flopped;
  assign out_data_taken = out_ready_internal & out_valid_internal;
 
assign reset_merged = in_reset  | out_reset;
 
   altera_reset_synchronizer
        #(
            .DEPTH      (2),
            .ASYNC_RESET(1'b1)
        )
        alt_rst_req_sync_in_rst
        (
            .clk        (in_clk),
            .reset_in   (reset_merged),
            .reset_out  (in_reset_merged)
        );
 
 altera_reset_synchronizer
        #(
            .DEPTH      (2),
            .ASYNC_RESET(1'b1)
        )
        alt_rst_req_sync_out_rst
        (
            .clk        (out_clk),
            .reset_in   (reset_merged),
            .reset_out  (out_reset_merged)
        );

  always @(posedge in_clk or posedge in_reset_merged) begin
    if (in_reset_merged) begin
      in_data_buffer <= {DATA_WIDTH{1'b0}};
      in_data_toggle <= 1'b0;
    end else begin
      if (take_in_data) begin
        in_data_toggle <= ~in_data_toggle;
        in_data_buffer <= in_data;
      end
    end 
  end 

  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_1 <= 1'b0;
    end else begin
        out_data_toggle_1 <= out_data_toggle;
    end 
  end 
  
  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_flopped <= 1'b0;
      out_data_buffer <= {DATA_WIDTH{1'b0}};
    end else begin
      out_data_buffer <= in_data_buffer;
      if (out_data_taken) begin
        out_data_toggle_flopped <= out_data_toggle_1;
      end
    end 
  end 

  always @(posedge out_clk or posedge out_reset_merged) begin
    if (out_reset_merged) begin
      out_data_toggle_flopped_n <= 1'b0;
    end else begin
        out_data_toggle_flopped_n <= ~out_data_toggle_flopped;
     end 
  end 
 
  altera_std_synchronizer_nocut #(.depth(FORWARD_SYNC_DEPTH)) in_to_out_synchronizer (
				     .clk(out_clk),
				     .reset_n(~out_reset_merged),
				     .din(in_data_toggle),
				     .dout(out_data_toggle)
				     );
  
  altera_std_synchronizer_nocut #(.depth(BACKWARD_SYNC_DEPTH)) out_to_in_synchronizer (
				     .clk(in_clk),
				     .reset_n(~in_reset_merged),
				     .din(out_data_toggle_flopped_n),
				     .dout(in_data_toggle_returned)
				     );


  generate if (USE_OUTPUT_PIPELINE == 1) begin

      altera_avalon_st_pipeline_base 
      #(
         .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
         .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT)
      ) output_stage (
         .clk(out_clk),
         .reset(out_reset_merged),
         .in_ready(out_ready_internal),
         .in_valid(out_valid_internal),
         .in_data(out_data_buffer),
         .out_ready(out_ready),
         .out_valid(out_valid),
         .out_data(out_data)
      );
 
  end else begin

      assign out_valid = out_valid_internal;
      assign out_ready_internal = out_ready;
      assign out_data = out_data_buffer;
 
  end
 
  endgenerate
 
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "+AbvKNif4wIR5q/igDfM4DePC0l9exDgETX/dMtFAe71y0qcBHKGD6iKoAonAc18tp3+n/dPcXHqqPQcDPaTTmk7OKjrFa3Pkst/YjYx7bmo6SUfrzaVl9kc3zT+f1aRSGKf5IVl/Ez3tpEbJU8K9v/gNVYnzYrHsEy/PmUF70jGx1Y0gg9VJp9ZA4cKQBHvpOeIQDAu1e1V9vqrigbcMJYaagQ8BdQNgGlG54uA9jkcDvaJINvasYg8JaK3ZKKS0VHmn7SyrcYbthL2ydwkAw+ZxblESbPihzayM3N2ympFKG5lwbv86+4EQoJr3v3AhbWhBhjJKCVNIxg6IKYzvISROWIcIy1PJfIgUGEpsxKHw4NTh5aKPgmw70/7AX0bVu/fx5jlvAti7awFnONy0i6OciLLP7MxaeOnj7dtx54Jq7vXG/ZKaKvb9MgmMJnYug+Ddo0B89+2piW6h2SfN5hnpBV/p+0LeCl0QsZfIaxVCQ1KSw1ZztUdlVcldTfvunqP7sj8j8v1X8D+Ofdm6gsexkRp2EzIqjlYc7Q9aJlBkREFFVtd0lBa2WPJ3cyBasvvH3ef9seVQqDOBIWtWaPXbbi9boNcC0A6xv/uVV0Q8yBRQuMW7DuzwKxuSjsv7fP3gaqJ5Md5scSHqMW6Rqy+RkMiK/mq0wBJ6j0gachGEmApnoOcX8kOGk5NLxjoOJs4FWcGYDcbOue4kP/iD+XJGmrSDQPcHNLXnh3gMccNX0Ivv5SzuXq0P12JK6RYRpe370D1KFadq1CmDmJFeBjbicc46JOH2ryRk9V+1+VRtcM1kILumm9qZmTd4XJAIVOEnzNmNMwFWofQvRLwuo2JLOHbQ3BDpQxFLoY8dNkql5hEVRPiNl7CuPyDcYxzN+5AWA6oFmsPGvcXcA2s5XJ9T3PVGoH+sVhRzYFXY7LsDoQApQjLzakcUiGhkTCmrBx5RK0i9lcHjE7mXgY0cDP2ZWom4Q7ICPJD9Pu8EvtaVFJaSdh1MjH6dckOcP3T"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwIl00Qc831pr4VoSieyQ+YPXNhdjU3lwfFST9+KWWVo6hyQj9XJxbz4RZTRFP7zM58CYQquLsyrIYG4z/degEUPyzQ7AfZYVDN2RhFR1W6maEYItv7kdIZGlRtvPitqUWsivVGU7jqilBOII2m3tgIPt6uOI4RFfkymJtduVbwj/1qTzbJ8eiTbjbSNKfRR9mFyLKWfJhGN5OI0xWjJL5sT0ydozme9TAKFknFFDoJhhTFKqD55AqC+/NIP3CBM0QZiWLekUo473jASW7Ab4fqpYuiP417IcEbanv2EG4LUjuCnp5v9K1LwGy7xdLwJI7NULahPUPyFOvbkT4L0nSCedfGkVqqPXeEyB3flbx85fRcvBx7W2QtGvE90/21CpDndT0gYzB+vRByQTVWqyIAfwf1SozwkdN0dB73kRV58LWCH/9WF7QEDnidQy1Y0bdkX6yj3U9ziKPYhfEm0WExuq2ISm5rNewGnor82kmXnKDPJi+njE00qABzJpSoZ5YKDGt36wE6xJHW/AhWlb+UIxchg1rbj/1B+m/i944attFJGBKSKN0jQW5s1bHe2mv7MAmNHXvlC4UEH+MzLVrcIhMgc9gy5XtsJyEqLavHXjhlSRSuNOW8f0a7JWumG4LmT4+Nza9aNG41EvTeeeyqWuT0bEsFRTnMuEhxvE4wIitKBwIkhuJ1IO9rhLLKwChxPDqzvUbib4qirbxPVWeLgDV0ylalnZeTRjKgkeSOG1DiMD1dbjiO+HqHLvhuQtxncUCd6GnJKgG6HL6lcp5Uo"
`endif