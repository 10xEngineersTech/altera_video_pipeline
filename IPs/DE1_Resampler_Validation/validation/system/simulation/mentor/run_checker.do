# run_checker.do  --  NOT auto-generated; safe from Qsys regeneration.
#
# One-shot build + run for the resampling_checker testbench.
# Usage from the mentor/ dir:   do run_checker.do
#
# It reuses the Qsys-generated msim_setup.tcl for library setup and the
# dev_com / com aliases, then compiles the checker + testbench and elaborates
# with -voptargs=+acc (NOT -novopt, which QuestaSim 2021.2 rejects as a fatal
# error -> "Error loading design").

do msim_setup.tcl

dev_com
com
vlog -sv ../../synthesis/resampling_checker.v
vlog -sv ../../synthesis/testbench.v

vsim -voptargs=+acc -t ps \
  -L work -L work_lib -L rst_controller -L alt_vip_crs_0 -L alt_vip_tpg_0 \
  -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver \
  -L cycloneii_ver \
  work.testbench

run -all
