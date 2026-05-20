#!/usr/bin/env python3
"""Convert input.png to a hex pixel file for testbench $readmemh.

Output format: one 6-hex-digit value per line, MSB = R, middle = G, LSB = B.
Example: red pixel (255,0,0) -> ff0000
"""
import os
from PIL import Image

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_PNG  = os.path.join(SCRIPT_DIR, "input.png")
OUTPUT_HEX = os.path.join(SCRIPT_DIR, "input_data.txt")

img = Image.open(INPUT_PNG).convert("RGB")
width, height = img.size
pixels = list(img.getdata())

print(f"Input image: {width}x{height} ({width*height} pixels)")

with open(OUTPUT_HEX, "w") as f:
    for y in range(height):
        for x in range(width):
            r, g, b = pixels[y * width + x]
            f.write(f"{r:02x}{g:02x}{b:02x}\n")

print(f"Written to: {OUTPUT_HEX}")
