# (C) 2001-2025 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


set cc_mode_instances [get_registers -nowarn axi_fifo|clock_cross_gen*] 

if {[get_collection_size $cc_mode_instances] != 0} {

   set_max_delay -from [get_registers axi_fifo|clock_cross_gen.write_pointer_cc|bin2gray|gray_out[*]] -to [get_registers axi_fifo|clock_cross_gen.write_pointer_cc|cc_reg[0][*]] 100
   set_min_delay -from [get_registers axi_fifo|clock_cross_gen.write_pointer_cc|bin2gray|gray_out[*]] -to [get_registers axi_fifo|clock_cross_gen.write_pointer_cc|cc_reg[0][*]] -100
   set_net_delay -from [get_registers axi_fifo|clock_cross_gen.write_pointer_cc|bin2gray|gray_out[*]] -to [get_registers axi_fifo|clock_cross_gen.write_pointer_cc|cc_reg[0][*]] -max -get_value_from_clock_period dst_clock_period
   set_max_skew  -from [get_registers axi_fifo|clock_cross_gen.write_pointer_cc|bin2gray|gray_out[*]] -to [get_registers axi_fifo|clock_cross_gen.write_pointer_cc|cc_reg[0][*]] -get_skew_value_from_clock_period src_clock_period

   set_max_delay -from [get_registers axi_fifo|clock_cross_gen.read_pointer_cc|bin2gray|gray_out[*]] -to [get_registers axi_fifo|clock_cross_gen.read_pointer_cc|cc_reg[0][*]] 100
   set_min_delay -from [get_registers axi_fifo|clock_cross_gen.read_pointer_cc|bin2gray|gray_out[*]] -to [get_registers axi_fifo|clock_cross_gen.read_pointer_cc|cc_reg[0][*]] -100
   set_net_delay -from [get_registers axi_fifo|clock_cross_gen.read_pointer_cc|bin2gray|gray_out[*]] -to [get_registers axi_fifo|clock_cross_gen.read_pointer_cc|cc_reg[0][*]] -max -get_value_from_clock_period dst_clock_period
   set_max_skew  -from [get_registers axi_fifo|clock_cross_gen.read_pointer_cc|bin2gray|gray_out[*]] -to [get_registers axi_fifo|clock_cross_gen.read_pointer_cc|cc_reg[0][*]] -get_skew_value_from_clock_period src_clock_period
   
}

