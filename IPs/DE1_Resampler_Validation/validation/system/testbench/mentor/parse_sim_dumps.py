#!/usr/bin/env python3
"""
parse_sim_dumps.py
==================
Parses the two hex dump files produced by the testbench:

  tpg_input.txt   – TPG output / CRS input  (YUV444, 3 bytes per pixel: Y, Cb, Cr)
  crs_output.txt  – CRS output               (YUV420 packed, 2 bytes per pixel)

YUV420 packing (as confirmed from simulation):
  pixel pair (2k, 2k+1) occupies 4 consecutive bytes:
    byte 4k+0 : Y[2k]   (even pixel luma)
    byte 4k+1 : Cb[k]   (shared Cb for the pair)
    byte 4k+2 : Y[2k+1] (odd pixel luma)
    byte 4k+3 : Cr[k]   (shared Cr for the pair)

Usage:
    python3 parse_sim_dumps.py --width <W> --height <H>
    python3 parse_sim_dumps.py --width 960 --height 540
"""

import argparse
import os
import sys
import numpy as np
try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow not installed – run: pip install pillow")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_hex_file(path):
    """Return uint8 numpy array of all hex bytes in the file (skip # comments)."""
    data = []
    with open(path) as f:
        for line in f:
            s = line.strip()
            if not s or s.startswith('#'):
                continue
            try:
                data.append(int(s, 16))
            except ValueError:
                pass
    return np.array(data, dtype=np.uint8)


def bt601_yuv_to_rgb(Y, Cb, Cr):
    """BT.601 full-range YCbCr → uint8 RGB."""
    Yf  = Y.astype(np.float32)
    Cbf = Cb.astype(np.float32) - 128.0
    Crf = Cr.astype(np.float32) - 128.0
    R = np.clip(Yf + 1.402 * Crf,                    0, 255)
    G = np.clip(Yf - 0.344136 * Cbf - 0.714136 * Crf, 0, 255)
    B = np.clip(Yf + 1.772 * Cbf,                    0, 255)
    return R.astype(np.uint8), G.astype(np.uint8), B.astype(np.uint8)


def first_frame(data, bpp, width, height):
    """Crop data to exactly one frame (bpp bytes per pixel)."""
    n = width * height * bpp
    if len(data) < n:
        print(f"  WARNING: only {len(data)} bytes – expected {n} for {width}x{height}x{bpp}bpp")
    return data[:n]


# ---------------------------------------------------------------------------
# Format parsers → (H, W, 3) uint8 RGB array
# ---------------------------------------------------------------------------

def parse_yuv444(data, width, height):
    """3 bytes/pixel: Y, Cb, Cr."""
    data = first_frame(data, 3, width, height)
    n    = len(data) // 3
    Y    = data[0::3][:n]
    Cb   = data[1::3][:n]
    Cr   = data[2::3][:n]
    R, G, B = bt601_yuv_to_rgb(Y, Cb, Cr)
    rows = n // width
    return np.stack([R, G, B], axis=1)[:rows * width].reshape(rows, width, 3)


def parse_yuv420_packed(data, width, height):
    """
    2 bytes/pixel, 4 bytes per pixel-pair:
      [Y_even, Cb, Y_odd, Cr]
    Reconstruct pixel-pair with shared Cb/Cr.
    """
    data    = first_frame(data, 2, width, height)
    n_pairs = len(data) // 4
    n_px    = n_pairs * 2

    Y_e = data[0::4][:n_pairs]
    Cb  = data[1::4][:n_pairs]
    Y_o = data[2::4][:n_pairs]
    Cr  = data[3::4][:n_pairs]

    Y_all  = np.empty(n_px, dtype=np.uint8)
    Cb_all = np.empty(n_px, dtype=np.uint8)
    Cr_all = np.empty(n_px, dtype=np.uint8)

    Y_all[0::2]  = Y_e
    Y_all[1::2]  = Y_o
    Cb_all[0::2] = Cb   # replicate Cb to both pixels in pair
    Cb_all[1::2] = Cb
    Cr_all[0::2] = Cr   # replicate Cr to both pixels in pair
    Cr_all[1::2] = Cr

    R, G, B = bt601_yuv_to_rgb(Y_all, Cb_all, Cr_all)
    rows = n_px // width
    return np.stack([R, G, B], axis=1)[:rows * width].reshape(rows, width, 3)


# ---------------------------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------------------------

def print_first_line(data, bpp, width, label):
    """Print per-pixel values for line 0 (first min(8, width) pixels)."""
    n = min(8, width)
    print(f"  {label} – first {n} pixels of line 0:")
    if bpp == 3:
        for i in range(n):
            off = i * 3
            if off + 2 < len(data):
                print(f"    px{i:3d}: Y={data[off]:3d}  Cb={data[off+1]:3d}  Cr={data[off+2]:3d}")
    elif bpp == 2:
        for k in range(n // 2):
            off = k * 4
            if off + 3 < len(data):
                print(f"    px{2*k:3d}: Y={data[off]:3d}  Cb={data[off+1]:3d}  "
                      f"px{2*k+1}: Y={data[off+2]:3d}  Cr={data[off+3]:3d}")


def print_line_stats(rgb, line_idx):
    """Print luma stats for a given row."""
    row = rgb[line_idx, :, :]
    luma = 0.299 * row[:, 0] + 0.587 * row[:, 1] + 0.114 * row[:, 2]
    print(f"  Line {line_idx}: luma min={luma.min():.0f}  max={luma.max():.0f}  "
          f"mean={luma.mean():.0f}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--width',   type=int, required=True,  help='Frame width in pixels')
    ap.add_argument('--height',  type=int, required=True,  help='Frame height in pixels')
    ap.add_argument('--infile',  default='tpg_input.txt',  help='TPG output dump')
    ap.add_argument('--outfile', default='crs_output.txt', help='CRS output dump')
    args = ap.parse_args()

    tasks = [
        (args.infile,  'TPG input  (YUV444)',  3, parse_yuv444),
        (args.outfile, 'CRS output (YUV420)',  2, parse_yuv420_packed),
    ]

    for path, label, bpp, parser in tasks:
        print(f"\n{'='*60}")
        print(f"{label}")
        print(f"  File : {path}")
        if not os.path.exists(path):
            print("  *** File not found ***")
            continue
        data = load_hex_file(path)
        if data.size == 0:
            print("  *** File is empty – no data was captured ***")
            continue
        print(f"  Bytes: {data.size}")

        # Raw line 0 diagnostics
        print_first_line(data, bpp, args.width, label)

        # Reconstruct image
        try:
            rgb = parser(data, args.width, args.height)
        except Exception as e:
            print(f"  Parse error: {e}")
            continue

        print(f"  Image: {rgb.shape[1]}×{rgb.shape[0]} px")

        # Per-line luma stats for first 4 lines
        for li in range(min(4, rgb.shape[0])):
            print_line_stats(rgb, li)

        # Save PNG
        out_png = path.replace('.txt', '.png')
        Image.fromarray(rgb, 'RGB').save(out_png)
        print(f"  → saved {out_png}")

    print()


if __name__ == '__main__':
    main()
