#!/usr/bin/python3
import os
import sys
import subprocess
import threading
import json
import re

try:
    import gi
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk, GdkPixbuf, Gdk, GLib
except ImportError:
    print("\n[!] ERROR: Missing 'gi' module (PyGObject).")
    print(f"Current Python: {sys.executable}")
    print("Please run this script using the system Python: /usr/bin/python3\n")
    sys.exit(1)

# Topology metadata: which fields are relevant per mode
TOPOLOGY_META = {
    "FULL":         {"clip": True,  "scl": True,  "crs": True,  "csc": True,  "desc": "DIL?CRS?CSC?Clipper?PC0?Scaler"},
    "SCALER_ONLY":  {"clip": False, "scl": True,  "crs": False, "csc": False, "desc": "Scaler only"},
    "CSC_ONLY":     {"clip": False, "scl": False, "crs": False, "csc": True,  "desc": "CSC only"},
    "CRS_ONLY":     {"clip": False, "scl": False, "crs": True,  "csc": False, "desc": "CRS only"},
    "CRS_CSC":      {"clip": False, "scl": False, "crs": True,  "csc": True,  "desc": "CRS?CSC"},
    "CLIP_SCL":     {"clip": True,  "scl": True,  "crs": False, "csc": False, "desc": "Clipper?PC0?Scaler"},
    "DIL_ONLY":     {"clip": False, "scl": False, "crs": False, "csc": False, "desc": "Deinterlacer only"},
}

TOPOLOGIES = list(TOPOLOGY_META.keys())

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PRESETS_DIR = os.path.join(BASE_DIR, "presets")
os.makedirs(PRESETS_DIR, exist_ok=True)


