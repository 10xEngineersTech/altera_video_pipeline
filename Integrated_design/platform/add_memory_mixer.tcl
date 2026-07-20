# add_memory_mixer.tcl
# =============================================================================
# Upgrade modify/.../platform/pipeline.qsys:
#   Add the datapath AFTER the packaged VVP pipeline IP (intel_vvp_pipeline2_0),
#   replicating the proven reference topology (reference/.../add_mixer.tcl +
#   its GUI-added vfb/emif/mem), but adapted to the modify design's
#   "flat / export-and-stitch-in-RTL" philosophy (no internal mm_bridge; each
#   new control agent is exported for rtl/controller.v).
#
# Target datapath (this script builds the [ADD] parts):
#
#   packaged_IP.m_axis_video_out (scaler, LITE)              <- exported already
#      -> intel_vvp_protocol_conv_1 (lite->full  #2)   [ADD]  in/out exported
#      -> intel_vvp_vfb_0.axi4s_vid_in  (frame WRITE) [ADD]  in exported
#           vfb write/read hosts <-> emif_0 <-> mem_0  [ADD]  INTERNAL Av-MM
#      -> intel_vvp_vfb_0.axi4s_vid_out (frame READ)         out exported
#      -> intel_vvp_mixer_0.axi4s_vid_1_in (layer 1)  [ADD]  in exported
#   intel_vvp_tpg_2 (solid colour)                    [ADD]
#      -> intel_vvp_mixer_0.axi4s_vid_0_in (backgrnd, INTERNAL connection)
#      -> intel_vvp_mixer_0.axi4s_vid_out               [ADD] out exported (dump)
#
# Already present (input stage, left untouched):
#   intel_vvp_protocol_conv_0  = lite->full #1  (image.png source path)
#   intel_vvp_tpg_1            = TPG #1          (pipeline input source)
#
# NOTE: The memory-side clock (vfb mem_clock, emif s0_axi4 clock) is driven by
#   the SAME clock_in.out_clk as the video side (matches the reference). The
#   DDR PHY reference clock emif_0.ref_clk is EXPORTED (emif_ref_clk) and must
#   be driven by a ~200 MHz source from rtl/top.v (as in the reference).
#
# Run (no --quartus-project: attaching to the DNI/device service hangs headless;
#   the device is set explicitly below instead -- see reference serv_req_info.txt):
#   cd Integrated_design/platform
#   qsys-script --script=add_memory_mixer.tcl
# =============================================================================
package require -exact qsys 25.1

load_system pipeline.qsys
puts "== system loaded, retargeting device =="

# Match quartus/system.qsf (identical device in reference and modify)
set_project_property DEVICE_FAMILY "Agilex 5"
set_project_property DEVICE        A5ED065BB32AE6SR0
puts "== device set, adding instances =="

# --- Idempotent: remove previously added instances on re-run ---
foreach inst {intel_vvp_protocol_conv_1 intel_vvp_tpg_2 intel_vvp_vfb_0 \
              intel_vvp_mixer_0 emif_0 mem_0} {
    if {[lsearch -exact [get_instances] $inst] >= 0} {
        remove_instance $inst
    }
}

# =============================================================================
# 1. Lite->Full converter #2  (packaged-IP scaler LITE out  ->  FULL for VFB)
#    Cloned from the existing modify intel_vvp_protocol_conv_0 (INPUT=EXTERNAL
#    = lite, OUTPUT=INTERNAL = full). RUNTIME_CONTROL=0 -> no control agent.
# =============================================================================
add_instance intel_vvp_protocol_conv_1 intel_vvp_protocol_conv 24.6.0
set_instance_parameter_value intel_vvp_protocol_conv_1 BPS                    8
set_instance_parameter_value intel_vvp_protocol_conv_1 NUMBER_OF_COLOR_PLANES 3
set_instance_parameter_value intel_vvp_protocol_conv_1 PIXELS_IN_PARALLEL     1
set_instance_parameter_value intel_vvp_protocol_conv_1 INPUT_MODE             EXTERNAL
set_instance_parameter_value intel_vvp_protocol_conv_1 OUTPUT_MODE            INTERNAL
set_instance_parameter_value intel_vvp_protocol_conv_1 COLOR_SPACE            RGB
set_instance_parameter_value intel_vvp_protocol_conv_1 RUNTIME_CONTROL        0
set_instance_parameter_value intel_vvp_protocol_conv_1 SEPARATE_SLAVE_CLOCK   0

