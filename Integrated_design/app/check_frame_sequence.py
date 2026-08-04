#!/usr/bin/python3
"""
check_frame_sequence.py - identify WHICH input frames survived the conversion.

The VFB counters tell you 16 frames were dropped. This tells you which 16.

Each captured output frame in app/frames/ carries the index of the input frame
it came from, encoded as a flat background colour by make_test_frames.py. We
decode by taking the most common pixel value in the frame (the background - the
white digits are a minority) and matching it to the nearest of the 32 known
background colours.

Matching on the flat background rather than OCR'ing the digits is deliberate: a
solid region survives any filtering the scaler might apply, thin strokes might
not.
"""
import os
import sys
from collections import Counter

NUM_FRAMES = 32
BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
FRAMES_DIR = os.path.join(BASE_DIR, "frames")
RESULT     = os.path.join(BASE_DIR, "frc_result.txt")


def rgb_to_ycbcr(r, g, b):
    y  =  0.299    * r + 0.587    * g + 0.114    * b
    cb = -0.168736 * r - 0.331264 * g + 0.5      * b + 128
    cr =  0.5      * r - 0.418688 * g - 0.081312 * b + 128
    clip = lambda v: max(0, min(255, int(round(v))))
    return clip(y), clip(cb), clip(cr)


def bg_colour(idx):
    """Must stay identical to make_test_frames.bg_colour."""
    hue = (idx * 360.0 / NUM_FRAMES) % 360.0
    h, s, v = hue / 60.0, 0.75, 0.80
    c = v * s
    x = c * (1 - abs((h % 2) - 1))
    m = v - c
    seg = int(h) % 6
    rgb = [(c, x, 0), (x, c, 0), (0, c, x),
           (0, x, c), (x, 0, c), (c, 0, x)][seg]
    return tuple(int(round((ch + m) * 255)) for ch in rgb)


# index -> expected (Y, Cb, Cr) of that frame's background
EXPECTED = {i: rgb_to_ycbcr(*bg_colour(i)) for i in range(1, NUM_FRAMES + 1)}


def decode_frame(path):
    """Return (index, distance) for the frame's dominant background colour."""
    words = []
    with open(path) as fh:
        for tok in fh.read().split():
            try:
                words.append(int(tok, 16))
            except ValueError:
                pass
    if not words:
        return None, None
    dom = Counter(words).most_common(1)[0][0]
    cr, y, cb = (dom >> 16) & 0xFF, (dom >> 8) & 0xFF, dom & 0xFF
    best, bestd = None, 1e9
    for idx, (ey, ecb, ecr) in EXPECTED.items():
        d = (y - ey) ** 2 + (cb - ecb) ** 2 + (cr - ecr) ** 2
        if d < bestd:
            best, bestd = idx, d
    return best, int(bestd ** 0.5)


def main():
    if not os.path.isdir(FRAMES_DIR):
        print(f"No {FRAMES_DIR} - run the simulation first."); return 1
    files = sorted(f for f in os.listdir(FRAMES_DIR) if f.endswith(".txt"))
    files = [f for f in files if os.path.getsize(os.path.join(FRAMES_DIR, f)) > 0]
    if not files:
        print("No non-empty frame files captured."); return 1

    seq = []
    print(f"{'file':<20} {'-> input frame':<16} match-error")
    print("-" * 52)
    for f in files:
        idx, dist = decode_frame(os.path.join(FRAMES_DIR, f))
        seq.append(idx)
        flag = "" if (dist is not None and dist < 40) else "   <-- POOR MATCH"
        print(f"{f:<20} {str(idx):<16} {dist}{flag}")

    print("\n" + "=" * 52)
    print("OUTPUT SEQUENCE :", " ".join(str(i) for i in seq))

    # Within the span actually covered, which inputs never appeared?
    present = [i for i in seq if i is not None]
    if present:
        lo, hi = min(present), max(present)
        missing = [i for i in range(lo, hi + 1) if i not in present]
        dups = [i for i, c in Counter(present).items() if c > 1]
        print(f"SPAN COVERED    : input frames {lo}..{hi}")
        print(f"SURVIVED        : {len(set(present))} distinct")
        print(f"DROPPED         : {' '.join(map(str, missing)) if missing else '(none)'}"
              f"   [{len(missing)} frames]")
        if dups:
            print(f"REPEATED        : {' '.join(map(str, sorted(dups)))}")
        span = hi - lo + 1
        if len(set(present)):
            print(f"EFFECTIVE RATIO : {span}/{len(set(present))} = "
                  f"{span / len(set(present)):.3f} input frames per output frame")

    # cross-check against what the hardware counters reported
    if os.path.exists(RESULT):
        r = {}
        for line in open(RESULT):
            if "=" in line:
                k, v = line.strip().split("=", 1)
                r[k] = v
        print("\nHARDWARE COUNTERS (frc_result.txt):")
        print(f"  verdict={r.get('verdict')}  dIN={r.get('d_in')} "
              f"dDROPPED={r.get('d_dropped')} dOUT={r.get('d_out')} "
              f"dREPEATED={r.get('d_repeated')}")
        print(f"  requested {r.get('requested_ratio')}, achieved {r.get('achieved_ratio')}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
