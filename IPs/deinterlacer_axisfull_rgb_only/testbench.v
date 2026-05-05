`timescale 1ns/10ps

module testbench;
	
	reg clk;
	reg reset;
	
	wire [23:0] out_tdata;
	wire 			out_tvalid;
	wire 			out_tlast;
	wire [2:0]	out_tuser;
	reg 			out_tready;
	
	integer video_file;
	integer pixel_count = 0;
	integer line_count  = 0;
	reg     in_frame    = 0;
	
	localparam IMG_WIDTH  = 20;
	localparam IMG_HEIGHT = 10;

	initial begin
		video_file = $fopen("video_dump.hex", "w");
		if (!video_file) begin
			$display("Error: Could not open video_dump.hex for writing.");
			$stop;
		end
		$display("Waiting for Start of Frame (tuser)...");
	end


	initial clk = 0;
	always #5 clk = ~clk;

	
	initial begin
    reset = 1;
    #50;
    reset = 0;
	end
	
	
	initial begin
    out_tready = 1;
 	end
	
	always @(posedge clk) begin 
	
    if (out_tvalid && out_tready) begin
        
        if (out_tuser[0] == 1'b1 && out_tuser[[1] == 1'b0 && !in_frame) begin
            $display("Start of Frame detected. Beginning capture...");
            in_frame    = 1'b1;
            pixel_count = 0;
            line_count  = 0;
        end

        if (in_frame) begin
            
            $fdisplay(video_file, "%06h", out_tdata);
            pixel_count = pixel_count + 1;
            
            if (out_tlast == 1'b1) begin
                
                if (pixel_count != IMG_WIDTH) begin
                    $display("Warning: Line %0d had %0d pixels (Expected %0d)", line_count, pixel_count, IMG_WIDTH);
                end
                
                line_count  = line_count + 1;
                pixel_count = 0; 
                
                if (line_count == IMG_HEIGHT) begin
                    $display("Successfully captured 1 full frame (%0dx%0d).", IMG_WIDTH, IMG_HEIGHT);
                    $fclose(video_file);
                    in_frame = 1'b0; 
                    $stop;           
				end
			end	
		end
	end
	end
	
					
	top dut (
		 .clk(clk),
		 .reset(reset),
		 .m_axis_tdata(out_tdata),
		 .m_axis_tvalid(out_tvalid),
		 .m_axis_tready(out_tready),
		 .m_axis_tlast(out_tlast),
		 .m_axis_tuser(out_tuser)
		 );
endmodule