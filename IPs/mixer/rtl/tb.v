`timescale 1 ps / 1 ps

// =============================================================================
// tb.v — Mixer demo testbench
//
// TPG0 (color bars, 64x64 base) + TPG1 (uniform red, 32x32 overlay at
// (16,16)) are mixed by intel_vvp_mixer_0. The first complete output frame
// is captured to a hex file (one 24-bit RRGGBB word per pixel) by make_file;
// app/hex_to_png.py turns that file into mixer_result.png.
// =============================================================================

module tb();

    localparam BG_WIDTH  = 64;
    localparam BG_HEIGHT = 64;
    localparam FG_WIDTH  = 32;
    localparam FG_HEIGHT = 32;
    localparam FG_H_OFF  = 16;
    localparam FG_V_OFF  = 16;

    // Written into the sim working directory (system/sim/mentor)
    localparam FILE_NAME = "../../../app/mixer_data.txt";

    localparam CLK_PERIOD = 10000;   // 100 MHz in ps

    reg clk;
    reg reset;

    wire [23:0] out_tdata;
    wire        out_tvalid;
    reg         out_tready;
    wire        out_tlast;
    wire [2:0]  out_tuser;

    wire frame_done;

    // --- Output frame capture ---
    make_file #(
        .IMG_H     (BG_HEIGHT),
        .IMG_W     (BG_WIDTH),
        .IS_FULL   (1),
        .FILE_NAME (FILE_NAME)
    ) mixer_out_capture (
        .clk        (clk),
        .reset      (reset),

        .tdata      (out_tdata),
        .tvalid     (out_tvalid),
        .tready     (out_tready),
        .tlast      (out_tlast),
        .tuser      (out_tuser),

        .frame_done (frame_done)
    );

    // --- DUT ---
    top #(
        .BG_WIDTH  (BG_WIDTH),
        .BG_HEIGHT (BG_HEIGHT),
        .FG_WIDTH  (FG_WIDTH),
        .FG_HEIGHT (FG_HEIGHT),
        .FG_H_OFF  (FG_H_OFF),
        .FG_V_OFF  (FG_V_OFF),
        .FG_R      (32'd255),
        .FG_G      (32'd0),
        .FG_B      (32'd0)
    ) dut (
        .clk        (clk),
        .reset      (reset),
        .out_tdata  (out_tdata),
        .out_tvalid (out_tvalid),
        .out_tready (out_tready),
        .out_tlast  (out_tlast),
        .out_tuser  (out_tuser)
    );

    // --- Clock ---
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // --- Stimulus ---
    initial begin
        reset      = 1;
        out_tready = 0;

        repeat (20) @(posedge clk);
        reset = 0;
        $display("[%0t] Reset de-asserted. Configuring mixer and TPGs...", $time);

        wait (dut.current_state == dut.ST_WORKING);
        $display("[%0t] Configuration complete. Mixer output streaming.", $time);

        @(posedge clk);
        out_tready = 1;

        wait (out_tvalid && out_tuser[0]);
        $display("[%0t] First Start of Frame detected at mixer output.", $time);

        wait (frame_done);
        $display("[%0t] Frame captured to %s.", $time, FILE_NAME);
        $finish;
    end

    // --- State trace (debug) ---
    reg [3:0] last_state = 4'hF;
    always @(posedge clk) begin
        if (!reset && dut.current_state !== last_state) begin
            $display("[%0t] STATE %0d -> %0d  cfg_step=%0d tpg_sel=%0d",
                     $time, last_state, dut.current_state, dut.cfg_step, dut.tpg_sel);
            last_state <= dut.current_state;
        end
    end

    // --- Timeout watchdog ---
    initial begin
        // Config + a few frames at 100 MHz; 64x64 frame ≈ 41 us
        #(2000000000);   // 2 ms
        $display("Error: Simulation timeout! current_state=%0d cfg_step=%0d",
                 dut.current_state, dut.cfg_step);
        $finish;
    end

endmodule
