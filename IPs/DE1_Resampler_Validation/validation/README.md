# Chroma Resampler Validation

A self-checking hardware harness that validates the Altera **Video & Image Processing (VIP) Chroma Resampler** MegaCore in simulation and on-device. A Test Pattern Generator (TPG) feeds colour-bar video through the resampler; an RTL **checker** reconstructs the expected output from the input stream and compares it against the resampler's actual output, driving a single **status LED**.

- **Device:** Cyclone II `EP2C20F484C7`
- **Tools:** Quartus II 13.0sp1 (Web Edition), QuestaSim 2021.2
- **Top level (synthesis):** `resampling_checker`
- **Format under test:** YCbCr, 8 bits/sample, **sequential** (1 symbol/beat), 1920×1080, colour bars
- **Conversions supported (two, build-time selectable):**
  - **4:4:4 → 4:4:4** pass-through — `CONV_444_TO_444` (**currently active**, matches Platform Designer `IN=444 / OUT=444`)
  - **4:4:4 → 4:2:0** (nearest-neighbour, cosited H+V) — `CONV_444_TO_420`

  The active conversion is chosen by a **single one-line edit** of `CRS_CONV_MODE` in
  [system/synthesis/config.vh](system/synthesis/config.vh) — the single source of truth that
  the checker reads as its `CONV_MODE` default. **It must match the Chroma Resampler IP format
  in Platform Designer** (`system.qsys`); switching modes therefore also requires regenerating
  the IP for the new `IN`/`OUT` format.

The per-config expected-output **layout** lives in [system/synthesis/expected_group_model.v](system/synthesis/expected_group_model.v); the checker forks its input parser and output assembler on `CONV_MODE` and shares the alignment FIFO, compare and resync. To add a conversion: add a `CONV_*` code + group layout there and the matching parser/assembler branches in the checker.

**4:4:4 → 4:4:4 specifics:** pure pass-through. Per pixel-pair the checker builds the expected
group `{Cb0, Y0, Cr0, Y1}` and the output assembler reads the CRS stream in the same
`Cb, Y0, Cr, Y1` phase order, so expected == actual symbol-for-symbol.

**4:2:0 specifics (confirmed in simulation):** the CRS YUV420 output is **2 bytes per pixel** —
even pixel `[Y, Cb]`, odd pixel `[Y, Cr]` — giving a 4-byte group per pixel-pair `{Y0, Cb0, Y1, Cr0}`.
Both Cb and Cr appear in every line (horizontal 2:1 subsampling only, chroma taken from the even
pixel). **Assumption** — with the current grayscale TPG (chroma uniformly `0x80`) the cosited
vertical sourcing cannot be discriminated by the checker; it rests on the documented model until
run with a chroma-varying pattern.

---

## Repository layout

| Path | Purpose |
|------|---------|
| [system/synthesis/config.vh](system/synthesis/config.vh) | **Conversion selector** (`CRS_CONV_MODE`): single-source-of-truth one-line switch between the two configs |
| [system/synthesis/resampling_checker.v](system/synthesis/resampling_checker.v) | Top-level checker: loopback, per-`CONV_MODE` parser/assembler forks, FIFO, status LED |
| [system/synthesis/expected_group_model.v](system/synthesis/expected_group_model.v) | Combinational expected-output group **layout** per `CONV_MODE` |
| [system/synthesis/system.v](system/synthesis/system.v) | Qsys-generated system: TPG + Chroma Resampler + reset controller |
| [system/synthesis/testbench.v](system/synthesis/testbench.v) | Clock/monitor testbench; reports PASS/FAIL on `status_led` |
| [system/synthesis/submodules/](system/synthesis/submodules/) | Encrypted VIP cores (`*.vo`, OpenCore Plus, time-limited) |
| [system/simulation/mentor/msim_setup.tcl](system/simulation/mentor/msim_setup.tcl) | Qsys-generated QuestaSim library/compile setup (auto-regenerated) |
| [system/simulation/mentor/run_checker.do](system/simulation/mentor/run_checker.do) | One-shot build+run wrapper (safe from Qsys regeneration) |
| [resampling.qsf](resampling.qsf) | Quartus project settings, pin assignments |

