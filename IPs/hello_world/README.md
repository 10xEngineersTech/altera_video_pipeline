# Nios® V Video Pipeline — TPG → Scaler

A bare-metal Nios® V application that configures and runs a simple video
processing pipeline on an Intel® Agilex™ 5 FPGA:

```
┌─────────┐      ┌──────────┐
│   TPG   │ ───▶ │  Scaler  │ ───▶  exported video out
│ 0x30400 │      │ 0x30000  │
└─────────┘      └──────────┘
 Test Pattern     Resize
 Generator        (e.g. 1920×1080 → 1280×720)
```

The Test Pattern Generator (TPG) produces a video stream, the Scaler resizes
it, and the scaler output is exported from the system. Both IPs are from the
Intel **Video and Vision Processing (VVP) Suite** and are driven from C using
their generated HAL drivers.

---

## Hardware

| Item              | Value                                    |
|-------------------|------------------------------------------|
| FPGA family       | Intel Agilex 5                           |
| Device            | A5ED065BB32AE6SR0                        |
| Toolchain         | Quartus Prime 25.1.1 + Nios V / RISCFree |
| CPU               | Nios V soft processor (RISC-V, `My_NiosV`) |
| On-chip RAM (SRAM)| 128 KB @ `0x00000000`                    |

### Memory map (key components)

| Component            | Base address |
|----------------------|--------------|
| SRAM (on-chip)       | `0x00000000` |
| Nios V data master   | `0x00020000` |
| Scaler (`intel_vvp_scaler_0`) | `0x00030000` |
| TPG (`intel_vvp_tpg_0`)       | `0x00030400` |
| System timer         | `0x00030600` |
| JTAG UART (stdio)    | `0x00030640` |

> The base addresses come from `software/bsp/system.h`. The application uses
> the generated macros (`INTEL_VVP_TPG_0_BASE`, `INTEL_VVP_SCALER_0_BASE`), so
> it stays correct even if Platform Designer reassigns addresses.

---

## Repository layout

```
.
├── niosv.qpf                  # Quartus project
├── niosv.qsys                 # Platform Designer system (CPU + TPG + Scaler + ...)
├── niosv.qsf                  # Quartus settings (device, pins)
├── output_files/              # Compiled FPGA bitstream (.sof) output
└── software/
    ├── bsp/                   # Board Support Package (generated)
    │   ├── system.h           # Address map + IP parameters
    │   ├── linker.x           # Linker script (memory regions)
    │   └── drivers/mtm/       # VVP HAL drivers (tpg, scaler, core, quantizer)
    └── app/
        ├── hello.c            # Application: configures and starts the pipeline
        ├── CMakeLists.txt     # Generated build description
        └── docs/              # Reference docs (config-sequence document)
```

---

## Prerequisites

- **Quartus Prime 25.1.1** with the **Nios V** and **RISCFree IDE** components.
- The Nios V tools must be on your `PATH`. Confirm with:

  ```bash
  which niosv-stack-report elf2hex
  ```

  If these are *not* found, the build will fail with **`Error 127`** (command
  not found). Launch RISCFree from a terminal that has the tools on `PATH`, or
  add them permanently:

  ```bash
  export PATH=/path/to/Quartus/niosv/bin:$PATH
  ```

---

## Build & run

### 1. Generate the FPGA hardware

Open the system, add/connect IP, generate HDL, then compile the bitstream:

```bash
qsys-edit niosv.qsys                  # edit the system (optional)
quartus_sh --flow compile niosv.qpf   # produces output_files/niosv.sof
```

### 2. Generate the BSP

Regenerate the BSP whenever the `.qsys` system changes — this refreshes
`system.h`, the linker script, and the IP drivers:

```bash
niosv-bsp -c -t=hal -p=niosv.qpf -r=niosv -s=niosv.qsys software/bsp/settings.bsp
```

### 3. Generate the application project

Only needed when the source file list changes:

```bash
niosv-app -a=software/app -b=software/bsp -s=software/app/hello.c
```

### 4. Build in RISCFree

Import the project and run **Project → Clean → Build**. This produces:

- `app.elf` — the executable
- `SRAM.hex` — memory-initialization image for the on-chip RAM
- `app.elf.stack_report` — stack/heap space report

### 5. Run on hardware

Program `output_files/niosv.sof` to the FPGA, then download `app.elf`.
Application `printf` output appears on the **JTAG UART** terminal.

---

## What the application does

`software/app/hello.c` brings up the pipeline in two helper functions:

- **`setup_scaler()`** — initializes the scaler, sets its input size (lite mode)
  and output size, then commits. The scaler has **no start/stop**; it processes
  whatever stream arrives once configured.
- **`setup_tpg()`** — initializes the TPG, sets the frame size, selects a
  pattern (color bars), commits, and **starts** generation.

`main()` configures the **scaler first**, then starts the **TPG last**, so the
first frames flow into an already-configured scaler.

The output resolution is set by `#define`s at the top of `hello.c`:

```c
#define IN_W   1920
#define IN_H   1080
#define OUT_W  1280
#define OUT_H   720
```

A detailed, step-by-step breakdown of every API call and the registers it
reads/writes is in [`software/app/docs/`](software/app/docs/).

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error 127` on `app.elf.stack_report` / `SRAM.hex` | Nios V tools not on the IDE's `PATH` | Launch RISCFree from a shell with the tools on `PATH`, or export it (see Prerequisites) |
| Editor shows **“Unresolved inclusion”** for a driver header | CDT indexer is stale; the build itself is fine | Right-click project → **Index → Rebuild**; enable the `compile_commands.json` provider |
| Undefined `*_BASE` macro | BSP not regenerated after editing the `.qsys` | Re-run the `niosv-bsp` command (step 2) |
| Linker error: **`.bss is not within region 'SRAM'`** | Program is larger than the 128 KB on-chip RAM | Build the **Release** config (`-O2`), enable `-ffunction-sections -fdata-sections` + `-Wl,--gc-sections`, or increase the on-chip RAM size in Platform Designer |

> **Note:** `software/bsp/*` and `software/app/CMakeLists.txt` are **generated**.
> Changes there are overwritten when you regenerate the BSP/app — re-apply build-flag
> tweaks afterward, or set them in the IDE's project properties.

---

## References

- Intel Video and Vision Processing Suite User Guide
- Nios V Processor Reference / Embedded Design Handbook
- Driver sources: `software/bsp/drivers/mtm/intel_vvp_{tpg,scaler}/`
