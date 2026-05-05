"""
create_image.py  –  Convert simulation pixel dumps to PPM images.

Usage:
    python3 create_image.py [width height]

Generates:
    tpg_yuv422.ppm   – TPG input reconstructed from YUV422 1PPC stream
    crs_yuv444.ppm   – CRS output from YUV444 1PPC stream

Data format:
    tpg_yuv422.txt  : one 4-hex-digit word per clock
                      even pixels → {Cb[7:0], Y[7:0]}
                      odd  pixels → {Cr[7:0], Y[7:0]}
    crs_yuv444.txt  : one 6-hex-digit word per clock
                      {V[7:0], Y[7:0], U[7:0]}
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
    """Parse CRS YUV444 dump  {V, Y, U} one word per pixel."""
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
        v   = (val >> 16) & 0xFF
        y   = (val >>  8) & 0xFF
        u   =  val        & 0xFF
        pixels.append(ycbcr_to_rgb(y, u, v))
    if skipped:
        print(f"  Skipped {skipped} invalid (x/z) words in {filename}")

    if len(pixels) < total:
        print(f"  Warning: only {len(pixels)} pixels in {filename}, expected {total}. Padding black.")
        pixels += [(0, 0, 0)] * (total - len(pixels))
    return pixels


def parse_yuv422(filename, width, height):
    """
    Parse TPG YUV422 1PPC dump.
    The Verilog now writes one line per PAIR (8 hex chars):
      {Cr[7:0], Y1[7:0], Cb[7:0], Y0[7:0]}
    This guarantees phase alignment — no Cb/Cr swap possible.
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
        val = int(word, 16)          # 32-bit: {Cr, Y1, Cb, Y0}
        cr  = (val >> 24) & 0xFF
        y1  = (val >> 16) & 0xFF
        cb  = (val >>  8) & 0xFF
        y0  =  val        & 0xFF

        pixels.append(ycbcr_to_rgb(y0, cb, cr))  # pixel 0
        pixels.append(ycbcr_to_rgb(y1, cb, cr))  # pixel 1

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

    # --- YUV422 TPG input (upsampled to 4:4:4 for display) ---
    yuv422_pixels = parse_yuv422("tpg_yuv422.txt", width, height)
    if yuv422_pixels:
        write_ppm("tpg_yuv422.ppm", width, height, yuv422_pixels)


if __name__ == "__main__":
    main()
