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
# Fallbacks point at this machine's install so the app still runs when the GUI
# is launched from a desktop icon / IDE that never sourced ~/.bashrc.
_DEFAULT_QUARTUS = "/home/lpt-10xe/altera_pro/25.1.1/quartus"
QUARTUS_INSTALL_DIR = os.environ.get("QUARTUS_INSTALL_DIR", _DEFAULT_QUARTUS)
# Use the QuestaSim (FE) that ships with Quartus 25.1.1 (questa_fse).
QUESTASIM_DIR = os.environ.get(
    "QUESTASIM_DIR", "/home/lpt-10xe/altera_pro/25.1.1/questa_fse"
)

# The io96b EMIF calibration sim model (SIMSF) aborts at time 0 with
# "Could not find Quartus installation - missing environment variable
# QUARTUS_ROOTDIR" (needed for the FRC/DDR4 path) unless QUARTUS_ROOTDIR points
# at the *quartus* directory: the model resolves $QUARTUS_ROOTDIR/../ip/altera
# and $QUARTUS_ROOTDIR/bin. A common mistake is exporting the SDK root (one
# level too high). Validate the inherited value and fall back to the quartus
# dir (QUARTUS_INSTALL_DIR) so a wrong/missing export self-corrects here.
def _valid_quartus_root(p):
    return bool(p) and os.path.isdir(os.path.join(p, "bin")) \
        and os.path.isdir(os.path.join(p, "..", "ip", "altera"))

QUARTUS_ROOTDIR = os.environ.get("QUARTUS_ROOTDIR", "")
if not _valid_quartus_root(QUARTUS_ROOTDIR):
    QUARTUS_ROOTDIR = QUARTUS_INSTALL_DIR

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

rtl_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl')

# -- Speed knobs (Tier 1) -----------------------------------------------------
# Batch/headless runs elaborate OPTIMIZED (no -voptargs=+acc) and log NO waves:
# with the io96b EMIF/DDR4 model, global +acc (full visibility) and recursive
# wave logging are the two biggest simulator slowdowns. GUI/debug runs keep +acc
# and waves so signals remain inspectable.
if is_debug:
    elab_block = (
        'set USER_DEFINED_ELAB_OPTIONS {-voptargs="+acc"}\n'
        'elab_debug\n\n'
        '# Full-visibility waves for interactive debug\n'
        'add wave /tb/dut/*\n'
        'add wave -r /*'
    )
else:
    elab_block = (
        'set USER_DEFINED_ELAB_OPTIONS {}\n'
        'elab'
    )

# Recompiling the device libs + all IP (dev_com/com, ~20-30 min) is only needed
# once per generation. `export SKIP_IP_COMPILE=1` reuses the existing work libs
# and only re-vlogs the RTL/TB — big turnaround win when iterating on rtl/*.v.
_skip = os.environ.get("SKIP_IP_COMPILE", "").strip().lower() not in ("", "0", "false", "no")
if _skip:
    compile_block = (
        '# SKIP_IP_COMPILE set: reusing precompiled device libs + IP\n'
        '# (run once without it after any qsys-generate / IP change)'
    )
else:
    compile_block = (
        '# Compile Device Libraries\n'
        'dev_com\n\n'
        '# Compile IP\n'
        'com'
    )

tcl_commands = f"""
# Move to sim directory
cd {sim_path}

# Setup and Compile IP
set QUARTUS_INSTALL_DIR {QUARTUS_INSTALL_DIR}
# 25.1.1 scatters the sim-lib sources; use the stitched dir built by setup_sim_libs.sh
set QUARTUS_SIM_LIB_DIR {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'sim_libs_c10gx')}
source msim_setup.tcl

{compile_block}

# Compile RTL and TB
vlog {os.path.join(rtl_dir, 'tb.v')}
vlog {os.path.join(rtl_dir, 'top.v')}
vlog {os.path.join(rtl_dir, 'make_file.v')}
vlog {os.path.join(rtl_dir, 'controller.v')}

# Elaborate ({'debug/+acc' if is_debug else 'optimized'})
set TOP_LEVEL_NAME work.tb
{elab_block}

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
    my_env["QUARTUS_ROOTDIR"] = QUARTUS_ROOTDIR
    my_env["QUARTUS_INSTALL_DIR"] = QUARTUS_INSTALL_DIR
    
    subprocess.run([vsim_bin, mode_flag, "-do", do_file_path], check=True, env=my_env)

except FileNotFoundError:
    print(f"Error: vsim not found ({vsim_bin}). Check QUESTASIM_DIR / PATH.")
except subprocess.CalledProcessError as e:
    print(f"Simulation failed with exit code {e.returncode}")
