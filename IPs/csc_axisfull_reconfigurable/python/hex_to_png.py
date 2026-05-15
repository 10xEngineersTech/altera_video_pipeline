import cv2
import numpy as np

def convert_hex_yuv_to_png_cv2(input_file, output_file, width, height):
    # 1. Load the hex strings from the file
    with open(input_file, 'r') as f:
        hex_data = f.read().split()
    
    if len(hex_data) < width * height:
        print(f"Error: Not enough data. Expected {width*height}, found {len(hex_data)}")
        return

    # 2. Convert hex strings to a flat list of integers (8-bit Y, U, V)
    # We create a NumPy array with shape (Total_Pixels, 3)
    raw_list = []
    for i in range(width * height):
        hex_val = hex_data[i].zfill(6) # Ensure 6 chars
        u = int(hex_val[0:2], 16)
        y = int(hex_val[2:4], 16)
        v = int(hex_val[4:6], 16)
        raw_list.append([y, u, v])
    
    # 3. Create a NumPy array of type uint8
    # Shape will be (height, width, 3)
    yuv_np = np.array(raw_list, dtype=np.uint8).reshape((height, width, 3))

    # 4. Use OpenCV to convert YUV 4:4:4 to BGR
    # Note: OpenCV's YUV444 interpretation is usually YCrCb
    # 1. Convert YUV to BGR (OpenCV's default)
    bgr = cv2.cvtColor(yuv_np, cv2.COLOR_YUV2BGR)

    # 2. Convert BGR to RGB
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)

    # 5. Save using OpenCV
    cv2.imwrite(output_file, rgb)
    print(f"Success! OpenCV converted image saved as {output_file}")

# --- Configuration ---
WIDTH = 32
HEIGHT = 32
INPUT_TXT = "cs_data.txt"
OUTPUT_IMG = "result.png"

if __name__ == "__main__":
    convert_hex_yuv_to_png_cv2(INPUT_TXT, OUTPUT_IMG, WIDTH, HEIGHT)
