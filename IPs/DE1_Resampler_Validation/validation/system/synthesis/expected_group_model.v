`timescale 1 ps / 1 ps

//------------------------------------------------------------------------------
// expected_group_model
//
// Per-configuration golden model for resampling_checker.  It owns only the pure
// (combinational) LAYOUT of one expected output group; the stateful parsing that
// feeds it (symbol framing, line parity, chroma line buffer) lives in the
// checker.  Selecting a config is therefore: add a CONV_* code, build its group
// here, and add the matching parser branch in resampling_checker.v.
//
// Group is carried as 32 bits.  Formats that use fewer symbols zero-pad the
// upper bits; the checker pads the ACTUAL group identically, so the compare is
// exact.
//
//   CONV_444_TO_422 : {Cb0, Y0, Cr0, Y1}            (4 symbols / pixel-pair)
//   CONV_444_TO_420 : {8'h00, Y0, C, Y1}            (3 symbols / pixel-pair)
//                     C = the single chroma symbol for the pair, already
//                     selected by the checker (Cb on even lines, Cr on odd).
//   CONV_OTHER      : placeholder, identity.
//
// Default is CONV_444_TO_420 -- the configuration currently in Platform Designer
// (4:4:4 in, 4:2:0 out, cosited H+V, nearest-neighbour).
//------------------------------------------------------------------------------
module expected_group_model #(
    parameter integer CONV_MODE = 2      // 0=444->422, 1=OTHER, 2=444->420
)(
    input  wire [7:0]  cb0,              // even-pixel Cb (4:2:2 only)
    input  wire [7:0]  cr0,              // even-pixel Cr (4:2:2 only)
    input  wire [7:0]  y0,               // even-pixel Y
    input  wire [7:0]  y1,               // odd-pixel  Y
    input  wire [7:0]  c,                // selected chroma for the pair (4:2:0)
    output wire [31:0] exp_group
);

    localparam integer CONV_444_TO_422 = 0;
    localparam integer CONV_OTHER       = 1;
    localparam integer CONV_444_TO_420  = 2;

    // 4:4:4 -> 4:2:2 nearest-neighbour cosited: luma preserved, chroma decimated
    // to the even (cosited) pixel.  Output group {Cb0, Y0, Cr0, Y1}.
    wire [31:0] grp_444_to_422 = {cb0, y0, cr0, y1};

    // 4:4:4 -> 4:2:0 nearest-neighbour cosited: per pixel-pair the stream carries
    // two luma and one chroma symbol, {Y0, C, Y1}.  C is Cb on even output lines
    // and Cr on odd output lines (selected upstream).  Upper byte zero-padded.
    wire [31:0] grp_444_to_420 = {8'h00, y0, c, y1};

    // Placeholder for a further conversion; identity until defined.
    wire [31:0] grp_other      = {cb0, cr0, y0, y1};

    assign exp_group = (CONV_MODE == CONV_444_TO_420) ? grp_444_to_420 :
                       (CONV_MODE == CONV_OTHER)      ? grp_other      :
                                                        grp_444_to_422;

endmodule
