`timescale 1 ps / 1 ps

module tpg (
    input  wire        clk,
    input  wire        reset,

    // AXI4-Stream Video Output
    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser
);

    // -------------------------------------------------------------------------
    // State Encoding
    // -------------------------------------------------------------------------
    localparam [3:0]
        ST_IDLE          = 4'd0,
        ST_CONTROL_1     = 4'd1,
        ST_WR_INTERLACED = 4'd2,
        ST_WR_WIDTH      = 4'd3,
        ST_WR_HEIGHT     = 4'd4,
        ST_WR_PAT_TYPE   = 4'd5,
        ST_WR_PAT_SEL    = 4'd6,
        ST_WR_COMMIT     = 4'd7,
        ST_CONTROL_2     = 4'd8,
        ST_POLL_ISSUE    = 4'd9,
        ST_POLL_WAIT     = 4'd10,
        ST_IP_RESET      = 4'd11,
        ST_CONTROL_3     = 4'd12,
        ST_OPERATIONAL   = 4'd13;

    // Register word addresses (byte addr >> 2)
    localparam [8:0] ADDR_WIDTH     = 9'h48;   // 0x0120 >> 2
    localparam [8:0] ADDR_HEIGHT    = 9'h49;   // 0x0124 >> 2
    localparam [8:0] ADDR_INTERLACE = 9'h4A;   // 0x0128 >> 2
    localparam [8:0] ADDR_STATUS    = 9'h50;   // 0x0140 >> 2
    localparam [8:0] ADDR_CONTROL   = 9'h52;   // 0x0148 >> 2
    localparam [8:0] ADDR_COMMIT    = 9'h53;   // 0x014C >> 2
    localparam [8:0] ADDR_PATTERN   = 9'h54;   // 0x0150 >> 2
    localparam [8:0] ADDR_BAR_SEL   = 9'h5A;   // 0x0168 >> 2

    // Internal Registers
    reg [3:0]  current_state; // Removed duplicate definition
    reg [8:0]  addr;
    reg        write, read;
    reg [31:0] wdata;
    reg [7:0]  cycle_count;
    reg        ip_reset;

    // Signals from DUT
    wire [31:0] readdata;
    wire        readdatavalid;
    wire        twait;

    // -------------------------------------------------------------------------
    // Control State Machine
    // -------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            write         <= 1'b0;
            read          <= 1'b0;
            addr          <= 9'h0;
            wdata         <= 32'h0;
            ip_reset      <= 1'b0;
            cycle_count   <= 8'b0;
        end else begin
            // Default: keep outputs active unless we transition (Avalon-MM protocol)
            case (current_state)

                ST_IDLE: begin
                    current_state <= ST_CONTROL_1;
                end

                ST_CONTROL_1: begin
                    write <= 1'b1;
                    addr  <= ADDR_CONTROL;
                    wdata <= 32'h0;
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_WR_INTERLACED;
                    end
                end

                ST_WR_INTERLACED: begin
                    write <= 1'b1;
                    addr  <= ADDR_INTERLACE;
                    wdata <= 32'h0;
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_WR_WIDTH;
                    end
                end

                ST_WR_WIDTH: begin
                    write <= 1'b1;
                    addr  <= ADDR_WIDTH;
                    wdata <= 32'd32; 
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_WR_HEIGHT;
                    end
                end

                ST_WR_HEIGHT: begin
                    write <= 1'b1;
                    addr  <= ADDR_HEIGHT;
                    wdata <= 32'd32;
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_WR_PAT_TYPE;
                    end
                end

                ST_WR_PAT_TYPE: begin
                    write <= 1'b1;
                    addr  <= ADDR_BAR_SEL;
                    wdata <= 32'h0; // Color Bars
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_WR_PAT_SEL;
                    end
                end

                ST_WR_PAT_SEL: begin
                    write <= 1'b1;
                    addr  <= ADDR_PATTERN;
                    wdata <= 32'd0;
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_WR_COMMIT;
                    end
                end

                ST_WR_COMMIT: begin
                    write <= 1'b1;
                    addr  <= ADDR_COMMIT;
                    wdata <= 32'h1;
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_CONTROL_2;
                    end
                end

                ST_CONTROL_2: begin
                    write <= 1'b1;
                    addr  <= ADDR_CONTROL;
                    wdata <= 32'h1; // Enable
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_POLL_ISSUE;
                    end
                end

                ST_POLL_ISSUE: begin
                    read <= 1'b1;
                    addr <= ADDR_STATUS;
                    if (!twait) begin
                        read <= 1'b0;
                        current_state <= ST_POLL_WAIT;
                    end
                end

                ST_POLL_WAIT: begin
                    if (readdatavalid) begin
                        if (readdata[1] == 1'b0)
                            current_state <= ST_IP_RESET;
                        else
                            current_state <= ST_POLL_ISSUE;
                    end
                end

                ST_IP_RESET: begin
                    ip_reset <= 1'b1;
                    cycle_count <= cycle_count + 1'b1;
                    if (cycle_count == 8'h07) begin
                        current_state <= ST_CONTROL_3;
                    end
                end

                ST_CONTROL_3: begin
                    ip_reset <= 1'b0;
                    write <= 1'b1;
                    addr  <= ADDR_CONTROL;
                    wdata <= 32'h1;
                    if (!twait) begin
                        write <= 1'b0;
                        current_state <= ST_OPERATIONAL;
                    end
                end

                ST_OPERATIONAL: begin
                    write <= 1'b0;
                    read  <= 1'b0;
                end

                default: current_state <= ST_IDLE;
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------------------------------
    tpg_ip dut (
        .clk_clk                                           (clk),
        .reset_reset                                       (reset),
        .intel_vvp_tpg_0_axi4s_vid_out_tdata               (out_tdata),
        .intel_vvp_tpg_0_axi4s_vid_out_tvalid              (out_tvalid),
        .intel_vvp_tpg_0_axi4s_vid_out_tready              (out_tready),
        .intel_vvp_tpg_0_axi4s_vid_out_tlast               (out_tlast),
        .intel_vvp_tpg_0_axi4s_vid_out_tuser               (out_tuser),
        .intel_vvp_tpg_0_av_mm_control_agent_address       (addr),
        .intel_vvp_tpg_0_av_mm_control_agent_write         (write),
        .intel_vvp_tpg_0_av_mm_control_agent_read          (read),
        .intel_vvp_tpg_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_0_av_mm_control_agent_writedata     (wdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdata      (readdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdatavalid (readdatavalid),
        .intel_vvp_tpg_0_av_mm_control_agent_waitrequest   (twait)
    );

endmodule
