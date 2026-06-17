
# (C) 2001-2026 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 13.0sp1 232 linux 2026.06.17.09:28:31

# ----------------------------------------
# vcsmx - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="system_tb"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="/mnt/ssd2/Quartus13Web/quartus/"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_ELAB=1 SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/rst_controller/
mkdir -p ./libraries/alt_vip_crs_0/
mkdir -p ./libraries/alt_vip_tpg_0/
mkdir -p ./libraries/system_inst_reset_bfm/
mkdir -p ./libraries/system_inst_clk_bfm/
mkdir -p ./libraries/system_inst/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/cycloneii_ver/

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/system_tb/simulation/submodules/tta_x_blank_mem.hex ./
fi

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v" -work altera_ver      
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"          -work lpm_ver         
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"             -work sgate_ver       
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"         -work altera_mf_ver   
  vlogan +v2k -sverilog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"     -work altera_lnsim_ver
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneii_atoms.v"   -work cycloneii_ver   
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  vlogan +v2k           "$QSYS_SIMDIR/system_tb/simulation/submodules/altera_reset_controller.v"     -work rst_controller       
  vlogan +v2k           "$QSYS_SIMDIR/system_tb/simulation/submodules/altera_reset_synchronizer.v"   -work rst_controller       
  vlogan +v2k           "$QSYS_SIMDIR/system_tb/simulation/submodules/system_alt_vip_crs_0.vo"       -work alt_vip_crs_0        
  vlogan +v2k           "$QSYS_SIMDIR/system_tb/simulation/submodules/system_alt_vip_tpg_0.vo"       -work alt_vip_tpg_0        
  vlogan +v2k -sverilog "$QSYS_SIMDIR/system_tb/simulation/submodules/verbosity_pkg.sv"              -work system_inst_reset_bfm
  vlogan +v2k -sverilog "$QSYS_SIMDIR/system_tb/simulation/submodules/altera_avalon_reset_source.sv" -work system_inst_reset_bfm
  vlogan +v2k -sverilog "$QSYS_SIMDIR/system_tb/simulation/submodules/verbosity_pkg.sv"              -work system_inst_clk_bfm  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/system_tb/simulation/submodules/altera_avalon_clock_source.sv" -work system_inst_clk_bfm  
  vlogan +v2k           "$QSYS_SIMDIR/system_tb/simulation/submodules/system.v"                      -work system_inst          
  vlogan +v2k           "$QSYS_SIMDIR/system_tb/simulation/system_tb.v"                                                         
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  vcs -lca -t ps $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $USER_DEFINED_SIM_OPTIONS
fi
