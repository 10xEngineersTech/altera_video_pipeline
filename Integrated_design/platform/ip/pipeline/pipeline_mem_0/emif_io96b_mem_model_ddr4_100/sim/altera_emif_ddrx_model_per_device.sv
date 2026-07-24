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
// memory model per device in a given depth expansion
//
///////////////////////////////////////////////////////////////////////////////
module altera_emif_ddrx_model_per_device
    # (

   parameter PROTOCOL_ENUM                                                = "",
   parameter MEM_FORMAT_ENUM                                              = "",
   parameter MEM_RANKS_PER_DIMM_HDL                                       = 0,
   parameter MEM_NUM_OF_DIMMS                                             = 0,
   parameter MEM_AC_PAR_EN                                                = 0,
   parameter MEM_DM_EN                                                    = 0,
   parameter MEM_CLAMSHELL_EN                                             = 0,

   parameter PORT_MEM_CKE_WIDTH                                           = 1,
   parameter PORT_MEM_BA_WIDTH                                            = 1,
   parameter PORT_MEM_BG_WIDTH                                            = 1,
   parameter PORT_MEM_C_WIDTH                                             = 1,
   parameter PORT_MEM_A_WIDTH                                             = 1,
   parameter PORT_MEM_CS_N_WIDTH                                          = 1,
   parameter PORT_MEM_RAS_N_WIDTH                                         = 1,
   parameter PORT_MEM_CAS_N_WIDTH                                         = 1,
   parameter PORT_MEM_WE_N_WIDTH                                          = 1,
   parameter PORT_MEM_ACT_N_WIDTH                                         = 1,
   parameter PORT_MEM_DQS_WIDTH                                           = 1,
   parameter PORT_MEM_DQS_N_WIDTH                                         = 1,
   parameter PORT_MEM_DQ_WIDTH                                            = 1,               
   parameter PORT_MEM_DM_WIDTH                                            = 1,
   parameter PORT_MEM_DBI_N_WIDTH                                         = 1,
   parameter PORT_MEM_RESET_N_WIDTH                                       = 1,
   parameter PORT_MEM_PAR_WIDTH                                           = 1,
   parameter PORT_MEM_ALERT_N_WIDTH                                       = 1,
   parameter PORT_MEM_RM_WIDTH                                            = 1,

   parameter MEM_TOPLEVEL_CS_N_WIDTH                                      = 0,
   parameter MEM_CHIP_ID_WIDTH                                            = 0,
   parameter MEM_ROW_ADDR_WIDTH                                           = 1,
   parameter MEM_COL_ADDR_WIDTH                                           = 1,
   parameter MEM_TRTP                                                     = 0,
   parameter MEM_TRCD                                                     = 0,
   parameter MEM_INIT_MRS0                                                = 0,
   parameter MEM_INIT_MRS1                                                = 0,
   parameter MEM_INIT_MRS2                                                = 0,
   parameter MEM_INIT_MRS3                                                = 0,
   parameter MEM_MIRROR_ADDRESSING_EN                                     = 0,
   parameter MEM_CS_N_IDX                                                 = 0,
   parameter MEM_DEPTH_IDX                                                = -1,
   parameter MEM_VERBOSE                                                  = 1,
   parameter MEM_CFG_GEN_SBE                                              = 0,
   parameter MEM_CFG_GEN_DBE                                              = 0,
   parameter MEM_CLK_FREQUENCY                                            = 0,
   parameter MEM_MICRON_AUTOMATA                                          = 0,

   parameter DIAG_SIM_MEMORY_PRELOAD                                      = 0,
   parameter DIAG_SIM_MEMORY_PRELOAD_MEM_FILE                             = ""
  )  (

   input  logic                        [PORT_MEM_A_WIDTH-1:0]            mem_a,
   input  logic                        [PORT_MEM_BA_WIDTH-1:0]           mem_ba,
   input  logic                        [PORT_MEM_BG_WIDTH-1:0]           mem_bg,
   input  logic                        [PORT_MEM_C_WIDTH-1:0]            mem_c,
   input  logic                                                          mem_ck,
   input  logic                                                          mem_ck_n,
   input  logic                        [PORT_MEM_CKE_WIDTH - 1:0]        mem_cke,
   input  logic                        [PORT_MEM_CS_N_WIDTH - 1:0]       mem_cs_n,
   input  logic                        [PORT_MEM_RAS_N_WIDTH - 1:0]      mem_ras_n,
   input  logic                        [PORT_MEM_CAS_N_WIDTH - 1:0]      mem_cas_n,
   input  logic                        [PORT_MEM_WE_N_WIDTH - 1:0]       mem_we_n,
   input  logic                        [PORT_MEM_ACT_N_WIDTH - 1:0]      mem_act_n,
   input  logic                        [PORT_MEM_RESET_N_WIDTH - 1:0]    mem_reset_n,
   input  logic                        [PORT_MEM_DM_WIDTH - 1:0]         mem_dm,
   inout  tri                          [PORT_MEM_DBI_N_WIDTH - 1:0]      mem_dbi_n,
   inout  tri                          [PORT_MEM_DQ_WIDTH - 1:0]         mem_dq,
   inout  tri                          [PORT_MEM_DQS_WIDTH - 1:0]        mem_dqs,
   inout  tri                          [PORT_MEM_DQS_N_WIDTH - 1:0]      mem_dqs_n,
   output logic                        [PORT_MEM_ALERT_N_WIDTH-1:0]      mem_alert_n,
   input  logic                        [PORT_MEM_PAR_WIDTH-1:0]          mem_par,
   input  logic                                                          mem_odt,
   input  logic                        [PORT_MEM_RM_WIDTH-1:0]           mem_rm,

   input  logic                        [PORT_MEM_CS_N_WIDTH - 1:0]       toplevel_cs_n,
   input  logic                        [PORT_MEM_RAS_N_WIDTH - 1:0]      toplevel_ras_n,
   input  logic                        [PORT_MEM_CAS_N_WIDTH - 1:0]      toplevel_cas_n,
   input  logic                        [PORT_MEM_WE_N_WIDTH - 1:0]       toplevel_we_n,
   input  logic                        [PORT_MEM_ACT_N_WIDTH - 1:0]      toplevel_act_n,
   input  logic                        [PORT_MEM_A_WIDTH-1:0]            toplevel_a,
   input  logic                        [PORT_MEM_BA_WIDTH-1:0]           toplevel_ba,
   input  logic                        [PORT_MEM_BG_WIDTH-1:0]           toplevel_bg,
   input  logic                        [PORT_MEM_C_WIDTH-1:0]            toplevel_c
  );
   timeunit 1ps;
   timeprecision 1ps;

   localparam MEM_NUMBER_OF_RANKS = (MEM_FORMAT_ENUM == "MEM_FORMAT_DISCRETE" ? (MEM_CLAMSHELL_EN ? PORT_MEM_CS_N_WIDTH >> 1 : PORT_MEM_CS_N_WIDTH) : MEM_RANKS_PER_DIMM_HDL);
   localparam MEM_CS_N_WIDTH = (MEM_CLAMSHELL_EN ? PORT_MEM_CS_N_WIDTH : MEM_NUMBER_OF_RANKS);

   reg                                 [PORT_MEM_A_WIDTH-1:0]            a;
   reg                                 [PORT_MEM_BA_WIDTH-1:0]           ba;
   reg                                 [PORT_MEM_BG_WIDTH-1:0]           bg;
   reg                                 [PORT_MEM_C_WIDTH-1:0]            c;
   reg                                                                   ck;
   reg                                                                   ck_n;
   reg                                                                   cke;
   reg                                 [MEM_CS_N_WIDTH-1:0]              cs_n;
   reg                                                                   ras_n;
   reg                                                                   cas_n;
   reg                                                                   we_n;
   reg                                                                   act_n;
   reg                                 [PORT_MEM_RESET_N_WIDTH-1:0]      reset_n;
   reg                                                                   odt;
   reg                                 [MEM_CS_N_WIDTH-1:0]              alert_n;
   reg                                 [PORT_MEM_PAR_WIDTH-1:0]          par;
   reg                                                                   single_bit_alert_n;
   reg                                 [PORT_MEM_DM_WIDTH-1:0]           dm;

   wire                                [PORT_MEM_DQ_WIDTH-1:0]           dq;
   wire                                [PORT_MEM_DQS_WIDTH-1:0]          dqs;
   wire                                [PORT_MEM_DQS_N_WIDTH-1:0]        dqs_n;
   wire                                [PORT_MEM_DBI_N_WIDTH-1:0]        dbi_n;

   reg                                 [7:0]                             ddr3_lrdimm_qcs_n;

   reg                                                                   bcom_ck;
   reg                                                                   bcom_ck_n;
   reg                                 [3:0]                             bcom_bus;
   reg                                                                   bcom_odt;
   reg                                                                   bcom_cke;
   wire                                                                  bcom_vref;

   generate
      always @(*) begin
         if (MEM_DM_EN != 0) begin
            if ((PROTOCOL_ENUM != "PROTOCOL_DDR4") && (PORT_MEM_DM_WIDTH != PORT_MEM_DQS_WIDTH) ||
                (PROTOCOL_ENUM == "PROTOCOL_DDR4") && (PORT_MEM_DBI_N_WIDTH != PORT_MEM_DQS_WIDTH)) begin
               $display("Memory model DM width must equal DQS width.");
               $finish;
            end
         end
         else begin
            dm <= #10 {PORT_MEM_DM_WIDTH{1'b0}};
         end
      end


   endgenerate


   generate
      reg my_parity;
      reg [4:0] err_out_shiftreg = 5'b11111;
      if (MEM_AC_PAR_EN) begin
         always @(posedge mem_ck) begin
            if (mem_cke) begin
               my_parity <= ^{mem_a, mem_ba, mem_ras_n, mem_cas_n, mem_we_n};
               err_out_shiftreg[4:1] <= err_out_shiftreg[3:0];
               if (cs_n != {PORT_MEM_CS_N_WIDTH{1'b1}}) begin
                  err_out_shiftreg[1:0] <= {2{my_parity == mem_par}};
               end else begin
                  err_out_shiftreg[0] <= 1'b1;
               end
            end
         end
      end
      assign single_bit_alert_n = (PROTOCOL_ENUM == "PROTOCOL_DDR4" ? &alert_n : err_out_shiftreg[4]);
   endgenerate


   generate
      if ((MEM_FORMAT_ENUM == "MEM_FORMAT_UDIMM") || (MEM_FORMAT_ENUM == "MEM_FORMAT_DISCRETE") || (MEM_FORMAT_ENUM == "MEM_FORMAT_SODIMM")) begin
         always @(*) begin
            a <= mem_a;
            ba <= mem_ba;
            bg <= mem_bg;
            c <= mem_c;
            ck <= mem_ck;
            ck_n <= mem_ck_n;
            cke <= mem_cke;
            cs_n <= mem_cs_n;
            ras_n <= mem_ras_n;
            cas_n <= mem_cas_n;
            we_n <= mem_we_n;
            act_n <= mem_act_n;
            reset_n <= mem_reset_n;
            odt <= mem_odt;
            par <= mem_par;
            mem_alert_n <= single_bit_alert_n;
         end
      end
   endgenerate


   generate
      genvar i;

      if ((PROTOCOL_ENUM == "PROTOCOL_DDR4") && (MEM_FORMAT_ENUM == "MEM_FORMAT_RDIMM" || MEM_FORMAT_ENUM == "MEM_FORMAT_LRDIMM")) begin : gen_ddr4_rcd_chip

         always @(*) begin
            ras_n <= a[16];
            cas_n <= a[15];
            we_n  <= a[14];
         end

         altera_emif_ddr4_model_rcd_chip #(
            .ADDRESS_MIRRORING                                (MEM_MIRROR_ADDRESSING_EN),
            .PORT_MEM_CS_N_WIDTH                              (PORT_MEM_CS_N_WIDTH),
            .PORT_MEM_A_WIDTH                                 (PORT_MEM_A_WIDTH),
            .PORT_MEM_C_WIDTH                                 (PORT_MEM_C_WIDTH)
         ) ddr4_rcd_chip (
            .DCKE       (mem_cke),
            .DODT       (mem_odt),
            .DCS_n      (mem_cs_n),
            .DC         (mem_c),

            .DA         (mem_a),
            .DBA        (mem_ba),
            .DBG        (mem_bg),
            .DACT_n     (mem_act_n),

            .CK_t       (mem_ck),
            .CK_c       (mem_ck_n),

            .DRST_n     (mem_reset_n),

            .DPAR       (mem_par),

            .ERROR_IN_n (single_bit_alert_n),

            .BODT       (bcom_odt),
            .BCKE       (bcom_cke),
            .BCOM       (bcom_bus),
            .BCK_t      (bcom_ck),
            .BCK_c      (bcom_ck_n),
            .BVrefCA    (bcom_vref),

            .QACKE      (cke),
            .QBCKE      (),
            .QAODT      (odt),
            .QBODT      (),
            .QACS_n     (cs_n),
            .QBCS_n     (),
            .QAC        (c),
            .QBC        (),

            .QAA        (a),
            .QBA        (),
            .QABA       (ba),
            .QABG       (bg),
            .QBBA       (),
            .QBBG       (),
            .QAACT_n    (act_n),
            .QBACT_n    (),

            .Y_t        (ck),
            .Y_c        (ck_n),

            .QRST_n     (reset_n),

            .QAPAR      (par),
            .QBPAR      (),

            .ALERT_n    (mem_alert_n),

            .SDA        (),
            .SA         (),
            .SCL        (),
            .BFUNC      (),
            .VDDSPD     (),

            .VDD        (1'b1),
            .VSS        (1'b0),
            .AVDD       (1'b1),
            .PVDD       (1'b1),
            .PVSS       (1'b0)
         );
      end

      if ((PROTOCOL_ENUM == "PROTOCOL_DDR3") && (MEM_FORMAT_ENUM == "MEM_FORMAT_RDIMM")) begin : gen_ddr3_rdimm_chip
         always @(*) begin
            reset_n <= mem_reset_n;
         end

         altera_emif_ddr3_model_rdimm_chip #(
            .MEM_DEPTH_IDX                                    (MEM_DEPTH_IDX),
            .PORT_MEM_CS_N_WIDTH                              (PORT_MEM_CS_N_WIDTH)
         ) rdimm_chip_i (
            .DCKE       (mem_cke),
            .DODT       (mem_odt),
            .DCS_n      (mem_cs_n),

            .DA         (mem_a),
            .DBA        (mem_ba),
            .DRAS_n     (mem_ras_n),
            .DCAS_n     (mem_cas_n),
            .DWE_n      (mem_we_n),

            .CK         (mem_ck),
            .CK_n       (mem_ck_n),

            .DRESET_n   (mem_reset_n),

            .PAR_IN     (mem_par),

            .QCKE       (cke),
            .QODT       (odt),
            .QCS_n      (cs_n),

            .QA         (a),
            .QBA        (ba),
            .QRAS_n     (ras_n),
            .QCAS_n     (cas_n),
            .QWE_n      (we_n),

            .Y          (ck),
            .Y_n        (ck_n),

            .ERROUT_n   (mem_alert_n)
         );
      end

      if ((PROTOCOL_ENUM == "PROTOCOL_DDR4") && (MEM_FORMAT_ENUM == "MEM_FORMAT_LRDIMM")) begin : gen_ddr4_lrdimm_buffer
         for (i = 0; i < PORT_MEM_DQS_WIDTH/2; i = i + 1) begin : gen_ddr4_db_chip
            altera_emif_ddr4_model_db_chip ddr4_db_chip (
               .BCK_t   (bcom_ck),
               .BCK_c   (bcom_ck_n),
               .BCKE    (bcom_cke),
               .BODT    (bcom_odt),
               .BVrefCA (bcom_vref),
               .BCOM    (bcom_bus),

               .MDQ     (       dq[i*8+7:i*8]),
               .MDQS0_t (      dqs[i*2]),
               .MDQS0_c (    dqs_n[i*2]),
               .MDQS1_t (      dqs[i*2+1]),
               .MDQS1_c (    dqs_n[i*2+1]),

               .DQ      (   mem_dq[i*8+7:i*8]),
               .DQS0_t  (  mem_dqs[i*2]),
               .DQS0_c  (mem_dqs_n[i*2]),
               .DQS1_t  (  mem_dqs[i*2+1]),
               .DQS1_c  (mem_dqs_n[i*2+1]),

               .ALERT_n (),

               .VDD     (1'b1),
               .VSS     (1'b0)
            );
         end
      end

      if ((PROTOCOL_ENUM == "PROTOCOL_DDR3") && (MEM_FORMAT_ENUM == "MEM_FORMAT_LRDIMM")) begin : gen_ddr3_lrdimm_chip
         always @(*) begin
            cs_n <= ddr3_lrdimm_qcs_n;
         end

         altera_emif_ddr3_model_lrdimm_chip #(
            .MEM_DEPTH_IDX                                    (MEM_DEPTH_IDX),
            .MEM_WIDTH_IDX                                    (0),
            .PORT_MEM_CS_N_WIDTH                              (PORT_MEM_CS_N_WIDTH),
            .PORT_MEM_DQS_WIDTH                               (PORT_MEM_DQS_WIDTH),
            .PORT_MEM_DQS_N_WIDTH                             (PORT_MEM_DQS_N_WIDTH),
            .PORT_MEM_DQ_WIDTH                                (PORT_MEM_DQ_WIDTH),
            .PORT_MEM_RM_WIDTH                                (PORT_MEM_RM_WIDTH),
            .MEM_CLK_FREQUENCY                                (MEM_CLK_FREQUENCY)
         ) lrdimm_chip_i (
            .DQ                                (mem_dq),
            .DQS_p                             (mem_dqs),
            .DQS_n                             (mem_dqs_n),
            .DA                                (mem_a),
            .DBA                               (mem_ba),
            .DRAS_n                            (mem_ras_n),
            .DCAS_n                            (mem_cas_n),
            .DWE_n                             (mem_we_n),
            .DCS_n                             ({{(8-PORT_MEM_CS_N_WIDTH-PORT_MEM_RM_WIDTH){1'b1}}, mem_rm, mem_cs_n}),
            .DCKE                              (mem_cke),
            .DODT                              (mem_odt),
            .CLK_p                             (mem_ck),
            .CLK_n                             (mem_ck_n),
            .PAR_IN                            (mem_par),
            .ERR_n                             (mem_alert_n),

            .MDQ                               (dq),
            .MDQS_p                            (dqs),
            .MDQS_n                            (dqs_n),
            .Y_p                               (ck),
            .Y_n                               (ck_n),

            .QAA                               (a),
            .QABA                              (ba),
            .QARAS_n                           (ras_n),
            .QACAS_n                           (cas_n),
            .QAWE_n                            (we_n),
            .QACS_n                            (ddr3_lrdimm_qcs_n[3:0]),
            .QACKE                             (cke),
            .QAODT                             (odt),

            .QBA                               (),
            .QBBA                              (),
            .QBRAS_n                           (),
            .QBCAS_n                           (),
            .QBWE_n                            (),
            .QBCS_n                            (ddr3_lrdimm_qcs_n[7:4]),
            .QBCKE                             (),
            .QBODT                             (),

            .RESET_n                           (mem_reset_n),
            .QRST_n                            (reset_n)
         );
      end
   endgenerate


   generate
      if (MEM_FORMAT_ENUM == "MEM_FORMAT_LRDIMM") begin : gen_lrdimm_rank
         genvar rank;
         for (rank = 0; rank < MEM_NUMBER_OF_RANKS; rank = rank + 1)  begin : rank_gen_lrdimm
            altera_emif_ddrx_model_rank #(

               .PROTOCOL_ENUM                                 (PROTOCOL_ENUM),
               .PORT_MEM_BA_WIDTH                             (PORT_MEM_BA_WIDTH),
               .PORT_MEM_BG_WIDTH                             (PORT_MEM_BG_WIDTH),
               .PORT_MEM_C_WIDTH                              (PORT_MEM_C_WIDTH),
               .PORT_MEM_A_WIDTH                              (PORT_MEM_A_WIDTH),
               .MEM_TOPLEVEL_CS_N_WIDTH                       (MEM_TOPLEVEL_CS_N_WIDTH),
               .MEM_CHIP_ID_WIDTH                             (MEM_CHIP_ID_WIDTH),
               .MEM_ROW_ADDR_WIDTH                            (MEM_ROW_ADDR_WIDTH),
               .MEM_COL_ADDR_WIDTH                            (MEM_COL_ADDR_WIDTH),
               .PORT_MEM_DQS_WIDTH                            (PORT_MEM_DQS_WIDTH),
               .PORT_MEM_DQ_WIDTH                             (PORT_MEM_DQ_WIDTH),
               .PORT_MEM_DM_WIDTH                             (PORT_MEM_DM_WIDTH),
               .PORT_MEM_DBI_N_WIDTH                          (PORT_MEM_DBI_N_WIDTH),

               .MEM_DM_EN                                     (MEM_DM_EN),
               .MEM_TRTP                                      (MEM_TRTP),
               .MEM_TRCD                                      (MEM_TRCD),
               .MEM_INIT_MRS0                                 (MEM_INIT_MRS0),
               .MEM_INIT_MRS1                                 (MEM_INIT_MRS1),
               .MEM_INIT_MRS2                                 (MEM_INIT_MRS2),
               .MEM_INIT_MRS3                                 (MEM_INIT_MRS3),
               .MEM_MIRROR_ADDRESSING                         (MEM_MIRROR_ADDRESSING_EN & (rank & 1'b1)),
               .MEM_CS_N_IDX                                  (MEM_CS_N_IDX + rank),
               .MEM_DEPTH_IDX                                 (MEM_DEPTH_IDX),
               .MEM_RANK_IDX                                  (rank),
               .MEM_VERBOSE                                   (MEM_VERBOSE),
               .MEM_CFG_GEN_SBE                               (MEM_CFG_GEN_SBE),
               .MEM_CFG_GEN_DBE                               (MEM_CFG_GEN_DBE),
               .MEM_MICRON_AUTOMATA                           (MEM_MICRON_AUTOMATA),

               .DIAG_SIM_MEMORY_PRELOAD                       (DIAG_SIM_MEMORY_PRELOAD),
               .DIAG_SIM_MEMORY_PRELOAD_MEM_FILE              (DIAG_SIM_MEMORY_PRELOAD_MEM_FILE)

            ) rank_inst (

               .mem_a               (a),
               .mem_ba              (ba),
               .mem_bg              (bg),
               .mem_c               (c),
               .mem_ck              (ck),
               .mem_ck_n            (ck_n),
               .mem_cke             (cke),
               .mem_ras_n           (ras_n),
               .mem_cas_n           (cas_n),
               .mem_we_n            (we_n),
               .mem_act_n           (act_n),
               .mem_reset_n         (reset_n),
               .mem_dm              (mem_dm),
               .mem_dbi_n           (mem_dbi_n),
               .mem_dq              (dq),
               .mem_dqs             (dqs),
               .mem_dqs_n           (dqs_n),
               .mem_odt             (odt),
               .mem_cs_n            (cs_n[rank]),
               .mem_alert_n         (alert_n[rank]),
               .mem_par             (par),

               .toplevel_cs_n       (toplevel_cs_n[rank]),
               .toplevel_ras_n      (toplevel_ras_n),
               .toplevel_cas_n      (toplevel_cas_n),
               .toplevel_we_n       (toplevel_we_n),
               .toplevel_act_n      (toplevel_act_n),
               .toplevel_a          (toplevel_a),
               .toplevel_ba         (toplevel_ba),
               .toplevel_bg         (toplevel_bg),
               .toplevel_c          (toplevel_c)

            );
         end
      end
      else if (MEM_CLAMSHELL_EN) begin : gen_clamshell_mem_rank
         
         localparam MEM_BOT_DQS_WIDTH =   (PORT_MEM_DQS_WIDTH     >> 1);
         localparam MEM_BOT_DM_WIDTH =    (PORT_MEM_DM_WIDTH    > 1) ? (PORT_MEM_DM_WIDTH      >> 1) : PORT_MEM_DM_WIDTH;
         localparam MEM_BOT_DBI_N_WIDTH = (PORT_MEM_DBI_N_WIDTH > 1) ? (PORT_MEM_DBI_N_WIDTH   >> 1) : PORT_MEM_DBI_N_WIDTH;

         localparam MEM_TOP_DQS_WIDTH =   PORT_MEM_DQS_WIDTH    - MEM_BOT_DQS_WIDTH;
         localparam MEM_TOP_DM_WIDTH =    (PORT_MEM_DM_WIDTH    > 1) ? (PORT_MEM_DM_WIDTH     - MEM_BOT_DM_WIDTH)    : PORT_MEM_DM_WIDTH;
         localparam MEM_TOP_DBI_N_WIDTH = (PORT_MEM_DBI_N_WIDTH > 1) ? (PORT_MEM_DBI_N_WIDTH  - MEM_BOT_DBI_N_WIDTH) : PORT_MEM_DBI_N_WIDTH;
         
         localparam MEM_TOP_BOT_SPLIT_FOR_DM  = (PORT_MEM_DM_WIDTH    > 1) ? MEM_TOP_DM_WIDTH    : 0;
         localparam MEM_TOP_BOT_SPLIT_FOR_DBI = (PORT_MEM_DBI_N_WIDTH > 1) ? MEM_TOP_DBI_N_WIDTH : 0;

         localparam MEM_BOT_DQ_WIDTH =    (PORT_MEM_DQ_WIDTH/PORT_MEM_DQS_WIDTH) * MEM_BOT_DQS_WIDTH;
         localparam MEM_TOP_DQ_WIDTH =    PORT_MEM_DQ_WIDTH - MEM_BOT_DQ_WIDTH;
         
         genvar rank;
         for (rank = 0; rank < MEM_NUMBER_OF_RANKS; rank = rank + 1)  begin : rank_gen
            altera_emif_ddrx_model_rank #(
               .PROTOCOL_ENUM                                 (PROTOCOL_ENUM),
               .PORT_MEM_BA_WIDTH                             (PORT_MEM_BA_WIDTH),
               .PORT_MEM_BG_WIDTH                             (PORT_MEM_BG_WIDTH),
               .PORT_MEM_C_WIDTH                              (PORT_MEM_C_WIDTH),
               .PORT_MEM_A_WIDTH                              (PORT_MEM_A_WIDTH),
               .MEM_CHIP_ID_WIDTH                             (MEM_CHIP_ID_WIDTH),
               .MEM_ROW_ADDR_WIDTH                            (MEM_ROW_ADDR_WIDTH),
               .MEM_COL_ADDR_WIDTH                            (MEM_COL_ADDR_WIDTH),
               .PORT_MEM_DQS_WIDTH                            (MEM_TOP_DQS_WIDTH),
               .PORT_MEM_DQ_WIDTH                             (MEM_TOP_DQ_WIDTH),
               .PORT_MEM_DM_WIDTH                             (MEM_TOP_DM_WIDTH),
               .PORT_MEM_DBI_N_WIDTH                          (MEM_TOP_DBI_N_WIDTH),

               .MEM_DM_EN                                     (MEM_DM_EN),
               .MEM_TRTP                                      (MEM_TRTP),
               .MEM_TRCD                                      (MEM_TRCD),
               .MEM_INIT_MRS0                                 (MEM_INIT_MRS0),
               .MEM_INIT_MRS1                                 (MEM_INIT_MRS1),
               .MEM_INIT_MRS2                                 (MEM_INIT_MRS2),
               .MEM_INIT_MRS3                                 (MEM_INIT_MRS3),
               .MEM_MIRROR_ADDRESSING                         (0),
               .MEM_DEPTH_IDX                                 (MEM_DEPTH_IDX),
               .MEM_RANK_IDX                                  (rank),
               .MEM_VERBOSE                                   (MEM_VERBOSE),
               .MEM_CFG_GEN_SBE                               (MEM_CFG_GEN_SBE),
               .MEM_CFG_GEN_DBE                               (MEM_CFG_GEN_DBE),
               .MEM_MICRON_AUTOMATA                           (MEM_MICRON_AUTOMATA)

            ) rank_top_inst (
               .mem_a         (a),
               .mem_ba        (ba),
               .mem_bg        (bg),
               .mem_c         (c),
               .mem_ck        (ck),
               .mem_ck_n      (ck_n),
               .mem_cke       (cke),
               .mem_ras_n     (ras_n),
               .mem_cas_n     (cas_n),
               .mem_we_n      (we_n),
               .mem_act_n     (act_n),
               .mem_reset_n   (reset_n),
               .mem_dm        (mem_dm[MEM_TOP_DM_WIDTH-1:0]),
               .mem_dbi_n     (mem_dbi_n[MEM_TOP_DBI_N_WIDTH-1:0]),
               .mem_dq        (mem_dq[MEM_TOP_DQ_WIDTH-1:0]),
               .mem_dqs       (mem_dqs[MEM_TOP_DQS_WIDTH-1:0]),
               .mem_dqs_n     (mem_dqs_n[MEM_TOP_DQS_WIDTH-1:0]),
               .mem_odt       (odt),
               .mem_cs_n      (cs_n[rank]),
               .mem_alert_n   (alert_n[rank]),
               .mem_par       (par)
            );

            altera_emif_ddrx_model_rank #(
               .PROTOCOL_ENUM                                 (PROTOCOL_ENUM),
               .PORT_MEM_BA_WIDTH                             (PORT_MEM_BA_WIDTH),
               .PORT_MEM_BG_WIDTH                             (PORT_MEM_BG_WIDTH),
               .PORT_MEM_C_WIDTH                              (PORT_MEM_C_WIDTH),
               .PORT_MEM_A_WIDTH                              (PORT_MEM_A_WIDTH),
               .MEM_CHIP_ID_WIDTH                             (MEM_CHIP_ID_WIDTH),
               .MEM_ROW_ADDR_WIDTH                            (MEM_ROW_ADDR_WIDTH),
               .MEM_COL_ADDR_WIDTH                            (MEM_COL_ADDR_WIDTH),
               .PORT_MEM_DQS_WIDTH                            (MEM_BOT_DQS_WIDTH),
               .PORT_MEM_DQ_WIDTH                             (MEM_BOT_DQ_WIDTH),
               .PORT_MEM_DM_WIDTH                             (MEM_BOT_DM_WIDTH),
               .PORT_MEM_DBI_N_WIDTH                          (MEM_BOT_DBI_N_WIDTH),

               .MEM_DM_EN                                     (MEM_DM_EN),
               .MEM_TRTP                                      (MEM_TRTP),
               .MEM_TRCD                                      (MEM_TRCD),
               .MEM_INIT_MRS0                                 (MEM_INIT_MRS0),
               .MEM_INIT_MRS1                                 (MEM_INIT_MRS1),
               .MEM_INIT_MRS2                                 (MEM_INIT_MRS2),
               .MEM_INIT_MRS3                                 (MEM_INIT_MRS3),
               .MEM_MIRROR_ADDRESSING                         (1),
               .MEM_DEPTH_IDX                                 (MEM_DEPTH_IDX),
               .MEM_RANK_IDX                                  (rank),
               .MEM_VERBOSE                                   (MEM_VERBOSE),
               .MEM_CFG_GEN_SBE                               (MEM_CFG_GEN_SBE),
               .MEM_CFG_GEN_DBE                               (MEM_CFG_GEN_DBE),
               .MEM_MICRON_AUTOMATA                           (MEM_MICRON_AUTOMATA)

            ) rank_bot_inst (
               .mem_a         (a),
               .mem_ba        (ba),
               .mem_bg        (bg),
               .mem_c         (c),
               .mem_ck        (ck),
               .mem_ck_n      (ck_n),
               .mem_cke       (cke),
               .mem_ras_n     (ras_n),
               .mem_cas_n     (cas_n),
               .mem_we_n      (we_n),
               .mem_act_n     (act_n),
               .mem_reset_n   (reset_n),
               .mem_dm        (mem_dm[PORT_MEM_DM_WIDTH-1:MEM_TOP_BOT_SPLIT_FOR_DM]),
               .mem_dbi_n     (mem_dbi_n[PORT_MEM_DBI_N_WIDTH-1:MEM_TOP_BOT_SPLIT_FOR_DBI]),
               .mem_dq        (mem_dq[PORT_MEM_DQ_WIDTH-1:MEM_TOP_DQ_WIDTH]),
               .mem_dqs       (mem_dqs[PORT_MEM_DQS_WIDTH-1:MEM_TOP_DQS_WIDTH]),
               .mem_dqs_n     (mem_dqs_n[PORT_MEM_DQS_N_WIDTH-1:MEM_TOP_DQS_WIDTH]),
               .mem_odt       (odt),
               .mem_cs_n      (cs_n[rank+MEM_NUMBER_OF_RANKS]),
               .mem_alert_n   (alert_n[rank+MEM_NUMBER_OF_RANKS]),
               .mem_par       (par)
            );
         end
      end
      else begin : gen_mem_rank
         genvar rank;
         for (rank = 0; rank < MEM_NUMBER_OF_RANKS; rank = rank + 1)  begin : rank_gen
            altera_emif_ddrx_model_rank #(

               .PROTOCOL_ENUM                                 (PROTOCOL_ENUM),
               .PORT_MEM_BA_WIDTH                             (PORT_MEM_BA_WIDTH),
               .PORT_MEM_BG_WIDTH                             (PORT_MEM_BG_WIDTH),
               .PORT_MEM_C_WIDTH                              (PORT_MEM_C_WIDTH),
               .PORT_MEM_A_WIDTH                              (PORT_MEM_A_WIDTH),
               .MEM_TOPLEVEL_CS_N_WIDTH                       (MEM_TOPLEVEL_CS_N_WIDTH),
               .MEM_CHIP_ID_WIDTH                             (MEM_CHIP_ID_WIDTH),
               .MEM_ROW_ADDR_WIDTH                            (MEM_ROW_ADDR_WIDTH),
               .MEM_COL_ADDR_WIDTH                            (MEM_COL_ADDR_WIDTH),
               .PORT_MEM_DQS_WIDTH                            (PORT_MEM_DQS_WIDTH),
               .PORT_MEM_DQ_WIDTH                             (PORT_MEM_DQ_WIDTH),
               .PORT_MEM_DM_WIDTH                             (PORT_MEM_DM_WIDTH),
               .PORT_MEM_DBI_N_WIDTH                          (PORT_MEM_DBI_N_WIDTH),

               .MEM_DM_EN                                     (MEM_DM_EN),
               .MEM_TRTP                                      (MEM_TRTP),
               .MEM_TRCD                                      (MEM_TRCD),
               .MEM_INIT_MRS0                                 (MEM_INIT_MRS0),
               .MEM_INIT_MRS1                                 (MEM_INIT_MRS1),
               .MEM_INIT_MRS2                                 (MEM_INIT_MRS2),
               .MEM_INIT_MRS3                                 (MEM_INIT_MRS3),
               .MEM_MIRROR_ADDRESSING                         (MEM_MIRROR_ADDRESSING_EN & (rank & 1'b1)),
               .MEM_CS_N_IDX                                  (MEM_CS_N_IDX + rank),
               .MEM_DEPTH_IDX                                 (MEM_DEPTH_IDX),
               .MEM_RANK_IDX                                  (rank),
               .MEM_VERBOSE                                   (MEM_VERBOSE),
               .MEM_CFG_GEN_SBE                               (MEM_CFG_GEN_SBE),
               .MEM_CFG_GEN_DBE                               (MEM_CFG_GEN_DBE),
               .MEM_MICRON_AUTOMATA                           (MEM_MICRON_AUTOMATA),

               .DIAG_SIM_MEMORY_PRELOAD                       (DIAG_SIM_MEMORY_PRELOAD),
               .DIAG_SIM_MEMORY_PRELOAD_MEM_FILE              (DIAG_SIM_MEMORY_PRELOAD_MEM_FILE)

            ) rank_inst (

               .mem_a               (a),
               .mem_ba              (ba),
               .mem_bg              (bg),
               .mem_c               (c),
               .mem_ck              (ck),
               .mem_ck_n            (ck_n),
               .mem_cke             (cke),
               .mem_ras_n           (ras_n),
               .mem_cas_n           (cas_n),
               .mem_we_n            (we_n),
               .mem_act_n           (act_n),
               .mem_reset_n         (reset_n),
               .mem_dm              (mem_dm),
               .mem_dbi_n           (mem_dbi_n),
               .mem_dq              (mem_dq),
               .mem_dqs             (mem_dqs),
               .mem_dqs_n           (mem_dqs_n),
               .mem_odt             (odt),
               .mem_cs_n            (cs_n[rank]),
               .mem_alert_n         (alert_n[rank]),
               .mem_par             (par),

               .toplevel_cs_n       (toplevel_cs_n[rank]),
               .toplevel_ras_n      (toplevel_ras_n),
               .toplevel_cas_n      (toplevel_cas_n),
               .toplevel_we_n       (toplevel_we_n),
               .toplevel_act_n      (toplevel_act_n),
               .toplevel_a          (toplevel_a),
               .toplevel_ba         (toplevel_ba),
               .toplevel_bg         (toplevel_bg),
               .toplevel_c          (toplevel_c)

            );
         end
      end
  endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "k1LH1RcWqBqQ76v8cfULmmlV9sW1nnbJaS2wcLgqGwqBhLWK73DmouWbV7pbibS7IH130sZk+lXZ9U2UpRjei+a4GXqGhMMc9IMzMkgIDLbmlHj0N0nMSI9TMo4z5CKT4okwkd1gkpoJ98r//fD7kKG+O0v6X7LJGK2BQC+3s5gBj2lSsro8UaDW99uGAXd1ozPUFOiI9DO+P2Bl903Ke20T6b0d5clKKvtf117o8GmgjgXmamM4SkQMczc8upoc5EnGDCtlRtlZZJC6amFVhWZ2yP/JbjVfXTj3la3C607ExlAWFny6tP92420SE7lha20dHEbMrTkdvgQ2yDtQ5CtI4PZ9/Bw0KJTPyZQjRqyfeGLYp00TMlDph6GaPFvYQ/jrRxr1878dR41NuptatHAbhfzFC7fuA3rorUsKhSaWpuoIvsaPPcK6CApV1oHRw2O6t6yRGBkW+2tYecuCsEr5g+ZyVuS8EjwK1lau/ywD6b5giA/MDIxhJt0FDWRB+ErZvugTWCNBPQ7qRGrtfQlp1Q4JqXT5NOpLtGPc2SPEWS+TnWvBJR5sFB42bUjJgQK2S06UtaoFh0KBmMq/Y5FHJzjCNIXkxri6u3o9DuipiCkB+NsM00TbvHgNcpoci0ahkFCrEvnmquyzV0WIVNtv+XfqRTk2kZ3LrxLVphuzGWyBa15sp6P2IScXwYVrawpUhOy3vy6lQNP3mvcRWy1LN2vSem4gbtiwpuDyPrkmrSLhFMF7IRE87/R4whA/ZjDu+RQBz8Uf+CSUOV4JbH7Sx4YrHgzgJSaZLJTtKrF0+SViSTTLquvSt796mc28KwH6ifW7OVmrjDfHElGP4vH4jdGN+Py0gvd867iPOQdY5l6c1TMBIm56LqVJtItSuptxPZfqoltHkJKrCGMiE26VIFYDs1zBQrLoHloGAFR40fBI9V5oDcduu2YZYBEE02Zkii0u0JyjiRJ5/8YfP3R+M1be9u5A/DzBDZmtqevUuiedYdQwO6rbwtZA8lLE"
`endif