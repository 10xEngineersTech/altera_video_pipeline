set_global_assignment -entity "system" -library "lib_system" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "system" -library "lib_system" -name IP_TOOL_VERSION "13.0sp1"
set_global_assignment -entity "system" -library "lib_system" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_system" -name SPD_FILE [file join $::quartus(sip_path) "../../system.spd"]
set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "../../system.qsys"]

set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "system.v"]
set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_controller.v"]
set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_synchronizer.v"]
set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_controller.sdc"]
set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "submodules/system_alt_vip_crs_0.vo"]
set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "submodules/tta_x_blank_mem.hex"]
set_global_assignment -library "lib_system" -name MISC_FILE [file join $::quartus(sip_path) "submodules/system_alt_vip_tpg_0.vo"]
