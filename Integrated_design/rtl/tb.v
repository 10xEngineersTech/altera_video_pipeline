`timescale 1 ns / 1 ps

// =============================================================================
// tb.v - Universal Testbench
//
// out_tready=1 set immediately after reset so pipeline drains freely
// during ST_POLL_CSC (prevents CSC deadlock in packaged design).
//
// frame_controller now auto-resets on every SOF so no cap_reset needed.
// First SOF after ST_WORKING is always a clean capture.
//
// Output protocol:
//   IS_FULL=0 (Lite): FULL, SCALER_ONLY, CLIP_SCL  (have PC0)
//   IS_FULL=1 (Full): CSC_ONLY, CRS_ONLY, CRS_CSC, DIL_ONLY (no PC0)
// =============================================================================

module tb();
    `include "../app/configuration.vh"

    // =========================================================================
    // Change these per test
    // =========================================================================
    localparam TOPOLOGY    = "SCALER_ONLY";   // FULL/SCALER_ONLY/CSC_ONLY/CRS_ONLY/CRS_CSC/CLIP_SCL/DIL_ONLY

    // =========================================================================
    // Geometry from configuration.vh
    // =========================================================================
    localparam IMG_WIDTH    = TPG_WIDTH;
    localparam IMG_HEIGHT   = TPG_HEIGHT;
    localparam IMG_L_OFF    = CLIPPER_LEFT;
    localparam IMG_T_OFF    = CLIPPER_TOP;
    localparam IMG_R_OFF    = CLIPPER_RIGHT;
    localparam IMG_B_OFF    = CLIPPER_BOTTOM;
    localparam SCALER_OUT_W = SCALER_WIDTH;
    localparam SCALER_OUT_H = SCALER_HEIGHT;

    // =========================================================================
    // Topology-derived constants
    // =========================================================================
    localparam HAS_SCL = (TOPOLOGY=="FULL"||TOPOLOGY=="SCALER_ONLY"||TOPOLOGY=="CLIP_SCL") ? 1 : 0;
    localparam HAS_PC0 = HAS_SCL;

    localparam CAP_W   = HAS_SCL ? SCALER_OUT_W : IMG_WIDTH;
    localparam CAP_H   = HAS_SCL ? SCALER_OUT_H : IMG_HEIGHT;
    localparam IS_FULL = HAS_PC0 ? 0 : 1;

    localparam [63:0] END_TIME = (CAP_H * CAP_W > TPG_WIDTH * TPG_HEIGHT) ?
                                  CAP_H * CAP_W * 500 :
                                  TPG_WIDTH * TPG_HEIGHT * 500;

    localparam CLK_PERIOD = 10;

    // =========================================================================
    // Signals
    // =========================================================================
    reg clk   = 0;
    reg reset = 1;
    always #(CLK_PERIOD/2) clk = ~clk;

    wire [23:0] out_tdata;
    wire        out_tvalid;
    reg         out_tready = 0;
    wire        out_tlast;
    wire [2:0]  out_tuser;
    wire        frame_done;

    reg  [23:0] pc1_in_tdata  = 24'h0;
    reg         pc1_in_tvalid = 1'b0;
    wire        pc1_in_tready;
    reg         pc1_in_tlast  = 1'b0;
    reg  [2:0]  pc1_in_tuser  = 3'b000;

    // =========================================================================
    // Output capture
    // frame_controller auto-resets on every SOF so no special gating needed.
    // It will capture whichever complete frame arrives first after ST_WORKING.
    // =========================================================================
    make_file #(
        .IMG_H    (CAP_H),
        .IMG_W    (CAP_W),
        .IS_FULL  (IS_FULL),
        //.FILE_NAME("../../../../app/crs_yuv422.txt")
        .FILE_NAME("../../../../app/sc_data.txt")
    ) scaler_out (
        .clk       (clk),
        .reset     (reset),
        .tdata     (out_tdata),
        .tvalid    (out_tvalid),
        .tready    (out_tready & (dut.current_state == dut.ST_WORKING)),
        .tlast     (out_tlast),
        .tuser     (out_tuser),
        .frame_done(frame_done)
    );
	 

    // =========================================================================
    // DUT
    // =========================================================================
    top #(
        .TOPOLOGY    (TOPOLOGY),
        .INPUT_SEL   (INPUT_SEL),
        .IMG_WIDTH   (IMG_WIDTH),
        .IMG_HEIGHT  (IMG_HEIGHT),
        .IMG_L_OFF   (IMG_L_OFF),
        .IMG_T_OFF   (IMG_T_OFF),
        .IMG_R_OFF   (IMG_R_OFF),
        .IMG_B_OFF   (IMG_B_OFF),
        .SCALER_OUT_W(SCALER_OUT_W),
        .SCALER_OUT_H(SCALER_OUT_H),
        .TPG_MODE    (TPG_COLORSPACE),
        .VID_PLANES  (VID_PLANES)
    ) dut (
        .clk          (clk),
        .reset        (reset),
        .out_tdata    (out_tdata),
        .out_tvalid   (out_tvalid),
        .out_tready   (out_tready),
        .out_tlast    (out_tlast),
        .out_tuser    (out_tuser),
        .pc1_in_tdata (pc1_in_tdata),
        .pc1_in_tvalid(pc1_in_tvalid),
        .pc1_in_tready(pc1_in_tready),
        .pc1_in_tlast (pc1_in_tlast),
        .pc1_in_tuser (pc1_in_tuser)
    );

    // =========================================================================
    // Stimulus
    // =========================================================================
    initial begin
        reset      = 1;
        out_tready = 0;
        repeat(10) @(posedge clk);
        reset = 0;
        $display("[%0t] Reset released.", $time);

        // Set out_tready=1 immediately after reset.
        // CRITICAL for CSC modes: pipeline must drain during ST_POLL_CSC.
        @(posedge clk);
        out_tready = 1;

        // Wait for FSM to complete configuration (includes CSC poll for TPG)
        wait(dut.current_state == dut.ST_WORKING);
        $display("[%0t] ST_WORKING - pipeline configured.", $time);


        // Wait for first clean SOF after ST_WORKING.
        // frame_controller auto-resets on this SOF and captures the frame.
        wait(out_tvalid && out_tuser[0]);
        $display("[%0t] SOF detected - capturing frame.", $time);

        wait(frame_done);
        $display("[%0t] Frame written to sc_data.txt.", $time);
        $finish;
    end

    // =========================================================================
    // Image player (INPUT_SEL=1 only)
    // =========================================================================
    generate
        if (INPUT_SEL == 1'b1) begin : gen_img
            reg [23:0] img_mem [0 : TPG_WIDTH * TPG_HEIGHT - 1];
            integer px, py;

            initial begin
                $readmemh("../../../../app/image_data.txt", img_mem);
                $display("[IMG] Loaded %0dx%0d image.", TPG_WIDTH, TPG_HEIGHT);

                wait(dut.current_state == dut.ST_WORKING);
                repeat(5) @(posedge clk);

                $display("[IMG] Sending image...");
                @(posedge clk); #1;

                for (py = 0; py < TPG_HEIGHT; py = py + 1) begin
                    for (px = 0; px < TPG_WIDTH; px = px + 1) begin
                        pc1_in_tdata  = img_mem[py * TPG_WIDTH + px];
                        pc1_in_tvalid = 1'b1;
                        pc1_in_tuser  = (px==0 && py==0) ? 3'b001 : 3'b000;
                        pc1_in_tlast  = (px==TPG_WIDTH-1) ? 1'b1 : 1'b0;

                        @(posedge clk);
                        while (!pc1_in_tready) @(posedge clk);
                        #1;
                    end
                end

                pc1_in_tvalid = 1'b0;
                pc1_in_tlast  = 1'b0;
                pc1_in_tuser  = 3'b000;
                $display("[IMG] Image sent.");
            end
        end
    endgenerate

    // =========================================================================
    // State trace
    // =========================================================================
    reg [4:0] last_state = 5'h1F;
    always @(posedge clk) begin
        if (!reset && dut.current_state !== last_state) begin
            $display("[%0t] STATE %0d->%0d cfg_step=%0d",
                     $time, last_state, dut.current_state, dut.cfg_step);
            last_state <= dut.current_state;
        end
    end

    // =========================================================================
    // Timeout watchdog
    // =========================================================================
    initial begin
        #(END_TIME);
        $display("ERROR: Timeout! state=%0d cfg_step=%0d bridge_wait=%b pc1_wait=%b",
                 dut.current_state, dut.cfg_step,
                 dut.bridge_wait, dut.pc1_wait);
        $finish;
    end

endmodule
