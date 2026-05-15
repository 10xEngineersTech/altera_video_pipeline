#!/usr/bin/python3
import cv2
import numpy as np
import sys
import os

def convert_rgb_hex_to_image(input_file, output_file, width, height):
    # 1. Read the hex file
    if not os.path.exists(input_file):
        print(f"Error: File {input_file} not found.")
        return

    with open(input_file, 'r') as f:
        hex_data = f.read().split()

    expected_pixels = width * height
    print(f"Processing {width}x{height} image ({expected_pixels} pixels)...")

    # 2. Parse 24-bit Hex to R, G, B components
    # Format: RGB (e.g., 0xFF8040 -> R=FF, G=80, B=40)
    rgb_list = []
    for i in range(expected_pixels):
        if i < len(hex_data):
            # Strip optional '0x' prefix and zero-pad to 6 chars
            h_str = hex_data[i].strip().lower().removeprefix('0x').zfill(6)
            r = int(h_str[0:2], 16)
            g = int(h_str[2:4], 16)
            b = int(h_str[4:6], 16)
            rgb_list.append([r, g, b])
        else:
            # Pad missing data with black
            rgb_list.append([0, 0, 0])

    # 3. Convert to uint8 numpy array and reshape
    rgb_np = np.array(rgb_list, dtype=np.uint8)
    rgb_img = rgb_np.reshape((height, width, 3))

    # 4. Convert RGB -> BGR for OpenCV and save
    bgr_img = cv2.cvtColor(rgb_img, cv2.COLOR_RGB2BGR)
    cv2.imwrite(output_file, bgr_img)
    print(f"Success! Image saved as {output_file}")


if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage:    python manual_csc.py <input_file> <output_file> <width> <height>")
        print("Example:  python manual_csc.py sc_data.txt result.png 1920 1080")
    else:
        in_file  = sys.argv[1]
        out_file = sys.argv[2]
        w        = int(sys.argv[3])
        h        = int(sys.argv[4])
        convert_rgb_hex_to_image(in_file, out_file, w, h)
