package require qsys

# ---------------------------------------------------------------------------
# Component metadata
# ---------------------------------------------------------------------------
set_module_property NAME                 intel_vvp_pipeline
set_module_property DISPLAY_NAME         "Intel VVP Pipeline"
set_module_property VERSION              1.0
set_module_property DESCRIPTION          "Parameterizable video processing pipeline with selectable topology"
set_module_property COMPOSITION_CALLBACK compose
set_module_property ELABORATION_CALLBACK elaborate

# Declare tab groups
add_display_item "" "General"                GROUP tab
add_display_item "" "Scaler"                 GROUP tab
add_display_item "" "Clipper"                GROUP tab
add_display_item "" "Chroma Resampler"       GROUP tab
add_display_item "" "Deinterlacer"           GROUP tab
add_display_item "" "Test Pattern Generator" GROUP tab
add_display_item "" "Protocol Converter"     GROUP tab

# ===========================================================================
# GENERAL TAB
# ===========================================================================
add_parameter TOPOLOGY STRING "FULL"
set_parameter_property TOPOLOGY DISPLAY_NAME  "Topology"
set_parameter_property TOPOLOGY ALLOWED_RANGES {FULL SCALER_ONLY CSC_ONLY RESAMPLER_ONLY}
add_display_item "General" TOPOLOGY PARAMETER

add_parameter BPS INTEGER 8
set_parameter_property BPS DISPLAY_NAME   "Bits Per Component (BPC)"
set_parameter_property BPS ALLOWED_RANGES {8 10 12}
add_display_item "General" BPS PARAMETER

add_parameter NUMBER_OF_COLOR_PLANES INTEGER 3
set_parameter_property NUMBER_OF_COLOR_PLANES DISPLAY_NAME   "Number of Color Planes"
set_parameter_property NUMBER_OF_COLOR_PLANES ALLOWED_RANGES {1 2 3 4}
add_display_item "General" NUMBER_OF_COLOR_PLANES PARAMETER

add_parameter PIXELS_IN_PARALLEL INTEGER 1
set_parameter_property PIXELS_IN_PARALLEL DISPLAY_NAME   "Pixels in Parallel (PPC)"
set_parameter_property PIXELS_IN_PARALLEL ALLOWED_RANGES {1 2 4 8}
add_display_item "General" PIXELS_IN_PARALLEL PARAMETER

add_parameter MAX_WIDTH INTEGER 8192
set_parameter_property MAX_WIDTH DISPLAY_NAME "Maximum Frame Width (pixels)"
add_display_item "General" MAX_WIDTH PARAMETER

add_parameter MAX_HEIGHT INTEGER 4320
set_parameter_property MAX_HEIGHT DISPLAY_NAME "Maximum Frame Height (lines)"
add_display_item "General" MAX_HEIGHT PARAMETER

add_parameter ENABLE_444 INTEGER 1
set_parameter_property ENABLE_444 DISPLAY_NAME "Support 4:4:4 / RGB"
add_display_item "General" ENABLE_444 PARAMETER

add_parameter ENABLE_422 INTEGER 0
set_parameter_property ENABLE_422 DISPLAY_NAME "Support 4:2:2"
add_display_item "General" ENABLE_422 PARAMETER

add_parameter ENABLE_420 INTEGER 0
set_parameter_property ENABLE_420 DISPLAY_NAME "Support 4:2:0"
add_display_item "General" ENABLE_420 PARAMETER

# ===========================================================================
# SCALER TAB
# ===========================================================================
add_parameter SCALER_RUNTIME_CONTROL INTEGER 1
set_parameter_property SCALER_RUNTIME_CONTROL DISPLAY_NAME "Runtime Control"
add_display_item "Scaler" SCALER_RUNTIME_CONTROL PARAMETER

add_parameter SCALER_RUNTIME_LOAD INTEGER 1
set_parameter_property SCALER_RUNTIME_LOAD DISPLAY_NAME "Runtime Coefficient Load"
add_display_item "Scaler" SCALER_RUNTIME_LOAD PARAMETER

add_parameter SCALER_ALGORITHM STRING "NEAREST_NEIGHBOUR"
set_parameter_property SCALER_ALGORITHM DISPLAY_NAME   "Scaling Algorithm"
set_parameter_property SCALER_ALGORITHM ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR BICUBIC}
add_display_item "Scaler" SCALER_ALGORITHM PARAMETER

add_parameter SCALER_EDGE_MIRROR STRING "REPLICATE"
set_parameter_property SCALER_EDGE_MIRROR DISPLAY_NAME   "Edge Mirror Mode"
set_parameter_property SCALER_EDGE_MIRROR ALLOWED_RANGES {REPLICATE REFLECT ZERO}
add_display_item "Scaler" SCALER_EDGE_MIRROR PARAMETER

add_parameter SCALER_ENABLE_V INTEGER 1
set_parameter_property SCALER_ENABLE_V DISPLAY_NAME "Enable Vertical Scaling"
add_display_item "Scaler" SCALER_ENABLE_V PARAMETER

add_parameter SCALER_V_TAPS INTEGER 4
set_parameter_property SCALER_V_TAPS DISPLAY_NAME   "Vertical Taps"
set_parameter_property SCALER_V_TAPS ALLOWED_RANGES {2 4 6 8 10 12}
add_display_item "Scaler" SCALER_V_TAPS PARAMETER

add_parameter SCALER_V_PHASES INTEGER 16
set_parameter_property SCALER_V_PHASES DISPLAY_NAME "Vertical Phases"
add_display_item "Scaler" SCALER_V_PHASES PARAMETER

add_parameter SCALER_V_COEFF_FUNCTION STRING "LANCZOS_2"
set_parameter_property SCALER_V_COEFF_FUNCTION DISPLAY_NAME   "Vertical Coefficient Function"
set_parameter_property SCALER_V_COEFF_FUNCTION ALLOWED_RANGES {LANCZOS_2 LANCZOS_3 BILINEAR BICUBIC}
add_display_item "Scaler" SCALER_V_COEFF_FUNCTION PARAMETER

add_parameter SCALER_ENABLE_H INTEGER 1
set_parameter_property SCALER_ENABLE_H DISPLAY_NAME "Enable Horizontal Scaling"
add_display_item "Scaler" SCALER_ENABLE_H PARAMETER

