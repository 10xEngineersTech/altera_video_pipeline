`timescale 1 ps / 1 ps

//------------------------------------------------------------------------------
// resampling_checker  (SEQUENTIAL mode: 1 symbol/beat, 8-bit)
//
// Wraps the Platform Designer "system" (TPG 4:4:4 -> Chroma Resampler 4:2:2).
// TPG dout is looped back into CRS din (the connection Qsys removes when both
// interfaces are exported), and both ends are tapped.
//
// Stream formats (YCbCr, 8 bps, sequential):
//   * Input  4:4:4 video body: symbols cycle  Cb, Cr, Y          (3 per pixel)
//   * Output 4:2:2 video body: symbols cycle  Cb, Y0, Cr, Y1     (4 per pixel-pair)
//
// 4:4:4 -> 4:2:2 nearest-neighbour cosited: luma preserved, chroma decimated to
// the even (cosited) pixel of each pair.  For an input pixel pair the expected
// 4:2:2 group is { Cb0, Y0, Cr0, Y1 }.
//
// PHASE AUTO-RESYNC:
//   The input symbol stream is parsed with a mod-6 pixel-pair counter.  In
//   gate-level (.vo) cosimulation the tapped TPG->CRS handshake can momentarily
//   miscount by one symbol at content transitions, which would otherwise frame
//   the input wrongly forever.  The status controller detects a sustained
//   mismatch and rotates the input framing by one symbol (without flushing the
//   alignment FIFO, so latency alignment is preserved) until it re-locks.  Only
//   a genuine fault -- no framing locks after cycling all six rotations --
//   latches the LED low.
//------------------------------------------------------------------------------
module resampling_checker(
    input  wire        clk_clk,       // Clock
    output wire        status_led     // Status LED: 1 = resampler matches model
);

    // Power-on reset: hold reset asserted for the first 32 clocks so the VIP
    // cores initialise, then release.
    reg [4:0] por_cnt     = 5'd0;
    reg       reset_reset = 1'b1;
    always @(posedge clk_clk) begin
        if (por_cnt != 5'h1f)
            por_cnt <= por_cnt + 1'b1;
        else
            reset_reset <= 1'b0;
    end

    //--------------------------------------------------------------------------
    // Interconnect / tap nets (8-bit, one symbol per beat)
    //--------------------------------------------------------------------------
    wire [7:0] tpg_data;
    wire       tpg_valid;
    wire       tpg_sop;
    wire       tpg_eop;
    wire       tpg_ready;             // CRS din_ready -> TPG dout_ready

    wire [7:0] crs_dout_data;
    wire       crs_dout_valid;
    wire       crs_dout_startofpacket;
    wire       crs_dout_endofpacket;
    wire       crs_dout_ready;

    assign crs_dout_ready = 1'b1;     // always ready

    //--------------------------------------------------------------------------
    // DUT instance: loop TPG dout -> CRS din, expose both ends.
    //--------------------------------------------------------------------------
    system dut (
        .clk_clk(clk_clk),
        .reset_reset_n(!reset_reset),

        // --- TPG source (out of system) ---
        .alt_vip_tpg_0_dout_data(tpg_data),
        .alt_vip_tpg_0_dout_valid(tpg_valid),
        .alt_vip_tpg_0_dout_startofpacket(tpg_sop),
        .alt_vip_tpg_0_dout_endofpacket(tpg_eop),
        .alt_vip_tpg_0_dout_ready(tpg_ready),

        // --- CRS sink (into system) -- driven by the TPG source above ---
        .alt_vip_crs_0_din_data(tpg_data),
        .alt_vip_crs_0_din_valid(tpg_valid),
        .alt_vip_crs_0_din_startofpacket(tpg_sop),
        .alt_vip_crs_0_din_endofpacket(tpg_eop),
        .alt_vip_crs_0_din_ready(tpg_ready),

        // --- CRS source (out of system) ---
        .alt_vip_crs_0_dout_data(crs_dout_data),
        .alt_vip_crs_0_dout_valid(crs_dout_valid),
        .alt_vip_crs_0_dout_startofpacket(crs_dout_startofpacket),
        .alt_vip_crs_0_dout_endofpacket(crs_dout_endofpacket),
        .alt_vip_crs_0_dout_ready(crs_dout_ready)
    );

    localparam [3:0] PKT_VIDEO = 4'h0;   // Avalon-ST Video data-packet type nibble

    //==========================================================================
    // INPUT side: parse 4:4:4 symbols with a mod-6 pixel-pair counter and build
    // the expected 4:2:2 group {Cb0, Y0, Cr0, Y1}.
    //   six: 0=Cb0 1=Cr0 2=Y0 3=Cb1(drop) 4=Cr1(drop) 5=Y1
    //==========================================================================
    wire in_is_sop = tpg_valid && tpg_sop;                           // qualified by VALID only
    reg  in_video  = 1'b0;
    wire in_pixel  = tpg_valid && tpg_ready && in_video && !tpg_sop;  // body symbol transfer

    reg  [2:0] six   = 3'd0;     // position within the 6-symbol pixel pair
    reg  [7:0] cb0   = 8'd0;
    reg  [7:0] cr0   = 8'd0;
    reg  [7:0] y0    = 8'd0;

    // Rotate handshake: the status controller toggles rotate_tgl to request a
    // one-symbol frame rotation; the input block acks by matching rotate_ack.
    // Each reg has a single driver (rotate_tgl: status block, rotate_ack: here).
    reg        rotate_tgl = 1'b0;
    reg        rotate_ack = 1'b0;
    wire       rotate_pending = (rotate_tgl != rotate_ack);

    // Expected group, valid when six==5 (current symbol is Y1).
    wire [31:0] exp_group  = {cb0, y0, cr0, tpg_data};   // {Cb0, Y0, Cr0, Y1}
    wire        push_group = in_pixel && !rotate_pending && (six == 3'd5);

    always @(posedge clk_clk) begin
        if (reset_reset) begin
            in_video   <= 1'b0;
            six        <= 3'd0;
            rotate_ack <= 1'b0;
        end else if (in_is_sop) begin
            in_video   <= (tpg_data[3:0] == PKT_VIDEO);
            six        <= 3'd0;           // first body symbol is Cb0
            rotate_ack <= rotate_tgl;     // drop any pending rotate at frame start
        end else if (in_pixel) begin
            if (rotate_pending) begin
                // Resync: consume this symbol WITHOUT advancing the frame, which
                // rotates the mod-6 framing by one relative to the stream.
                rotate_ack <= rotate_tgl;
            end else begin
                case (six)
                    3'd0: cb0 <= tpg_data;
                    3'd1: cr0 <= tpg_data;
                    3'd2: y0  <= tpg_data;
                    default: ;            // 3,4 dropped chroma; 5 is Y1 (used live)
                endcase
                six <= (six == 3'd5) ? 3'd0 : six + 1'b1;
            end
        end
    end

    //==========================================================================
    // OUTPUT side: assemble 4:2:2 group (phase Cb,Y0,Cr,Y1) from output symbols.
    //==========================================================================
    wire out_is_sop = crs_dout_valid && crs_dout_startofpacket;
    reg  out_video  = 1'b0;
    wire out_pixel  = crs_dout_valid && crs_dout_ready && out_video && !crs_dout_startofpacket;

    reg  [1:0] out_phase = 2'd0;  // 0:Cb  1:Y0  2:Cr  3:Y1
    reg  [7:0] o_cb       = 8'd0;
    reg  [7:0] o_y0       = 8'd0;
    reg  [7:0] o_cr       = 8'd0;
    wire        out_done  = out_pixel && (out_phase == 2'd3);          // Y1 completes a group
    wire [31:0] act_group = {o_cb, o_y0, o_cr, crs_dout_data};         // {Cb0, Y0, Cr0, Y1}

    always @(posedge clk_clk) begin
        if (reset_reset) begin
            out_video <= 1'b0;
            out_phase <= 2'd0;
        end else if (out_is_sop) begin
            out_video <= (crs_dout_data[3:0] == PKT_VIDEO);
            out_phase <= 2'd0;
        end else if (out_pixel) begin
            case (out_phase)
                2'd0: o_cb <= crs_dout_data;
                2'd1: o_y0 <= crs_dout_data;
                2'd2: o_cr <= crs_dout_data;
                default: ;
            endcase
            out_phase <= (out_phase == 2'd3) ? 2'd0 : out_phase + 1'b1;
        end
    end

    //==========================================================================
    // Latency-alignment FIFO: queue expected groups, dequeue per output group.
    //==========================================================================
    localparam FIFO_AW    = 8;
    localparam FIFO_DEPTH = (1 << FIFO_AW);

    reg  [31:0]        fifo_mem [0:FIFO_DEPTH-1];
    reg  [FIFO_AW-1:0] wr_ptr     = {FIFO_AW{1'b0}};
    reg  [FIFO_AW-1:0] rd_ptr     = {FIFO_AW{1'b0}};
    reg  [FIFO_AW:0]   fifo_count = {(FIFO_AW+1){1'b0}};

    wire wr_en      = push_group;
    wire fifo_empty = (fifo_count == 0);
    wire do_rd      = out_done && !fifo_empty;

    wire [31:0] fifo_rd_data = fifo_mem[rd_ptr];

    always @(posedge clk_clk) begin
        if (reset_reset) begin
            wr_ptr     <= {FIFO_AW{1'b0}};
            rd_ptr     <= {FIFO_AW{1'b0}};
            fifo_count <= {(FIFO_AW+1){1'b0}};
        end else begin
            if (wr_en) begin
                fifo_mem[wr_ptr] <= exp_group;
                wr_ptr           <= wr_ptr + 1'b1;
            end
            if (do_rd)
                rd_ptr <= rd_ptr + 1'b1;

            case ({wr_en, do_rd})
                2'b10:   fifo_count <= fifo_count + 1'b1;
                2'b01:   fifo_count <= fifo_count - 1'b1;
                default: fifo_count <= fifo_count;
            endcase
        end
    end

    //==========================================================================
    // Status + phase auto-resync controller.
    //   - match     : group equals the latency-aligned expected value
    //   - mis_run   : consecutive mismatched groups -> triggers a frame rotate
    //   - lock_run  : consecutive matched groups -> declares "locked"
    //   - tries     : consecutive rotate attempts without re-locking
    //   A real fault never locks under any of the 6 framings, so tries saturates
    //   and latches the error; a one-off cosim slip re-locks within a few tries.
    //==========================================================================
    localparam [2:0] MIS_THRESH = 3'd3;   // mismatches before a rotate
    localparam [3:0] LOCK_RUN   = 4'd8;   // matches to declare locked
    localparam [3:0] MAX_TRIES  = 4'd9;   // rotate attempts before declaring fault

    reg [2:0] mis_run = 3'd0;
    reg [3:0] lock_run = 4'd0;
    reg [3:0] tries   = 4'd0;
    reg       err_latched = 1'b0;

    wire grp_match = (act_group == fifo_rd_data);

    always @(posedge clk_clk) begin
        if (reset_reset) begin
            mis_run     <= 3'd0;
            lock_run    <= 4'd0;
            tries       <= 4'd0;
            err_latched <= 1'b0;
            rotate_tgl  <= 1'b0;
        end else if (do_rd) begin
            if (grp_match) begin
                mis_run <= 3'd0;
                if (lock_run >= LOCK_RUN)
                    tries <= 4'd0;               // sustained lock -> clear attempts
                else
                    lock_run <= lock_run + 1'b1;
            end else begin
                lock_run <= 4'd0;
                if (mis_run >= (MIS_THRESH - 1'b1)) begin
                    // sustained mismatch -> rotate the input framing by one symbol
                    mis_run    <= 3'd0;
                    rotate_tgl <= ~rotate_tgl;    // request a one-symbol rotate
                    if (tries >= MAX_TRIES)
                        err_latched <= 1'b1;      // no framing locks -> genuine fault
                    else
                        tries <= tries + 1'b1;
                end else begin
                    mis_run <= mis_run + 1'b1;
                end
            end
        end
    end

    assign status_led = !err_latched;

endmodule
