`timescale 1 ps / 1 ps

module resampling_checker(
    input  wire        clk_clk,       // Clock
    input  wire        reset_reset,   // Reset
    output wire        status_led     // Status LED
);

    // ----- AXIS output from CRS -----
    wire [47:0] alt_vip_cl_crs_0_dout_data;
    wire        alt_vip_cl_crs_0_dout_valid;
    wire        alt_vip_cl_crs_0_dout_startofpacket;
    wire        alt_vip_cl_crs_0_dout_endofpacket;
    wire [2:0]  alt_vip_cl_crs_0_dout_empty;
    wire        alt_vip_cl_crs_0_dout_ready;

    assign alt_vip_cl_crs_0_dout_ready = 1'b1; // always ready

    // ----- DUT instance -----
    system dut (
        .alt_vip_cl_crs_0_dout_data(alt_vip_cl_crs_0_dout_data),
        .alt_vip_cl_crs_0_dout_valid(alt_vip_cl_crs_0_dout_valid),
        .alt_vip_cl_crs_0_dout_startofpacket(alt_vip_cl_crs_0_dout_startofpacket),
        .alt_vip_cl_crs_0_dout_endofpacket(alt_vip_cl_crs_0_dout_endofpacket),
        .alt_vip_cl_crs_0_dout_empty(alt_vip_cl_crs_0_dout_empty),
        .alt_vip_cl_crs_0_dout_ready(alt_vip_cl_crs_0_dout_ready),
        .clk_clk(clk_clk),
        .reset_reset(reset_reset)
    );

    // ----- AXIS input from TPG -----
    wire [31:0] in_tdata;
    wire        in_valid;

    assign in_tdata  = dut.alt_vip_cl_tpg_0_dout_data;
    assign in_valid  = dut.alt_vip_cl_tpg_0_dout_valid;

    // ----- Stage register -----
    reg [47:0] first_stage0 = 32'b0;

 reg [31:0] sec_stage0 = 32'b0;

    always @(posedge clk_clk) begin
        if (reset_reset) begin
            first_stage0 <= 32'b0;
        end else if (in_valid) begin
            // Update stage with lower 32 bits of CRS data
            if (first_stage0 != alt_vip_cl_crs_0_dout_data[47:0]) begin
                first_stage0 <= alt_vip_cl_crs_0_dout_data[47:0];

		sec_stage0<=in_tdata;
            end
        end
    end


wire [47:0] cont_data; 

assign cont_data = {sec_stage0[31:24], sec_stage0[23:16], sec_stage0[7:0],
                    sec_stage0[31:24], sec_stage0[23:16], sec_stage0[7:0]};

    // ----- Status LED logic -----
    // Example: compare CRS 48-bit output with a repeated pattern from stage register
    assign status_led = (alt_vip_cl_crs_0_dout_data == cont_data);

endmodule
