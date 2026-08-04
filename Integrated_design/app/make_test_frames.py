#!/usr/bin/python3
"""
make_test_frames.py - build a numbered sequence of input frames for the
frame-rate-conversion test.

Produces NUM_FRAMES frames of FRAME_W x FRAME_H, each carrying its own index
rendered as digits plus a distinct background colour. Feed them through the
pipeline at a down-converting rate (e.g. 32 -> 16 fps) and the frames that come
out the other side tell you EXACTLY which inputs survived and which the frame
buffer discarded - the counters say "16 dropped", these say *which* 16.

Outputs:
  app/frames_in/frame_01.png ... frame_32.png   for viewing the input set
  app/image_data.txt                            all frames concatenated, the
                                                format tb.v's $readmemh expects

Pixel format matches hex_to_png.py exactly:  Cr<<16 | Y<<8 | Cb   (BT.601 full
range). Getting this wrong shows up as wrong colours, not as an error, so it is
verified by round-tripping in the self-test at the bottom.

Why digits AND colour: the digits are for humans, the flat background colour is
for the checker. A solid region decodes reliably even if the scaler applies a
filter kernel, whereas thin digit strokes might not survive resampling.
"""
import os

NUM_FRAMES = 32
FRAME_W    = 10
FRAME_H    = 10

BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
OUT_DIR   = os.path.join(BASE_DIR, "frames_in")
HEX_FILE  = os.path.join(BASE_DIR, "image_data.txt")

# 3x5 bitmap font, scaled up when drawn.
FONT = {
    '0': ["111", "101", "101", "101", "111"],
    '1': ["010", "110", "010", "010", "111"],
    '2': ["111", "001", "111", "100", "111"],
    '3': ["111", "001", "111", "001", "111"],
    '4': ["101", "101", "111", "001", "001"],
    '5': ["111", "100", "111", "001", "111"],
    '6': ["111", "100", "111", "101", "111"],
    '7': ["111", "001", "001", "001", "001"],
    '8': ["111", "101", "111", "101", "111"],
    '9': ["111", "101", "111", "001", "111"],
}


def rgb_to_ycbcr(r, g, b):
    """Inverse of hex_to_png.ycbcr_to_rgb (BT.601 full range)."""
    y  =  0.299    * r + 0.587    * g + 0.114    * b
    cb = -0.168736 * r - 0.331264 * g + 0.5      * b + 128
    cr =  0.5      * r - 0.418688 * g - 0.081312 * b + 128
    clip = lambda v: max(0, min(255, int(round(v))))
    return clip(y), clip(cb), clip(cr)


def pack(r, g, b):
    y, cb, cr = rgb_to_ycbcr(r, g, b)
    return (cr << 16) | (y << 8) | cb


def bg_colour(idx):
    """A distinct, well-separated colour per frame index.

    Deliberately avoids near-black and near-white so the white digits always
    contrast, and keeps the hues far apart so the checker can identify a frame
    from its background even after any filtering in the datapath.
    """
    hue = (idx * 360.0 / NUM_FRAMES) % 360.0
    h, s, v = hue / 60.0, 0.75, 0.80
    c = v * s
    x = c * (1 - abs((h % 2) - 1))
    m = v - c
    seg = int(h) % 6
    rgb = [(c, x, 0), (x, c, 0), (0, c, x),
           (0, x, c), (x, 0, c), (c, 0, x)][seg]
    return tuple(int(round((ch + m) * 255)) for ch in rgb)


def draw_digits(px, text, colour, scale, x0, y0):
    """Blit `text` into the pixel grid at (x0, y0)."""
    cx = x0
    for ch in text:
        glyph = FONT.get(ch)
        if glyph:
            for gy, row in enumerate(glyph):
                for gx, bit in enumerate(row):
                    if bit == '1':
                        for sy in range(scale):
                            for sx in range(scale):
                                x, y = cx + gx * scale + sx, y0 + gy * scale + sy
                                if 0 <= x < FRAME_W and 0 <= y < FRAME_H:
                                    px[y][x] = colour
        cx += (3 * scale) + (1 if scale == 1 else scale)


def build_frame(idx):
    """One frame: flat background colour + the index drawn in white."""
    bg = bg_colour(idx)
    px = [[bg for _ in range(FRAME_W)] for _ in range(FRAME_H)]

    text  = str(idx)
    scale = 1                                   # 3x5 font, 1:1 at 10x10
    tw    = len(text) * (3 * scale) + (len(text) - 1) * scale
    th    = 5 * scale
    draw_digits(px, text, (255, 255, 255),
                scale, (FRAME_W - tw) // 2, (FRAME_H - th) // 2)
    return px


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for f in os.listdir(OUT_DIR):
        if f.endswith(".png"):
            os.remove(os.path.join(OUT_DIR, f))

    try:
        from PIL import Image
        have_pil = True
    except ImportError:
        have_pil = False
        print("NOTE: PIL unavailable - writing image_data.txt only, no preview PNGs")

    words = []
    for idx in range(1, NUM_FRAMES + 1):
        px = build_frame(idx)
        for row in px:
            for (r, g, b) in row:
                words.append(f"{pack(r, g, b):06x}")
        if have_pil:
            im = Image.new("RGB", (FRAME_W, FRAME_H))
            im.putdata([p for row in px for p in row])
            im.save(os.path.join(OUT_DIR, f"frame_{idx:02d}.png"))

    # 16 words per line purely for readability; $readmemh ignores layout
    with open(HEX_FILE, "w") as fh:
        for i in range(0, len(words), 16):
            fh.write(" ".join(words[i:i + 16]) + "\n")

    print(f"Wrote {NUM_FRAMES} frames of {FRAME_W}x{FRAME_H}")
    print(f"  preview PNGs : {OUT_DIR}/frame_NN.png")
    print(f"  hex for tb.v : {HEX_FILE}  ({len(words)} words = "
          f"{NUM_FRAMES} x {FRAME_W * FRAME_H})")
    print(f"  tb.v must read {FRAME_W * FRAME_H} words per frame, "
          f"frame N at offset N*{FRAME_W * FRAME_H}")

    # self-test: the packing must round-trip through hex_to_png's decoder
    def ycbcr_to_rgb(y, cb, cr):
        cb -= 128; cr -= 128
        return (max(0, min(255, int(y + 1.402 * cr))),
                max(0, min(255, int(y - 0.344136 * cb - 0.714136 * cr))),
                max(0, min(255, int(y + 1.772 * cb))))
    worst = 0
    for idx in (1, 16, 32):
        want = bg_colour(idx)
        v = pack(*want)
        got = ycbcr_to_rgb((v >> 8) & 0xFF, v & 0xFF, (v >> 16) & 0xFF)
        worst = max(worst, max(abs(a - b) for a, b in zip(want, got)))
    print(f"  round-trip check: worst channel error {worst} "
          f"({'OK' if worst <= 2 else 'TOO HIGH - check the colour maths'})")


if __name__ == "__main__":
    main()
