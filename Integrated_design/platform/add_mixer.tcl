# add_mixer.tcl
# Upgrade pipeline.qsys:
#   1. Retarget the system (and all child IP) to the Quartus project device
#      (A5ED065BB32AE6SR0) via sync_sysinfo_parameters — run with
#      --quartus-project=../quartus/system.qpf so sysinfo comes from the QSF.
#   2. Add intel_vvp_tpg_1 ("TPG#2"): uniform-color pattern (CORE_PATTERN_0=1),
#      runtime-programmed solid red 20x20 background layer.
#   3. Add intel_vvp_mixer_0 (NUM_LAYERS=2):
#        axi4s_vid_0_in (background) <- intel_vvp_tpg_1 (connected internally)
#        axi4s_vid_1_in (layer 1)    <- exported (VFB read output, via top.v)
#        axi4s_vid_out               -> exported (captured by tb instead of VFB)
#   4. Both new control agents go on mm_bridge_0 at EXPLICIT base addresses so
#      the existing map (VFB 0x000 / CONV 0x200 / SCL 0x400 / CLIP 0x600 /
#      CRS 0x800 / CSC 0xA00) does not shift:
#        mixer  0x0C00-0x0FFF  (0x400 span)
#        tpg_1  0x1000-0x11FF  (0x200 span)
#
# Rebuild with:
#   cd Integrated_design/platform
#   qsys-script --script=add_mixer.tcl
# (no --quartus-project: attaching to the project's DNI service hangs headless;
#  the device is set explicitly below instead)
package require -exact qsys 25.1

load_system pipeline.qsys
puts "== system loaded, retargeting device =="

# Match the device selected in quartus/system.qsf
set_project_property DEVICE_FAMILY "Agilex 5"
set_project_property DEVICE A5ED065BB32AE6SR0
puts "== device set, adding instances =="

# --- Idempotent: remove previously added instances on re-run ---
foreach inst {intel_vvp_tpg_1 intel_vvp_mixer_0} {
    if {[lsearch -exact [get_instances] $inst] >= 0} {
        remove_instance $inst
    }
}

# =============================================================================
# TPG#2 - uniform color background source (color set at runtime: solid red)
# =============================================================================
add_instance intel_vvp_tpg_1 intel_vvp_tpg
set_instance_parameter_value intel_vvp_tpg_1 BPS                    8
set_instance_parameter_value intel_vvp_tpg_1 PIXELS_IN_PARALLEL     1
set_instance_parameter_value intel_vvp_tpg_1 RUNTIME_CONTROL        1
set_instance_parameter_value intel_vvp_tpg_1 EXTERNAL_MODE          0
set_instance_parameter_value intel_vvp_tpg_1 NUM_CORES              1
set_instance_parameter_value intel_vvp_tpg_1 CORE_PATTERN_0         1
set_instance_parameter_value intel_vvp_tpg_1 CORE_COL_SPACE_0       0
set_instance_parameter_value intel_vvp_tpg_1 OUTPUT_FORMAT          4.4.4

# =============================================================================
# Mixer - 2 layers: background (TPG#2) + layer 1 (VFB read frame)
# =============================================================================
add_instance intel_vvp_mixer_0 intel_vvp_mixer
set_instance_parameter_value intel_vvp_mixer_0 BPS                    8
set_instance_parameter_value intel_vvp_mixer_0 NUMBER_OF_COLOR_PLANES 3
set_instance_parameter_value intel_vvp_mixer_0 PIXELS_IN_PARALLEL     1
set_instance_parameter_value intel_vvp_mixer_0 RUNTIME_CONTROL        1
set_instance_parameter_value intel_vvp_mixer_0 EXTERNAL_MODE          0
set_instance_parameter_value intel_vvp_mixer_0 NUM_LAYERS             2
set_instance_parameter_value intel_vvp_mixer_0 BLENDING_MODE_1        0

# =============================================================================
# Clocks / resets
# =============================================================================
foreach inst {intel_vvp_tpg_1 intel_vvp_mixer_0} {
    add_connection clock_in.out_clk   ${inst}.main_clock
    add_connection reset_in.out_reset ${inst}.main_reset
}

# =============================================================================
# Video streams: TPG#2 -> mixer background (internal); layer-1 in + out exported
# =============================================================================
add_connection intel_vvp_tpg_1.axi4s_vid_out intel_vvp_mixer_0.axi4s_vid_0_in

add_interface intel_vvp_mixer_0_axi4s_vid_1_in axi4stream slave
set_interface_property intel_vvp_mixer_0_axi4s_vid_1_in EXPORT_OF intel_vvp_mixer_0.axi4s_vid_1_in
add_interface intel_vvp_mixer_0_axi4s_vid_out axi4stream master
set_interface_property intel_vvp_mixer_0_axi4s_vid_out EXPORT_OF intel_vvp_mixer_0.axi4s_vid_out

# =============================================================================
# Control agents on mm_bridge_0 at explicit bases (existing map untouched)
# =============================================================================
add_connection mm_bridge_0.m0 intel_vvp_mixer_0.av_mm_control_agent
set_connection_parameter_value mm_bridge_0.m0/intel_vvp_mixer_0.av_mm_control_agent baseAddress "0x0c00"
add_connection mm_bridge_0.m0 intel_vvp_tpg_1.av_mm_control_agent
set_connection_parameter_value mm_bridge_0.m0/intel_vvp_tpg_1.av_mm_control_agent baseAddress "0x1000"

puts "== connections done, syncing sysinfo =="
sync_sysinfo_parameters
puts "== saving system =="
save_system pipeline.qsys
puts "== done =="