**Pin assignments:** `clk_clk → PIN_L1`, `status_led → PIN_R20`.

---

## Block diagram — `resampling_checker`

Exporting both the TPG `dout` and CRS `din` interfaces in Qsys removes the internal
TPG→CRS link, so the checker closes that loop in RTL and taps both ends. The input
parser, output assembler, FIFO depth and expected-group layout all fork on `CONV_MODE`;
the diagram below shows the symbol grouping for each of the two configs.

```
                         resampling_checker
  ┌──────────────────────────────────────────────────────────────────────────┐
  │                                                                            │
  │   ┌──────────────┐  POR (32 clk)                                           │
  │   │ power-on rst │──────────────┐                                          │
  │   └──────────────┘              │ reset_reset_n                            │
  │                                 v                                          │
  │                       ┌───────────────────────  system (dut)  ──────────┐ │
  │                       │                                                  │ │
  │                       │   ┌────────┐   TPG dout      ┌────────────────┐  │ │
  │   clk_clk ───────────────▶│  TPG   │── (4:4:4) ─────▶│ Chroma Resampler│  │ │
  │                       │   │ 4:4:4  │   8b/symbol  ┌─▶│ 444→444 (active)│  │ │
  │                       │   └────────┘              │  │   or 444→4:2:0  │  │ │
  │                       │       │  loopback (RTL):   │  └───────┬────────┘  │ │
  │                       │       │  TPG dout ─────────┘          │ CRS dout  │ │
  │                       │       │  drives CRS din               │ 8b/symbol │ │
  │                       └───────┼───────────────────────────────┼──────────┘ │
  │                  tap: tpg_*   │                                │ tap: crs_* │
  │                               v                                v            │
  │             ┌───────────────────────────┐      ┌───────────────────────────┐
  │             │  INPUT 4:4:4 parser        │      │  OUTPUT assembler          │
  │             │  mod-6 pixel-pair counter  │      │  (per CONV_MODE):          │
  │             │  per CONV_MODE:            │      │  444: Cb,Y0,Cr,Y1          │
  │             │   444: exp {Cb0,Y0,Cr0,Y1} │      │   -> act {Cb0,Y0,Cr0,Y1}   │
  │             │   420: exp {Y0,Cb0,Y1,Cr0} │      │  420: Y0,Cb0,Y1,Cr0        │
  │             │                            │      │   -> act {Y0,Cb0,Y1,Cr0}   │
  │             └─────────────┬─────────────┘      └─────────────┬─────────────┘
  │                   push    │ expected groups                  │ actual groups
  │                           v                                  │
  │                 ┌───────────────────┐                        │
  │                 │  alignment FIFO    │  pop (per output group)│
  │                 │  256×32 (444)      │───────────┐            │
  │                 │  2048×32 (420)     │           │            │
  │                 │  (absorbs latency) │           v            v
  │                 └───────────────────┘     ┌───────────────────────┐
  │                                            │  compare  exp == act   │
  │                                            └───────────┬───────────┘
  │                                                        │ match / mismatch
  │                                                        v
  │                                       ┌────────────────────────────────┐
  │                                       │  status + phase auto-resync     │
  │                                       │  • sustained mismatch -> rotate │
  │                                       │    input framing by 1 symbol    │
  │                                       │  • re-lock on sustained match   │
  │                                       │  • genuine fault -> latch error │
  │                                       └────────────────┬───────────────┘
  │                                                        v                  │
  │                                                  status_led               │
  └──────────────────────────────────────────────────────────────────────────┘
        status_led = 1  ⇒  resampler output matches the model (good)
        status_led = 0  ⇒  a fault was latched (no input framing matched)
```

---

## How the checker works

1. **Loopback.** TPG `dout` is wired into CRS `din` in RTL (the link Qsys drops once
   both interfaces are exported). Both the TPG output and CRS output are tapped.

