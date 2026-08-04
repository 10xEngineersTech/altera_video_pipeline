#!/usr/bin/python3
"""
frames_to_png.py - turn the captured output frames into viewable images.

The simulation writes each output frame as hex text to app/frames/. This
converts every one to a PNG in app/frames_out/, names it with the INPUT frame
it came from, and builds a side-by-side filmstrip so the conversion is visible
at a glance:

    app/frames_out/out_00_src01.png     <- 1st output, was input frame 1
    app/frames_out/out_07_src10.png     <- 8th output, was input frame 10
    app/frames_out/filmstrip.png        <- input row vs output row

Decoding matches hex_to_png.py:  Cr<<16 | Y<<8 | Cb  (BT.601 full range).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_frame_sequence as C          # reuse the tag decoder

BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
FRAMES_DIR = os.path.join(BASE_DIR, "frames")
IN_DIR     = os.path.join(BASE_DIR, "frames_in")
OUT_DIR    = os.path.join(BASE_DIR, "frames_out")
W = H = 10                                # must match the captured geometry


def ycbcr_to_rgb(y, cb, cr):
    cb -= 128; cr -= 128
    return (max(0, min(255, int(y + 1.402 * cr))),
            max(0, min(255, int(y - 0.344136 * cb - 0.714136 * cr))),
            max(0, min(255, int(y + 1.772 * cb))))


def load_pixels(path):
    words = []
    for tok in open(path).read().split():
        try:
            words.append(int(tok, 16))
        except ValueError:
            pass
    px = []
    for v in words[:W * H]:
        px.append(ycbcr_to_rgb((v >> 8) & 0xFF, v & 0xFF, (v >> 16) & 0xFF))
    while len(px) < W * H:                # pad a short/truncated frame
        px.append((0, 0, 0))
    return px


def main():
    try:
        from PIL import Image
    except ImportError:
        print("PIL required: pip install pillow"); return 1
    if not os.path.isdir(FRAMES_DIR):
        print(f"No {FRAMES_DIR} - run the simulation first."); return 1

    os.makedirs(OUT_DIR, exist_ok=True)
    for f in os.listdir(OUT_DIR):
        if f.endswith(".png"):
            os.remove(os.path.join(OUT_DIR, f))

    files = sorted(f for f in os.listdir(FRAMES_DIR)
                   if f.endswith(".txt")
                   and os.path.getsize(os.path.join(FRAMES_DIR, f)) > 0)
    if not files:
        print("No non-empty frame files."); return 1

    outs = []
    for n, f in enumerate(files):
        path = os.path.join(FRAMES_DIR, f)
        idx, _ = C.decode_frame(path)
        im = Image.new("RGB", (W, H))
        im.putdata(load_pixels(path))
        name = f"out_{n:02d}_src{idx:02d}.png" if idx else f"out_{n:02d}_srcXX.png"
        im.save(os.path.join(OUT_DIR, name))
        outs.append((idx, im))
        print(f"  {f}  ->  {name}")

    # filmstrip: full input sequence on top, what survived underneath,
    # each survivor sitting under the input it came from
    scale, gap = 8, 2
    n_in = C.NUM_FRAMES
    strip_w = n_in * (W * scale + gap)
    strip = Image.new("RGB", (strip_w, 2 * (H * scale) + 3 * gap), (30, 30, 30))
    for i in range(1, n_in + 1):
        p = os.path.join(IN_DIR, f"frame_{i:02d}.png")
        if os.path.exists(p):
            strip.paste(Image.open(p).resize((W * scale, H * scale), Image.NEAREST),
                        ((i - 1) * (W * scale + gap), gap))
    for idx, im in outs:
        if idx:
            strip.paste(im.resize((W * scale, H * scale), Image.NEAREST),
                        ((idx - 1) * (W * scale + gap), H * scale + 2 * gap))
    strip.save(os.path.join(OUT_DIR, "filmstrip.png"))

    survived = sorted({i for i, _ in outs if i})
    print(f"\n  {len(files)} output frames -> {OUT_DIR}/")
    print(f"  filmstrip.png : top row = all 32 inputs, bottom row = survivors")
    print(f"  survived: {' '.join(map(str, survived))}")
    print(f"  gaps in the bottom row are the dropped frames")
    return 0


if __name__ == "__main__":
    sys.exit(main())
