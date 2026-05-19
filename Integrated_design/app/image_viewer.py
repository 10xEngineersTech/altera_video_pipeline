#!/usr/bin/python3
import os
import sys
import subprocess
import threading

try:
    import gi
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk, GdkPixbuf, Gdk, GLib
except ImportError:
    print("\n[!] ERROR: Missing 'gi' module (PyGObject).")
    print(f"Current Python: {sys.executable}")
    print("Please run this script using the system Python: /usr/bin/python3\n")
    sys.exit(1)

class ImageViewerWindow(Gtk.Window):
    def __init__(self, image_path):
        super().__init__(title="Video Pipeline | Configuration & Viewer")
        self.set_default_size(1100, 800)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.connect("destroy", Gtk.main_quit)

        self.apply_styling()

        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(main_box)

        # Header
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        header.get_style_context().add_class("header-bar")
        header_label = Gtk.Label(label="Video Pipeline Control Center")
        header_label.get_style_context().add_class("header-title")
        header.pack_start(header_label, False, False, 20)

        self.status_badge = Gtk.Label(label="CONNECTED")
        self.status_badge.get_style_context().add_class("status-badge")
        header.pack_end(self.status_badge, False, False, 20)
        main_box.pack_start(header, False, False, 0)

        # Main content
        content_panes = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        main_box.pack_start(content_panes, True, True, 0)

        # ---- Sidebar ----
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        sidebar.get_style_context().add_class("sidebar")
        sidebar.set_size_request(310, -1)
        content_panes.pack_start(sidebar, False, False, 0)

        sidebar_title = Gtk.Label(label="Parameters")
        sidebar_title.get_style_context().add_class("sidebar-title")
        sidebar.pack_start(sidebar_title, False, False, 10)

        # --- Input Source Selector ---
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

        # Small hint shown when image source is active
        self.img_dim_hint = Gtk.Label(label="")
        self.img_dim_hint.set_xalign(0)
        self.img_dim_hint.get_style_context().add_class("dim-hint")
        src_box.pack_start(self.img_dim_hint, False, False, 0)

        sidebar.pack_start(src_box, False, False, 0)

        # Connect toggle handler AFTER both radios exist
        self.radio_image.connect("toggled", self._on_source_toggled)

        # --- Input Resolution (auto-locked when image source is selected) ---
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

        # --- Other parameter groups ---
        self.add_param_group(sidebar, "Clipper Offsets", [
            ("Top Offset",    "clip_top",    0),
            ("Bottom Offset", "clip_bottom", 0),
            ("Left Offset",   "clip_left",   0),
            ("Right Offset",  "clip_right",  0)
        ])

        self.add_param_group(sidebar, "Scaler Output", [
            ("Scaler Width",  "scale_w", 640),
            ("Scaler Height", "scale_h", 480)
        ])

        # Debugging Checkbox
        self.debug_checkbox = Gtk.CheckButton(label="Enable Debugging Mode")
        self.debug_checkbox.get_style_context().add_class("debug-checkbox")
        sidebar.pack_start(self.debug_checkbox, False, False, 5)

        # Apply Button
        apply_btn = Gtk.Button(label="Apply Settings")
        apply_btn.get_style_context().add_class("apply-button")
        apply_btn.connect("clicked", self.on_apply_clicked)
        sidebar.pack_end(apply_btn, False, False, 20)

        # ---- Viewer Area ----
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

        try:
            if os.path.exists(image_path):
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(image_path)
                self.image_widget.set_from_pixbuf(pixbuf)
                self.info_label = Gtk.Label(
                    label=f"Buffer: {pixbuf.get_width()}x{pixbuf.get_height()}")
            else:
                self.info_label = Gtk.Label(
                    label="No image found. Run pipeline to generate.")
            self.info_label.get_style_context().add_class("info-text")
            viewer_container.pack_start(self.info_label, False, False, 0)
        except Exception as e:
            err = Gtk.Label(label=f"Load Error: {e}")
            self.image_container.pack_start(err, True, True, 0)

    # -------------------------------------------------------------------------
    # Helpers
    # -------------------------------------------------------------------------

    def add_param_group(self, parent, title, fields):
        group_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        group_box.get_style_context().add_class("param-group")
        label = Gtk.Label(label=title)
        label.set_xalign(0)
        label.get_style_context().add_class("group-label")
        group_box.pack_start(label, False, False, 0)
        for name, key, default in fields:
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            field_label = Gtk.Label(label=name)
            field_label.set_xalign(0)
            hbox.pack_start(field_label, True, True, 0)
            adj  = Gtk.Adjustment(value=default, lower=0, upper=8192, step_increment=1)
            spin = Gtk.SpinButton(adjustment=adj, climb_rate=1, digits=0)
            spin.set_width_chars(6)
            hbox.pack_end(spin, False, False, 0)
            self.params[key] = spin
            group_box.pack_start(hbox, False, False, 0)
        parent.pack_start(group_box, False, False, 0)

    def _get_image_dims(self):
        """Return (width, height) of image.png using GdkPixbuf, or (None, None)."""
        base_dir = os.path.dirname(os.path.abspath(__file__))
        img_path = os.path.join(base_dir, "image.png")
        try:
            pixbuf = GdkPixbuf.Pixbuf.new_from_file(img_path)
            return pixbuf.get_width(), pixbuf.get_height()
        except Exception:
            return None, None

    # -------------------------------------------------------------------------
    # Signal handlers
    # -------------------------------------------------------------------------

    def _on_source_toggled(self, widget):
        """Called when the 'Image File' radio button changes state."""
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
            # Lock spinners — dimensions are dictated by the image file
            self.params['tpg_w'].set_sensitive(False)
            self.params['tpg_h'].set_sensitive(False)
        else:
            # Restore free editing
            self.params['tpg_w'].set_sensitive(True)
            self.params['tpg_h'].set_sensitive(True)
            self.img_dim_hint.set_text("")
            self.res_group_label.set_text("Input Resolution")

    def on_apply_clicked(self, widget):
        is_debugging = self.debug_checkbox.get_active()
        use_image    = self.radio_image.get_active()
        values       = {k: v.get_value_as_int() for k, v in self.params.items()}
        base_dir     = os.path.dirname(os.path.abspath(__file__))

        config_path        = os.path.join(base_dir, "pipeline_config.txt")
        vh_path            = os.path.join(base_dir, "configuration.vh")
        run_project_script = os.path.join(base_dir, "runProject.py")
        hex_to_png_script  = os.path.join(base_dir, "hex_to_png.py")
        png_to_hex_script  = os.path.join(base_dir, "png_to_hex.py")

        # When image source is active, use the actual image dimensions —
        # the spinners are locked to show them, but we read GdkPixbuf directly
        # to be authoritative.
        if use_image:
            img_w, img_h = self._get_image_dims()
            if img_w is None:
                self.status_badge.set_text("ERROR: image.png not found")
                return
            values['tpg_w'] = img_w
            values['tpg_h'] = img_h

        try:
            # 1. Write text config
            with open(config_path, "w") as f:
                f.write(f"debug_mode = {is_debugging}\n")
                f.write(f"input_source = {'image' if use_image else 'tpg'}\n")
                for k, v in values.items():
                    f.write(f"{k} = {v}\n")

            # 2. Write Verilog header (.vh)
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
                f.write(f"parameter SCALER_WIDTH    = {values['scale_w']};\n")
                f.write(f"parameter SCALER_HEIGHT   = {values['scale_h']};\n")

            def run_pipeline():
                try:
                    if use_image:
                        GLib.idle_add(self.status_badge.set_text, "CONVERTING IMAGE...")
                        # png_to_hex uses native image resolution — no resize
                        result = subprocess.run(
                            ["python3", png_to_hex_script],
                            capture_output=True, text=True, check=True
                        )
                        # Log the detected dimensions from stdout
                        for line in result.stdout.splitlines():
                            if line.startswith("SUCCESS"):
                                print(f"[PNG→HEX] {line}")

                    GLib.idle_add(self.status_badge.set_text, "SIMULATING...")
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
        self.status_badge.set_text("IMAGE READY")
        self.status_badge.get_style_context().add_class("success-badge")
        try:
            base_dir    = os.path.dirname(os.path.abspath(__file__))
            result_path = os.path.join(base_dir, "result.png")
            if not os.path.exists(result_path):
                result_path = os.path.join(base_dir, "tpg.png")
            if os.path.exists(result_path):
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(result_path)
                self.image_widget.set_from_pixbuf(pixbuf)
                src_tag = (f"image.png ({values['tpg_w']}x{values['tpg_h']})"
                           if used_image else "TPG")
                self.info_label.set_text(
                    f"Source: {src_tag}  →  "
                    f"Output: {pixbuf.get_width()}x{pixbuf.get_height()}"
                )
        except Exception as e:
            print(f"UI Refresh Error: {e}")
        return False

    def update_badge_error(self):
        self.status_badge.set_text("PIPELINE FAILED")
        return False

    # -------------------------------------------------------------------------
    # Styling
    # -------------------------------------------------------------------------

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
            .debug-checkbox label { color: #cbd5e1; font-size: 13px; }
            spinbutton { background-color: #0f172a; color: white;
                         border: 1px solid #334155; border-radius: 6px; }
            spinbutton:disabled { color: #475569; }
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
    img_path = os.path.join(current_dir, "result.png")
    if not os.path.exists(img_path):
        img_path = os.path.join(current_dir, "tpg.png")
    if len(sys.argv) > 1:
        img_path = sys.argv[1]

    win = ImageViewerWindow(img_path)
    win.show_all()
    Gtk.main()
