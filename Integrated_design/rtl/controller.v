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
    wire        first_frame_active;
	 reg 			 sof;
	 
    // A transaction occurs only when valid and ready are both high.
    wire raw_beat;
    assign raw_beat = tvalid && ready;

    // In full mode, metadata packets (image info) are interleaved in-band.
    // tuser[1] is set on the FIRST beat of a metadata packet only; the packet
    // spans multiple beats and terminates with its own tlast. Track packet
    // boundaries so every metadata beat is excluded from counters and capture.
    reg mid_packet;   // between first beat and tlast of any packet
    reg in_meta;      // current packet is a metadata packet

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mid_packet <= 1'b0;
            in_meta    <= 1'b0;
        end else if (raw_beat) begin
            if (!mid_packet) begin
                // First beat of a new packet: classify it
                in_meta    <= (IS_FULL==1) && tuser[1];
                mid_packet <= !last;   // single-beat packet ends immediately
            end else if (last) begin
                mid_packet <= 1'b0;
                in_meta    <= 1'b0;
            end
        end
    end

    wire meta_beat;
    assign meta_beat = (IS_FULL==1) &&
                       (mid_packet ? in_meta : tuser[1]);

    wire transfer_active;
	 assign transfer_active = raw_beat && !meta_beat;
	 
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
            if(start_of_frame && !frame_done) begin
					sof <= 1'b1;
					if(~(line_count == 15'b0 && pixel_count == 15'b0))
						error <= 1'b1;
				end
            // Frame and Line Counting Logic (freeze once the frame is captured
            // so subsequent frames can't retrigger the error/recovery path)
            if (transfer_active && !frame_done) begin
                
                if (start_of_frame) begin
                    pixel_count        <= 1;
                    line_count         <= 0;
                end else begin
                    if (last) begin // tlast marks end of a line
                        pixel_count <= 0;
                        if (line_count < (IMG_H - 1))
                            line_count <= line_count + 1;
                        else begin if(line_count == (IMG_H - 1) && pixel_count == (IMG_W - 1))
									frame_done <= 1'b1;
								else
									error <= 1'b1;
                        end
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
	 assign write_flag = (transfer_active && first_frame_active 
	&& !frame_done && (pixel_count < IMG_W) && (line_count < IMG_H)) ? 1'b1 : 1'b0;

endmodule
