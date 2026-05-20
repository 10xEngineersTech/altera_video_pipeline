#!/usr/bin/env python3
"""Convert simulation output hex file to output.png.

Reads output_data.txt (one 6-hex-digit RGB pixel per line) produced by the
testbench and reconstructs a PNG image.

Pixel format: 0xRRGGBB  (MSB=R, middle=G, LSB=B)
"""
import os
from PIL import Image

SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
INPUT_HEX   = os.path.join(SCRIPT_DIR, "output_data.txt")
OUTPUT_PNG  = os.path.join(SCRIPT_DIR, "output.png")

IMG_WIDTH  = 64
IMG_HEIGHT = 36
TOTAL      = IMG_WIDTH * IMG_HEIGHT

if not os.path.exists(INPUT_HEX):
    raise FileNotFoundError(f"{INPUT_HEX} not found — run the simulation first.")

with open(INPUT_HEX, "r") as f:
    lines = [l.strip() for l in f if l.strip()]

if len(lines) < TOTAL:
    print(f"Warning: expected {TOTAL} pixels, got {len(lines)} — padding with black.")

pixels = []
for i in range(TOTAL):
    if i < len(lines):
        val = int(lines[i], 16)
        r = (val >> 16) & 0xFF
        g = (val >>  8) & 0xFF
        b =  val        & 0xFF
        pixels.append((r, g, b))
    else:
        pixels.append((0, 0, 0))

img = Image.new("RGB", (IMG_WIDTH, IMG_HEIGHT))
img.putdata(pixels)
img.save(OUTPUT_PNG)
print(f"Saved {IMG_WIDTH}x{IMG_HEIGHT} image to: {OUTPUT_PNG}")
