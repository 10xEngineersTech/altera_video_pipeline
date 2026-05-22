module frame_controller #(
   parameter IMG_H   = 1080,
   parameter IMG_W   = 1920,
   parameter IS_FULL = 1      // 1: Full mode, 0: Lite mode
)(
   input  wire        clk,
   input  wire        reset,
   input  wire [23:0] tdata,
   input  wire        tvalid,
   input  wire        ready,
   input  wire        last,
   input  wire [2:0]  tuser,
   
   output wire         write_flag,
   output reg         frame_done,
	output reg         error
);

   // Internal counters
   reg [15:0] pixel_count; // Horizontal index
   reg [15:0] line_count;  // Vertical index
   wire       first_frame_active;
	reg 			sof;
	 
   // A transaction occurs only when valid and ready are both high
   wire transfer_active;
	assign transfer_active = tvalid && ready;
	 
   // Logic to detect the start of a frame (SOF)
   // In AXI-Stream Video, tuser[0] typically marks the first pixel of a frame
	wire start_of_frame;
	 
	assign start_of_frame = (IS_FULL==1) ? transfer_active && tuser[0] & ~tuser[1] : transfer_active && tuser[0];
	 
	assign first_frame_active = (transfer_active && ~frame_done && (start_of_frame || sof)) ? 1'b1 : 1'b0;
	 
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			pixel_count        <= 0;
         line_count         <= 0;
         frame_done         <= 1'b0;
			sof 					 <= 1'b0;
		end else begin
			error <= 1'b0;
			if(start_of_frame) begin 
				sof <= 1'b1;
				if(~(line_count == 15'b0 && pixel_count == 15'b0))
					error <= 1'b1;
			end
         // Frame and Line Counting Logic
         if (transfer_active) begin
				if(^tdata === 1'bx) begin
					error <= 1'b1;
					pixel_count        <= 0;
					line_count         <= 0;
					frame_done         <= 1'b0;
					sof 					 <= 1'b0;
				end
				if (start_of_frame) begin
					pixel_count        <= 1;
					line_count         <= 0;
				end else begin
					if (last) begin // tlast marks end of a line
						if (line_count < (IMG_H - 1)) begin
							line_count <= line_count + 1;
							pixel_count <= 0;
						end
						else if(line_count == (IMG_H - 1) && pixel_count == (IMG_W - 1))
							frame_done <= 1'b1;
						//else error <= 1'b1;
					end else begin
						pixel_count <= pixel_count + 1;
					end
				end
			end
		end
	end
	 
	 // write_flag Logic
    // High only if: Handshake occurs, within dimensions, 
    // during first frame, and NOT a metapacket (tuser[1] check)
	 assign write_flag = (transfer_active && first_frame_active && !frame_done && (pixel_count < IMG_W)
													  && (line_count < IMG_H) && ~(^tdata === 1'bx)) ? 1'b1 : 1'b0;

endmodule
