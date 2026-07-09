# Mixer IP Demo

Two `intel_vvp_tpg` instances with different patterns feed an `intel_vvp_mixer`;
the mixer output frame is dumped to a hex file and converted to a PNG.

```
intel_vvp_tpg_0 (color bars, 64x64)    ──► mixer base layer  ─┐
intel_vvp_tpg_1 (uniform red, 32x32)   ──► mixer layer 1     ─┴─► axi4s_vid_out ──► hex ──► PNG
```

The overlay layer is placed at offset (16,16) with opaque blending, so the
output is 64x64 color bars with a 32x32 red square inset.

## Layout

- `system.qsys` — Platform Designer system (2x TPG + mixer, video streams
  connected internally; the three Avalon-MM control agents and the mixer
  video output are exported). Rebuild with:
  `qsys-script --script=build_system.tcl --quartus-project=mixer.qpf`
- `rtl/top.v` — configuration FSM (mixer layer setup → overlay TPG → base TPG)
  around the `system` instance
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

Frame geometry, overlay position, and overlay color are parameters at the top
of `rtl/tb.v` (`BG_*`, `FG_*`); keep `WIDTH`/`HEIGHT` in `app/hex_to_png.py`
in sync with `BG_WIDTH`/`BG_HEIGHT`. The TPG patterns themselves are
compile-time Qsys parameters (`CORE_PATTERN_0`: 0 = bars, 1 = uniform) set in
`build_system.tcl`; the uniform color is runtime-programmed by `top.v`.
