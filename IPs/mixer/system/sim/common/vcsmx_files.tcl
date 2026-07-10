source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_mixer_1/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_reset_in/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_8/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_2/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_3/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_9/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_4/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_7/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_clock_in/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_5/sim/common/vcsmx_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/system/system_intel_vvp_tpg_6/sim/common/vcsmx_files.tcl]

namespace eval system {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [system_intel_vvp_mixer_1::get_design_libraries]]
    set libraries [dict merge $libraries [system_reset_in::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_8::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_2::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_3::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_9::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_4::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_7::get_design_libraries]]
    set libraries [dict merge $libraries [system_clock_in::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_5::get_design_libraries]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_6::get_design_libraries]]
    dict set libraries altera_reset_controller_1924 1
    dict set libraries system                       1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [system_intel_vvp_mixer_1::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_mixer_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_reset_in::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_8::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_8/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_2::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_2/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_3::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_3/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_9::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_9/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_4::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_4/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_7::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_7/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_clock_in::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_5::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_5/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [system_intel_vvp_tpg_6::get_memory_files "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_6/sim/" "$QUARTUS_INSTALL_DIR"]]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [system_intel_vvp_mixer_1::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_mixer_1/sim/"]]
    set design_files [dict merge $design_files [system_reset_in::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_reset_in/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_8::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_8/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_2::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_2/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_3::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_3/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_9::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_9/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_4::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_4/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_7::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_7/sim/"]]
    set design_files [dict merge $design_files [system_clock_in::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_clock_in/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_5::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_5/sim/"]]
    set design_files [dict merge $design_files [system_intel_vvp_tpg_6::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_6/sim/"]]
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    set design_files [concat $design_files [system_intel_vvp_mixer_1::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_mixer_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_reset_in::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_8::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_8/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_2::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_2/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_3::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_3/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_9::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_9/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_4::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_4/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_7::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_7/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_clock_in::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_5::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_5/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [system_intel_vvp_tpg_6::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_6/sim/" "$QUARTUS_INSTALL_DIR"]]
    lappend design_files "vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v\"  -work altera_reset_controller_1924"  
    lappend design_files "vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v\"  -work altera_reset_controller_1924"
    lappend design_files "vlogan +v2k $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"$QSYS_SIMDIR/system.v\"  -work system"                                                                             
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
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_mixer_1::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_reset_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_8::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_2::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_3::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_9::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_4::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_7::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_clock_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_5::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [system_intel_vvp_tpg_6::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [system_intel_vvp_mixer_1::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_reset_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_8::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_2::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_3::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_9::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_4::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_7::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_clock_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_5::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [system_intel_vvp_tpg_6::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_mixer_1::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_reset_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_8::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_2::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_3::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_9::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_4::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_7::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_clock_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_5::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [system_intel_vvp_tpg_6::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    dict set ENV_VARIABLES "LD_LIBRARY_PATH" $LD_LIBRARY_PATH
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ENV_VARIABLES
  }
  
  
  proc get_dpi_libraries {QSYS_SIMDIR} {
    set libraries [dict create]
    set libraries [dict merge $libraries [system_intel_vvp_mixer_1::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_mixer_1/sim/"]]
    set libraries [dict merge $libraries [system_reset_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_reset_in/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_8::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_8/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_2::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_2/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_3::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_3/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_9::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_9/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_4::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_4/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_7::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_7/sim/"]]
    set libraries [dict merge $libraries [system_clock_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_clock_in/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_5::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_5/sim/"]]
    set libraries [dict merge $libraries [system_intel_vvp_tpg_6::get_dpi_libraries "$QSYS_SIMDIR/../../ip/system/system_intel_vvp_tpg_6/sim/"]]
    
    return $libraries
  }
  
}