add_parameter SCALER_H_TAPS INTEGER 4
set_parameter_property SCALER_H_TAPS DISPLAY_NAME   "Horizontal Taps"
set_parameter_property SCALER_H_TAPS ALLOWED_RANGES {2 4 6 8 10 12}
add_display_item "Scaler" SCALER_H_TAPS PARAMETER

add_parameter SCALER_H_PHASES INTEGER 16
set_parameter_property SCALER_H_PHASES DISPLAY_NAME "Horizontal Phases"
add_display_item "Scaler" SCALER_H_PHASES PARAMETER

add_parameter SCALER_H_COEFF_FUNCTION STRING "LANCZOS_2"
set_parameter_property SCALER_H_COEFF_FUNCTION DISPLAY_NAME   "Horizontal Coefficient Function"
set_parameter_property SCALER_H_COEFF_FUNCTION ALLOWED_RANGES {LANCZOS_2 LANCZOS_3 BILINEAR BICUBIC}
add_display_item "Scaler" SCALER_H_COEFF_FUNCTION PARAMETER

# ===========================================================================
# CLIPPER TAB
# ===========================================================================
add_parameter CLIPPER_RUNTIME_CONTROL INTEGER 1
set_parameter_property CLIPPER_RUNTIME_CONTROL DISPLAY_NAME "Runtime Control"
add_display_item "Clipper" CLIPPER_RUNTIME_CONTROL PARAMETER

add_parameter CLIPPER_CLIPPING_METHOD STRING "OFFSETS"
set_parameter_property CLIPPER_CLIPPING_METHOD DISPLAY_NAME   "Clipping Method"
set_parameter_property CLIPPER_CLIPPING_METHOD ALLOWED_RANGES {OFFSETS RECTANGLE}
add_display_item "Clipper" CLIPPER_CLIPPING_METHOD PARAMETER

add_parameter CLIPPER_LEFT_OFFSET INTEGER 0
set_parameter_property CLIPPER_LEFT_OFFSET DISPLAY_NAME "Left Offset"
add_display_item "Clipper" CLIPPER_LEFT_OFFSET PARAMETER

add_parameter CLIPPER_TOP_OFFSET INTEGER 0
set_parameter_property CLIPPER_TOP_OFFSET DISPLAY_NAME "Top Offset"
add_display_item "Clipper" CLIPPER_TOP_OFFSET PARAMETER

add_parameter CLIPPER_RIGHT_OFFSET INTEGER 0
set_parameter_property CLIPPER_RIGHT_OFFSET DISPLAY_NAME "Right Offset"
add_display_item "Clipper" CLIPPER_RIGHT_OFFSET PARAMETER

add_parameter CLIPPER_BOTTOM_OFFSET INTEGER 0
set_parameter_property CLIPPER_BOTTOM_OFFSET DISPLAY_NAME "Bottom Offset"
add_display_item "Clipper" CLIPPER_BOTTOM_OFFSET PARAMETER

add_parameter CLIPPER_RECTANGLE_WIDTH INTEGER 1920
set_parameter_property CLIPPER_RECTANGLE_WIDTH DISPLAY_NAME "Rectangle Width"
add_display_item "Clipper" CLIPPER_RECTANGLE_WIDTH PARAMETER

add_parameter CLIPPER_RECTANGLE_HEIGHT INTEGER 1080
set_parameter_property CLIPPER_RECTANGLE_HEIGHT DISPLAY_NAME "Rectangle Height"
add_display_item "Clipper" CLIPPER_RECTANGLE_HEIGHT PARAMETER

# ===========================================================================
# CHROMA RESAMPLER TAB
# ===========================================================================
add_parameter CRS_RUNTIME_CONTROL INTEGER 0
set_parameter_property CRS_RUNTIME_CONTROL DISPLAY_NAME "Runtime Control"
add_display_item "Chroma Resampler" CRS_RUNTIME_CONTROL PARAMETER

add_parameter CRS_MAX_WIDTH INTEGER 16384
set_parameter_property CRS_MAX_WIDTH DISPLAY_NAME "Maximum Width"
add_display_item "Chroma Resampler" CRS_MAX_WIDTH PARAMETER

add_parameter CRS_SUPPORT_444_TO_422 INTEGER 0
set_parameter_property CRS_SUPPORT_444_TO_422 DISPLAY_NAME "Support 4:4:4 to 4:2:2"
add_display_item "Chroma Resampler" CRS_SUPPORT_444_TO_422 PARAMETER

add_parameter CRS_SUPPORT_444_TO_420 INTEGER 0
set_parameter_property CRS_SUPPORT_444_TO_420 DISPLAY_NAME "Support 4:4:4 to 4:2:0"
add_display_item "Chroma Resampler" CRS_SUPPORT_444_TO_420 PARAMETER

add_parameter CRS_SUPPORT_422_TO_444 INTEGER 1
set_parameter_property CRS_SUPPORT_422_TO_444 DISPLAY_NAME "Support 4:2:2 to 4:4:4"
add_display_item "Chroma Resampler" CRS_SUPPORT_422_TO_444 PARAMETER

add_parameter CRS_SUPPORT_422_TO_420 INTEGER 0
set_parameter_property CRS_SUPPORT_422_TO_420 DISPLAY_NAME "Support 4:2:2 to 4:2:0"
add_display_item "Chroma Resampler" CRS_SUPPORT_422_TO_420 PARAMETER

add_parameter CRS_SUPPORT_420_TO_422 INTEGER 0
set_parameter_property CRS_SUPPORT_420_TO_422 DISPLAY_NAME "Support 4:2:0 to 4:2:2"
add_display_item "Chroma Resampler" CRS_SUPPORT_420_TO_422 PARAMETER

add_parameter CRS_SUPPORT_420_TO_444 INTEGER 0
set_parameter_property CRS_SUPPORT_420_TO_444 DISPLAY_NAME "Support 4:2:0 to 4:4:4"
add_display_item "Chroma Resampler" CRS_SUPPORT_420_TO_444 PARAMETER

add_parameter CRS_HORIZ_ALGORITHM STRING "NEAREST_NEIGHBOUR"
set_parameter_property CRS_HORIZ_ALGORITHM DISPLAY_NAME   "Horizontal Algorithm"
set_parameter_property CRS_HORIZ_ALGORITHM ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR}
add_display_item "Chroma Resampler" CRS_HORIZ_ALGORITHM PARAMETER

