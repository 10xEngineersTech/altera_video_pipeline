`timescale 1 ps / 1 ps
module make_file #(
    parameter IMG_H     = 1080,
    parameter IMG_W     = 1920,
    parameter IS_FULL   = 1,      // 1: Full mode, 0: Lite mode
    parameter FILE_NAME = "output_data.txt"
)(
    input wire        clk,
    input wire        reset,

    input wire        tready,
    input wire [23:0] tdata,
    input wire        tvalid,
    input wire        tlast,
    input wire [2:0]  tuser,

    output wire       frame_done
);
    wire write_flag, error;

    // --- Instantiate Frame Controller ---
    frame_controller #(
        .IMG_H(IMG_H),
        .IMG_W(IMG_W),
        .IS_FULL(IS_FULL)
    ) controller (
        .clk        (clk),
        .reset      (reset),
        .tdata      (tdata),
        .tvalid     (tvalid),
        .ready      (tready),
        .last       (tlast),
        .tuser      (tuser),
        .frame_done (frame_done),
        .write_flag (write_flag),
        .error      (error)
    );

    integer fd;
    reg     captured;

    initial begin
        captured = 0;
        fd = $fopen(FILE_NAME, "w");
        if (fd == 0) begin
            $display("Error: Could not open file %s for writing.", FILE_NAME);
            $finish;
        end
    end

    // --- File Writing Logic - only capture first complete frame ---
    always @(posedge clk) begin
        if (write_flag && !captured) begin
            $fwrite(fd, "%h ", tdata);
            if (tlast)
                $fwrite(fd, "\n");
        end
    end

    // --- Close file on first frame_done only ---
    always @(posedge clk) begin
        if (frame_done && !captured) begin
            captured <= 1;
            $display("[MODULE] Frame Done detected for %s. Closing file.", FILE_NAME);
            repeat(10) @(posedge clk);
            $fclose(fd);
            $display("[MODULE] Hex file closed.");
        end
    end

endmodule
