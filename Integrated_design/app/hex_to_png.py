#!/usr/bin/python3
import cv2
import numpy as np
import os
import sys

# =============================================================================
# Config Loader
# =============================================================================
def load_config(config_file):
    cfg = {}
    if not os.path.exists(config_file):
        print(f"Warning: Config file {config_file} not found. Using defaults.")
        return {"scale_w": 640, "scale_h": 480}
    with open(config_file, 'r') as f:
        for line in f:
            if '=' in line:
                name, value = line.split('=', 1)
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

# =============================================================================
# Shared Utilities
# =============================================================================
# Number of meaningful low hex digits per captured word (VID_PLANES*2).
# Set from config in __main__; None = keep the whole word.
MEANINGFUL_NIBBLES = None

def is_valid_hex(word):
    return not any(c in word.lower() for c in ('x', 'z'))

def ycbcr_to_rgb(y, cb, cr):
    """BT.601 full-range YCbCr -> clipped RGB tuple."""
    cb -= 128
    cr -= 128
    r = y + 1.402    * cr
    g = y - 0.344136 * cb - 0.714136 * cr
    b = y + 1.772    * cb
    return (max(0, min(255, int(r))),
            max(0, min(255, int(g))),
            max(0, min(255, int(b))))

def load_and_clean(filename):
    try:
        with open(filename, 'r') as f:
            raw = f.read().split()
    except FileNotFoundError:
        print(f"Error: {filename} not found.")
        sys.exit(1)
    # Keep only the meaningful low nibbles. On a 2-plane (16-bit) datapath the
    # capture bus is still 24-bit, so the undriven high byte shows up as x/z;
    # trimming first prevents those words from being discarded as invalid.
    if MEANINGFUL_NIBBLES:
        raw = [w[-MEANINGFUL_NIBBLES:] if len(w) >= MEANINGFUL_NIBBLES else w
               for w in raw]
    valid   = [w for w in raw if is_valid_hex(w)]
    skipped = len(raw) - len(valid)
    if skipped:
        print(f"  Skipped {skipped} invalid (x/z) words.")
    print(f"  Found {len(valid)} pixel words.")
    return valid

# =============================================================================
# Conversion Functions
# =============================================================================
def convert_rgb(input_file, output_file, width, height):
    """
    RGB packed: tdata[23:0] = { R[7:0], G[7:0], B[7:0] }
    Used for: SCALER_ONLY, CLIP_SCL, FULL/CSC with RGB output
    """
    pixel_words = load_and_clean(input_file)
    total       = width * height
    raw_list    = []
    for i in range(total):
        if i < len(pixel_words):
            h = pixel_words[i].zfill(6)
            r = int(h[0:2], 16)
            g = int(h[2:4], 16)
            b = int(h[4:6], 16)
        else:
            r, g, b = 0, 0, 0
        raw_list.append([b, g, r])
    bgr = np.array(raw_list, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{height})")


def convert_yuv444(input_file, output_file, width, height):
    """
    YUV444 packed: tdata[23:0] = { Cr[7:0], Y[7:0], Cb[7:0] }
    Used for: CRS 444 output, CSC YCbCr output
    """
    pixel_words = load_and_clean(input_file)
    total       = width * height
    pixels      = []
    for i in range(total):
        if i < len(pixel_words):
            val = int(pixel_words[i], 16)
            cr  = (val >> 16) & 0xFF
            y   = (val >>  8) & 0xFF
            cb  =  val        & 0xFF
            pixels.append(ycbcr_to_rgb(y, cb, cr))
        else:
            pixels.append((0, 0, 0))
    bgr_list = [[b, g, r] for r, g, b in pixels]
    bgr      = np.array(bgr_list, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{height})")


def convert_yuv422(input_file, output_file, width, height):
    """
    YUV422 1PPC:
      Even pixels: { 8'b0, Y[7:0], Cb[7:0] }
      Odd  pixels: { 8'b0, Y[7:0], Cr[7:0] }
    Used for: CRS 422 output
    """
    pixel_words = load_and_clean(input_file)
    total       = width * height
    pixels      = []
    for i in range(0, len(pixel_words), 2):
        if len(pixels) >= total:
            break
        if i + 1 >= len(pixel_words):
            val0 = int(pixel_words[i], 16)
            y0   = (val0 >> 8) & 0xFF
            cb   =  val0       & 0xFF
            pixels.append(ycbcr_to_rgb(y0, cb, 128))
            break
        val0 = int(pixel_words[i],   16)
        y0   = (val0 >> 8) & 0xFF
        cb   =  val0       & 0xFF
        val1 = int(pixel_words[i+1], 16)
        y1   = (val1 >> 8) & 0xFF
        cr   =  val1       & 0xFF
        pixels.append(ycbcr_to_rgb(y0, cb, cr))
        pixels.append(ycbcr_to_rgb(y1, cb, cr))
    if len(pixels) < total:
        pixels += [(0, 0, 0)] * (total - len(pixels))
    pixels   = pixels[:total]
    bgr_list = [[b, g, r] for r, g, b in pixels]
    bgr      = np.array(bgr_list, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{height})")


