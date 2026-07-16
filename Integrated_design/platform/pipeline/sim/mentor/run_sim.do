
# Move to sim directory
cd /mnt/ssd2/hamza/altera_video_pipeline/Integrated_design/app/../platform/pipeline/sim/mentor

# Setup and Compile IP
set QUARTUS_INSTALL_DIR /mnt/ssd2/Quartus_25_1_1_Setup_Installation/quartus
# 25.1.1 scatters the sim-lib sources; use the stitched dir built by setup_sim_libs.sh
set QUARTUS_SIM_LIB_DIR /mnt/ssd2/hamza/altera_video_pipeline/Integrated_design/app/../sim_libs_c10gx
source msim_setup.tcl

# Compile Device Libraries
dev_com

# Compile IP
com

# Compile RTL and TB
vlog /mnt/ssd2/hamza/altera_video_pipeline/Integrated_design/app/../rtl/tb.v
vlog /mnt/ssd2/hamza/altera_video_pipeline/Integrated_design/app/../rtl/top.v
vlog /mnt/ssd2/hamza/altera_video_pipeline/Integrated_design/app/../rtl/make_file.v
vlog /mnt/ssd2/hamza/altera_video_pipeline/Integrated_design/app/../rtl/controller.v

# Elaborate
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {-voptargs="+acc"}
elab_debug

# Add Waves (only useful if GUI opens, but harmless in command line)
add wave /tb/dut/*
add wave -r /*

# Run simulation
run -all

# Exit if not in debug mode
quit -f
