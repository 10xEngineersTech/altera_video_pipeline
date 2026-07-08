source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_clock_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_onchip_memory2_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_reset_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_mm_bridge_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/common/modelsim_files.tcl]

namespace eval pipeline {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_2::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_clock_in::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_tpg_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_dil_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_onchip_memory2_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_csc_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_reset_in::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_mm_bridge_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_clipper_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_vfb_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_crs_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_1::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_scaler_0::get_design_libraries]]
    dict set libraries altera_merlin_master_translator_193  1
    dict set libraries altera_merlin_slave_translator_191   1
    dict set libraries altera_merlin_master_agent_1940      1
    dict set libraries altera_merlin_slave_agent_1930       1
    dict set libraries altera_avalon_sc_fifo_1932           1
    dict set libraries altera_merlin_router_1921            1
    dict set libraries altera_avalon_st_pipeline_stage_1930 1
    dict set libraries altera_merlin_burst_adapter_1940     1
    dict set libraries altera_merlin_demultiplexer_1921     1
    dict set libraries altera_merlin_multiplexer_1922       1
    dict set libraries altera_merlin_width_adapter_1961     1
    dict set libraries altera_mm_interconnect_1920          1
    dict set libraries altera_merlin_traffic_limiter_1921   1
    dict set libraries altera_reset_controller_1924         1
    dict set libraries pipeline                             1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [pipeline_intel_vvp_protocol_conv_2::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_clock_in::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_tpg_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_dil_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_onchip_memory2_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_onchip_memory2_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_csc_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_reset_in::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_mm_bridge_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mm_bridge_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_clipper_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_vfb_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_protocol_conv_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_crs_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_protocol_conv_1::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_scaler_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [pipeline_intel_vvp_protocol_conv_2::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/"]]
    set design_files [dict merge $design_files [pipeline_clock_in::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_clock_in/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_tpg_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_dil_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_onchip_memory2_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_onchip_memory2_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_csc_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_reset_in::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_reset_in/sim/"]]
    set design_files [dict merge $design_files [pipeline_mm_bridge_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mm_bridge_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_clipper_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_vfb_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_protocol_conv_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_crs_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_protocol_conv_1::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_scaler_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/"]]
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    set design_files [concat $design_files [pipeline_intel_vvp_protocol_conv_2::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_clock_in::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_tpg_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_dil_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_onchip_memory2_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_onchip_memory2_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_csc_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_reset_in::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_mm_bridge_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mm_bridge_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_clipper_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_vfb_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_protocol_conv_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_crs_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_protocol_conv_1::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_scaler_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_translator_193/sim/pipeline_altera_merlin_master_translator_193_lgcew2q.sv"]\"  -work altera_merlin_master_translator_193"                  
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/pipeline_altera_merlin_slave_translator_191_xg7rzxi.sv"]\"  -work altera_merlin_slave_translator_191"                     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_agent_1940/sim/pipeline_altera_merlin_master_agent_1940_pqs4u4y.sv"]\"  -work altera_merlin_master_agent_1940"                              
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/pipeline_altera_merlin_slave_agent_1930_jxauz3i.sv"]\"  -work altera_merlin_slave_agent_1930"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/altera_merlin_burst_uncompressor.sv"]\"  -work altera_merlin_slave_agent_1930"                                                
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_1932/sim/pipeline_altera_avalon_sc_fifo_1932_onpcouq.v"]\"  -work altera_avalon_sc_fifo_1932"                                                  
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_gbik46i.sv"]\"  -work altera_merlin_router_1921"                                                
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_lky73xq.sv"]\"  -work altera_merlin_router_1921"                                                
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/pipeline_altera_avalon_st_pipeline_stage_1930_oiupeiq.sv"]\"  -work altera_avalon_st_pipeline_stage_1930"               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/altera_avalon_st_pipeline_base.v"]\"  -work altera_avalon_st_pipeline_stage_1930"                                       
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/pipeline_altera_merlin_burst_adapter_altera_avalon_st_pipeline_stage_1940_3ux5izy.v"]\"  -work altera_merlin_burst_adapter_1940"
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/pipeline_altera_merlin_burst_adapter_1940_nwcdjmq.sv"]\"  -work altera_merlin_burst_adapter_1940"                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_uncmpr.sv"]\"  -work altera_merlin_burst_adapter_1940"                                          
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_13_1.sv"]\"  -work altera_merlin_burst_adapter_1940"                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_burst_adapter_new.sv"]\"  -work altera_merlin_burst_adapter_1940"                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_incr_burst_converter.sv"]\"  -work altera_merlin_burst_adapter_1940"                                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_wrap_burst_converter.sv"]\"  -work altera_merlin_burst_adapter_1940"                                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_default_burst_converter.sv"]\"  -work altera_merlin_burst_adapter_1940"                                              
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_burst_adapter_1940/sim/altera_merlin_address_alignment.sv"]\"  -work altera_merlin_burst_adapter_1940"                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/pipeline_altera_merlin_demultiplexer_1921_x6yjluq.sv"]\"  -work altera_merlin_demultiplexer_1921"                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/pipeline_altera_merlin_multiplexer_1922_4kg5nvi.sv"]\"  -work altera_merlin_multiplexer_1922"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_1922"                                                        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/pipeline_altera_merlin_multiplexer_1922_prxs4ai.sv"]\"  -work altera_merlin_multiplexer_1922"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_1922"                                                        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_width_adapter_1961/sim/pipeline_altera_merlin_width_adapter_1961_v6j5a2a.sv"]\"  -work altera_merlin_width_adapter_1961"                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_width_adapter_1961/sim/altera_merlin_address_alignment.sv"]\"  -work altera_merlin_width_adapter_1961"                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_width_adapter_1961/sim/altera_merlin_burst_uncompressor.sv"]\"  -work altera_merlin_width_adapter_1961"                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_width_adapter_1961/sim/pipeline_altera_merlin_width_adapter_1961_sjmxhvi.sv"]\"  -work altera_merlin_width_adapter_1961"                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_width_adapter_1961/sim/altera_merlin_address_alignment.sv"]\"  -work altera_merlin_width_adapter_1961"                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_width_adapter_1961/sim/altera_merlin_burst_uncompressor.sv"]\"  -work altera_merlin_width_adapter_1961"                                            
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/pipeline_altera_mm_interconnect_1920_5c5nkdi.v"]\"  -work altera_mm_interconnect_1920"                                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_vvh72si.sv"]\"  -work altera_merlin_router_1921"                                                
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/pipeline_altera_mm_interconnect_1920_h5rdvxi.v"]\"  -work altera_mm_interconnect_1920"                                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_agent_1940/sim/pipeline_altera_merlin_master_agent_1940_r3ep6da.sv"]\"  -work altera_merlin_master_agent_1940"                              
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_iaaklri.sv"]\"  -work altera_merlin_router_1921"                                                
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_rjze4mq.sv"]\"  -work altera_merlin_router_1921"                                                
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/pipeline_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_xk7jela.v"]\"  -work altera_merlin_traffic_limiter_1921"    
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"  -work altera_merlin_traffic_limiter_1921"                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"  -work altera_merlin_traffic_limiter_1921"                                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/pipeline_altera_merlin_traffic_limiter_1921_3mmasty.sv"]\"  -work altera_merlin_traffic_limiter_1921"                     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/pipeline_altera_merlin_demultiplexer_1921_a5o6jrq.sv"]\"  -work altera_merlin_demultiplexer_1921"                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/pipeline_altera_merlin_multiplexer_1922_3dgt5zq.sv"]\"  -work altera_merlin_multiplexer_1922"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_1922"                                                        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/pipeline_altera_merlin_demultiplexer_1921_fcckpky.sv"]\"  -work altera_merlin_demultiplexer_1921"                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/pipeline_altera_merlin_multiplexer_1922_ihb5yvy.sv"]\"  -work altera_merlin_multiplexer_1922"                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_1922"                                                        
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/pipeline_altera_mm_interconnect_1920_xjpsnky.v"]\"  -work altera_mm_interconnect_1920"                                               
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"  -work altera_reset_controller_1924"                                                                  
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"  -work altera_reset_controller_1924"                                                                
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/pipeline.v"]\"  -work pipeline"                                                                                                                                         
    return $design_files
  }
  
  proc get_non_duplicate_elab_option {ELAB_OPTIONS NEW_ELAB_OPTION} {
    set IS_DUPLICATE [string first $NEW_ELAB_OPTION $ELAB_OPTIONS]
    if {$IS_DUPLICATE == -1} {
      return $NEW_ELAB_OPTION
    } else {
      return ""
    }
  }
  
  
  proc get_elab_options {SIMULATOR_TOOL_BITNESS} {
    set ELAB_OPTIONS ""
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_protocol_conv_2::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_clock_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_tpg_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_dil_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_onchip_memory2_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_csc_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_reset_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_mm_bridge_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_clipper_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_vfb_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_protocol_conv_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_crs_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_protocol_conv_1::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_scaler_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [pipeline_intel_vvp_protocol_conv_2::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_clock_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_tpg_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_dil_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_onchip_memory2_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_csc_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_reset_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_mm_bridge_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_clipper_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_vfb_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_protocol_conv_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_crs_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_protocol_conv_1::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_scaler_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_protocol_conv_2::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_clock_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_tpg_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_dil_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_onchip_memory2_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_csc_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_reset_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_mm_bridge_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_clipper_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_vfb_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_protocol_conv_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_crs_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_protocol_conv_1::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_scaler_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
  proc normalize_path {FILEPATH} {
      if {[catch { package require fileutil } err]} { 
          return $FILEPATH 
      } 
      set path [fileutil::lexnormalize [file join [pwd] $FILEPATH]]  
      if {[file pathtype $FILEPATH] eq "relative"} { 
          set path [fileutil::relative [pwd] $path] 
      } 
      return $path 
  } 
  proc get_dpi_libraries {QSYS_SIMDIR} {
    set libraries [dict create]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_2::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/"]]
    set libraries [dict merge $libraries [pipeline_clock_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_clock_in/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_tpg_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_dil_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_onchip_memory2_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_onchip_memory2_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_csc_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_reset_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_reset_in/sim/"]]
    set libraries [dict merge $libraries [pipeline_mm_bridge_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mm_bridge_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_clipper_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_vfb_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_crs_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_1::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_scaler_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/"]]
    
    return $libraries
  }
  
}
