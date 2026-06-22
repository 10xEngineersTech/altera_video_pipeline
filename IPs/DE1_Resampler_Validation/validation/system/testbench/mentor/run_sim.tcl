# run_sim.tcl – non-interactive compile + simulate
# Sourced from the mentor/ directory by:
#   vsim -c -do "cd <mentor_dir>; source run_sim.tcl"

set QSYS_SIMDIR     "./../"
set QUARTUS_INSTALL_DIR "/mnt/ssd2/Quartus13Web/quartus/"
set TOP_LEVEL_NAME  "system_tb"

# ---- libraries ----
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib ./libraries/
ensure_lib ./libraries/work/
vmap work     ./libraries/work/
vmap work_lib ./libraries/work/

if { ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] } {
  foreach lib { altera_ver lpm_ver sgate_ver altera_mf_ver cycloneii_ver altera_lnsim_ver } {
    ensure_lib ./libraries/$lib/
    vmap $lib  ./libraries/$lib/
  }
  vlog     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v" -work altera_ver
  vlog     "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"          -work lpm_ver
  vlog     "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"             -work sgate_ver
  vlog     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"         -work altera_mf_ver
  vlog -sv "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"     -work altera_lnsim_ver
  vlog     "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneii_atoms.v"   -work cycloneii_ver
}

foreach lib { altera_avalon_vip_pkgs_lib rst_controller alt_vip_crs_0 alt_vip_tpg_0 system_inst_reset_bfm system_inst_clk_bfm system_inst } {
  ensure_lib ./libraries/$lib/
  vmap $lib  ./libraries/$lib/
}

# ---- copy hex files ----
file copy -force $QSYS_SIMDIR/system_tb/simulation/submodules/tta_x_blank_mem.hex ./

# ---- compile ----
vlog -sv "$QSYS_SIMDIR/system_tb/simulation/submodules/verbosity_pkg.sv"                                            -work altera_avalon_vip_pkgs_lib
vlog     "$QSYS_SIMDIR/system_tb/simulation/submodules/altera_reset_controller.v"                                   -work rst_controller
vlog     "$QSYS_SIMDIR/system_tb/simulation/submodules/altera_reset_synchronizer.v"                                 -work rst_controller
vlog     "$QSYS_SIMDIR/system_tb/simulation/submodules/system_alt_vip_crs_0.vo"                                     -work alt_vip_crs_0
vlog     "$QSYS_SIMDIR/system_tb/simulation/submodules/system_alt_vip_tpg_0.vo"                                     -work alt_vip_tpg_0
vlog -sv "$QSYS_SIMDIR/system_tb/simulation/submodules/altera_avalon_reset_source.sv" -L altera_avalon_vip_pkgs_lib -work system_inst_reset_bfm
vlog -sv "$QSYS_SIMDIR/system_tb/simulation/submodules/altera_avalon_clock_source.sv" -L altera_avalon_vip_pkgs_lib -work system_inst_clk_bfm
vlog     "$QSYS_SIMDIR/system_tb/simulation/submodules/system.v"                                                    -work system_inst
vlog     "$QSYS_SIMDIR/system_tb/simulation/system_tb.v"

# ---- elaborate ----
vsim -t ps \
  -L work -L work_lib \
  -L altera_avalon_vip_pkgs_lib \
  -L rst_controller \
  -L alt_vip_crs_0 \
  -L alt_vip_tpg_0 \
  -L system_inst_reset_bfm \
  -L system_inst_clk_bfm \
  -L system_inst \
  -L altera_ver -L lpm_ver -L sgate_ver \
  -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver \
  $TOP_LEVEL_NAME

run -all
quit