add_parameter CRS_VERT_ALGORITHM STRING "BILINEAR"
set_parameter_property CRS_VERT_ALGORITHM DISPLAY_NAME   "Vertical Algorithm"
set_parameter_property CRS_VERT_ALGORITHM ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR}
add_display_item "Chroma Resampler" CRS_VERT_ALGORITHM PARAMETER

add_parameter CRS_HORIZ_CO_SITING STRING "LEFT"
set_parameter_property CRS_HORIZ_CO_SITING DISPLAY_NAME   "Horizontal Co-siting"
set_parameter_property CRS_HORIZ_CO_SITING ALLOWED_RANGES {LEFT CENTER RIGHT}
add_display_item "Chroma Resampler" CRS_HORIZ_CO_SITING PARAMETER

add_parameter CRS_VERT_CO_SITING STRING "TOP"
set_parameter_property CRS_VERT_CO_SITING DISPLAY_NAME   "Vertical Co-siting"
set_parameter_property CRS_VERT_CO_SITING ALLOWED_RANGES {TOP CENTER BOTTOM}
add_display_item "Chroma Resampler" CRS_VERT_CO_SITING PARAMETER

# ===========================================================================
# DEINTERLACER TAB
# ===========================================================================
add_parameter DIL_MODE STRING "BOB"
set_parameter_property DIL_MODE DISPLAY_NAME   "Deinterlace Mode"
set_parameter_property DIL_MODE ALLOWED_RANGES {BOB WEAVE}
add_display_item "Deinterlacer" DIL_MODE PARAMETER

add_parameter DIL_BOB_MODE STRING "DEINTERLACE_F0_ONLY"
set_parameter_property DIL_BOB_MODE DISPLAY_NAME   "Bob Mode"
set_parameter_property DIL_BOB_MODE ALLOWED_RANGES {DEINTERLACE_F0_ONLY DEINTERLACE_F1_ONLY DEINTERLACE_BOTH}
add_display_item "Deinterlacer" DIL_BOB_MODE PARAMETER

add_parameter DIL_MAX_WIDTH INTEGER 2048
set_parameter_property DIL_MAX_WIDTH DISPLAY_NAME "Maximum Width"
add_display_item "Deinterlacer" DIL_MAX_WIDTH PARAMETER

add_parameter DIL_MEM_BUFF_BASE_ADDR INTEGER 0
set_parameter_property DIL_MEM_BUFF_BASE_ADDR DISPLAY_NAME "Memory Buffer Base Address"
add_display_item "Deinterlacer" DIL_MEM_BUFF_BASE_ADDR PARAMETER

add_parameter DIL_MEM_BUFF_LINE_STRIDE INTEGER 32768
set_parameter_property DIL_MEM_BUFF_LINE_STRIDE DISPLAY_NAME "Memory Buffer Line Stride"
add_display_item "Deinterlacer" DIL_MEM_BUFF_LINE_STRIDE PARAMETER

add_parameter DIL_WRITE_BURST_TARGET INTEGER 32
set_parameter_property DIL_WRITE_BURST_TARGET DISPLAY_NAME "Write Burst Target"
add_display_item "Deinterlacer" DIL_WRITE_BURST_TARGET PARAMETER

add_parameter DIL_READ_BURST_TARGET INTEGER 32
set_parameter_property DIL_READ_BURST_TARGET DISPLAY_NAME "Read Burst Target"
add_display_item "Deinterlacer" DIL_READ_BURST_TARGET PARAMETER

add_parameter DIL_WRITE_FIFO_DEPTH INTEGER 64
set_parameter_property DIL_WRITE_FIFO_DEPTH DISPLAY_NAME "Write FIFO Depth"
add_display_item "Deinterlacer" DIL_WRITE_FIFO_DEPTH PARAMETER

add_parameter DIL_READ_FIFO_DEPTH INTEGER 64
set_parameter_property DIL_READ_FIFO_DEPTH DISPLAY_NAME "Read FIFO Depth"
add_display_item "Deinterlacer" DIL_READ_FIFO_DEPTH PARAMETER

# ===========================================================================
# TEST PATTERN GENERATOR TAB
# ===========================================================================
add_parameter TPG_OUTPUT_FORMAT STRING "4.2.2"
set_parameter_property TPG_OUTPUT_FORMAT DISPLAY_NAME   "Output Format"
set_parameter_property TPG_OUTPUT_FORMAT ALLOWED_RANGES {4.2.2 4.4.4 RGB}
add_display_item "Test Pattern Generator" TPG_OUTPUT_FORMAT PARAMETER

add_parameter TPG_RUNTIME_CONTROL INTEGER 0
set_parameter_property TPG_RUNTIME_CONTROL DISPLAY_NAME "Runtime Control"
add_display_item "Test Pattern Generator" TPG_RUNTIME_CONTROL PARAMETER

add_parameter TPG_FIXED_WIDTH INTEGER 32
set_parameter_property TPG_FIXED_WIDTH DISPLAY_NAME "Fixed Width"
add_display_item "Test Pattern Generator" TPG_FIXED_WIDTH PARAMETER

add_parameter TPG_FIXED_HEIGHT INTEGER 32
set_parameter_property TPG_FIXED_HEIGHT DISPLAY_NAME "Fixed Height"
add_display_item "Test Pattern Generator" TPG_FIXED_HEIGHT PARAMETER

add_parameter TPG_FIXED_FPS INTEGER 60
set_parameter_property TPG_FIXED_FPS DISPLAY_NAME "Fixed Frame Rate (FPS)"
add_display_item "Test Pattern Generator" TPG_FIXED_FPS PARAMETER

add_parameter TPG_CORE_COL_SPACE_0 INTEGER 2
set_parameter_property TPG_CORE_COL_SPACE_0 DISPLAY_NAME "Core 0 Color Space"
add_display_item "Test Pattern Generator" TPG_CORE_COL_SPACE_0 PARAMETER

add_parameter TPG_CORE_PATTERN_0 INTEGER 0
set_parameter_property TPG_CORE_PATTERN_0 DISPLAY_NAME "Core 0 Pattern"
add_display_item "Test Pattern Generator" TPG_CORE_PATTERN_0 PARAMETER

