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


module cal_arch_fp_atom_inst_comp #(
   parameter IS_USED  = 0,

   parameter BASE_ADDRESS                                    = 0,

   localparam PORT_I_AVM_ADDRESS_WIDTH                        = 22,
   localparam PORT_I_AVM_WRITEDATA_WIDTH                      = 32,
   localparam PORT_O_AVM_READDATA_COMP_WIDTH                  = 32
) (
);
   timeunit 1ns;
   timeprecision 1ps;

   logic                                                      avm_clk;
   logic                                                      avm_rst_n;
   logic [PORT_I_AVM_ADDRESS_WIDTH-1:0]                       i_avm_address;
   logic                                                      i_avm_read;
   logic                                                      i_avm_write;
   logic [PORT_I_AVM_WRITEDATA_WIDTH-1:0]                     i_avm_writedata;
   logic [PORT_O_AVM_READDATA_COMP_WIDTH-1:0]                 o_avm_readdata_comp;

   tennm_compensation_block # (
      .base_address                                         (BASE_ADDRESS)
   ) comp (
      .avm_clk                                              (avm_clk),
      .avm_rst_n                                            (avm_rst_n),
      .i_avm_address                                        (i_avm_address),
      .i_avm_read                                           (i_avm_read),
      .i_avm_write                                          (i_avm_write),
      .i_avm_writedata                                      (i_avm_writedata),
      .o_avm_readdata_comp                                  (o_avm_readdata_comp)
   );

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwK2SQRYah++/I259ynJY9XVhjOy+CK1Ma59+SYMqlHtK1INZrAxUtBUzE3ufTMvZyHUK1PbUT72f8CtyUmgApT1fhNiF3ijyvm6cC/h8Z+zZYCgrQ1U9RnNcdrQgU9VNNMdePxU16l/iUo4eD82UGM7MZn8Tc0uyR0G4tdTa/fJs8W/+GH4SEAMbnqLsZMXr10/ddW97imr/1/rBFtFAYWRsndR1B9ZvIy6qXsggeMh6yqA4CVTkiObJtctW9SeQTJPgMCThttEfrilWAOcm0OuY3bAKSd1srxi824fR/JCyZasC1eJgb3bUeRIUpu+eis8RRP4binCgLvKRJBMzls+Ippwv3sd0uwbxhDbRsZzWjfYXpAD5X6hsG+u28AD207CwQXw8o4YdFdX5B9kq3JXXfAqTs1gmp9btyE1vBlc0xjuzqJzD/p7xP9q0ar1gsjFOO9+0KhyYarLabCgGFUZmI1lItFeVW+qnCQGmCKg8HHwhq5QeR0BeDK9Vg7C9u1uLA2VLcJmkIvRQcny0JUb2p5F9E7MTa69NU8MF+TUdVJB2i3QVXZg3/+dPvVGWTj0ziWs7l4dfBrBhjDDonQ97l0s6AgIIPZfof+YW/QITXZc90QqNiQ+8gQrQqi/GrcmfPxw2wh+ZlILhDFmZGtCL3RlNi8tC3MqT9B7hqhYdmFjV5akL1Cenz5rBHJOwysdE3tphfnawUxBUS6xQ+h5xEjchT+yW+uhLYoGHy49H4G5ZL94DuKY0n2YaWRKIds7283hfIakYVASidQIH196"
`endif