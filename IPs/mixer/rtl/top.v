`timescale 1 ps / 1 ps

// =============================================================================
// top.v  —  Mixer demo top-level controller
//
// Topology (inside system.qsys):
//   intel_vvp_tpg_0 (color bars)    → mixer axi4s_vid_0_in (base layer)
//   intel_vvp_tpg_1 (uniform color) → mixer axi4s_vid_1_in (layer 1)
//   mixer axi4s_vid_out             → exported to tb for hex capture
//
// The three Avalon-MM control agents are exported; this module configures
// them with a single FSM:
//   1. Mixer   — layer 1: enable, opaque, (FG_H_OFF, FG_V_OFF), commit
//   2. TPG 1   — overlay: FG_WIDTH×FG_HEIGHT uniform color (FG_R,FG_G,FG_B)
//   3. TPG 0   — base:    BG_WIDTH×BG_HEIGHT color bars
//   4. WORKING — mixer output streams, base-size frames with overlay inset
//
// Each TPG uses the sequence proven in Integrated_design/rtl/top.v:
// CONTROL=0, config regs, COMMIT, CONTROL=1, poll STATUS.pending_commit,
// short gap, CONTROL=1 again. The base TPG is enabled LAST so the overlay
// layer is already streaming when the first base frame starts, guaranteeing
// the overlay is present in the very first output frame.
// =============================================================================

module top #(
    // Base layer (background, TPG0 — color bars)
    parameter [31:0] BG_WIDTH  = 32'd64,
    parameter [31:0] BG_HEIGHT = 32'd64,

    // Overlay layer (foreground, TPG1 — uniform color)
    parameter [31:0] FG_WIDTH  = 32'd32,
    parameter [31:0] FG_HEIGHT = 32'd32,
    parameter [31:0] FG_H_OFF  = 32'd16,
    parameter [31:0] FG_V_OFF  = 32'd16,
    parameter [31:0] FG_R      = 32'd255,
    parameter [31:0] FG_G      = 32'd0,
    parameter [31:0] FG_B      = 32'd0
)(
    input  wire        clk,
    input  wire        reset,

    // Mixer AXI4-S video output
    output wire [23:0] out_tdata,
    output wire        out_tvalid,
    input  wire        out_tready,
    output wire        out_tlast,
    output wire [2:0]  out_tuser
);

    // =========================================================================
    // TPG register word addresses (UG-20344 / intel_vvp_tpg_regs.h)
    // =========================================================================
    localparam [6:0] TPG_ADDR_WIDTH     = 7'h48;
    localparam [6:0] TPG_ADDR_HEIGHT    = 7'h49;
    localparam [6:0] TPG_ADDR_INTERLACE = 7'h4A;
    localparam [6:0] TPG_ADDR_STATUS    = 7'h50;
    localparam [6:0] TPG_ADDR_CONTROL   = 7'h52;
    localparam [6:0] TPG_ADDR_COMMIT    = 7'h53;
    localparam [6:0] TPG_ADDR_PATTERN   = 7'h54;
    localparam [6:0] TPG_ADDR_C0        = 7'h57;   // B (or Cb)
    localparam [6:0] TPG_ADDR_C1        = 7'h58;   // G (or Y)
    localparam [6:0] TPG_ADDR_C2        = 7'h59;   // R (or Cr)
    localparam [6:0] TPG_ADDR_BAR_SEL   = 7'h5A;

    // =========================================================================
    // Mixer register word addresses (intel_vvp_mixer_regs.h)
    //   STATUS = RT+0 = 0x50, COMMIT = RT+1 = 0x51, layer1 base = RT+2 = 0x52
    // =========================================================================
    localparam [7:0] MIX_ADDR_STATUS       = 8'h50;
    localparam [7:0] MIX_ADDR_COMMIT       = 8'h51;
    localparam [7:0] MIX_ADDR_L1_MODE      = 8'h52;   // bit0 = enable
    localparam [7:0] MIX_ADDR_L1_BLEND     = 8'h53;   // 0=transparent 1=opaque
    localparam [7:0] MIX_ADDR_L1_ALPHA     = 8'h54;
    localparam [7:0] MIX_ADDR_L1_H_OFFSET  = 8'h55;
    localparam [7:0] MIX_ADDR_L1_V_OFFSET  = 8'h56;

    // =========================================================================
    // State encoding
    // =========================================================================
    localparam [3:0]
        ST_IDLE       = 4'd0,
        ST_CFG_MIXER  = 4'd1,   // layer regs + commit
        ST_CFG_TPG    = 4'd2,   // write sequence for the selected TPG
        ST_TPG_POLL_I = 4'd3,   // issue STATUS read
        ST_TPG_POLL_W = 4'd4,   // wait for readdata, check pending-commit
        ST_TPG_GAP    = 4'd5,   // few idle cycles
        ST_TPG_GO     = 4'd6,   // re-write CONTROL=1
        ST_WORKING    = 4'd7;

    reg [3:0] current_state;
    reg [3:0] cfg_step;
    reg [7:0] cycle_count;
    reg       tpg_sel;          // 0: configuring TPG1 (overlay), 1: TPG0 (base)

    // =========================================================================
    // Control buses
    // =========================================================================
    reg  [6:0]  tpg_addr;  reg tpg_write, tpg_read;  reg [31:0] tpg_wdata;
    reg  [7:0]  mix_addr;  reg mix_write;            reg [31:0] mix_wdata;

    // Per-TPG demux: drive the selected TPG's agent, idle the other one.
    // (tpg_sel==0 → TPG1 overlay first, tpg_sel==1 → TPG0 base last)
    wire tpg0_write = tpg_sel ? tpg_write : 1'b0;
    wire tpg0_read  = tpg_sel ? tpg_read  : 1'b0;
    wire tpg1_write = tpg_sel ? 1'b0 : tpg_write;
    wire tpg1_read  = tpg_sel ? 1'b0 : tpg_read;

    wire [31:0] tpg0_readdata,      tpg1_readdata;
    wire        tpg0_readdatavalid, tpg1_readdatavalid;
    wire        tpg0_wait,          tpg1_wait;
    wire        mix_wait;

    wire [31:0] tpg_readdata      = tpg_sel ? tpg0_readdata      : tpg1_readdata;
    wire        tpg_readdatavalid = tpg_sel ? tpg0_readdatavalid : tpg1_readdatavalid;
    wire        tpg_wait          = tpg_sel ? tpg0_wait          : tpg1_wait;

    // Per-TPG configuration values
    wire [31:0] cfg_width   = tpg_sel ? BG_WIDTH  : FG_WIDTH;
    wire [31:0] cfg_height  = tpg_sel ? BG_HEIGHT : FG_HEIGHT;

    // =========================================================================
    // Configuration state machine
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            cfg_step      <= 4'd0;
            cycle_count   <= 8'd0;
            tpg_sel       <= 1'b0;
            tpg_write     <= 1'b0;
            tpg_read      <= 1'b0;
            mix_write     <= 1'b0;
        end else begin
            case (current_state)

                ST_IDLE: begin
                    cfg_step      <= 4'd0;
                    current_state <= ST_CFG_MIXER;
                end

                // ══════════════════════════════════════════════════════════
                // Mixer layer 1 setup, then commit
                // ══════════════════════════════════════════════════════════
                // Avalon-MM rule: addr/data must be stable while waitrequest=1.
                // On acceptance, write deasserts for one cycle while cfg_step
                // advances and the next addr/data load, so controls never
                // change during a pending transaction.
                ST_CFG_MIXER: begin
                    case (cfg_step)
                        4'd0: begin mix_addr <= MIX_ADDR_L1_MODE;     mix_wdata <= 32'h1;      end
                        4'd1: begin mix_addr <= MIX_ADDR_L1_BLEND;    mix_wdata <= 32'h1;      end
                        4'd2: begin mix_addr <= MIX_ADDR_L1_ALPHA;    mix_wdata <= 32'd255;    end
                        4'd3: begin mix_addr <= MIX_ADDR_L1_H_OFFSET; mix_wdata <= FG_H_OFF;   end
                        4'd4: begin mix_addr <= MIX_ADDR_L1_V_OFFSET; mix_wdata <= FG_V_OFF;   end
                        4'd5: begin mix_addr <= MIX_ADDR_COMMIT;      mix_wdata <= 32'h1;      end
                        default: ;
                    endcase
                    if (mix_write && !mix_wait) begin
                        mix_write <= 1'b0;
                        if (cfg_step == 4'd5) begin
                            cfg_step      <= 4'd0;
                            tpg_sel       <= 1'b0;      // overlay TPG first
                            current_state <= ST_CFG_TPG;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                        end
                    end else begin
                        mix_write <= 1'b1;
                    end
                end

                // ══════════════════════════════════════════════════════════
                // TPG write sequence (runs twice: TPG1 overlay, then TPG0 base)
                // ══════════════════════════════════════════════════════════
                ST_CFG_TPG: begin
                    case (cfg_step)
                        4'd0:  begin tpg_addr <= TPG_ADDR_CONTROL;   tpg_wdata <= 32'h0;      end
                        4'd1:  begin tpg_addr <= TPG_ADDR_INTERLACE; tpg_wdata <= 32'h0;      end
                        4'd2:  begin tpg_addr <= TPG_ADDR_WIDTH;     tpg_wdata <= cfg_width;  end
                        4'd3:  begin tpg_addr <= TPG_ADDR_HEIGHT;    tpg_wdata <= cfg_height; end
                        4'd4:  begin tpg_addr <= TPG_ADDR_BAR_SEL;   tpg_wdata <= 32'h0;      end
                        4'd5:  begin tpg_addr <= TPG_ADDR_PATTERN;   tpg_wdata <= 32'h0;      end
                        4'd6:  begin tpg_addr <= TPG_ADDR_C0;        tpg_wdata <= FG_B;       end
                        4'd7:  begin tpg_addr <= TPG_ADDR_C1;        tpg_wdata <= FG_G;       end
                        4'd8:  begin tpg_addr <= TPG_ADDR_C2;        tpg_wdata <= FG_R;       end
                        4'd9:  begin tpg_addr <= TPG_ADDR_COMMIT;    tpg_wdata <= 32'h1;      end
                        4'd10: begin tpg_addr <= TPG_ADDR_CONTROL;   tpg_wdata <= 32'h1;      end
                        default: ;
                    endcase
                    if (tpg_write && !tpg_wait) begin
                        tpg_write <= 1'b0;
                        if (cfg_step == 4'd10) begin
                            cfg_step      <= 4'd0;
                            current_state <= ST_TPG_POLL_I;
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                        end
                    end else begin
                        tpg_write <= 1'b1;
                    end
                end

                ST_TPG_POLL_I: begin
                    tpg_read <= 1'b1;
                    tpg_addr <= TPG_ADDR_STATUS;
                    if (tpg_read && !tpg_wait) begin
                        tpg_read      <= 1'b0;
                        current_state <= ST_TPG_POLL_W;
                    end
                end

                ST_TPG_POLL_W: begin
                    if (tpg_readdatavalid) begin
                        if (tpg_readdata[1] == 1'b0) begin
                            cycle_count   <= 8'd0;
                            current_state <= ST_TPG_GAP;
                        end else begin
                            current_state <= ST_TPG_POLL_I;
                        end
                    end
                end

                ST_TPG_GAP: begin
                    cycle_count <= cycle_count + 1'b1;
                    if (cycle_count == 8'h07)
                        current_state <= ST_TPG_GO;
                end

                ST_TPG_GO: begin
                    tpg_write <= 1'b1;
                    tpg_addr  <= TPG_ADDR_CONTROL;
                    tpg_wdata <= 32'h1;
                    if (tpg_write && !tpg_wait) begin
                        tpg_write <= 1'b0;
                        cfg_step  <= 4'd0;
                        if (tpg_sel == 1'b0) begin
                            tpg_sel       <= 1'b1;       // now the base TPG
                            current_state <= ST_CFG_TPG;
                        end else begin
                            current_state <= ST_WORKING;
                        end
                    end
                end

                // ══════════════════════════════════════════════════════════
                // All IPs configured — mixer output streaming
                // ══════════════════════════════════════════════════════════
                ST_WORKING: begin
                    tpg_write <= 1'b0;
                    tpg_read  <= 1'b0;
                    mix_write <= 1'b0;
                end

                default: current_state <= ST_IDLE;
            endcase
        end
    end

    // =========================================================================
    // Qsys system instantiation
    // =========================================================================
    system u_system (
        .clk_clk     (clk),
        .reset_reset (reset),

        // ----- Mixer AXI4-S video output -----
        .intel_vvp_mixer_0_axi4s_vid_out_tdata  (out_tdata),
        .intel_vvp_mixer_0_axi4s_vid_out_tvalid (out_tvalid),
        .intel_vvp_mixer_0_axi4s_vid_out_tready (out_tready),
        .intel_vvp_mixer_0_axi4s_vid_out_tlast  (out_tlast),
        .intel_vvp_mixer_0_axi4s_vid_out_tuser  (out_tuser),

        // ----- Mixer Avalon-MM control -----
        .intel_vvp_mixer_0_av_mm_control_agent_address       (mix_addr),
        .intel_vvp_mixer_0_av_mm_control_agent_write         (mix_write),
        .intel_vvp_mixer_0_av_mm_control_agent_read          (1'b0),
        .intel_vvp_mixer_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_mixer_0_av_mm_control_agent_writedata     (mix_wdata),
        .intel_vvp_mixer_0_av_mm_control_agent_readdata      (),
        .intel_vvp_mixer_0_av_mm_control_agent_readdatavalid (),
        .intel_vvp_mixer_0_av_mm_control_agent_waitrequest   (mix_wait),

        // ----- TPG0 (base, color bars) Avalon-MM control -----
        .intel_vvp_tpg_0_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_0_av_mm_control_agent_write         (tpg0_write),
        .intel_vvp_tpg_0_av_mm_control_agent_read          (tpg0_read),
        .intel_vvp_tpg_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_0_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdata      (tpg0_readdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdatavalid (tpg0_readdatavalid),
        .intel_vvp_tpg_0_av_mm_control_agent_waitrequest   (tpg0_wait),

        // ----- TPG1 (overlay, uniform color) Avalon-MM control -----
        .intel_vvp_tpg_1_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_1_av_mm_control_agent_write         (tpg1_write),
        .intel_vvp_tpg_1_av_mm_control_agent_read          (tpg1_read),
        .intel_vvp_tpg_1_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_1_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_1_av_mm_control_agent_readdata      (tpg1_readdata),
        .intel_vvp_tpg_1_av_mm_control_agent_readdatavalid (tpg1_readdatavalid),
        .intel_vvp_tpg_1_av_mm_control_agent_waitrequest   (tpg1_wait)
    );

endmodule
