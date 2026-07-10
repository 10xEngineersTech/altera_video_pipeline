# build_system.tcl
# Rebuild system.qsys: 8x intel_vvp_tpg -> intel_vvp_mixer (NUM_LAYERS=8).
# TPG0 = base layer (color bars), TPG1..TPG7 = overlay layers 1..7 (uniform
# color, runtime-programmed by rtl/top.v).
# Video streams are connected inside the system; the nine Avalon-MM control
# agents and the mixer AXI4-S output are exported for the RTL controller/tb.
package require -exact qsys 25.1

load_system system.qsys

set NUM_TPG 8

# --- Remove any previously added processing instances (idempotent rebuild) ---
set old_insts {intel_vvp_mixer_0}
for {set i 0} {$i < $NUM_TPG} {incr i} {
    lappend old_insts intel_vvp_tpg_$i
}
foreach inst $old_insts {
    if {[lsearch -exact [get_instances] $inst] >= 0} {
        remove_instance $inst
    }
}

# =============================================================================
# TPGs  -  TPG0: base layer, color bars; TPG1..7: overlays, uniform color
# =============================================================================
for {set i 0} {$i < $NUM_TPG} {incr i} {
    set inst intel_vvp_tpg_$i
    add_instance $inst intel_vvp_tpg
    set_instance_parameter_value $inst BPS                    8
    set_instance_parameter_value $inst NUMBER_OF_COLOR_PLANES 3
    set_instance_parameter_value $inst PIXELS_IN_PARALLEL     1
    set_instance_parameter_value $inst RUNTIME_CONTROL        1
    set_instance_parameter_value $inst EXTERNAL_MODE          0
    set_instance_parameter_value $inst NUM_CORES              1
    # Pattern: 0 = color bars (base), 1 = uniform color (overlays)
    set_instance_parameter_value $inst CORE_PATTERN_0         [expr {$i == 0 ? 0 : 1}]
    set_instance_parameter_value $inst CORE_COL_SPACE_0       0
    set_instance_parameter_value $inst OUTPUT_FORMAT          4.4.4
}

# =============================================================================
# Mixer  -  8 layers (base + 7 overlays), runtime control
# =============================================================================
add_instance intel_vvp_mixer_0 intel_vvp_mixer
set_instance_parameter_value intel_vvp_mixer_0 BPS                    8
set_instance_parameter_value intel_vvp_mixer_0 NUMBER_OF_COLOR_PLANES 3
set_instance_parameter_value intel_vvp_mixer_0 PIXELS_IN_PARALLEL     1
set_instance_parameter_value intel_vvp_mixer_0 RUNTIME_CONTROL        1
set_instance_parameter_value intel_vvp_mixer_0 EXTERNAL_MODE          0
set_instance_parameter_value intel_vvp_mixer_0 NUM_LAYERS             8
# Overlay blending: 0 = opaque supported (static/input alpha not needed)
for {set l 1} {$l < $NUM_TPG} {incr l} {
    set_instance_parameter_value intel_vvp_mixer_0 BLENDING_MODE_$l   0
}

# =============================================================================
# Clocks and resets
# =============================================================================
set proc_insts {intel_vvp_mixer_0}
for {set i 0} {$i < $NUM_TPG} {incr i} {
    lappend proc_insts intel_vvp_tpg_$i
}
foreach inst $proc_insts {
    add_connection clock_in.out_clk    ${inst}.main_clock
    add_connection reset_in.out_reset  ${inst}.main_reset
}

# =============================================================================
# Video stream connections: TPG0 -> mixer base, TPGn -> mixer layer n
# =============================================================================
for {set i 0} {$i < $NUM_TPG} {incr i} {
    add_connection intel_vvp_tpg_${i}.axi4s_vid_out intel_vvp_mixer_0.axi4s_vid_${i}_in
}

# =============================================================================
# Exports
# =============================================================================
# TPG control agents
for {set i 0} {$i < $NUM_TPG} {incr i} {
    add_interface intel_vvp_tpg_${i}_av_mm_control_agent avalon slave
    set_interface_property intel_vvp_tpg_${i}_av_mm_control_agent EXPORT_OF intel_vvp_tpg_${i}.av_mm_control_agent
}
# Mixer control agent
add_interface intel_vvp_mixer_0_av_mm_control_agent avalon slave
set_interface_property intel_vvp_mixer_0_av_mm_control_agent EXPORT_OF intel_vvp_mixer_0.av_mm_control_agent
# Mixer video output
add_interface intel_vvp_mixer_0_axi4s_vid_out axi4stream master
set_interface_property intel_vvp_mixer_0_axi4s_vid_out EXPORT_OF intel_vvp_mixer_0.axi4s_vid_out

sync_sysinfo_parameters
save_system system.qsys
