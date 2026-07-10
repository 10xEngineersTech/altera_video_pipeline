
namespace eval pipeline_intel_vvp_vfb_0 {
  proc get_design_libraries {} {
    set libraries [dict create]
    dict set libraries altera_common_sv_packages              1
    dict set libraries intel_vvp_reset_sync_2440              1
    dict set libraries intel_vvp_input_interface_bridge_2440  1
    dict set libraries intel_vvp_output_interface_bridge_2440 1
    dict set libraries intel_vvp_vfb_scheduler_2451           1
    dict set libraries intel_vvp_snoop_core_2440              1
    dict set libraries intel_vvp_packet_discard_2440          1
    dict set libraries intel_vvp_packet_writer_2450           1
    dict set libraries intel_vvp_packet_reader_2450           1
    dict set libraries intel_vvp_ro_reg_servicer_2441         1
    dict set libraries altera_merlin_master_translator_193    1
    dict set libraries altera_merlin_slave_translator_191     1
    dict set libraries altera_mm_interconnect_1920            1
    dict set libraries intel_vvp_vfb_2451                     1
    dict set libraries pipeline_intel_vvp_vfb_0               1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    dict set design_files "altera_common_sv_packages::mentor_intel_vvp_common_pkg"  "-makelib altera_common_sv_packages \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/mentor/intel_vvp_common_pkg.sv"]\"   -end"   
    dict set design_files "altera_common_sv_packages::mentor_intel_mtm_common_pkg"  "-makelib altera_common_sv_packages \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/intel_mtm_common_pkg.sv"]\"   -end"            
    dict set design_files "altera_common_sv_packages::mentor_intel_vvp_utility_pkg" "-makelib altera_common_sv_packages \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/intel_vvp_utility_pkg.sv"]\"   -end"           
    dict set design_files "altera_common_sv_packages::mentor_intel_vvp_snoop_pkg"   "-makelib altera_common_sv_packages \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/intel_vvp_snoop_pkg.sv"]\"   -end"             
    dict set design_files "altera_common_sv_packages::mentor_intel_vvp_mpvdma_pkg"  "-makelib altera_common_sv_packages \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/sv_packages/intel_vvp_mpvdma_pkg.sv"]\"   -end"
    dict set design_files "altera_common_sv_packages::mentor_intel_vvp_vfb_pkg"     "-makelib altera_common_sv_packages \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/intel_vvp_vfb_pkg.sv"]\"   -end"               
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    lappend design_files "-makelib intel_vvp_reset_sync_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_reset_sync_2440/sim/mentor/src_hdl/intel_vvp_reset_sync.sv"]\"   -L altera_common_sv_packages -end"                                                     
    lappend design_files "-makelib intel_vvp_input_interface_bridge_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/mentor/intel_vvp_axi_pipeline_stage.sv"]\"   -L altera_common_sv_packages -end"                             
    lappend design_files "-makelib intel_vvp_input_interface_bridge_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/mentor/intel_vvp_axi_master.sv"]\"   -L altera_common_sv_packages -end"                                     
    lappend design_files "-makelib intel_vvp_input_interface_bridge_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_input_interface_bridge_2440/sim/mentor/src_hdl/intel_vvp_input_interface_bridge.sv"]\"   -L altera_common_sv_packages -end"                 
    lappend design_files "-makelib intel_vvp_output_interface_bridge_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/mentor/intel_vvp_axi_pipeline_stage.sv"]\"   -L altera_common_sv_packages -end"                           
    lappend design_files "-makelib intel_vvp_output_interface_bridge_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/mentor/intel_vvp_axi_master.sv"]\"   -L altera_common_sv_packages -end"                                   
    lappend design_files "-makelib intel_vvp_output_interface_bridge_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_output_interface_bridge_2440/sim/mentor/src_hdl/intel_vvp_output_interface_bridge.sv"]\"   -L altera_common_sv_packages -end"              
    lappend design_files "-makelib intel_vvp_vfb_scheduler_2451 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/intel_vvp_pipelined_mux.sv"]\"   -L altera_common_sv_packages -end"                                                    
    lappend design_files "-makelib intel_vvp_vfb_scheduler_2451 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/intel_vvp_common_slave_interface.sv"]\"   -L altera_common_sv_packages -end"                                           
    lappend design_files "-makelib intel_vvp_vfb_scheduler_2451 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/intel_vvp_axi_pipeline_stage.sv"]\"   -L altera_common_sv_packages -end"                                               
    lappend design_files "-makelib intel_vvp_vfb_scheduler_2451 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/src_hdl/intel_vvp_vfb_scheduler_buff_num.sv"]\"   -L altera_common_sv_packages -end"                                   
    lappend design_files "-makelib intel_vvp_vfb_scheduler_2451 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/src_hdl/intel_vvp_vfb_scheduler_wr.sv"]\"   -L altera_common_sv_packages -end"                                         
    lappend design_files "-makelib intel_vvp_vfb_scheduler_2451 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/src_hdl/intel_vvp_vfb_scheduler_rd.sv"]\"   -L altera_common_sv_packages -end"                                         
    lappend design_files "-makelib intel_vvp_vfb_scheduler_2451 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_scheduler_2451/sim/mentor/src_hdl/intel_vvp_vfb_scheduler.sv"]\"   -L altera_common_sv_packages -end"                                            
    lappend design_files "-makelib intel_vvp_snoop_core_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_snoop_core_2440/sim/mentor/intel_vvp_axi_pipeline_stage.sv"]\"   -L altera_common_sv_packages -end"                                                     
    lappend design_files "-makelib intel_vvp_snoop_core_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_snoop_core_2440/sim/mentor/intel_vvp_axi_master.sv"]\"   -L altera_common_sv_packages -end"                                                             
    lappend design_files "-makelib intel_vvp_snoop_core_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_snoop_core_2440/sim/mentor/src_hdl/intel_vvp_snoop_core.sv"]\"   -L altera_common_sv_packages -end"                                                     
    lappend design_files "-makelib intel_vvp_packet_discard_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_discard_2440/sim/mentor/intel_vvp_axi_pipeline_stage.sv"]\"   -L altera_common_sv_packages -end"                                             
    lappend design_files "-makelib intel_vvp_packet_discard_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_discard_2440/sim/mentor/intel_vvp_axi_master.sv"]\"   -L altera_common_sv_packages -end"                                                     
    lappend design_files "-makelib intel_vvp_packet_discard_2440 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_discard_2440/sim/mentor/src_hdl/intel_vvp_packet_discard.sv"]\"   -L altera_common_sv_packages -end"                                         
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_shift_mux.sv"]\"   -L altera_common_sv_packages -end"                                                        
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_pack_simple.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_unpack_simple.sv"]\"   -L altera_common_sv_packages -end"                                                    
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_pack_hard.sv"]\"   -L altera_common_sv_packages -end"                                                        
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_unpack_hard.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_axi_zero_pad.sv"]\"   -L altera_common_sv_packages -end"                                                     
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_axi_zero_strip.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_axi_pipeline_stage.sv"]\"   -L altera_common_sv_packages -end"                                               
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_axi_master.sv"]\"   -L altera_common_sv_packages -end"                                                       
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_binary_to_gray.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_gray_to_binary.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_counter_clock_crosser.sv"]\"   -L altera_common_sv_packages -end"                                            
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_fifo_input.sv"]\"   -L altera_common_sv_packages -end"                                                       
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_fifo_output.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_common_fifo.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_mpvdma_cmd_split.sv"]\"   -L altera_common_sv_packages -end"                                                 
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/intel_vvp_mpvdma_resp_cc.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/src_hdl/intel_vvp_packet_writer_fifo.sv"]\"   -L altera_common_sv_packages -end"                                       
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/src_hdl/intel_vvp_packet_writer_streamer.sv"]\"   -L altera_common_sv_packages -end"                                   
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/src_hdl/intel_vvp_packet_writer_master.sv"]\"   -L altera_common_sv_packages -end"                                     
    lappend design_files "-makelib intel_vvp_packet_writer_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_writer_2450/sim/mentor/src_hdl/intel_vvp_packet_writer.sv"]\"   -L altera_common_sv_packages -end"                                            
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_shift_mux.sv"]\"   -L altera_common_sv_packages -end"                                                        
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_pack_simple.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_unpack_simple.sv"]\"   -L altera_common_sv_packages -end"                                                    
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_pack_hard.sv"]\"   -L altera_common_sv_packages -end"                                                        
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_unpack_hard.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_axi_zero_pad.sv"]\"   -L altera_common_sv_packages -end"                                                     
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_axi_zero_strip.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_axi_pipeline_stage.sv"]\"   -L altera_common_sv_packages -end"                                               
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_axi_master.sv"]\"   -L altera_common_sv_packages -end"                                                       
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_binary_to_gray.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_gray_to_binary.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_counter_clock_crosser.sv"]\"   -L altera_common_sv_packages -end"                                            
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_fifo_input.sv"]\"   -L altera_common_sv_packages -end"                                                       
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_fifo_output.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_common_fifo.sv"]\"   -L altera_common_sv_packages -end"                                                      
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_mpvdma_cmd_split.sv"]\"   -L altera_common_sv_packages -end"                                                 
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/intel_vvp_mpvdma_resp_cc.sv"]\"   -L altera_common_sv_packages -end"                                                   
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/src_hdl/intel_vvp_packet_reader_fifo.sv"]\"   -L altera_common_sv_packages -end"                                       
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/src_hdl/intel_vvp_packet_reader_master.sv"]\"   -L altera_common_sv_packages -end"                                     
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/src_hdl/intel_vvp_packet_reader_streamer.sv"]\"   -L altera_common_sv_packages -end"                                   
    lappend design_files "-makelib intel_vvp_packet_reader_2450 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_packet_reader_2450/sim/mentor/src_hdl/intel_vvp_packet_reader.sv"]\"   -L altera_common_sv_packages -end"                                            
    lappend design_files "-makelib intel_vvp_ro_reg_servicer_2441 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_ro_reg_servicer_2441/sim/mentor/src_hdl/intel_vvp_ro_reg_servicer.sv"]\"   -L altera_common_sv_packages -end"                                      
    lappend design_files "-makelib intel_vvp_ro_reg_servicer_2441 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_ro_reg_servicer_2441/sim/pipeline_intel_vvp_vfb_0_intel_vvp_ro_reg_servicer_2441_wkfgrla.sv"]\"   -L altera_common_sv_packages -end"               
    lappend design_files "-makelib altera_merlin_master_translator_193 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_translator_193/sim/pipeline_intel_vvp_vfb_0_altera_merlin_master_translator_193_lgcew2q.sv"]\"   -L altera_common_sv_packages -end"
    lappend design_files "-makelib altera_merlin_slave_translator_191 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/pipeline_intel_vvp_vfb_0_altera_merlin_slave_translator_191_xg7rzxi.sv"]\"   -L altera_common_sv_packages -end"   
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/pipeline_intel_vvp_vfb_0_altera_mm_interconnect_1920_jcbczky.v"]\"   -end"                                                      
    lappend design_files "-makelib intel_vvp_vfb_2451 \"[normalize_path "$QSYS_SIMDIR/../intel_vvp_vfb_2451/sim/pipeline_intel_vvp_vfb_0_intel_vvp_vfb_2451_pdxh2ti.v"]\"   -end"                                                                                 
    lappend design_files "-makelib pipeline_intel_vvp_vfb_0 \"[normalize_path "$QSYS_SIMDIR/pipeline_intel_vvp_vfb_0.v"]\"   -end"                                                                                                                                
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
