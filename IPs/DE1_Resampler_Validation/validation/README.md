# Chroma Resampler Validation

A self-checking hardware harness that validates the Altera **Video & Image Processing (VIP) Chroma Resampler** MegaCore in simulation and on-device. A Test Pattern Generator (TPG) feeds colour-bar video through the resampler; an RTL **checker** reconstructs the expected output from the input stream and compares it against the resampler's actual output, driving a single **status LED**.

- **Device:** Cyclone II `EP2C20F484C7`
- **Tools:** Quartus II 13.0sp1 (Web Edition), QuestaSim 2021.2
- **Top level (synthesis):** `resampling_checker`
- **Format under test:** YCbCr, 8 bits/sample, **sequential** (1 symbol/beat), 1920×1080, colour bars
- **Conversion under test:** **4:4:4 → 4:2:2** (nearest-neighbour, cosited)

---

## Repository layout

| Path | Purpose |
|------|---------|
| [system/synthesis/resampling_checker.v](system/synthesis/resampling_checker.v) | Top-level checker: loopback, expected-value model, FIFO, status LED |
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
TPG→CRS link, so the checker closes that loop in RTL and taps both ends.

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
  │                       │   │ 4:4:4  │   8b/symbol  ┌─▶│  4:4:4 → 4:2:2  │  │ │
  │                       │   └────────┘              │  └───────┬────────┘  │ │
  │                       │       │  loopback (RTL):   │          │ CRS dout  │ │
  │                       │       │  TPG dout ─────────┘          │ (4:2:2)   │ │
  │                       │       │  drives CRS din               │ 8b/symbol │ │
  │                       └───────┼───────────────────────────────┼──────────┘ │
  │                  tap: tpg_*   │                                │ tap: crs_* │
  │                               v                                v            │
  │             ┌───────────────────────────┐      ┌───────────────────────────┐
  │             │  INPUT 4:4:4 parser        │      │  OUTPUT 4:2:2 assembler    │
  │             │  mod-6 pixel-pair counter  │      │  4-phase: Cb,Y0,Cr,Y1      │
  │             │  Cb0,Cr0,Y0,Cb1,Cr1,Y1     │      │  -> act_group {Cb0,Y0,     │
  │             │  -> exp_group {Cb0,Y0,      │      │                Cr0,Y1}     │
  │             │      Cr0,Y1}               │      └─────────────┬─────────────┘
  │             └─────────────┬─────────────┘                    │
  │                   push    │ expected groups                  │ actual groups
  │                           v                                  │
  │                 ┌───────────────────┐                        │
  │                 │  alignment FIFO    │  pop (per output group)│
  │                 │  256 × 32-bit      │───────────┐            │
  │                 │  (absorbs latency) │           │            │
  │                 └───────────────────┘           v            v
  │                                            ┌───────────────────────┐
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
   symbols `Cb,Cr,Y` per pixel. For each pixel pair it builds the expected 4:2:2 group
   `{Cb0, Y0, Cr0, Y1}` — luma preserved, chroma decimated to the even (cosited) pixel.

3. **Output assembler (4:2:2).** A 4-phase counter reassembles the CRS output symbols
   `Cb,Y0,Cr,Y1` into the actual group.

4. **Latency alignment.** Expected groups are queued in a 256×32-bit FIFO and dequeued
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

The TPG and Chroma Resampler are configured in Platform Designer (Qsys). Changing the
format/direction (e.g. parallel↔sequential, or 4:2:2↔4:4:4) regenerates `system.v` and
the `.vo` cores, and changes the port widths and symbol ordering. The checker's
input/output parsers and field orders must then be updated to match the regenerated
stream (verify symbol order by sampling the streams at clock edges in simulation).
