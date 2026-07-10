`timescale 1 ns / 1 ps

module tb();
    `include "../app/configuration.vh"
    localparam IMG_WIDTH      = TPG_WIDTH;
    localparam IMG_HIGHT      = TPG_HEIGHT;
    localparam IMG_COLOR      = 32'd1;
    localparam IMG_CR_SM      = 32'd3;
    localparam IMG_L_OFF      = CLIPPER_LEFT;
    localparam IMG_T_OFF      = CLIPPER_TOP;
    localparam IMG_R_OFF      = CLIPPER_RIGHT;
    localparam IMG_B_OFF      = CLIPPER_BOTTOM;

    localparam SCALER_OUT_W   = SCALER_WIDTH;
    localparam SCALER_OUT_H   = SCALER_HEIGHT;

    // DDR4 calibration (abbreviated sim model) runs before the first frame
    // can round-trip through the EMIF, so pad the watchdog with a fixed margin.
    localparam CAL_MARGIN = 1000000; // 1 ms
    localparam END_TIME   = ((SCALER_HEIGHT * SCALER_WIDTH < TPG_WIDTH * TPG_HEIGHT) ? TPG_WIDTH * TPG_HEIGHT * 1000 : SCALER_HEIGHT * SCALER_WIDTH * 1000) + CAL_MARGIN;

    // --- Clock and Reset ---
    reg clk;
    reg emif_ref_clk;
    reg reset;

    // --- Output Monitor Signals ---
    wire [23:0] out_tdata;
    wire        out_tvalid;
    reg         out_tready;
    wire        out_tlast;
    wire [2:0]  out_tuser;

    wire frame_done;

    // --- PC1 (protocol_conv_1) image source signals ---
    // Driven by the image hex player block when INPUT_SEL=1; tied off when INPUT_SEL=0.
    reg  [23:0] pc1_in_tdata  = 24'h0;
    reg         pc1_in_tvalid = 1'b0;
    wire        pc1_in_tready;
    reg         pc1_in_tlast  = 1'b0;
    reg  [2:0]  pc1_in_tuser  = 3'b000;

    // --- Simulation Constants ---
    localparam CLK_PERIOD = 10; // 100MHz

	 make_file #(
        .IMG_H(SCALER_OUT_H),
        .IMG_W(SCALER_OUT_W),
        .IS_FULL(1),
		  .FILE_NAME("../../../../app/sc_data.txt")
    ) vfb_out_capture (
        .clk        (clk),
        .reset      (reset),

        .tdata      (out_tdata),
        .tvalid     (out_tvalid),
        .tready     (out_tready & (dut.ST_WORKING == dut.current_state)),
        .tlast      (out_tlast),
        .tuser      (out_tuser),

        .frame_done (frame_done)
    );

    // --- Instantiate the Top Module ---
    top #(
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HIGHT),
		  .IMG_COLOR(IMG_COLOR),
		  .IMG_CR_SM(IMG_CR_SM),
        .IMG_L_OFF(IMG_L_OFF),
        .IMG_R_OFF(IMG_R_OFF),
        .IMG_T_OFF(IMG_T_OFF),
        .IMG_B_OFF(IMG_B_OFF),
        .SCALER_OUT_W(SCALER_OUT_W),
        .SCALER_OUT_H(SCALER_OUT_H),
        .INPUT_SEL(INPUT_SEL)
    ) dut (
        .clk(clk),
        .emif_ref_clk(emif_ref_clk),
        .reset(reset),
        .out_tdata(out_tdata),
        .out_tvalid(out_tvalid),
        .out_tready(out_tready),
        .out_tlast(out_tlast),
        .out_tuser(out_tuser),
        // PC1 image source ports
        .pc1_in_tdata (pc1_in_tdata),
        .pc1_in_tvalid(pc1_in_tvalid),
        .pc1_in_tready(pc1_in_tready),
        .pc1_in_tlast (pc1_in_tlast),
        .pc1_in_tuser (pc1_in_tuser)
    );

    // --- Clock Generation ---
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // EMIF PHY reference clock: 200 MHz (PHY_REFCLK_FREQ_MHZ)
    initial emif_ref_clk = 0;
    always #2.5 emif_ref_clk = ~emif_ref_clk;

    // --- Stimulus Process ---
    initial begin
        reset = 1;
        out_tready = 0;

        repeat(10) @(posedge clk);
        reset = 0;
        $display("[%0t] Reset de-asserted. Starting Configuration...", $time);

        wait(dut.current_state == dut.ST_WORKING);
        $display("[%0t] Configuration Complete. System is now WORKING.", $time);

        @(posedge clk);
        out_tready = 1;

        wait(out_tvalid && out_tuser[0]);
        $display("[%0t] First Start of Frame (SOF) detected at VFB output!", $time);

        repeat(5) begin
            wait(out_tvalid && out_tlast);
            @(posedge clk);
        end

        $display("[%0t] Captured data segments. Simulation passing.", $time);

        wait(frame_done);
        $display("[%0t] Frame successfully written to file.", $time);
        $finish;
    end

    // --- Image hex player (active only when INPUT_SEL=1) ---
    generate
        if (INPUT_SEL == 1'b1) begin : gen_img_src
            // Pixel memory: loaded from the hex file produced by png_to_hex.py
            reg [23:0] img_mem [0 : TPG_WIDTH * TPG_HEIGHT - 1];
            integer px, py;

            initial begin
                $readmemh("../../../../app/image_data.txt", img_mem);
                $display("[IMG ] Image hex loaded (%0dx%0d).", TPG_WIDTH, TPG_HEIGHT);

                // Wait until all IPs (including PC1) are configured
                wait(dut.current_state == dut.ST_WORKING);
                repeat(5) @(posedge clk);

                $display("[IMG ] Sending image frame to PC1 input...");
                @(posedge clk); #1;

                for (py = 0; py < TPG_HEIGHT; py = py + 1) begin
                    for (px = 0; px < TPG_WIDTH; px = px + 1) begin
                        pc1_in_tdata  = img_mem[py * TPG_WIDTH + px];
                        pc1_in_tvalid = 1'b1;
                        // SOF on first pixel
                        pc1_in_tuser  = (px == 0 && py == 0) ? 3'b001 : 3'b000;
                        // EOL on last pixel of each line
                        pc1_in_tlast  = (px == TPG_WIDTH - 1) ? 1'b1 : 1'b0;

                        @(posedge clk);
                        while (!pc1_in_tready) @(posedge clk);
                        #1;
                    end
                end

                // Deassert after last pixel
                pc1_in_tvalid = 1'b0;
                pc1_in_tlast  = 1'b0;
                pc1_in_tuser  = 3'b000;
                $display("[IMG ] Image frame sent.");
            end
        end
    endgenerate

    // --- State trace (debug) ---
    reg [4:0] last_state = 5'h1F;
    always @(posedge clk) begin
        if (!reset && dut.current_state !== last_state) begin
            $display("[%0t] STATE %0d -> %0d  cfg_step=%0d", $time, last_state, dut.current_state, dut.cfg_step);
            last_state <= dut.current_state;
        end
    end

    // --- Timeout Watchdog ---
    initial begin
        #(END_TIME);
        $display("Error: Simulation Timeout!  current_state=%0d cfg_step=%0d", dut.current_state, dut.cfg_step);
        $display("  tpg_wait=%b bridge_wait=%b pc1_wait=%b",
                 dut.tpg_wait, dut.bridge_wait, dut.pc1_wait);
        $finish;
    end

endmodule
