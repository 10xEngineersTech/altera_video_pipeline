# dump.do -- temporary 4:2:0 format probe. Run from system/simulation/mentor/
do msim_setup.tcl
dev_com
com
vlog -sv ../../synthesis/dump_tb.v
vsim -voptargs=+acc -t ps \
  -L work -L work_lib -L rst_controller -L alt_vip_crs_0 -L alt_vip_tpg_0 \
  -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver \
  -L cycloneii_ver \
  work.dump_tb
run -all
