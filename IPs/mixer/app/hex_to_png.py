#!/usr/bin/python3
# Convert the mixer output hex dump (mixer_data.txt, one 24-bit RRGGBB word
# per pixel as written by rtl/make_file.v) into mixer_result.png.
import cv2
import numpy as np
import os

# Must match BG_WIDTH / BG_HEIGHT in rtl/tb.v
WIDTH  = 1280
HEIGHT = 720


def convert_hex_rgb_to_png(input_file, output_file, width, height):
    if not os.path.exists(input_file):
        print(f"Error: Input file {input_file} not found.")
        return False

    with open(input_file, 'r') as f:
        hex_data = f.read().split()

    if len(hex_data) < width * height:
        print(f"Error: Not enough data. Expected {width*height} pixels, found {len(hex_data)}")
        pixels_to_process = len(hex_data)
    else:
        pixels_to_process = width * height

    # tdata[23:0] = {R[7:0], G[7:0], B[7:0]}; $fwrite "%h" prints MSB first
    raw_list = []
    for i in range(pixels_to_process):
        hex_val = hex_data[i].zfill(6)
        r = int(hex_val[0:2], 16)
        g = int(hex_val[2:4], 16)
        b = int(hex_val[4:6], 16)
        raw_list.append([b, g, r])  # OpenCV BGR order

    while len(raw_list) < width * height:
        raw_list.append([0, 0, 0])

    bgr_np = np.array(raw_list, dtype=np.uint8).reshape((height, width, 3))
    cv2.imwrite(output_file, bgr_np)
    print(f"Success! Mixer output image saved as {output_file}")
    print(f"Dimensions used: {width}x{height}")
    return True


if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.abspath(__file__))
    INPUT_TXT  = os.path.join(base_dir, "mixer_data.txt")
    OUTPUT_IMG = os.path.join(base_dir, "mixer_result.png")
    convert_hex_rgb_to_png(INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)
