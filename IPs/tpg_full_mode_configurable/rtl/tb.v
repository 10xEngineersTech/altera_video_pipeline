`timescale 1 ps / 1 ps

module tb();

    // Clock and Reset
    reg clk;
    reg reset;

    // AXI4-Stream Video Output
    wire [23:0] out_tdata;
    wire        out_tvalid;
    wire       out_tready;
    wire        out_tlast;
    wire [2:0]  out_tuser;
	 
	 assign out_tready = (uut.current_state == 4'd13);
	 //assign out_tready = 1'b1;
    // Clock Generation (100 MHz)
    initial begin
        clk = 0;
        forever #5000 clk = ~clk; 
    end

    // Reset Sequence
    initial begin
        reset = 1;
        repeat(256) @(posedge clk);
        reset = 0;
    end

    // --- Monitor Output ---
    // This block tracks when the TPG actually starts sending data
    always @(posedge clk) begin
        if (out_tvalid && out_tready) begin
            $display("[AXI-S] Data received: %h (SOF: %b, EOL: %b)", 
                      out_tdata, out_tuser[0], out_tlast);
        end
    end

    // --- UUT Instantiation ---
    tpg uut (
        .clk        (clk),
        .reset      (reset),
        .out_tdata  (out_tdata),
        .out_tvalid (out_tvalid),
        .out_tready (out_tready),
        .out_tlast  (out_tlast),
        .out_tuser  (out_tuser)
    );

    // --- Simulation Watchdog ---
    initial begin
        // Adjust time based on how long the IP takes to hit a field boundary
        #(20000000); 
        if (!out_tvalid) begin
            $display("FAILURE: TPG did not start streaming within timeout.");
        end else begin
            $display("SUCCESS: TPG is streaming video.");
        end
        $finish;
    end

endmodule
