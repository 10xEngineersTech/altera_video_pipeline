
# Move to sim directory
cd {/home/izaan-10xe/altera_video_pipeline (copy)/Integrated_design/app/../platform/pipeline/sim/mentor}

# Setup and Compile IP
set QUARTUS_INSTALL_DIR {/home/izaan-10xe/altera_pro/25.1.1/quartus}
source msim_setup.tcl

# DPI required by the io96b EMIF model (see runProject.py notes)
vlog -sv /home/izaan-10xe/altera_pro/25.1.1/quartus/eda/sim_lib/simsf_dpi.cpp

# Compile IP
com

# Compile RTL and TB
# Paths are Tcl-brace-quoted: the containing folder can legally have spaces/
# parens in its name (e.g. "altera_video_pipeline (copy)"), which otherwise
# splits an unquoted path into multiple words and breaks every command that
# takes a single path argument (cd, vlog, ...).
vlog {/home/izaan-10xe/altera_video_pipeline (copy)/Integrated_design/app/../rtl/tb.v}
vlog {/home/izaan-10xe/altera_video_pipeline (copy)/Integrated_design/app/../rtl/top.v}
vlog {/home/izaan-10xe/altera_video_pipeline (copy)/Integrated_design/app/../rtl/make_file.v}
vlog {/home/izaan-10xe/altera_video_pipeline (copy)/Integrated_design/app/../rtl/controller.v}

# Elaborate
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {-voptargs="+acc" -suppress 7041 -suppress 7033}
elab_debug

# Waves skipped: headless run. Set FRC_WAVES=1 to force them on.

# Run simulation
run -all

# Exit if not in debug mode
quit -f
