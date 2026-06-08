#!/usr/bin/env python3
"""
create_image_yuv422.py - Convert YUV422 simulation pixel dumps to PNG images.

Usage:
    python3 create_image_yuv422.py <width> <height>

Reads:  crs_yuv422.txt  (output from make_file, space-separated 6-hex-digit words)
Writes: crs_yuv422.png

Data format (Intel VVP CRS 422 output, 1PPC, Full protocol):
    tdata[23:0] = {8'b0, Y[7:0], Cb_or_Cr[7:0]}
    Even pixels (0,2,4,...): {0, Y0, Cb}
    Odd  pixels (1,3,5,...): {0, Y1, Cr}
    Chroma pair (Cb,Cr) is shared between even and odd Y samples.
"""

import sys
import os
import cv2
import numpy as np


def ycbcr_to_rgb(y, cb, cr):
    """BT.601 full-range YCbCr -> clipped RGB."""
    cb -= 128
    cr -= 128
    r = y + 1.402    * cr
    g = y - 0.344136 * cb - 0.714136 * cr
    b = y + 1.772    * cb
    return (max(0, min(255, int(r))),
            max(0, min(255, int(g))),
            max(0, min(255, int(b))))


def parse_yuv422(filename, width, height):
    if not os.path.exists(filename):
        print(f"Error: {filename} not found.")
        return []

    with open(filename) as f:
        all_words = f.read().split()

    # Filter out any invalid (x/z) words
    valid = [w for w in all_words if not any(c in w.lower() for c in ('x', 'z'))]
    skipped = len(all_words) - len(valid)
    if skipped:
        print(f"  Skipped {skipped} invalid words.")

    print(f"  {len(valid)} pixel words, expected {width * height}")

    total  = width * height
    pixels = []

    for i in range(0, len(valid), 2):
        if len(pixels) >= total:
            break

        # Even pixel: {0, Y0, Cb}
        val0 = int(valid[i], 16)
        y0   = (val0 >> 8) & 0xFF
        cb   =  val0       & 0xFF

        if i + 1 >= len(valid):
            # Lone pixel at end - pad Cr with neutral
            pixels.append(ycbcr_to_rgb(y0, cb, 128))
            break

        # Odd pixel: {0, Y1, Cr}
        val1 = int(valid[i + 1], 16)
        y1   = (val1 >> 8) & 0xFF
        cr   =  val1       & 0xFF

        # Two pixels share the same chroma pair
        pixels.append(ycbcr_to_rgb(y0, cb, cr))
        pixels.append(ycbcr_to_rgb(y1, cb, cr))

    if len(pixels) < total:
        print(f"  Warning: only {len(pixels)} pixels, expected {total}. Padding with black.")
        pixels += [(0, 0, 0)] * (total - len(pixels))

    return pixels[:total]


def main():
    if len(sys.argv) != 3:
        print("Usage: python3 create_image_yuv422.py <width> <height>")
        sys.exit(1)

    width  = int(sys.argv[1])
    height = int(sys.argv[2])
    print(f"Image size: {width}x{height}")

    base_dir   = os.path.dirname(os.path.abspath(__file__))
    input_txt  = os.path.join(base_dir, "crs_yuv422.txt")
    output_png = os.path.join(base_dir, "crs_yuv422.png")

    pixels = parse_yuv422(input_txt, width, height)
    if not pixels:
        print("No pixels to write.")
        return

    # Build BGR numpy array for OpenCV
    bgr = []
    for r, g, b in pixels:
        bgr.append([b, g, r])

    bgr_np = np.array(bgr, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_png, bgr_np)
    print(f"Saved {output_png}  ({width}x{height})")


if __name__ == "__main__":
    main()
