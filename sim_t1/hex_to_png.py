#!/usr/bin/env python3
from PIL import Image
import os

SIM_DIR = "/home/izaan/t1/sim"

def hex_to_png(hex_file, png_file, width):
    if not os.path.exists(hex_file):
        print("ERROR: " + hex_file + " not found")
        return
    with open(hex_file) as f:
        lines = [l.strip() for l in f if l.strip()]
    height = len(lines) // width
    total  = width * height
    print(str(len(lines)) + " pixels -> " + str(width) + "x" + str(height))
    pixels = []
    for line in lines[:total]:
        val = int(line, 16)
        # Try B,G,R order
        b = (val >> 16) & 0xFF
        g = (val >>  8) & 0xFF
        r = (val >>  0) & 0xFF
        pixels.append((r, g, b))
    img = Image.new("RGB", (width, height))
    img.putdata(pixels)
    img.save(png_file)
    print("Saved: " + png_file)

hex_to_png(os.path.join(SIM_DIR, "tpg_output.hex"),    os.path.join(SIM_DIR, "tpg_output.png"),    64)
hex_to_png(os.path.join(SIM_DIR, "output_scaled.hex"), os.path.join(SIM_DIR, "scaler_output.png"), 128)
print("Done")
