
namespace eval clipper_ip_intel_vvp_tpg_0 {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_common_sv_packages              1
    dict set libraries intel_vvp_reset_sync_2440              1
    dict set libraries intel_vvp_tpg_scheduler_2451           1
    dict set libraries intel_vvp_output_interface_bridge_2440 1
    dict set libraries intel_vvp_tpg_bars_algo_comp_2451      1
    dict set libraries intel_vvp_tpg_2451                     1
    dict set libraries clipper_ip_intel_vvp_tpg_0             1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::aldec_intel_mtm_common_pkg"  "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/intel_mtm_common_pkg.sv"]\"  -work altera_common_sv_packages" 
    dict set design_files "altera_common_sv_packages::aldec_intel_vvp_common_pkg"  "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/intel_vvp_common_pkg.sv"]\"  -work altera_common_sv_packages" 
    dict set design_files "altera_common_sv_packages::aldec_intel_vvp_tpg_pkg"     "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/intel_vvp_tpg_pkg.sv"]\"  -work altera_common_sv_packages"    
    dict set design_files "altera_common_sv_packages::aldec_intel_vvp_utility_pkg" "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/intel_vvp_utility_pkg.sv"]\"  -work altera_common_sv_packages"
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_reset_sync_2440/sim/aldec/src_hdl/intel_vvp_reset_sync.sv"]\" -l altera_common_sv_packages -work intel_vvp_reset_sync_2440"                                       
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_scheduler_2451"                                 
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_scheduler_2451"                                         
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/intel_vvp_pipelined_mux.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_scheduler_2451"                                      
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/intel_vvp_common_slave_interface.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_scheduler_2451"                             
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/src_hdl/intel_vvp_tpg_scheduler.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_scheduler_2451"                              
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_scheduler_2451/sim/aldec/src_hdl/intel_vvp_tpg_scheduler_stopwatch.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_scheduler_2451"                    
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_output_interface_bridge_2440"             
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_output_interface_bridge_2440"                     
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/aldec/src_hdl/intel_vvp_output_interface_bridge.sv"]\" -l altera_common_sv_packages -work intel_vvp_output_interface_bridge_2440"
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_bars_algo_comp_2451/sim/aldec/intel_vvp_axi_zero_pad.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_bars_algo_comp_2451"                             
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_bars_algo_comp_2451/sim/aldec/intel_vvp_axi_zero_strip.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_bars_algo_comp_2451"                           
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_bars_algo_comp_2451/sim/aldec/intel_vvp_axi_pipeline_stage.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_bars_algo_comp_2451"                       
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_bars_algo_comp_2451/sim/aldec/intel_vvp_axi_master.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_bars_algo_comp_2451"                               
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_bars_algo_comp_2451/sim/aldec/src_hdl/intel_vvp_tpg_bars_algo_comp_lut.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_bars_algo_comp_2451"           
    lappend design_files "vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_bars_algo_comp_2451/sim/aldec/src_hdl/intel_vvp_tpg_bars_algo_comp.sv"]\" -l altera_common_sv_packages -work intel_vvp_tpg_bars_algo_comp_2451"               
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_tpg_2451/sim/clipper_ip_intel_vvp_tpg_0_intel_vvp_tpg_2451_d5l5lza.v"]\"  -work intel_vvp_tpg_2451"                                                          
    lappend design_files "vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/clipper_ip_intel_vvp_tpg_0.v"]\"  -work clipper_ip_intel_vvp_tpg_0"                                                                                                       
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
