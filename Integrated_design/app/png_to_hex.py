import cv2
import os
import sys

def convert_png_to_hex_rgb(input_image_path, output_txt_path):
    """
    Convert a PNG to a space-separated RGB hex file compatible with $readmemh.
    Uses the image's native resolution — no resize.
    Returns (width, height) on success, or (None, None) on failure.
    """
    img = cv2.imread(input_image_path)
    if img is None:
        print(f"Error: Could not load image {input_image_path}")
        return None, None

    height, width = img.shape[:2]

    # tdata[23:0] = {R[7:0], G[7:0], B[7:0]}; OpenCV loads BGR
    hex_pixels = []
    for row in range(height):
        for col in range(width):
            b, g, r = img[row, col]
            hex_pixels.append(f"{r:02x}{g:02x}{b:02x}")

    # Space-separated, compatible with Verilog $readmemh
    with open(output_txt_path, 'w') as f:
        f.write(" ".join(hex_pixels))
        f.write(" ")

    print(f"SUCCESS {width} {height}")   # machine-readable for image_viewer.py
    return width, height


if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.abspath(__file__))
    w, h = convert_png_to_hex_rgb(
        os.path.join(base_dir, "image.png"),
        os.path.join(base_dir, "image_data.txt")
    )
    if w is not None:
        sys.exit(0)
    else:
        sys.exit(1)
