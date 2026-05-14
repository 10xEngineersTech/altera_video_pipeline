# Resampling Checker (`resampling_checker.v`)

This module serves as the primary validation testbench component for the Intel VVP Chroma Resampler II IP. It monitors the AXI4-Stream Video output of the Test Pattern Generator (TPG) and the output of the Resampler, verifying that the 4:2:2 to 4:4:4 chroma upsampling is performed correctly.

## Architecture & Algorithm

The checker is designed to operate on a **1 pixel per clock (1ppc)** streaming interface. 

### Data Formatting
In a 1ppc AXI4-Stream Video configuration:
- **4:2:2 Input (TPG)**: Chroma components alternate. 
  - **Even Pixels** (Cycle 0): Data contains `{Y, U (Cb)}`
  - **Odd Pixels** (Cycle 1): Data contains `{Y, V (Cr)}`
- **4:4:4 Output (Resampler)**: Every pixel contains all three components: `{V, Y, U}`.

### Reference Model Synthesis
Because the Resampler converts alternating chroma to full chroma, it must buffer the `U` component from the even pixel and use it for both the even and odd pixel outputs. Similarly, the `V` component from the odd pixel is used for both the even and odd pixel outputs.

The `resampling_checker` mimics this behavior natively:
1. When an **even** pixel arrives (determined by `tuser[0]` Start-Of-Frame or internal parity tracking), the checker saves the `U` and `Y` components.
2. When the subsequent **odd** pixel arrives, the checker now has all the necessary information (`U0`, `Y0` from the first cycle, and `V0`, `Y1` from the current cycle).
3. It immediately generates **two** expected 4:4:4 pixels (`{V0, Y0, U0}` and `{V0, Y1, U0}`) and pushes both into a synchronous expected data FIFO.

### FIFO-Based Synchronization
A major advantage of this checker over a static delay-line approach is the use of a deep **Synchronous FIFO**.

The Resampler IP inherently has pipeline latency. Furthermore, the latency can change depending on configuration parameters, or there could be unpredictable stalls in the AXI4-Stream.
- By pushing expected pixels into a FIFO the moment the TPG generates the reference data, the checker completely decouples itself from the Resampler's internal latency.
- When the Resampler outputs a valid pixel (`crs_out_tvalid`), the checker simply pops the next expected pixel from the FIFO and compares them.

### Control Packet Filtering
Intel VVP streams use `tuser[1]` to differentiate between Video Data Packets and Control Packets. 
The checker actively monitors `tuser[1]` and ignores control packets. This prevents control packets from desynchronizing the checker's even/odd pixel parity logic.

## Signals & Interface

| Signal Name | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_clk` | Input | 1 | Simulation Clock |
| `reset_reset` | Input | 1 | Active-high synchronous reset |
| `crs_out_tdata` | Input | 24 | 4:4:4 Video Output from Resampler (`{V, Y, U}`) |
| `crs_out_tvalid` | Input | 1 | Valid signal from Resampler |
| `crs_out_tuser` | Input | 3 | User signals from Resampler (`[0]` SOF, `[1]` Ctrl, `[2]` forced to 0) |
| `tpg_out_tdata` | Input | 24 | 4:2:2 Video Output from TPG (`{C, Y}`) |
| `tpg_out_tvalid` | Input | 1 | Valid signal from TPG |
| `tpg_out_tuser` | Input | 3 | User signals from TPG (`[0]` SOF, `[1]` Ctrl, `[2]` forced to 0) |
| `status_led` | Output | 1 | Goes HIGH when >10 pixels have successfully matched without errors. |

## Error Logging

If a mismatch occurs between the expected reference and the actual Resampler output, the checker asserts its internal `error_flag` which keeps the `status_led` LOW. It will also print a descriptive error message to the simulator console:
`Time [t]: Mismatch! Expected [exp_hex], Got [act_hex]`

Additionally, if the Resampler outputs a valid pixel but the internal expected FIFO is empty (indicating the Resampler generated garbage data without being fed), a specific FIFO underrun error is printed.
