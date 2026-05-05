
# Move to sim directory
cd /mnt/ssd2/hamza/altera_video_pipeline/Integrated_design/app/../platform/pipeline/sim/mentor

# Setup and Compile IP
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

# Add Waves (TPG)
add wave /tb/dut/u_pipeline_inst/intel_vvp_tpg_0_axi4s_vid_out_*
# Add Waves (Clipper)
add wave /tb/dut/u_pipeline_inst/intel_vvp_clipper_0_axi4s_vid_out_*
add wave /tb/dut/u_pipeline_inst/intel_vvp_clipper_0_av_mm_control_agent_*
# Add Waves (Scaler)
add wave /tb/dut/u_pipeline_inst/intel_vvp_scaler_0_av_mm_control_agent_*

# Add everything else and run
add wave -r /*
run -all
