#!/usr/bin/python3
import os
import sys
import subprocess
import threading

# Aesthetic check: Ensure we are using the correct python for system libraries
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

        # Main Layout Container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(main_box)

        # Header Bar
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        header.get_style_context().add_class("header-bar")
        header_label = Gtk.Label(label="Video Pipeline Control Center")
        header_label.get_style_context().add_class("header-title")
        header.pack_start(header_label, False, False, 20)
        
        self.status_badge = Gtk.Label(label="CONNECTED")
        self.status_badge.get_style_context().add_class("status-badge")
        header.pack_end(self.status_badge, False, False, 20)
        main_box.pack_start(header, False, False, 0)

        # Main Content
        content_panes = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        main_box.pack_start(content_panes, True, True, 0)

        # Sidebar
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        sidebar.get_style_context().add_class("sidebar")
        sidebar.set_size_request(300, -1)
        content_panes.pack_start(sidebar, False, False, 0)

        sidebar_title = Gtk.Label(label="Parameters")
        sidebar_title.get_style_context().add_class("sidebar-title")
        sidebar.pack_start(sidebar_title, False, False, 10)

        # Configuration Groups
        self.params = {}
        self.add_param_group(sidebar, "Test Pattern Generator", [
            ("TPG Width", "tpg_w", 32),
            ("TPG Height", "tpg_h", 32)
        ])
        
        self.add_param_group(sidebar, "Clipper Offsets", [
            ("Top Offset", "clip_top", 2),
            ("Bottom Offset", "clip_bottom", 2),
            ("Left Offset", "clip_left", 2),
            ("Right Offset", "clip_right", 2)
        ])
        
        self.add_param_group(sidebar, "Scaler Output", [
            ("Scaler Width", "scale_w", 128),
            ("Scaler Height", "scale_h", 128)
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

        # Viewer Area
        viewer_container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        # GTK 3 specific margin settings
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
                self.info_label = Gtk.Label(label=f"Buffer: {pixbuf.get_width()}x{pixbuf.get_height()}")
            else:
                self.info_label = Gtk.Label(label="No image found. Run pipeline to generate.")
            
            self.info_label.get_style_context().add_class("info-text")
            viewer_container.pack_start(self.info_label, False, False, 0)
        except Exception as e:
            err = Gtk.Label(label=f"Load Error: {e}")
            self.image_container.pack_start(err, True, True, 0)

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
            
            adj = Gtk.Adjustment(value=default, lower=0, upper=8192, step_increment=1)
            spin = Gtk.SpinButton(adjustment=adj, climb_rate=1, digits=0)
            spin.set_width_chars(6)
            hbox.pack_end(spin, False, False, 0)
            
            self.params[key] = spin
            group_box.pack_start(hbox, False, False, 0)

        parent.pack_start(group_box, False, False, 0)

    def on_apply_clicked(self, widget):
        is_debugging = self.debug_checkbox.get_active()
        values = {k: v.get_value_as_int() for k, v in self.params.items()}
        base_dir = os.path.dirname(os.path.abspath(__file__))
        
        config_path = os.path.join(base_dir, "pipeline_config.txt")
        vh_path = os.path.join(base_dir, "configuration.vh")
        run_project_script = os.path.join(base_dir, "runProject.py")
        hex_to_png_script = os.path.join(base_dir, "hex_to_png.py")

        try:
            # 1. Write Text Config
            with open(config_path, "w") as f:
                f.write(f"debug_mode = {is_debugging}\n")
                for k, v in values.items():
                    f.write(f"{k} = {v}\n")

            # 2. Write Verilog Header (.vh) with EXACT names for tb.v
            with open(vh_path, "w") as f:
                f.write("// Auto-generated Configuration Header\n\n")
                f.write(f"parameter DEBUG_MODE      = {1 if is_debugging else 0};\n")
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
                    # Pass debugging flag to runProject.py
                    subprocess.run(["python3", run_project_script, str(is_debugging)], check=True)
                    # Convert result
                    subprocess.run(["python3", hex_to_png_script], check=True)
                    GLib.idle_add(self.update_badge_finished)
                except Exception as e:
                    print(f"Pipeline Error: {e}")
                    GLib.idle_add(self.update_badge_error)

            threading.Thread(target=run_pipeline, daemon=True).start()
            self.status_badge.set_text("PROCESSING...")
            self.status_badge.get_style_context().remove_class("success-badge")

        except Exception as e:
            print(f"Save Error: {e}")

    def update_badge_finished(self):
        self.status_badge.set_text("IMAGE READY")
        self.status_badge.get_style_context().add_class("success-badge")
        
        # Refresh the image in the UI
        try:
            base_dir = os.path.dirname(os.path.abspath(__file__))
            result_path = os.path.join(base_dir, "tpg.png")
            if os.path.exists(result_path):
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(result_path)
                self.image_widget.set_from_pixbuf(pixbuf)
                self.info_label.set_text(f"Buffer: {pixbuf.get_width()}x{pixbuf.get_height()}")
        except Exception as e:
            print(f"UI Refresh Error: {e}")
        return False

    def update_badge_error(self):
        self.status_badge.set_text("PIPELINE FAILED")
        return False

    def apply_styling(self):
        style_provider = Gtk.CssProvider()
        css = """
            window { background-color: #0f172a; }
            .header-bar { background-color: #1e293b; padding: 15px 0; border-bottom: 2px solid #334155; }
            .header-title { color: #f8fafc; font-size: 20px; font-weight: 800; }
            .status-badge { background-color: #0ea5e9; color: white; padding: 4px 12px; border-radius: 100px; font-size: 11px; font-weight: bold; }
            .success-badge { background-color: #10b981; }
            .sidebar { background-color: #1e293b; border-right: 1px solid #334155; padding: 20px; }
            .sidebar-title { color: #94a3b8; font-size: 12px; font-weight: 700; }
            .param-group { color: #94a3b8; background-color: rgba(255,255,255,0.03); padding: 15px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.05); }
            .group-label { color: #38bdf8; font-weight: 700; font-size: 13px; margin-bottom: 5px; }
            
            /* Emerald Button styling */
            button.apply-button { 
                background-image: none;
                background-color: #10b981; 
                border-radius: 8px; 
                padding: 12px; 
                margin-top: 10px;
                border: none;
                box-shadow: none;
            }
            button.apply-button label { 
                color: #000000; 
                font-weight: 800; 
            }
            button.apply-button:hover { 
                background-color: #34d399; 
            }
            
            .debug-checkbox label { color: #cbd5e1; font-size: 13px; }
            spinbutton { background-color: #0f172a; color: white; border: 1px solid #334155; border-radius: 6px; }
            .image-container { background-color: #020617; border-radius: 16px; padding: 15px; border: 1px solid #334155; }
            .info-text { color: #64748b; font-size: 12px; }
        """
        style_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    img_path = os.path.join(current_dir, "tpg.png")
    if len(sys.argv) > 1: img_path = sys.argv[1]
    
    win = ImageViewerWindow(img_path)
    win.show_all()
    Gtk.main()
