// =============================================================================
// vid_checker.v ? adapted for intel_vvp_pipeline2 simulation
// =============================================================================
`timescale 1ns/1ps

module vid_checker (
    input  wire        clk,
    input  wire        rst,

    input  wire [15:0] exp_width,
    input  wire [15:0] exp_height,

    input  wire [23:0] vid_tdata,
    input  wire        vid_tvalid,
    output wire        vid_tready,
    input  wire        vid_tlast,
    input  wire  [2:0] vid_tuser,

    output reg         check_pass,
    output reg         check_fail,
    output reg   [7:0] frames_checked
);

    assign vid_tready = (exp_width != 16'd0) && (exp_height != 16'd0);

    wire accepted = vid_tvalid;
    wire sof      = accepted & vid_tuser[0];
    wire eol      = accepted & vid_tlast;

    reg [15:0] pcnt;
    reg [15:0] lcnt;
    reg        frm_active;

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
                if (sof) begin
                    if (frm_active) begin
                        if (lcnt != exp_height) begin
                            $display("[CHECKER][%0t ns] FAIL: height=%0d expected=%0d",
                                     $time/1000, lcnt, exp_height);
                            check_pass <= 1'b0;
                            check_fail <= 1'b1;
                        end else if (!check_fail) begin
                            $display("[CHECKER][%0t ns] PASS: frame %0d (%0dx%0d)",
                                     $time/1000, frames_checked, exp_width, exp_height);
                            check_pass     <= 1'b1;
                            frames_checked <= frames_checked + 1'b1;
                        end else begin
                            check_pass <= 1'b0;
                        end
                    end
                    frm_active <= 1'b1;
                    lcnt       <= 16'd0;
                end

                if (frm_active || sof) begin
                    if (eol) begin : blk_eol
                        reg [15:0] line_width;
                        line_width = sof ? 16'd1 : (pcnt + 16'd1);
                        if (line_width != exp_width) begin
                            $display("[CHECKER][%0t ns] FAIL: line %0d width=%0d expected=%0d",
                                     $time/1000, sof ? 16'd0 : lcnt,
                                     line_width, exp_width);
                            check_pass <= 1'b0;
                            check_fail <= 1'b1;
                        end
                        lcnt <= (sof ? 16'd0 : lcnt) + 16'd1;
                        pcnt <= 16'd0;
                    end else begin
                        pcnt <= sof ? 16'd1 : pcnt + 16'd1;
                    end
                end
            end
        end
    end
endmodule
