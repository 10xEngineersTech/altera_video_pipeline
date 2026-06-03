#!/usr/bin/python3
import cv2
import numpy as np
import os
import sys

# ─────────────────────────────────────────────────────────────────────────────
# Config Loader
# ─────────────────────────────────────────────────────────────────────────────
def load_config(config_file):
    cfg = {}
    if not os.path.exists(config_file):
        print(f"Warning: Config file {config_file} not found. Using defaults.")
        return {"scale_w": 640, "scale_h": 480}
    with open(config_file, 'r') as f:
        for line in f:
            if '=' in line:
                name, value = line.split('=')
                val_str = value.strip()
                if val_str.lower() == 'true':
                    cfg[name.strip()] = True
                elif val_str.lower() == 'false':
                    cfg[name.strip()] = False
                else:
                    try:
                        cfg[name.strip()] = int(val_str)
                    except ValueError:
                        cfg[name.strip()] = val_str
    return cfg

# ─────────────────────────────────────────────────────────────────────────────
# Shared Utilities
# ─────────────────────────────────────────────────────────────────────────────
def is_valid_hex(word):
    """Return False if the word contains Verilog 'x' or 'z' unknown values."""
    return not any(c in word.lower() for c in ('x', 'z'))

def ycbcr_to_rgb(y, cb, cr):
    """BT.601 full-range YCbCr → clipped RGB tuple."""
    cb -= 128
    cr -= 128
    r = y + 1.402    * cr
    g = y - 0.344136 * cb - 0.714136 * cr
    b = y + 1.772    * cb
    return (max(0, min(255, int(r))),
            max(0, min(255, int(g))),
            max(0, min(255, int(b))))

def load_and_clean(filename):
    """
    Load hex words from file, skip x/z words.
    Handles any whitespace layout (one word per line OR many per line).
    """
    try:
        with open(filename, 'r') as f:
            raw = f.read().split()       # split on ALL whitespace
    except FileNotFoundError:
        print(f"Error: {filename} not found.")
        sys.exit(1)

    valid   = [w for w in raw if is_valid_hex(w)]
    skipped = len(raw) - len(valid)
    if skipped:
        print(f"  Skipped {skipped} invalid (x/z) words.")

    print(f"  Found {len(valid)} pixel words.")
    return valid

# ─────────────────────────────────────────────────────────────────────────────
# Conversion Functions
# ─────────────────────────────────────────────────────────────────────────────
def convert_rgb(input_file, output_file, width, height):
    """
    RGB packed: tdata[23:0] = { R[7:0], G[7:0], B[7:0] }
    """
    pixel_words = load_and_clean(input_file)
    total       = width * height

    if len(pixel_words) < total:
        print(f"  Warning: only {len(pixel_words)} pixels found, "
              f"expected {total}. Padding with black.")

    raw_list = []
    for i in range(total):
        if i < len(pixel_words):
            h = pixel_words[i].zfill(6)
            r = int(h[0:2], 16)
            g = int(h[2:4], 16)
            b = int(h[4:6], 16)
        else:
            r, g, b = 0, 0, 0
        raw_list.append([b, g, r])       # OpenCV uses BGR order

    bgr = np.array(raw_list, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{height})")


def convert_yuv444(input_file, output_file, width, height):
    """
    YUV444 packed: tdata[23:0] = { Y[7:0], U[7:0], V[7:0] }
    One full chroma sample per pixel — no interpolation needed.
    """
    pixel_words = load_and_clean(input_file)
    total       = width * height

    if len(pixel_words) < total:
        print(f"  Warning: only {len(pixel_words)} pixels found, "
              f"expected {total}. Padding with black.")

    pixels = []
    for i in range(total):
        if i < len(pixel_words):
            val = int(pixel_words[i], 16)
            v   = (val >> 16) & 0xFF
            y   = (val >>  8) & 0xFF
            u   =  val        & 0xFF
            pixels.append(ycbcr_to_rgb(y, u, v))
        else:
            pixels.append((0, 0, 0))

    bgr_list = [[b, g, r] for r, g, b in pixels]
    bgr      = np.array(bgr_list, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{height})")