# ===========================================================================
# PROTOCOL CONVERTER TAB
# ===========================================================================
add_parameter PCONV_INPUT_MODE STRING "INTERNAL"
set_parameter_property PCONV_INPUT_MODE DISPLAY_NAME   "Input Mode"
set_parameter_property PCONV_INPUT_MODE ALLOWED_RANGES {INTERNAL EXTERNAL}
add_display_item "Protocol Converter" PCONV_INPUT_MODE PARAMETER

add_parameter PCONV_OUTPUT_MODE STRING "EXTERNAL"
set_parameter_property PCONV_OUTPUT_MODE DISPLAY_NAME   "Output Mode"
set_parameter_property PCONV_OUTPUT_MODE ALLOWED_RANGES {INTERNAL EXTERNAL}
add_display_item "Protocol Converter" PCONV_OUTPUT_MODE PARAMETER

add_parameter PCONV_COLOR_SPACE STRING "RGB"
set_parameter_property PCONV_COLOR_SPACE DISPLAY_NAME   "Color Space"
set_parameter_property PCONV_COLOR_SPACE ALLOWED_RANGES {RGB YCbCr YUV}
add_display_item "Protocol Converter" PCONV_COLOR_SPACE PARAMETER

add_parameter PCONV_CHROMA_SAMPLING STRING "444"
set_parameter_property PCONV_CHROMA_SAMPLING DISPLAY_NAME   "Chroma Sampling"
set_parameter_property PCONV_CHROMA_SAMPLING ALLOWED_RANGES {444 422 420}
add_display_item "Protocol Converter" PCONV_CHROMA_SAMPLING PARAMETER

add_parameter PCONV_CHROMA_SITING STRING "TOP_LEFT"
set_parameter_property PCONV_CHROMA_SITING DISPLAY_NAME   "Chroma Siting"
set_parameter_property PCONV_CHROMA_SITING ALLOWED_RANGES {TOP_LEFT TOP_CENTER CENTER}
add_display_item "Protocol Converter" PCONV_CHROMA_SITING PARAMETER

add_parameter PCONV_VVP_USER_SUPPORT STRING "NONE_ALLOWED"
set_parameter_property PCONV_VVP_USER_SUPPORT DISPLAY_NAME   "VVP User Signal Support"
set_parameter_property PCONV_VVP_USER_SUPPORT ALLOWED_RANGES {NONE_ALLOWED PASS EMBED}
add_display_item "Protocol Converter" PCONV_VVP_USER_SUPPORT PARAMETER

add_parameter PCONV_VIP_USER_SUPPORT STRING "DISCARD"
set_parameter_property PCONV_VIP_USER_SUPPORT DISPLAY_NAME   "VIP User Signal Support"
set_parameter_property PCONV_VIP_USER_SUPPORT ALLOWED_RANGES {DISCARD PASS}
add_display_item "Protocol Converter" PCONV_VIP_USER_SUPPORT PARAMETER

add_parameter PCONV_ENABLE_YCBCR_SWAP INTEGER 0
set_parameter_property PCONV_ENABLE_YCBCR_SWAP DISPLAY_NAME "Enable YCbCr Swap"
add_display_item "Protocol Converter" PCONV_ENABLE_YCBCR_SWAP PARAMETER

# ===========================================================================
# ELABORATION CALLBACK — controls which tab parameters are editable
# ===========================================================================
proc elaborate {} {
    catch {

    set topo [get_parameter_value TOPOLOGY]

    set is_scaler  [expr {$topo eq "FULL" || $topo eq "SCALER_ONLY"}]
    set is_clipper [expr {$topo eq "FULL"}]
    set is_crs     [expr {$topo eq "FULL" || $topo eq "RESAMPLER_ONLY"}]
    set is_dil     [expr {$topo eq "FULL"}]
    set is_tpg     [expr {$topo eq "FULL"}]
    set is_pconv   [expr {$topo eq "FULL" || $topo eq "CSC_ONLY"}]

    foreach p {SCALER_RUNTIME_CONTROL SCALER_RUNTIME_LOAD SCALER_ALGORITHM
               SCALER_EDGE_MIRROR SCALER_ENABLE_V SCALER_V_TAPS SCALER_V_PHASES
               SCALER_V_COEFF_FUNCTION SCALER_ENABLE_H SCALER_H_TAPS
               SCALER_H_PHASES SCALER_H_COEFF_FUNCTION} {
        set_parameter_property $p ENABLED $is_scaler
    }

    foreach p {CLIPPER_RUNTIME_CONTROL CLIPPER_CLIPPING_METHOD CLIPPER_LEFT_OFFSET
               CLIPPER_TOP_OFFSET CLIPPER_RIGHT_OFFSET CLIPPER_BOTTOM_OFFSET
               CLIPPER_RECTANGLE_WIDTH CLIPPER_RECTANGLE_HEIGHT} {
        set_parameter_property $p ENABLED $is_clipper
    }

    foreach p {CRS_RUNTIME_CONTROL CRS_MAX_WIDTH CRS_SUPPORT_444_TO_422
               CRS_SUPPORT_444_TO_420 CRS_SUPPORT_422_TO_444 CRS_SUPPORT_422_TO_420
               CRS_SUPPORT_420_TO_422 CRS_SUPPORT_420_TO_444 CRS_HORIZ_ALGORITHM
               CRS_VERT_ALGORITHM CRS_HORIZ_CO_SITING CRS_VERT_CO_SITING} {
        set_parameter_property $p ENABLED $is_crs
    }

    foreach p {DIL_MODE DIL_BOB_MODE DIL_MAX_WIDTH DIL_MEM_BUFF_BASE_ADDR
               DIL_MEM_BUFF_LINE_STRIDE DIL_WRITE_BURST_TARGET DIL_READ_BURST_TARGET
               DIL_WRITE_FIFO_DEPTH DIL_READ_FIFO_DEPTH} {
        set_parameter_property $p ENABLED $is_dil
    }

    foreach p {TPG_OUTPUT_FORMAT TPG_RUNTIME_CONTROL TPG_FIXED_WIDTH
               TPG_FIXED_HEIGHT TPG_FIXED_FPS TPG_CORE_COL_SPACE_0 TPG_CORE_PATTERN_0} {
        set_parameter_property $p ENABLED $is_tpg
    }

    foreach p {PCONV_INPUT_MODE PCONV_OUTPUT_MODE PCONV_COLOR_SPACE PCONV_CHROMA_SAMPLING
               PCONV_CHROMA_SITING PCONV_VVP_USER_SUPPORT PCONV_VIP_USER_SUPPORT
               PCONV_ENABLE_YCBCR_SWAP} {
        set_parameter_property $p ENABLED $is_pconv
    }

    } ;# end catch
}

