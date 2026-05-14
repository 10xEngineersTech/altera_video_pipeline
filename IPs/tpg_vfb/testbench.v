`timescale 1ns/1ps

module testbench;

    parameter IMG_WIDTH  = 64;
    parameter IMG_HEIGHT = 64;
    parameter TOTAL_PIX  = IMG_WIDTH * IMG_HEIGHT;

    reg         clk;
    reg         reset;

    // VFB output
    wire [23:0] vfb_out_tdata;
    wire        vfb_out_tvalid;
    reg         vfb_out_tready;
    wire        vfb_out_tlast;
    wire [2:0]  vfb_out_tuser;

    // TPG monitor
    wire [23:0] tpg_mon_tdata;
    wire        tpg_mon_tvalid;
    wire        tpg_mon_tlast;
    wire [2:0]  tpg_mon_tuser;
    wire	tpg_mon_tready;

    // Control agent
    reg  [6:0]  control_agent_address;
    reg         control_agent_write;
    reg  [3:0]  control_agent_byteenable;
    reg  [31:0] control_agent_writedata;
    reg         control_agent_read;
    wire [31:0] control_agent_readdata;
    wire        control_agent_readdatavalid;
    wire        control_agent_waitrequest;

    // DUT ? top module
    top u0 (
        .clk                         (clk),
        .reset                       (reset),
        .vfb_out_tdata               (vfb_out_tdata),
        .vfb_out_tvalid              (vfb_out_tvalid),
        .vfb_out_tready              (vfb_out_tready),
        .vfb_out_tlast               (vfb_out_tlast),
        .vfb_out_tuser               (vfb_out_tuser),
        .tpg_mon_tdata               (tpg_mon_tdata),
        .tpg_mon_tvalid              (tpg_mon_tvalid),
        .tpg_mon_tlast               (tpg_mon_tlast),
        .tpg_mon_tuser               (tpg_mon_tuser),
        .tpg_mon_tready	      (tpg_mon_tready),
        .control_agent_address       (control_agent_address),
        .control_agent_write         (control_agent_write),
        .control_agent_byteenable    (control_agent_byteenable),
        .control_agent_writedata     (control_agent_writedata),
        .control_agent_read          (control_agent_read),
        .control_agent_readdata      (control_agent_readdata),
        .control_agent_readdatavalid (control_agent_readdatavalid),
        .control_agent_waitrequest   (control_agent_waitrequest)
    );

    // Clock
    initial clk = 0;
    always #3.33 clk = ~clk;

    // Tasks
    task write_reg;
        input [6:0]  addr;
        input [31:0] data;
        begin
            @(posedge clk);
            control_agent_address    <= addr;
            control_agent_writedata  <= data;
            control_agent_byteenable <= 4'hF;
            control_agent_write      <= 1'b1;
            @(posedge clk);
            while (control_agent_waitrequest === 1'b1) @(posedge clk);
            control_agent_write <= 1'b0;
            $display("[%0t] WRITE reg[0x%02h] = 0x%08h", $time, addr, data);
        end
    endtask

    task read_reg;
        input [6:0] addr;
        begin
            @(posedge clk);
            control_agent_address    <= addr;
            control_agent_byteenable <= 4'hF;
            control_agent_read       <= 1'b1;
            @(posedge clk);
            while (control_agent_waitrequest === 1'b1) @(posedge clk);
            control_agent_read <= 1'b0;
            @(posedge clk);
            wait (control_agent_readdatavalid === 1'b1);
            $display("[%0t] READ  reg[0x%02h] = 0x%08h", $time, addr, control_agent_readdata);
        end
    endtask

    task wait_for_input;
        integer timeout;
        begin
            timeout = 0;
            $display("[%0t] Waiting for VFB to receive first frame...", $time);
            forever begin
                read_reg(7'h50);
                if (control_agent_readdata[0] === 1'b1) begin
                    $display("[%0t] INPUT_STATUS = 1, VFB is receiving!", $time);
                    disable wait_for_input;
                end
                timeout = timeout + 1;
                if (timeout > 500) begin
                    $display("[%0t] TIMEOUT waiting for INPUT_STATUS!", $time);
                    $stop;
                end
                repeat(200) @(posedge clk);
            end
        end
    endtask

    // TPG capture
    integer tpg_file;
    integer tpg_pix_count;
    integer tpg_frame_count;
    integer tpg_done;

    initial begin
        tpg_file        = $fopen("/home/izaan/tpg_vfb/sim/tpg_output.hex", "w");
        tpg_pix_count   = 0;
        tpg_frame_count = 0;
        tpg_done        = 0;
    end

    always @(posedge clk) begin
        if (!tpg_done && tpg_mon_tvalid && tpg_mon_tready) begin
            if (tpg_mon_tuser[0]) begin
                $display("[%0t] TPG SOF Frame %0d", $time, tpg_frame_count);
                tpg_frame_count = tpg_frame_count + 1;
                tpg_pix_count   = 0;
            end
            if (tpg_frame_count >= 2 &&
                tpg_mon_tuser[1] == 1'b0 &&
                tpg_mon_tuser[0] == 1'b0) begin
                $fdisplay(tpg_file, "%h", tpg_mon_tdata);
                tpg_pix_count = tpg_pix_count + 1;
                if (tpg_pix_count == TOTAL_PIX) begin
                    $display("[%0t] *** TPG FRAME COMPLETE ***", $time);
                    $fclose(tpg_file);
                    tpg_done = 1;
                end
            end
        end
    end

    // VFB capture
    integer vfb_file;
    integer vfb_pix_count;
    integer vfb_frame_count;

    initial begin
        vfb_file        = $fopen("/home/izaan/tpg_vfb/sim/output_frame.hex", "w");
        vfb_pix_count   = 0;
        vfb_frame_count = 0;
    end

    always @(posedge clk) begin
        if (vfb_out_tvalid && vfb_out_tready) begin
            if (vfb_out_tuser[0]) begin
                $display("[%0t] VFB SOF Frame %0d", $time, vfb_frame_count);
                vfb_frame_count = vfb_frame_count + 1;
                vfb_pix_count   = 0;
            end
            if (vfb_frame_count >= 3 &&
                vfb_out_tuser[1] == 1'b0 &&
                vfb_out_tuser[0] == 1'b0) begin
                $fdisplay(vfb_file, "%h", vfb_out_tdata);
                vfb_pix_count = vfb_pix_count + 1;
                if (vfb_pix_count == TOTAL_PIX) begin
                    $display("[%0t] *** VFB FRAME COMPLETE ***", $time);
                    $fclose(vfb_file);
                    $stop;
                end
            end
        end
    end

    // Main stimulus
    initial begin
        reset                    <= 1'b1;
        vfb_out_tready           <= 1'b0;
        control_agent_address    <= 7'h00;
        control_agent_write      <= 1'b0;
        control_agent_read       <= 1'b0;
        control_agent_writedata  <= 32'h0;
        control_agent_byteenable <= 4'hF;

        repeat(300) @(posedge clk);
        reset <= 1'b0;
        $display("[%0t] Reset released", $time);
        repeat(100) @(posedge clk);

        $display("--- VID_PID check (expect 0x6AF70237) ---");
        read_reg(7'h00);

        wait_for_input;

        repeat(500) @(posedge clk);

        $display("--- NUM_INPUT_FIELDS ---");
        read_reg(7'h51);

        $display("--- Enabling VFB output ---");
        write_reg(7'h57, 32'h0000_0001);

        @(posedge clk);
        vfb_out_tready <= 1'b1;
        $display("[%0t] tready asserted", $time);

        #5_000_000;
        $display("[%0t] WATCHDOG timeout.", $time);
        $fclose(vfb_file);
        $fclose(tpg_file);
        $stop;
    end

endmodule