# =============================================================================
# 2. TPG #2  -  mixer background source (solid/uniform colour, runtime-set)
#    Config = reference add_mixer.tcl background TPG.
# =============================================================================
add_instance intel_vvp_tpg_2 intel_vvp_tpg 24.5.1
set_instance_parameter_value intel_vvp_tpg_2 BPS                    8
set_instance_parameter_value intel_vvp_tpg_2 PIXELS_IN_PARALLEL     1
set_instance_parameter_value intel_vvp_tpg_2 RUNTIME_CONTROL        1
set_instance_parameter_value intel_vvp_tpg_2 EXTERNAL_MODE          0
set_instance_parameter_value intel_vvp_tpg_2 NUM_CORES              1
set_instance_parameter_value intel_vvp_tpg_2 CORE_PATTERN_0         1
set_instance_parameter_value intel_vvp_tpg_2 CORE_COL_SPACE_0       0
set_instance_parameter_value intel_vvp_tpg_2 OUTPUT_FORMAT          4.4.4

# =============================================================================
# 3. Video Frame Buffer  -  single instance does WRITE and READ to memory
#    Params copied verbatim from reference pipeline_intel_vvp_vfb_0.ip.
#    CLOCKS_ARE_SEPARATE=1 -> separate main_clock (video) and mem_clock.
#    MAX_WIDTH/HEIGHT (128x96) generously cover the modify 24x36 scaler output;
#    runtime dimensions are programmed by controller.v (RUNTIME_CONTROL=1).
# =============================================================================
add_instance intel_vvp_vfb_0 intel_vvp_vfb 24.5.1
set_instance_parameter_value intel_vvp_vfb_0 BPS                    8
set_instance_parameter_value intel_vvp_vfb_0 NUMBER_OF_COLOR_PLANES 3
set_instance_parameter_value intel_vvp_vfb_0 PIXELS_IN_PARALLEL     1
set_instance_parameter_value intel_vvp_vfb_0 MAX_WIDTH              128
set_instance_parameter_value intel_vvp_vfb_0 MAX_HEIGHT             96
set_instance_parameter_value intel_vvp_vfb_0 CLOCKS_ARE_SEPARATE    1
set_instance_parameter_value intel_vvp_vfb_0 P_AV_MM_DATA_WIDTH     256
set_instance_parameter_value intel_vvp_vfb_0 P_AV_MM_ADDR_WIDTH     32
set_instance_parameter_value intel_vvp_vfb_0 WRITE_BURST_TARGET     8
set_instance_parameter_value intel_vvp_vfb_0 READ_BURST_TARGET      8
set_instance_parameter_value intel_vvp_vfb_0 FRAME_DROP_ENABLE      1
set_instance_parameter_value intel_vvp_vfb_0 FRAME_REPEAT_ENABLE    1
set_instance_parameter_value intel_vvp_vfb_0 DROP_BROKEN_FRAMES     1
set_instance_parameter_value intel_vvp_vfb_0 MEM_BUFF_BASE_ADDR     0
set_instance_parameter_value intel_vvp_vfb_0 MEM_BUFF_STRIDE        49152
set_instance_parameter_value intel_vvp_vfb_0 MEM_BUFF_LINE_STRIDE   512
set_instance_parameter_value intel_vvp_vfb_0 MAX_CONTROL_PACKETS    0
set_instance_parameter_value intel_vvp_vfb_0 DROP_RPT_AUX_PKTS_WITH_FRAMES 1
set_instance_parameter_value intel_vvp_vfb_0 WRITE_FIFO_DEPTH       64
set_instance_parameter_value intel_vvp_vfb_0 READ_FIFO_DEPTH        64
set_instance_parameter_value intel_vvp_vfb_0 PACKING                PERFECT
set_instance_parameter_value intel_vvp_vfb_0 RUNTIME_CONTROL        1
set_instance_parameter_value intel_vvp_vfb_0 SEPARATE_SLAVE_CLOCK   0
set_instance_parameter_value intel_vvp_vfb_0 EXTERNAL_MODE          0

# =============================================================================
# 4. Mixer  -  2 layers: background (TPG #2) + layer 1 (VFB read frame)
# =============================================================================
add_instance intel_vvp_mixer_0 intel_vvp_mixer 24.5.1
set_instance_parameter_value intel_vvp_mixer_0 BPS                    8
set_instance_parameter_value intel_vvp_mixer_0 NUMBER_OF_COLOR_PLANES 3
set_instance_parameter_value intel_vvp_mixer_0 PIXELS_IN_PARALLEL     1
set_instance_parameter_value intel_vvp_mixer_0 RUNTIME_CONTROL        1
set_instance_parameter_value intel_vvp_mixer_0 EXTERNAL_MODE          0
set_instance_parameter_value intel_vvp_mixer_0 NUM_LAYERS             2
set_instance_parameter_value intel_vvp_mixer_0 BLENDING_MODE_1        0

