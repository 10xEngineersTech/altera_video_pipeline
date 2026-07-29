`timescale 1 ps / 1 ps

module make_file #(
    parameter IMG_H     = 1080,
    parameter IMG_W     = 1920,
    parameter IS_FULL   = 1,      // 1: Full mode, 0: Lite mode
    parameter SKIP_ROWS = 0,      // hidden guard rows discarded at top of frame
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
        .IS_FULL(IS_FULL),
        .SKIP_ROWS(SKIP_ROWS)
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
		  .error		  (error)
    );
     
    integer fd;
    initial begin
        // Open file for writing
        fd = $fopen(FILE_NAME, "w");
        if (fd == 0) begin
            $display("Error: Could not open file %s for writing.", FILE_NAME);
            $finish;
        end
    end

    // --- File Writing Logic ---
    always @(posedge clk) begin
        if (write_flag) begin
            $fwrite(fd, "%h ", tdata);
            
            if (tlast) begin
                $fwrite(fd, "\n");
            end
        end
    end
    
    // --- Housekeeping: Close file when frame is done ---
    always @(posedge clk) begin
        if (frame_done) begin
            $display("[MODULE] Frame Done detected for %s. Closing file.", FILE_NAME);
            // Small delay to ensure the final write completes
            repeat (10) @(posedge clk);
            $fclose(fd);
            $display("[MODULE] Hex file closed.");
            // NOTE: Usually you don't put $stop inside a sub-module 
            // but it works if this is purely for a Testbench.
             
        end
    end
	 
	 always @(posedge clk) begin
        if (error) begin
            $display("Error %s. Closing file.", FILE_NAME);
            $fclose(fd);
				fd = $fopen(FILE_NAME, "w");
				if (fd == 0) begin
					$display("Error: Could not open file %s for writing.", FILE_NAME);
					$finish;
				end
				$fwrite(fd, "%h ", tdata);
        end
    end

endmodule