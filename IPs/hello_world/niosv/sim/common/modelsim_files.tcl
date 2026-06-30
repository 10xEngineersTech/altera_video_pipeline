source [file join [file dirname [info script]] ./../../../ip/niosv/niosv_intel_vvp_scaler_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/niosv/niosv_clock_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/niosv/niosv_intel_vvp_tpg_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/niosv/niosv_reset_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/niosv/niosv_intel_niosv_m_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/niosv/niosv_jtag_uart_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/niosv/niosv_intel_onchip_memory_0/sim/common/modelsim_files.tcl]

namespace eval niosv {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [niosv_intel_vvp_scaler_0::get_design_libraries]]
    set libraries [dict merge $libraries [niosv_clock_in::get_design_libraries]]
    set libraries [dict merge $libraries [niosv_intel_vvp_tpg_0::get_design_libraries]]
    set libraries [dict merge $libraries [niosv_reset_in::get_design_libraries]]
    set libraries [dict merge $libraries [niosv_intel_niosv_m_0::get_design_libraries]]
    set libraries [dict merge $libraries [niosv_jtag_uart_0::get_design_libraries]]
    set libraries [dict merge $libraries [niosv_intel_onchip_memory_0::get_design_libraries]]
    dict set libraries altera_merlin_slave_translator_191 1
    dict set libraries altera_merlin_axi_master_ni_19112  1
    dict set libraries altera_merlin_slave_agent_1930     1
    dict set libraries altera_avalon_sc_fifo_1932         1
    dict set libraries altera_merlin_router_1921          1
    dict set libraries altera_merlin_traffic_limiter_1921 1
    dict set libraries altera_merlin_demultiplexer_1921   1
    dict set libraries altera_merlin_multiplexer_1922     1
    dict set libraries altera_mm_interconnect_1920        1
    dict set libraries altera_irq_mapper_2001             1
    dict set libraries altera_reset_controller_1924       1
    dict set libraries niosv                              1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [niosv_intel_vvp_scaler_0::get_memory_files "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_vvp_scaler_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [niosv_clock_in::get_memory_files "$QSYS_SIMDIR/../../ip/niosv/niosv_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [niosv_intel_vvp_tpg_0::get_memory_files "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_vvp_tpg_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [niosv_reset_in::get_memory_files "$QSYS_SIMDIR/../../ip/niosv/niosv_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [niosv_intel_niosv_m_0::get_memory_files "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_niosv_m_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [niosv_jtag_uart_0::get_memory_files "$QSYS_SIMDIR/../../ip/niosv/niosv_jtag_uart_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [niosv_intel_onchip_memory_0::get_memory_files "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_onchip_memory_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [niosv_intel_vvp_scaler_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_vvp_scaler_0/sim/"]]
    set design_files [dict merge $design_files [niosv_clock_in::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_clock_in/sim/"]]
    set design_files [dict merge $design_files [niosv_intel_vvp_tpg_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_vvp_tpg_0/sim/"]]
    set design_files [dict merge $design_files [niosv_reset_in::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_reset_in/sim/"]]
    set design_files [dict merge $design_files [niosv_intel_niosv_m_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_niosv_m_0/sim/"]]
    set design_files [dict merge $design_files [niosv_jtag_uart_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_jtag_uart_0/sim/"]]
    set design_files [dict merge $design_files [niosv_intel_onchip_memory_0::get_common_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_onchip_memory_0/sim/"]]
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    set design_files [concat $design_files [niosv_intel_vvp_scaler_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_vvp_scaler_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [niosv_clock_in::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [niosv_intel_vvp_tpg_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_vvp_tpg_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [niosv_reset_in::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [niosv_intel_niosv_m_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_niosv_m_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [niosv_jtag_uart_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_jtag_uart_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [niosv_intel_onchip_memory_0::get_design_files $USER_DEFINED_COMPILE_OPTIONS $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_VHDL_COMPILE_OPTIONS "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_onchip_memory_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/niosv_altera_merlin_slave_translator_191_xg7rzxi.sv"]\"  -work altera_merlin_slave_translator_191"                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_master_ni_19112/sim/altera_merlin_address_alignment.sv"]\"  -work altera_merlin_axi_master_ni_19112"                                    
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_master_ni_19112/sim/niosv_altera_merlin_axi_master_ni_19112_2jrcixq.sv"]\"  -work altera_merlin_axi_master_ni_19112"                    
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/niosv_altera_merlin_slave_agent_1930_jxauz3i.sv"]\"  -work altera_merlin_slave_agent_1930"                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/altera_merlin_burst_uncompressor.sv"]\"  -work altera_merlin_slave_agent_1930"                                         
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_1932/sim/niosv_altera_avalon_sc_fifo_1932_22gxxgi.v"]\"  -work altera_avalon_sc_fifo_1932"                                              
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/niosv_altera_merlin_router_1921_lybrmxi.sv"]\"  -work altera_merlin_router_1921"                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/niosv_altera_merlin_router_1921_wk4zmiq.sv"]\"  -work altera_merlin_router_1921"                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/niosv_altera_merlin_router_1921_2c3yowy.sv"]\"  -work altera_merlin_router_1921"                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/niosv_altera_merlin_router_1921_fv5lsya.sv"]\"  -work altera_merlin_router_1921"                                            
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/niosv_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_jyjty3i.v"]\"  -work altera_merlin_traffic_limiter_1921"
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"  -work altera_merlin_traffic_limiter_1921"                                     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"  -work altera_merlin_traffic_limiter_1921"                                    
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/niosv_altera_merlin_traffic_limiter_1921_2thi65i.sv"]\"  -work altera_merlin_traffic_limiter_1921"                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/niosv_altera_merlin_demultiplexer_1921_tzpzzfi.sv"]\"  -work altera_merlin_demultiplexer_1921"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/niosv_altera_merlin_demultiplexer_1921_iqu23ka.sv"]\"  -work altera_merlin_demultiplexer_1921"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/niosv_altera_merlin_multiplexer_1922_r3eaopi.sv"]\"  -work altera_merlin_multiplexer_1922"                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_1922"                                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/niosv_altera_merlin_multiplexer_1922_ivj7c2q.sv"]\"  -work altera_merlin_multiplexer_1922"                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_1922"                                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/niosv_altera_merlin_demultiplexer_1921_7qm2rni.sv"]\"  -work altera_merlin_demultiplexer_1921"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/niosv_altera_merlin_demultiplexer_1921_llj7jvi.sv"]\"  -work altera_merlin_demultiplexer_1921"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/niosv_altera_merlin_multiplexer_1922_qgsvfny.sv"]\"  -work altera_merlin_multiplexer_1922"                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_1922"                                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/niosv_altera_merlin_multiplexer_1922_vgo2gcq.sv"]\"  -work altera_merlin_multiplexer_1922"                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"  -work altera_merlin_multiplexer_1922"                                                 
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/niosv_altera_mm_interconnect_1920_hncfsey.v"]\"  -work altera_mm_interconnect_1920"                                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_irq_mapper_2001/sim/niosv_altera_irq_mapper_2001_x43qi7i.sv"]\"  -work altera_irq_mapper_2001"                                                     
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"  -work altera_reset_controller_1924"                                                           
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"  -work altera_reset_controller_1924"                                                         
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/niosv.v"]\"  -work niosv"                                                                                                                                        
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
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [niosv_intel_vvp_scaler_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [niosv_clock_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [niosv_intel_vvp_tpg_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [niosv_reset_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [niosv_intel_niosv_m_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [niosv_jtag_uart_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [niosv_intel_onchip_memory_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [niosv_intel_vvp_scaler_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [niosv_clock_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [niosv_intel_vvp_tpg_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [niosv_reset_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [niosv_intel_niosv_m_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [niosv_jtag_uart_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [niosv_intel_onchip_memory_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [niosv_intel_vvp_scaler_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [niosv_clock_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [niosv_intel_vvp_tpg_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [niosv_reset_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [niosv_intel_niosv_m_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [niosv_jtag_uart_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [niosv_intel_onchip_memory_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
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
    set libraries [dict merge $libraries [niosv_intel_vvp_scaler_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_vvp_scaler_0/sim/"]]
    set libraries [dict merge $libraries [niosv_clock_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/niosv/niosv_clock_in/sim/"]]
    set libraries [dict merge $libraries [niosv_intel_vvp_tpg_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_vvp_tpg_0/sim/"]]
    set libraries [dict merge $libraries [niosv_reset_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/niosv/niosv_reset_in/sim/"]]
    set libraries [dict merge $libraries [niosv_intel_niosv_m_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_niosv_m_0/sim/"]]
    set libraries [dict merge $libraries [niosv_jtag_uart_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/niosv/niosv_jtag_uart_0/sim/"]]
    set libraries [dict merge $libraries [niosv_intel_onchip_memory_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/niosv/niosv_intel_onchip_memory_0/sim/"]]
    
    return $libraries
  }
  
}
