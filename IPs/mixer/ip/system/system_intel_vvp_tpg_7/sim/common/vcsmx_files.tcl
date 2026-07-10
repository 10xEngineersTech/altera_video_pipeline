
namespace eval system_intel_vvp_tpg_7 {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_common_sv_packages              1
    dict set libraries intel_vvp_reset_sync_2440              1
    dict set libraries intel_vvp_tpg_scheduler_2451           1
    dict set libraries intel_vvp_output_interface_bridge_2440 1
    dict set libraries intel_vvp_tpg_const_algo_comp_2451     1
    dict set libraries intel_vvp_reset_bridge_2440            1
    dict set libraries intel_vvp_ro_reg_servicer_2441         1
    dict set libraries intel_vvp_mm_agent_reset_hold_2440     1
    dict set libraries altera_merlin_master_translator_193    1
    dict set libraries altera_merlin_slave_translator_191     1
    dict set libraries altera_mm_interconnect_1920            1
    dict set libraries intel_vvp_slave_front_end_2441         1
    dict set libraries intel_vvp_tpg_2451                     1
    dict set libraries system_intel_vvp_tpg_7                 1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::synopsys_intel_mtm_common_pkg"  "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/intel_mtm_common_pkg.sv\"  -work altera_common_sv_packages" 
    dict set design_files "altera_common_sv_packages::synopsys_intel_vvp_common_pkg"  "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/intel_vvp_common_pkg.sv\"  -work altera_common_sv_packages" 
    dict set design_files "altera_common_sv_packages::synopsys_intel_vvp_tpg_pkg"     "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/intel_vvp_tpg_pkg.sv\"  -work altera_common_sv_packages"    
    dict set design_files "altera_common_sv_packages::synopsys_intel_vvp_utility_pkg" "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/intel_vvp_utility_pkg.sv\"  -work altera_common_sv_packages"
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_reset_sync_2440/sim/synopsys/src_hdl/intel_vvp_reset_sync.sv\"  -work intel_vvp_reset_sync_2440"                                                 
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/intel_vvp_axi_pipeline_stage.sv\"  -work intel_vvp_tpg_scheduler_2451"                                           
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/intel_vvp_axi_master.sv\"  -work intel_vvp_tpg_scheduler_2451"                                                   
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/intel_vvp_pipelined_mux.sv\"  -work intel_vvp_tpg_scheduler_2451"                                                
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/intel_vvp_common_slave_interface.sv\"  -work intel_vvp_tpg_scheduler_2451"                                       
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/src_hdl/intel_vvp_tpg_scheduler.sv\"  -work intel_vvp_tpg_scheduler_2451"                                        
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/synopsys/src_hdl/intel_vvp_tpg_scheduler_stopwatch.sv\"  -work intel_vvp_tpg_scheduler_2451"                              
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/synopsys/intel_vvp_axi_pipeline_stage.sv\"  -work intel_vvp_output_interface_bridge_2440"                       
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/synopsys/intel_vvp_axi_master.sv\"  -work intel_vvp_output_interface_bridge_2440"                               
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/synopsys/src_hdl/intel_vvp_output_interface_bridge.sv\"  -work intel_vvp_output_interface_bridge_2440"          
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_const_algo_comp_2451/sim/synopsys/intel_vvp_axi_zero_pad.sv\"  -work intel_vvp_tpg_const_algo_comp_2451"                                     
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_const_algo_comp_2451/sim/synopsys/intel_vvp_axi_zero_strip.sv\"  -work intel_vvp_tpg_const_algo_comp_2451"                                   
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_const_algo_comp_2451/sim/synopsys/intel_vvp_axi_pipeline_stage.sv\"  -work intel_vvp_tpg_const_algo_comp_2451"                               
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_const_algo_comp_2451/sim/synopsys/intel_vvp_axi_master.sv\"  -work intel_vvp_tpg_const_algo_comp_2451"                                       
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_const_algo_comp_2451/sim/synopsys/src_hdl/intel_vvp_tpg_const_algo_comp.sv\"  -work intel_vvp_tpg_const_algo_comp_2451"                      
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_reset_bridge_2440/sim/synopsys/src_hdl/intel_vvp_reset_bridge.sv\"  -work intel_vvp_reset_bridge_2440"                                           
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_ro_reg_servicer_2441/sim/synopsys/src_hdl/intel_vvp_ro_reg_servicer.sv\"  -work intel_vvp_ro_reg_servicer_2441"                                  
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_ro_reg_servicer_2441/sim/system_intel_vvp_tpg_7_intel_vvp_ro_reg_servicer_2441_ekbrpli.sv\"  -work intel_vvp_ro_reg_servicer_2441"               
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_mm_agent_reset_hold_2440/sim/synopsys/src_hdl/intel_vvp_mm_agent_reset_hold.sv\"  -work intel_vvp_mm_agent_reset_hold_2440"                      
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../altera_merlin_master_translator_193/sim/system_intel_vvp_tpg_7_altera_merlin_master_translator_193_lgcew2q.sv\"  -work altera_merlin_master_translator_193"
    lappend design_files "vlogan +v2k -sverilog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/system_intel_vvp_tpg_7_altera_merlin_slave_translator_191_xg7rzxi.sv\"  -work altera_merlin_slave_translator_191"   
    lappend design_files "vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/system_intel_vvp_tpg_7_altera_mm_interconnect_1920_epi4vay.v\"  -work altera_mm_interconnect_1920"                                   
    lappend design_files "vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_slave_front_end_2441/sim/system_intel_vvp_tpg_7_intel_vvp_slave_front_end_2441_2hphgyy.v\"  -work intel_vvp_slave_front_end_2441"                          
    lappend design_files "vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/system_intel_vvp_tpg_7_altera_mm_interconnect_1920_vevxpda.v\"  -work altera_mm_interconnect_1920"                                   
    lappend design_files "vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../intel_vvp_tpg_2451/sim/system_intel_vvp_tpg_7_intel_vvp_tpg_2451_qzlh2ai.v\"  -work intel_vvp_tpg_2451"                                                              
    lappend design_files "vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/system_intel_vvp_tpg_7.v\"  -work system_intel_vvp_tpg_7"                                                                                                               
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
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
  proc get_dpi_libraries {QSYS_SIMDIR} {
    set libraries [dict create]
    
    return $libraries
  }
  
}
