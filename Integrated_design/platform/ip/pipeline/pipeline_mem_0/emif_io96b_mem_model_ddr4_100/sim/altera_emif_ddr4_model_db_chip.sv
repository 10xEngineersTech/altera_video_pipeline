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


///////////////////////////////////////////////////////////////////////////////
// Basic simulation model of DDR4 Data Buffer used by LRDIMM
//
///////////////////////////////////////////////////////////////////////////////
module altera_emif_ddr4_model_db_chip (
   input       BCK_t,
   input       BCK_c,
   input       BCKE,
   input       BODT,
   input       BVrefCA,
   input [3:0] BCOM,

   inout [7:0] MDQ,
   inout       MDQS0_t,
   inout       MDQS0_c,
   inout       MDQS1_t,
   inout       MDQS1_c,

   inout [7:0] DQ,
   inout       DQS0_t,
   inout       DQS0_c,
   inout       DQS1_t,
   inout       DQS1_c,

   output      ALERT_n,

   input       VDD,
   input       VSS
);

   timeunit 1ps;
   timeprecision 1ps;

   genvar i;

   generate
      for (i = 0; i < 8; i = i + 1) begin : gen_dq_delay
         altera_emif_ddrx_model_bidir_delay #(
            .DELAY                         (1.0)
         ) inst_dq_bidir_dly (
            .porta                         (MDQ[i]),
            .portb                         (DQ[i])
         );
      end
   endgenerate

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_p_0 (
      .porta                         (MDQS0_t),
      .portb                         (DQS0_t)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_n_0 (
      .porta                         (MDQS0_c),
      .portb                         (DQS0_c)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_p_1 (
      .porta                         (MDQS1_t),
      .portb                         (DQS1_t)
   );

   altera_emif_ddrx_model_bidir_delay #(
      .DELAY                         (1.0)
   ) dqs_n_1 (
      .porta                         (MDQS1_c),
      .portb                         (DQS1_c)
   );

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "k1LH1RcWqBqQ76v8cfULmmlV9sW1nnbJaS2wcLgqGwqBhLWK73DmouWbV7pbibS7IH130sZk+lXZ9U2UpRjei+a4GXqGhMMc9IMzMkgIDLbmlHj0N0nMSI9TMo4z5CKT4okwkd1gkpoJ98r//fD7kKG+O0v6X7LJGK2BQC+3s5gBj2lSsro8UaDW99uGAXd1ozPUFOiI9DO+P2Bl903Ke20T6b0d5clKKvtf117o8GnAnX7wmIiP3Eb9SA7UPklmvAfL+510pBGi3XgCeJyUDk5ozHDg2kDuPZ5SGnc5xq0Yp22Nd4KL+I+UmzfA0w7vnjzJr2lGLS7WrxRc9XodBl3BNM66ZJL7gq25JgCN49gECz9aF0jXBRAXb9PwMs8p2Awm30kN7L2PhMVdelkxaPZgu5XzLiFrtOeyHswwCvgBGA3bWFqsjpPnDTAC1Iu7genweDWXDcVGV23Y6+H0LlWOeaet7ak2F046HRifGAimpi7IHGi3scybO0PpJOD288kicrEAbxhfUUQt2IzsF2CWqBRk0/od1p7e96+oqZ7oPDzpB3atuAOodyA9zLuh+Kag/mDbVBBLeQ6QfyzvAcAEFsGpFXT/BAL4E9VNsS97x4Nt3pEvo/ZYSHb3kumx3N8N7ugs7c5I+KMLN+vTHYVb5c/1KYsIYahfxYsbeUpdZUC+ZaM24JAMw3TNOZetVGhqqqgyxNVIRsk/uVvghgGPsfdgvvEE7Tuwfs+HiT3yuk9hiJCtVFyzRA6TL9SbYJHNkH5cYHOHZ2ksQISjksnO6tesueRjm/6AOJZbixbUEeEA69FCaftoP/KR6w9ZPP6qXluaOwoivj7Txnt1AYr5sy0ZPz5QFtuI12DaoKpVbTIG8O/EAbg2T7jPw9qd8rRXCqGQgrCZlvdnj5wW8/nTY5hcPXFYxkgkCQeBL39zKm95WjjNOxxb85co8RSyjwILxLu0V96siquoSimRQy3LesYwryzb921ZD9snPMNmpcSkvfRatxJgNki/KAN2"
`endif