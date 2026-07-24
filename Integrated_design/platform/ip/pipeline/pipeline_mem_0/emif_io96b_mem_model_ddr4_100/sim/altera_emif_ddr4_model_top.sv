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


module altera_emif_ddr4_model_top #(
   parameter MEM_FORMAT_ENUM                    = "",
   parameter MEM_NUM_DIMMS                      = 0,
   parameter MEM_RANKS_PER_DIMM_HDL             = 0,
   parameter MEM_AC_MIRROR_EN                   = 0,
   parameter MEM_CLAMSHELL_EN                   = 0,
   parameter MEM_ROW_ADDR_WIDTH                 = 0,
   parameter MEM_COL_ADDR_WIDTH                 = 0,
   parameter MEM_CK_T_WIDTH                     = 0,
   parameter MEM_CK_C_WIDTH                     = 0,
   parameter MEM_CKE_WIDTH                      = 0,
   parameter MEM_ODT_WIDTH                      = 0,
   parameter MEM_CS_N_WIDTH                     = 0,
   parameter MEM_CHIP_ID_WIDTH                  = 0,
   parameter MEM_RESET_N_WIDTH                  = 0,
   parameter MEM_ACT_N_WIDTH                    = 0,
   parameter MEM_PAR_WIDTH                      = 0,
   parameter MEM_ALERT_N_WIDTH                  = 0,
   parameter MEM_A_WIDTH                        = 0,
   parameter MEM_BANK_ADDR_WIDTH                = 0,
   parameter MEM_BANK_GROUP_ADDR_WIDTH          = 0,
   parameter MEM_DQ_WIDTH                       = 0,
   parameter MEM_DQS_T_WIDTH                    = 0,
   parameter MEM_DQS_C_WIDTH                    = 0,
   parameter MEM_DBI_N_WIDTH                    = 0,

   // ======= Actual port width ==========
   //TODO: override the port width for all bus that can be 0-wide to 1
   localparam LOCAL_MEM_DBI_N_WIDTH             = MEM_DBI_N_WIDTH == 0 ? 1 : MEM_DBI_N_WIDTH,
   localparam LOCAL_MEM_CHIP_ID_WIDTH           = MEM_CHIP_ID_WIDTH == 0 ? 1 : MEM_CHIP_ID_WIDTH

) (
   input logic  [MEM_CK_T_WIDTH            -1 : 0] mem_ck_t_0,
   input logic  [MEM_CK_C_WIDTH            -1 : 0] mem_ck_c_0,
   input logic  [MEM_CKE_WIDTH             -1 : 0] mem_cke_0,
   input logic  [MEM_ODT_WIDTH             -1 : 0] mem_odt_0,
   input logic  [MEM_RESET_N_WIDTH         -1 : 0] mem_reset_n_0,
   input logic  [MEM_CS_N_WIDTH            -1 : 0] mem_cs_n_0,
   input logic  [LOCAL_MEM_CHIP_ID_WIDTH   -1 : 0] mem_c_0,
   input logic  [MEM_ACT_N_WIDTH           -1 : 0] mem_act_n_0,
   input logic  [MEM_A_WIDTH               -1 : 0] mem_a_0,
   input logic  [MEM_BANK_ADDR_WIDTH       -1 : 0] mem_ba_0,
   input logic  [MEM_BANK_GROUP_ADDR_WIDTH -1 : 0] mem_bg_0,
   input logic  [MEM_PAR_WIDTH             -1 : 0] mem_par_0,
   inout tri    [MEM_DQ_WIDTH              -1 : 0] mem_dq_0,
   inout tri    [MEM_DQS_T_WIDTH           -1 : 0] mem_dqs_t_0,
   inout tri    [MEM_DQS_C_WIDTH           -1 : 0] mem_dqs_c_0,
   inout tri    [LOCAL_MEM_DBI_N_WIDTH     -1 : 0] mem_dbi_n_0,
   output logic [MEM_ALERT_N_WIDTH         -1 : 0] mem_alert_n_0,
   output logic                                    oct_rzqin_0
);
   timeunit 1ns;
   timeprecision 1ps;

   assign oct_rzqin_0 = 'h0;

   altera_emif_ddrx_model # (
      .PORT_MEM_CK_WIDTH          (MEM_CK_T_WIDTH),
      .PORT_MEM_CK_N_WIDTH        (MEM_CK_C_WIDTH),
      .PORT_MEM_CKE_WIDTH         (MEM_CKE_WIDTH),
      .PORT_MEM_A_WIDTH           (MEM_A_WIDTH),
      .PORT_MEM_BA_WIDTH          (MEM_BANK_ADDR_WIDTH),
      .PORT_MEM_BG_WIDTH          (MEM_BANK_GROUP_ADDR_WIDTH),
      .PORT_MEM_C_WIDTH           (LOCAL_MEM_CHIP_ID_WIDTH),
      .PORT_MEM_CS_N_WIDTH        (MEM_CS_N_WIDTH),
      .PORT_MEM_ODT_WIDTH         (MEM_ODT_WIDTH),
      .PORT_MEM_RESET_N_WIDTH     (MEM_RESET_N_WIDTH),
      .PORT_MEM_ACT_N_WIDTH       (MEM_ACT_N_WIDTH),
      .PORT_MEM_PAR_WIDTH         (MEM_PAR_WIDTH),
      .PORT_MEM_DQ_WIDTH          (MEM_DQ_WIDTH),
      .PORT_MEM_DBI_N_WIDTH       (LOCAL_MEM_DBI_N_WIDTH),
      .PORT_MEM_DQS_WIDTH         (MEM_DQS_T_WIDTH),
      .PORT_MEM_DQS_N_WIDTH       (MEM_DQS_C_WIDTH),
      .MEM_CHIP_ID_WIDTH          (MEM_CHIP_ID_WIDTH),
      .MEM_RANKS_PER_DIMM_HDL     (MEM_RANKS_PER_DIMM_HDL),
      .MEM_NUM_OF_DIMMS           (MEM_NUM_DIMMS),
      .PROTOCOL_ENUM              ("PROTOCOL_DDR4"),
      .MEM_ROW_ADDR_WIDTH         (MEM_ROW_ADDR_WIDTH),
      .MEM_COL_ADDR_WIDTH         (MEM_COL_ADDR_WIDTH),
      .MEM_FORMAT_ENUM            (MEM_FORMAT_ENUM),
      .MEM_INIT_MRS0                           (0),   
      .MEM_INIT_MRS1                           (0),   
      .MEM_INIT_MRS2                           (0),   
      .MEM_INIT_MRS3                           (0),   
      .MEM_AC_PAR_EN                           (0),   
      .MEM_CLAMSHELL_EN                        (MEM_CLAMSHELL_EN),
      .MEM_TRTP                                (0),   
      .MEM_TRCD                                (0),   
      .MEM_DISCRETE_MIRROR_ADDRESSING_EN       (MEM_AC_MIRROR_EN),   
      .MEM_MIRROR_ADDRESSING_EN                (MEM_AC_MIRROR_EN),   
      .MEM_CFG_GEN_SBE                         (0),   
      .MEM_CFG_GEN_DBE                         (0),   
      .MEM_MICRON_AUTOMATA                     (0),   
      .DIAG_SIM_MEMORY_PRELOAD                 (0),   
      .DIAG_SIM_MEMORY_PRELOAD_PRI_MEM_FILE    (""),  
      .DIAG_SIM_MEMORY_PRELOAD_SEC_MEM_FILE    ("")   
   ) altera_emif_ddr4_model_inst (
      .mem_ck            (mem_ck_t_0),
      .mem_ck_n          (mem_ck_c_0),
      .mem_cke           (mem_cke_0),
      .mem_odt           (mem_odt_0),
      .mem_reset_n       (mem_reset_n_0),
      .mem_cs_n          (mem_cs_n_0),
      .mem_c             (mem_c_0),
      .mem_act_n         (mem_act_n_0),
      .mem_a             (mem_a_0),
      .mem_ba            (mem_ba_0),
      .mem_bg            (mem_bg_0),
      .mem_par           (mem_par_0),
      .mem_dq            (mem_dq_0),
      .mem_dqs           (mem_dqs_t_0),
      .mem_dqs_n         (mem_dqs_c_0),
      .mem_dbi_n         (mem_dbi_n_0), 
      .mem_alert_n       (mem_alert_n_0)
   );

   
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "k1LH1RcWqBqQ76v8cfULmmlV9sW1nnbJaS2wcLgqGwqBhLWK73DmouWbV7pbibS7IH130sZk+lXZ9U2UpRjei+a4GXqGhMMc9IMzMkgIDLbmlHj0N0nMSI9TMo4z5CKT4okwkd1gkpoJ98r//fD7kKG+O0v6X7LJGK2BQC+3s5gBj2lSsro8UaDW99uGAXd1ozPUFOiI9DO+P2Bl903Ke20T6b0d5clKKvtf117o8GkelurE38aoQNNbu5gvkZRoEOUlZDJy6a0hvqVeOKQj2EBZZupiyBMeA3wNMiwebytcZ6mrrJPhmlu1NdZoFSJp4fCoDIMTyhJ2Ch/ZcPE5I6VpPz1XsrUtS6gSGmrYxBjcYBoEe+LleKmhfNwW4RCpFfB4H2CRszIFpp16Vsa46Ybk9XDYzJMYqSg9l06MBWeINbFPvHqFY0tBJxqL9HWZveeY8v4+VGUe0JTATvbuypk2WJCLEJ3+RmdWTIAUegVzMdqmGLNd55moFo0xrt/Z2bz/vNP/yaO0QxZUOdlc2+w+rRf3CZX1YjWzdLJHEonYHzJbco6JVMIZC0viRVLEDt7b/sciiE9ZDeiiIQaxOyJ3wUYcSOI9VIFkJCIqc5BHh0fm0SRQkDhQGcUln4tjX/eXBc06bdAOdHMIhDBKtlWL17yt3SGCIdb94Kryb0aqkDYtP8SYNHy0IW/X4Rs5/ejWrNtWfdrBVaEVZcg4WC+s1bLwAZbeoTADROVh+iVrIQmzt/n9HoHfrfOL6N8MsGVeOW8biLGa/aPe90oQ9jvEBjbYjeUlCreHj3F6hCecOrFQzmBJAH03ebgif8rRsBXlBZz3woKIpuLh2tkATtVgPFzQYGz2yK4lFaNPv410WQ054Vfhrh0gMQ5fmo90vLGAGvgculB7ho/SWXMHFilhTFeLBm/CNU32+WhsI/KZ9oHeBIePCUjiM9bWDGtpR/c3ql8OvmkK6gaWR1VvRQ5CLjC5VfQQyWnCTRdzPvpfZNYJCOMQS/vV/Pv0KlEt"
`endif