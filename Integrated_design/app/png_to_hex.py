import cv2
import numpy as np
import os
import sys

def convert_png_to_hex_rgb(input_image_path, output_txt_path, width, height):
    img = cv2.imread(input_image_path)
    if img is None:
        print(f"Error: Could not load image {input_image_path}")
        return

    img_resized = cv2.resize(img, (width, height), interpolation=cv2.INTER_AREA)

    # tdata[23:0] = {R[7:0], G[7:0], B[7:0]}; OpenCV loads BGR
    hex_pixels = []
    for row in range(height):
        for col in range(width):
            b, g, r = img_resized[row, col]
            hex_pixels.append(f"{r:02x}{g:02x}{b:02x}")

    # Space-separated — compatible with Verilog $readmemh
    with open(output_txt_path, 'w') as f:
        f.write(" ".join(hex_pixels))
        f.write(" ")

    print(f"Success! {width}x{height} image -> {output_txt_path}")


if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # Accept width and height as optional CLI arguments so image_viewer.py can
    # call this with the current TPG dimensions: python3 png_to_hex.py <W> <H>
    if len(sys.argv) >= 3:
        width  = int(sys.argv[1])
        height = int(sys.argv[2])
    else:
        # Fall back to reading from pipeline_config.txt
        config_path = os.path.join(base_dir, "pipeline_config.txt")
        width, height = 640, 480  # safe default
        try:
            with open(config_path) as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("tpg_w"):
                        width = int(line.split("=")[1].strip())
                    elif line.startswith("tpg_h"):
                        height = int(line.split("=")[1].strip())
        except FileNotFoundError:
            print(f"Warning: {config_path} not found, using default {width}x{height}")

    convert_png_to_hex_rgb(
        os.path.join(base_dir, "image.png"),
        os.path.join(base_dir, "image_data.txt"),
        width,
        height
    )