2. **Input model (4:4:4).** A mod-6 pixel-pair counter parses the sequential input
   symbols (TPG order `Cb, Y, Cr` per pixel) and builds the expected group per `CONV_MODE`:
   - **444 pass-through:** `{Cb0, Y0, Cr0, Y1}` — symbols forwarded unchanged.
   - **4:2:0:** `{Y0, Cb0, Y1, Cr0}` — luma preserved, chroma decimated to the even
     (cosited) pixel; all four symbols registered before the FIFO write.

3. **Output assembler.** A 4-phase counter reassembles the CRS output symbols into the
   actual group, matching the input model's field order for the active config
   (444: `Cb,Y0,Cr,Y1`; 420: `Y0,Cb0,Y1,Cr0`).

4. **Latency alignment.** Expected groups are queued in a 32-bit FIFO (256-deep in 444
   mode, 2048-deep in 420 mode to cover the extra registered-group latency) and dequeued
   one-per-output-group, so the comparison is pixel-aligned regardless of the
   resampler's pipeline latency or stream back-pressure.

5. **Status + phase auto-resync.** On a sustained mismatch the controller rotates the
   input framing by one symbol (toggle/ack handshake, no FIFO flush) until it re-locks.
   This absorbs a rare gate-level co-simulation handshake slip that occurs at content
   transitions. Only a genuine fault — where **no** framing locks after cycling all
   rotations — latches `err_latched` and drives `status_led` low.

Avalon-ST Video control packets (type nibble `0xF`) and the data-packet type header
(`0x0`) are excluded from the comparison; only real pixel symbols are modelled.

---

## Simulation (QuestaSim)

From `system/simulation/mentor/`:

```tcl
do run_checker.do
```

This compiles the Altera libraries, the VIP cores, `system`, the checker, and the
testbench, then elaborates and runs to completion. Expected result:

```
PASS: status_led held high for 9990 cycles.
```

> **Note — `-novopt`:** Qsys writes `elab_debug` with `-novopt`, which QuestaSim 2021.2
> rejects as a fatal error ("Error loading design"). `run_checker.do` and the patched
> `msim_setup.tcl` use `-voptargs=+acc` instead. Qsys **overwrites `msim_setup.tcl` on
> every HDL regeneration**, so re-apply that one-line change (or just use `run_checker.do`
> / the plain `ld`/`elab` aliases) after regenerating.

---

## Synthesis / programming (Quartus)

Full compile of `resampling_checker`. Notes:

- The Chroma Resampler is an **OpenCore Plus** time-limited core: an unlicensed build
  produces a tethered `.sof` that stops after ~1 hour. The **EDA Netlist Writer is
  disabled** (`EDA_SIMULATION_TOOL = <None>`) because it cannot emit the encrypted core.
- The checker's expected-value FIFO infers a 256×32 dual-port RAM (`altsyncram`).

---

## Reconfiguring the conversion

Two conversions are built in and selected at build time. Switching between them takes two
coordinated steps — the RTL only models what the IP actually does, so the two **must** agree:

1. **RTL side — one line.** Set `CRS_CONV_MODE` in [system/synthesis/config.vh](system/synthesis/config.vh):

   ```verilog
   `define CRS_CONV_MODE `CONV_444_TO_444   // 4:4:4 -> 4:4:4 pass-through (active)
   // `define CRS_CONV_MODE `CONV_444_TO_420   // 4:4:4 -> 4:2:0
   ```

   This forwards to the checker's `CONV_MODE` parameter, which forks the input parser,
   output assembler, FIFO depth and `expected_group_model` layout to match.

2. **IP side — Platform Designer.** Set the Chroma Resampler `IN`/`OUT` format in
   `system.qsys` to the matching direction (e.g. `IN=444 / OUT=444` for pass-through,
   `IN=444 / OUT=420` for 4:2:0) and regenerate. This rewrites `system.v` and the `.vo`
   cores. (Qsys also overwrites `msim_setup.tcl` — re-apply the `-voptargs=+acc` note above.)

**Adding a third conversion** (or changing the more fundamental format/direction, e.g.
parallel↔sequential): add a `CONV_*` code in `config.vh`, a group layout in
`expected_group_model.v`, and the matching parser/assembler branches in
`resampling_checker.v` — then verify the symbol order by sampling the streams at clock
edges in simulation.
