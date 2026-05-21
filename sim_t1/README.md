# SCALER_ONLY Simulation — TPG 64×64 → Scaler → 128×122

## What This Is
Simulation testbench for `intel_vvp_pipeline2` packaged IP in SCALER_ONLY topology.

## Chain
```
TPG (64×64, VVP Full) → pconv (Full→AXI4S) → Scaler (AXI4S, 128×122) → output
```

## Files
| File | Purpose |
|------|---------|
| `top.v` | DUT — wires TPG to pipeline, state machine configures scaler via MM bridge |
| `testbench.v` | Drives reset, captures frame 10 to hex file |
| `vid_checker.v` | Verifies output frame dimensions |
| `hex_to_png.py` | Converts output hex to PNG image |
| `system.qsys` | Platform Designer system (TPG + intel_vvp_pipeline2_0) |

## How to Run
```bash
# In QuestaSim
cd /home/izaan/t1/system/sim/mentor
do msim_setup.tcl
vlog /home/izaan/t1/top.v
vlog /home/izaan/t1/testbench.v
vsim testbench
run -all

# Generate PNG
python3 /home/izaan/t1/hex_to_png.py
```

## Key Settings
- TPG: 64×64, RGB_444, VVP Full format
- pconv: Full→AXI4S, COLOR_SPACE=RGB
- Scaler: EXTERNAL_MODE=1, RUNTIME_CONTROL=1, MAX_IN=64, MAX_OUT=128
- MM bridge: ADDRESS_WIDTH=11, UNITS=WORDS
- State machine waits 5000 cycles after reset before writing registers (mm_reset_hold workaround)
- Captures frame 10 (scaler settles after ~8 frames)

## Current Status
- ✓ 128 pixels per line output confirmed
- ✓ 122 lines per frame output confirmed  
- ✗ Output image scrambled — horizontal pixel ordering issue under investigation
