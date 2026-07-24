
# Move to sim directory
cd /home/lpt-10xe/altera_projects/altera_video_pipeline/Integrated_design/app/../platform/pipeline/sim/mentor

# Setup and Compile IP
set QUARTUS_INSTALL_DIR /home/lpt-10xe/altera_pro/25.1.1/quartus
# 25.1.1 scatters the sim-lib sources; use the stitched dir built by setup_sim_libs.sh
set QUARTUS_SIM_LIB_DIR /home/lpt-10xe/altera_projects/altera_video_pipeline/Integrated_design/app/../sim_libs_c10gx
source msim_setup.tcl

# Compile Device Libraries
dev_com

# Compile IP
com

# Compile RTL and TB
vlog /home/lpt-10xe/altera_projects/altera_video_pipeline/Integrated_design/app/../rtl/tb.v
vlog /home/lpt-10xe/altera_projects/altera_video_pipeline/Integrated_design/app/../rtl/top.v
vlog /home/lpt-10xe/altera_projects/altera_video_pipeline/Integrated_design/app/../rtl/make_file.v
vlog /home/lpt-10xe/altera_projects/altera_video_pipeline/Integrated_design/app/../rtl/controller.v

# Elaborate (optimized)
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {}
elab

# Run simulation
run -all

# Exit if not in debug mode
quit -f
