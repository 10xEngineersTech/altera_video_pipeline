import subprocess
import os
import sys

# 1. Receive the isDebugging value from command line arguments
# The main GUI passes str(is_debugging), which is "True" or "False"
is_debug = False
if len(sys.argv) > 1:
    is_debug = sys.argv[1] == "True"

# 2. Define your paths and commands
sim_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "platform", "pipeline", "sim", "mentor")
do_file_path = os.path.join(sim_path, "run_sim.do")

# Logic for automatic quitting if in background mode
quit_command = "" if is_debug else "quit -f"

tcl_commands = f"""
# Move to sim directory
cd {sim_path}

# Setup and Compile IP
set QUARTUS_INSTALL_DIR /mnt/ssd2/Quartus_Setup_Installation/quartus
source msim_setup.tcl

# Compile Device Libraries
dev_com

# Compile IP
com

# Compile RTL and TB
#vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'mm_bridge.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'tb.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'top.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'make_file.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'controller.v')}

# Elaborate
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {{-voptargs="+acc"}}
elab_debug

# Add Waves (only useful if GUI opens, but harmless in command line)
add wave /tb/dut/u_pipeline/intel_*
add wave -r /*

# Run simulation
run -all

# Exit if not in debug mode
{quit_command}
"""

# 3. Write the DO file
with open(do_file_path, "w") as f:
    f.write(tcl_commands)

# 4. Execute Questa
# If is_debug is True: Use "-gui"
# If is_debug is False: Use "-c" (Command Line / Console mode)
mode_flag = "-gui" if is_debug else "-c"

try:
    if is_debug:
        print("Launching QuestaSim GUI Mode...")
    else:
        print("Running Simulation in Background (Command Line Mode)...")
        
    # Define environment and config
    my_env = os.environ.copy()
    my_env["QUESTASIM_DIR"] = "/mnt/ssd2/Quartus21/questasim/linux_x86_64"
    
    subprocess.run(["vsim", mode_flag, "-do", do_file_path], check=True, env=my_env)
    
except FileNotFoundError:
    print("Error: 'vsim' not found in PATH. Make sure Questa is sourced.")
except subprocess.CalledProcessError as e:
    print(f"Simulation failed with exit code {e.returncode}")
