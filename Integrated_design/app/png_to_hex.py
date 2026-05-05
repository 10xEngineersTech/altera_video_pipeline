import cv2
import numpy as np

def convert_png_to_hex_yuv(input_image_path, output_txt_path, width, height):
    # 1. Load the image
    img = cv2.imread(input_image_path)
    if img is None:
        print(f"Error: Could not load image {input_image_path}")
        return

    # 2. Resize the image to match the hardware/simulation dimensions
    img_resized = cv2.resize(img, (width, height), interpolation=cv2.INTER_AREA)

    # 3. Convert BGR (OpenCV default) to YUV 4:4:4
    # Note: cv2.COLOR_BGR2YUV converts to YCrCb (Y, U, V)
    yuv_img = cv2.cvtColor(img_resized, cv2.COLOR_RGB2YUV)

    # 4. Extract pixels and format as Hex strings
    # The decoding script expects: [U (hex 0:2)][Y (hex 2:4)][V (hex 4:6)]
    hex_pixels = []
    
    for row in range(height):
        for col in range(width):
            y, u, v = yuv_img[row, col]
            
            # Format each as 2-digit hex (8-bit)
            # We follow the order from your decoder: U then Y then V
            hex_str = f"{u:02x}{y:02x}{v:02x}"
            hex_pixels.append(hex_str)

    # 5. Write to text file
    with open(output_txt_path, 'w') as f:
        # Join with spaces to match the $fwrite(fd, "%h ", tdata) format
        f.write(" ".join(hex_pixels))
        # Add a trailing space or newline if needed for your Verilog task
        f.write(" ") 

    print(f"Success! {width}x{height} image converted to {output_txt_path}")

# --- Configuration ---
WIDTH = 32  
HEIGHT = 32  
INPUT_IMG = "input.png"      # Your source image
OUTPUT_TXT = "data.txt"   # The file for your Verilog simulation

if __name__ == "__main__":
    convert_png_to_hex_yuv(INPUT_IMG, OUTPUT_TXT, WIDTH, HEIGHT)
