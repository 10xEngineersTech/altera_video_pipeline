# Intel VVP Pipeline — Platform Component

## Overview

`intel_vvp_pipeline2_hw.tcl` is a Platform Designer composition component (`_hw.tcl`) that packages six Intel VVP IPs into a single reusable block with a parameterized GUI. It is the primary file in this directory.

The component name registered with Platform Designer is `intel_vvp_pipeline2`.

---


## Exported Interfaces

| Interface | Direction | Source |
|---|---|---|
| `clk` | input | `altera_clock_bridge` |
| `reset` | input | `altera_reset_bridge` |
| `av_mm_control` | slave | `altera_avalon_mm_bridge.s0` |
| `tpg_axi4s_vid_out` | output | TPG video out |
| `clipper_axi4s_vid_in` | input | Clipper video in |
| `scaler_axi4s_vid_out` | output | Scaler video out |
| `crs_axi4s_vid_in` | input | CRS video in |
| `crs_axi4s_vid_out` | output | CRS video out |
| `dil_axi4s_vid_in` | input | DIL video in |
| `dil_axi4s_vid_out` | output | DIL video out |

---

## GUI Parameters

The GUI is organized into five tabs plus a Block Diagram tab.

### General Tab

| Parameter | Type | Options / Range | Effect |
|---|---|---|---|
| Bits Per Sample | INTEGER | 8 / 10 / 12 | Propagated to all IPs as `BPS` |
| Number of Color Planes | INTEGER | 1–4 | Propagated to Clipper, Protocol Conv, Scaler, DIL |
| Pixels in Parallel | INTEGER | 1 / 2 / 4 / 8 | Propagated to all IPs |
| Max Frame Width | INTEGER | — | Sets `MAX_IN_WIDTH` / `MAX_OUT_WIDTH` on Scaler |
| Max Frame Height | INTEGER | — | Sets `OUTPUT_HEIGHT` on Scaler |
| Color Space | STRING | `RGB` / `YUV_444` / `YUV_422` / `YUV_420` | See [Color Space](#color-space-parameter) |
| Lite Mode | INTEGER (bool) | 0 / 1 | See [Lite Mode](#lite-mode-parameter) |

### Block Diagram Tab

Static HTML panel displaying the pipeline topology image (`doc/pipeline_diagram_wide.png`). The four radio buttons (Full / Simplified / Option C / Option D) are decorative — all show the same image.

### Scaler Config Tab

Three collapsible sub-groups matching the Intel VVP Scaler GUI:

| Sub-group | Parameters |
|---|---|
| Scaling | Algorithm, Edge Mirror, Enable V/H Scaling, No Blanking, Runtime Load, Mem Init |
| Vertical Scaling | Taps, Phases, Banks, Partial Scaling, 4:2:0 Mirror, Coeff Function/Signed/Int-Bits/Frac-Bits, Prescale Frac Bits |
| Horizontal Scaling | Taps, Phases, Banks, Partial Scaling, Half Rate 4:2:0, Coeff Function/Signed/Int-Bits/Frac-Bits |

### Clipper Config Tab

One sub-group:

| Sub-group | Parameters |
|---|---|
| Clipping | Clipping Method (OFFSETS / RECTANGLE), Left/Top/Right/Bottom Offset, Rectangle Width/Height |

### Chroma Resampler Config Tab

Three sub-groups matching the Intel VVP CRS GUI:

| Sub-group | Parameters |
|---|---|
| Chroma Sampling | Max Width, six conversion mode toggles (444↔422, 444↔420, 422↔420), three pass-through toggles (420/422/444) |
| Horizontal Settings | Algorithm, Co-Siting, Enable Luma Adapt |
| Vertical Settings | Algorithm, Co-Siting, Enable Luma Adapt |

---

## Color Space Parameter

The `COLOR_SPACE` parameter is a single abstraction that simultaneously configures three IPs:

| `COLOR_SPACE` value | Protocol Conv `COLOR_SPACE` | Protocol Conv `CHROMA_SAMPLING` | TPG `OUTPUT_FORMAT` | TPG `CORE_COL_SPACE_0` | Scaler ENABLE flags |
|---|---|---|---|---|---|
| `RGB` | `RGB` | 444 | `4.4.4` | 0 | 444=1, 422=0, 420=0 |
| `YUV_444` | `YCbCr` | 444 | `4.4.4` | 1 | 444=1, 422=0, 420=0 |
| `YUV_422` | `YCbCr` | 422 | `4.2.2` | 2 | 444=0, 422=1, 420=0 |
| `YUV_420` | `YCbCr` | 420 | `4.2.0` | 3 | 444=0, 422=0, 420=1 |

---

## Lite Mode Parameter

The `AXIS_LITE_MODE` checkbox propagates `EXTERNAL_MODE` to five IPs: TPG, Clipper, Scaler, CRS, and DIL. When enabled, these IPs use the AXI4-Stream Lite variant of their video interface.

---

## How to Use

1. Add the directory containing `intel_vvp_pipeline2_hw.tcl` to the Platform Designer IP search paths (or the Quartus IP Catalog).
2. Instantiate `intel_vvp_pipeline2` in your top-level `.qsys` file.
3. Configure parameters through the GUI — all settings propagate to the sub-IPs at generation time via `compose {}`.
4. Connect `clk`, `reset`, and `av_mm_control` from your system; wire the AXI4-Stream ports to your video datapath.

---

## Known Limitations

- Block Diagram radio buttons are decorative; image switching is not implemented.
- The `file:///` path used to load diagram images may not resolve in all Platform Designer environments.
- DIL parameters (mode, width, buffer stride, FIFO depth) are hardcoded in `compose {}` and not exposed in the GUI.
- TPG fixed-pattern parameters (width, height, FPS, color values) are hardcoded in `compose {}` and not exposed in the GUI.
