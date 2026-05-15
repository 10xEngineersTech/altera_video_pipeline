`timescale 1 ps / 1 ps

module tb();
    
	 localparam IMG_WIDTH      = 32'd32;
    localparam IMG_HIGHT      = 32'd32;
	 
	 wire frame_done1,frame_done2;
	 
	 // Clock Period: 100 MHz
    parameter CLK_PERIOD = 10000;

    // Signals
    reg         clk_clk = 0;
    reg         reset_reset = 1;
    
    // Output Interface
    wire [23:0] m_axis_tdata;
    wire        m_axis_tvalid;
    reg         m_axis_tready = 0;
    wire        m_axis_tlast;
    wire [2:0]  m_axis_tuser;

    // Clock Generation
    always #(CLK_PERIOD/2) clk_clk = ~clk_clk;
	 
//	 // --- File Writer Sink ---
//    make_file #(
//        .IMG_H(IMG_HIGHT),
//        .IMG_W(IMG_WIDTH),
//        .IS_FULL(1),
//		  .FILE_NAME("/home/lpt-10xe/Desktop/Internship10x/ColorSpace/python/tpg_data.txt")
//    ) tpg_out (
//        .clk        (clk_clk),
//        .reset      (reset_reset),
//        
//        // WIRED CORRECTLY TO THE DUT OUTPUTS
//        .tdata      (dut.out_tdata),
//        .tvalid     (dut.out_tvalid),
//        .tready     (dut.out_tready), 
//        .tlast      (dut.out_tlast),
//        .tuser      (dut.out_tuser),
//        
//        .frame_done (frame_done1)
//    );
	 
	 make_file #(
        .IMG_H(IMG_HIGHT),
        .IMG_W(IMG_WIDTH),
        .IS_FULL(1),
		  .FILE_NAME("/home/lpt-10xe/Desktop/Internship10x/ColorSpace/python/cs_data.txt")
    ) cs_out (
        .clk        (clk_clk),
        .reset      (reset_reset),
        
        // WIRED CORRECTLY TO THE DUT OUTPUTS
        .tdata      (m_axis_tdata),
        .tvalid     (m_axis_tvalid),
        .tready     (m_axis_tready & (dut.current_state == dut.ST_OPERATIONAL)), 
        .tlast      (m_axis_tlast),
        .tuser      (m_axis_tuser),
        
        .frame_done (frame_done2)
    );

    // DUT Instance
    top #(2)dut (
        .clk_clk                              (clk_clk),
        .reset_reset                          (reset_reset),
        // Monitored Output (RGB)
        .out_tdata  (m_axis_tdata),
        .out_tvalid (m_axis_tvalid),
        .out_tready (m_axis_tready),
        .out_tlast  (m_axis_tlast),
        .out_tuser  (m_axis_tuser)
    );

    // Initial Stimulus
    initial begin
        $display("--- Starting Color Space Conversion Simulation ---");
        
        // 1. Reset Sequence
        reset_reset = 1;
        repeat (20) @(posedge clk_clk);
        reset_reset = 0;
        $display("Reset de-asserted at %t", $time);
		  
        repeat (100) @(posedge clk_clk);
		  
        m_axis_tready = 1;
        $display("Downstream Ready asserted. Monitoring output pixels...");
		  
		  wait(frame_done2);
		  repeat (5) @(posedge clk_clk);

        $display("Simulation complete.");
        $finish;
    end
	 
    always @(posedge clk_clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $display("Time: %t | RGB Out: %h | SOF: %b | LAST: %b", 
                     $time, m_axis_tdata, m_axis_tuser[0], m_axis_tlast);
        end
    end

endmodule