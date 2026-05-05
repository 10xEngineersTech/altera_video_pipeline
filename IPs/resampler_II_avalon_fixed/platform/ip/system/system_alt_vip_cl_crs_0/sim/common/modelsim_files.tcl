
namespace eval system_alt_vip_cl_crs_0 {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_common_sv_packages            1
    dict set libraries alt_vip_video_input_bridge_resp_2360 1
    dict set libraries alt_vip_video_output_bridge_2360     1
    dict set libraries alt_vip_video_input_bridge_cmd_2360  1
    dict set libraries alt_vip_pip_converter_core_2360      1
    dict set libraries alt_vip_packet_demux_2360            1
    dict set libraries alt_vip_crs_h_up_core_2360           1
    dict set libraries alt_vip_cpp_converter_2360           1
    dict set libraries alt_vip_packet_mux_2360              1
    dict set libraries alt_vip_cl_crs_422_to_var_2360       1
    dict set libraries alt_vip_crs_scheduler_2360           1
    dict set libraries alt_vip_cl_crs_2360                  1
    dict set libraries system_alt_vip_cl_crs_0              1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::mentor_alt_vip_common_pkg" "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_resp_2360/sim/mentor/common/alt_vip_common_pkg.sv"]\"  -work altera_common_sv_packages"
    return $design_files
  }
  
  proc get_design_files {USER_DEFINED_COMPILE_OPTIONS USER_DEFINED_VERILOG_COMPILE_OPTIONS USER_DEFINED_VHDL_COMPILE_OPTIONS QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_resp_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_video_input_bridge_resp_2360"   
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_resp_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_video_input_bridge_resp_2360"   
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_resp_2360/sim/mentor/modules/alt_vip_common_video_packet_decode/src_hdl/alt_vip_common_latency_1_to_latency_0.sv"]\" -L altera_common_sv_packages -work alt_vip_video_input_bridge_resp_2360"
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_resp_2360/sim/mentor/modules/alt_vip_common_video_packet_decode/src_hdl/alt_vip_common_video_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_video_input_bridge_resp_2360"   
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_resp_2360/sim/mentor/src_hdl/alt_vip_video_input_bridge_resp.sv"]\" -L altera_common_sv_packages -work alt_vip_video_input_bridge_resp_2360"                                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_output_bridge_2360/sim/mentor/modules/alt_vip_common_video_packet_encode/src_hdl/alt_vip_common_latency_0_to_latency_1.sv"]\" -L altera_common_sv_packages -work alt_vip_video_output_bridge_2360"        
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_output_bridge_2360/sim/mentor/modules/alt_vip_common_video_packet_encode/src_hdl/alt_vip_common_video_packet_empty.sv"]\" -L altera_common_sv_packages -work alt_vip_video_output_bridge_2360"            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_output_bridge_2360/sim/mentor/modules/alt_vip_common_video_packet_encode/src_hdl/alt_vip_common_video_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_video_output_bridge_2360"           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_output_bridge_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_video_output_bridge_2360"           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_output_bridge_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_video_output_bridge_2360"           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_output_bridge_2360/sim/mentor/modules/alt_vip_common_message_pipeline_stage/src_hdl/alt_vip_common_message_pipeline_stage.sv"]\" -L altera_common_sv_packages -work alt_vip_video_output_bridge_2360"     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_output_bridge_2360/sim/mentor/modules/alt_vip_common_sop_align/src_hdl/alt_vip_common_sop_align.sv"]\" -L altera_common_sv_packages -work alt_vip_video_output_bridge_2360"                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_output_bridge_2360/sim/mentor/src_hdl/alt_vip_video_output_bridge.sv"]\" -L altera_common_sv_packages -work alt_vip_video_output_bridge_2360"                                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_cmd_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_video_input_bridge_cmd_2360"     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_cmd_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_video_input_bridge_cmd_2360"     
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_video_input_bridge_cmd_2360/sim/mentor/src_hdl/alt_vip_video_input_bridge_cmd.sv"]\" -L altera_common_sv_packages -work alt_vip_video_input_bridge_cmd_2360"                                                    
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_pip_converter_core_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_pip_converter_core_2360"             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_pip_converter_core_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_pip_converter_core_2360"             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_pip_converter_core_2360/sim/mentor/modules/alt_vip_common_fifo2/src_hdl/alt_vip_common_fifo2.sv"]\" -L altera_common_sv_packages -work alt_vip_pip_converter_core_2360"                                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_pip_converter_core_2360/sim/mentor/src_hdl/alt_vip_pip_converter_core.sv"]\" -L altera_common_sv_packages -work alt_vip_pip_converter_core_2360"                                                                
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_packet_demux_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_packet_demux_2360"                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_packet_demux_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_packet_demux_2360"                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_packet_demux_2360/sim/mentor/src_hdl/alt_vip_packet_demux.sv"]\" -L altera_common_sv_packages -work alt_vip_packet_demux_2360"                                                                                  
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_h_kernel/src_hdl/alt_vip_common_h_kernel.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_h_kernel/src_hdl/alt_vip_common_h_kernel_par.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_h_kernel/src_hdl/alt_vip_common_h_kernel_seq.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                         
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_mirror/src_hdl/alt_vip_common_mirror.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                                 
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_mux_tree/src_hdl/alt_vip_common_mux_tree.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_round_sat/src_hdl/alt_vip_common_round_sat.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_mult_add/src_hdl/alt_vip_common_mult_add.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_sop_align/src_hdl/alt_vip_common_sop_align.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/modules/alt_vip_common_seq_par_convert/src_hdl/alt_vip_common_seq_par_convert.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/src_hdl/alt_vip_crs_h_up_core.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                                                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/src_hdl/alt_vip_crs_h_up_core_nn.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/src_hdl/alt_vip_crs_h_up_core_bl.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/src_hdl/alt_vip_crs_h_up_core_ft.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_h_up_core_2360/sim/mentor/src_hdl/alt_vip_crs_h_up_core_la.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_h_up_core_2360"                                                                            
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_cpp_converter_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_cpp_converter_2360"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_cpp_converter_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_cpp_converter_2360"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_cpp_converter_2360/sim/mentor/modules/alt_vip_common_fifo2/src_hdl/alt_vip_common_fifo2.sv"]\" -L altera_common_sv_packages -work alt_vip_cpp_converter_2360"                                                   
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_cpp_converter_2360/sim/mentor/src_hdl/alt_vip_cpp_converter.sv"]\" -L altera_common_sv_packages -work alt_vip_cpp_converter_2360"                                                                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_packet_mux_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_packet_mux_2360"                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_packet_mux_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_packet_mux_2360"                             
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_packet_mux_2360/sim/mentor/modules/alt_vip_common_mux_tree/src_hdl/alt_vip_common_mux_tree.sv"]\" -L altera_common_sv_packages -work alt_vip_packet_mux_2360"                                                   
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_packet_mux_2360/sim/mentor/src_hdl/alt_vip_packet_mux.sv"]\" -L altera_common_sv_packages -work alt_vip_packet_mux_2360"                                                                                        
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_cl_crs_422_to_var_2360/sim/system_alt_vip_cl_crs_0_alt_vip_cl_crs_422_to_var_2360_xj5jyii.v"]\"  -work alt_vip_cl_crs_422_to_var_2360"                                                                              
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_scheduler_2360/sim/mentor/modules/alt_vip_common_event_packet_decode/src_hdl/alt_vip_common_event_packet_decode.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_scheduler_2360"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_scheduler_2360/sim/mentor/modules/alt_vip_common_event_packet_encode/src_hdl/alt_vip_common_event_packet_encode.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_scheduler_2360"                       
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_scheduler_2360/sim/mentor/modules/alt_vip_common_slave_interface/src_hdl/alt_vip_common_slave_interface.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_scheduler_2360"                               
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_scheduler_2360/sim/mentor/modules/alt_vip_common_slave_interface/src_hdl/alt_vip_common_slave_interface_mux.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_scheduler_2360"                           
    lappend design_files "vlog -sv $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_crs_scheduler_2360/sim/mentor/src_hdl/alt_vip_crs_scheduler.sv"]\" -L altera_common_sv_packages -work alt_vip_crs_scheduler_2360"                                                                               
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/../alt_vip_cl_crs_2360/sim/system_alt_vip_cl_crs_0_alt_vip_cl_crs_2360_dbzwawy.v"]\"  -work alt_vip_cl_crs_2360"                                                                                                               
    lappend design_files "vlog $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS  \"[normalize_path "$QSYS_SIMDIR/system_alt_vip_cl_crs_0.v"]\"  -work system_alt_vip_cl_crs_0"                                                                                                                                                                  
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
