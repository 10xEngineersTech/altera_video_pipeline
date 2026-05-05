# Intel VVP Scaler Validation

This repository contains the simulation environment for validating the Intel VVP Scaler IP in **Lite Mode** for AXIS and scaled down architecture.


	 					  		  TPG -> Scaler 
	 										|
	 										v
		Scaled down size to check ->   Scaler Checker -> Status O/P

## 1. How the Scaler Is Configured

The Scaler IP is configured at runtime by the testbench using Avalon-MM (AVMM) register writes. Since the IP is in **Lite Mode**, changes take effect immediately without needing a commit register write.

After reset is released, `testbench.v` performs the following writes (word-addressed):

| Word Addr | Register Name      | Description                        |
|-----------|--------------------|------------------------------------|
| `0x48`    | `IMG_INFO_WIDTH`   | Input pixels per line (from TPG)   |
| `0x49`    | `IMG_INFO_HEIGHT`  | Input lines per frame (from TPG)   |
| `0x52`    | `OUTPUT_WIDTH`     | Target output pixels per line      |
| `0x53`    | `OUTPUT_HEIGHT`    | Target output lines per frame      |

The testbench also passes the `exp_width` and `exp_height` directly to the checker to verify the hardware's output against these settings.

IMG_INFO_WIDTH and IMG_INFO_HEIGHT are fixed 20x10 from (TPG in) platform design but they need to be programmed for scaler.
OUTPUT_WIDTH and OUTPUT_HEIGHT are user selectable using testbench.

## 2. File Descriptions

*   **`testbench.v`**: The top-level simulation environment.
    *   Generates the 50 MHz clock and system reset.
    *   Defines the source of truth for scaling dimensions via `localparam`.
    *   Configures the Scaler IP registers via the Avalon-MM interface.
    *   Monitors `check_pass` and `check_fail` signals to determine simulation success.
*   **`top.v`**: The Design Under Test (DUT) wrapper.
    *   Instantiates `system.qsys` (which contains the Test Pattern Generator and the Scaler IP).
    *   Instantiates `vid_checker.v` to monitor the scaler's output.
    *   Exposes AVMM and status ports to the testbench.
*   **`vid_checker.v`**: The video verification monitor.
    *   Watches the AXI4-Stream interface (CCD protocol) coming out of the Scaler.
    *   Counts pixels per line (`tlast`) and lines per frame (`tuser[0]`).
    *   Compares real-time counts against `exp_width` and `exp_height`.
    *   Pulses `check_pass` on successful frame completion and latches `check_fail` on any mismatch.