def convert_yuv420(input_file, output_file, width, height):
    """
    Intel VVP 420 passthrough interleaved packing:
      Every pixel word: { Cr_or_Cb[7:0], Y[7:0], Cr_or_Cb[7:0] }
      Even lines: { Cb[7:0], Y[7:0], Cb[7:0] }  -> Cb line
      Odd  lines: { Cr[7:0], Y[7:0], Cr[7:0] }  -> Cr line

    To reconstruct full YCbCr per pixel:
      - Y  from current pixel word (bits 15:8)
      - Cb from even line, same column (bits 7:0)
      - Cr from odd  line, same column (bits 7:0)
    Pair even+odd lines to get full color for both rows.
    """
    pixel_words = load_and_clean(input_file)
    total       = width * height

    # Reshape into lines
    lines = []
    for row in range(height):
        start = row * width
        end   = start + width
        line  = pixel_words[start:end] if end <= len(pixel_words) else \
                pixel_words[start:] + ['808080'] * (width - len(pixel_words[start:]))
        lines.append(line)

    # Intel VVP 420 field-based stream:
    #   Field 0 (even rows): lines 0  .. height//2 - 1  -> pixel rows 0,2,4,...
    #   Field 1 (odd  rows): lines height//2 .. height-1 -> pixel rows 1,3,5,...
    #   Within each field, lines alternate: Cb line, Cr line, Cb line, Cr line
    #   Each Cb/Cr pair reconstructs one pixel row of the field
    #
    # Total output: width x height pixels (full frame)

    field0 = lines[:height // 2]   # even field: rows 0,2,4,...
    field1 = lines[height // 2:]   # odd  field: rows 1,3,5,...

    def reconstruct_field(field_lines, width):
        """Reconstruct pixels from alternating Cb/Cr lines in one field."""
        result = []
        for row in range(0, len(field_lines), 2):
            cb_line = field_lines[row]
            cr_line = field_lines[row+1] if row+1 < len(field_lines) else field_lines[row]
            for col in range(width):
                val_cb = int(cb_line[col], 16)
                val_cr = int(cr_line[col], 16)
                y  = (val_cb >> 8) & 0xFF
                cb =  val_cb       & 0xFF
                cr =  val_cr       & 0xFF
                result.append(ycbcr_to_rgb(y, cb, cr))
        return result

    even_pixels = reconstruct_field(field0, width)  # rows 0,2,4,...
    odd_pixels  = reconstruct_field(field1, width)  # rows 1,3,5,...

    # Interleave even and odd field rows to reconstruct full frame
    rows_per_field = len(even_pixels) // width
    pixels = []
    for r in range(rows_per_field):
        start = r * width
        end   = start + width
        pixels.extend(even_pixels[start:end])  # even row
        if r < len(odd_pixels) // width:
            pixels.extend(odd_pixels[start:end])  # odd row

    out_h    = len(pixels) // width
    total_px = width * out_h
    if len(pixels) < total_px:
        pixels += [(0, 0, 0)] * (total_px - len(pixels))
    pixels   = pixels[:total_px]
    bgr_list = [[b, g, r] for r, g, b in pixels]
    bgr      = np.array(bgr_list, dtype=np.uint8).reshape((out_h, width, 3))
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{out_h})")


# =============================================================================
# Main
# =============================================================================
if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.abspath(__file__))

    CONFIG_FILE = os.path.join(base_dir, "pipeline_config.txt")
    params      = load_config(CONFIG_FILE)
    WIDTH       = params.get('scale_w', 640)
    HEIGHT      = params.get('scale_h', 480)

    INPUT_TXT  = os.path.join(base_dir, "sc_data.txt")
    OUTPUT_IMG = os.path.join(base_dir, "result.png")

    print(f"Config loaded  -  Width={WIDTH}, Height={HEIGHT}")
    print(f"Input file     -  {INPUT_TXT}")

    fmt_names = {0: "RGB", 1: "YUV444", 2: "YUV422", 3: "YUV420"}

    # Prefer the format recorded by the GUI; fall back to interactive menu.
    cs = params.get('tpg_colorspace', None)
    if isinstance(cs, int) and cs in (0, 1, 2, 3):
        fmt = cs
        print(f"Format from config: {fmt_names[fmt]} (tpg_colorspace={cs})")
    else:
        menu = (
            "\nSelect output format (format of sc_data.txt):\n"
            "  0 = RGB    (CSC->RGB, SCALER_ONLY, CLIP_SCL, FULL)\n"
            "  1 = YUV444 (CRS 444 output, CSC YCbCr output)\n"
            "  2 = YUV422 (CRS 422 output)\n"
            "  3 = YUV420 (CRS 420 passthrough)\n"
            "Choice: "
        )
        while True:
            try:
                fmt = int(input(menu).strip())
                if fmt in (0, 1, 2, 3):
                    break
                print("  Invalid. Enter 0-3.")
            except ValueError:
                print("  Invalid. Enter a number.")

    # Meaningful low nibbles = color planes * 2. Use vid_planes if present,
    # else derive from the format (2 planes for 4:2:2/4:2:0, 3 otherwise).
    planes = params.get('vid_planes', None)
    if not isinstance(planes, int) or planes not in (2, 3):
        planes = 2 if fmt in (2, 3) else 3
    MEANINGFUL_NIBBLES = planes * 2

    print(f"\nConverting {fmt_names[fmt]} ({planes} planes) -> PNG ...")

    if   fmt == 0: convert_rgb   (INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)
    elif fmt == 1: convert_yuv444(INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)
    elif fmt == 2: convert_yuv422(INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)
    elif fmt == 3: convert_yuv420(INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)

    print("Done.")
