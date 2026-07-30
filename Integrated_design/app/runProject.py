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
ACDS_ROOT = "/home/lpt-10xe/altera_pro/25.1.1"

QUARTUS_INSTALL_DIR = os.environ.get(
    "QUARTUS_INSTALL_DIR", os.path.join(ACDS_ROOT, "quartus")
)
# Use the QuestaSim (FE) that ships with Quartus 25.1.1 (questa_fse).
QUESTASIM_DIR = os.environ.get(
    "QUESTASIM_DIR", os.path.join(ACDS_ROOT, "questa_fse")
)


def _valid_quartus_rootdir(path):
    """QUARTUS_ROOTDIR must be the 'quartus' SUBDIR, not the SDK root.

    The io96b EMIF calibration model resolves '$QUARTUS_ROOTDIR/../ip/altera/...'
    and '$QUARTUS_ROOTDIR/bin/...'. Pointing it one level too high (at the SDK
    root) leaves both missing, and the model aborts at t=0 with
    'Could not find Quartus installation - missing environment variable
    QUARTUS_ROOTDIR' - even though the variable IS exported. Symptom: the run
    ends in ~20 s and sc_data.txt is never updated.
    """
    if not path:
        return False
    return os.path.isdir(os.path.join(path, "bin")) and \
           os.path.isdir(os.path.join(path, "..", "ip", "altera"))


# Prefer an already-correct inherited value; otherwise fall back to
# QUARTUS_INSTALL_DIR (which IS the quartus dir). Never trust the inherited
# value blindly - a GUI launched from a desktop icon or IDE never sources
# ~/.bashrc, so it may be absent or wrong.
QUARTUS_ROOTDIR = os.environ.get("QUARTUS_ROOTDIR", "")
if not _valid_quartus_rootdir(QUARTUS_ROOTDIR):
    QUARTUS_ROOTDIR = QUARTUS_INSTALL_DIR
if not _valid_quartus_rootdir(QUARTUS_ROOTDIR):
    print(f"WARNING: QUARTUS_ROOTDIR={QUARTUS_ROOTDIR!r} looks wrong "
          f"(need <acds>/quartus). DDR4/EMIF calibration will abort at t=0.")

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

# Device libraries: Questa Intel Starter FPGA Edition ships the Verilog device
# libraries precompiled and mapped in its own modelsim.ini, so the full dev_com
# is not needed - and in 25.1.1 it cannot even run, because it opens
# $QUARTUS_SIM_LIB_DIR/{220model.v,sgate.v,altera_mf.v,tennm_atoms.sv,...} and
# both quartus/eda/sim_lib{,2} and devices/sim_lib{,2} are bare stubs (only
# sim_prep.py / manifest.lua / simsf_dpi.cpp); the real sources live in
# questa_fse/intel/verilog/src. The old workaround pointed QUARTUS_SIM_LIB_DIR
# at a hand-stitched sim_libs/ dir that is not in the repo and was built for
# Cyclone 10 GX anyway. Result: 'g++: simsf_dpi.cpp: No such file'.
#
# BUT one piece of dev_com IS mandatory: simsf_dpi.cpp. Elaboration succeeds
# without it, which is misleading - the failure only shows at time 0, when the
# io96b EMIF model calls into the DPI:
#   ** Warning: (vsim-3770) Failed to find user specified function
#                'simsf_get_logic_string_attribute_setting' in DPI C/C++ sources
#   ** Fatal:   (vsim-160) tennm_agilex5_io96_ncrypt.sv(145): Null foreign
#                function pointer encountered when calling 'simsf_constra3...'
# The precompiled libraries supply the SystemVerilog, not the C++ object, so
# simsf_dpi.cpp must be compiled into 'work' (the working DDR_TPG reference has
# exactly this: libraries/work/_dpi/.../simsf_dpi.o and no device libraries).
# eda/sim_lib is the variant this design's msim_setup.tcl targets and matches
# the precompiled questa_fe/eda/sim_lib the EMIF model resolves against.
SIMSF_DPI = os.path.join(QUARTUS_INSTALL_DIR, "eda", "sim_lib", "simsf_dpi.cpp")
if not os.path.exists(SIMSF_DPI):
    print(f"WARNING: {SIMSF_DPI} not found - the io96b EMIF model will hit a "
          f"null foreign function pointer at time 0.")

# Set FRC_DEV_COM=1 to additionally run the full dev_com (only useful once the
# device libs are populated via
#   quartus_py $QUARTUS_ROOTDIR/../devices/sim_lib2/sim_prep.py questasim ).
want_dev_com = os.environ.get("FRC_DEV_COM", "0") == "1"
dev_com_block = (
    "# DPI required by the io96b EMIF model (see runProject.py notes)\n"
    f"vlog -sv {SIMSF_DPI}\n"
)
if want_dev_com:
    dev_com_block += "# Full device library compile (FRC_DEV_COM=1)\ndev_com\n"

# The io96b EMIF model trips a few pedantic Questa checks; the EMIF example
# design's own flow suppresses exactly these.
elab_opts = '{-voptargs="+acc" -suppress 7041 -suppress 7033}'

# Wave logging. `add wave -r /*` recursively logs EVERY signal in the design -
# with FRC that includes the entire io96b EMIF PHY and the DDR4 model. The old
# comment here claimed it was "harmless in command line", but it is not: in -c
# mode `add wave` still drives full WLF logging (observed ~240 KB/min of
# vsim.wlf during DDR4 calibration), on top of the unoptimized +acc
# elaboration. Calibration is already the dominant cost of an FRC run, so only
# pay for waves when someone is actually going to look at them.
#
# Note elab_debug/+acc is kept even headless: tb.v reaches into the DUT
# hierarchy (dut.current_state, dut.ready_to_start, dut.cfg_step, ...), and a
# fully optimized elaboration would optimize those away.
if is_debug:
    wave_block = "# Waves (GUI/debug only - see note in runProject.py)\nadd wave /tb/dut/*\nadd wave -r /*\n"
else:
    wave_block = ("# Waves skipped: headless run. Set FRC_WAVES=1 to force them on.\n"
                  if os.environ.get("FRC_WAVES", "0") != "1"
                  else "add wave /tb/dut/*\nadd wave -r /*\n")

tcl_commands = f"""
# Move to sim directory
cd {sim_path}

# Setup and Compile IP
set QUARTUS_INSTALL_DIR {QUARTUS_INSTALL_DIR}
source msim_setup.tcl

{dev_com_block}
# Compile IP
com

# Compile RTL and TB
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'tb.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'top.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'make_file.v')}
vlog {os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'rtl', 'controller.v')}

# Elaborate
set TOP_LEVEL_NAME work.tb
set USER_DEFINED_ELAB_OPTIONS {elab_opts}
elab_debug

{wave_block}
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
    # MUST reach the vsim process: the io96b EMIF calibration model reads this
    # at t=0 and aborts the whole simulation if it is missing or wrong.
    my_env["QUARTUS_ROOTDIR"] = QUARTUS_ROOTDIR
    my_env["QUARTUS_INSTALL_DIR"] = QUARTUS_INSTALL_DIR
    print(f"QUARTUS_ROOTDIR = {QUARTUS_ROOTDIR}")

    subprocess.run([vsim_bin, mode_flag, "-do", do_file_path], check=True, env=my_env)

except FileNotFoundError:
    print(f"Error: vsim not found ({vsim_bin}). Check QUESTASIM_DIR / PATH.")
except subprocess.CalledProcessError as e:
    print(f"Simulation failed with exit code {e.returncode}")
