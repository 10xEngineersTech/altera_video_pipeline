
namespace eval clipper_ip_intel_vvp_clipper_0 {
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::synopsys_intel_vvp_common_pkg"  "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/synopsys/intel_vvp_common_pkg.sv"
    dict set design_files "altera_common_sv_packages::synopsys_intel_vvp_clipper_pkg" "$QSYS_SIMDIR/../intel_vvp_clipper_scheduler_2451/sim/synopsys/intel_vvp_clipper_pkg.sv"    
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [dict create]
    dict set design_files "intel_vvp_reset_sync.sv"                                                       "$QSYS_SIMDIR/../intel_vvp_reset_sync_2440/sim/synopsys/src_hdl/intel_vvp_reset_sync.sv"                                               
    dict set design_files "intel_vvp_axi_pipeline_stage.sv"                                               "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/synopsys/intel_vvp_axi_pipeline_stage.sv"                                   
    dict set design_files "intel_vvp_axi_master.sv"                                                       "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/synopsys/intel_vvp_axi_master.sv"                                           
    dict set design_files "intel_vvp_input_interface_bridge.sv"                                           "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/synopsys/src_hdl/intel_vvp_input_interface_bridge.sv"                       
    dict set design_files "intel_vvp_axi_pipeline_stage.sv"                                               "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/synopsys/intel_vvp_axi_pipeline_stage.sv"                                  
    dict set design_files "intel_vvp_axi_master.sv"                                                       "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/synopsys/intel_vvp_axi_master.sv"                                          
    dict set design_files "intel_vvp_output_interface_bridge.sv"                                          "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/synopsys/src_hdl/intel_vvp_output_interface_bridge.sv"                     
    dict set design_files "intel_vvp_pipelined_mux.sv"                                                    "$QSYS_SIMDIR/../intel_vvp_clipper_scheduler_2451/sim/synopsys/intel_vvp_pipelined_mux.sv"                                             
    dict set design_files "intel_vvp_common_slave_interface.sv"                                           "$QSYS_SIMDIR/../intel_vvp_clipper_scheduler_2451/sim/synopsys/intel_vvp_common_slave_interface.sv"                                    
    dict set design_files "intel_vvp_axi_pipeline_stage.sv"                                               "$QSYS_SIMDIR/../intel_vvp_clipper_scheduler_2451/sim/synopsys/intel_vvp_axi_pipeline_stage.sv"                                        
    dict set design_files "intel_vvp_axi_master.sv"                                                       "$QSYS_SIMDIR/../intel_vvp_clipper_scheduler_2451/sim/synopsys/intel_vvp_axi_master.sv"                                                
    dict set design_files "intel_vvp_clipper_scheduler.sv"                                                "$QSYS_SIMDIR/../intel_vvp_clipper_scheduler_2451/sim/synopsys/src_hdl/intel_vvp_clipper_scheduler.sv"                                 
    dict set design_files "intel_vvp_shift_mux.sv"                                                        "$QSYS_SIMDIR/../intel_vvp_clipper_algo_comp_2451/sim/synopsys/intel_vvp_shift_mux.sv"                                                 
    dict set design_files "intel_vvp_axi_zero_pad.sv"                                                     "$QSYS_SIMDIR/../intel_vvp_clipper_algo_comp_2451/sim/synopsys/intel_vvp_axi_zero_pad.sv"                                              
    dict set design_files "intel_vvp_axi_zero_strip.sv"                                                   "$QSYS_SIMDIR/../intel_vvp_clipper_algo_comp_2451/sim/synopsys/intel_vvp_axi_zero_strip.sv"                                            
    dict set design_files "intel_vvp_axi_pipeline_stage.sv"                                               "$QSYS_SIMDIR/../intel_vvp_clipper_algo_comp_2451/sim/synopsys/intel_vvp_axi_pipeline_stage.sv"                                        
    dict set design_files "intel_vvp_axi_master.sv"                                                       "$QSYS_SIMDIR/../intel_vvp_clipper_algo_comp_2451/sim/synopsys/intel_vvp_axi_master.sv"                                                
    dict set design_files "intel_vvp_clipper_algo_comp_front.sv"                                          "$QSYS_SIMDIR/../intel_vvp_clipper_algo_comp_2451/sim/synopsys/src_hdl/intel_vvp_clipper_algo_comp_front.sv"                           
    dict set design_files "intel_vvp_clipper_algo_comp_back.sv"                                           "$QSYS_SIMDIR/../intel_vvp_clipper_algo_comp_2451/sim/synopsys/src_hdl/intel_vvp_clipper_algo_comp_back.sv"                            
    dict set design_files "intel_vvp_clipper_algo_comp.sv"                                                "$QSYS_SIMDIR/../intel_vvp_clipper_algo_comp_2451/sim/synopsys/src_hdl/intel_vvp_clipper_algo_comp.sv"                                 
    dict set design_files "intel_vvp_reset_bridge.sv"                                                     "$QSYS_SIMDIR/../intel_vvp_reset_bridge_2440/sim/synopsys/src_hdl/intel_vvp_reset_bridge.sv"                                           
    dict set design_files "intel_vvp_ro_reg_servicer.sv"                                                  "$QSYS_SIMDIR/../intel_vvp_ro_reg_servicer_2441/sim/synopsys/src_hdl/intel_vvp_ro_reg_servicer.sv"                                     
    dict set design_files "clipper_ip_intel_vvp_clipper_0_intel_vvp_ro_reg_servicer_2441_nuyi3qi.sv"      "$QSYS_SIMDIR/../intel_vvp_ro_reg_servicer_2441/sim/clipper_ip_intel_vvp_clipper_0_intel_vvp_ro_reg_servicer_2441_nuyi3qi.sv"          
    dict set design_files "intel_vvp_mm_agent_reset_hold.sv"                                              "$QSYS_SIMDIR/../intel_vvp_mm_agent_reset_hold_2440/sim/synopsys/src_hdl/intel_vvp_mm_agent_reset_hold.sv"                             
    dict set design_files "clipper_ip_intel_vvp_clipper_0_altera_merlin_master_translator_193_lgcew2q.sv" "$QSYS_SIMDIR/../altera_merlin_master_translator_193/sim/clipper_ip_intel_vvp_clipper_0_altera_merlin_master_translator_193_lgcew2q.sv"
    dict set design_files "clipper_ip_intel_vvp_clipper_0_altera_merlin_slave_translator_191_xg7rzxi.sv"  "$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/clipper_ip_intel_vvp_clipper_0_altera_merlin_slave_translator_191_xg7rzxi.sv"  
    dict set design_files "clipper_ip_intel_vvp_clipper_0_altera_mm_interconnect_1920_epi4vay.v"          "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/clipper_ip_intel_vvp_clipper_0_altera_mm_interconnect_1920_epi4vay.v"                 
    dict set design_files "clipper_ip_intel_vvp_clipper_0_intel_vvp_slave_front_end_2441_bjsqhuy.v"       "$QSYS_SIMDIR/../intel_vvp_slave_front_end_2441/sim/clipper_ip_intel_vvp_clipper_0_intel_vvp_slave_front_end_2441_bjsqhuy.v"           
    dict set design_files "clipper_ip_intel_vvp_clipper_0_altera_mm_interconnect_1920_vibtxqa.v"          "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/clipper_ip_intel_vvp_clipper_0_altera_mm_interconnect_1920_vibtxqa.v"                 
    dict set design_files "clipper_ip_intel_vvp_clipper_0_intel_vvp_clipper_2451_czyt47i.v"               "$QSYS_SIMDIR/../intel_vvp_clipper_2451/sim/clipper_ip_intel_vvp_clipper_0_intel_vvp_clipper_2451_czyt47i.v"                           
    dict set design_files "clipper_ip_intel_vvp_clipper_0.v"                                              "$QSYS_SIMDIR/clipper_ip_intel_vvp_clipper_0.v"                                                                                        
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