# =============================================================================
# 5. EMIF (DDR4) + DDR4 memory model  -  the VFB backing store.
#    ----------------------------------------------------------------------
#    VERIFY: emif_io96b_ddr4comp is a board/preset-heavy IP. Only the primary
#    knob (DDR4-3200W speed bin, matching reference pipeline_emif_0.ip) is set
#    here; operating freq (800 MHz) and PHY refclk (200 MHz) are left on their
#    AUTOSET defaults, and any AXI/DQ width difference vs the 256-bit VFB host
#    is bridged by the auto-inserted interconnect. Explicit freq/refclk values
#    are intentionally NOT forced (they are AUTOSET-derived; forcing them can
#    raise "cannot set derived parameter" in qsys-script). If Quartus reports
#    a mismatch, open emif_0 in the Platform Designer GUI, apply the same
#    dev-kit DDR4 preset the reference uses, and re-save.
# =============================================================================
add_instance emif_0 emif_io96b_ddr4comp
set_instance_parameter_value emif_0 MEM_SPEEDBIN 3200W
# Match reference exactly: pin the PHY mainband access mode explicitly (ref has
# AUTOSET_EN=false; both derive ASYNC, but pin it so nothing floats).
set_instance_parameter_value emif_0 PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN false
set_instance_parameter_value emif_0 PHY_MAINBAND_ACCESS_MODE ASYNC

