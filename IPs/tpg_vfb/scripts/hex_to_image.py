from PIL import Image

HEX_FILE  = "/home/izaan/tpg_vfb/sim/output_frame.hex"
OUT_IMAGE = "/home/izaan/tpg_vfb/sim/output_frame.png"
WIDTH     = 64
HEIGHT    = 64

pixels = []
with open(HEX_FILE, "r") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        if 'x' in line.lower() or 'z' in line.lower():
            pixels.append((255, 0, 255))  # magenta for unknown
            continue
        val = int(line, 16)
        r = (val >> 16) & 0xFF
        g = (val >>  8) & 0xFF
        b = (val >>  0) & 0xFF
        pixels.append((r, g, b))

total = WIDTH * HEIGHT
if len(pixels) < total:
    print(f"WARNING: only {len(pixels)} pixels, expected {total}")
    pixels += [(0,0,0)] * (total - len(pixels))
else:
    pixels = pixels[:total]

print(f"Total pixels read: {len(pixels)}")
img = Image.new("RGB", (WIDTH, HEIGHT))
img.putdata(pixels)
img.save(OUT_IMAGE)
print(f"Saved: {OUT_IMAGE}")
