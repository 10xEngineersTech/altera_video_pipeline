`timescale 1 ps / 1 ps

module testbench();

    reg clk_clk;
    reg reset_reset;

    // ----- Clock Generation -----
    initial begin
        clk_clk = 0;
        forever #5000 clk_clk = ~clk_clk; // 100 MHz
    end

    // ----- Reset Generation -----
    initial begin
        reset_reset = 1;
        #100000;
        reset_reset = 0;
    end

    // ----- Avalon-MM Control Signals -----
    reg   [6:0] avmm_addr;
    reg         avmm_write;
    reg   [3:0] avmm_be;
    reg  [31:0] avmm_wdata;
    reg         avmm_read;
    wire [31:0] avmm_rdata;
    wire        avmm_rdv;
    wire        avmm_wait;

    // ----- Top Level Instance -----
    top u_top (
        .clk_clk(clk_clk),
        .reset_reset(reset_reset),

        // Avalon-MM Control Interface
        .av_mm_control_agent_address(avmm_addr),
        .av_mm_control_agent_write(avmm_write),
        .av_mm_control_agent_byteenable(avmm_be),
        .av_mm_control_agent_writedata(avmm_wdata),
        .av_mm_control_agent_read(avmm_read),
        .av_mm_control_agent_readdata(avmm_rdata),
        .av_mm_control_agent_readdatavalid(avmm_rdv),
        .av_mm_control_agent_waitrequest(avmm_wait)
    );

    // ----- Avalon-MM Write Task -----
    task avmm_wr;
        input  [6:0] addr;
        input [31:0] data;
        begin
            @(posedge clk_clk); #1;
            avmm_addr  = addr;
            avmm_wdata = data;
            avmm_be    = 4'hF;
            avmm_write = 1'b1;
            avmm_read  = 1'b0;

            @(posedge clk_clk);
            while (avmm_wait) @(posedge clk_clk);

            #1;
            avmm_write = 1'b0;
            $display("[TB  ][%5t ns] AVMM WR  addr=0x%02h  data=0x%08h",
                     $time/1000, addr, data);
        end
    endtask

    // ----- Avalon-MM Read Task -----
    task avmm_rd;
        input  [6:0] addr;
        output [31:0] rdata;
        begin
            @(posedge clk_clk); #1;
            avmm_addr  = addr;
            avmm_be    = 4'hF;
            avmm_read  = 1'b1;
            avmm_write = 1'b0;

            // Wait for the read to be accepted (waitrequest low at posedge)
            @(posedge clk_clk);
            while (avmm_wait) @(posedge clk_clk);

            // Read has been accepted — deassert read IMMEDIATELY
            // (Avalon-MM pipelined protocol: do NOT hold read after acceptance)
            #1;
            avmm_read = 1'b0;

            // Now wait for the read data response (readdatavalid)
            while (!avmm_rdv) @(posedge clk_clk);
            
            rdata = avmm_rdata;
            
            $display("[TB  ][%5t ns] AVMM RD  addr=0x%02h  data=0x%08h",
                     $time/1000, addr, rdata);
        end
    endtask


    reg [31:0] read_val;
    // ----- Stimulus and Monitor -----
    initial begin
        // Initialize Avalon signals
         avmm_addr  = 0;
         avmm_wdata = 0;
         avmm_be    = 0;
         avmm_write = 0;
         avmm_read  = 0;

        // Wait for reset to finish
        // NOTE: TPG is internal to the system module (no external GO bit).
        // It starts automatically after reset. The CRS reset bridge has
        // SYNC_LEN=3 and the TPG needs several more clocks for internal
        // init + first control packet generation. We program the CRS
        // OUTPUT_MODE + COMMIT as fast as possible (2 clk settling only)
        // so the configuration is applied BEFORE the first frame arrives.
        @(negedge reset_reset);
        repeat (2) @(posedge clk_clk);  // minimal settling time

        // --- CRITICAL: Program CRS before TPG sends first frame ---
        $display("[TB  ][%5t ns] Programming Resampler (OUTPUT_MODE=3 → YUV444)...", $time/1000);

        // Address 0x0148 (Word address 7'h52): OUTPUT_MODE
        // Write 3 for 4:4:4 output (per IP documentation)
        avmm_wr(7'h52, 32'h3);

        // Address 0x0144 (Word address 7'h51): COMMIT
        // Write any value to commit changes and apply scaling settings
        avmm_wr(7'h51, 32'h1);

        $display("[TB  ][%5t ns] Resampler programmed.", $time/1000);

        // --- Verification reads (non-critical, done after programming) ---
        avmm_rd(7'h50, read_val);
        $display("[TB  ] STATUS after programming: 0x%08x (Processing=%b, Pending=%b)",
                 read_val, read_val[0], read_val[1]);

        // Wait for TPG to start sending data and CRS to start processing
        repeat (100) @(posedge clk_clk);

        // Check STATUS during video processing (Processing bit 0 should = 1)
        avmm_rd(7'h50, read_val);
        $display("[TB  ] STATUS during processing: 0x%08x (Processing=%b, Pending=%b)",
                 read_val, read_val[0], read_val[1]);

        // Run for enough time to capture at least 5 frames
        #50000000;
        
        $display("Simulation finished. Check output files.");
        $stop;
    end

    // ----- VCD dump -----
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);
    end

    // ----- Data Dump for Image Generation -----
    integer fd_yuv420, fd_yuv444;
    initial begin
        fd_yuv420 = $fopen("tpg_yuv420.txt", "w");   // TPG output:  24-bit YUV420 1PPC (internal)
        fd_yuv444 = $fopen("crs_yuv444.txt", "w");    // CRS output:  24-bit YUV444 1PPC
    end

    // TPG YUV420 dump -- probe internal TPG→CRS signals inside the system
    // The TPG output is 24-bit YUV420: {plane2[7:0], plane1[7:0], plane0[7:0]}
    // For YUV420: plane0=Y, plane1=U/Cb, plane2=V/Cr
    // Only dump video data (not control packets: tuser[1]==0)
    always @(posedge clk_clk) begin
        if (u_top.u_dut.intel_vvp_tpg_0_axi4s_vid_out_tvalid &&
            u_top.u_dut.intel_vvp_tpg_0_axi4s_vid_out_tready &&
            (u_top.u_dut.intel_vvp_tpg_0_axi4s_vid_out_tuser[1] == 1'b0)) begin
            $fdisplay(fd_yuv420, "%06x", u_top.u_dut.intel_vvp_tpg_0_axi4s_vid_out_tdata);
        end
    end

    // CRS YUV444 dump -- {plane2[7:0], plane1[7:0], plane0[7:0]}
    // For YUV444: plane0=Y, plane1=U/Cb, plane2=V/Cr
    // Only dump video data (not control packets: tuser[1]==0)
    always @(posedge clk_clk) begin
        if (u_top.crs_out_tvalid && u_top.crs_out_tready &&
            (u_top.crs_out_tuser[1] == 1'b0)) begin
            $fdisplay(fd_yuv444, "%06x", u_top.crs_out_tdata);
        end
    end

endmodule
