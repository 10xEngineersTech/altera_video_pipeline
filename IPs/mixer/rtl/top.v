`timescale 1 ps / 1 ps

// =============================================================================
// top.v  —  Mixer demo top-level controller (8 TPG sources)
//
// Topology (inside system.qsys):
//   intel_vvp_tpg_0 (color bars)      → mixer axi4s_vid_0_in (base layer)
//   intel_vvp_tpg_1..7 (uniform color)→ mixer axi4s_vid_1..7_in (layers 1..7)
//   mixer axi4s_vid_out               → exported to tb for hex capture
//
// The nine Avalon-MM control agents are exported; this module configures
// them with a single FSM:
//   1. Mixer   — layers 1..7: enable, opaque, offsets; single commit
//   2. TPG 1..7— overlays: FG_WIDTH×FG_HEIGHT uniform color, one per layer,
//                placed on a diagonal with FG_STEP spacing (layer 7 on top)
//   3. TPG 0   — base:    BG_WIDTH×BG_HEIGHT color bars
//   4. WORKING — mixer output streams, base-size frames with overlays inset
//
// Mixer register map (intel_vvp_mixer_regs.h): STATUS = 0x50, COMMIT = 0x51,
// layer N (1..7) base = 0x52 + 7*(N-1); regs at base+0..4 are
// MODE, BLEND_MODE, STATIC_ALPHA, H_OFFSET, V_OFFSET.
//
// Each TPG uses the sequence proven in Integrated_design/rtl/top.v:
// CONTROL=0, config regs, COMMIT, CONTROL=1, poll STATUS.pending_commit,
// short gap, CONTROL=1 again. The base TPG is enabled LAST so all overlay
// layers are already streaming when the first base frame starts, guaranteeing
// every overlay is present in the very first output frame.
// =============================================================================

module top #(
    // Base layer (background, TPG0 — color bars)
    parameter [31:0] BG_WIDTH  = 32'd1280,
    parameter [31:0] BG_HEIGHT = 32'd720,

    // Overlay layers (foreground, TPG1..7 — uniform color, fixed palette).
    // Overlay N is placed at ((N-1)*FG_STEP, (N-1)*FG_STEP).
    parameter [31:0] FG_WIDTH  = 32'd180,
    parameter [31:0] FG_HEIGHT = 32'd180,
    parameter [31:0] FG_STEP   = 32'd90
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
    //   STATUS = RT+0 = 0x50, COMMIT = RT+1 = 0x51,
    //   layer N base = 0x52 + 7*(N-1), N in 1..7
    // =========================================================================
    localparam [7:0] MIX_ADDR_COMMIT      = 8'h51;
    localparam [7:0] MIX_ADDR_LAYERS_BASE = 8'h52;
    localparam [7:0] MIX_LAYER_NUM_REGS   = 8'd7;
    // Offsets within a layer's register block
    localparam [2:0] MIX_OFS_MODE     = 3'd0;   // bit0 = enable
    localparam [2:0] MIX_OFS_BLEND    = 3'd1;   // 0=transparent 1=opaque
    localparam [2:0] MIX_OFS_ALPHA    = 3'd2;
    localparam [2:0] MIX_OFS_H_OFFSET = 3'd3;
    localparam [2:0] MIX_OFS_V_OFFSET = 3'd4;

    // =========================================================================
    // Overlay palette: {R, G, B} for layers 1..7
    // =========================================================================
    function [23:0] overlay_rgb;
        input [2:0] idx;
        case (idx)
            3'd1:    overlay_rgb = 24'hFF0000;   // red
            3'd2:    overlay_rgb = 24'h00FF00;   // green
            3'd3:    overlay_rgb = 24'h0000FF;   // blue
            3'd4:    overlay_rgb = 24'hFFFF00;   // yellow
            3'd5:    overlay_rgb = 24'h00FFFF;   // cyan
            3'd6:    overlay_rgb = 24'hFF00FF;   // magenta
            default: overlay_rgb = 24'hFFFFFF;   // white (layer 7)
        endcase
    endfunction

    // =========================================================================
    // State encoding
    // =========================================================================
    localparam [3:0]
        ST_IDLE       = 4'd0,
        ST_CFG_MIXER  = 4'd1,   // layer regs for layers 1..7
        ST_MIX_COMMIT = 4'd2,   // single commit after all layers
        ST_CFG_TPG    = 4'd3,   // write sequence for the selected TPG
        ST_TPG_POLL_I = 4'd4,   // issue STATUS read
        ST_TPG_POLL_W = 4'd5,   // wait for readdata, check pending-commit
        ST_TPG_GAP    = 4'd6,   // few idle cycles
        ST_TPG_GO     = 4'd7,   // re-write CONTROL=1
        ST_WORKING    = 4'd8;

    reg [3:0] current_state;
    reg [3:0] cfg_step;
    reg [7:0] cycle_count;
    reg [2:0] layer_idx;        // mixer layer being configured (1..7)
    reg [2:0] tpg_sel;          // TPG being configured: 1..7 overlays, then 0 base

    // =========================================================================
    // Control buses
    // =========================================================================
    reg  [6:0]  tpg_addr;  reg tpg_write, tpg_read;  reg [31:0] tpg_wdata;
    reg  [7:0]  mix_addr;  reg mix_write;            reg [31:0] mix_wdata;

    // Per-TPG demux: drive the selected TPG's agent, idle the others.
    wire [7:0] tpg_write_v, tpg_read_v;
    genvar g;
    generate
        for (g = 0; g < 8; g = g + 1) begin : tpg_demux
            assign tpg_write_v[g] = (tpg_sel == g[2:0]) ? tpg_write : 1'b0;
            assign tpg_read_v[g]  = (tpg_sel == g[2:0]) ? tpg_read  : 1'b0;
        end
    endgenerate

    wire [31:0] tpg_readdata_v      [0:7];
    wire [7:0]  tpg_readdatavalid_v;
    wire [7:0]  tpg_wait_v;
    wire        mix_wait;

    wire [31:0] tpg_readdata      = tpg_readdata_v[tpg_sel];
    wire        tpg_readdatavalid = tpg_readdatavalid_v[tpg_sel];
    wire        tpg_wait          = tpg_wait_v[tpg_sel];

    // Per-TPG configuration values (TPG0 = base, others = fixed-size overlays)
    wire        is_base    = (tpg_sel == 3'd0);
    wire [31:0] cfg_width  = is_base ? BG_WIDTH  : FG_WIDTH;
    wire [31:0] cfg_height = is_base ? BG_HEIGHT : FG_HEIGHT;
    wire [23:0] cfg_rgb    = overlay_rgb(tpg_sel);

    // Mixer per-layer values: layer N at ((N-1)*FG_STEP, (N-1)*FG_STEP)
    wire [7:0]  mix_layer_base = MIX_ADDR_LAYERS_BASE
                               + ({5'd0, layer_idx} - 8'd1) * MIX_LAYER_NUM_REGS;
    wire [31:0] layer_off      = ({29'd0, layer_idx} - 32'd1) * FG_STEP;

    // =========================================================================
    // Configuration state machine
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            cfg_step      <= 4'd0;
            cycle_count   <= 8'd0;
            layer_idx     <= 3'd1;
            tpg_sel       <= 3'd1;
            tpg_write     <= 1'b0;
            tpg_read      <= 1'b0;
            mix_write     <= 1'b0;
        end else begin
            case (current_state)

                ST_IDLE: begin
                    cfg_step      <= 4'd0;
                    layer_idx     <= 3'd1;
                    current_state <= ST_CFG_MIXER;
                end

                // ══════════════════════════════════════════════════════════
                // Mixer layers 1..7 setup, then a single commit
                // ══════════════════════════════════════════════════════════
                // Avalon-MM rule: addr/data must be stable while waitrequest=1.
                // On acceptance, write deasserts for one cycle while cfg_step
                // advances and the next addr/data load, so controls never
                // change during a pending transaction.
                ST_CFG_MIXER: begin
                    case (cfg_step)
                        4'd0: begin mix_addr <= mix_layer_base + {5'd0, MIX_OFS_MODE};     mix_wdata <= 32'h1;     end
                        4'd1: begin mix_addr <= mix_layer_base + {5'd0, MIX_OFS_BLEND};    mix_wdata <= 32'h1;     end
                        4'd2: begin mix_addr <= mix_layer_base + {5'd0, MIX_OFS_ALPHA};    mix_wdata <= 32'd255;   end
                        4'd3: begin mix_addr <= mix_layer_base + {5'd0, MIX_OFS_H_OFFSET}; mix_wdata <= layer_off; end
                        4'd4: begin mix_addr <= mix_layer_base + {5'd0, MIX_OFS_V_OFFSET}; mix_wdata <= layer_off; end
                        default: ;
                    endcase
                    if (mix_write && !mix_wait) begin
                        mix_write <= 1'b0;
                        if (cfg_step == 4'd4) begin
                            cfg_step <= 4'd0;
                            if (layer_idx == 3'd7) begin
                                current_state <= ST_MIX_COMMIT;
                            end else begin
                                layer_idx <= layer_idx + 1'b1;
                            end
                        end else begin
                            cfg_step <= cfg_step + 1'b1;
                        end
                    end else begin
                        mix_write <= 1'b1;
                    end
                end

                ST_MIX_COMMIT: begin
                    mix_addr  <= MIX_ADDR_COMMIT;
                    mix_wdata <= 32'h1;
                    if (mix_write && !mix_wait) begin
                        mix_write     <= 1'b0;
                        cfg_step      <= 4'd0;
                        tpg_sel       <= 3'd1;      // overlay TPGs first
                        current_state <= ST_CFG_TPG;
                    end else begin
                        mix_write <= 1'b1;
                    end
                end

                // ══════════════════════════════════════════════════════════
                // TPG write sequence (runs 8x: TPG1..TPG7 overlays, TPG0 base)
                // ══════════════════════════════════════════════════════════
                ST_CFG_TPG: begin
                    case (cfg_step)
                        4'd0:  begin tpg_addr <= TPG_ADDR_CONTROL;   tpg_wdata <= 32'h0;      end
                        4'd1:  begin tpg_addr <= TPG_ADDR_INTERLACE; tpg_wdata <= 32'h0;      end
                        4'd2:  begin tpg_addr <= TPG_ADDR_WIDTH;     tpg_wdata <= cfg_width;  end
                        4'd3:  begin tpg_addr <= TPG_ADDR_HEIGHT;    tpg_wdata <= cfg_height; end
                        4'd4:  begin tpg_addr <= TPG_ADDR_BAR_SEL;   tpg_wdata <= 32'h0;      end
                        4'd5:  begin tpg_addr <= TPG_ADDR_PATTERN;   tpg_wdata <= 32'h0;      end
                        4'd6:  begin tpg_addr <= TPG_ADDR_C0;        tpg_wdata <= {24'd0, cfg_rgb[7:0]};   end
                        4'd7:  begin tpg_addr <= TPG_ADDR_C1;        tpg_wdata <= {24'd0, cfg_rgb[15:8]};  end
                        4'd8:  begin tpg_addr <= TPG_ADDR_C2;        tpg_wdata <= {24'd0, cfg_rgb[23:16]}; end
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
                        if (tpg_sel == 3'd0) begin
                            current_state <= ST_WORKING;      // base TPG was last
                        end else if (tpg_sel == 3'd7) begin
                            tpg_sel       <= 3'd0;            // now the base TPG
                            current_state <= ST_CFG_TPG;
                        end else begin
                            tpg_sel       <= tpg_sel + 1'b1;  // next overlay TPG
                            current_state <= ST_CFG_TPG;
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
        .intel_vvp_tpg_0_av_mm_control_agent_write         (tpg_write_v[0]),
        .intel_vvp_tpg_0_av_mm_control_agent_read          (tpg_read_v[0]),
        .intel_vvp_tpg_0_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_0_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_0_av_mm_control_agent_readdata      (tpg_readdata_v[0]),
        .intel_vvp_tpg_0_av_mm_control_agent_readdatavalid (tpg_readdatavalid_v[0]),
        .intel_vvp_tpg_0_av_mm_control_agent_waitrequest   (tpg_wait_v[0]),

        // ----- TPG1..TPG7 (overlays, uniform color) Avalon-MM control -----
        .intel_vvp_tpg_1_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_1_av_mm_control_agent_write         (tpg_write_v[1]),
        .intel_vvp_tpg_1_av_mm_control_agent_read          (tpg_read_v[1]),
        .intel_vvp_tpg_1_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_1_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_1_av_mm_control_agent_readdata      (tpg_readdata_v[1]),
        .intel_vvp_tpg_1_av_mm_control_agent_readdatavalid (tpg_readdatavalid_v[1]),
        .intel_vvp_tpg_1_av_mm_control_agent_waitrequest   (tpg_wait_v[1]),

        .intel_vvp_tpg_2_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_2_av_mm_control_agent_write         (tpg_write_v[2]),
        .intel_vvp_tpg_2_av_mm_control_agent_read          (tpg_read_v[2]),
        .intel_vvp_tpg_2_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_2_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_2_av_mm_control_agent_readdata      (tpg_readdata_v[2]),
        .intel_vvp_tpg_2_av_mm_control_agent_readdatavalid (tpg_readdatavalid_v[2]),
        .intel_vvp_tpg_2_av_mm_control_agent_waitrequest   (tpg_wait_v[2]),

        .intel_vvp_tpg_3_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_3_av_mm_control_agent_write         (tpg_write_v[3]),
        .intel_vvp_tpg_3_av_mm_control_agent_read          (tpg_read_v[3]),
        .intel_vvp_tpg_3_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_3_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_3_av_mm_control_agent_readdata      (tpg_readdata_v[3]),
        .intel_vvp_tpg_3_av_mm_control_agent_readdatavalid (tpg_readdatavalid_v[3]),
        .intel_vvp_tpg_3_av_mm_control_agent_waitrequest   (tpg_wait_v[3]),

        .intel_vvp_tpg_4_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_4_av_mm_control_agent_write         (tpg_write_v[4]),
        .intel_vvp_tpg_4_av_mm_control_agent_read          (tpg_read_v[4]),
        .intel_vvp_tpg_4_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_4_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_4_av_mm_control_agent_readdata      (tpg_readdata_v[4]),
        .intel_vvp_tpg_4_av_mm_control_agent_readdatavalid (tpg_readdatavalid_v[4]),
        .intel_vvp_tpg_4_av_mm_control_agent_waitrequest   (tpg_wait_v[4]),

        .intel_vvp_tpg_5_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_5_av_mm_control_agent_write         (tpg_write_v[5]),
        .intel_vvp_tpg_5_av_mm_control_agent_read          (tpg_read_v[5]),
        .intel_vvp_tpg_5_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_5_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_5_av_mm_control_agent_readdata      (tpg_readdata_v[5]),
        .intel_vvp_tpg_5_av_mm_control_agent_readdatavalid (tpg_readdatavalid_v[5]),
        .intel_vvp_tpg_5_av_mm_control_agent_waitrequest   (tpg_wait_v[5]),

        .intel_vvp_tpg_6_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_6_av_mm_control_agent_write         (tpg_write_v[6]),
        .intel_vvp_tpg_6_av_mm_control_agent_read          (tpg_read_v[6]),
        .intel_vvp_tpg_6_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_6_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_6_av_mm_control_agent_readdata      (tpg_readdata_v[6]),
        .intel_vvp_tpg_6_av_mm_control_agent_readdatavalid (tpg_readdatavalid_v[6]),
        .intel_vvp_tpg_6_av_mm_control_agent_waitrequest   (tpg_wait_v[6]),

        .intel_vvp_tpg_7_av_mm_control_agent_address       (tpg_addr),
        .intel_vvp_tpg_7_av_mm_control_agent_write         (tpg_write_v[7]),
        .intel_vvp_tpg_7_av_mm_control_agent_read          (tpg_read_v[7]),
        .intel_vvp_tpg_7_av_mm_control_agent_byteenable    (4'hF),
        .intel_vvp_tpg_7_av_mm_control_agent_writedata     (tpg_wdata),
        .intel_vvp_tpg_7_av_mm_control_agent_readdata      (tpg_readdata_v[7]),
        .intel_vvp_tpg_7_av_mm_control_agent_readdatavalid (tpg_readdatavalid_v[7]),
        .intel_vvp_tpg_7_av_mm_control_agent_waitrequest   (tpg_wait_v[7])
    );

endmodule
