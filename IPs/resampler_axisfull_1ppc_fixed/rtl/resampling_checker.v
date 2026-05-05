`timescale 1 ps / 1 ps

module resampling_checker(
    input  wire        clk_clk,       // Clock
    input  wire        reset_reset,   // Reset
    
    // CRS Output to check
    input  wire [23:0] crs_out_tdata,
    input  wire        crs_out_tvalid,
    input  wire [2:0]  crs_out_tuser,
    
    // TPG Input (reference)
    input  wire [15:0] tpg_out_tdata,
    input  wire        tpg_out_tvalid,
    input  wire [1:0]  tpg_out_tuser,

    output wire        status_led     // Status LED
);

    // 4:2:2 1ppc:
    // Even pixel: tpg_out_tdata = {U (Cb), Y}
    // Odd pixel:  tpg_out_tdata = {V (Cr), Y}
    
    // 4:4:4 1ppc:
    // crs_out_tdata = {V, Y, U}

    // Ignore control packets (tuser[1] == 1)
    wire tpg_is_video = tpg_out_tvalid && (tpg_out_tuser[1] == 1'b0);
    wire crs_is_video = crs_out_tvalid && (crs_out_tuser[1] == 1'b0);

    reg [7:0] saved_u;
    reg [7:0] saved_y0;
    reg       tpg_phase; // 0 for even, 1 for odd

    // FIFO for expected data
    reg [23:0] expected_fifo [0:1023];
    reg [9:0]  wr_ptr;
    reg [9:0]  rd_ptr;

    always @(posedge clk_clk or posedge reset_reset) begin
        if (reset_reset) begin
            tpg_phase <= 1'b0;
            wr_ptr <= 10'd0;
            saved_u <= 8'd0;
            saved_y0 <= 8'd0;
        end else begin
            if (tpg_is_video) begin
                if (tpg_out_tuser[0] || tpg_phase == 1'b0) begin
                    // Even pixel (or SOF forces even)
                    saved_u  <= tpg_out_tdata[15:8];
                    saved_y0 <= tpg_out_tdata[7:0];
                    tpg_phase <= 1'b1;
                end else begin
                    // Odd pixel
                    // Write 2 pixels to FIFO
                    // Pixel 0: {V0, Y0, U0}
                    expected_fifo[wr_ptr]   <= {tpg_out_tdata[15:8], saved_y0, saved_u};
                    // Pixel 1: {V0, Y1, U0}
                    expected_fifo[wr_ptr+1] <= {tpg_out_tdata[15:8], tpg_out_tdata[7:0], saved_u};
                    wr_ptr <= wr_ptr + 2;
                    tpg_phase <= 1'b0;
                end
            end
        end
    end

    wire [23:0] expected_out = expected_fifo[rd_ptr];
    wire        fifo_empty = (wr_ptr == rd_ptr);

    reg status_led_reg;
    reg error_flag;
    reg [31:0] match_count;

    always @(posedge clk_clk or posedge reset_reset) begin
        if (reset_reset) begin
            rd_ptr <= 10'd0;
            status_led_reg <= 1'b0;
            error_flag <= 1'b0;
            match_count <= 32'd0;
        end else begin
            if (crs_is_video) begin
                if (!fifo_empty) begin
                    if (crs_out_tdata != expected_out) begin
                        error_flag <= 1'b1;
                        $display("Time %0t: Mismatch! Expected %x, Got %x", $time, expected_out, crs_out_tdata);
                    end else begin
                        match_count <= match_count + 1;
                    end
                    rd_ptr <= rd_ptr + 1;
                end else begin
                    $display("Time %0t: CRS valid but expected FIFO empty!", $time);
                    error_flag <= 1'b1;
                end
            end
            
            // Turn on LED if we have matched a sufficient number of pixels and no errors
            if (match_count > 10 && !error_flag) begin
                status_led_reg <= 1'b1;
            end else begin
                status_led_reg <= 1'b0;
            end
        end
    end

    assign status_led = status_led_reg;

endmodule
