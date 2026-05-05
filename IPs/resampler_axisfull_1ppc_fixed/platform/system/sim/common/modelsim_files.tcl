source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_crs_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_clock_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_reset_in/sim/common/modelsim_files.tcl]

namespace eval system {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [system_intel_vvp_crs_0::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_0::get_design_libraries]]
    set libraries [dict merge $libraries [system_clock_in::get_design_libraries]]
    set libraries [dict merge $libraries [system_reset_in::get_design_libraries]]
    dict set libraries altera_reset_controller_1924 1
    dict set libraries system                       1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [system_intel_vvp_crs_0::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_crs_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_0::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_clock_in::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_reset_in::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [system_intel_vvp_crs_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_crs_0/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_0/sim/"]]
    set design_files [dict merge $design_files [system_clock_in::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_clock_in/sim/"]]
    set design_files [dict merge $design_files [system_reset_in::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_reset_in/sim/"]]
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    set design_files [concat $design_files [system_intel_vvp_crs_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_crs_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_clock_in::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_reset_in::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"  -work altera_reset_controller_1924"  
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"  -work altera_reset_controller_1924"
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/system.v"]\"  -work system"                                                                             
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
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_crs_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_clock_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_reset_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [system_intel_vvp_crs_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_clock_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_reset_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_crs_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_clock_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_reset_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
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
    set libraries [dict merge $libraries [system_intel_vvp_crs_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_crs_0/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_0/sim/"]]
    set libraries [dict merge $libraries [system_clock_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_clock_in/sim/"]]
    set libraries [dict merge $libraries [system_reset_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_reset_in/sim/"]]
    
    return $libraries
  }
  
}
