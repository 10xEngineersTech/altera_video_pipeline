source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_mm_bridge_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_tpg_1/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_clock_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_mem_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_mixer_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_reset_in/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_emif_0/sim/common/modelsim_files.tcl]
source [file join [file dirname [info script]] ./../../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/common/modelsim_files.tcl]

namespace eval pipeline {
  proc get_design_libraries {} {
    set libraries [dict create]
    set libraries [dict merge $libraries [pipeline_mm_bridge_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_crs_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_vfb_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_tpg_1::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_tpg_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_clock_in::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_csc_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_clipper_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_mem_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_mixer_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_2::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_1::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_scaler_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_reset_in::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_emif_0::get_design_libraries]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_dil_0::get_design_libraries]]
    dict set libraries altera_merlin_master_translator_193  1
    dict set libraries altera_merlin_axi_translator_1981    1
    dict set libraries altera_merlin_master_agent_1940      1
    dict set libraries altera_avalon_sc_fifo_1932           1
    dict set libraries altera_merlin_axi_slave_ni_19122     1
    dict set libraries altera_avalon_st_pipeline_stage_1930 1
    dict set libraries altera_merlin_router_1921            1
    dict set libraries altera_merlin_traffic_limiter_1921   1
    dict set libraries altera_merlin_demultiplexer_1921     1
    dict set libraries altera_merlin_multiplexer_1922       1
    dict set libraries altera_mm_interconnect_1920          1
    dict set libraries altera_merlin_slave_translator_191   1
    dict set libraries altera_merlin_slave_agent_1930       1
    dict set libraries altera_reset_controller_1924         1
    dict set libraries pipeline                             1
    return $libraries
  }
  
  proc get_memory_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set memory_files [list]
    set memory_files [concat $memory_files [pipeline_mm_bridge_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mm_bridge_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_crs_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_vfb_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_tpg_1::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_tpg_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_clock_in::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_csc_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_clipper_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_mem_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mem_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_mixer_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_mixer_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_protocol_conv_2::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_protocol_conv_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_protocol_conv_1::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_scaler_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_reset_in::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_emif_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_emif_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set memory_files [concat $memory_files [pipeline_intel_vvp_dil_0::get_memory_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    return $memory_files
  }
  
  proc get_common_design_files {QSYS_SIMDIR} {
    set design_files [dict create]
    set design_files [dict merge $design_files [pipeline_mm_bridge_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mm_bridge_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_crs_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_vfb_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_tpg_1::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_1/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_tpg_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_clock_in::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_clock_in/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_csc_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_clipper_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_mem_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mem_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_mixer_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_mixer_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_protocol_conv_2::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_protocol_conv_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_protocol_conv_1::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_scaler_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_reset_in::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_reset_in/sim/"]]
    set design_files [dict merge $design_files [pipeline_emif_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_emif_0/sim/"]]
    set design_files [dict merge $design_files [pipeline_intel_vvp_dil_0::get_common_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/"]]
    return $design_files
  }
  
  proc get_design_files {QSYS_SIMDIR QUARTUS_INSTALL_DIR} {
    set design_files [list]
    set design_files [concat $design_files [pipeline_mm_bridge_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mm_bridge_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_crs_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_vfb_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_tpg_1::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_tpg_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_clock_in::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_clock_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_csc_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_clipper_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_mem_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mem_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_mixer_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_mixer_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_protocol_conv_2::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_protocol_conv_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_protocol_conv_1::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_scaler_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_reset_in::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_reset_in/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_emif_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_emif_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    set design_files [concat $design_files [pipeline_intel_vvp_dil_0::get_design_files "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/" "$QUARTUS_INSTALL_DIR"]]
    lappend design_files "-makelib altera_merlin_master_translator_193 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_translator_193/sim/pipeline_altera_merlin_master_translator_193_lgcew2q.sv"]\"   -end"                      
    lappend design_files "-makelib altera_merlin_axi_translator_1981 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_translator_1981/sim/pipeline_altera_merlin_axi_translator_1981_d6vgxmy.sv"]\"   -end"                            
    lappend design_files "-makelib altera_merlin_master_agent_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_agent_1940/sim/pipeline_altera_merlin_master_agent_1940_pqs4u4y.sv"]\"   -end"                                  
    lappend design_files "-makelib altera_avalon_sc_fifo_1932 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_1932/sim/pipeline_altera_avalon_sc_fifo_1932_22gxxgi.v"]\"   -end"                                                  
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/pipeline_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_19122_cmr7m5y.v"]\"   -end"          
    lappend design_files "-makelib altera_avalon_st_pipeline_stage_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/pipeline_altera_avalon_st_pipeline_stage_1930_oiupeiq.sv"]\"   -end"                   
    lappend design_files "-makelib altera_avalon_st_pipeline_stage_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_st_pipeline_stage_1930/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                           
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/pipeline_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19122_ywrtanq.v"]\"   -end"
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/pipeline_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19122_rjx2lky.v"]\"   -end"
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/pipeline_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_19122_todvwcq.v"]\"   -end"
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/altera_merlin_burst_uncompressor.sv"]\"   -end"                                                
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/altera_merlin_address_alignment.sv"]\"   -end"                                                 
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/compare_eq.sv"]\"   -end"                                                                      
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/rd_response_mem_nyynhlq.sv"]\"   -end"                                                         
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/rd_comp_sel_nyynhlq.sv"]\"   -end"                                                             
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/rd_pri_mux_nyynhlq.sv"]\"   -end"                                                              
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/rd_sipo_plus_nyynhlq.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/wr_response_mem_nyynhlq.sv"]\"   -end"                                                         
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/wr_comp_sel_nyynhlq.sv"]\"   -end"                                                             
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/wr_pri_mux_nyynhlq.sv"]\"   -end"                                                              
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/wr_sipo_plus_nyynhlq.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_axi_slave_ni_19122 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_axi_slave_ni_19122/sim/pipeline_altera_merlin_axi_slave_ni_19122_nyynhlq.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_ejy33ty.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_ku4bwcy.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/pipeline_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_pplxesy.v"]\"   -end"    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"   -end"                                                
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                               
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/pipeline_altera_merlin_traffic_limiter_1921_yeyvuii.sv"]\"   -end"                         
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/pipeline_altera_merlin_demultiplexer_1921_segvfsa.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/pipeline_altera_merlin_demultiplexer_1921_h574mtq.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/pipeline_altera_merlin_multiplexer_1922_anwbaiy.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/pipeline_altera_merlin_multiplexer_1922_h5ygz5q.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/pipeline_altera_mm_interconnect_1920_a3rbxji.v"]\"   -end"                                               
    lappend design_files "-makelib altera_merlin_slave_translator_191 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_translator_191/sim/pipeline_altera_merlin_slave_translator_191_xg7rzxi.sv"]\"   -end"                         
    lappend design_files "-makelib altera_merlin_master_agent_1940 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_master_agent_1940/sim/pipeline_altera_merlin_master_agent_1940_r3ep6da.sv"]\"   -end"                                  
    lappend design_files "-makelib altera_merlin_slave_agent_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/pipeline_altera_merlin_slave_agent_1930_jxauz3i.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_slave_agent_1930 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_slave_agent_1930/sim/altera_merlin_burst_uncompressor.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_avalon_sc_fifo_1932 \"[normalize_path "$QSYS_SIMDIR/../altera_avalon_sc_fifo_1932/sim/pipeline_altera_avalon_sc_fifo_1932_onpcouq.v"]\"   -end"                                                  
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_7myouha.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_router_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_router_1921/sim/pipeline_altera_merlin_router_1921_2k5lrca.sv"]\"   -end"                                                    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/pipeline_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_xk7jela.v"]\"   -end"    
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_merlin_reorder_memory.sv"]\"   -end"                                                
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/altera_avalon_st_pipeline_base.v"]\"   -end"                                               
    lappend design_files "-makelib altera_merlin_traffic_limiter_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_traffic_limiter_1921/sim/pipeline_altera_merlin_traffic_limiter_1921_3mmasty.sv"]\"   -end"                         
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/pipeline_altera_merlin_demultiplexer_1921_xszfdlq.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/pipeline_altera_merlin_multiplexer_1922_kejbziy.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_merlin_demultiplexer_1921 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_demultiplexer_1921/sim/pipeline_altera_merlin_demultiplexer_1921_zxmzkgi.sv"]\"   -end"                               
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/pipeline_altera_merlin_multiplexer_1922_72syt5i.sv"]\"   -end"                                     
    lappend design_files "-makelib altera_merlin_multiplexer_1922 \"[normalize_path "$QSYS_SIMDIR/../altera_merlin_multiplexer_1922/sim/altera_merlin_arbitrator.sv"]\"   -end"                                                            
    lappend design_files "-makelib altera_mm_interconnect_1920 \"[normalize_path "$QSYS_SIMDIR/../altera_mm_interconnect_1920/sim/pipeline_altera_mm_interconnect_1920_lzj4ora.v"]\"   -end"                                               
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_controller.v"]\"   -end"                                                                  
    lappend design_files "-makelib altera_reset_controller_1924 \"[normalize_path "$QSYS_SIMDIR/../altera_reset_controller_1924/sim/altera_reset_synchronizer.v"]\"   -end"                                                                
    lappend design_files "-makelib pipeline \"[normalize_path "$QSYS_SIMDIR/pipeline.v"]\"   -end"                                                                                                                                         
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
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_mm_bridge_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_crs_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_vfb_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_tpg_1::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_tpg_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_clock_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_csc_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_clipper_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_mem_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_mixer_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_protocol_conv_2::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_protocol_conv_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_protocol_conv_1::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_scaler_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_reset_in::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_emif_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    append ELAB_OPTIONS [get_non_duplicate_elab_option $ELAB_OPTIONS [pipeline_intel_vvp_dil_0::get_elab_options $SIMULATOR_TOOL_BITNESS]]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $ELAB_OPTIONS
  }
  
  
  proc get_sim_options {SIMULATOR_TOOL_BITNESS} {
    set SIM_OPTIONS ""
    append SIM_OPTIONS [pipeline_mm_bridge_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_crs_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_vfb_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_tpg_1::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_tpg_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_clock_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_csc_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_clipper_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_mem_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_mixer_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_protocol_conv_2::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_protocol_conv_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_protocol_conv_1::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_scaler_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_reset_in::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_emif_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    append SIM_OPTIONS [pipeline_intel_vvp_dil_0::get_sim_options $SIMULATOR_TOOL_BITNESS]
    if ![ string match "bit_64" $SIMULATOR_TOOL_BITNESS ] {
    } else {
    }
    return $SIM_OPTIONS
  }
  
  
  proc get_env_variables {SIMULATOR_TOOL_BITNESS} {
    set ENV_VARIABLES [dict create]
    set LD_LIBRARY_PATH [dict create]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_mm_bridge_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_crs_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_vfb_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_tpg_1::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_tpg_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_clock_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_csc_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_clipper_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_mem_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_mixer_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_protocol_conv_2::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_protocol_conv_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_protocol_conv_1::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_scaler_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_reset_in::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_emif_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
    set LD_LIBRARY_PATH [dict merge $LD_LIBRARY_PATH [dict get [pipeline_intel_vvp_dil_0::get_env_variables $SIMULATOR_TOOL_BITNESS] "LD_LIBRARY_PATH"]]
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
    set libraries [dict merge $libraries [pipeline_mm_bridge_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mm_bridge_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_crs_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_crs_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_vfb_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_vfb_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_tpg_1::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_1/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_tpg_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_tpg_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_clock_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_clock_in/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_csc_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_csc_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_clipper_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_clipper_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_mem_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_mem_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_mixer_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_mixer_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_2::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_2/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_protocol_conv_1::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_protocol_conv_1/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_scaler_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_scaler_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_reset_in::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_reset_in/sim/"]]
    set libraries [dict merge $libraries [pipeline_emif_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_emif_0/sim/"]]
    set libraries [dict merge $libraries [pipeline_intel_vvp_dil_0::get_dpi_libraries "$QSYS_SIMDIR/../../ip/pipeline/pipeline_intel_vvp_dil_0/sim/"]]
    
    return $libraries
  }
  
}
