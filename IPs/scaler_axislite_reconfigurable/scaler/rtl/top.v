// =============================================================================
// top.v  –  Design Under Test (DUT)
// =============================================================================
// Structural wrapper that connects:
//   1. Platform subsystem  – system.qsys  (TPG 20×10 driving the Scaler)
//   2. Checker             – checker.v    (monitors scaler output for 10×5)
//
// All stimulus (clock, reset, Avalon-MM writes) is driven externally by
// testbench.v.  This module has no initial blocks and no $system calls –
// it is synthesisable except for checker.v's $display statements.
//
// Port summary
// ─────────────────────────────────────────────────────────────────────────────
//  CLOCK / RESET
//    clk                  50 MHz clock
//    rst                  Active-HIGH synchronous reset
//
//  AVALON-MM CONTROL (to scaler intel_vvp_scaler_1_av_mm_control_agent)
//    avmm_addr   [6:0]    Word address (0x00-0x7F)
//    avmm_write           Write strobe
//    avmm_be     [3:0]    Byte-enable (use 4'hF for full 32-bit writes)
//    avmm_wdata  [31:0]   Write data
//    avmm_read            Read strobe
//    avmm_rdata  [31:0]   Read data  (output from scaler)
//    avmm_rdv             Read-data valid
//    avmm_wait            Wait-request (hold address/data while asserted)
//
//  CHECKER STATUS (read by testbench)
//    check_pass           Pulses high for one clock when a frame passes
//    check_fail           Latches high on first dimension mismatch
//    frames_checked [7:0] Running count of successfully verified frames
// =============================================================================
`timescale 1ns/1ps

module top (
    // ── Clock / Reset ──────────────────────────────────────────────────────
    input  wire        clk,
    input  wire        rst,

    // ── Avalon-MM Scaler Control ────────────────────────────────────────────
    input  wire  [6:0] avmm_addr,
    input  wire        avmm_write,
    input  wire  [3:0] avmm_be,
    input  wire [31:0] avmm_wdata,
    input  wire        avmm_read,
    output wire [31:0] avmm_rdata,
    output wire        avmm_rdv,       // readdatavalid
    output wire        avmm_wait,      // waitrequest

    // ── Expected Output Dimensions (from testbench, forwarded to checker) ───
    input  wire [15:0] exp_width,      // Expected scaler output pixels per line
    input  wire [15:0] exp_height,     // Expected scaler output lines  per frame

    // ── Checker Status ──────────────────────────────────────────────────────
    output wire        check_pass,
    output wire        check_fail,
    output wire  [7:0] frames_checked
);

    // =========================================================================
    // Internal wires – AXI4-Stream video between scaler and checker
    // =========================================================================
    wire [23:0] scaler_tdata;
    wire        scaler_tvalid;
    wire        scaler_tready;   // driven by checker (always 1'b1)
    wire        scaler_tlast;
    wire  [2:0] scaler_tuser;

    // =========================================================================
    // Platform subsystem: TPG (20×10) → Scaler → exported AXI4-Stream output
    // =========================================================================
    system u_system (
        // Clock & Reset
        .clk_clk                                               (clk),
        .reset_reset                                           (rst),

        // Scaler video output (exported)
        .intel_vvp_scaler_0_axi4s_vid_out_tdata               (scaler_tdata),
        .intel_vvp_scaler_0_axi4s_vid_out_tvalid              (scaler_tvalid),
        .intel_vvp_scaler_0_axi4s_vid_out_tready              (scaler_tready),
        .intel_vvp_scaler_0_axi4s_vid_out_tlast               (scaler_tlast),
        .intel_vvp_scaler_0_axi4s_vid_out_tuser               (scaler_tuser),

        // Scaler Avalon-MM control (exported)
        .intel_vvp_scaler_0_av_mm_control_agent_address       (avmm_addr),
        .intel_vvp_scaler_0_av_mm_control_agent_write         (avmm_write),
        .intel_vvp_scaler_0_av_mm_control_agent_byteenable    (avmm_be),
        .intel_vvp_scaler_0_av_mm_control_agent_writedata     (avmm_wdata),
        .intel_vvp_scaler_0_av_mm_control_agent_read          (avmm_read),
        .intel_vvp_scaler_0_av_mm_control_agent_readdata      (avmm_rdata),
        .intel_vvp_scaler_0_av_mm_control_agent_readdatavalid (avmm_rdv),
        .intel_vvp_scaler_0_av_mm_control_agent_waitrequest   (avmm_wait)
    );

    // =========================================================================
    // Checker: monitors scaler output and verifies 10×5 output dimensions
    // =========================================================================
    vid_checker u_checker (
        .clk            (clk),
        .rst            (rst),

        // Expected dimensions driven by testbench
        .exp_width      (exp_width),
        .exp_height     (exp_height),

        .vid_tdata      (scaler_tdata),
        .vid_tvalid     (scaler_tvalid),
        .vid_tready     (scaler_tready),   // checker drives this → feeds system input
        .vid_tlast      (scaler_tlast),
        .vid_tuser      (scaler_tuser),

        .check_pass     (check_pass),
        .check_fail     (check_fail),
        .frames_checked (frames_checked)
    );

endmodule