class ImageViewerWindow(Gtk.Window):
    def __init__(self, image_path):
        super().__init__(title="Video Pipeline | Configuration & Viewer")
        self.set_default_size(1200, 820)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.connect("destroy", Gtk.main_quit)

        self.apply_styling()

        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(main_box)

        # ?? Header ????????????????????????????????????????????????????????????
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        header.get_style_context().add_class("header-bar")
        header_label = Gtk.Label(label="Video Pipeline Control Center")
        header_label.get_style_context().add_class("header-title")
        header.pack_start(header_label, False, False, 20)

        self.status_badge = Gtk.Label(label="CONNECTED")
        self.status_badge.get_style_context().add_class("status-badge")
        header.pack_end(self.status_badge, False, False, 20)
        main_box.pack_start(header, False, False, 0)

        # ?? Main content ??????????????????????????????????????????????????????
        content_panes = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        main_box.pack_start(content_panes, True, True, 0)

        # ?? Sidebar ???????????????????????????????????????????????????????????
        sidebar_scroll = Gtk.ScrolledWindow()
        sidebar_scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        sidebar_scroll.set_size_request(330, -1)
        content_panes.pack_start(sidebar_scroll, False, False, 0)

        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        sidebar.get_style_context().add_class("sidebar")
        sidebar_scroll.add(sidebar)

        sidebar_title = Gtk.Label(label="Parameters")
        sidebar_title.get_style_context().add_class("sidebar-title")
        sidebar.pack_start(sidebar_title, False, False, 10)

        # ?? Preset bar ????????????????????????????????????????????????????????
        preset_group = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        preset_group.get_style_context().add_class("param-group")
        preset_lbl = Gtk.Label(label="Presets")
        preset_lbl.set_xalign(0)
        preset_lbl.get_style_context().add_class("group-label")
        preset_group.pack_start(preset_lbl, False, False, 0)

        preset_load_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.preset_combo = Gtk.ComboBoxText()
        self.preset_combo.append_text("? select preset ?")
        self.preset_combo.set_active(0)
        self._refresh_preset_list()
        self.preset_combo.set_hexpand(True)
        preset_load_row.pack_start(self.preset_combo, True, True, 0)

        load_btn = Gtk.Button(label="Load")
        load_btn.get_style_context().add_class("mini-btn")
        load_btn.connect("clicked", self.on_load_preset)
        preset_load_row.pack_start(load_btn, False, False, 0)

        preset_group.pack_start(preset_load_row, False, False, 0)

        preset_save_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.preset_name_entry = Gtk.Entry()
        self.preset_name_entry.set_placeholder_text("Preset name?")
        self.preset_name_entry.set_hexpand(True)
        preset_save_row.pack_start(self.preset_name_entry, True, True, 0)

        save_btn = Gtk.Button(label="Save")
        save_btn.get_style_context().add_class("mini-btn-save")
        save_btn.connect("clicked", self.on_save_preset)
        preset_save_row.pack_start(save_btn, False, False, 0)

        preset_group.pack_start(preset_save_row, False, False, 0)
        sidebar.pack_start(preset_group, False, False, 0)

        # ?? Topology selector ?????????????????????????????????????????????????
        topo_group = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        topo_group.get_style_context().add_class("param-group")
        topo_lbl = Gtk.Label(label="Topology")
        topo_lbl.set_xalign(0)
        topo_lbl.get_style_context().add_class("group-label")
        topo_group.pack_start(topo_lbl, False, False, 0)

        self.topo_combo = Gtk.ComboBoxText()
        for t in TOPOLOGIES:
            self.topo_combo.append_text(t)
        self.topo_combo.set_active(0)  # FULL
        self.topo_combo.connect("changed", self.on_topology_changed)
        topo_group.pack_start(self.topo_combo, False, False, 0)

        self.topo_desc = Gtk.Label(label=TOPOLOGY_META["FULL"]["desc"])
        self.topo_desc.set_xalign(0)
        self.topo_desc.get_style_context().add_class("dim-hint")
        topo_group.pack_start(self.topo_desc, False, False, 0)

        sidebar.pack_start(topo_group, False, False, 0)

        # ?? Input Source ??????????????????????????????????????????????????????
        src_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        src_box.get_style_context().add_class("param-group")
        src_lbl = Gtk.Label(label="Input Source")
        src_lbl.set_xalign(0)
        src_lbl.get_style_context().add_class("group-label")
        src_box.pack_start(src_lbl, False, False, 0)

        self.radio_tpg   = Gtk.RadioButton.new_with_label(None, "TPG (Test Pattern Generator)")
        self.radio_image = Gtk.RadioButton.new_with_label_from_widget(
            self.radio_tpg, "Image File (image.png)")
        self.radio_tpg.get_style_context().add_class("src-radio")
        self.radio_image.get_style_context().add_class("src-radio")
        src_box.pack_start(self.radio_tpg,   False, False, 0)
        src_box.pack_start(self.radio_image, False, False, 0)

        self.img_dim_hint = Gtk.Label(label="")
        self.img_dim_hint.set_xalign(0)
        self.img_dim_hint.get_style_context().add_class("dim-hint")
        src_box.pack_start(self.img_dim_hint, False, False, 0)
        sidebar.pack_start(src_box, False, False, 0)

        self.radio_image.connect("toggled", self._on_source_toggled)

        # ?? Parameters ????????????????????????????????????????????????????????
        self.params = {}

        res_group = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        res_group.get_style_context().add_class("param-group")
        self.res_group_label = Gtk.Label(label="Input Resolution")
        self.res_group_label.set_xalign(0)
        self.res_group_label.get_style_context().add_class("group-label")
        res_group.pack_start(self.res_group_label, False, False, 0)

        for name, key, default in [("Width", "tpg_w", 640), ("Height", "tpg_h", 480)]:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            lbl  = Gtk.Label(label=name)
            lbl.set_xalign(0)
            hbox.pack_start(lbl, True, True, 0)
            adj  = Gtk.Adjustment(value=default, lower=1, upper=8192, step_increment=1)
            spin = Gtk.SpinButton(adjustment=adj, climb_rate=1, digits=0)
            spin.set_width_chars(6)
            hbox.pack_end(spin, False, False, 0)
            self.params[key] = spin
            res_group.pack_start(hbox, False, False, 0)

        sidebar.pack_start(res_group, False, False, 0)

        # Clipper group (conditionally sensitive)
        self.clip_group_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.clip_group_box.get_style_context().add_class("param-group")
        clip_lbl = Gtk.Label(label="Clipper Offsets")
        clip_lbl.set_xalign(0)
        clip_lbl.get_style_context().add_class("group-label")
        self.clip_group_box.pack_start(clip_lbl, False, False, 0)
        for name, key, default in [
            ("Top Offset",    "clip_top",    0),
            ("Bottom Offset", "clip_bottom", 0),
            ("Left Offset",   "clip_left",   0),
            ("Right Offset",  "clip_right",  0),
        ]:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            lbl  = Gtk.Label(label=name)
            lbl.set_xalign(0)
            hbox.pack_start(lbl, True, True, 0)
            adj  = Gtk.Adjustment(value=default, lower=0, upper=8192, step_increment=1)
            spin = Gtk.SpinButton(adjustment=adj, climb_rate=1, digits=0)
            spin.set_width_chars(6)
            hbox.pack_end(spin, False, False, 0)
            self.params[key] = spin
            self.clip_group_box.pack_start(hbox, False, False, 0)
        sidebar.pack_start(self.clip_group_box, False, False, 0)

        # Scaler group (conditionally sensitive)
        self.scl_group_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.scl_group_box.get_style_context().add_class("param-group")
        scl_lbl = Gtk.Label(label="Scaler Output")
        scl_lbl.set_xalign(0)
        scl_lbl.get_style_context().add_class("group-label")
        self.scl_group_box.pack_start(scl_lbl, False, False, 0)
        for name, key, default in [
            ("Scaler Width",  "scale_w", 640),
            ("Scaler Height", "scale_h", 480),
        ]:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            lbl  = Gtk.Label(label=name)
            lbl.set_xalign(0)
            hbox.pack_start(lbl, True, True, 0)
            adj  = Gtk.Adjustment(value=default, lower=1, upper=8192, step_increment=1)
            spin = Gtk.SpinButton(adjustment=adj, climb_rate=1, digits=0)
            spin.set_width_chars(6)
            hbox.pack_end(spin, False, False, 0)
            self.params[key] = spin
            self.scl_group_box.pack_start(hbox, False, False, 0)
        sidebar.pack_start(self.scl_group_box, False, False, 0)

        # ?? PIP (Picture-in-Picture) ?????????????????????????????????????????
        self.pip_group_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.pip_group_box.get_style_context().add_class("param-group")
        pip_lbl = Gtk.Label(label="PIP (Picture-in-Picture)")
        pip_lbl.set_xalign(0)
        pip_lbl.get_style_context().add_class("group-label")
        self.pip_group_box.pack_start(pip_lbl, False, False, 0)

        self.pip_checkbox = Gtk.CheckButton(label="Enable PIP")
        self.pip_checkbox.connect("toggled", self._on_pip_toggled)
        self.pip_group_box.pack_start(self.pip_checkbox, False, False, 0)

        pip_color_hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        pip_color_lbl = Gtk.Label(label="Background Color")
        pip_color_lbl.set_xalign(0)
        pip_color_hbox.pack_start(pip_color_lbl, True, True, 0)
        self.pip_color_combo = Gtk.ComboBoxText()
        self.pip_color_combo.append_text("Red")
        self.pip_color_combo.append_text("Green")
        self.pip_color_combo.append_text("Blue")
        self.pip_color_combo.set_active(2)  # default Blue
        pip_color_hbox.pack_end(self.pip_color_combo, False, False, 0)
        self.pip_group_box.pack_start(pip_color_hbox, False, False, 0)

        for name, key, default in [
            ("Background Width",  "pip_bg_w", 1280),
            ("Background Height", "pip_bg_h", 960),
        ]:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            lbl  = Gtk.Label(label=name)
            lbl.set_xalign(0)
            hbox.pack_start(lbl, True, True, 0)
            adj  = Gtk.Adjustment(value=default, lower=1, upper=8192, step_increment=1)
            spin = Gtk.SpinButton(adjustment=adj, climb_rate=1, digits=0)
            spin.set_width_chars(6)
            hbox.pack_end(spin, False, False, 0)
            self.params[key] = spin
            self.pip_group_box.pack_start(hbox, False, False, 0)

        pip_pos_hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        pip_pos_lbl = Gtk.Label(label="Position")
        pip_pos_lbl.set_xalign(0)
        pip_pos_hbox.pack_start(pip_pos_lbl, True, True, 0)
        self.pip_pos_combo = Gtk.ComboBoxText()
        for p in ("Center", "Top-Left", "Top-Right", "Bottom-Left", "Bottom-Right", "Custom"):
            self.pip_pos_combo.append_text(p)
        self.pip_pos_combo.set_active(0)  # default Center
        self.pip_pos_combo.connect("changed", self._on_pip_pos_changed)
        pip_pos_hbox.pack_end(self.pip_pos_combo, False, False, 0)
        self.pip_group_box.pack_start(pip_pos_hbox, False, False, 0)

        for name, key, default in [
            ("Custom H Offset", "pip_h_off", 0),
            ("Custom V Offset", "pip_v_off", 0),
        ]:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            lbl  = Gtk.Label(label=name)
            lbl.set_xalign(0)
            hbox.pack_start(lbl, True, True, 0)
            adj  = Gtk.Adjustment(value=default, lower=0, upper=8192, step_increment=1)
            spin = Gtk.SpinButton(adjustment=adj, climb_rate=1, digits=0)
            spin.set_width_chars(6)
            hbox.pack_end(spin, False, False, 0)
            self.params[key] = spin
            self.pip_group_box.pack_start(hbox, False, False, 0)
        sidebar.pack_start(self.pip_group_box, False, False, 0)

        # ?? CRS Output Mode ???????????????????????????????????????????????????
        self.crs_group_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.crs_group_box.get_style_context().add_class("param-group")
        crs_lbl = Gtk.Label(label="CRS Output Mode")
        crs_lbl.set_xalign(0)
        crs_lbl.get_style_context().add_class("group-label")
        self.crs_group_box.pack_start(crs_lbl, False, False, 0)
        self.crs_combo = Gtk.ComboBoxText()
        self.crs_combo.append_text("0 - 4:2:0 output")
        self.crs_combo.append_text("2 - 4:2:2 output")
        self.crs_combo.append_text("3 - 4:4:4 output")
        self.crs_combo.set_active(2)  # default 444
        self.crs_group_box.pack_start(self.crs_combo, False, False, 0)
        sidebar.pack_start(self.crs_group_box, False, False, 0)

        # ?? CSC Mode ??????????????????????????????????????????????????????????
        self.csc_group_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.csc_group_box.get_style_context().add_class("param-group")
        csc_lbl = Gtk.Label(label="CSC Mode")
        csc_lbl.set_xalign(0)
        csc_lbl.get_style_context().add_class("group-label")
        self.csc_group_box.pack_start(csc_lbl, False, False, 0)
        self.csc_combo = Gtk.ComboBoxText()
        self.csc_combo.append_text("0: Passthrough")
        self.csc_combo.append_text("1: RGB -> YCbCr HD (BT.709)")
        self.csc_combo.append_text("2: YCbCr HD -> RGB")
        self.csc_combo.append_text("3: RGB -> YCbCr SD (BT.601)")
        self.csc_combo.append_text("4: YCbCr SD -> RGB")
        self.csc_combo.set_active(0)  # default passthrough
        self.csc_group_box.pack_start(self.csc_combo, False, False, 0)
        sidebar.pack_start(self.csc_group_box, False, False, 0)

        # ?? TPG Color Space ???????????????????????????????????????????????????
        self.tpg_cs_group_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.tpg_cs_group_box.get_style_context().add_class("param-group")
        tpg_cs_lbl = Gtk.Label(label="TPG Color Space")
        tpg_cs_lbl.set_xalign(0)
        tpg_cs_lbl.get_style_context().add_class("group-label")
        self.tpg_cs_group_box.pack_start(tpg_cs_lbl, False, False, 0)
        self.tpg_cs_combo = Gtk.ComboBoxText()
        self.tpg_cs_combo.append_text("0 - RGB")
        self.tpg_cs_combo.append_text("1 - YUV 4:4:4")
        self.tpg_cs_combo.append_text("2 - YUV 4:2:2")
        self.tpg_cs_combo.append_text("3 - YUV 4:2:0")
        self.tpg_cs_combo.set_active(1)  # default YUV 4:4:4
        self.tpg_cs_combo.connect("changed", self._on_tpg_cs_changed)
        self.tpg_cs_group_box.pack_start(self.tpg_cs_combo, False, False, 0)
        sidebar.pack_start(self.tpg_cs_group_box, False, False, 0)

        # Debug checkbox
        self.debug_checkbox = Gtk.CheckButton(label="Enable Debugging Mode")
        self.debug_checkbox.get_style_context().add_class("debug-checkbox")
        sidebar.pack_start(self.debug_checkbox, False, False, 5)

        # Apply button
        apply_btn = Gtk.Button(label="?  Run Simulation")
        apply_btn.get_style_context().add_class("apply-button")
        apply_btn.connect("clicked", self.on_apply_clicked)
        sidebar.pack_end(apply_btn, False, False, 20)

        # ?? Viewer Area ???????????????????????????????????????????????????????
        viewer_container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        viewer_container.set_margin_top(30)
        viewer_container.set_margin_bottom(30)
        viewer_container.set_margin_start(30)
        viewer_container.set_margin_end(30)
        content_panes.pack_start(viewer_container, True, True, 0)

        self.image_container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.image_container.get_style_context().add_class("image-container")
        viewer_container.pack_start(self.image_container, True, True, 0)

        self.image_widget = Gtk.Image()
        self.image_container.pack_start(self.image_widget, True, True, 0)

        self.info_label = Gtk.Label(label="")
        self.info_label.get_style_context().add_class("info-text")
        viewer_container.pack_start(self.info_label, False, False, 0)

        # Auto-sync scaler dims with input dims for non-scaler topologies
        self.params["tpg_w"].connect("value-changed", self._on_input_res_changed)
        self.params["tpg_h"].connect("value-changed", self._on_input_res_changed)

        # Initial UI state
        self._update_topology_ui()
        self._show_source_image(self.radio_image.get_active())
        self._on_pip_toggled(None)

    # ?? Topology UI ???????????????????????????????????????????????????????????

    def _get_topology(self):
        return TOPOLOGIES[self.topo_combo.get_active()]

    def on_topology_changed(self, widget):
        topo = self._get_topology()
        self.topo_desc.set_text(TOPOLOGY_META[topo]["desc"])
        self._update_topology_ui()

    def _on_input_res_changed(self, widget):
        # If current topology has no scaler, keep scaler spinners in sync
        meta = TOPOLOGY_META[self._get_topology()]
        if not meta["scl"] and "scale_w" in self.params:
            self.params["scale_w"].set_value(self.params["tpg_w"].get_value())
            self.params["scale_h"].set_value(self.params["tpg_h"].get_value())

    def _get_crs_mode(self):
        # Returns 0, 2, or 3
        idx = self.crs_combo.get_active()
        return [0, 2, 3][idx] if idx >= 0 else 3

    def _get_csc_mode(self):
        return self.csc_combo.get_active()  # 0-4

    def _get_tpg_colorspace(self):
        # 0=RGB, 1=YUV444, 2=YUV422, 3=YUV420 (combo index == value)
        idx = self.tpg_cs_combo.get_active()
        return idx if idx >= 0 else 1

    def _get_vid_planes(self):
        # Datapath color planes: 3 for RGB/4:4:4, 2 for 4:2:2/4:2:0.
        # Must match the generated pipeline IP's NUMBER_OF_COLOR_PLANES.
        return 2 if self._get_tpg_colorspace() in (2, 3) else 3

    def _get_output_format(self):
        # Decode format of the pipeline OUTPUT (what sc_data.txt holds):
        #   0=RGB, 1=YUV444, 2=YUV422, 3=YUV420
        # This is NOT the TPG input colorspace: CSC swaps RGB<->YCbCr and CRS
        # changes chroma subsampling, so the output can differ from the input.
        # Data-plane order is CRS -> CSC, and CSC works in 4:4:4, so CSC has the
        # final say on colorspace.
        meta = TOPOLOGY_META[self._get_topology()]
        fmt = self._get_tpg_colorspace()           # input colorspace
        if meta["crs"]:
            crs = self._get_crs_mode()             # 0=420, 2=422, 3=444
            fmt = {3: 1, 2: 2, 0: 3}.get(crs, 1)   # YCbCr at that subsampling
        if meta["csc"]:
            mode = self._get_csc_mode()
            if mode in (1, 3):                     # RGB -> YCbCr (4:4:4)
                fmt = 1
            elif mode in (2, 4):                   # YCbCr -> RGB
                fmt = 0
            # mode 0 (passthrough): keep current fmt
        return fmt

    def _get_pip_color(self):
        # 0=Red, 1=Green, 2=Blue (VPSS R/G/B-only convention)
        idx = self.pip_color_combo.get_active()
        return idx if idx >= 0 else 2  # default Blue

    def _get_pip_position(self):
        idx = self.pip_pos_combo.get_active()
        names = ("center", "top-left", "top-right", "bottom-left", "bottom-right", "custom")
        return names[idx] if 0 <= idx < len(names) else "center"

    def _on_pip_pos_changed(self, widget):
        is_custom = self._get_pip_position() == "custom"
        enabled = self.pip_checkbox.get_active()
        self.params['pip_h_off'].set_sensitive(enabled and is_custom)
        self.params['pip_v_off'].set_sensitive(enabled and is_custom)

    def _on_tpg_cs_changed(self, widget):
        # The CSC dropdown has no memory of which TPG format it was last set
        # up for - if the user manually picked a YCbCr<->RGB conversion for
        # one test, then changed the TPG format for a different test without
        # touching CSC again, the stale conversion silently carried over and
        # produced a broken composite (confirmed: reproduced byte-for-byte
        # identical output this way). Snap CSC back to passthrough on every
        # TPG format change so each test starts from a safe, explicit choice
        # - RGB's own case still gets auto-forced to the correct conversion
        # by _update_pip_colorspace_lock right after.
        if hasattr(self, "csc_combo"):
            self.csc_combo.set_active(0)  # passthrough
        self._update_pip_colorspace_lock()

    def _update_pip_colorspace_lock(self):
        # The PIP background TPG is hardware-fixed to YCbCr (4:4:4) - the main
        # video must reach the mixer in the same encoding or the two layers
        # decode inconsistently.
        #  - CSC-capable topology (FULL/CSC_ONLY/CRS_CSC): TPG can be RGB (or
        #    any YCbCr variant) - CSC is force-set to convert RGB->YCbCr (SD/
        #    BT.601) whenever RGB is chosen, so the final stream entering the
        #    mixer is always YCbCr 4:4:4.
        #  - No-CSC topology: there's no way to convert RGB, so lock to
        #    YUV444 (the TPG's native encoding, matching the background).
        enabled = self.pip_checkbox.get_active()
        has_csc = TOPOLOGY_META[self._get_topology()]["csc"]
        if enabled and not has_csc:
            self.tpg_cs_combo.set_active(1)  # force YUV444
        self.tpg_cs_combo.set_sensitive(
            not self.radio_image.get_active() and (not enabled or has_csc))
        if hasattr(self, "csc_combo"):
            pip_rgb = enabled and has_csc and self._get_tpg_colorspace() == 0
            if pip_rgb:
                self.csc_combo.set_active(3)  # force RGB -> YCbCr SD (BT.601)
            self.csc_combo.set_sensitive(has_csc and not pip_rgb)

    def _on_pip_toggled(self, widget):
        enabled = self.pip_checkbox.get_active()
        self.pip_color_combo.set_sensitive(enabled)
        self.params['pip_bg_w'].set_sensitive(enabled)
        self.params['pip_bg_h'].set_sensitive(enabled)
        self.pip_pos_combo.set_sensitive(enabled)
        self._on_pip_pos_changed(None)
        self._update_pip_colorspace_lock()

    def _update_topology_ui(self):
        topo = self._get_topology()
        meta = TOPOLOGY_META[topo]
        # Set sensitivity directly on individual spinners
        for key in ["clip_top", "clip_bottom", "clip_left", "clip_right"]:
            if key in self.params:
                self.params[key].set_sensitive(meta["clip"])
        for key in ["scale_w", "scale_h"]:
            if key in self.params:
                self.params[key].set_sensitive(meta["scl"])
        # CRS dropdown (CSC sensitivity handled by _update_pip_colorspace_lock)
        if hasattr(self, 'crs_combo'):
            self.crs_combo.set_sensitive(meta["crs"])
        self._update_pip_colorspace_lock()
        # When no scaler: auto-set scaler spinners to match input resolution
        # so user sees the actual output dimensions even though they're grayed out
        if not meta["scl"] and "scale_w" in self.params and "tpg_w" in self.params:
            self.params["scale_w"].set_value(self.params["tpg_w"].get_value())
            self.params["scale_h"].set_value(self.params["tpg_h"].get_value())

    # ?? Presets ???????????????????????????????????????????????????????????????

    def _preset_path(self, name):
        return os.path.join(PRESETS_DIR, f"{name}.json")

    def _refresh_preset_list(self):
        # Remove all items except the placeholder (index 0)
        while self.preset_combo.get_model() and len(self.preset_combo.get_model()) > 1:
            self.preset_combo.remove(1)
        presets = sorted(f[:-5] for f in os.listdir(PRESETS_DIR) if f.endswith(".json"))
        for p in presets:
            self.preset_combo.append_text(p)

    def on_save_preset(self, widget):
        name = self.preset_name_entry.get_text().strip()
        if not name:
            self.status_badge.set_text("Enter a preset name first")
            return
        # Sanitize name
        name = re.sub(r'[^\w\-]', '_', name)
        data = {
            "topology":  self._get_topology(),
            "input_sel": self.radio_image.get_active(),
            "params":    {k: v.get_value_as_int() for k, v in self.params.items()},
            "debug":     self.debug_checkbox.get_active(),
            "crs_mode":  self._get_crs_mode(),
            "csc_mode":  self._get_csc_mode(),
            "tpg_cs":    self._get_tpg_colorspace(),
            "pip_enabled":  self.pip_checkbox.get_active(),
            "pip_color":    self._get_pip_color(),
            "pip_position": self._get_pip_position(),
        }
        with open(self._preset_path(name), "w") as f:
            json.dump(data, f, indent=2)
        self._refresh_preset_list()
        self.preset_name_entry.set_text("")
        self.status_badge.set_text(f"Saved: {name}")

    def on_load_preset(self, widget):
        idx = self.preset_combo.get_active()
        if idx <= 0:
            return
        name = self.preset_combo.get_active_text()
        path = self._preset_path(name)
        if not os.path.exists(path):
            self.status_badge.set_text("Preset file not found")
            return
        with open(path) as f:
            data = json.load(f)

        # Restore topology
        topo = data.get("topology", "FULL")
        if topo in TOPOLOGIES:
            self.topo_combo.set_active(TOPOLOGIES.index(topo))

        # Restore params
        for k, v in data.get("params", {}).items():
            if k in self.params:
                self.params[k].set_value(v)

        # Restore source
        use_image = data.get("input_sel", False)
        self.radio_image.set_active(use_image)
        self.radio_tpg.set_active(not use_image)

        # Restore debug
        self.debug_checkbox.set_active(data.get("debug", False))

        # Restore CRS mode
        crs = data.get("crs_mode", 3)
        crs_map = {0: 0, 2: 1, 3: 2}
        self.crs_combo.set_active(crs_map.get(crs, 2))

        # Restore CSC mode
        csc = data.get("csc_mode", 0)
        if 0 <= csc <= 4:
            self.csc_combo.set_active(csc)

        # Restore TPG color space
        tpg_cs = data.get("tpg_cs", 1)
        if 0 <= tpg_cs <= 3:
            self.tpg_cs_combo.set_active(tpg_cs)

        # Restore PIP settings
        self.pip_checkbox.set_active(data.get("pip_enabled", False))
        pip_color = data.get("pip_color", 2)
        if 0 <= pip_color <= 2:
            self.pip_color_combo.set_active(pip_color)
        pip_pos = data.get("pip_position", "center")
        pos_names = ("center", "top-left", "top-right", "bottom-left", "bottom-right", "custom")
        if pip_pos in pos_names:
            self.pip_pos_combo.set_active(pos_names.index(pip_pos))
        self._on_pip_toggled(None)

        self.status_badge.set_text(f"Loaded: {name}")

    # ?? Source toggle ?????????????????????????????????????????????????????????

    def _get_image_dims(self):
        img_path = os.path.join(BASE_DIR, "image.png")
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file(img_path)
            return pixbuf.get_width(), pixbuf.get_height()
        except Exception:
            return None, None

    def _on_source_toggled(self, widget):
        use_image = self.radio_image.get_active()
        if use_image:
            w, h = self._get_image_dims()
            if w is not None:
                self.params['tpg_w'].set_value(w)
                self.params['tpg_h'].set_value(h)
                self.img_dim_hint.set_text(f"  image.png detected: {w} x {h}")
                self.res_group_label.set_text("Input Resolution  (from image.png)")
            else:
                self.img_dim_hint.set_text("  Warning: image.png not found!")
                self.res_group_label.set_text("Input Resolution  (image.png MISSING)")
            self.params['tpg_w'].set_sensitive(False)
            self.params['tpg_h'].set_sensitive(False)
        else:
            self.params['tpg_w'].set_sensitive(True)
            self.params['tpg_h'].set_sensitive(True)
            self.img_dim_hint.set_text("")
            self.res_group_label.set_text("Input Resolution")
        # TPG color space only applies to the TPG input path
        if hasattr(self, "tpg_cs_combo"):
            self.tpg_cs_combo.set_sensitive(not use_image)
        self._show_source_image(use_image)

    def _show_source_image(self, use_image):
        fname = "image.png" if use_image else "tpg.png"
        path  = os.path.join(BASE_DIR, fname)
        try:
            if os.path.exists(path):
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(path)
                self.image_widget.set_from_pixbuf(pixbuf)
                if hasattr(self, "info_label"):
                    self.info_label.set_text(
                        f"Source: {fname}  ({pixbuf.get_width()}x{pixbuf.get_height()})"
                    )
            else:
                if hasattr(self, "info_label"):
                    self.info_label.set_text(f"{fname} not found in app folder.")
        except Exception as e:
            print(f"Image load error: {e}")

    # ?? Write topology to tb.v and top.v ??????????????????????????????????????

    def _patch_topology_in_rtl(self, topology, csc_mode, crs_mode):
        rtl_dir = os.path.join(BASE_DIR, "..", "rtl")
        tb_path  = os.path.join(rtl_dir, "tb.v")
        top_path = os.path.join(rtl_dir, "top.v")

        # Debug - print resolved paths
        print(f"[PATCH] tb_path  = {tb_path}  exists={os.path.exists(tb_path)}")
        print(f"[PATCH] top_path = {top_path}  exists={os.path.exists(top_path)}")
        print(f"[PATCH] topology={topology} csc_mode={csc_mode} crs_mode={crs_mode}")

        # Patch tb.v: localparam TOPOLOGY = "...";
        if os.path.exists(tb_path):
            with open(tb_path) as f:
                c = f.read()
            c = re.sub(
                r'(localparam\s+TOPOLOGY\s*=\s*)"[^"]*"',
                f'\\1"{topology}"',
                c
            )
            with open(tb_path, "w") as f:
                f.write(c)

        # Patch top.v: TOPOLOGY, CSC_MODE, CRS_OUTPUT_MODE
        if os.path.exists(top_path):
            with open(top_path) as f:
                c = f.read()
            c = re.sub(
                r'(parameter\s+TOPOLOGY\s*=\s*)"[^"]*"',
                f'\\1"{topology}"',
                c
            )
            c = re.sub(
                r'(parameter\s+\[2:0\]\s+CSC_MODE\s*=\s*)3\'d\d+',
                f'\\1 3\'d{csc_mode}',
                c
            )
            c = re.sub(
                r'(parameter\s+\[31:0\]\s+CRS_OUTPUT_MODE\s*=\s*)32\'d\d+',
                f'\\1 32\'d{crs_mode}',
                c
            )
            with open(top_path, "w") as f:
                f.write(c)

    # ?? Apply / Run ???????????????????????????????????????????????????????????

    def on_apply_clicked(self, widget):
        is_debugging = self.debug_checkbox.get_active()
        use_image    = self.radio_image.get_active()
        topology     = self._get_topology()
        values       = {k: v.get_value_as_int() for k, v in self.params.items()}

        config_path        = os.path.join(BASE_DIR, "pipeline_config.txt")
        vh_path            = os.path.join(BASE_DIR, "configuration.vh")
        run_project_script = os.path.join(BASE_DIR, "runProject.py")
        hex_to_png_script  = os.path.join(BASE_DIR, "hex_to_png.py")
        png_to_hex_script  = os.path.join(BASE_DIR, "png_to_hex.py")

        if use_image:
            img_w, img_h = self._get_image_dims()
            if img_w is None:
                self.status_badge.set_text("ERROR: image.png not found")
                return
            values['tpg_w'] = img_w
            values['tpg_h'] = img_h

        try:
            # 1. Compute correct output dimensions based on topology
            meta = TOPOLOGY_META[topology]
            if meta["scl"]:
                out_w = values["scale_w"]
                out_h = values["scale_h"]
            else:
                # No scaler - output dims = input dims
                out_w = values["tpg_w"]
                out_h = values["tpg_h"]

            pip_enabled = self.pip_checkbox.get_active()
            pip_color   = self._get_pip_color()
            pip_pos     = self._get_pip_position()
            has_csc     = meta["csc"]

            # PIP background TPG is hardware-fixed to YCbCr 4:4:4. On a
            # CSC-capable topology the main video can be RGB (or any YCbCr
            # variant) since CSC converts it to YCbCr before the mixer; on a
            # topology without CSC there's no way to convert RGB, so it's
            # locked to YUV444 to match the background.
            tpg_cs   = self._get_tpg_colorspace() if (not pip_enabled or has_csc) else 1
            pip_rgb  = pip_enabled and has_csc and tpg_cs == 0
            csc_mode = 3 if pip_rgb else self._get_csc_mode()  # 3 = RGB->YCbCr SD (BT.601)

            # 2. Patch topology, CSC mode, CRS mode in RTL files
            self._patch_topology_in_rtl(topology, csc_mode, self._get_crs_mode())

            # When PIP is on, the mixer's output canvas is the PIP background
            # size, not the pipeline's own output size, so the render step
            # needs that size regardless of the topology's own settings.
            # The final stream is YCbCr 4:4:4 in every case except one: CSC
            # set to a YCbCr->RGB mode (2 or 4) genuinely converts the video
            # to RGB before it reaches the mixer, and top.v calibrates the
            # PIP background to match with literal RGB values in that case
            # too - so the render step must decode as RGB here, not YCbCr,
            # or the (correct) captured bytes get mis-decoded.
            pip_csc_to_rgb = pip_enabled and csc_mode in (2, 4)
            render_w      = values["pip_bg_w"] if pip_enabled else out_w
            render_h      = values["pip_bg_h"] if pip_enabled else out_h
            if pip_enabled:
                output_format = 0 if pip_csc_to_rgb else 1
            else:
                output_format = self._get_output_format()

            # Inset position within the background canvas.
            max_h_off = max(0, values["pip_bg_w"] - out_w)
            max_v_off = max(0, values["pip_bg_h"] - out_h)
            if pip_pos == "custom":
                pip_h_off = min(values["pip_h_off"], max_h_off)
                pip_v_off = min(values["pip_v_off"], max_v_off)
            elif pip_pos == "top-left":
                pip_h_off, pip_v_off = 0, 0
            elif pip_pos == "top-right":
                pip_h_off, pip_v_off = max_h_off, 0
            elif pip_pos == "bottom-left":
                pip_h_off, pip_v_off = 0, max_v_off
            elif pip_pos == "bottom-right":
                pip_h_off, pip_v_off = max_h_off, max_v_off
            else:  # center
                pip_h_off, pip_v_off = max_h_off // 2, max_v_off // 2

            # Note: the mixer's one-time settling artifact on the first row it
            # composites in a field is now handled transparently in tb.v (a
            # hidden guard row is added to the real hardware canvas/offset and
            # cropped from the capture) - no compromise needed here, V offset
            # 0 (flush at the very top) works exactly as requested.

            # Write pipeline_config.txt
            with open(config_path, "w") as f:
                f.write(f"debug_mode = {is_debugging}\n")
                f.write(f"input_source = {'image' if use_image else 'tpg'}\n")
                f.write(f"topology = {topology}\n")
                for k, v in values.items():
                    if k not in ("scale_w", "scale_h"):
                        f.write(f"{k} = {v}\n")
                # Always write correct output dims for hex_to_png.py
                # For non-scaler modes this = input dims, for scaler modes = scaler
                # output (or the PIP background canvas size, when PIP is enabled)
                f.write(f"scale_w = {render_w}\n")
                f.write(f"scale_h = {render_h}\n")
                # TPG color space: 0=RGB, 1=YUV444, 2=YUV422, 3=YUV420
                f.write(f"tpg_colorspace = {tpg_cs}\n")
                # Datapath color planes (3 for RGB/444, 2 for 422/420)
                f.write(f"vid_planes = {self._get_vid_planes()}\n")
                # Actual pipeline OUTPUT format for the decoder (after CSC/CRS)
                f.write(f"output_format = {output_format}\n")
                f.write(f"pip_enable = {1 if pip_enabled else 0}\n")
                f.write(f"pip_bg_color = {pip_color}\n")
                f.write(f"pip_position = {pip_pos}\n")
                f.write(f"pip_h_offset = {pip_h_off}\n")
                f.write(f"pip_v_offset = {pip_v_off}\n")

            # 3. Write configuration.vh
            with open(vh_path, "w") as f:
                f.write("// Auto-generated Configuration Header\n\n")
                f.write(f"parameter DEBUG_MODE      = {1 if is_debugging else 0};\n")
                f.write(f"parameter INPUT_SEL       = {1 if use_image else 0};\n")
                f.write(f"parameter TPG_WIDTH       = {values['tpg_w']};\n")
                f.write(f"parameter TPG_HEIGHT      = {values['tpg_h']};\n")
                f.write(f"parameter CLIPPER_TOP     = {values['clip_top']};\n")
                f.write(f"parameter CLIPPER_BOTTOM  = {values['clip_bottom']};\n")
                f.write(f"parameter CLIPPER_LEFT    = {values['clip_left']};\n")
                f.write(f"parameter CLIPPER_RIGHT   = {values['clip_right']};\n")
                f.write(f"parameter SCALER_WIDTH    = {out_w};\n")
                f.write(f"parameter SCALER_HEIGHT   = {out_h};\n")
                f.write(f"parameter TPG_COLORSPACE  = {tpg_cs};\n")
                f.write(f"parameter VID_PLANES      = {self._get_vid_planes()};\n")
                f.write(f"parameter PIP_ENABLE      = {1 if pip_enabled else 0};\n")
                f.write(f"parameter PIP_BG_COLOR    = {pip_color};\n")
                f.write(f"parameter PIP_BG_W        = {values['pip_bg_w']};\n")
                f.write(f"parameter PIP_BG_H        = {values['pip_bg_h']};\n")
                f.write(f"parameter PIP_H_OFF       = {pip_h_off};\n")
                f.write(f"parameter PIP_V_OFF       = {pip_v_off};\n")

            def run_pipeline():
                try:
                    if use_image:
                        GLib.idle_add(self.status_badge.set_text, "CONVERTING IMAGE...")
                        result = subprocess.run(
                            ["python3", png_to_hex_script],
                            capture_output=True, text=True, check=True
                        )
                        for line in result.stdout.splitlines():
                            if line.startswith("SUCCESS"):
                                print(f"[PNG?HEX] {line}")

                    GLib.idle_add(self.status_badge.set_text, f"SIMULATING [{topology}]...")
                    subprocess.run(
                        ["python3", run_project_script, str(is_debugging)],
                        check=True
                    )
                    subprocess.run(["python3", hex_to_png_script], check=True)
                    GLib.idle_add(self.update_badge_finished, use_image, values)
                except Exception as e:
                    print(f"Pipeline Error: {e}")
                    GLib.idle_add(self.update_badge_error)

            threading.Thread(target=run_pipeline, daemon=True).start()
            self.status_badge.set_text("PROCESSING...")
            self.status_badge.get_style_context().remove_class("success-badge")

        except Exception as e:
            print(f"Save Error: {e}")

    def update_badge_finished(self, used_image, values):
        topo = self._get_topology()
        self.status_badge.set_text(f"READY [{topo}]")
        self.status_badge.get_style_context().add_class("success-badge")

        # Show result image
        result_path = os.path.join(BASE_DIR, "result.png")
        if os.path.exists(result_path):
            try:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(result_path)
                self.image_widget.set_from_pixbuf(pixbuf)
                self.info_label.set_text(
                    f"Result: {topo} | {pixbuf.get_width()}x{pixbuf.get_height()} | "
                    f"Input: {values['tpg_w']}x{values['tpg_h']}"
                )
            except Exception as e:
                print(f"Result image load error: {e}")
        else:
            self._show_source_image(used_image)
        return False

    def update_badge_error(self):
        self.status_badge.set_text("PIPELINE FAILED")
        return False

    # ?? Styling ???????????????????????????????????????????????????????????????

    def apply_styling(self):
        style_provider = Gtk.CssProvider()
        css = """
            window { background-color: #0f172a; }
            .header-bar { background-color: #1e293b; padding: 15px 0;
                          border-bottom: 2px solid #334155; }
            .header-title { color: #f8fafc; font-size: 20px; font-weight: 800; }
            .status-badge { background-color: #0ea5e9; color: white;
                            padding: 4px 12px; border-radius: 100px;
                            font-size: 11px; font-weight: bold; }
            .success-badge { background-color: #10b981; }
            .sidebar { background-color: #1e293b; border-right: 1px solid #334155;
                       padding: 20px; }
            .sidebar-title { color: #94a3b8; font-size: 12px; font-weight: 700; }
            .param-group { color: #94a3b8; background-color: rgba(255,255,255,0.03);
                           padding: 15px; border-radius: 12px;
                           border: 1px solid rgba(255,255,255,0.05); }
            .group-label { color: #38bdf8; font-weight: 700; font-size: 13px;
                           margin-bottom: 5px; }
            .src-radio label { color: #cbd5e1; font-size: 13px; }
            .dim-hint { color: #86efac; font-size: 11px; font-style: italic; }
            button.apply-button {
                background-image: none; background-color: #10b981;
                border-radius: 8px; padding: 12px; margin-top: 10px;
                border: none; box-shadow: none;
            }
            button.apply-button label { color: #000000; font-weight: 800; }
            button.apply-button:hover { background-color: #34d399; }
            button.mini-btn {
                background-image: none; background-color: #0ea5e9;
                border-radius: 6px; padding: 4px 10px; border: none;
            }
            button.mini-btn label { color: white; font-weight: 700; font-size: 12px; }
            button.mini-btn:hover { background-color: #38bdf8; }
            button.mini-btn-save {
                background-image: none; background-color: #8b5cf6;
                border-radius: 6px; padding: 4px 10px; border: none;
            }
            button.mini-btn-save label { color: white; font-weight: 700; font-size: 12px; }
            button.mini-btn-save:hover { background-color: #a78bfa; }
            .debug-checkbox label { color: #cbd5e1; font-size: 13px; }
            spinbutton { background-color: #0f172a; color: white;
                         border: 1px solid #334155; border-radius: 6px; }
            spinbutton:disabled { color: #475569; }
            entry { background-color: #0f172a; color: white;
                    border: 1px solid #334155; border-radius: 6px; padding: 4px 8px; }
            combobox { background-color: #0f172a; color: white; border-radius: 6px; }
            .image-container { background-color: #020617; border-radius: 16px;
                               padding: 15px; border: 1px solid #334155; }
            .info-text { color: #64748b; font-size: 12px; }
        """
        style_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )


if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    img_path = os.path.join(current_dir, "tpg.png")
    if len(sys.argv) > 1:
        img_path = sys.argv[1]

    win = ImageViewerWindow(img_path)
    win.show_all()
    Gtk.main()
