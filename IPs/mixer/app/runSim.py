import subprocess
import os
import sys

# Usage: python3 runSim.py [True|False]
# True  -> open Questa GUI (debug)
# False -> run headless (default)
is_debug = False
if len(sys.argv) > 1:
    is_debug = sys.argv[1] == "True"

base_dir = os.path.dirname(os.path.abspath(__file__))
sim_path = os.path.join(base_dir, "..", "system", "sim", "mentor")
do_file_path = os.path.join(sim_path, "run_sim.do")
rtl_dir = os.path.join(base_dir, "..", "rtl")

quit_command = "" if is_debug else "quit -f"

tcl_commands = f"""
# Move to sim directory
cd {sim_path}

# Setup and Compile IP
set QUARTUS_INSTALL_DIR $::env(QUARTUS_INSTALL_DIR)
source msim_setup.tcl

# Compile Device Libraries
dev_com

# Compile IP
com

# Compile RTL and TB
vlog {os.path.join(rtl_dir, 'controller.v')}
vlog {os.path.join(rtl_dir, 'make_file.v')}
vlog {os.path.join(rtl_dir, 'top.v')}
vlog {os.path.join(rtl_dir, 'tb.v')}

# Elaborate
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {{-voptargs="+acc"}}
elab_debug

# Run simulation
run -all

{quit_command}
"""

with open(do_file_path, "w") as f:
    f.write(tcl_commands)

mode_flag = "-gui" if is_debug else "-c"

my_env = os.environ.copy()

# Resolve vsim: use PATH if available, otherwise fall back to QUESTASIM_INSTALL_DIR
import shutil
vsim_cmd = shutil.which("vsim")
if vsim_cmd is None:
    questa_dir = my_env.get("QUESTASIM_INSTALL_DIR")
    if questa_dir:
        candidate = os.path.join(questa_dir, "bin", "vsim")
        if os.path.isfile(candidate):
            vsim_cmd = candidate
            my_env["PATH"] = os.path.join(questa_dir, "bin") + os.pathsep + my_env.get("PATH", "")

try:
    if vsim_cmd is None:
        raise FileNotFoundError
    subprocess.run([vsim_cmd, mode_flag, "-do", do_file_path], check=True, env=my_env)
except FileNotFoundError:
    print("Error: 'vsim' not found. Add Questa to PATH or set QUESTASIM_INSTALL_DIR.")
except subprocess.CalledProcessError as e:
    print(f"Simulation failed with exit code {e.returncode}")
