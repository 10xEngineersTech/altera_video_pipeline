
namespace eval system_intel_vvp_mixer_1 {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_common_sv_packages              1
    dict set libraries intel_vvp_reset_sync_2440              1
    dict set libraries intel_vvp_input_interface_bridge_2440  1
    dict set libraries intel_vvp_output_interface_bridge_2440 1
    dict set libraries intel_vvp_mixer_slave_2451             1
    dict set libraries intel_vvp_mixer_scheduler_2451         1
    dict set libraries intel_vvp_mixer_algo_comp_2451         1
    dict set libraries intel_vvp_packet_discard_2440          1
    dict set libraries intel_vvp_reset_bridge_2440            1
    dict set libraries intel_vvp_ro_reg_servicer_2441         1
    dict set libraries intel_vvp_mm_agent_reset_hold_2440     1
    dict set libraries altera_merlin_master_translator_193    1
    dict set libraries altera_merlin_slave_translator_191     1
    dict set libraries altera_mm_interconnect_1920            1
    dict set libraries intel_vvp_slave_front_end_2441         1
    dict set libraries intel_vvp_mixer_2451                   1
    dict set libraries system_intel_vvp_mixer_1               1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::aldec_intel_vvp_common_pkg"  "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/aldec/intel_vvp_common_pkg.sv"]\"  -work altera_common_sv_packages"
    dict set design_files "altera_common_sv_packages::aldec_intel_vvp_mixer_pkg"   "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/intel_vvp_mixer_pkg.sv"]\"  -work altera_common_sv_packages"            
    dict set design_files "altera_common_sv_packages::aldec_intel_mtm_common_pkg"  "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_scheduler_2451/sim/aldec/intel_mtm_common_pkg.sv"]\"  -work altera_common_sv_packages"       
    dict set design_files "altera_common_sv_packages::aldec_intel_vvp_utility_pkg" "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_scheduler_2451/sim/aldec/intel_vvp_utility_pkg.sv"]\"  -work altera_common_sv_packages"      
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_reset_sync_2440/sim/aldec/src_hdl/intel_vvp_reset_sync.sv"]\" -l altera_common_sv_packages -work intel_vvp_reset_sync_2440"                                                      
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_input_interface_bridge_2440"                              
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_input_interface_bridge_2440"                                      
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/aldec/src_hdl/intel_vvp_input_interface_bridge.sv"]\" -l altera_common_sv_packages -work intel_vvp_input_interface_bridge_2440"                  
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_output_interface_bridge_2440"                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_output_interface_bridge_2440"                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/aldec/src_hdl/intel_vvp_output_interface_bridge.sv"]\" -l altera_common_sv_packages -work intel_vvp_output_interface_bridge_2440"               
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/intel_vvp_pipelined_mux.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                                         
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/intel_vvp_common_slave_interface.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                                
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/src_hdl/intel_vvp_mixer_slave_ctrl_insert.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                       
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/src_hdl/intel_vvp_mixer_slave_sync.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                              
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/src_hdl/intel_vvp_mixer_slave_int.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                               
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/src_hdl/intel_vvp_mixer_slave_ext.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                               
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_slave_2451/sim/aldec/src_hdl/intel_vvp_mixer_slave.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_slave_2451"                                                   
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_scheduler_2451/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_scheduler_2451"                                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_scheduler_2451/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_scheduler_2451"                                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_scheduler_2451/sim/aldec/src_hdl/intel_vvp_mixer_scheduler_ov_int.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_scheduler_2451"                                
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_scheduler_2451/sim/aldec/src_hdl/intel_vvp_mixer_scheduler_ov_ext.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_scheduler_2451"                                
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_scheduler_2451/sim/aldec/src_hdl/intel_vvp_mixer_scheduler.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_scheduler_2451"                                       
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_add_tree.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                      
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_mult.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                          
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_2_mult_add.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_3_mult_add.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_4_mult_add.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_mult_add.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                      
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_round_sat.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                     
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_shift_mux.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                     
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_axi_zero_pad.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                  
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_axi_zero_strip.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                            
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/src_hdl/intel_vvp_mixer_algo_comp_align.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                 
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/src_hdl/intel_vvp_mixer_algo_comp_dp.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_algo_comp_2451/sim/aldec/src_hdl/intel_vvp_mixer_algo_comp.sv"]\" -l altera_common_sv_packages -work intel_vvp_mixer_algo_comp_2451"                                       
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_discard_2440/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_packet_discard_2440"                                              
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_discard_2440/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_packet_discard_2440"                                                      
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_discard_2440/sim/aldec/src_hdl/intel_vvp_packet_discard.sv"]\" -l altera_common_sv_packages -work intel_vvp_packet_discard_2440"                                          
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_reset_bridge_2440/sim/aldec/src_hdl/intel_vvp_reset_bridge.sv"]\" -l altera_common_sv_packages -work intel_vvp_reset_bridge_2440"                                                
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_ro_reg_servicer_2441/sim/aldec/src_hdl/intel_vvp_ro_reg_servicer.sv"]\" -l altera_common_sv_packages -work intel_vvp_ro_reg_servicer_2441"                                       
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_ro_reg_servicer_2441/sim/system_intel_vvp_mixer_1_intel_vvp_ro_reg_servicer_2441_t7dn2nq.sv"]\" -l altera_common_sv_packages -work intel_vvp_ro_reg_servicer_2441"               
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mm_agent_reset_hold_2440/sim/aldec/src_hdl/intel_vvp_mm_agent_reset_hold.sv"]\" -l altera_common_sv_packages -work intel_vvp_mm_agent_reset_hold_2440"                           
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_translator_193/sim/system_intel_vvp_mixer_1_altera_merlin_master_translator_193_lgcew2q.sv"]\" -l altera_common_sv_packages -work altera_merlin_master_translator_193"
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/system_intel_vvp_mixer_1_altera_merlin_slave_translator_191_xg7rzxi.sv"]\" -l altera_common_sv_packages -work altera_merlin_slave_translator_191"   
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/system_intel_vvp_mixer_1_altera_mm_interconnect_1920_hdaqvey.v"]\"  -work altera_mm_interconnect_1920"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_slave_front_end_2441/sim/system_intel_vvp_mixer_1_intel_vvp_slave_front_end_2441_ggsszvi.v"]\"  -work intel_vvp_slave_front_end_2441"                                       
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/system_intel_vvp_mixer_1_altera_mm_interconnect_1920_rm3fhtq.v"]\"  -work altera_mm_interconnect_1920"                                                
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_mixer_2451/sim/system_intel_vvp_mixer_1_intel_vvp_mixer_2451_snnu3si.v"]\"  -work intel_vvp_mixer_2451"                                                                     
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/system_intel_vvp_mixer_1.v"]\"  -work system_intel_vvp_mixer_1"                                                                                                                          
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
    
    return $libraries
  }
  
}