def convert_yuv422(input_file, output_file, width, height):
    """
    YUV422 1PPC:
      Even pixels: { 8'b0, Y[7:0], U[7:0] }
      Odd  pixels: { 8'b0, Y[7:0], V[7:0] }
    Two pixels share one chroma pair.
    """
    pixel_words = load_and_clean(input_file)
    total       = width * height
    pixels      = []

    for i in range(0, len(pixel_words), 2):
        if len(pixels) >= total:
            break

        if i + 1 >= len(pixel_words):
            # Lone trailing pixel — pad Cr with neutral 128
            val0 = int(pixel_words[i], 16)
            y0   = (val0 >> 8) & 0xFF
            u0   =  val0       & 0xFF
            pixels.append(ycbcr_to_rgb(y0, u0, 128))
            break

        # Even pixel: { 0, Y0, Cb }
        val0 = int(pixel_words[i],   16)
        y0   = (val0 >> 8) & 0xFF
        u0   =  val0       & 0xFF

        # Odd pixel: { 0, Y1, Cr }
        val1 = int(pixel_words[i+1], 16)
        y1   = (val1 >> 8) & 0xFF
        v0   =  val1       & 0xFF

        pixels.append(ycbcr_to_rgb(y0, u0, v0))
        pixels.append(ycbcr_to_rgb(y1, u0, v0))

    if len(pixels) < total:
        print(f"  Warning: only {len(pixels)} pixels reconstructed, "
              f"expected {total}. Padding with black.")
        pixels += [(0, 0, 0)] * (total - len(pixels))

    pixels   = pixels[:total]
    bgr_list = [[b, g, r] for r, g, b in pixels]
    bgr      = np.array(bgr_list, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{height})")


def convert_yuv420(input_file, output_file, width, height):
    """
    YUV420: Y plane (W*H words) followed by interleaved UV plane (W/2 * H/2 words).
      Y  words : { 16'b0, Y[7:0] }
      UV words : { 8'b0,  U[7:0], V[7:0] }  (one UV pair covers a 2x2 block)
    """
    pixel_words = load_and_clean(input_file)
    total       = width * height
    uv_count    = (width // 2) * (height // 2)

    if len(pixel_words) < total:
        print(f"  Warning: only {len(pixel_words)} words found, "
              f"expected at least {total}. Padding with black.")

    # ── Y plane ──────────────────────────────────────────────────────────────
    y_words = pixel_words[:total]
    y_plane = [int(w, 16) & 0xFF for w in y_words]
    while len(y_plane) < total:
        y_plane.append(0)

    # ── UV plane ─────────────────────────────────────────────────────────────
    uv_words = pixel_words[total: total + uv_count]
    uv_plane = []
    for w in uv_words:
        val = int(w, 16)
        u   = (val >> 8) & 0xFF
        v   =  val       & 0xFF
        uv_plane.append((u, v))
    while len(uv_plane) < uv_count:
        uv_plane.append((128, 128))

    # ── Reconstruct pixels ───────────────────────────────────────────────────
    pixels = []
    for row in range(height):
        for col in range(width):
            y_idx  =  row         * width        + col
            uv_idx = (row // 2)   * (width // 2) + (col // 2)
            y      = y_plane[y_idx]
            u, v   = uv_plane[uv_idx]
            pixels.append(ycbcr_to_rgb(y, u, v))

    bgr_list = [[b, g, r] for r, g, b in pixels]
    bgr      = np.array(bgr_list, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{height})")

# ─────────────────────────────────────────────────────────────────────────────
# User Format Prompt
# ─────────────────────────────────────────────────────────────────────────────
def ask_format():
    """Keep asking until a valid format choice (0–3) is entered."""
    menu = (
        "\nSelect input format:\n"
        "  0 = RGB\n"
        "  1 = YUV444\n"
        "  2 = YUV422\n"
        "  3 = YUV420\n"
        "Choice: "
    )
    while True:
        try:
            choice = int(input(menu).strip())
            if choice in (0, 1, 2, 3):
                return choice
            print("  Invalid choice. Please enter 0, 1, 2, or 3.")
        except ValueError:
            print("  Invalid input. Please enter a number.")

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.abspath(__file__))

    CONFIG_FILE = os.path.join(base_dir, "pipeline_config.txt")
    params      = load_config(CONFIG_FILE)
    WIDTH       = params.get('scale_w', 640)
    HEIGHT      = params.get('scale_h', 480)

    INPUT_TXT  = os.path.join(base_dir, "sc_data.txt")
    OUTPUT_IMG = os.path.join(base_dir, "result.png")

    print(f"Config loaded  →  Width={WIDTH}, Height={HEIGHT}")
    print(f"Input file     →  {INPUT_TXT}")

    fmt_names = {0: "RGB", 1: "YUV444", 2: "YUV422", 3: "YUV420"}
    fmt       = ask_format()
    print(f"\nConverting {fmt_names[fmt]} → PNG ...")

    if   fmt == 0: convert_rgb   (INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)
    elif fmt == 1: convert_yuv444(INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)
    elif fmt == 2: convert_yuv422(INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)
    elif fmt == 3: convert_yuv420(INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)

    print("Done.")
