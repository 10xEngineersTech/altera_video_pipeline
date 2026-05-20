`timescale 1 ps / 1 ps

// Testbench for the protocol_converter chain:
//   input.png  -> [AXIS Lite] -> converter_0 (Lite->Full)
//                             -> converter_1 (Full->Lite) -> [AXIS Lite] -> output_data.txt
//
// Register map (word addresses = byte_addr / 4):
//   0x120/4 = 7'h48 : IMG_INFO_WIDTH
//   0x124/4 = 7'h49 : IMG_INFO_HEIGHT
//   0x128/4 = 7'h4A : IMG_INFO_INTERLACE  (0 = progressive)
//   0x130/4 = 7'h4C : IMG_INFO_COLORSPACE (0 = RGB)
//   0x134/4 = 7'h4D : IMG_INFO_SUBSAMPLING(0 = 4:4:4)
//   0x154/4 = 7'h55 : CTRL               (bit0 = start)

module testbench;

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    localparam IMG_WIDTH  = 64;
    localparam IMG_HEIGHT = 36;
    localparam CLK_PERIOD = 10000; // 100 MHz in ps

    localparam INPUT_FILE  = "/mnt/ssd2/hamza/altera_video_pipeline/IPs/protocol_converter/rtl/input_data.txt";
    localparam OUTPUT_FILE = "/mnt/ssd2/hamza/altera_video_pipeline/IPs/protocol_converter/rtl/output_data.txt";

    // -------------------------------------------------------------------------
    // Clock & reset
    // -------------------------------------------------------------------------
    reg clk   = 0;
    reg reset = 1;
    always #(CLK_PERIOD/2) clk = ~clk;

    // -------------------------------------------------------------------------
    // AXIS Lite input (to converter_0)
    // -------------------------------------------------------------------------
    reg  [23:0] s_tdata  = 0;
    reg         s_tvalid = 0;
    wire        s_tready;
    reg         s_tlast  = 0;
    reg  [2:0]  s_tuser  = 0;

    // -------------------------------------------------------------------------
    // AXIS Lite output (from converter_1)
    // -------------------------------------------------------------------------
    wire [23:0] m_tdata;
    wire        m_tvalid;
    reg         m_tready = 1; // always accept output
    wire        m_tlast;
    wire [2:0]  m_tuser;

    // -------------------------------------------------------------------------
    // Avalon-MM control (converter_0 only)
    // -------------------------------------------------------------------------
    reg  [6:0]  avmm_addr  = 0;
    reg         avmm_write = 0;
    reg  [3:0]  avmm_be    = 0;
    reg  [31:0] avmm_wdata = 0;
    reg         avmm_read  = 0;
    wire [31:0] avmm_rdata;
    wire        avmm_rdv;
    wire        avmm_wait;

    // -------------------------------------------------------------------------
    // DUT
    // -------------------------------------------------------------------------
    top u_top (
        .clk_clk                (clk),
        .reset_reset            (reset),

        .s_axis_tdata           (s_tdata),
        .s_axis_tvalid          (s_tvalid),
        .s_axis_tready          (s_tready),
        .s_axis_tlast           (s_tlast),
        .s_axis_tuser           (s_tuser),

        .m_axis_tdata           (m_tdata),
        .m_axis_tvalid          (m_tvalid),
        .m_axis_tready          (m_tready),
        .m_axis_tlast           (m_tlast),
        .m_axis_tuser           (m_tuser),

        .av_mm_conv0_address    (avmm_addr),
        .av_mm_conv0_write      (avmm_write),
        .av_mm_conv0_byteenable (avmm_be),
        .av_mm_conv0_writedata  (avmm_wdata),
        .av_mm_conv0_read       (avmm_read),
        .av_mm_conv0_readdata   (avmm_rdata),
        .av_mm_conv0_readdatavalid (avmm_rdv),
        .av_mm_conv0_waitrequest   (avmm_wait)
    );

    // -------------------------------------------------------------------------
    // Avalon-MM write task
    // -------------------------------------------------------------------------
    task avmm_wr;
        input [6:0]  addr;
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
            $display("[AVMM][%0t ns] WR addr=0x%02h  data=0x%08h", $time/1000, addr, data);
        end
    endtask

    // -------------------------------------------------------------------------
    // Pixel memory for stimulus
    // -------------------------------------------------------------------------
    reg [23:0] pix_mem [0 : IMG_WIDTH*IMG_HEIGHT-1];

    // -------------------------------------------------------------------------
    // Output file handle and capture state
    // -------------------------------------------------------------------------
    integer out_fd;
    integer line_cnt;
    reg     frame_started;
    reg     frame_done;

    // -------------------------------------------------------------------------
    // Output capture: runs in parallel with stimulus
    // -------------------------------------------------------------------------
    initial begin
        frame_started = 1'b0;
        frame_done    = 1'b0;
        line_cnt      = 0;
    end

    always @(posedge clk) begin
        if (m_tvalid && m_tready && !m_tuser[1]) begin
            // SOF: first pixel of the output frame
            if (m_tuser[0]) begin
                frame_started = 1'b1;
                line_cnt      = 0;
            end

            // Write video pixel to file
            if (frame_started && !frame_done) begin
                $fwrite(out_fd, "%06x\n", m_tdata);

                if (m_tlast) begin
                    line_cnt = line_cnt + 1;
                    if (line_cnt >= IMG_HEIGHT) begin
                        frame_done = 1'b1;
                    end
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Main stimulus
    // -------------------------------------------------------------------------
    integer x, y;

    initial begin
        $readmemh(INPUT_FILE, pix_mem);

        out_fd = $fopen(OUTPUT_FILE, "w");
        if (out_fd == 0) begin
            $display("ERROR: cannot open %s", OUTPUT_FILE);
            $finish;
        end

        // ----- Reset -----
        reset = 1;
        repeat (20) @(posedge clk);
        reset = 0;
        $display("[TB  ] Reset released at %0t ns", $time/1000);
        repeat (10) @(posedge clk);

        // ----- Configure converter_0 registers -----
        // IMG_INFO_WIDTH  (byte 0x120 -> word 0x48)
        avmm_wr(7'h48, IMG_WIDTH);
        // IMG_INFO_HEIGHT (byte 0x124 -> word 0x49)
        avmm_wr(7'h49, IMG_HEIGHT);
        // IMG_INFO_INTERLACE (byte 0x128 -> word 0x4A) : 0 = progressive
        avmm_wr(7'h4A, 32'h0);
        // IMG_INFO_COLORSPACE (byte 0x130 -> word 0x4C) : 0 = RGB
        avmm_wr(7'h4C, 32'h0);
        // IMG_INFO_SUBSAMPLING (byte 0x134 -> word 0x4D) : 0 = 4:4:4
        avmm_wr(7'h4D, 32'h0);
        // CTRL (byte 0x154 -> word 0x55) : bit0 = 1 to start
        avmm_wr(7'h55, 32'h1);

        repeat (5) @(posedge clk);
        $display("[TB  ] Converter_0 configured and started.");

        // ----- Drive AXIS Lite video frame -----
        // tdata[23:16]=R, [15:8]=G, [7:0]=B
        // tuser[0]=1 on first pixel (SOF); tlast=1 on last pixel of each line
        @(posedge clk); #1;

        for (y = 0; y < IMG_HEIGHT; y = y + 1) begin
            for (x = 0; x < IMG_WIDTH; x = x + 1) begin
                s_tdata  = pix_mem[y * IMG_WIDTH + x];
                s_tvalid = 1'b1;
                s_tuser  = (x == 0 && y == 0) ? 3'b001 : 3'b000;
                s_tlast  = (x == IMG_WIDTH - 1) ? 1'b1 : 1'b0;

                @(posedge clk);
                while (!s_tready) @(posedge clk);
                #1;
            end
        end

        // Deassert valid after last pixel
        s_tvalid = 1'b0;
        s_tlast  = 1'b0;
        s_tuser  = 3'b000;
        $display("[TB  ] Stimulus done. Waiting for output frame...");

        // ----- Wait for output frame to complete -----
        wait (frame_done);
        repeat (20) @(posedge clk);

        $fclose(out_fd);
        $display("[TB  ] Simulation complete. Output written to %s", OUTPUT_FILE);
        $finish;
    end

    // -------------------------------------------------------------------------
    // Watchdog: 500 000 cycles (5 ms @ 100 MHz)
    // -------------------------------------------------------------------------
    initial begin
        repeat (500000) @(posedge clk);
        if (!frame_done) begin
            $display("ERROR: Watchdog timeout — frame_done never asserted.");
            $fclose(out_fd);
            $finish;
        end
    end

    // -------------------------------------------------------------------------
    // VCD dump
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);
    end

endmodule
