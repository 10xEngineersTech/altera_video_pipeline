"""
create_image.py  –  Convert simulation pixel dumps to PPM images.

Usage:
    python3 create_image.py [width height]

Generates:
    tpg_yuv420.ppm   – TPG input reconstructed from YUV420 1PPC stream
    crs_yuv444.ppm   – CRS output from YUV444 1PPC stream

Data format:
    tpg_yuv420.txt  : one 6-hex-digit word per clock (24-bit, 1PPC)
                      data[23:0] = {V[7:0], Y[7:0], U[7:0]}
    crs_yuv444.txt  : one 6-hex-digit word per clock (24-bit, 1PPC)
                      data[23:0] = {V[7:0], Y[7:0], U[7:0]}
"""

import sys


def ycbcr_to_rgb(y, cb, cr):
    """BT.601 full-range YCbCr → clipped RGB tuple."""
    cb -= 128
    cr -= 128
    r = y + 1.402  * cr
    g = y - 0.344136 * cb - 0.714136 * cr
    b = y + 1.772  * cb
    return (max(0, min(255, int(r))),
            max(0, min(255, int(g))),
            max(0, min(255, int(b))))


def is_valid_hex(word):
    """Return False if the word contains Verilog 'x' or 'z' unknown values."""
    return not any(c in word.lower() for c in ('x', 'z'))


def write_ppm(filename, width, height, rgb_pixels):
    """Write a P3 PPM file (no external libraries required)."""
    with open(filename, "w") as f:
        f.write(f"P3\n{width} {height}\n255\n")
        for r, g, b in rgb_pixels:
            f.write(f"{r} {g} {b}\n")
    print(f"Saved {filename}  ({width}x{height},  {len(rgb_pixels)} pixels)")


def parse_yuv444(filename, width, height):
    """
    Parse YUV444 dump: one 6-hex-digit word per pixel.
    data[23:0] = {V[7:0], Y[7:0], U[7:0]}
    """
    try:
        raw = [l.strip() for l in open(filename) if l.strip()]
    except FileNotFoundError:
        print(f"Error: {filename} not found – run the simulation first.")
        return []

    total = width * height
    pixels = []
    skipped = 0
    for word in raw:
        if len(pixels) >= total:
            break
        if not is_valid_hex(word):
            skipped += 1
            continue
        val = int(word, 16)
        v   = (val >> 16) & 0xFF   # data[23:16] = V
        y   = (val >>  8) & 0xFF   # data[15:8]  = Y
        u   =  val        & 0xFF   # data[7:0]   = U
        pixels.append(ycbcr_to_rgb(y, u, v))
    if skipped:
        print(f"  Skipped {skipped} invalid (x/z) words in {filename}")

    if len(pixels) < total:
        print(f"  Warning: only {len(pixels)} pixels in {filename}, expected {total}. Padding black.")
        pixels += [(0, 0, 0)] * (total - len(pixels))
    return pixels


def parse_yuv420(filename, width, height):
    """
    Parse TPG YUV420 1PPC dump.
    Each line is one 6-hex-digit word per pixel:
      data[23:0] = {V[7:0], Y[7:0], U[7:0]}

    In YUV420, chroma is subsampled 2x2. The TPG sends per-pixel data
    on the bus, but chroma values are only valid for every other pixel
    horizontally and every other line vertically.

    For display purposes, we treat each pixel's data as-is (the TPG
    repeats chroma for subsampled positions).
    """
    try:
        raw = [l.strip() for l in open(filename) if l.strip()]
    except FileNotFoundError:
        print(f"Error: {filename} not found – run the simulation first.")
        return []

    valid = [w for w in raw if is_valid_hex(w)]
    skipped = len(raw) - len(valid)
    if skipped:
        print(f"  Skipped {skipped} invalid (x/z) words in {filename}")

    total = width * height
    pixels = []
    for word in valid:
        if len(pixels) >= total:
            break
        val = int(word, 16)
        v   = (val >> 16) & 0xFF   # data[23:16] = V
        y   = (val >>  8) & 0xFF   # data[15:8]  = Y
        u   =  val        & 0xFF   # data[7:0]   = U
        pixels.append(ycbcr_to_rgb(y, u, v))

    if len(pixels) < total:
        print(f"  Warning: only {len(pixels)} pixels reconstructed from {filename}, expected {total}. Padding black.")
        pixels += [(0, 0, 0)] * (total - len(pixels))
    return pixels


def main():
    width  = 16
    height = 4

    if len(sys.argv) == 3:
        width  = int(sys.argv[1])
        height = int(sys.argv[2])

    print(f"Image size: {width}x{height}")

    # --- YUV444 CRS output ---
    yuv444_pixels = parse_yuv444("crs_yuv444.txt", width, height)
    if yuv444_pixels:
        write_ppm("crs_yuv444.ppm", width, height, yuv444_pixels)

    # --- YUV420 TPG input (rendered for display) ---
    yuv420_pixels = parse_yuv420("tpg_yuv420.txt", width, height)
    if yuv420_pixels:
        write_ppm("tpg_yuv420.ppm", width, height, yuv420_pixels)


if __name__ == "__main__":
    main()
