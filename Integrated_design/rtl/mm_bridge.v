// =============================================================================
// mm_bridge.v  ?  Unified Avalon-MM Bridge
//
// Single Avalon-MM master bus fanned out to 4 pipeline IP slaves:
//   Clipper, Scaler, CRS (Resampler), CSC (Color Space Converter)
//
// Address Map (upper bits decode the slave):
//   0x000 - 0x0FF  ?  Clipper
//   0x100 - 0x1FF  ?  Scaler
//   0x200 - 0x2FF  ?  CRS
//   0x300 - 0x3FF  ?  CSC
//
// The lower 7 bits [6:0] are the per-IP word address (passed directly
// to the selected slave). Upper 2 bits [8:7] select the slave.
//
// waitrequest is muxed ? only the selected slave's waitrequest is
// returned to the master. Idle slaves are ignored.
//
// Port naming mirrors the existing pipeline.v port names so this module
// can be dropped in between top.v and pipeline.v with no port changes
// on either side.
// =============================================================================

module mm_bridge (
    input  wire        clk,
    input  wire        reset,

    // -------------------------------------------------------------------------
    // Single unified master port (driven by top.v FSM)
    // -------------------------------------------------------------------------
    input  wire [8:0]  master_address,      // [8:7] = slave sel, [6:0] = reg addr
    input  wire        master_write,
    input  wire        master_read,
    input  wire [3:0]  master_byteenable,
    input  wire [31:0] master_writedata,
    output reg  [31:0] master_readdata,
    output reg         master_readdatavalid,
    output wire        master_waitrequest,

    // -------------------------------------------------------------------------
    // Clipper slave port
    // -------------------------------------------------------------------------
    output reg  [6:0]  clip_address,
    output reg         clip_write,
    output reg         clip_read,
    output wire [3:0]  clip_byteenable,
    output reg  [31:0] clip_writedata,
    input  wire [31:0] clip_readdata,
    input  wire        clip_readdatavalid,
    input  wire        clip_waitrequest,

    // -------------------------------------------------------------------------
    // Scaler slave port
    // -------------------------------------------------------------------------
    output reg  [6:0]  scl_address,
    output reg         scl_write,
    output reg         scl_read,
    output wire [3:0]  scl_byteenable,
    output reg  [31:0] scl_writedata,
    input  wire [31:0] scl_readdata,
    input  wire        scl_readdatavalid,
    input  wire        scl_waitrequest,

    // -------------------------------------------------------------------------
    // CRS (Resampler) slave port
    // -------------------------------------------------------------------------
    output reg  [6:0]  crs_address,
    output reg         crs_write,
    output reg         crs_read,
    output wire [3:0]  crs_byteenable,
    output reg  [31:0] crs_writedata,
    input  wire [31:0] crs_readdata,
    input  wire        crs_readdatavalid,
    input  wire        crs_waitrequest,

    // -------------------------------------------------------------------------
    // CSC (Color Space Converter) slave port
    // -------------------------------------------------------------------------
    output reg  [6:0]  csc_address,
    output reg         csc_write,
    output reg         csc_read,
    output wire [3:0]  csc_byteenable,
    output reg  [31:0] csc_writedata,
    input  wire [31:0] csc_readdata,
    input  wire        csc_readdatavalid,
    input  wire        csc_waitrequest
);

    // =========================================================================
    // Slave select encoding ? upper 2 bits of master_address
    // =========================================================================
    localparam SEL_CLIP = 2'd0;   // 0x000 - 0x0FF
    localparam SEL_SCL  = 2'd1;   // 0x100 - 0x1FF
    localparam SEL_CRS  = 2'd2;   // 0x200 - 0x2FF
    localparam SEL_CSC  = 2'd3;   // 0x300 - 0x3FF

    wire [1:0] slave_sel = master_address[8:7];
    wire [6:0] reg_addr  = master_address[6:0];

    // =========================================================================
    // waitrequest mux ? only selected slave stalls the master
    // =========================================================================
    assign master_waitrequest =
        (slave_sel == SEL_CLIP) ? clip_waitrequest :
        (slave_sel == SEL_SCL)  ? scl_waitrequest  :
        (slave_sel == SEL_CRS)  ? crs_waitrequest  :
                                  csc_waitrequest;

    // =========================================================================
    // byteenable passthrough (all slaves get the same value)
    // =========================================================================
    assign clip_byteenable = master_byteenable;
    assign scl_byteenable  = master_byteenable;
    assign crs_byteenable  = master_byteenable;
    assign csc_byteenable  = master_byteenable;

    // =========================================================================
    // Write/read fan-out ? only selected slave sees write/read asserted
    // All others are deasserted
    // =========================================================================
    always @(*) begin
        // Default: deassert everything
        clip_write = 1'b0; clip_read = 1'b0;
        scl_write  = 1'b0; scl_read  = 1'b0;
        crs_write  = 1'b0; crs_read  = 1'b0;
        csc_write  = 1'b0; csc_read  = 1'b0;

        clip_address   = reg_addr;
        scl_address    = reg_addr;
        crs_address    = reg_addr;
        csc_address    = reg_addr;

        clip_writedata = master_writedata;
        scl_writedata  = master_writedata;
        crs_writedata  = master_writedata;
        csc_writedata  = master_writedata;

        case (slave_sel)
            SEL_CLIP: begin
                clip_write = master_write;
                clip_read  = master_read;
            end
            SEL_SCL: begin
                scl_write  = master_write;
                scl_read   = master_read;
            end
            SEL_CRS: begin
                crs_write  = master_write;
                crs_read   = master_read;
            end
            SEL_CSC: begin
                csc_write  = master_write;
                csc_read   = master_read;
            end
        endcase
    end

    // =========================================================================
    // readdata / readdatavalid mux ? pipeline back to master
    // Registered to break any combinational path from slave to master
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            master_readdata      <= 32'h0;
            master_readdatavalid <= 1'b0;
        end else begin
            master_readdatavalid <= 1'b0; // default: no valid data
            case (slave_sel)
                SEL_CLIP: begin
                    if (clip_readdatavalid) begin
                        master_readdata      <= clip_readdata;
                        master_readdatavalid <= 1'b1;
                    end
                end
                SEL_SCL: begin
                    if (scl_readdatavalid) begin
                        master_readdata      <= scl_readdata;
                        master_readdatavalid <= 1'b1;
                    end
                end
                SEL_CRS: begin
                    if (crs_readdatavalid) begin
                        master_readdata      <= crs_readdata;
                        master_readdatavalid <= 1'b1;
                    end
                end
                SEL_CSC: begin
                    if (csc_readdatavalid) begin
                        master_readdata      <= csc_readdata;
                        master_readdatavalid <= 1'b1;
                    end
                end
            endcase
        end
      end
     endmodule

