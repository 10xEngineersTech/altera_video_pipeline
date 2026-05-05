// =============================================================================
// vid_checker.v
// =============================================================================
// Monitors the Intel VVP Scaler AXI4-Stream video output and verifies that
// every output frame matches the expected scaled dimensions supplied by the
// testbench at runtime via exp_width / exp_height ports.
//
// Signal conventions (Intel VVP CCD AXI4-Stream):
//   tdata [23:0] : packed pixel data (R[7:0], G[7:0], B[7:0])
//   tvalid        : output pixel is valid
//   tready        : downstream ready (always 1 – this module never back-pressures)
//   tlast         : last pixel of the current line (End-of-Line)
//   tuser [2:0]   : tuser[0] = Start-of-Frame (SOF), first pixel of a new frame
// =============================================================================
`timescale 1ns/1ps

module vid_checker (
    input  wire        clk,
    input  wire        rst,           // Active-high synchronous reset

    // ------------------------------------------------------------
    // Expected output dimensions – driven by testbench at runtime.
    // These must match the values written to the scaler Avalon-MM
    // control registers (OUT_WIDTH / OUT_HEIGHT).
    // ------------------------------------------------------------
    input  wire [15:0] exp_width,     // Expected output pixels per line
    input  wire [15:0] exp_height,    // Expected output lines  per frame

    // ------------------------------------------------------------
    // AXI4-Stream video input (from scaler output)
    // ------------------------------------------------------------
    input  wire [23:0] vid_tdata,
    input  wire        vid_tvalid,
    output wire        vid_tready,    // Always asserted – we never back-pressure
    input  wire        vid_tlast,
    input  wire  [2:0] vid_tuser,

    // ------------------------------------------------------------
    // Status outputs
    // ------------------------------------------------------------
    output reg         check_pass,    // High if last frame passed, re-evaluated at every frame end
    output reg         check_fail,    // Latches high on any dimension error
    output reg   [7:0] frames_checked // Count of successfully verified frames
);

    // -------------------------------------------------------------------------
    // Ready only after testbench configures expected dimensions
    // -------------------------------------------------------------------------
    assign vid_tready = (exp_width != 16'd0) && (exp_height != 16'd0);


    // -------------------------------------------------------------------------
    // Handshake qualifiers
    // -------------------------------------------------------------------------
    wire accepted = vid_tvalid;               // tready is always 1
    wire sof      = accepted & vid_tuser[0];  // Start-of-Frame
    wire eol      = accepted & vid_tlast;     // End-of-Line

    // -------------------------------------------------------------------------
    // Counters
    // -------------------------------------------------------------------------
    reg [15:0] pcnt;       // Pixels accumulated on the CURRENT line so far
                           // (not counting the pixel being processed this cycle)
    reg [15:0] lcnt;       // Lines completed in the CURRENT frame
    reg        frm_active; // 1 once the first SOF has been seen

    // -------------------------------------------------------------------------
    // Main checker logic
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            pcnt           <= 16'd0;
            lcnt           <= 16'd0;
            frm_active     <= 1'b0;
            check_pass     <= 1'b0;
            check_fail     <= 1'b0;
            frames_checked <= 8'd0;
        end else begin

            if (accepted) begin

                // -------------------------------------------------------------
                // SOF: a new frame is starting
                // -------------------------------------------------------------
                if (sof) begin
                    if (frm_active) begin
                        // Verify the height of the frame that just finished
                        if (lcnt != exp_height) begin
                            $display("[CHECKER][%0t ns] FAIL: frame height = %0d, expected %0d",
                                     $time/1000, lcnt, exp_height);
                            check_pass <= 1'b0;
                            check_fail <= 1'b1;
                        end else if (!check_fail) begin
                            $display("[CHECKER][%0t ns] PASS: frame %0d verified (%0dx%0d)",
                                     $time/1000, frames_checked, exp_width, exp_height);
                            check_pass     <= 1'b1;
                            frames_checked <= frames_checked + 1'b1;
                        end else begin
                            // A previous frame already failed; keep pass low
                            check_pass <= 1'b0;
                        end
                    end
                    // Start a fresh frame
                    frm_active <= 1'b1;
                    lcnt       <= 16'd0;
                end

                // -------------------------------------------------------------
                // Pixel / line accounting (runs whenever we are inside a frame)
                // -------------------------------------------------------------
                if (frm_active || sof) begin

                    if (eol) begin
                        // Current pixel completes the line.
                        // Total pixels on this line = pcnt + 1 (this pixel),
                        // or 1 if SOF and EOL arrive on the same cycle.
                        begin : blk_eol_check
                            reg [15:0] line_width;
                            line_width = sof ? 16'd1 : (pcnt + 16'd1);
                            if (line_width != exp_width) begin
                                $display("[CHECKER][%0t ns] FAIL: line %0d width = %0d, expected %0d",
                                         $time/1000,
                                         sof ? 16'd0 : lcnt,
                                         line_width, exp_width);
                                check_pass <= 1'b0;
                                check_fail <= 1'b1;
                            end
                        end
                        // Advance line counter and reset pixel counter
                        lcnt <= (sof ? 16'd0 : lcnt) + 16'd1;
                        pcnt <= 16'd0;

                    end else begin
                        // Mid-line pixel
                        pcnt <= sof ? 16'd1        // SOF pixel starts the count at 1
                                    : pcnt + 16'd1;
                    end

                end // if (frm_active || sof)

            end // if (accepted)
        end // if (!rst)
    end

endmodule
