# Mixer IP Demo

Eight `intel_vvp_tpg` instances feed an `intel_vvp_mixer` (`NUM_LAYERS=8`);
the mixer output frame is dumped to a hex file and converted to a PNG.

```
intel_vvp_tpg_0 (color bars, 1280x720)      ──► mixer base layer ─┐
intel_vvp_tpg_1 (uniform red,     180x180) ──► mixer layer 1    ─┤
intel_vvp_tpg_2 (uniform green,   180x180) ──► mixer layer 2    ─┤
intel_vvp_tpg_3 (uniform blue,    180x180) ──► mixer layer 3    ─┤
intel_vvp_tpg_4 (uniform yellow,  180x180) ──► mixer layer 4    ─┼─► axi4s_vid_out ──► hex ──► PNG
intel_vvp_tpg_5 (uniform cyan,    180x180) ──► mixer layer 5    ─┤
intel_vvp_tpg_6 (uniform magenta, 180x180) ──► mixer layer 6    ─┤
intel_vvp_tpg_7 (uniform white,   180x180) ──► mixer layer 7    ─┘
```

Overlay layer N is placed at offset ((N-1)*90, (N-1)*90) with opaque blending,
so the output is 1280x720 color bars with seven overlapping 180x180 colored
squares stepping down the diagonal; where squares overlap, the
higher-numbered layer is on top (white above magenta above cyan, ...).

## Layout

- `system.qsys` — Platform Designer system (8x TPG + mixer, video streams
  connected internally; the nine Avalon-MM control agents and the mixer
  video output are exported). Rebuild with:
  `qsys-script --script=build_system.tcl --quartus-project=mixer.qpf`
- `rtl/top.v` — configuration FSM (mixer layers 1..7 setup → overlay TPGs
  1..7 → base TPG 0) around the `system` instance
- `rtl/tb.v` — testbench; captures the first complete mixer output frame to
  `app/mixer_data.txt` via `make_file.v`/`controller.v`
- `app/runSim.py` — compiles the Qsys sim model + RTL in Questa and runs the
  testbench (`python3 app/runSim.py` headless, `python3 app/runSim.py True`
  for the GUI). Requires `QUARTUS_INSTALL_DIR` set and `vsim` on `PATH`.
- `app/hex_to_png.py` — converts `app/mixer_data.txt` to `app/mixer_result.png`

## Run

```bash
cd IPs/mixer
python3 app/runSim.py        # → app/mixer_data.txt
python3 app/hex_to_png.py    # → app/mixer_result.png
```

Frame geometry and overlay size/spacing are parameters at the top of
`rtl/tb.v` (`BG_*`, `FG_*`); keep `WIDTH`/`HEIGHT` in `app/hex_to_png.py`
in sync with `BG_WIDTH`/`BG_HEIGHT`. The overlay colors are the fixed
palette in `overlay_rgb()` in `rtl/top.v` (runtime-programmed); the TPG
patterns themselves are compile-time Qsys parameters (`CORE_PATTERN_0`:
0 = bars, 1 = uniform) set in `build_system.tcl`.
