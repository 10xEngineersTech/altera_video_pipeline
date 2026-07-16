import subprocess
import os
import sys

# 1. Receive the isDebugging value from command line arguments
# The main GUI passes str(is_debugging), which is "True" or "False"
is_debug = False
if len(sys.argv) > 1:
    is_debug = sys.argv[1] == "True"

# Tool install paths come from the environment (export these in ~/.bashrc so
# moving to another machine only means editing bashrc, not this script).
# Fallbacks keep the current setup working if the vars are not exported.
QUARTUS_INSTALL_DIR = os.environ.get(
    "QUARTUS_INSTALL_DIR", "/mnt/ssd2/Quartus_25_1_1_Setup_Installation/quartus"
)
# Use the QuestaSim (FE) that ships with Quartus 25.1.1 (questa_fse).
QUESTASIM_DIR = os.environ.get(
    "QUESTASIM_DIR", "/mnt/ssd2/Quartus_25_1_1_Setup_Installation/questa_fse"
)

# Call vsim explicitly from QUESTASIM_DIR so the app is not affected by whatever
# other vsim happens to be first on PATH. Falls back to a bare "vsim" (PATH).
vsim_bin = os.path.join(QUESTASIM_DIR, "bin", "vsim")
if not os.path.exists(vsim_bin):
    vsim_bin = "vsim"

# 2. Define your paths and commands
sim_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "platform", "pipeline", "sim", "mentor")
do_file_path = os.path.join(sim_path, "run_sim.do")

# Logic for automatic quitting if in background mode
quit_command = "" if is_debug else "quit -f"

tcl_commands = f"""
# Move to sim directory
cd {sim_path}

# Setup and Compile IP
set QUARTUS_INSTALL_DIR {QUARTUS_INSTALL_DIR}
# 25.1.1 scatters the sim-lib sources; use the stitched dir built by setup_sim_libs.sh
set QUARTUS_SIM_LIB_DIR {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'sim_libs_c10gx')}
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

# Add Waves (only useful if GUI opens, but harmless in command line)
add wave /tb/dut/*
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
    my_env["QUESTASIM_DIR"] = QUESTASIM_DIR
    
    subprocess.run([vsim_bin, mode_flag, "-do", do_file_path], check=True, env=my_env)

except FileNotFoundError:
    print(f"Error: vsim not found ({vsim_bin}). Check QUESTASIM_DIR / PATH.")
except subprocess.CalledProcessError as e:
    print(f"Simulation failed with exit code {e.returncode}")
