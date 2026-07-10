
# Move to sim directory
cd /home/lpt-10xe/altera_projects/altera_video_pipeline/IPs/mixer/app/../system/sim/mentor

# Setup and Compile IP
set QUARTUS_INSTALL_DIR $::env(QUARTUS_INSTALL_DIR)
source msim_setup.tcl

# Compile Device Libraries
dev_com

# Compile IP
com

# Compile RTL and TB
vlog /home/lpt-10xe/altera_projects/altera_video_pipeline/IPs/mixer/app/../rtl/controller.v
vlog /home/lpt-10xe/altera_projects/altera_video_pipeline/IPs/mixer/app/../rtl/make_file.v
vlog /home/lpt-10xe/altera_projects/altera_video_pipeline/IPs/mixer/app/../rtl/top.v
vlog /home/lpt-10xe/altera_projects/altera_video_pipeline/IPs/mixer/app/../rtl/tb.v

# Elaborate
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {-voptargs="+acc"}
elab_debug

# Run simulation
run -all

quit -f
