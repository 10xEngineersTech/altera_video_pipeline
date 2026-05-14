`timescale 1 ns / 1 ps

module tb();
    `include "../app/configuration.vh"
    localparam IMG_WIDTH      = TPG_WIDTH;
    localparam IMG_HIGHT      = TPG_HEIGHT;
    localparam IMG_COLOR      = 32'd1;
    localparam IMG_CR_SM      = 32'd3;   
    localparam IMG_L_OFF      = CLIPPER_LEFT;
    localparam IMG_T_OFF      = CLIPPER_TOP;
    localparam IMG_R_OFF      = CLIPPER_RIGHT;
    localparam IMG_B_OFF      = CLIPPER_BOTTOM;
    
    localparam SCALER_OUT_W   = SCALER_WIDTH;
    localparam SCALER_OUT_H   = SCALER_HEIGHT;
    
    localparam END_TIME   = (SCALER_HEIGHT * SCALER_WIDTH < TPG_WIDTH * TPG_HEIGHT) ? TPG_WIDTH * TPG_HEIGHT * 100 : SCALER_HEIGHT * SCALER_WIDTH * 100;
	 
    // --- Clock and Reset ---
    reg clk;
    reg reset;

    // --- Output Monitor Signals ---
    // These must match between the DUT and the file writer
    wire [23:0] out_tdata;
    wire        out_tvalid;
    reg         out_tready; // Kept as reg so the initial block can drive it
    wire        out_tlast;
    wire [2:0]  out_tuser;
    
    wire frame_done1,frame_done2;

    // --- Simulation Constants ---
    localparam CLK_PERIOD = 10; // 100MHz
    
    // --- File Writer Sink ---
    make_file #(
        .IMG_H(IMG_HIGHT),
        .IMG_W(IMG_WIDTH),
        .IS_FULL(1),
		  .FILE_NAME("../../../../app/tpg_data.txt")
    ) tpg_out (
        .clk        (clk),
        .reset      (reset),
        
        // WIRED CORRECTLY TO THE DUT OUTPUTS
        .tdata      (dut.tpg_tdata),
        .tvalid     (dut.tpg_tvalid),
        .tready     (dut.tpg_tready), 
        .tlast      (dut.tpg_tlast),
        .tuser      (dut.tpg_tuser),
        
        .frame_done (frame_done1)
    );
	 
	 make_file #(
        .IMG_H(SCALER_OUT_H),
        .IMG_W(SCALER_OUT_W),
        .IS_FULL(0),
		  .FILE_NAME("../../../../app/sc_data.txt")
    ) scaler_out (
        .clk        (clk),
        .reset      (reset),
        
        // WIRED CORRECTLY TO THE DUT OUTPUTS
        .tdata      (out_tdata),
        .tvalid     (out_tvalid),
        .tready     (out_tready), 
        .tlast      (out_tlast),
        .tuser      (out_tuser),
        
        .frame_done (frame_done2)
    );
    
    // --- Instantiate the Top Module ---
    top #(
        .IMG_WIDTH(IMG_WIDTH),      // Smaller sizes for faster simulation
        .IMG_HIGHT(IMG_HIGHT),
		  .IMG_COLOR(IMG_COLOR),
		  .IMG_CR_SM(IMG_CR_SM),
        .IMG_L_OFF(IMG_L_OFF),
        .IMG_R_OFF(IMG_R_OFF),
        .IMG_T_OFF(IMG_T_OFF),
        .IMG_B_OFF(IMG_B_OFF),
        .SCALER_OUT_W(SCALER_OUT_W),
        .SCALER_OUT_H(SCALER_OUT_H)
    ) dut (
        .clk(clk),
        .reset(reset),
        .out_tdata(out_tdata),
        .out_tvalid(out_tvalid),
        .out_tready(out_tready),
        .out_tlast(out_tlast),
        .out_tuser(out_tuser)
    );

    // --- Clock Generation ---
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // --- Stimulus Process ---
    initial begin
        // Initialize
        reset = 1;
        out_tready = 0;
        
        // Hold reset for 10 cycles
        repeat(10) @(posedge clk);
        reset = 0;
        $display("[%0t] Reset de-asserted. Starting Configuration...", $time);

        // Wait for the state machine to reach STATE_WORKING
        // In the real simulation, you'd watch the 'current_state' signal
        wait(dut.current_state == dut.ST_WORKING); // ST_WORKING = 5'd16
        $display("[%0t] Configuration Complete. System is now WORKING.", $time);

        // Turn on the sink (ready to receive video)
        @(posedge clk);
        out_tready = 1;

        // Monitor for the first Start of Frame (tuser[0] usually denotes SOF in Intel VVP)
        wait(out_tvalid && out_tuser[0]);
        $display("[%0t] First Start of Frame (SOF) detected!", $time);

        // Run for a few frames
        repeat(5) begin
            wait(out_tvalid && out_tlast); // End of a line
            @(posedge clk);
        end
        
        $display("[%0t] Captured data segments. Simulation passing.", $time);
        
        // Wait for the file writer to declare it's finished capturing a frame
        wait(frame_done1 && frame_done2);
        $display("[%0t] Frame successfully written to file.", $time);
        $finish;
    end

    // --- Timeout Watchdog ---
    initial begin
        #(END_TIME); // Adjust based on frame size
        $display("Error: Simulation Timeout!");
        $finish;
    end

endmodule
