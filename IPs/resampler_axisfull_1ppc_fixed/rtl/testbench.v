`timescale 1 ps / 1 ps

module testbench();

    reg clk_clk;
    reg reset_reset;
    wire status_led;

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

    // ----- Top Level Instance -----
    top u_top (
        .clk_clk(clk_clk),
        .reset_reset(reset_reset),
        .status_led(status_led)
    );

    // ----- Stimulus and Monitor -----
    initial begin
        // Wait for reset to finish
        @(negedge reset_reset);
        repeat (10) @(posedge clk_clk);

        $display("Waiting for CRS to process stream...");

        // Monitor status
        repeat (100) @(posedge clk_clk);
        
        $display("Monitoring status_led...");
        repeat (5000) begin // Keep increased timeout
            @(posedge clk_clk);
            if (status_led) begin
                $display("Status: PASS (status_led is HIGH)");
                $stop;
            end
        end
        
        $display("Status: FAIL (status_led timed out)");
        $stop;
    end

    // ----- VCD dump -----
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);
    end

    // ----- Data Dump for Image Generation -----
    integer fd_yuv422, fd_yuv444;
    initial begin
        fd_yuv422 = $fopen("tpg_yuv422.txt", "w");   // TPG input:  16-bit YUV422 1PPC
        fd_yuv444 = $fopen("crs_yuv444.txt", "w");   // CRS output: 24-bit YUV444 1PPC
    end

    // TPG YUV422 dump -- phase-tracked pairs written as one 32-bit word
    //   Even pixel → {Cb[7:0], Y0[7:0]}
    //   Odd  pixel → {Cr[7:0], Y1[7:0]}
    //   Output line → {Cr[7:0], Y1[7:0], Cb[7:0], Y0[7:0]}  (8 hex digits)
    reg        tpg_phase;       // 0 = waiting for even pixel, 1 = waiting for odd
    reg [7:0]  saved_cb;
    reg [7:0]  saved_y0;

    always @(posedge clk_clk or posedge reset_reset) begin
        if (reset_reset) begin
            tpg_phase <= 1'b0;
            saved_cb  <= 8'd0;
            saved_y0  <= 8'd0;
        end else begin
            if (u_top.tpg_out_tvalid &&
                (u_top.tpg_out_tuser[1] == 1'b0)) begin

                // tuser[0] = SOF → forces re-sync to even phase
                if (u_top.tpg_out_tuser[0] || tpg_phase == 1'b0) begin
                    // Even pixel: {Cb, Y0}
                    saved_cb  <= u_top.tpg_out_tdata[15:8];
                    saved_y0  <= u_top.tpg_out_tdata[7:0];
                    tpg_phase <= 1'b1;
                end else begin
                    // Odd pixel: {Cr, Y1}  → write complete pair
                    $fdisplay(fd_yuv422, "%02x%02x%02x%02x",
                        u_top.tpg_out_tdata[15:8], // Cr
                        u_top.tpg_out_tdata[7:0],  // Y1
                        saved_cb,                  // Cb
                        saved_y0);                 // Y0
                    tpg_phase <= 1'b0;
                end
            end
        end
    end

    // CRS YUV444 dump  -- {V[7:0], Y[7:0], U[7:0]}
    always @(posedge clk_clk) begin
        if (u_top.crs_out_tvalid && 1'b1 && // crs_out_tready is always 1 in top.v
            (u_top.crs_out_tuser[1] == 1'b0)) begin
            $fdisplay(fd_yuv444, "%06x", u_top.crs_out_tdata);
        end
    end

endmodule
