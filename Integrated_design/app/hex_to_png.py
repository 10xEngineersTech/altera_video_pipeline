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

def load_and_clean(filename, width=None):
    try:
        with open(filename, 'r') as f:
            raw_lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: {filename} not found.")
        sys.exit(1)
    # Parse per capture line (row), not as one flattened token stream - a
    # capture row occasionally has a few extra/short words (e.g. a harmless
    # one-time capture-startup artifact on the first row). Flattening the
    # whole file and reshaping by a fixed width lets that discrepancy shift
    # every subsequent row, which looks like a positioning/wrap-around bug
    # in the rendered image even though the underlying data is correct.
    # Clamping/padding each line to exactly `width` words keeps rows aligned.
    all_words = []
    skipped   = 0
    for raw_line in raw_lines:
        words = raw_line.split()
        if MEANINGFUL_NIBBLES:
            words = [w[-MEANINGFUL_NIBBLES:] if len(w) >= MEANINGFUL_NIBBLES else w
                     for w in words]
        valid = [w for w in words if is_valid_hex(w)]
        skipped += len(words) - len(valid)
        if width is not None and len(valid) != width:
            if len(valid) > width:
                valid = valid[:width]
            else:
                valid = valid + ['000000'] * (width - len(valid))
        all_words.extend(valid)
    if skipped:
        print(f"  Skipped {skipped} invalid (x/z) words.")
    print(f"  Found {len(all_words)} pixel words.")
    return all_words

# =============================================================================
# Conversion Functions
# =============================================================================
def convert_rgb(input_file, output_file, width, height):
    """
    RGB packed: tdata[23:0] = { R[7:0], G[7:0], B[7:0] }
    Used for: SCALER_ONLY, CLIP_SCL, FULL/CSC with RGB output
    """
    pixel_words = load_and_clean(input_file, width=width)
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
    pixel_words = load_and_clean(input_file, width=width)
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
    pixel_words = load_and_clean(input_file, width=width)
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
    Intel VVP 4:2:0 packing (per UG-20344 39.3.5): chroma is subsampled 2x1
    in both directions, but luma is NOT subsampled at all - so the IP packs
    two full-resolution luma samples into the word's 3 color planes, plus
    one shared chroma sample:
      word = { chroma[7:0], Y_odd[7:0], Y_even[7:0] }
    Each raw line carries its own (non-subsampled) luma for its own row, but
    only ONE chroma component (Cb or Cr) - lines alternate Cb/Cr role, and
    that chroma is shared vertically across each line pair. Raw capture is
    `height` lines x (width/2) words (half as many words per line as real
    pixels, since two luma samples share one word).
    """
    half_width = width // 2
    pixel_words = load_and_clean(input_file, width=half_width)

    lines = []
    for row in range(height):
        start = row * half_width
        end   = start + half_width
        line  = pixel_words[start:end] if end <= len(pixel_words) else \
                pixel_words[start:] + ['000000'] * (half_width - len(pixel_words[start:]))
        lines.append(line)

    rows = []
    for pair in range(0, height, 2):
        line_a = lines[pair]
        line_b = lines[pair + 1] if pair + 1 < height else lines[pair]
        row_a, row_b = [], []
        for col in range(half_width):
            wa = int(line_a[col], 16)
            wb = int(line_b[col], 16)
            y0_a, y1_a, chroma_a = (wa >> 16) & 0xFF, (wa >> 8) & 0xFF, wa & 0xFF
            y0_b, y1_b, chroma_b = (wb >> 16) & 0xFF, (wb >> 8) & 0xFF, wb & 0xFF
            cb, cr = chroma_a, chroma_b  # even line = Cb, odd line = Cr
            row_a.append(ycbcr_to_rgb(y0_a, cb, cr))
            row_a.append(ycbcr_to_rgb(y1_a, cb, cr))
            row_b.append(ycbcr_to_rgb(y0_b, cb, cr))
            row_b.append(ycbcr_to_rgb(y1_b, cb, cr))
        rows.append(row_a)
        rows.append(row_b)

    bgr = np.zeros((height, width, 3), dtype=np.uint8)
    for r in range(height):
        for c in range(width):
            rr, gg, bb = rows[r][c]
            bgr[r, c] = [bb, gg, rr]
    cv2.imwrite(output_file, bgr)
    print(f"  Saved {output_file}  ({width}x{height})")


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

    # Prefer the actual pipeline OUTPUT format (after CSC/CRS). Fall back to the
    # TPG input colorspace (correct only when no CSC/CRS changes it), then to the
    # interactive menu.
    of = params.get('output_format', None)
    cs = params.get('tpg_colorspace', None)
    if isinstance(of, int) and of in (0, 1, 2, 3):
        fmt = of
        print(f"Output format from config: {fmt_names[fmt]} (output_format={of})")
    elif isinstance(cs, int) and cs in (0, 1, 2, 3):
        fmt = cs
        print(f"Format from config (input colorspace fallback): {fmt_names[fmt]}")
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