# Abstract DDR4 memory model (simulation backing store; no board pins)
add_instance mem_0 emif_io96b_mem_model_ddr4
# --- DDR4 geometry/timing to match emif_0 (from reference pipeline_mem_0.ip) ---
set_instance_parameter_value mem_0 CTRL_DMDBI_EN                      0
set_instance_parameter_value mem_0 MEM_ACT_N_WIDTH                    1
set_instance_parameter_value mem_0 MEM_AC_MIRROR_EN                   false
set_instance_parameter_value mem_0 MEM_AC_PARITY_LATENCY_MODE         0.0
set_instance_parameter_value mem_0 MEM_ALERT_N_WIDTH                  1
set_instance_parameter_value mem_0 MEM_AL_CYC                         0.0
set_instance_parameter_value mem_0 MEM_A_WIDTH                        17
set_instance_parameter_value mem_0 MEM_BANK_ADDR_WIDTH                2
set_instance_parameter_value mem_0 MEM_BANK_GROUP_ADDR_WIDTH          1
set_instance_parameter_value mem_0 MEM_CHIP_ID_WIDTH                  0
set_instance_parameter_value mem_0 MEM_CKE_WIDTH                      1
set_instance_parameter_value mem_0 MEM_CK_C_WIDTH                     1
set_instance_parameter_value mem_0 MEM_CK_T_WIDTH                     1
set_instance_parameter_value mem_0 MEM_CLAMSHELL_EN                   false
set_instance_parameter_value mem_0 MEM_CL_CYC                         20.0
set_instance_parameter_value mem_0 MEM_COL_ADDR_WIDTH                 10
set_instance_parameter_value mem_0 MEM_CS_N_WIDTH                     1
set_instance_parameter_value mem_0 MEM_CWL_CYC                        16.0
set_instance_parameter_value mem_0 MEM_DBI_N_WIDTH                    0
set_instance_parameter_value mem_0 MEM_DQS_C_WIDTH                    4
set_instance_parameter_value mem_0 MEM_DQS_T_WIDTH                    4
set_instance_parameter_value mem_0 MEM_DQ_WIDTH                       32
set_instance_parameter_value mem_0 MEM_FINE_GRANULARITY_REFRESH_MODE  1.0
set_instance_parameter_value mem_0 MEM_FORMAT_ENUM                    MEM_FORMAT_DISCRETE
set_instance_parameter_value mem_0 MEM_NUM_DIMMS                      0
set_instance_parameter_value mem_0 MEM_ODT_WIDTH                      1
set_instance_parameter_value mem_0 MEM_PAGE_SIZE                      2048.0
set_instance_parameter_value mem_0 MEM_PAR_WIDTH                      1
set_instance_parameter_value mem_0 MEM_RANKS_PER_DIMM_HDL             0
set_instance_parameter_value mem_0 MEM_RCD_PARITY_LATENCY_CONTROL_WORD 0.0
set_instance_parameter_value mem_0 MEM_RCD_PARITY_LATENCY_CYC         0.0
set_instance_parameter_value mem_0 MEM_RD_PREAMBLE_MODE               1.0
set_instance_parameter_value mem_0 MEM_RESET_N_WIDTH                  1
set_instance_parameter_value mem_0 MEM_ROW_ADDR_WIDTH                 16
set_instance_parameter_value mem_0 MEM_SPD137_RCD_CA_DRV              0.0
set_instance_parameter_value mem_0 MEM_SPD138_RCD_CK_DRV              0.0
set_instance_parameter_value mem_0 MEM_TCCD_DLR_NS                    0.0
set_instance_parameter_value mem_0 MEM_TCCD_L_NS                      5.0
set_instance_parameter_value mem_0 MEM_TCCD_S_NS                      2.5
set_instance_parameter_value mem_0 MEM_TCKESR_CYC                     9.0
set_instance_parameter_value mem_0 MEM_TCKE_NS                        5.0
set_instance_parameter_value mem_0 MEM_TCKSRE_NS                      10.0
set_instance_parameter_value mem_0 MEM_TCKSRX_NS                      10.0
set_instance_parameter_value mem_0 MEM_TCK_CL_CWL_MAX_NS              0.682
set_instance_parameter_value mem_0 MEM_TCK_CL_CWL_MIN_NS              0.625
set_instance_parameter_value mem_0 MEM_TCPDED_NS                      2.5
set_instance_parameter_value mem_0 MEM_TDQSCK_MAX_MIN_NS              0.16
set_instance_parameter_value mem_0 MEM_TDQSCK_NS                      0.0
set_instance_parameter_value mem_0 MEM_TFAW_DLR_NS                    0.0
set_instance_parameter_value mem_0 MEM_TFAW_NS                        30.0
set_instance_parameter_value mem_0 MEM_TMOD_NS                        15.0
set_instance_parameter_value mem_0 MEM_TMPRR_NS                       0.625
set_instance_parameter_value mem_0 MEM_TMRD_NS                        5.0
set_instance_parameter_value mem_0 MEM_TRAS_MAX_NS                    70200.0
set_instance_parameter_value mem_0 MEM_TRAS_MIN_NS                    32.0
set_instance_parameter_value mem_0 MEM_TRAS_NS                        32.0
set_instance_parameter_value mem_0 MEM_TRCD_NS                        12.5
set_instance_parameter_value mem_0 MEM_TRC_NS                         44.5
set_instance_parameter_value mem_0 MEM_TREFI_NS                       7800.0
set_instance_parameter_value mem_0 MEM_TRFC_DLR_NS                    0.0
set_instance_parameter_value mem_0 MEM_TRFC_NS                        350.0
set_instance_parameter_value mem_0 MEM_TRP_NS                         12.5
set_instance_parameter_value mem_0 MEM_TRRD_DLR_NS                    0.0
set_instance_parameter_value mem_0 MEM_TRRD_L_NS                      6.4
set_instance_parameter_value mem_0 MEM_TRRD_S_NS                      5.3
set_instance_parameter_value mem_0 MEM_TRTP_NS                        7.5
set_instance_parameter_value mem_0 MEM_TWR_CRC_DM_NS                  3.75
set_instance_parameter_value mem_0 MEM_TWR_NS                         15.0
set_instance_parameter_value mem_0 MEM_TWTR_L_CRC_DM_NS               3.75
set_instance_parameter_value mem_0 MEM_TWTR_L_NS                      7.5
set_instance_parameter_value mem_0 MEM_TWTR_S_CRC_DM_NS               3.75
set_instance_parameter_value mem_0 MEM_TWTR_S_NS                      2.5
set_instance_parameter_value mem_0 MEM_TXP_NS                         6.0
set_instance_parameter_value mem_0 MEM_TXS_DLL_NS                     640.0
set_instance_parameter_value mem_0 MEM_TXS_NS                         360.0
set_instance_parameter_value mem_0 MEM_TZQCS_NS                       80.0
set_instance_parameter_value mem_0 MEM_TZQINIT_CYC                    1024.0
set_instance_parameter_value mem_0 MEM_TZQOPER_CYC                    512.0
set_instance_parameter_value mem_0 MEM_WR_CRC_EN                      0.0
set_instance_parameter_value mem_0 MEM_WR_PREAMBLE_MODE               1.0

