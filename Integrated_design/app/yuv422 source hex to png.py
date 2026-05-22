#!/usr/bin/env python3
"""
create_image_yuv422.py  –  Convert YUV422 1PPC simulation pixel dumps to PPM images.

Usage:
    python3 create_image_yuv422.py [width height]

Generates:
    crs_yuv422.ppm   – CRS output reconstructed from YUV422 1PPC stream

Data format (Intel VVP 1PPC YUV422):
    crs_yuv422.txt  : one 6-hex-digit word per clock (24-bit, 1PPC)
                      Even Pixels: data[23:0] = {8'b0, Y[7:0], U[7:0]}
                      Odd Pixels:  data[23:0] = {8'b0, Y[7:0], V[7:0]}

NOTE on control packets:
    The Intel VVP CRS IP multiplexes info/control packets on the same AXI4-S
    bus. In some configurations these packets arrive with tuser[1]=0 (same as
    video pixels), so the tuser[1] filter in the testbench cannot exclude them.
    Each frame block in the dump therefore looks like:

        00000f          <-- SOF / info-packet sentinel  (3 header words)
        000003          <-- control word 2
        XXXXXX          <-- control word 3 (e.g. frame-geometry)
        ... W*H pixel words ...
        000000          <-- EOF pad word

    This script uses a state machine that detects the 00000f SOF sentinel and
    skips the following 2 control header words plus the 000000 EOF pad.
"""

import sys

# ── Pixel sentinels emitted by the Intel VVP CRS info-packet header ──────────
SOF_SENTINEL = 0x00000F   # always the first word of every frame header
EOF_SENTINEL  = 0x000000  # pad/end-of-frame marker

# Number of control words that follow the SOF sentinel (excluding SOF itself)
_HEADER_TAIL = 2   # i.e. 000003 + XXXXXX (frame-geometry word)


def ycbcr_to_rgb(y, cb, cr):
    """BT.601 full-range YCbCr → clipped RGB tuple."""
    cb -= 128
    cr -= 128
    r = y + 1.402   * cr
    g = y - 0.344136 * cb - 0.714136 * cr
    b = y + 1.772   * cb
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


def strip_control_packets(words):
    """
    Remove Intel VVP info-packet / control words from a flat list of hex
    strings.

    State machine:
        IDLE      – waiting for the SOF sentinel (0x00000f)
        SKIP_HDR  – skipping the _HEADER_TAIL control words after SOF
        PIXELS    – collecting pixel words until the next SOF or EOF

    Returns a list of pure pixel hex-word strings.
    """
    STATE_IDLE     = 0
    STATE_SKIP_HDR = 1
    STATE_PIXELS   = 2

    pixel_words  = []
    skip_remain  = 0
    state        = STATE_IDLE

    for w in words:
        val = int(w, 16)

        if state == STATE_IDLE:
            if val == SOF_SENTINEL:
                state       = STATE_SKIP_HDR
                skip_remain = _HEADER_TAIL
            # Any word before the first SOF is also discarded (pre-frame garbage)

        elif state == STATE_SKIP_HDR:
            skip_remain -= 1
            if skip_remain == 0:
                state = STATE_PIXELS

        elif state == STATE_PIXELS:
            if val == SOF_SENTINEL:
                # Next frame starting – go straight back to skip-header
                state       = STATE_SKIP_HDR
                skip_remain = _HEADER_TAIL
            elif val == EOF_SENTINEL:
                # End-of-frame pad – discard and stay in PIXELS
                # (another SOF will arrive next cycle anyway)
                pass
            else:
                pixel_words.append(w)

    return pixel_words


def parse_yuv422(filename, width, height):
    """
    Parse YUV422 dump: one 6-hex-digit word per pixel.
    Even Pixels (0, 2, ...): {8'b0, Y[7:0], U[7:0]}
    Odd Pixels  (1, 3, ...): {8'b0, Y[7:0], V[7:0]}
    """
    try:
        raw = [l.strip() for l in open(filename) if l.strip()]
    except FileNotFoundError:
        print(f"Error: {filename} not found – run the simulation first.")
        return []

    valid = [w for w in raw if is_valid_hex(w)]
    skipped_xz = len(raw) - len(valid)
    if skipped_xz:
        print(f"  Skipped {skipped_xz} invalid (x/z) words in {filename}")

    # --- Strip info-packet control headers ---
    pixel_words = strip_control_packets(valid)
    n_stripped = len(valid) - len(pixel_words)
    print(f"  Stripped {n_stripped} control/header words  "
          f"({len(pixel_words)} pixel words remaining)")

    total  = width * height
    pixels = []

    # Process in pairs: Even (Y0, Cb) and Odd (Y1, Cr)
    for i in range(0, len(pixel_words), 2):
        if len(pixels) >= total:
            break

        if i + 1 >= len(pixel_words):
            # Lone pixel – pad missing Cr with 128 (neutral)
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

        # Reconstruct two full-colour pixels sharing the chroma pair
        pixels.append(ycbcr_to_rgb(y0, u0, v0))
        pixels.append(ycbcr_to_rgb(y1, u0, v0))

    if len(pixels) < total:
        print(f"  Warning: only {len(pixels)} pixels reconstructed from "
              f"{filename}, expected {total}. Padding with black.")
        pixels += [(0, 0, 0)] * (total - len(pixels))

    return pixels[:total]


def main():
    width  = 16
    height = 4

    if len(sys.argv) == 3:
        width  = int(sys.argv[1])
        height = int(sys.argv[2])

    print(f"Image size: {width}x{height}")

    # --- YUV422 CRS output ---
    yuv422_pixels = parse_yuv422("sc_data.txt", width, height)
    if yuv422_pixels:
        write_ppm("crs_yuv422.ppm", width, height, yuv422_pixels)


if __name__ == "__main__":
    main()
