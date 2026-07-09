# build_system.tcl
# Rebuild system.qsys: 2x intel_vvp_tpg (different patterns) -> intel_vvp_mixer
# TPG0 = base layer (color bars), TPG1 = overlay layer 1 (uniform color).
# Video streams are connected inside the system; the three Avalon-MM control
# agents and the mixer AXI4-S output are exported for the RTL controller/tb.
package require -exact qsys 25.1

load_system system.qsys

# --- Remove any previously added processing instances (idempotent rebuild) ---
foreach inst {intel_vvp_tpg_0 intel_vvp_tpg_1 intel_vvp_mixer_0} {
    if {[lsearch -exact [get_instances] $inst] >= 0} {
        remove_instance $inst
    }
}

# =============================================================================
# TPG 0  -  base layer, color bars pattern
# =============================================================================
add_instance intel_vvp_tpg_0 intel_vvp_tpg
set_instance_parameter_value intel_vvp_tpg_0 BPS                 8
set_instance_parameter_value intel_vvp_tpg_0 NUMBER_OF_COLOR_PLANES 3
set_instance_parameter_value intel_vvp_tpg_0 PIXELS_IN_PARALLEL  1
set_instance_parameter_value intel_vvp_tpg_0 RUNTIME_CONTROL     1
set_instance_parameter_value intel_vvp_tpg_0 EXTERNAL_MODE       0
set_instance_parameter_value intel_vvp_tpg_0 NUM_CORES           1
set_instance_parameter_value intel_vvp_tpg_0 CORE_PATTERN_0      0
set_instance_parameter_value intel_vvp_tpg_0 CORE_COL_SPACE_0    0
set_instance_parameter_value intel_vvp_tpg_0 OUTPUT_FORMAT       4.4.4

# =============================================================================
# TPG 1  -  overlay layer, uniform color pattern
# =============================================================================
add_instance intel_vvp_tpg_1 intel_vvp_tpg
set_instance_parameter_value intel_vvp_tpg_1 BPS                 8
set_instance_parameter_value intel_vvp_tpg_1 NUMBER_OF_COLOR_PLANES 3
set_instance_parameter_value intel_vvp_tpg_1 PIXELS_IN_PARALLEL  1
set_instance_parameter_value intel_vvp_tpg_1 RUNTIME_CONTROL     1
set_instance_parameter_value intel_vvp_tpg_1 EXTERNAL_MODE       0
set_instance_parameter_value intel_vvp_tpg_1 NUM_CORES           1
set_instance_parameter_value intel_vvp_tpg_1 CORE_PATTERN_0      1
set_instance_parameter_value intel_vvp_tpg_1 CORE_COL_SPACE_0    0
set_instance_parameter_value intel_vvp_tpg_1 OUTPUT_FORMAT       4.4.4

# =============================================================================
# Mixer  -  2 layers (base + 1 overlay), runtime control
# =============================================================================
add_instance intel_vvp_mixer_0 intel_vvp_mixer
set_instance_parameter_value intel_vvp_mixer_0 BPS                    8
set_instance_parameter_value intel_vvp_mixer_0 NUMBER_OF_COLOR_PLANES 3
set_instance_parameter_value intel_vvp_mixer_0 PIXELS_IN_PARALLEL     1
set_instance_parameter_value intel_vvp_mixer_0 RUNTIME_CONTROL        1
set_instance_parameter_value intel_vvp_mixer_0 EXTERNAL_MODE          0
set_instance_parameter_value intel_vvp_mixer_0 NUM_LAYERS             2
# Layer 1 blending: 1 = opaque supported (static/input alpha not needed)
set_instance_parameter_value intel_vvp_mixer_0 BLENDING_MODE_1        0

# =============================================================================
# Clocks and resets
# =============================================================================
foreach inst {intel_vvp_tpg_0 intel_vvp_tpg_1 intel_vvp_mixer_0} {
    add_connection clock_in.out_clk    ${inst}.main_clock
    add_connection reset_in.out_reset  ${inst}.main_reset
}

# =============================================================================
# Video stream connections: TPG0 -> mixer base, TPG1 -> mixer layer 1
# =============================================================================
add_connection intel_vvp_tpg_0.axi4s_vid_out intel_vvp_mixer_0.axi4s_vid_0_in
add_connection intel_vvp_tpg_1.axi4s_vid_out intel_vvp_mixer_0.axi4s_vid_1_in

# =============================================================================
# Exports
# =============================================================================
# TPG control agents
add_interface intel_vvp_tpg_0_av_mm_control_agent avalon slave
set_interface_property intel_vvp_tpg_0_av_mm_control_agent EXPORT_OF intel_vvp_tpg_0.av_mm_control_agent
add_interface intel_vvp_tpg_1_av_mm_control_agent avalon slave
set_interface_property intel_vvp_tpg_1_av_mm_control_agent EXPORT_OF intel_vvp_tpg_1.av_mm_control_agent
# Mixer control agent
add_interface intel_vvp_mixer_0_av_mm_control_agent avalon slave
set_interface_property intel_vvp_mixer_0_av_mm_control_agent EXPORT_OF intel_vvp_mixer_0.av_mm_control_agent
# Mixer video output
add_interface intel_vvp_mixer_0_axi4s_vid_out axi4stream master
set_interface_property intel_vvp_mixer_0_axi4s_vid_out EXPORT_OF intel_vvp_mixer_0.axi4s_vid_out

sync_sysinfo_parameters
save_system system.qsys
