# debug_checker.do  --  NOT auto-generated; safe from Qsys regeneration.
#
# Clean compile + INTERACTIVE elaborate (full visibility) for waveform debugging.
# Unlike run_checker.do it does NOT 'run -all', so you can add waves first, then
# 'run -all' yourself.
#
# Fixes the elaborate error:
#   ** Error (vopt-2732) Module parameter 'CHANNELS_IN_PAR' not found for override
#       (system.v) ... Error loading design
# That happens when the *synthesis* system.v (parameterised RTL wrapper,
# system/synthesis/system.v) is sitting in 'work' instead of the *simulation*
# system.v (system/simulation/system.v) that matches the gate-level .vo cores.
# 'com' below recompiles the correct simulation system.v into 'work'.
# Do NOT compile system/synthesis/system.v for simulation.
#
# Note: elab_debug uses -voptargs=+acc (not -novopt, which QuestaSim 2021.2
# rejects).  Qsys overwrites msim_setup.tcl on regeneration, so re-apply that.

do msim_setup.tcl

dev_com
com
vlog -sv +incdir+../../synthesis ../../synthesis/expected_group_model.v
vlog -sv +incdir+../../synthesis ../../synthesis/resampling_checker.v
vlog -sv +incdir+../../synthesis ../../synthesis/testbench.v

elab_debug

# Add waves here if desired, e.g.:
#   add wave -r /testbench/*
# then run:
#   run -all
