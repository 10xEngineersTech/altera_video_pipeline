import cv2
import numpy as np
import os

def convert_png_to_hex_rgb(input_image_path, output_txt_path, width, height):
    # 1. Load the image
    img = cv2.imread(input_image_path)
    if img is None:
        print(f"Error: Could not load image {input_image_path}")
        return

    # 2. Resize to match hardware/simulation dimensions
    img_resized = cv2.resize(img, (width, height), interpolation=cv2.INTER_AREA)

    # 3. Extract pixels and format as hex strings
    #    Hardware tdata[23:0] = {R[7:0], G[7:0], B[7:0]}, MSB first in hex
    #    OpenCV loads as BGR so img[row,col] = [B, G, R]
    hex_pixels = []
    for row in range(height):
        for col in range(width):
            b, g, r = img_resized[row, col]
            hex_pixels.append(f"{r:02x}{g:02x}{b:02x}")

    # 4. Write to text file (space-separated to match $fwrite(fd, "%h ", tdata))
    with open(output_txt_path, 'w') as f:
        f.write(" ".join(hex_pixels))
        f.write(" ")

    print(f"Success! {width}x{height} image converted to {output_txt_path}")

# --- Configuration ---
WIDTH = 32
HEIGHT = 32
INPUT_IMG = "input.png"
OUTPUT_TXT = "data.txt"

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.abspath(__file__))
    convert_png_to_hex_rgb(
        os.path.join(base_dir, INPUT_IMG),
        os.path.join(base_dir, OUTPUT_TXT),
        WIDTH,
        HEIGHT
    )
