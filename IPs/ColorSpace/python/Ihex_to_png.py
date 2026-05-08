#!/usr/bin/python3
import cv2
import numpy as np
import sys
import os

def convert_yuv_to_rgb_manual(input_file, output_file, width, height):
    # 1. Read the hex file
    if not os.path.exists(input_file):
        print(f"Error: File {input_file} not found.")
        return

    with open(input_file, 'r') as f:
        hex_data = f.read().split()

    expected_pixels = width * height
    print(f"Processing {width}x{height} image ({expected_pixels} pixels)...")

    # 2. Parse 24-bit Hex to Y, U, V components
    # Format: YUV (e.g., 0xFFFF80 -> Y=FF, U=FF, V=80)
    yuv_list = []
    for i in range(expected_pixels):
        if i < len(hex_data):
            # Strip optional '0x' prefix and zero-pad to 6 chars
            h_str = hex_data[i].strip().lower().removeprefix('0x').zfill(6)
            y = int(h_str[0:2], 16)
            u = int(h_str[2:4], 16)
            v = int(h_str[4:6], 16)
            yuv_list.append([y, u, v])
        else:
            # Pad missing data with black (Y=0, U=128, V=128)
            yuv_list.append([0, 128, 128])

    # Convert to float32 for high-precision matrix math
    yuv_np = np.array(yuv_list, dtype=np.float32)

    # 3. BT.709 Full-Range YUV -> RGB Matrix
    # R = Y + 0.0000*(U-128) + 1.5748*(V-128)
    # G = Y - 0.1873*(U-128) - 0.4681*(V-128)
    # B = Y + 1.8556*(U-128) + 0.0000*(V-128)
    matrix = np.array([
        [1.5748,  1.0000,  0.0000],   # Coefficients for R
        [-0.4681, 1.0000, -0.1873],   # Coefficients for G
        [0.0000,  1.0000,  1.8556]    # Coefficients for B
    ], dtype=np.float32)
    
    # Summands: absorb the -128 chroma offset into a constant per channel
    # R: 1.5748 * (-128)                         = -201.5744
    # G: -0.1873*(-128) + -0.4681*(-128)         =  +83.8976
    # B: 1.8556 * (-128)                         = -237.5168
    summands = np.array([-201.5744, 83.8976, -237.5168], dtype=np.float32)

    # 4. Matrix multiply: each pixel [Y,U,V] dot matrix.T gives [R,G,B]
    rgb = np.dot(yuv_np, matrix.T) + summands

    # 5. Clip to [0, 255] and convert to uint8
    rgb = np.clip(np.round(rgb), 0, 255).astype(np.uint8)

    # 6. Reshape to (Height, Width, 3)
    rgb_img = rgb.reshape((height, width, 3))

    # 7. Convert RGB -> BGR for OpenCV and save
    bgr_img = cv2.cvtColor(rgb_img, cv2.COLOR_RGB2BGR)
    cv2.imwrite(output_file, bgr_img)  # BUG FIX: was saving rgb_img instead of bgr_img
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
        convert_yuv_to_rgb_manual(in_file, out_file, w, h)
