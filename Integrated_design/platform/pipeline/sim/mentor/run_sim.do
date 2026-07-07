
# Move to sim directory
cd /home/lpt-10xe/altera_projects/altera_video_pipeline/Integrated_design/app/../platform/pipeline/sim/mentor

# Setup and Compile IP
set QUARTUS_INSTALL_DIR /home/lpt-10xe/altera_pro/25.1.1/quartus
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

# Elaborate
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {-voptargs="+acc"}
elab_debug

# Add Waves (only useful if GUI opens, but harmless in command line)
add wave /tb/dut/u_pipeline/intel_*
add wave -r /*

# Run simulation
run -all

# Exit if not in debug mode
quit -f
