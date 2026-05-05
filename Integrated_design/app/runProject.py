import subprocess
import os

# 1. Define your paths and commands
sim_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "platform", "pipeline", "sim", "mentor")
do_file_path = os.path.join(sim_path, "run_sim.do")

tcl_commands = f"""
# Move to sim directory
cd {sim_path}

# Setup and Compile IP
source msim_setup.tcl

# Compile Device Libraries
dev_com

# Compile IP
com

# Compile RTL and TB
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'tb.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'top.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'make_file.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'controller.v')}

# Elaborate
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {{-voptargs="+acc"}}
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
"""

# 2. Write the DO file
with open(do_file_path, "w") as f:
    f.write(tcl_commands)

# 3. Execute Questa
# -gui opens the window, -do executes the script
try:
    print("Launching QuestaSim...")
    subprocess.run(["vsim", "-c", "-do", do_file_path], check=True)
except FileNotFoundError:
    print("Error: 'vsim' not found in PATH. Make sure Questa is sourced.")
except subprocess.CalledProcessError as e:
    print(f"Simulation failed with exit code {e.returncode}")
