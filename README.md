# Altera Video Processing Pipeline — Comprehensive README

> A deep-dive guide explaining the architecture, configuration flow, simulation design, and every moving part of this Intel/Altera FPGA video pipeline project.

---

## Table of Contents

1. [Project Goal](#1-project-goal)
2. [Toolchain & Environment](#2-toolchain--environment)
3. [Repository Layout](#3-repository-layout)
4. [Pipeline Architecture (The Big Picture)](#4-pipeline-architecture-the-big-picture)
5. [Each IP Block Explained](#5-each-ip-block-explained)
6. [How Configuration Actually Works](#6-how-configuration-actually-works)
   - 6.1 [Avalon-MM Protocol Basics](#61-avalon-mm-protocol-basics)
   - 6.2 [The Configuration State Machine (top.v)](#62-the-configuration-state-machine-topv)
   - 6.3 [TPG Configuration Steps](#63-tpg-configuration-steps)
   - 6.4 [Clipper Configuration Steps](#64-clipper-configuration-steps)
   - 6.5 [Scaler Configuration Steps](#65-scaler-configuration-steps)
   - 6.6 [Resampler (CRS) Configuration Steps](#66-resampler-crs-configuration-steps)
   - 6.7 [Color Space Converter (CSC) Configuration Steps](#67-color-space-converter-csc-configuration-steps)
   - 6.8 [Protocol Converter 1 (PC1) Configuration (INPUT_SEL=1 only)](#68-protocol-converter-1-pc1-configuration-input_sel1-only)
7. [CSC Coefficient System (Q10.21 Fixed-Point)](#7-csc-coefficient-system-q1021-fixed-point)
8. [Data Flow & AXI4-Stream Signals](#8-data-flow--axi4-stream-signals)
9. [Testbench Deep Dive (tb.v)](#9-testbench-deep-dive-tbv)
10. [RTL File Roles](#10-rtl-file-roles)
11. [The GUI Application](#11-the-gui-application)
12. [Simulation Output Files](#12-simulation-output-files)
13. [Independent IP Testbenches](#13-independent-ip-testbenches)
14. [Register Map Quick Reference](#14-register-map-quick-reference)
15. [Common Gotchas & Design Decisions](#15-common-gotchas--design-decisions)

---

## 1. Project Goal

This project replicates the functionality of **AMD's Video Processing Subsystem (VPSS) IP** using the **Intel/Altera VVP (Video and Vision Processing) IP suite** and Altera's Platform Designer (Qsys) toolchain.

The pipeline takes a video source (either a hardware Test Pattern Generator or an image loaded from a PNG file), passes it through a chain of processing stages — deinterlacing, chroma resampling, color space conversion, spatial cropping, and resolution scaling — and outputs a fully processed video frame.

---

## 2. Toolchain & Environment

| Tool | Version | Role |
|------|---------|------|
| Quartus | 25.1 | Synthesis & Implementation |
| QuestaSim FPGA Starter Edition | 21.1 | RTL Simulation |
| Python 3 + GTK3 | — | GUI application |
| OpenCV (Python) | — | PNG reconstruction from hex output |

---

## 3. Repository Layout

```
altera_video_pipeline/
├── Integrated_design/           ← Full end-to-end pipeline
│   ├── app/                     ← GUI + Python utilities + generated config files
│   ├── rtl/                     ← Simulation RTL (tb.v, top.v, make_file.v, controller.v)
│   ├── platform/                ← Platform Designer (Qsys) system (pipeline.v + IP cores)
│   └── quartus/                 ← Quartus project files
└── IPs/                         ← Isolated IP testbenches
    ├── clipper_axisfull_reconfigurable/
    ├── deinterlacer_axisfull_rgb_only/
    ├── resampler_II_avalon_fixed/
    ├── resampler_axisfull_1ppc_fixed/
    ├── ColorSpace/
    ├── tpg_full_mode_configurable/
    └── scaler_axislite_reconfigurable/
```

The two main areas are:
- **`Integrated_design/`** — the complete pipeline working end-to-end, with a GUI to drive it.
- **`IPs/`** — standalone testbenches to validate each IP block in isolation before integrating.

---

## 4. Pipeline Architecture (The Big Picture)

The integrated pipeline processes video through this fixed chain:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  [TPG] ──AXIS Full──► [DIL] ──AXIS Full──► [CRS] ──AXIS Full──► [CSC]     │
│  (YUV422           (Deinterlacer)       (Resampler:         (Color Space    │
│   Interlaced)      progressive out)     422→444)            Converter)      │
│                                                                     │       │
│                                                              AXIS Full      │
│                                                                     ▼       │
│  [Scaler] ◄──AXIS Lite──[PC0] ◄──AXIS Full──[Clipper] ◄────────────┘      │
│  (Downscale)  (Protocol    (Spatial crop)                                   │
│               Converter)                                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key insight:** The TPG and DIL (Deinterlacer) are NOT internally connected inside `pipeline.v`. The `top.v` module bridges them externally. This is intentional — it allows `top.v` to **gate the data flow** until all IPs are fully configured.

There is also an alternate input path (when `INPUT_SEL=1`): instead of the TPG, a PNG image is loaded from disk and injected into the pipeline via **Protocol Converter 1 (PC1)**, which converts the AXI4-Stream Lite feed into Full mode before entering the DIL.

---

## 5. Each IP Block Explained

### Test Pattern Generator (TPG)
- **Role:** Generates synthetic video frames (color bars, ramps, etc.) as the primary video source.
- **Output format:** AXI4-Stream Full, YUV 4:2:2, Interlaced.
- **Configured via:** Avalon-MM register writes (width, height, pattern type, interlace mode, commit).
- **Reconfigurable:** Yes — parameters like resolution and pattern can be changed at runtime.

### Deinterlacer (DIL)
- **Role:** Converts interlaced video (two fields per frame) into progressive video (one complete frame). This doubles the effective line count.
- **Output format:** AXI4-Stream Full, YUV 4:2:2, Progressive.
- **Reconfigurable:** No — fixed configuration, no register writes needed.

### Chroma Resampler (CRS)
- **Role:** Upsamples chroma from YUV 4:2:2 (one chroma sample per 2 pixels horizontally) to YUV 4:4:4 (full chroma for every pixel). This is needed before color space conversion.
- **Output format:** AXI4-Stream Full, YUV 4:4:4.
- **Reconfigurable:** Yes — the output mode register selects 4:2:2 or 4:4:4 output.

### Color Space Converter (CSC)
- **Role:** Applies a 3×3 matrix transformation + offset (summand) to convert between RGB and YCbCr color spaces (BT.709 or BT.601).
- **Output format:** AXI4-Stream Full (same pixel width, different color encoding).
- **Reconfigurable:** Yes — 13 coefficient/summand registers + commit. Requires polling a status register to confirm the new coefficients have taken effect.
- **Modes available:**
  - Mode 0: Passthrough (RGB→RGB, identity matrix)
  - Mode 1: RGB → YCbCr HD (BT.709)
  - Mode 2: YCbCr HD → RGB
  - Mode 3: RGB → YCbCr SD (BT.601)
  - Mode 4: YCbCr SD → RGB

### Clipper
- **Role:** Spatial cropping — trims pixels from the top, bottom, left, and right edges of the frame. Useful for removing overscan or extracting a region of interest.
- **Output size:** `(Width - Left_off - Right_off) × (Height - Top_off - Bottom_off)`
- **Interface:** AXI4-Stream Full in → AXI4-Stream Full out.
- **Reconfigurable:** Yes — offsets are written via Avalon-MM, then committed with register `0x51`.

### Protocol Converter 0 (PC0)
- **Role:** Bridges AXI4-Stream **Full** (carries embedded frame metadata in sideband signals) to AXI4-Stream **Lite** (simpler handshake). The Scaler operates in Lite mode.
- **Reconfigurable:** No — internal Qsys component, transparent to the user.

### Scaler
- **Role:** High-quality resolution downscaling. Takes the clipped frame and reduces it to the desired output resolution.
- **Interface:** AXI4-Stream Lite in → AXI4-Stream Lite out.
- **Reconfigurable:** Yes — four registers: input width/height and output width/height.

---

## 6. How Configuration Actually Works

### 6.1 Avalon-MM Protocol Basics

Each IP is controlled via an **Avalon Memory-Mapped (Avalon-MM)** control port. Think of it as a simple bus interface:

```
Master (top.v FSM) ──[address, writedata, write]──► Slave (IP core)
                   ◄──[waitrequest]────────────────
```

The key rule is: **you must hold `address` and `writedata` stable whenever `waitrequest=1`**. The slave asserts `waitrequest` when it's busy and can't accept a transaction yet. Only when `waitrequest=0` is the transaction accepted.

In `top.v`, every IP has its own dedicated set of registers:
```verilog
reg [6:0]  clip_addr;  reg clip_write;  reg [31:0] clip_wdata;
wire       clip_wait;   // driven by the IP
```

Reads work similarly: assert `read`, hold `address`, wait for `waitrequest` to deassert, then wait for `readdatavalid` to go high on a later cycle, then sample `readdata`.

### 6.2 The Configuration State Machine (top.v)

`top.v` contains a large **Finite State Machine (FSM)** that sequences all register writes in the correct order before allowing video data to flow. The states, in order, are:

```
ST_IDLE
  └─► ST_TPG_CTRL_1        ← Disable TPG (write 0 to CONTROL)
  └─► ST_TPG_WR_INTL       ← Set interlace mode
  └─► ST_TPG_WR_W          ← Set frame width
  └─► ST_TPG_WR_H          ← Set frame height
  └─► ST_TPG_WR_PAT_T      ← Set bar selector (pattern type part 1)
  └─► ST_TPG_WR_PAT_S      ← Set pattern type
  └─► ST_TPG_WR_CMT        ← Commit TPG settings (write 1 to COMMIT)
  └─► ST_TPG_CTRL_2        ← Enable TPG (write 1 to CONTROL)
  └─► ST_TPG_POLL_ISS      ← Issue a status read
  └─► ST_TPG_POLL_W        ← Wait for read data; if TPG not ready, poll again
  └─► ST_TPG_IP_RST        ← Wait 8 clock cycles (internal reset settling)
  └─► ST_TPG_CTRL_3        ← Re-enable TPG
  └─► ST_CONFIG_CLIP        ← Write 9 Clipper registers
  └─► ST_CONFIG_SCL         ← Write 4 Scaler registers
  └─► ST_CONFIG_CRS         ← Write 2 CRS registers (mode + commit)
  └─► ST_CONFIG_CSC         ← Write 14 CSC registers (coefficients + commit)
  └─► ST_POLL_CSC           ← Poll CSC status until commit is absorbed
  └─► ST_WORKING            ← All done! Video flows.

  (If INPUT_SEL=1, insert ST_CONFIG_PC1 between ST_POLL_CSC and ST_WORKING)
```

**Data gating:** The critical gate is:
```verilog
wire ready_to_start = (current_state >= ST_CONFIG_CSC);
assign dil_in_tvalid = tpg_out_tvalid & ready_to_start;
```
The TPG starts generating data immediately after `ST_TPG_CTRL_3`, but this data is **blocked from reaching the DIL** until the FSM reaches `ST_CONFIG_CSC`. This ensures no data enters the pipeline before the Clipper, Scaler, CRS, and CSC are configured.

### 6.3 TPG Configuration Steps

| State | Register | Address | Value | Purpose |
|-------|----------|---------|-------|---------|
| ST_TPG_CTRL_1 | CONTROL | `0x52` | `0x0` | Disable TPG before changing settings |
| ST_TPG_WR_INTL | IMG_INFO_INTERLACE | `0x4A` | `0x0` | Set interlaced mode (0 = interlaced fields) |
| ST_TPG_WR_W | IMG_INFO_WIDTH | `0x48` | `IMG_WIDTH` | Frame width in pixels |
| ST_TPG_WR_H | IMG_INFO_HEIGHT | `0x49` | `IMG_HEIGHT` | Frame height in lines |
| ST_TPG_WR_PAT_T | BAR_SEL | `0x5A` | `0x0` | Color bar selector |
| ST_TPG_WR_PAT_S | PATTERN | `0x54` | `0x0` | Pattern type (0 = color bars) |
| ST_TPG_WR_CMT | COMMIT | `0x53` | `0x1` | Latch all settings atomically |
| ST_TPG_CTRL_2 | CONTROL | `0x52` | `0x1` | Enable TPG |
| ST_TPG_POLL_ISS | STATUS | `0x50` | read | Issue status register read |
| ST_TPG_POLL_W | — | — | check bit[1] | bit[1]=0 means ready; poll until ready |
| ST_TPG_IP_RST | — | — | wait 8 cycles | Settling time after reset |
| ST_TPG_CTRL_3 | CONTROL | `0x52` | `0x1` | Re-enable to start producing data |

> **Why disable before writing?** Writing to a running IP can cause mid-frame corruption. Disable → configure → commit → re-enable is the safe sequence.

### 6.4 Clipper Configuration Steps

The Clipper uses a **multi-step sub-FSM** within `ST_CONFIG_CLIP`, driven by a `cfg_step` counter. Nine consecutive writes are issued:

| cfg_step | Register | Address | Value |
|----------|----------|---------|-------|
| 0 | IMG_INFO_HEIGHT | `0x49` | `IMG_HEIGHT` |
| 1 | IMG_INFO_WIDTH | `0x48` | `IMG_WIDTH` |
| 2 | IMG_INFO_COLOR_SPC | `0x4C` | `IMG_COLOR` (e.g., 1 = YUV) |
| 3 | IMG_INFO_CHROMA_SUB | `0x4D` | `IMG_CR_SM` (e.g., 3 = 4:4:4) |
| 4 | LEFT_OFFSET | `0x52` | `IMG_L_OFF` |
| 5 | TOP_OFFSET | `0x53` | `IMG_T_OFF` |
| 6 | RIGHT_OFFSET | `0x54` | `IMG_R_OFF` |
| 7 | BOTTOM_OFFSET | `0x55` | `IMG_B_OFF` |
| 8 | COMMIT | `0x51` | `0x1` → apply all offsets |

**Important pattern:** The FSM "pre-loads" the next address/data pair atomically while accepting the current transaction (when `clip_write=1 AND clip_wait=0`). This ensures `addr/data` are always stable by the time the next cycle's `waitrequest` could fire.

The output frame size from the Clipper becomes the Scaler's input size:
```
SCALER_IN_W = IMG_WIDTH  - IMG_R_OFF - IMG_L_OFF
SCALER_IN_H = IMG_HEIGHT - IMG_T_OFF - IMG_B_OFF
```

### 6.5 Scaler Configuration Steps

Four writes in `ST_CONFIG_SCL`:

| cfg_step | Register | Address | Value |
|----------|----------|---------|-------|
| 0 | IMG_INFO_WIDTH (input) | `0x48` | `SCALER_IN_W` (clipped width) |
| 1 | IMG_INFO_HEIGHT (input) | `0x49` | `SCALER_IN_H` (clipped height) |
| 2 | OUTPUT_WIDTH | `0x52` | `SCALER_OUT_W` |
| 3 | OUTPUT_HEIGHT | `0x53` | `SCALER_OUT_H` |

The Scaler must know both its **input** dimensions (what's coming in from the Clipper) and its **output** dimensions (the desired output resolution).

### 6.6 Resampler (CRS) Configuration Steps

Two writes in `ST_CONFIG_CRS`:

| cfg_step | Register | Address | Value |
|----------|----------|---------|-------|
| 0 | OUTPUT_MODE | `0x52` | `CRS_OUTPUT_MODE` (2=4:2:2, 3=4:4:4) |
| 1 | COMMIT | `0x51` | `0x1` |

Default `CRS_OUTPUT_MODE = 3` (YUV 4:4:4), required before the CSC which expects full-chroma input.

### 6.7 Color Space Converter (CSC) Configuration Steps

This is the most complex configuration: 14 writes in `ST_CONFIG_CSC`.

| cfg_step | Register | Address | Value |
|----------|----------|---------|-------|
| 0 | COEFF_A0 | `0x52` | Row 0, Col 0 of 3×3 matrix |
| 1 | COEFF_A1 | `0x53` | Row 0, Col 1 |
| 2 | COEFF_A2 | `0x54` | Row 0, Col 2 |
| 3 | COEFF_B0 | `0x55` | Row 1, Col 0 |
| 4 | COEFF_B1 | `0x56` | Row 1, Col 1 |
| 5 | COEFF_B2 | `0x57` | Row 1, Col 2 |
| 6 | COEFF_C0 | `0x58` | Row 2, Col 0 |
| 7 | COEFF_C1 | `0x59` | Row 2, Col 1 |
| 8 | COEFF_C2 | `0x5A` | Row 2, Col 2 |
| 9 | SUMMAND_S0 | `0x5B` | Offset added to output channel 0 |
| 10 | SUMMAND_S1 | `0x5C` | Offset added to output channel 1 |
| 11 | SUMMAND_S2 | `0x5D` | Offset added to output channel 2 |
| 12 | OUT_CS | `0x5E` | Output color space declaration |
| 13 | COMMIT | `0x51` | `0xFFFFFFFF` → apply all coefficients |

After COMMIT, the FSM moves to `ST_POLL_CSC` and repeatedly reads the STATUS register until `bit[1] == 0`, confirming the new coefficients have been absorbed by the hardware. This is necessary because the CSC applies new settings only at a frame boundary.

**Special case for INPUT_SEL=1:** If using an image source instead of TPG, the CSC poll is skipped because no data is flowing yet (so there's no frame boundary to wait for). The FSM goes directly from `ST_CONFIG_CSC` to `ST_CONFIG_PC1`.

### 6.8 Protocol Converter 1 (PC1) Configuration (INPUT_SEL=1 only)

Six writes in `ST_CONFIG_PC1`:

| cfg_step | Register | Address | Value |
|----------|----------|---------|-------|
| 0 | IMG_INFO_WIDTH | `0x48` | `IMG_WIDTH` |
| 1 | IMG_INFO_HEIGHT | `0x49` | `IMG_HEIGHT` |
| 2 | IMG_INFO_INTERLACE | `0x4A` | `0x0` (progressive) |
| 3 | IMG_INFO_COLORSPACE | `0x4C` | `0x0` (RGB) |
| 4 | IMG_INFO_SUBSAMPLING | `0x4D` | `0x3` (4:4:4) |
| 5 | CTRL | `0x55` | `0x1` (start/enable) |

After this, the FSM enters `ST_WORKING` and the testbench starts streaming the image pixel-by-pixel from the hex file into `pc1_in_tdata`.

---

## 7. CSC Coefficient System (Q10.21 Fixed-Point)

The CSC uses **Q10.21 signed fixed-point** numbers (32 bits: 10 integer bits + 21 fractional bits + 1 sign bit).

To convert a real matrix coefficient `f` to Q10.21:
```
Q10.21 value = round(f × 2^21) = round(f × 2097152)
```

Example — BT.709 RGB→YCbCr, `RH_A0 = 0x000E0C4A`:
```
0x000E0C4A = 921674 decimal
921674 / 2097152 ≈ 0.2126  (this is the standard BT.709 R→Y luma coefficient)
```

The full transformation is:
```
[Out0]   [A0 B0 C0]   [In0]   [S0]
[Out1] = [A1 B1 C1] × [In1] + [S1]
[Out2]   [A2 B2 C2]   [In2]   [S2]
```

The five built-in modes:

| Mode | CSC_MODE | Description |
|------|----------|-------------|
| Passthrough | 0 | Identity matrix, no conversion |
| RGB → YCbCr HD | 1 | BT.709, adds luma/chroma offsets via summands |
| YCbCr HD → RGB | 2 | Inverse BT.709 |
| RGB → YCbCr SD | 3 | BT.601, older standard (SD video) |
| YCbCr SD → RGB | 4 | Inverse BT.601 |

The coefficient mux in `top.v` selects the right constants based on the `CSC_MODE` parameter at elaboration time.

---

## 8. Data Flow & AXI4-Stream Signals

AXI4-Stream uses these standard signals:

| Signal | Direction | Meaning |
|--------|-----------|---------|
| `tdata` | Source → Sink | Pixel data (24-bit: 8 bits per channel) |
| `tvalid` | Source → Sink | Source has valid data to send |
| `tready` | Sink → Source | Sink can accept data this cycle |
| `tlast` | Source → Sink | Last pixel of the current video line (End-Of-Line) |
| `tuser[0]` | Source → Sink | Start-Of-Frame (SOF) — marks the very first pixel of a new frame |

**A transaction occurs when `tvalid AND tready` are both high on a rising clock edge.**

### AXI4-Stream Full vs Lite

- **Full:** Carries full frame metadata including SOF (`tuser[0]`) and EOL (`tlast`) embedded directly in the stream. Used by: TPG, DIL, CRS, CSC, Clipper.
- **Lite:** A simplified variant used by the Scaler. The Protocol Converter (PC0) bridges Full→Lite.

### Data Format

Pixel data is 24 bits wide: `tdata[23:16]` = channel 2, `[15:8]` = channel 1, `[7:0]` = channel 0. The exact meaning depends on color space (e.g., U-Y-V for YUV, R-G-B for RGB).

---

## 9. Testbench Deep Dive (tb.v)

`tb.v` is the top-level simulation harness. Here's what it does, step by step:

### Setup
```verilog
`include "../app/configuration.vh"   // Pull in GUI-generated parameters
```
All simulation parameters (resolution, crop offsets, scaler dimensions) come from the auto-generated `configuration.vh`.

### Clock & Reset
- Clock period: 10 ns (100 MHz)
- Reset is asserted for 10 clock cycles, then deasserted

### Scaler Output Capture (`make_file` instance)
```verilog
make_file #(
    .IMG_H(SCALER_OUT_H), .IMG_W(SCALER_OUT_W),
    .IS_FULL(0),                        // Scaler output is AXIS Lite
    .FILE_NAME("../../../../app/sc_data.txt")
) scaler_out (...);
```
This module monitors the Scaler's output and writes a complete frame to `sc_data.txt`. It only captures data when `dut.current_state == ST_WORKING`.

### Stimulus Sequence
```
1. Assert reset for 10 cycles
2. Deassert reset
3. Wait for FSM to reach ST_WORKING
4. Assert out_tready (backpressure removed)
5. Wait for first SOF (tuser[0]=1)
6. Wait for 5 more line-end events (tlast=1)
7. Wait for frame_done from make_file
8. $finish
```

### Image Source (INPUT_SEL=1)
A `generate` block instantiates an "image hex player" only when `INPUT_SEL=1`. It:
1. Loads `image_data.txt` (PNG converted to hex by `png_to_hex.py`) into memory
2. Waits for `ST_WORKING`
3. Streams all pixels row by row, asserting `tuser[0]` on the first pixel, `tlast` on the last pixel of each row, and handling `tready` backpressure

### Timeout Watchdog
```verilog
localparam END_TIME = (SCALER_HEIGHT * SCALER_WIDTH < TPG_WIDTH * TPG_HEIGHT)
                      ? TPG_WIDTH * TPG_HEIGHT * 100
                      : SCALER_HEIGHT * SCALER_WIDTH * 100;
initial begin
    #(END_TIME);
    $display("Error: Simulation Timeout!");
    $finish;
end
```
The watchdog scales with the larger of the input or output frame size. If the simulation hangs (e.g., a `waitrequest` never clears), it prints diagnostic info and terminates.

---

## 10. RTL File Roles

| File | What It Does |
|------|-------------|
| `tb.v` | Top-level testbench — drives clock/reset, includes config, instantiates DUT and make_file, runs stimulus, has watchdog |
| `top.v` | DUT wrapper — instantiates `pipeline` (Qsys system), runs the Avalon-MM configuration FSM, gates the TPG→DIL data path |
| `pipeline.v` | Auto-generated by Platform Designer — wires all Intel VVP IP cores together, exposes all AXI4-S and Avalon-MM ports |
| `make_file.v` | Parametric AXI4-Stream sink — instantiates `frame_controller`, opens a hex output file, writes one complete frame worth of pixels |
| `controller.v` | (`frame_controller`) — tracks pixel/line counts, detects SOF via `tuser[0]`, asserts `write_flag` only for valid in-bounds pixels of the **first** frame, signals `frame_done` at end-of-frame |

### How `make_file.v` Works
- `IS_FULL=1`: receives AXI4-Stream Full (has sideband metadata) — used on the TPG tap to write `tpg_data.txt`
- `IS_FULL=0`: receives AXI4-Stream Lite — used on the Scaler tap to write `sc_data.txt`
- Only the **first complete frame** is written; subsequent frames are ignored
- The `frame_controller` internally counts pixels per line and lines per frame, using `tuser[0]` to detect the start of each frame

---

## 11. The GUI Application

Located in `Integrated_design/app/`, the GUI provides a one-click workflow.

### Files

| File | Role |
|------|------|
| `image_viewer.py` | Main GTK3 GUI — parameter sidebar + image viewer + pipeline trigger |
| `runProject.py` | Generates a QuestaSim `.do` script with relative paths, then runs `vsim -c` in batch mode |
| `hex_to_png.py` | Reads `pipeline_config.txt` for scaler output dimensions, parses `sc_data.txt` (24-bit U-Y-V hex pixels), converts to `result.png` using OpenCV |
| `png_to_hex.py` | Converts an input PNG to the hex format expected by the simulation image player (for `INPUT_SEL=1`) |
| `configuration.vh` | **Auto-generated** by GUI — Verilog parameter definitions included by `tb.v` |
| `pipeline_config.txt` | **Auto-generated** by GUI — human-readable key=value config read by `hex_to_png.py` |

### Workflow

```
User sets parameters in sidebar
         │
         ▼
  Click "Apply Settings"
         │
         ├─► Writes configuration.vh    (Verilog `parameter` definitions)
         ├─► Writes pipeline_config.txt (Python-readable key=value)
         ├─► Calls runProject.py        (generates .do script, runs vsim -c)
         │         │
         │         └─► QuestaSim compiles and simulates → writes sc_data.txt
         │
         └─► Calls hex_to_png.py       (parses sc_data.txt → result.png)
                   │
                   └─► GUI displays result.png + updates status to "IMAGE READY"
```

### To Launch

```bash
cd Integrated_design/app
python3 image_viewer.py
```

---

## 12. Simulation Output Files

| File | Written By | Contents |
|------|-----------|---------|
| `app/tpg_data.txt` | `make_file` (IS_FULL=1, TPG tap) | Raw TPG pixel hex — one complete frame at source resolution |
| `app/sc_data.txt` | `make_file` (IS_FULL=0, Scaler tap) | Raw Scaler pixel hex — one complete frame, 24-bit U-Y-V per pixel |
| `app/result.png` | `hex_to_png.py` | Final RGB image reconstructed from scaler output |

The pixel format in `sc_data.txt` is **U-Y-V** (not the more common Y-Cb-Cr ordering). `hex_to_png.py` handles the channel reordering when constructing the PNG.

---

## 13. Independent IP Testbenches

Each IP under `IPs/` has a self-contained testbench for validation before integration.

### Clipper (`clipper_axisfull_reconfigurable/`)
- TPG → Clipper → output monitor
- Default: 4-pixel crop on all four sides
- Validates SOF/EOL framing in the cropped output
- Uses Avalon-MM with commit register at `0x51`

### Deinterlacer (`deinterlacer_axisfull_rgb_only/`)
- Fixed 20×10 input (Width×Height), RGB only
- Output captured to `video_dump.hex`
- Validates per-line pixel counts match expected progressive output dimensions

### Resampler II — Avalon-ST (`resampler_II_avalon_fixed/`)
- Uses Avalon-ST (not AXI4-S) interface
- 32-bit input → 48-bit output
- Compares resampler output against expected reference values

### Resampler II — AXI4-S (`resampler_axisfull_1ppc_fixed/`)
- AXI4-Stream Full, 1 pixel per clock, YUV 4:2:2 → 4:4:4
- FIFO-based checker decouples itself from pipeline latency
- Python script `create_image.py` reconstructs a PPM image from simulation output

### Scaler (`scaler_axislite_reconfigurable/`)
- Lite mode, reconfigurable output resolution
- Programmed at runtime via Avalon-MM (input W/H, output W/H)
- `vid_checker` verifies output dimensions match programmed values

---

## 14. Register Map Quick Reference

All addresses are **word addresses** (multiply by 4 for byte address).

### TPG Registers

| Word Addr | Name | Description |
|-----------|------|-------------|
| `0x48` | IMG_INFO_WIDTH | Input pixels per line |
| `0x49` | IMG_INFO_HEIGHT | Input lines per frame |
| `0x4A` | IMG_INFO_INTERLACE | Interlace mode (0=interlaced) |
| `0x50` | STATUS | bit[1]: 1=busy, 0=ready |
| `0x52` | CONTROL | bit[0]: 0=disable, 1=enable |
| `0x53` | COMMIT | Write 1 to apply settings |
| `0x54` | PATTERN | Pattern type (0=color bars) |
| `0x5A` | BAR_SEL | Color bar selector |

### Clipper Registers

| Word Addr | Name | Description |
|-----------|------|-------------|
| `0x48` | IMG_INFO_WIDTH | Input frame width |
| `0x49` | IMG_INFO_HEIGHT | Input frame height |
| `0x4C` | IMG_INFO_COLOR_SPC | Color space (1=YUV) |
| `0x4D` | IMG_INFO_CHROMA_SUB | Chroma subsampling (3=4:4:4) |
| `0x51` | COMMIT | Write 1 to apply crop settings |
| `0x52` | LEFT_OFFSET | Pixels to crop from left |
| `0x53` | TOP_OFFSET | Lines to crop from top |
| `0x54` | RIGHT_OFFSET | Pixels to crop from right |
| `0x55` | BOTTOM_OFFSET | Lines to crop from bottom |

### Scaler Registers

| Word Addr | Name | Description |
|-----------|------|-------------|
| `0x48` | IMG_INFO_WIDTH | Input width (= clipped width) |
| `0x49` | IMG_INFO_HEIGHT | Input height (= clipped height) |
| `0x52` | OUTPUT_WIDTH | Target output pixels per line |
| `0x53` | OUTPUT_HEIGHT | Target output lines per frame |

### CRS (Resampler) Registers

| Word Addr | Name | Description |
|-----------|------|-------------|
| `0x51` | COMMIT | Write 1 to apply |
| `0x52` | OUTPUT_MODE | 2=YUV 4:2:2, 3=YUV 4:4:4 |

### CSC Registers

| Word Addr | Name | Description |
|-----------|------|-------------|
| `0x50` | STATUS | bit[1]: 1=pending, 0=applied |
| `0x51` | COMMIT | Write 0xFFFFFFFF to apply |
| `0x52`–`0x54` | COEFF_A0–A2 | Row 0 of 3×3 matrix |
| `0x55`–`0x57` | COEFF_B0–B2 | Row 1 of 3×3 matrix |
| `0x58`–`0x5A` | COEFF_C0–C2 | Row 2 of 3×3 matrix |
| `0x5B`–`0x5D` | SUMMAND_S0–S2 | Per-channel offsets |
| `0x5E` | OUT_CS | Output color space declaration |

---

## 15. Common Gotchas & Design Decisions

### Waitrequest Handling
The most critical Avalon-MM rule: **addr/data must be stable whenever `waitrequest=1`**, not just when you're actively writing. The FSM uses a "pre-load" pattern — the next transaction's address and data are loaded into registers at the same clock edge where the current transaction is accepted. This guarantees stability.

### Why Is the TPG→DIL Connection External?
Platform Designer would normally auto-connect IPs in a pipeline. Here, the TPG↔DIL connection is deliberately brought out to `top.v` so the FSM can gate the data path (`& ready_to_start`). Without this gate, the DIL could receive data before the downstream IPs (Clipper, Scaler, CSC) are configured, causing frame corruption or lockup.

### CSC Polling
The CSC doesn't apply new coefficients instantly — it waits for a frame boundary (the next SOF) to switch. If you write new coefficients and immediately send data, you'll get one corrupted frame with mixed old/new coefficients. The `ST_POLL_CSC` state solves this by waiting until the STATUS register confirms the new coefficients are active.

### INPUT_SEL Modes
- `INPUT_SEL=0`: TPG as source (default). Good for testing with synthetic patterns.
- `INPUT_SEL=1`: PNG image as source. `png_to_hex.py` converts the PNG to `image_data.txt`, which the testbench reads and streams via PC1.

### Timeout Watchdog Scaling
The timeout is proportional to `max(input pixels, output pixels) × 100`. This handles cases where upscaling or downscaling would otherwise need different timeouts. It's a rough estimate but sufficient for simulation.

### Pixel Format in Output
`sc_data.txt` stores pixels in **U-Y-V** order (not Y-U-V). This matches how the Intel VVP Scaler orders channels internally. `hex_to_png.py` accounts for this when reconstructing the image using OpenCV's BGR channel ordering.

---

*Generated from source: `top.v`, `tb.v`, project documentation, and IP User Guide.*
