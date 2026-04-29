// =============================================================================
// testbench.v  –  Simulation Testbench for top.v
// =============================================================================
// Drives the DUT (top.v) which contains:
//   ┌────────────────────────────────────────────┐
//   │  top.v  (DUT)                              │
//   │  ┌─────────────┐    ┌────────────────────┐ │
//   │  │  system.qsys│    │   vid_checker.v    │ │
//   │  │  TPG IN_W   │───▶│  verify OUT_W x    │ │
//   │  │      x IN_H │    │         OUT_H      │ │
//   │  │  Scaler     │    │                    │ │
//   │  └─────────────┘    └────────────────────┘ │
//   └────────────────────────────────────────────┘
//
// ─── SINGLE SOURCE OF TRUTH ──────────────────────────────────────────────────
//  Edit only the four localparams below to change input/output resolution:
//
//    SCALER_IN_W  / SCALER_IN_H   → written to scaler IMG_INFO registers
//    SCALER_OUT_W / SCALER_OUT_H → written to scaler OUTPUT registers
//                                    AND passed to checker as expected dimensions
//
//  The checker will automatically expect SCALER_OUT_W × SCALER_OUT_H output.
// ─────────────────────────────────────────────────────────────────────────────
//
// Scaler Avalon-MM Register Map (LITE MODE, word-addressed, 7-bit address bus):
//   Byte 0x0120 (Word 0x48) – IMG_INFO_WIDTH    input pixels per line
//   Byte 0x0124 (Word 0x49) – IMG_INFO_HEIGHT   input lines  per frame
//   Byte 0x0148 (Word 0x52) – OUTPUT_WIDTH      output pixels per line
//   Byte 0x014C (Word 0x53) – OUTPUT_HEIGHT     output lines  per frame
// =============================================================================
`timescale 1ns/1ps

module testbench;

    // =========================================================================
    // *** CONFIGURE SCALING DIMENSIONS HERE ***
    //  These parameters are used for:
    //    1. Avalon-MM writes that configure the hardware scaler
    //    2. exp_width / exp_height passed to the checker in top.v
    // =========================================================================
    localparam SCALER_IN_W  = 24;   // Scaler input  pixels per line  (from TPG)
    localparam SCALER_IN_H  = 24;   // Scaler input  lines  per frame (from TPG)
    localparam SCALER_OUT_W = 8;   // Scaler output pixels per line  (checker expects this)
    localparam SCALER_OUT_H = 8;   // Scaler output lines  per frame (checker expects this)

    // =========================================================================
    // Simulation control parameters
    // =========================================================================
    localparam CLK_HALF      = 10;          // half-period in ns  → 50 MHz
    localparam RST_CYCLES    = 20;          // clock cycles to hold reset
    localparam SETTLE_CYCLES = 5;           // idle cycles after reset before config
    localparam PASS_FRAMES   = 2;           // frames to verify before declaring pass
    localparam SIM_TIMEOUT   = 10_000_000;  // 10 ms hard timeout in ns

    // Scaler control register word addresses (Intel VVP, LITE MODE ON)
    // NOTE: Qsys addresses are byte-addressed, but 'addressUnits' is WORDS here.
    localparam [6:0] REG_IN_WIDTH   = 7'h48;  // Byte 0x0120 – IMG_INFO_WIDTH
    localparam [6:0] REG_IN_HEIGHT  = 7'h49;  // Byte 0x0124 – IMG_INFO_HEIGHT
    localparam [6:0] REG_OUT_WIDTH  = 7'h52;  // Byte 0x0148 – OUTPUT_WIDTH
    localparam [6:0] REG_OUT_HEIGHT = 7'h53;  // Byte 0x014C – OUTPUT_HEIGHT

    // =========================================================================
    // DUT interface signals
    // =========================================================================
    reg         clk;
    reg         rst;

    // Avalon-MM
    reg   [6:0] avmm_addr;
    reg         avmm_write;
    reg   [3:0] avmm_be;
    reg  [31:0] avmm_wdata;
    reg         avmm_read;
    wire [31:0] avmm_rdata;
    wire        avmm_rdv;
    wire        avmm_wait;

    // Expected output dimensions driven from this testbench → top → checker
    // Automatically set to SCALER_OUT_W / SCALER_OUT_H in the initial block.
    reg  [15:0] exp_width;
    reg  [15:0] exp_height;

    // Checker status
    wire        check_pass;
    wire        check_fail;
    wire  [7:0] frames_checked;
	 
	 
	 // =========================================================================
    // input/ouput signals
    // =========================================================================
	 wire [23:0] scaler_tdata  ,tpg_tdata;
    wire 		 scaler_tvalid ,tpg_tvalid;
    wire 		 scaler_tready ,tpg_tready;
    wire 		 scaler_tlast  ,tpg_tlast;
    wire [2:0]  scaler_tuser  ,tpg_tuser;
	 
	 assign scaler_tdata  = u_top.scaler_tdata;
	 assign scaler_tvalid = u_top.scaler_tvalid;
	 assign scaler_tready = u_top.scaler_tready;
	 assign scaler_tlast  = u_top.scaler_tlast;
	 assign scaler_tuser  = u_top.scaler_tuser;
	 
	 assign tpg_tdata  = u_top.u_system.intel_vvp_tpg_0_axi4s_vid_out_tdata;
	 assign tpg_tvalid = u_top.u_system.intel_vvp_tpg_0_axi4s_vid_out_tvalid;
	 assign tpg_tready = u_top.u_system.intel_vvp_tpg_0_axi4s_vid_out_tready;
	 assign tpg_tlast  = u_top.u_system.intel_vvp_tpg_0_axi4s_vid_out_tlast;
	 assign tpg_tuser  = u_top.u_system.intel_vvp_tpg_0_axi4s_vid_out_tuser;
	 
	 integer fd_in, fd_out;

	initial begin
		// Open files for writing
		fd_in  = $fopen("input_hex.txt", "w");
		fd_out = $fopen("output_hex.txt", "w");

		if (fd_in == 0 || fd_out == 0) begin
			$display("Error: Could not open hex files for writing.");
			$finish;
		end
	end

	// --- Capture Input (TPG) ---
	always @(posedge clk) begin
		if (tpg_tvalid && tpg_tready && ~(check_pass || check_fail)) begin
			$fwrite(fd_in, "%h ", tpg_tdata);
        
			// If it's the end of the line, move to a new line in the text file
			if (tpg_tlast) begin
				$fwrite(fd_in, "\n");
			end
		end
	end

	// --- Capture Output (Scaler) ---
	always @(posedge clk) begin
		if (scaler_tvalid && scaler_tready && ~(check_pass || check_fail)) begin
			$fwrite(fd_out, "%h ", scaler_tdata);
        
			// If it's the end of the line, move to a new line in the text file
			if (scaler_tlast) begin
				$fwrite(fd_out, "\n");
			end
		end
	end

	// Ensure files are flushed and closed when $finish is called
    // We use a small delay or check for the end of simulation
    always @(check_pass or check_fail) begin
        if (check_pass || check_fail) begin
            // Small delay to ensure the last pixel is written
            #100;
            $fclose(fd_in);
            $fclose(fd_out);
            $display("[TB ] Hex files closed.");
        end
    end

    // =========================================================================
    // DUT instantiation
    // =========================================================================
    top u_top (
        .clk            (clk),
        .rst            (rst),

        .avmm_addr      (avmm_addr),
        .avmm_write     (avmm_write),
        .avmm_be        (avmm_be),
        .avmm_wdata     (avmm_wdata),
        .avmm_read      (avmm_read),
        .avmm_rdata     (avmm_rdata),
        .avmm_rdv       (avmm_rdv),
        .avmm_wait      (avmm_wait),

        // Tell the checker what output size to expect
        .exp_width      (exp_width),
        .exp_height     (exp_height),

        .check_pass     (check_pass),
        .check_fail     (check_fail),
        .frames_checked (frames_checked)
    );

    // =========================================================================
    // Clock generation  – 50 MHz (20 ns period)
    // =========================================================================
    initial clk = 1'b0;
    always  #CLK_HALF clk = ~clk;

    // =========================================================================
    // Task: Avalon-MM single 32-bit register write
    //   – holds address/data/write high until waitrequest deasserts
    //   – deasserts write on the following cycle
    // =========================================================================
    task avmm_wr;
        input  [6:0] addr;
        input [31:0] data;
        begin
            @(posedge clk); #1;
            avmm_addr  = addr;
            avmm_wdata = data;
            avmm_be    = 4'hF;
            avmm_write = 1'b1;
            avmm_read  = 1'b0;

            @(posedge clk);
            while (avmm_wait) @(posedge clk);

            #1;
            avmm_write = 1'b0;
            avmm_addr  = 7'h00;
            avmm_wdata = 32'h0;
            $display("[TB  ][%5t ns] AVMM WR  addr=0x%02h  data=0x%08h",
                     $time/1000, addr, data);
        end
    endtask

    // =========================================================================
    // Task: Avalon-MM single 32-bit register read
    // =========================================================================
    task avmm_rd;
        input  [6:0]  addr;
        output [31:0] rdata;
        begin
            @(posedge clk); #1;
            avmm_addr  = addr;
            avmm_read  = 1'b1;
            avmm_write = 1'b0;

            @(posedge clk);
            while (avmm_wait) @(posedge clk);

            #1;
            avmm_read = 1'b0;
            avmm_addr = 7'h00;

            @(posedge clk);
            while (!avmm_rdv) @(posedge clk);

            rdata = avmm_rdata;
            $display("[TB  ][%5t ns] AVMM RD  addr=0x%02h  data=0x%08h",
                     $time/1000, addr, rdata);
        end
    endtask

    // =========================================================================
    // Task: configure_scaler
    //   Writes SCALER_IN_W, SCALER_IN_H, SCALER_OUT_W, SCALER_OUT_H to the
    //   scaler Avalon-MM control registers (LITE MODE – 4 registers, no commit).
    //   Also sets exp_width / exp_height so the checker knows what output
    //   dimensions to expect.
    // =========================================================================
    task configure_scaler;
        begin
            $display("[TB  ][%5t ns] ---- Configuring Scaler (LITE MODE) ----", $time/1000);
            $display("[TB  ][%5t ns]   Input  : %0d x %0d",
                     $time/1000, SCALER_IN_W, SCALER_IN_H);
            $display("[TB  ][%5t ns]   Output : %0d x %0d  (checker expects this)",
                     $time/1000, SCALER_OUT_W, SCALER_OUT_H);

            // ── Program the 4 scaler registers (lite mode) ───────────────────
            // Step 1: input resolution
            avmm_wr(REG_IN_WIDTH,   SCALER_IN_W[31:0]);    // 0x0120 = 20
            avmm_wr(REG_IN_HEIGHT,  SCALER_IN_H[31:0]);    // 0x0124 = 10

            // Step 2: output resolution
            avmm_wr(REG_OUT_WIDTH,  SCALER_OUT_W[31:0]);   // 0x0148 = 10
            avmm_wr(REG_OUT_HEIGHT, SCALER_OUT_H[31:0]);   // 0x014C = 5

            // ── Write expected dimensions to checker ─────────────────────────
            exp_width  = SCALER_OUT_W[15:0];
            exp_height = SCALER_OUT_H[15:0];

            $display("[TB  ][%5t ns] ---- Scaler configured. Checker expects %0dx%0d ----",
                     $time/1000, SCALER_OUT_W, SCALER_OUT_H);
        end
    endtask

    // =========================================================================
    // Stimulus: reset → configure
    // =========================================================================
    initial begin
        // Default / safe initial values
        avmm_addr  = 7'h00;
        avmm_write = 1'b0;
        avmm_be    = 4'hF;
        avmm_wdata = 32'h0;
        avmm_read  = 1'b0;
        exp_width  = 16'd0;   // checker will not yet fire (no SOF yet)
        exp_height = 16'd0;

        // Assert reset
        rst = 1'b1;
        $display("[TB  ][     0 ns] Reset asserted.");
        repeat (RST_CYCLES) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        $display("[TB  ][%5t ns] Reset released.", $time/1000);

        repeat (SETTLE_CYCLES) @(posedge clk);

        // Configure scaler and tell checker what to expect
        configure_scaler();

    end

    // =========================================================================
    // Monitor: wait for enough verified frames, then end simulation
    // =========================================================================
    initial begin
        $display("[TB  ] =====================================================");
        $display("[TB  ] Testbench Start  (LITE MODE)");
        $display("[TB  ] Input  : %0dx%0d",  SCALER_IN_W, SCALER_IN_H);
        $display("[TB  ] Output : %0dx%0d  (checker will verify this)",
                 SCALER_OUT_W, SCALER_OUT_H);
        $display("[TB  ] Need   : %0d passing frames", PASS_FRAMES);
        $display("[TB  ] =====================================================");

        wait (frames_checked >= PASS_FRAMES || check_fail);
        repeat (4) @(posedge clk);

        $display("[TB  ] =====================================================");
        if (check_fail) begin
            $display("[TB  ] *** RESULT : FAIL ***");
            $display("[TB  ] Dimension mismatch – expected %0dx%0d.",
                     SCALER_OUT_W, SCALER_OUT_H);
            $display("[TB  ] Frames verified before failure : %0d", frames_checked);
        end else begin
            $display("[TB  ] *** RESULT : PASS ***");
            $display("[TB  ] %0d frames verified as %0dx%0d without error.",
                     frames_checked, SCALER_OUT_W, SCALER_OUT_H);
        end
        $display("[TB  ] =====================================================");
        $finish;
    end

    // =========================================================================
    // check_fail alert (continuous)
    // =========================================================================
    always @(posedge clk) begin
        if (check_fail)
            $display("[TB  ][%5t ns] *** check_fail asserted! ***", $time/1000);
    end

    // =========================================================================
    // Per-frame pass display
    // =========================================================================
    reg [7:0] prev_frames_checked;
    initial prev_frames_checked = 8'd0;
    
    always @(posedge clk) begin
        if (rst) begin
            prev_frames_checked <= 8'd0;
        end else begin
            prev_frames_checked <= frames_checked;
            if (check_pass && (frames_checked > prev_frames_checked))
                $display("[TB  ][%5t ns] Frame #%0d PASSED (%0dx%0d verified).",
                         $time/1000, prev_frames_checked, SCALER_OUT_W, SCALER_OUT_H);
        end
    end

    // =========================================================================
    // Hard timeout watchdog
    // =========================================================================
    initial begin
        #SIM_TIMEOUT;
        $display("[TB  ] =====================================================");
        $display("[TB  ] *** TIMEOUT – exceeded %0d ns ***", SIM_TIMEOUT);
        $display("[TB  ] Frames checked : %0d | check_fail : %b",
                 frames_checked, check_fail);
        $display("[TB  ] =====================================================");
        $finish;
    end

    // =========================================================================
    // VCD waveform dump
    // =========================================================================
    initial begin
        $dumpfile("scaler_sim.vcd");
        $dumpvars(0, testbench);
        $display("[TB  ] Waveform dump → scaler_sim.vcd");
    end

endmodule