# ===========================================================================
# COMPOSITION CALLBACK — conditionally instantiates hardware per topology
# ===========================================================================
proc compose {} {
    set topo    [get_parameter_value TOPOLOGY]
    set bps     [get_parameter_value BPS]
    set nplanes [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set pip     [get_parameter_value PIXELS_IN_PARALLEL]
    set mwidth  [get_parameter_value MAX_WIDTH]
    set mheight [get_parameter_value MAX_HEIGHT]
    set en444   [get_parameter_value ENABLE_444]
    set en422   [get_parameter_value ENABLE_422]
    set en420   [get_parameter_value ENABLE_420]

    set is_scaler  [expr {$topo eq "FULL" || $topo eq "SCALER_ONLY"}]
    set is_clipper [expr {$topo eq "FULL"}]
    set is_crs     [expr {$topo eq "FULL" || $topo eq "RESAMPLER_ONLY"}]
    set is_dil     [expr {$topo eq "FULL"}]
    set is_tpg     [expr {$topo eq "FULL"}]
    set is_pconv   [expr {$topo eq "FULL" || $topo eq "CSC_ONLY"}]

    set clipper_has_mm [expr {$is_clipper && [get_parameter_value CLIPPER_RUNTIME_CONTROL]}]
    set scaler_has_mm  [expr {$is_scaler  && [get_parameter_value SCALER_RUNTIME_CONTROL]}]
    set need_bridge    [expr {$clipper_has_mm || $scaler_has_mm}]

    # -----------------------------------------------------------------------
    # Infrastructure (always present)
    # -----------------------------------------------------------------------
    add_instance clock_in altera_clock_bridge 19.2.0
    set_instance_parameter_value clock_in NUM_CLOCK_OUTPUTS   1
    set_instance_parameter_value clock_in EXPLICIT_CLOCK_RATE 50000000

    add_instance reset_in altera_reset_bridge 19.2.0
    set_instance_parameter_value reset_in NUM_RESET_OUTPUTS  1
    set_instance_parameter_value reset_in ACTIVE_LOW_RESET   0
    set_instance_parameter_value reset_in SYNCHRONOUS_EDGES  deassert
    set_instance_parameter_value reset_in USE_RESET_REQUEST  0
    set_instance_parameter_value reset_in SYNC_RESET         0

    add_connection clock_in.out_clk reset_in.clk

    # -----------------------------------------------------------------------
    # Avalon-MM bridge (only when at least one slave IP needs it)
    # -----------------------------------------------------------------------
    if {$need_bridge} {
        add_instance mm_bridge_0 altera_avalon_mm_bridge 20.1.0
        set_instance_parameter_value mm_bridge_0 DATA_WIDTH            32
        set_instance_parameter_value mm_bridge_0 ADDRESS_WIDTH         10
        set_instance_parameter_value mm_bridge_0 ADDRESS_UNITS         SYMBOLS
        set_instance_parameter_value mm_bridge_0 MAX_BURST_SIZE        1
        set_instance_parameter_value mm_bridge_0 MAX_PENDING_RESPONSES 4
        set_instance_parameter_value mm_bridge_0 PIPELINE_COMMAND      1
        set_instance_parameter_value mm_bridge_0 PIPELINE_RESPONSE     1
        set_instance_parameter_value mm_bridge_0 SYNC_RESET            0
        set_instance_parameter_value mm_bridge_0 USE_RESPONSE          0
        set_instance_parameter_value mm_bridge_0 USE_WRITERESPONSE     0

        add_connection clock_in.out_clk   mm_bridge_0.clk
        add_connection reset_in.out_reset mm_bridge_0.reset
    }

    # -----------------------------------------------------------------------
    # Test Pattern Generator
    # -----------------------------------------------------------------------
    if {$is_tpg} {
        add_instance intel_vvp_tpg_0 intel_vvp_tpg 24.5.1
        set_instance_parameter_value intel_vvp_tpg_0 EXTERNAL_MODE       0
        set_instance_parameter_value intel_vvp_tpg_0 BPS                 $bps
        set_instance_parameter_value intel_vvp_tpg_0 PIXELS_IN_PARALLEL  $pip
        set_instance_parameter_value intel_vvp_tpg_0 OUTPUT_FORMAT       [get_parameter_value TPG_OUTPUT_FORMAT]
        set_instance_parameter_value intel_vvp_tpg_0 RUNTIME_CONTROL     [get_parameter_value TPG_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_tpg_0 ENABLE_DEBUG        0
        set_instance_parameter_value intel_vvp_tpg_0 SEPARATE_SLAVE_CLOCK 0
        set_instance_parameter_value intel_vvp_tpg_0 PIPELINE_READY      0
        set_instance_parameter_value intel_vvp_tpg_0 NUM_CORES           1
        set_instance_parameter_value intel_vvp_tpg_0 ENABLE_CTRL_IN      0
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_WIDTH         [get_parameter_value TPG_FIXED_WIDTH]
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_HEIGHT        [get_parameter_value TPG_FIXED_HEIGHT]
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_FPS           [get_parameter_value TPG_FIXED_FPS]
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_R_CR          16
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_G_Y           16
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_B_CB          16
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_INTERLACE     8
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_BARS_MODE     0
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_POWER_FACTOR  16
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_FINE_FACTOR   256
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_B_BACKGROUND  0
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_G_BACKGROUND  0
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_R_BACKGROUND  0
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_B_FONT        255
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_G_FONT        255
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_R_FONT        255
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_LOCATION_X    0
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_LOCATION_Y    0
        set_instance_parameter_value intel_vvp_tpg_0 FIXED_SCALE_FACTOR  1
        set_instance_parameter_value intel_vvp_tpg_0 BINARY_DISPLAY_MODE Seconds
        set_instance_parameter_value intel_vvp_tpg_0 CORE_COL_SPACE_0    [get_parameter_value TPG_CORE_COL_SPACE_0]
        set_instance_parameter_value intel_vvp_tpg_0 CORE_PATTERN_0      [get_parameter_value TPG_CORE_PATTERN_0]
        foreach i {1 2 3 4 5 6 7} {
            set_instance_parameter_value intel_vvp_tpg_0 CORE_COL_SPACE_${i} 0
            set_instance_parameter_value intel_vvp_tpg_0 CORE_PATTERN_${i}   0
        }
        add_connection clock_in.out_clk   intel_vvp_tpg_0.main_clock
        add_connection reset_in.out_reset intel_vvp_tpg_0.main_reset
    }

    # -----------------------------------------------------------------------
    # Clipper
    # -----------------------------------------------------------------------
    if {$is_clipper} {
        add_instance intel_vvp_clipper_0 intel_vvp_clipper 24.5.1
        set_instance_parameter_value intel_vvp_clipper_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_clipper_0 NUMBER_OF_COLOR_PLANES $nplanes
        set_instance_parameter_value intel_vvp_clipper_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_clipper_0 CLIPPING_METHOD        [get_parameter_value CLIPPER_CLIPPING_METHOD]
        set_instance_parameter_value intel_vvp_clipper_0 LEFT_OFFSET            [get_parameter_value CLIPPER_LEFT_OFFSET]
        set_instance_parameter_value intel_vvp_clipper_0 TOP_OFFSET             [get_parameter_value CLIPPER_TOP_OFFSET]
        set_instance_parameter_value intel_vvp_clipper_0 RIGHT_OFFSET           [get_parameter_value CLIPPER_RIGHT_OFFSET]
        set_instance_parameter_value intel_vvp_clipper_0 BOTTOM_OFFSET          [get_parameter_value CLIPPER_BOTTOM_OFFSET]
        set_instance_parameter_value intel_vvp_clipper_0 RECTANGLE_WIDTH        [get_parameter_value CLIPPER_RECTANGLE_WIDTH]
        set_instance_parameter_value intel_vvp_clipper_0 RECTANGLE_HEIGHT       [get_parameter_value CLIPPER_RECTANGLE_HEIGHT]
        set_instance_parameter_value intel_vvp_clipper_0 RUNTIME_CONTROL        [get_parameter_value CLIPPER_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_clipper_0 ENABLE_DEBUG           0
        set_instance_parameter_value intel_vvp_clipper_0 SEPARATE_SLAVE_CLOCK   0
        set_instance_parameter_value intel_vvp_clipper_0 EXTERNAL_MODE          0

        add_connection clock_in.out_clk   intel_vvp_clipper_0.main_clock
        add_connection reset_in.out_reset intel_vvp_clipper_0.main_reset

        if {$clipper_has_mm} {
            add_connection mm_bridge_0.m0 intel_vvp_clipper_0.av_mm_control_agent
            set_connection_parameter_value \
                mm_bridge_0.m0/intel_vvp_clipper_0.av_mm_control_agent baseAddress 0x0000
        }
    }

    # -----------------------------------------------------------------------
    # Protocol Converter
    # -----------------------------------------------------------------------
    if {$is_pconv} {
        add_instance intel_vvp_protocol_conv_0 intel_vvp_protocol_conv 24.6.0
        set_instance_parameter_value intel_vvp_protocol_conv_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_protocol_conv_0 NUMBER_OF_COLOR_PLANES $nplanes
        set_instance_parameter_value intel_vvp_protocol_conv_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_protocol_conv_0 RUNTIME_CONTROL        0
        set_instance_parameter_value intel_vvp_protocol_conv_0 ENABLE_DEBUG           0
        set_instance_parameter_value intel_vvp_protocol_conv_0 SEPARATE_SLAVE_CLOCK   0
        set_instance_parameter_value intel_vvp_protocol_conv_0 PIPELINE_READY         0
        set_instance_parameter_value intel_vvp_protocol_conv_0 INPUT_MODE             [get_parameter_value PCONV_INPUT_MODE]
        set_instance_parameter_value intel_vvp_protocol_conv_0 OUTPUT_MODE            [get_parameter_value PCONV_OUTPUT_MODE]
        set_instance_parameter_value intel_vvp_protocol_conv_0 CLIP_LONG_FIELDS       0
        set_instance_parameter_value intel_vvp_protocol_conv_0 ENABLE_TIMEOUT         0
        set_instance_parameter_value intel_vvp_protocol_conv_0 VVP_USER_SUPPORT       [get_parameter_value PCONV_VVP_USER_SUPPORT]
        set_instance_parameter_value intel_vvp_protocol_conv_0 VIP_USER_SUPPORT       [get_parameter_value PCONV_VIP_USER_SUPPORT]
        set_instance_parameter_value intel_vvp_protocol_conv_0 COLOR_SPACE            [get_parameter_value PCONV_COLOR_SPACE]
        set_instance_parameter_value intel_vvp_protocol_conv_0 CHROMA_SAMPLING        [get_parameter_value PCONV_CHROMA_SAMPLING]
        set_instance_parameter_value intel_vvp_protocol_conv_0 CHROMA_SITING          [get_parameter_value PCONV_CHROMA_SITING]
        set_instance_parameter_value intel_vvp_protocol_conv_0 ENABLE_YCBCR_SWAP      [get_parameter_value PCONV_ENABLE_YCBCR_SWAP]

        add_connection clock_in.out_clk   intel_vvp_protocol_conv_0.main_clock
        add_connection reset_in.out_reset intel_vvp_protocol_conv_0.main_reset
    }

    # -----------------------------------------------------------------------
    # Scaler
    # -----------------------------------------------------------------------
    if {$is_scaler} {
        add_instance intel_vvp_scaler_0 intel_vvp_scaler 24.5.1
        set_instance_parameter_value intel_vvp_scaler_0 EXTERNAL_MODE          1
        set_instance_parameter_value intel_vvp_scaler_0 PIPELINE_READY         0
        set_instance_parameter_value intel_vvp_scaler_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_scaler_0 NUMBER_OF_COLOR_PLANES $nplanes
        set_instance_parameter_value intel_vvp_scaler_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_444             $en444
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_422             $en422
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_420             $en420
        set_instance_parameter_value intel_vvp_scaler_0 RUNTIME_CONTROL        [get_parameter_value SCALER_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_DEBUG           0
        set_instance_parameter_value intel_vvp_scaler_0 SEPARATE_SLAVE_CLOCK   0
        set_instance_parameter_value intel_vvp_scaler_0 MAX_IN_WIDTH           $mwidth
        set_instance_parameter_value intel_vvp_scaler_0 MAX_OUT_WIDTH          $mwidth
        set_instance_parameter_value intel_vvp_scaler_0 OUTPUT_HEIGHT          $mheight
        set_instance_parameter_value intel_vvp_scaler_0 NO_BLANKING            0
        set_instance_parameter_value intel_vvp_scaler_0 RUNTIME_LOAD           [get_parameter_value SCALER_RUNTIME_LOAD]
        set_instance_parameter_value intel_vvp_scaler_0 MEM_INIT               0
        set_instance_parameter_value intel_vvp_scaler_0 ALGORITHM              [get_parameter_value SCALER_ALGORITHM]
        set_instance_parameter_value intel_vvp_scaler_0 EDGE_MIRROR            [get_parameter_value SCALER_EDGE_MIRROR]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_V               [get_parameter_value SCALER_ENABLE_V]
        set_instance_parameter_value intel_vvp_scaler_0 V_TAPS                 [get_parameter_value SCALER_V_TAPS]
        set_instance_parameter_value intel_vvp_scaler_0 V_PHASES               [get_parameter_value SCALER_V_PHASES]
        set_instance_parameter_value intel_vvp_scaler_0 V_COEFF_FUNCTION       [get_parameter_value SCALER_V_COEFF_FUNCTION]
        set_instance_parameter_value intel_vvp_scaler_0 V_PARTIAL_SCALING      0
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_420_MIRROR      0
        set_instance_parameter_value intel_vvp_scaler_0 V_BANKS                1
        set_instance_parameter_value intel_vvp_scaler_0 V_COEFF_SIGNED         1
        set_instance_parameter_value intel_vvp_scaler_0 V_COEFF_INT_BITS       1
        set_instance_parameter_value intel_vvp_scaler_0 V_COEFF_FRAC_BITS      6
        set_instance_parameter_value intel_vvp_scaler_0 V_PRES_FRAC_BITS       0
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_H               [get_parameter_value SCALER_ENABLE_H]
        set_instance_parameter_value intel_vvp_scaler_0 H_TAPS                 [get_parameter_value SCALER_H_TAPS]
        set_instance_parameter_value intel_vvp_scaler_0 H_PHASES               [get_parameter_value SCALER_H_PHASES]
        set_instance_parameter_value intel_vvp_scaler_0 H_COEFF_FUNCTION       [get_parameter_value SCALER_H_COEFF_FUNCTION]
        set_instance_parameter_value intel_vvp_scaler_0 H_PARTIAL_SCALING      0
        set_instance_parameter_value intel_vvp_scaler_0 HALF_RATE_420          0
        set_instance_parameter_value intel_vvp_scaler_0 H_BANKS                1
        set_instance_parameter_value intel_vvp_scaler_0 H_COEFF_SIGNED         1
        set_instance_parameter_value intel_vvp_scaler_0 H_COEFF_INT_BITS       1
        set_instance_parameter_value intel_vvp_scaler_0 H_COEFF_FRAC_BITS      6
        set_instance_parameter_value intel_vvp_scaler_0 P_UPDATE_CMD_SUPPORTED 0
        set_instance_parameter_value intel_vvp_scaler_0 P_CORE_CTRL_ID         0

        add_connection clock_in.out_clk   intel_vvp_scaler_0.main_clock
        add_connection reset_in.out_reset intel_vvp_scaler_0.main_reset

        if {$scaler_has_mm} {
            add_connection mm_bridge_0.m0 intel_vvp_scaler_0.av_mm_control_agent
            # Offset scaler after clipper if both are present, else start at 0
            set scaler_base [expr {$clipper_has_mm ? 0x0200 : 0x0000}]
            set_connection_parameter_value \
                mm_bridge_0.m0/intel_vvp_scaler_0.av_mm_control_agent baseAddress $scaler_base
        }
    }

    # -----------------------------------------------------------------------
    # Chroma Resampler
    # -----------------------------------------------------------------------
    if {$is_crs} {
        add_instance intel_vvp_crs_0 intel_vvp_crs 24.5.1
        set_instance_parameter_value intel_vvp_crs_0 EXTERNAL_MODE           0
        set_instance_parameter_value intel_vvp_crs_0 PIPELINE_READY          0
        set_instance_parameter_value intel_vvp_crs_0 BPS                     $bps
        set_instance_parameter_value intel_vvp_crs_0 PIXELS_IN_PARALLEL_IN   $pip
        set_instance_parameter_value intel_vvp_crs_0 PIXELS_IN_PARALLEL_OUT  $pip
        set_instance_parameter_value intel_vvp_crs_0 MAX_WIDTH               [get_parameter_value CRS_MAX_WIDTH]
        set_instance_parameter_value intel_vvp_crs_0 RUNTIME_CONTROL         [get_parameter_value CRS_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_crs_0 ENABLE_DEBUG            0
        set_instance_parameter_value intel_vvp_crs_0 P_UPDATE_CMD_SUPPORTED  0
        set_instance_parameter_value intel_vvp_crs_0 P_CORE_CTRL_ID          0
        set_instance_parameter_value intel_vvp_crs_0 SEPARATE_SLAVE_CLOCK    0
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_TO_422      [get_parameter_value CRS_SUPPORT_444_TO_422]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_TO_420      [get_parameter_value CRS_SUPPORT_444_TO_420]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_TO_444      [get_parameter_value CRS_SUPPORT_422_TO_444]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_TO_420      [get_parameter_value CRS_SUPPORT_422_TO_420]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_TO_422      [get_parameter_value CRS_SUPPORT_420_TO_422]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_TO_444      [get_parameter_value CRS_SUPPORT_420_TO_444]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_PASS        0
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_PASS        0
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_PASS        0
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_ALGORITHM         [get_parameter_value CRS_HORIZ_ALGORITHM]
        set_instance_parameter_value intel_vvp_crs_0 VERT_ALGORITHM          [get_parameter_value CRS_VERT_ALGORITHM]
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_CO_SITING         [get_parameter_value CRS_HORIZ_CO_SITING]
        set_instance_parameter_value intel_vvp_crs_0 VERT_CO_SITING          [get_parameter_value CRS_VERT_CO_SITING]
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_ENABLE_LUMA_ADAPT 0
        set_instance_parameter_value intel_vvp_crs_0 VERT_ENABLE_LUMA_ADAPT  0
        set_instance_parameter_value intel_vvp_crs_0 NO_BLANKING             0

        add_connection clock_in.out_clk   intel_vvp_crs_0.main_clock
        add_connection reset_in.out_reset intel_vvp_crs_0.main_reset
    }

    # -----------------------------------------------------------------------
    # Deinterlacer
    # -----------------------------------------------------------------------
    if {$is_dil} {
        add_instance intel_vvp_dil_0 intel_vvp_dil 24.5.1
        set_instance_parameter_value intel_vvp_dil_0 EXTERNAL_MODE          0
        set_instance_parameter_value intel_vvp_dil_0 PIPELINE_READY         0
        set_instance_parameter_value intel_vvp_dil_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_dil_0 NUMBER_OF_COLOR_PLANES $nplanes
        set_instance_parameter_value intel_vvp_dil_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_dil_0 MAX_WIDTH              [get_parameter_value DIL_MAX_WIDTH]
        set_instance_parameter_value intel_vvp_dil_0 MEM_BUFF_BASE_ADDR     [get_parameter_value DIL_MEM_BUFF_BASE_ADDR]
        set_instance_parameter_value intel_vvp_dil_0 MEM_BUFF_LINE_STRIDE   [get_parameter_value DIL_MEM_BUFF_LINE_STRIDE]
        set_instance_parameter_value intel_vvp_dil_0 WRITE_FIFO_DEPTH       [get_parameter_value DIL_WRITE_FIFO_DEPTH]
        set_instance_parameter_value intel_vvp_dil_0 READ_FIFO_DEPTH        [get_parameter_value DIL_READ_FIFO_DEPTH]
        set_instance_parameter_value intel_vvp_dil_0 PACKING                PERFECT
        set_instance_parameter_value intel_vvp_dil_0 CLOCKS_ARE_SEPARATE    1
        set_instance_parameter_value intel_vvp_dil_0 P_AV_MM_DATA_WIDTH     32
        set_instance_parameter_value intel_vvp_dil_0 P_AV_MM_ADDR_WIDTH     32
        set_instance_parameter_value intel_vvp_dil_0 WRITE_BURST_TARGET     [get_parameter_value DIL_WRITE_BURST_TARGET]
        set_instance_parameter_value intel_vvp_dil_0 READ_BURST_TARGET      [get_parameter_value DIL_READ_BURST_TARGET]
        set_instance_parameter_value intel_vvp_dil_0 DIL_MODE               [get_parameter_value DIL_MODE]
        set_instance_parameter_value intel_vvp_dil_0 BOB_DIL_MODE           [get_parameter_value DIL_BOB_MODE]
        set_instance_parameter_value intel_vvp_dil_0 SEPARATE_SLAVE_CLOCK   0
        set_instance_parameter_value intel_vvp_dil_0 RUNTIME_CONTROL        0
        set_instance_parameter_value intel_vvp_dil_0 ENABLE_DEBUG           0
        set_instance_parameter_value intel_vvp_dil_0 FIFO                   0

        add_connection clock_in.out_clk   intel_vvp_dil_0.main_clock
        add_connection reset_in.out_reset intel_vvp_dil_0.main_reset
    }

    # -----------------------------------------------------------------------
    # Video stream connections (topology-dependent)
    # -----------------------------------------------------------------------
    if {$topo eq "FULL"} {
        add_connection intel_vvp_clipper_0.axi4s_vid_out       intel_vvp_protocol_conv_0.axi4s_vid_in
        add_connection intel_vvp_protocol_conv_0.axi4s_vid_out intel_vvp_scaler_0.axi4s_vid_in
    }

    # -----------------------------------------------------------------------
    # External interface exports (topology-dependent)
    # -----------------------------------------------------------------------
    add_interface clk   clock end
    set_interface_property clk   EXPORT_OF clock_in.in_clk

    add_interface reset reset end
    set_interface_property reset EXPORT_OF reset_in.in_reset

    if {$need_bridge} {
        add_interface av_mm_control avalon end
        set_interface_property av_mm_control EXPORT_OF mm_bridge_0.s0
    }

    if {$is_tpg} {
        add_interface tpg_axi4s_vid_out axi4stream start
        set_interface_property tpg_axi4s_vid_out EXPORT_OF intel_vvp_tpg_0.axi4s_vid_out
    }

    if {$topo eq "FULL"} {
        add_interface clipper_axi4s_vid_in axi4stream end
        set_interface_property clipper_axi4s_vid_in EXPORT_OF intel_vvp_clipper_0.axi4s_vid_in

        add_interface scaler_axi4s_vid_out axi4stream start
        set_interface_property scaler_axi4s_vid_out EXPORT_OF intel_vvp_scaler_0.axi4s_vid_out
    }

    if {$topo eq "SCALER_ONLY"} {
        add_interface scaler_axi4s_vid_in axi4stream end
        set_interface_property scaler_axi4s_vid_in EXPORT_OF intel_vvp_scaler_0.axi4s_vid_in

        add_interface scaler_axi4s_vid_out axi4stream start
        set_interface_property scaler_axi4s_vid_out EXPORT_OF intel_vvp_scaler_0.axi4s_vid_out
    }

    if {$topo eq "CSC_ONLY"} {
        add_interface pconv_axi4s_vid_in axi4stream end
        set_interface_property pconv_axi4s_vid_in EXPORT_OF intel_vvp_protocol_conv_0.axi4s_vid_in

        add_interface pconv_axi4s_vid_out axi4stream start
        set_interface_property pconv_axi4s_vid_out EXPORT_OF intel_vvp_protocol_conv_0.axi4s_vid_out
    }

    if {$is_crs} {
        add_interface crs_axi4s_vid_in axi4stream end
        set_interface_property crs_axi4s_vid_in EXPORT_OF intel_vvp_crs_0.axi4s_vid_in

        add_interface crs_axi4s_vid_out axi4stream start
        set_interface_property crs_axi4s_vid_out EXPORT_OF intel_vvp_crs_0.axi4s_vid_out
    }

    if {$is_dil} {
        add_interface dil_axi4s_vid_in axi4stream end
        set_interface_property dil_axi4s_vid_in EXPORT_OF intel_vvp_dil_0.axi4s_vid_in

        add_interface dil_axi4s_vid_out axi4stream start
        set_interface_property dil_axi4s_vid_out EXPORT_OF intel_vvp_dil_0.axi4s_vid_out
    }
}