# =============================================================================
# 6. Clocks  -  single fabric clock (clock_in.out_clk) feeds video + mem side,
#    exactly as in the reference.
# =============================================================================
foreach {inst port} {
    intel_vvp_protocol_conv_1 main_clock
    intel_vvp_tpg_2           main_clock
    intel_vvp_mixer_0         main_clock
    intel_vvp_vfb_0           main_clock
    intel_vvp_vfb_0           mem_clock
    emif_0                    s0_axi4_clock_in
    emif_0                    s0_axi4lite_clock
} {
    add_connection clock_in.out_clk ${inst}.${port}
}

# =============================================================================
# 7. Resets  -  reset_in.out_reset (Qsys adapts polarity to emif *_n ports).
# =============================================================================
foreach {inst port} {
    intel_vvp_protocol_conv_1 main_reset
    intel_vvp_tpg_2           main_reset
    intel_vvp_mixer_0         main_reset
    intel_vvp_vfb_0           main_reset
    intel_vvp_vfb_0           mem_reset
    emif_0                    core_init_n
    emif_0                    s0_axi4lite_reset_n
} {
    add_connection reset_in.out_reset ${inst}.${port}
}

# =============================================================================
# 8. Memory path (INTERNAL) - vfb hosts <-> emif s0_axi4 <-> mem_0 conduits.
#    Qsys auto-inserts the Avalon-MM->AXI4 interconnect / burst adapters.
# =============================================================================
add_connection intel_vvp_vfb_0.av_mm_mem_write_host emif_0.s0_axi4
set_connection_parameter_value \
    intel_vvp_vfb_0.av_mm_mem_write_host/emif_0.s0_axi4 baseAddress "0x0000"
add_connection intel_vvp_vfb_0.av_mm_mem_read_host  emif_0.s0_axi4
set_connection_parameter_value \
    intel_vvp_vfb_0.av_mm_mem_read_host/emif_0.s0_axi4  baseAddress "0x0000"

add_connection mem_0.mem_0        emif_0.mem_0
add_connection mem_0.mem_ck_0     emif_0.mem_ck_0
add_connection mem_0.mem_reset_n  emif_0.mem_reset_n
add_connection mem_0.oct_0        emif_0.oct_0

# =============================================================================
# 9. Internal video connection: TPG #2 -> mixer background (layer 0)
# =============================================================================
add_connection intel_vvp_tpg_2.axi4s_vid_out intel_vvp_mixer_0.axi4s_vid_0_in

# =============================================================================
# 10. Exported boundaries (stitched by rtl/top.v; driven by rtl/controller.v)
#     Video streams  (mirrors reference exports + the new conv_1):
# =============================================================================
proc export_stream {ifname internal dir} {
    add_interface $ifname axi4stream $dir
    set_interface_property $ifname EXPORT_OF $internal
}
export_stream conv1_axi4s_vid_in   intel_vvp_protocol_conv_1.axi4s_vid_in  slave
export_stream conv1_axi4s_vid_out  intel_vvp_protocol_conv_1.axi4s_vid_out master
export_stream vfb0_axi4s_vid_in    intel_vvp_vfb_0.axi4s_vid_in            slave
export_stream vfb0_axi4s_vid_out   intel_vvp_vfb_0.axi4s_vid_out           master
export_stream mixer0_axi4s_vid_1_in intel_vvp_mixer_0.axi4s_vid_1_in       slave
export_stream mixer0_axi4s_vid_out intel_vvp_mixer_0.axi4s_vid_out         master

#     Control agents (per-IP export, as conv_0/tpg_1 already are):
proc export_ctrl {ifname internal} {
    add_interface $ifname avalon slave
    set_interface_property $ifname EXPORT_OF $internal
}
# conv_1 (lite->full) has an av_mm_control_agent even with RUNTIME_CONTROL=0 (like
# the existing conv_0 "PC1"): it must be told the frame dimensions so it emits
# correct Full-protocol control packets for the VFB. Export it for controller.v.
export_ctrl conv1_av_mm_control_agent  intel_vvp_protocol_conv_1.av_mm_control_agent
export_ctrl vfb0_av_mm_control_agent   intel_vvp_vfb_0.av_mm_control_agent
export_ctrl mixer0_av_mm_control_agent intel_vvp_mixer_0.av_mm_control_agent
export_ctrl tpg2_av_mm_control_agent   intel_vvp_tpg_2.av_mm_control_agent

#     DDR PHY reference clock (drive ~200 MHz from top.v, as in reference):
add_interface  emif_ref_clk clock sink
set_interface_property emif_ref_clk EXPORT_OF emif_0.ref_clk

# =============================================================================
puts "== connections + exports done, syncing sysinfo =="
sync_sysinfo_parameters
puts "== saving system =="
save_system pipeline.qsys
puts "== done -- next: qsys-generate, then diff synth/pipeline.v vs reference =="
