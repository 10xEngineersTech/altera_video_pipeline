package require qsys

set_module_property NAME                 intel_vvp_pipeline2
set_module_property DISPLAY_NAME         "Intel VVP Pipeline2"
set_module_property VERSION              1.0
set_module_property DESCRIPTION          "Intel VVP Video Processing Pipeline - VPSS-equivalent"
set_module_property COMPOSITION_CALLBACK compose

# ---------------------------------------------------------------------------
# GENERAL parameters
# ---------------------------------------------------------------------------
add_parameter TOPOLOGY STRING "FULL"
set_parameter_property TOPOLOGY DISPLAY_NAME   "Video Processing Functionality"
set_parameter_property TOPOLOGY ALLOWED_RANGES {FULL SCALER_ONLY CSC_ONLY RESAMPLER_ONLY}

add_parameter BPS INTEGER 8
set_parameter_property BPS DISPLAY_NAME   "Bits per color sample"
set_parameter_property BPS ALLOWED_RANGES {8 10 12 16}

add_parameter NUMBER_OF_COLOR_PLANES INTEGER 3
set_parameter_property NUMBER_OF_COLOR_PLANES DISPLAY_NAME   "Number of color planes"
set_parameter_property NUMBER_OF_COLOR_PLANES ALLOWED_RANGES {1 2 3 4}

add_parameter PIXELS_IN_PARALLEL INTEGER 1
set_parameter_property PIXELS_IN_PARALLEL DISPLAY_NAME   "Number of pixels in parallel"
set_parameter_property PIXELS_IN_PARALLEL ALLOWED_RANGES {1 2 4 6 8}

add_parameter MAX_WIDTH INTEGER 8192
set_parameter_property MAX_WIDTH DISPLAY_NAME "Max Frame Width (pixels)"

add_parameter MAX_HEIGHT INTEGER 4320
set_parameter_property MAX_HEIGHT DISPLAY_NAME "Max Frame Height (lines)"

add_parameter COLOR_SPACE STRING "YUV_422"
set_parameter_property COLOR_SPACE DISPLAY_NAME   "Color Space"
set_parameter_property COLOR_SPACE ALLOWED_RANGES {RGB YUV_444 YUV_422 YUV_420}

add_parameter AXIS_LITE_MODE INTEGER 0
set_parameter_property AXIS_LITE_MODE DISPLAY_NAME "Lite mode"
set_parameter_property AXIS_LITE_MODE DISPLAY_HINT "boolean"

add_parameter ENABLE_DIL INTEGER 1
set_parameter_property ENABLE_DIL DISPLAY_NAME "Enable Deinterlacer"
set_parameter_property ENABLE_DIL DISPLAY_HINT "boolean"

add_parameter ENABLE_CRS INTEGER 1
set_parameter_property ENABLE_CRS DISPLAY_NAME "Enable Chroma Resampler"
set_parameter_property ENABLE_CRS DISPLAY_HINT "boolean"

add_parameter ENABLE_CLIPPER INTEGER 1
set_parameter_property ENABLE_CLIPPER DISPLAY_NAME "Enable Clipper"
set_parameter_property ENABLE_CLIPPER DISPLAY_HINT "boolean"

add_parameter ENABLE_PCONV INTEGER 1
set_parameter_property ENABLE_PCONV DISPLAY_NAME "Enable Protocol Converter"
set_parameter_property ENABLE_PCONV DISPLAY_HINT "boolean"

add_parameter ENABLE_SCALER INTEGER 1
set_parameter_property ENABLE_SCALER DISPLAY_NAME "Enable Scaler"
set_parameter_property ENABLE_SCALER DISPLAY_HINT "boolean"

# ---------------------------------------------------------------------------
# DEINTERLACER parameters
# ---------------------------------------------------------------------------
add_parameter DIL_MODE STRING "BOB"
set_parameter_property DIL_MODE DISPLAY_NAME   "Deinterlacing Type"
set_parameter_property DIL_MODE ALLOWED_RANGES {BOB WEAVE MOTION_ADAPTIVE}

add_parameter DIL_EXTERNAL_MODE INTEGER 0
set_parameter_property DIL_EXTERNAL_MODE DISPLAY_NAME "Lite mode"
set_parameter_property DIL_EXTERNAL_MODE DISPLAY_HINT "boolean"

add_parameter DIL_AV_MM_DATA_WIDTH INTEGER 32
set_parameter_property DIL_AV_MM_DATA_WIDTH DISPLAY_NAME "Avalon memory-mapped local ports width"
set_parameter_property DIL_AV_MM_DATA_WIDTH ALLOWED_RANGES {16 32 64 128 256}

add_parameter DIL_AV_MM_ADDR_WIDTH INTEGER 32
set_parameter_property DIL_AV_MM_ADDR_WIDTH DISPLAY_NAME "Avalon memory-mapped host(s) local ports address width"

add_parameter DIL_WRITE_FIFO_DEPTH INTEGER 64
set_parameter_property DIL_WRITE_FIFO_DEPTH DISPLAY_NAME "The depth of the write FIFO"
set_parameter_property DIL_WRITE_FIFO_DEPTH ALLOWED_RANGES {32 64 128 256 512 1024}

add_parameter DIL_WRITE_BURST_TARGET INTEGER 32
set_parameter_property DIL_WRITE_BURST_TARGET DISPLAY_NAME "Avalon memory-mapped write burst target"
set_parameter_property DIL_WRITE_BURST_TARGET ALLOWED_RANGES {2 4 8 16 32 64 128}

add_parameter DIL_READ_FIFO_DEPTH INTEGER 64
set_parameter_property DIL_READ_FIFO_DEPTH DISPLAY_NAME "The depth of the read FIFO"
set_parameter_property DIL_READ_FIFO_DEPTH ALLOWED_RANGES {32 64 128 256 512 1024}

add_parameter DIL_READ_BURST_TARGET INTEGER 32
set_parameter_property DIL_READ_BURST_TARGET DISPLAY_NAME "Avalon memory-mapped read burst target"
set_parameter_property DIL_READ_BURST_TARGET ALLOWED_RANGES {2 4 8 16 32 64 128}

add_parameter DIL_MEM_BUFF_BASE_ADDR INTEGER 0
set_parameter_property DIL_MEM_BUFF_BASE_ADDR DISPLAY_NAME "Frame buffer memory base address"

add_parameter DIL_MEM_BUFF_LINE_STRIDE INTEGER 32768
set_parameter_property DIL_MEM_BUFF_LINE_STRIDE DISPLAY_NAME "Inter-line stride"

add_parameter DIL_PACKING STRING "PERFECT"
set_parameter_property DIL_PACKING DISPLAY_NAME   "Packing method"
set_parameter_property DIL_PACKING ALLOWED_RANGES {PERFECT WORD_ALIGNED}

add_parameter DIL_CLOCKS_ARE_SEPARATE INTEGER 1
set_parameter_property DIL_CLOCKS_ARE_SEPARATE DISPLAY_NAME "Separate clock for the Avalon memory-mapped host interface(s)"
set_parameter_property DIL_CLOCKS_ARE_SEPARATE DISPLAY_HINT "boolean"

add_parameter DIL_RUNTIME_CONTROL INTEGER 0
set_parameter_property DIL_RUNTIME_CONTROL DISPLAY_NAME "Memory mapped control interface"
set_parameter_property DIL_RUNTIME_CONTROL DISPLAY_HINT "boolean"

add_parameter DIL_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property DIL_SEPARATE_SLAVE_CLOCK DISPLAY_NAME "Separate clock for control interface"
set_parameter_property DIL_SEPARATE_SLAVE_CLOCK DISPLAY_HINT "boolean"

add_parameter DIL_ENABLE_DEBUG INTEGER 0
set_parameter_property DIL_ENABLE_DEBUG DISPLAY_NAME "Debug features"
set_parameter_property DIL_ENABLE_DEBUG DISPLAY_HINT "boolean"

add_parameter DIL_BOB_MODE STRING "DEINTERLACE_F0_ONLY"
set_parameter_property DIL_BOB_MODE DISPLAY_NAME   "Bob deinterlacing Type"
set_parameter_property DIL_BOB_MODE ALLOWED_RANGES {DEINTERLACE_F0_ONLY DEINTERLACE_F1_ONLY DEINTERLACE_BOTH}

add_parameter DIL_MAX_WIDTH INTEGER 2048
set_parameter_property DIL_MAX_WIDTH DISPLAY_NAME "Maximum interlaced field width"

add_parameter DIL_PIPELINE_READY INTEGER 0
set_parameter_property DIL_PIPELINE_READY DISPLAY_NAME "Pipeline ready signals"
set_parameter_property DIL_PIPELINE_READY DISPLAY_HINT "boolean"

add_parameter DIL_FIFO INTEGER 0
set_parameter_property DIL_FIFO DISPLAY_NAME "Use FIFO"
set_parameter_property DIL_FIFO DISPLAY_HINT "boolean"

# ---------------------------------------------------------------------------
# CHROMA RESAMPLER parameters
# ---------------------------------------------------------------------------
add_parameter CRS_EXTERNAL_MODE INTEGER 0
set_parameter_property CRS_EXTERNAL_MODE DISPLAY_NAME "Lite mode"
set_parameter_property CRS_EXTERNAL_MODE DISPLAY_HINT "boolean"

add_parameter CRS_NO_BLANKING INTEGER 0
set_parameter_property CRS_NO_BLANKING DISPLAY_NAME "Disable flush/fill between frames"
set_parameter_property CRS_NO_BLANKING DISPLAY_HINT "boolean"

add_parameter CRS_MAX_WIDTH INTEGER 16384
set_parameter_property CRS_MAX_WIDTH DISPLAY_NAME "Maximum field width"

add_parameter CRS_SUPPORT_420_PASS INTEGER 0
set_parameter_property CRS_SUPPORT_420_PASS DISPLAY_NAME "4:2:0 passthrough"
set_parameter_property CRS_SUPPORT_420_PASS DISPLAY_HINT "boolean"

add_parameter CRS_SUPPORT_420_TO_422 INTEGER 0
set_parameter_property CRS_SUPPORT_420_TO_422 DISPLAY_NAME "4:2:0 to 4:2:2 conversion"
set_parameter_property CRS_SUPPORT_420_TO_422 DISPLAY_HINT "boolean"

add_parameter CRS_SUPPORT_420_TO_444 INTEGER 0
set_parameter_property CRS_SUPPORT_420_TO_444 DISPLAY_NAME "4:2:0 to 4:4:4 conversion"
set_parameter_property CRS_SUPPORT_420_TO_444 DISPLAY_HINT "boolean"

add_parameter CRS_SUPPORT_422_PASS INTEGER 0
set_parameter_property CRS_SUPPORT_422_PASS DISPLAY_NAME "4:2:2 passthrough"
set_parameter_property CRS_SUPPORT_422_PASS DISPLAY_HINT "boolean"

add_parameter CRS_SUPPORT_422_TO_420 INTEGER 0
set_parameter_property CRS_SUPPORT_422_TO_420 DISPLAY_NAME "4:2:2 to 4:2:0 conversion"
set_parameter_property CRS_SUPPORT_422_TO_420 DISPLAY_HINT "boolean"

add_parameter CRS_SUPPORT_422_TO_444 INTEGER 1
set_parameter_property CRS_SUPPORT_422_TO_444 DISPLAY_NAME "4:2:2 to 4:4:4 conversion"
set_parameter_property CRS_SUPPORT_422_TO_444 DISPLAY_HINT "boolean"

add_parameter CRS_SUPPORT_444_PASS INTEGER 0
set_parameter_property CRS_SUPPORT_444_PASS DISPLAY_NAME "4:4:4 passthrough"
set_parameter_property CRS_SUPPORT_444_PASS DISPLAY_HINT "boolean"

add_parameter CRS_SUPPORT_444_TO_420 INTEGER 0
set_parameter_property CRS_SUPPORT_444_TO_420 DISPLAY_NAME "4:4:4 to 4:2:0 conversion"
set_parameter_property CRS_SUPPORT_444_TO_420 DISPLAY_HINT "boolean"

add_parameter CRS_SUPPORT_444_TO_422 INTEGER 0
set_parameter_property CRS_SUPPORT_444_TO_422 DISPLAY_NAME "4:4:4 to 4:2:2 conversion"
set_parameter_property CRS_SUPPORT_444_TO_422 DISPLAY_HINT "boolean"

add_parameter CRS_HORIZ_ALGORITHM STRING "NEAREST_NEIGHBOUR"
set_parameter_property CRS_HORIZ_ALGORITHM DISPLAY_NAME   "Horizontal resampling algorithm"
set_parameter_property CRS_HORIZ_ALGORITHM ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR FILTERED}

add_parameter CRS_HORIZ_CO_SITING STRING "LEFT"
set_parameter_property CRS_HORIZ_CO_SITING DISPLAY_NAME   "Horizontal chroma siting"
set_parameter_property CRS_HORIZ_CO_SITING ALLOWED_RANGES {LEFT CENTER}

add_parameter CRS_HORIZ_ENABLE_LUMA_ADAPT INTEGER 0
set_parameter_property CRS_HORIZ_ENABLE_LUMA_ADAPT DISPLAY_NAME "Horizontal luma adaptive resampling"
set_parameter_property CRS_HORIZ_ENABLE_LUMA_ADAPT DISPLAY_HINT "boolean"

add_parameter CRS_VERT_ALGORITHM STRING "BILINEAR"
set_parameter_property CRS_VERT_ALGORITHM DISPLAY_NAME   "Vertical resampling algorithm"
set_parameter_property CRS_VERT_ALGORITHM ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR FILTERED}

add_parameter CRS_VERT_CO_SITING STRING "TOP"
set_parameter_property CRS_VERT_CO_SITING DISPLAY_NAME   "Vertical chroma siting"
set_parameter_property CRS_VERT_CO_SITING ALLOWED_RANGES {TOP CENTER}

add_parameter CRS_VERT_ENABLE_LUMA_ADAPT INTEGER 0
set_parameter_property CRS_VERT_ENABLE_LUMA_ADAPT DISPLAY_NAME "Vertical luma adaptive resampling"
set_parameter_property CRS_VERT_ENABLE_LUMA_ADAPT DISPLAY_HINT "boolean"

add_parameter CRS_RUNTIME_CONTROL INTEGER 0
set_parameter_property CRS_RUNTIME_CONTROL DISPLAY_NAME "Memory-mapped control interface"
set_parameter_property CRS_RUNTIME_CONTROL DISPLAY_HINT "boolean"

add_parameter CRS_PIPELINE_READY INTEGER 0
set_parameter_property CRS_PIPELINE_READY DISPLAY_NAME "Pipeline ready signals"
set_parameter_property CRS_PIPELINE_READY DISPLAY_HINT "boolean"

add_parameter CRS_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property CRS_SEPARATE_SLAVE_CLOCK DISPLAY_NAME "Separate clock for control interface"
set_parameter_property CRS_SEPARATE_SLAVE_CLOCK DISPLAY_HINT "boolean"

add_parameter CRS_ENABLE_DEBUG INTEGER 0
set_parameter_property CRS_ENABLE_DEBUG DISPLAY_NAME "Debug features"
set_parameter_property CRS_ENABLE_DEBUG DISPLAY_HINT "boolean"

# ---------------------------------------------------------------------------
# CLIPPER parameters
# ---------------------------------------------------------------------------
add_parameter CL_BPS INTEGER 8
set_parameter_property CL_BPS DISPLAY_NAME "Bits per color sample"
set_parameter_property CL_BPS ALLOWED_RANGES {8 10 12 16}

add_parameter CL_NUMBER_OF_COLOR_PLANES INTEGER 3
set_parameter_property CL_NUMBER_OF_COLOR_PLANES DISPLAY_NAME "Number of color planes"
set_parameter_property CL_NUMBER_OF_COLOR_PLANES ALLOWED_RANGES {1 2 3 4}

add_parameter CL_PIXELS_IN_PARALLEL INTEGER 1
set_parameter_property CL_PIXELS_IN_PARALLEL DISPLAY_NAME "Number of pixels in parallel"
set_parameter_property CL_PIXELS_IN_PARALLEL ALLOWED_RANGES {1 2 4 6 8}

add_parameter CL_EXTERNAL_MODE INTEGER 0
set_parameter_property CL_EXTERNAL_MODE DISPLAY_NAME "Lite mode"
set_parameter_property CL_EXTERNAL_MODE DISPLAY_HINT "boolean"

add_parameter CL_RUNTIME_CONTROL INTEGER 1
set_parameter_property CL_RUNTIME_CONTROL DISPLAY_NAME "Memory mapped control interface"
set_parameter_property CL_RUNTIME_CONTROL DISPLAY_HINT "boolean"

add_parameter CL_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property CL_SEPARATE_SLAVE_CLOCK DISPLAY_NAME "Separate clock for control interface"
set_parameter_property CL_SEPARATE_SLAVE_CLOCK DISPLAY_HINT "boolean"

add_parameter CL_ENABLE_DEBUG INTEGER 0
set_parameter_property CL_ENABLE_DEBUG DISPLAY_NAME "Debug features"
set_parameter_property CL_ENABLE_DEBUG DISPLAY_HINT "boolean"

add_parameter CL_CLIPPING_METHOD STRING "OFFSETS"
set_parameter_property CL_CLIPPING_METHOD DISPLAY_NAME   "Clipping method"
set_parameter_property CL_CLIPPING_METHOD ALLOWED_RANGES {OFFSETS RECTANGLE}

add_parameter CL_LEFT_OFFSET INTEGER 0
set_parameter_property CL_LEFT_OFFSET DISPLAY_NAME "Left Offset"

add_parameter CL_TOP_OFFSET INTEGER 0
set_parameter_property CL_TOP_OFFSET DISPLAY_NAME "Top Offset"

add_parameter CL_RIGHT_OFFSET INTEGER 0
set_parameter_property CL_RIGHT_OFFSET DISPLAY_NAME "Right Offset"

add_parameter CL_BOTTOM_OFFSET INTEGER 0
set_parameter_property CL_BOTTOM_OFFSET DISPLAY_NAME "Bottom Offset"

add_parameter CL_RECTANGLE_WIDTH INTEGER 1920
set_parameter_property CL_RECTANGLE_WIDTH DISPLAY_NAME "Output Width"

add_parameter CL_RECTANGLE_HEIGHT INTEGER 1080
set_parameter_property CL_RECTANGLE_HEIGHT DISPLAY_NAME "Output Height"

# ---------------------------------------------------------------------------
# PROTOCOL CONVERTER parameters
# ---------------------------------------------------------------------------
add_parameter PCONV_ENABLE_YCBCR_SWAP INTEGER 0
set_parameter_property PCONV_ENABLE_YCBCR_SWAP DISPLAY_NAME "YCbCr 444 color swap"
set_parameter_property PCONV_ENABLE_YCBCR_SWAP DISPLAY_HINT "boolean"

add_parameter PCONV_RUNTIME_CONTROL INTEGER 0
set_parameter_property PCONV_RUNTIME_CONTROL DISPLAY_NAME "Memory mapped control interface"
set_parameter_property PCONV_RUNTIME_CONTROL DISPLAY_HINT "boolean"

add_parameter PCONV_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property PCONV_SEPARATE_SLAVE_CLOCK DISPLAY_NAME "Separate clock for control interface"
set_parameter_property PCONV_SEPARATE_SLAVE_CLOCK DISPLAY_HINT "boolean"

add_parameter PCONV_ENABLE_DEBUG INTEGER 0
set_parameter_property PCONV_ENABLE_DEBUG DISPLAY_NAME "Debug features"
set_parameter_property PCONV_ENABLE_DEBUG DISPLAY_HINT "boolean"

add_parameter PCONV_PIPELINE_READY INTEGER 0
set_parameter_property PCONV_PIPELINE_READY DISPLAY_NAME "Pipeline ready signals"
set_parameter_property PCONV_PIPELINE_READY DISPLAY_HINT "boolean"

add_parameter PCONV_INPUT_MODE STRING "INTERNAL"
set_parameter_property PCONV_INPUT_MODE DISPLAY_NAME   "Input protocol variant"
set_parameter_property PCONV_INPUT_MODE ALLOWED_RANGES {"INTERNAL:Intel FPGA Streaming Video Full" "EXTERNAL:Avalon Streaming Video"}

add_parameter PCONV_OUTPUT_MODE STRING "EXTERNAL"
set_parameter_property PCONV_OUTPUT_MODE DISPLAY_NAME   "Output protocol variant"
set_parameter_property PCONV_OUTPUT_MODE ALLOWED_RANGES {"INTERNAL:Intel FPGA Streaming Video Full" "EXTERNAL:Avalon Streaming Video"}

add_parameter PCONV_VIP_USER_SUPPORT STRING "DISCARD"
set_parameter_property PCONV_VIP_USER_SUPPORT DISPLAY_NAME   "Avalon-ST Video user packet handling"
set_parameter_property PCONV_VIP_USER_SUPPORT ALLOWED_RANGES {DISCARD PASS}

add_parameter PCONV_COLOR_SPACE STRING "YCbCr"
set_parameter_property PCONV_COLOR_SPACE DISPLAY_NAME   "Video color space"
set_parameter_property PCONV_COLOR_SPACE ALLOWED_RANGES {RGB YCbCr YUV}

add_parameter PCONV_CHROMA_SAMPLING STRING "422"
set_parameter_property PCONV_CHROMA_SAMPLING DISPLAY_NAME   "Video chroma sampling"
set_parameter_property PCONV_CHROMA_SAMPLING ALLOWED_RANGES {444 422 420}

add_parameter PCONV_CHROMA_SITING STRING "TOP_LEFT"
set_parameter_property PCONV_CHROMA_SITING DISPLAY_NAME   "Video chroma siting"
set_parameter_property PCONV_CHROMA_SITING ALLOWED_RANGES {TOP_LEFT TOP_CENTER CENTER}

add_parameter PCONV_CLIP_LONG_FIELDS INTEGER 0
set_parameter_property PCONV_CLIP_LONG_FIELDS DISPLAY_NAME "Clip long fields"
set_parameter_property PCONV_CLIP_LONG_FIELDS DISPLAY_HINT "boolean"

add_parameter PCONV_ENABLE_TIMEOUT INTEGER 0
set_parameter_property PCONV_ENABLE_TIMEOUT DISPLAY_NAME "Enable timeout"
set_parameter_property PCONV_ENABLE_TIMEOUT DISPLAY_HINT "boolean"

add_parameter PCONV_VVP_USER_SUPPORT STRING "NONE_ALLOWED"
set_parameter_property PCONV_VVP_USER_SUPPORT DISPLAY_NAME   "Intel FPGA Streaming Video aux packet handling"
set_parameter_property PCONV_VVP_USER_SUPPORT ALLOWED_RANGES {NONE_ALLOWED PASS EMBED}

# ---------------------------------------------------------------------------
# SCALER parameters
# ---------------------------------------------------------------------------
add_parameter SC_EXTERNAL_MODE INTEGER 1
set_parameter_property SC_EXTERNAL_MODE DISPLAY_NAME "Lite mode"
set_parameter_property SC_EXTERNAL_MODE DISPLAY_HINT "boolean"

add_parameter SC_ENABLE_444 INTEGER 1
set_parameter_property SC_ENABLE_444 DISPLAY_NAME "444 chroma sampling"
set_parameter_property SC_ENABLE_444 DISPLAY_HINT "boolean"

add_parameter SC_ENABLE_422 INTEGER 0
set_parameter_property SC_ENABLE_422 DISPLAY_NAME "422 chroma sampling"
set_parameter_property SC_ENABLE_422 DISPLAY_HINT "boolean"

add_parameter SC_ENABLE_420 INTEGER 0
set_parameter_property SC_ENABLE_420 DISPLAY_NAME "420 chroma sampling"
set_parameter_property SC_ENABLE_420 DISPLAY_HINT "boolean"

add_parameter SC_NO_BLANKING INTEGER 0
set_parameter_property SC_NO_BLANKING DISPLAY_NAME "Disable flush/fill between frames"
set_parameter_property SC_NO_BLANKING DISPLAY_HINT "boolean"

add_parameter SC_MAX_IN_WIDTH INTEGER 8192
set_parameter_property SC_MAX_IN_WIDTH DISPLAY_NAME "Maximum input field width"

add_parameter SC_MAX_OUT_WIDTH INTEGER 8192
set_parameter_property SC_MAX_OUT_WIDTH DISPLAY_NAME "Maximum output field width"

add_parameter SC_OUTPUT_HEIGHT INTEGER 4320
set_parameter_property SC_OUTPUT_HEIGHT DISPLAY_NAME "Output Picture Height"

add_parameter SC_RUNTIME_CONTROL INTEGER 1
set_parameter_property SC_RUNTIME_CONTROL DISPLAY_NAME "Memory-mapped control interface"
set_parameter_property SC_RUNTIME_CONTROL DISPLAY_HINT "boolean"

add_parameter SC_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property SC_SEPARATE_SLAVE_CLOCK DISPLAY_NAME "Separate clock for control interface"
set_parameter_property SC_SEPARATE_SLAVE_CLOCK DISPLAY_HINT "boolean"

add_parameter SC_ENABLE_DEBUG INTEGER 0
set_parameter_property SC_ENABLE_DEBUG DISPLAY_NAME "Debug features"
set_parameter_property SC_ENABLE_DEBUG DISPLAY_HINT "boolean"

add_parameter SC_PIPELINE_READY INTEGER 0
set_parameter_property SC_PIPELINE_READY DISPLAY_NAME "Pipeline ready signals"
set_parameter_property SC_PIPELINE_READY DISPLAY_HINT "boolean"

add_parameter SC_ALGORITHM STRING "NEAREST_NEIGHBOUR"
set_parameter_property SC_ALGORITHM DISPLAY_NAME   "Scaling algorithm"
set_parameter_property SC_ALGORITHM ALLOWED_RANGES {NEAREST_NEIGHBOUR BILINEAR POLYPHASE}

add_parameter SC_EDGE_MIRROR STRING "REPLICATE"
set_parameter_property SC_EDGE_MIRROR DISPLAY_NAME   "Edge behavior"
set_parameter_property SC_EDGE_MIRROR ALLOWED_RANGES {REPLICATE REFLECT}

add_parameter SC_RUNTIME_LOAD INTEGER 1
set_parameter_property SC_RUNTIME_LOAD DISPLAY_NAME "Runtime coefficient updates"
set_parameter_property SC_RUNTIME_LOAD DISPLAY_HINT "boolean"

add_parameter SC_MEM_INIT INTEGER 0
set_parameter_property SC_MEM_INIT DISPLAY_NAME "Initialize coefficients at startup"
set_parameter_property SC_MEM_INIT DISPLAY_HINT "boolean"

add_parameter SC_ENABLE_V INTEGER 1
set_parameter_property SC_ENABLE_V DISPLAY_NAME "Vertical scaling"
set_parameter_property SC_ENABLE_V DISPLAY_HINT "boolean"

add_parameter SC_V_PARTIAL_SCALING INTEGER 0
set_parameter_property SC_V_PARTIAL_SCALING DISPLAY_NAME "Vertical partial image scaling"
set_parameter_property SC_V_PARTIAL_SCALING DISPLAY_HINT "boolean"

add_parameter SC_ENABLE_420_MIRROR INTEGER 0
set_parameter_property SC_ENABLE_420_MIRROR DISPLAY_NAME "Mirror 420 chroma data"
set_parameter_property SC_ENABLE_420_MIRROR DISPLAY_HINT "boolean"

add_parameter SC_V_TAPS INTEGER 4
set_parameter_property SC_V_TAPS DISPLAY_NAME "Number of vertical taps"
set_parameter_property SC_V_TAPS ALLOWED_RANGES {1 2 4 8 12 16 32 64}

add_parameter SC_V_PHASES INTEGER 16
set_parameter_property SC_V_PHASES DISPLAY_NAME "Number of vertical phases"
set_parameter_property SC_V_PHASES ALLOWED_RANGES {2 4 8 16 32 64 128 256}

add_parameter SC_V_BANKS INTEGER 1
set_parameter_property SC_V_BANKS DISPLAY_NAME "Number of vertical banks"
set_parameter_property SC_V_BANKS ALLOWED_RANGES {1 2 4 8 16}

add_parameter SC_V_COEFF_SIGNED INTEGER 1
set_parameter_property SC_V_COEFF_SIGNED DISPLAY_NAME "Use signed vertical coefficients"
set_parameter_property SC_V_COEFF_SIGNED DISPLAY_HINT "boolean"

add_parameter SC_V_COEFF_INT_BITS INTEGER 1
set_parameter_property SC_V_COEFF_INT_BITS DISPLAY_NAME "Vertical coefficient integer bits"

add_parameter SC_V_COEFF_FRAC_BITS INTEGER 6
set_parameter_property SC_V_COEFF_FRAC_BITS DISPLAY_NAME "Vertical coefficient fraction bits"

add_parameter SC_V_PRES_FRAC_BITS INTEGER 0
set_parameter_property SC_V_PRES_FRAC_BITS DISPLAY_NAME "Fraction bits preserved between vertical and horizontal scaling"

add_parameter SC_V_COEFF_FUNCTION STRING "LANCZOS_2"
set_parameter_property SC_V_COEFF_FUNCTION DISPLAY_NAME   "Vertical coefficient function"
set_parameter_property SC_V_COEFF_FUNCTION ALLOWED_RANGES {BICUBIC LANCZOS_1 LANCZOS_2 LANCZOS_3 LANCZOS_4}

add_parameter SC_V_INIT_FILE STRING ""
set_parameter_property SC_V_INIT_FILE DISPLAY_NAME "Vertical coefficient init file"

add_parameter SC_ENABLE_H INTEGER 1
set_parameter_property SC_ENABLE_H DISPLAY_NAME "Horizontal scaling"
set_parameter_property SC_ENABLE_H DISPLAY_HINT "boolean"

add_parameter SC_H_PARTIAL_SCALING INTEGER 0
set_parameter_property SC_H_PARTIAL_SCALING DISPLAY_NAME "Horizontal partial image scaling"
set_parameter_property SC_H_PARTIAL_SCALING DISPLAY_HINT "boolean"

add_parameter SC_HALF_RATE_420 INTEGER 0
set_parameter_property SC_HALF_RATE_420 DISPLAY_NAME "Half rate 420"
set_parameter_property SC_HALF_RATE_420 DISPLAY_HINT "boolean"

add_parameter SC_H_TAPS INTEGER 4
set_parameter_property SC_H_TAPS DISPLAY_NAME "Number of horizontal taps"
set_parameter_property SC_H_TAPS ALLOWED_RANGES {1 2 4 8 12 16 32 64}

add_parameter SC_H_PHASES INTEGER 16
set_parameter_property SC_H_PHASES DISPLAY_NAME "Number of horizontal phases"
set_parameter_property SC_H_PHASES ALLOWED_RANGES {2 4 8 16 32 64 128 256}

add_parameter SC_H_BANKS INTEGER 1
set_parameter_property SC_H_BANKS DISPLAY_NAME "Number of horizontal banks"
set_parameter_property SC_H_BANKS ALLOWED_RANGES {1 2 4 8 16}

add_parameter SC_H_COEFF_SIGNED INTEGER 1
set_parameter_property SC_H_COEFF_SIGNED DISPLAY_NAME "Use signed horizontal coefficients"
set_parameter_property SC_H_COEFF_SIGNED DISPLAY_HINT "boolean"

add_parameter SC_H_COEFF_INT_BITS INTEGER 1
set_parameter_property SC_H_COEFF_INT_BITS DISPLAY_NAME "Horizontal coefficient integer bits"

add_parameter SC_H_COEFF_FRAC_BITS INTEGER 6
set_parameter_property SC_H_COEFF_FRAC_BITS DISPLAY_NAME "Horizontal coefficient fraction bits"

add_parameter SC_H_COEFF_FUNCTION STRING "LANCZOS_2"
set_parameter_property SC_H_COEFF_FUNCTION DISPLAY_NAME   "Horizontal coefficient function"
set_parameter_property SC_H_COEFF_FUNCTION ALLOWED_RANGES {BICUBIC LANCZOS_1 LANCZOS_2 LANCZOS_3 LANCZOS_4}

add_parameter SC_H_INIT_FILE STRING ""
set_parameter_property SC_H_INIT_FILE DISPLAY_NAME "Horizontal coefficient init file"

# ---------------------------------------------------------------------------
# GUI layout
# ---------------------------------------------------------------------------
proc open_diagram {} {}

add_display_item "" general_tab group "General"
set_display_item_property general_tab DISPLAY_HINT "tab"
add_display_item general_tab TOPOLOGY               parameter
add_display_item general_tab BPS                    parameter
add_display_item general_tab NUMBER_OF_COLOR_PLANES parameter
add_display_item general_tab PIXELS_IN_PARALLEL     parameter
add_display_item general_tab MAX_WIDTH              parameter
add_display_item general_tab MAX_HEIGHT             parameter
add_display_item general_tab COLOR_SPACE            parameter
add_display_item general_tab AXIS_LITE_MODE         parameter
add_display_item general_tab enable_group group "Pass-Through Control (Full Mode Only)"
add_display_item enable_group ENABLE_DIL            parameter
add_display_item enable_group ENABLE_CRS            parameter
add_display_item enable_group ENABLE_CLIPPER        parameter
add_display_item enable_group ENABLE_PCONV          parameter
add_display_item enable_group ENABLE_SCALER         parameter

add_display_item "" mm_tab group "MM Bridge Address Map"
set_display_item_property mm_tab DISPLAY_HINT "tab"
add_display_item mm_tab mm_addr_map TEXT "<html><body><h3>MM Bridge Address Map (Word Addressed)</h3><table border='1' cellpadding='6' cellspacing='0'><tr bgcolor='#d0e8ff'><th>IP</th><th>Base Address</th><th>End Address</th><th>Size</th><th>Condition</th></tr><tr><td>Deinterlacer (DIL)</td><td>0x0000</td><td>0x01FF</td><td>0x0200</td><td>DIL_RUNTIME_CONTROL=1</td></tr><tr><td>Chroma Resampler (CRS)</td><td>0x0200</td><td>0x03FF</td><td>0x0200</td><td>CRS_RUNTIME_CONTROL=1</td></tr><tr><td>Clipper</td><td>0x0400</td><td>0x05FF</td><td>0x0200</td><td>CL_RUNTIME_CONTROL=1</td></tr><tr><td>Scaler</td><td>0x0600</td><td>0x07FF</td><td>0x0200</td><td>SC_RUNTIME_CONTROL=1</td></tr></table><br/><h3>Key Register Addresses (add base to register offset)</h3><table border='1' cellpadding='6' cellspacing='0'><tr bgcolor='#d0ffd0'><th>Register</th><th>Word Offset</th><th>Clipper Abs</th><th>Scaler Abs</th></tr><tr><td>IN_WIDTH</td><td>0x48</td><td>0x0448</td><td>0x0648</td></tr><tr><td>IN_HEIGHT</td><td>0x49</td><td>0x0449</td><td>0x0649</td></tr><tr><td>OUT_WIDTH</td><td>0x52</td><td>0x0452</td><td>0x0652</td></tr><tr><td>OUT_HEIGHT</td><td>0x53</td><td>0x0453</td><td>0x0653</td></tr><tr><td>COMMIT</td><td>0x51</td><td>0x0451</td><td>0x0651</td></tr></table></body></html>"

add_display_item "" diagram_group group "Block Diagram"
set_display_item_property diagram_group DISPLAY_HINT "tab"
add_display_item diagram_group diagram_image TEXT "<html><body>\
<table border='0' cellpadding='4' cellspacing='0'>\
<tr>\
<td><b>Full Mode</b></td>\
<td><table border='1' cellpadding='4' cellspacing='0'><tr>\
<td>s_axis_in</td><td>&rarr;</td>\
<td bgcolor='#aaddff'>DIL (separate)</td><td>&nbsp;&nbsp;</td>\
<td bgcolor='#ddaaff'>CRS</td><td>&rarr;</td>\
<td bgcolor='#ffddaa'>Clipper</td><td>&rarr;</td>\
<td bgcolor='#ffffaa'>PConv</td><td>&rarr;</td>\
<td bgcolor='#aaffaa'>Scaler</td><td>&rarr;</td>\
<td>m_axis_out</td>\
</tr></table></td>\
</tr>\
<tr><td colspan='2' height='10'></td></tr>\
<tr>\
<td><b>Scaler Only</b></td>\
<td><table border='1' cellpadding='4' cellspacing='0'><tr>\
<td>s_axis_in</td><td>&rarr;</td>\
<td bgcolor='#aaffaa'>Scaler</td><td>&rarr;</td>\
<td>m_axis_out</td>\
</tr></table></td>\
</tr>\
<tr><td colspan='2' height='10'></td></tr>\
<tr>\
<td><b>CSC Only</b></td>\
<td><table border='1' cellpadding='4' cellspacing='0'><tr>\
<td>s_axis_in</td><td>&rarr;</td>\
<td bgcolor='#ffffaa'>Protocol Conv</td><td>&rarr;</td>\
<td>m_axis_out</td>\
</tr></table></td>\
</tr>\
<tr><td colspan='2' height='10'></td></tr>\
<tr>\
<td><b>Resampler Only</b></td>\
<td><table border='1' cellpadding='4' cellspacing='0'><tr>\
<td>s_axis_in</td><td>&rarr;</td>\
<td bgcolor='#ffaaaa'>Chroma Resampler</td><td>&rarr;</td>\
<td>m_axis_out</td>\
</tr></table></td>\
</tr>\
</table>\
</body></html>"

add_display_item "" dil_tab group "Deinterlacer Config"
set_display_item_property dil_tab DISPLAY_HINT "tab"
add_display_item dil_tab dil_param_group group "Parameters"
add_display_item dil_param_group DIL_MODE                   parameter
add_display_item dil_tab dil_vdf_group group "Video Data Format"
add_display_item dil_vdf_group DIL_EXTERNAL_MODE            parameter
add_display_item dil_tab dil_mem_group group "Memory"
add_display_item dil_mem_group DIL_AV_MM_DATA_WIDTH         parameter
add_display_item dil_mem_group DIL_AV_MM_ADDR_WIDTH         parameter
add_display_item dil_mem_group DIL_WRITE_FIFO_DEPTH         parameter
add_display_item dil_mem_group DIL_WRITE_BURST_TARGET       parameter
add_display_item dil_mem_group DIL_READ_FIFO_DEPTH          parameter
add_display_item dil_mem_group DIL_READ_BURST_TARGET        parameter
add_display_item dil_mem_group DIL_MEM_BUFF_BASE_ADDR       parameter
add_display_item dil_mem_group DIL_MEM_BUFF_LINE_STRIDE     parameter
add_display_item dil_mem_group DIL_PACKING                  parameter
add_display_item dil_mem_group DIL_CLOCKS_ARE_SEPARATE      parameter
add_display_item dil_tab dil_ctrl_group group "Control"
add_display_item dil_ctrl_group DIL_RUNTIME_CONTROL         parameter
add_display_item dil_ctrl_group DIL_SEPARATE_SLAVE_CLOCK    parameter
add_display_item dil_ctrl_group DIL_ENABLE_DEBUG            parameter
add_display_item dil_tab dil_beh_group group "Deinterlacer Behaviour"
add_display_item dil_beh_group DIL_BOB_MODE                 parameter
add_display_item dil_tab dil_frame_group group "Maximum Frame Size"
add_display_item dil_frame_group DIL_MAX_WIDTH              parameter
add_display_item dil_tab dil_gen_group group "General"
add_display_item dil_gen_group DIL_PIPELINE_READY           parameter
add_display_item dil_gen_group DIL_FIFO                     parameter

add_display_item "" crs_tab group "Chroma Resampler Config"
set_display_item_property crs_tab DISPLAY_HINT "tab"
add_display_item crs_tab crs_vdf_group group "Video Data Format"
add_display_item crs_vdf_group CRS_EXTERNAL_MODE            parameter
add_display_item crs_vdf_group CRS_NO_BLANKING              parameter
add_display_item crs_vdf_group CRS_MAX_WIDTH                parameter
add_display_item crs_tab crs_sampling_group group "Chroma Sampling Support"
add_display_item crs_sampling_group CRS_SUPPORT_420_PASS    parameter
add_display_item crs_sampling_group CRS_SUPPORT_420_TO_422  parameter
add_display_item crs_sampling_group CRS_SUPPORT_420_TO_444  parameter
add_display_item crs_sampling_group CRS_SUPPORT_422_PASS    parameter
add_display_item crs_sampling_group CRS_SUPPORT_422_TO_420  parameter
add_display_item crs_sampling_group CRS_SUPPORT_422_TO_444  parameter
add_display_item crs_sampling_group CRS_SUPPORT_444_PASS    parameter
add_display_item crs_sampling_group CRS_SUPPORT_444_TO_420  parameter
add_display_item crs_sampling_group CRS_SUPPORT_444_TO_422  parameter
add_display_item crs_tab crs_horiz_group group "Horizontal Resampling Settings"
add_display_item crs_horiz_group CRS_HORIZ_ALGORITHM         parameter
add_display_item crs_horiz_group CRS_HORIZ_CO_SITING         parameter
add_display_item crs_horiz_group CRS_HORIZ_ENABLE_LUMA_ADAPT parameter
add_display_item crs_tab crs_vert_group group "Vertical Resampling Settings"
add_display_item crs_vert_group CRS_VERT_ALGORITHM           parameter
add_display_item crs_vert_group CRS_VERT_CO_SITING           parameter
add_display_item crs_vert_group CRS_VERT_ENABLE_LUMA_ADAPT   parameter
add_display_item crs_tab crs_ctrl_group group "Control Settings"
add_display_item crs_ctrl_group CRS_RUNTIME_CONTROL          parameter
add_display_item crs_ctrl_group CRS_PIPELINE_READY           parameter
add_display_item crs_ctrl_group CRS_SEPARATE_SLAVE_CLOCK     parameter
add_display_item crs_ctrl_group CRS_ENABLE_DEBUG             parameter

add_display_item "" clipper_tab group "Clipper Config"
set_display_item_property clipper_tab DISPLAY_HINT "tab"
add_display_item clipper_tab cl_vdf_group group "Video Data Format"
add_display_item cl_vdf_group CL_BPS                    parameter
add_display_item cl_vdf_group CL_NUMBER_OF_COLOR_PLANES parameter
add_display_item cl_vdf_group CL_PIXELS_IN_PARALLEL     parameter
add_display_item clipper_tab cl_ctrl_group group "Control"
add_display_item cl_ctrl_group CL_EXTERNAL_MODE         parameter
add_display_item cl_ctrl_group CL_RUNTIME_CONTROL       parameter
add_display_item cl_ctrl_group CL_SEPARATE_SLAVE_CLOCK  parameter
add_display_item cl_ctrl_group CL_ENABLE_DEBUG          parameter
add_display_item clipper_tab cl_clip_group group "Clipping Options"
add_display_item cl_clip_group CL_CLIPPING_METHOD       parameter
add_display_item cl_clip_group CL_LEFT_OFFSET           parameter
add_display_item cl_clip_group CL_TOP_OFFSET            parameter
add_display_item cl_clip_group CL_RIGHT_OFFSET          parameter
add_display_item cl_clip_group CL_BOTTOM_OFFSET         parameter
add_display_item cl_clip_group CL_RECTANGLE_WIDTH       parameter
add_display_item cl_clip_group CL_RECTANGLE_HEIGHT      parameter

add_display_item "" pconv_tab group "Protocol Converter Config"
set_display_item_property pconv_tab DISPLAY_HINT "tab"
add_display_item pconv_tab pconv_vdf_group group "Video Data Format"
add_display_item pconv_vdf_group PCONV_ENABLE_YCBCR_SWAP    parameter
add_display_item pconv_tab pconv_ctrl_group group "Control Settings"
add_display_item pconv_ctrl_group PCONV_RUNTIME_CONTROL     parameter
add_display_item pconv_ctrl_group PCONV_SEPARATE_SLAVE_CLOCK parameter
add_display_item pconv_ctrl_group PCONV_ENABLE_DEBUG        parameter
add_display_item pconv_tab pconv_pipe_group group "Pipeline Optimization"
add_display_item pconv_pipe_group PCONV_PIPELINE_READY      parameter
add_display_item pconv_tab pconv_intf_group group "Interface Protocols"
add_display_item pconv_intf_group PCONV_INPUT_MODE          parameter
add_display_item pconv_intf_group PCONV_OUTPUT_MODE         parameter
add_display_item pconv_tab pconv_avst_group group "Avalon Streaming Video Input Settings"
add_display_item pconv_avst_group PCONV_VIP_USER_SUPPORT    parameter
add_display_item pconv_avst_group PCONV_COLOR_SPACE         parameter
add_display_item pconv_avst_group PCONV_CHROMA_SAMPLING     parameter
add_display_item pconv_avst_group PCONV_CHROMA_SITING       parameter
add_display_item pconv_avst_group PCONV_CLIP_LONG_FIELDS    parameter
add_display_item pconv_avst_group PCONV_ENABLE_TIMEOUT      parameter
add_display_item pconv_tab pconv_vvp_group group "Intel FPGA Streaming Video Full Input Settings"
add_display_item pconv_vvp_group PCONV_VVP_USER_SUPPORT     parameter

add_display_item "" scaler_tab group "Scaler Config"
set_display_item_property scaler_tab DISPLAY_HINT "tab"
add_display_item scaler_tab sc_vdf_group group "Video Data Format"
add_display_item sc_vdf_group SC_EXTERNAL_MODE          parameter
add_display_item sc_vdf_group SC_ENABLE_444             parameter
add_display_item sc_vdf_group SC_ENABLE_422             parameter
add_display_item sc_vdf_group SC_ENABLE_420             parameter
add_display_item sc_vdf_group SC_NO_BLANKING            parameter
add_display_item sc_vdf_group SC_MAX_IN_WIDTH           parameter
add_display_item sc_vdf_group SC_MAX_OUT_WIDTH          parameter
add_display_item sc_vdf_group SC_OUTPUT_HEIGHT          parameter
add_display_item scaler_tab sc_ctrl_group group "Control Settings"
add_display_item sc_ctrl_group SC_RUNTIME_CONTROL       parameter
add_display_item sc_ctrl_group SC_SEPARATE_SLAVE_CLOCK  parameter
add_display_item sc_ctrl_group SC_ENABLE_DEBUG          parameter
add_display_item sc_ctrl_group SC_PIPELINE_READY        parameter
add_display_item scaler_tab sc_scaling_group group "Scaling"
add_display_item sc_scaling_group SC_ALGORITHM          parameter
add_display_item sc_scaling_group SC_EDGE_MIRROR        parameter
add_display_item sc_scaling_group SC_RUNTIME_LOAD       parameter
add_display_item sc_scaling_group SC_MEM_INIT           parameter
add_display_item scaler_tab sc_vscaling_group group "Vertical Scaling"
add_display_item sc_vscaling_group SC_ENABLE_V          parameter
add_display_item sc_vscaling_group SC_V_PARTIAL_SCALING parameter
add_display_item sc_vscaling_group SC_ENABLE_420_MIRROR parameter
add_display_item sc_vscaling_group SC_V_TAPS            parameter
add_display_item sc_vscaling_group SC_V_PHASES          parameter
add_display_item sc_vscaling_group SC_V_BANKS           parameter
add_display_item sc_vscaling_group SC_V_COEFF_SIGNED    parameter
add_display_item sc_vscaling_group SC_V_COEFF_INT_BITS  parameter
add_display_item sc_vscaling_group SC_V_COEFF_FRAC_BITS parameter
add_display_item sc_vscaling_group SC_V_PRES_FRAC_BITS  parameter
add_display_item sc_vscaling_group SC_V_COEFF_FUNCTION  parameter
add_display_item sc_vscaling_group SC_V_INIT_FILE       parameter
add_display_item scaler_tab sc_hscaling_group group "Horizontal Scaling"
add_display_item sc_hscaling_group SC_ENABLE_H          parameter
add_display_item sc_hscaling_group SC_H_PARTIAL_SCALING parameter
add_display_item sc_hscaling_group SC_HALF_RATE_420     parameter
add_display_item sc_hscaling_group SC_H_TAPS            parameter
add_display_item sc_hscaling_group SC_H_PHASES          parameter
add_display_item sc_hscaling_group SC_H_BANKS           parameter
add_display_item sc_hscaling_group SC_H_COEFF_SIGNED    parameter
add_display_item sc_hscaling_group SC_H_COEFF_INT_BITS  parameter
add_display_item sc_hscaling_group SC_H_COEFF_FRAC_BITS parameter
add_display_item sc_hscaling_group SC_H_COEFF_FUNCTION  parameter
add_display_item sc_hscaling_group SC_H_INIT_FILE       parameter

# ---------------------------------------------------------------------------
# COMPOSE
# ---------------------------------------------------------------------------
proc compose {} {

    set topo    [get_parameter_value TOPOLOGY]
    set bps     [get_parameter_value BPS]
    set nplanes [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set pip     [get_parameter_value PIXELS_IN_PARALLEL]

    if {$topo eq "FULL"} {
        set do_dil     [get_parameter_value ENABLE_DIL]
        set do_crs     [get_parameter_value ENABLE_CRS]
        set do_clipper [get_parameter_value ENABLE_CLIPPER]
        set do_pconv   [get_parameter_value ENABLE_PCONV]
        set do_scaler  [get_parameter_value ENABLE_SCALER]
    } elseif {$topo eq "SCALER_ONLY"} {
        set do_dil 0; set do_crs 0; set do_clipper 0
        set do_pconv 1; set do_scaler 1
    } elseif {$topo eq "CSC_ONLY"} {
        set do_dil 0; set do_crs 0; set do_clipper 0
        set do_pconv 1; set do_scaler 0
    } elseif {$topo eq "RESAMPLER_ONLY"} {
        set do_dil 0; set do_crs 1; set do_clipper 0
        set do_pconv 0; set do_scaler 0
    } else {
        set do_dil 0; set do_crs 0; set do_clipper 0
        set do_pconv 0; set do_scaler 0
    }

    # pconv fixed modes from reference
    set pconv_in  "INTERNAL"
    set pconv_out "EXTERNAL"
    # Scaler EXTERNAL_MODE: use user setting
    # (pconv output is AXI4S so scaler needs EXTERNAL=1 only when pconv present)
    set sc_ext [expr {$do_pconv ? 1 : [get_parameter_value SC_EXTERNAL_MODE]}]

    # MM bridge needed when any IP has runtime control enabled
    set need_mm [expr {
        ($do_dil     && [get_parameter_value DIL_RUNTIME_CONTROL]) ||
        ($do_crs     && [get_parameter_value CRS_RUNTIME_CONTROL]) ||
        ($do_clipper && [get_parameter_value CL_RUNTIME_CONTROL])  ||
        ($do_scaler  && [get_parameter_value SC_RUNTIME_CONTROL])
    }]

    set sc_en_444 [get_parameter_value SC_ENABLE_444]
    set sc_en_422 [get_parameter_value SC_ENABLE_422]
    set sc_en_420 [get_parameter_value SC_ENABLE_420]
    set sc_planes [expr {$sc_en_422 && !$sc_en_444 && !$sc_en_420 ? 2 : $nplanes}]

    # -----------------------------------------------------------------------
    # Infrastructure
    # -----------------------------------------------------------------------
    add_instance clock_in altera_clock_bridge 19.2.0
    set_instance_parameter_value clock_in NUM_CLOCK_OUTPUTS   1
    set_instance_parameter_value clock_in EXPLICIT_CLOCK_RATE 50000000

    add_instance reset_in altera_reset_bridge 19.2.0
    set_instance_parameter_value reset_in NUM_RESET_OUTPUTS 1
    set_instance_parameter_value reset_in ACTIVE_LOW_RESET  0
    set_instance_parameter_value reset_in SYNCHRONOUS_EDGES deassert
    set_instance_parameter_value reset_in USE_RESET_REQUEST 0
    set_instance_parameter_value reset_in SYNC_RESET        0
    add_connection clock_in.out_clk reset_in.clk

    if {$need_mm} {
        add_instance mm_bridge_0 altera_avalon_mm_bridge 20.1.0
        set_instance_parameter_value mm_bridge_0 DATA_WIDTH            32
        set_instance_parameter_value mm_bridge_0 ADDRESS_WIDTH         11
        set_instance_parameter_value mm_bridge_0 ADDRESS_UNITS         WORDS
        set_instance_parameter_value mm_bridge_0 MAX_BURST_SIZE        1
        set_instance_parameter_value mm_bridge_0 MAX_PENDING_RESPONSES 4
        set_instance_parameter_value mm_bridge_0 MAX_PENDING_WRITES    0
        set_instance_parameter_value mm_bridge_0 PIPELINE_COMMAND      1
        set_instance_parameter_value mm_bridge_0 PIPELINE_RESPONSE     1
        set_instance_parameter_value mm_bridge_0 SYNC_RESET            0
        set_instance_parameter_value mm_bridge_0 USE_RESPONSE          0
        set_instance_parameter_value mm_bridge_0 USE_WRITERESPONSE     0
        add_connection clock_in.out_clk   mm_bridge_0.clk
        add_connection reset_in.out_reset mm_bridge_0.reset
    }

    # -----------------------------------------------------------------------
    # Deinterlacer — separate exported ports (not chained)
    # -----------------------------------------------------------------------
    if {$do_dil} {
        add_instance intel_vvp_dil_0 intel_vvp_dil 24.5.1
        set_instance_parameter_value intel_vvp_dil_0 EXTERNAL_MODE          [get_parameter_value DIL_EXTERNAL_MODE]
        set_instance_parameter_value intel_vvp_dil_0 PIPELINE_READY         [get_parameter_value DIL_PIPELINE_READY]
        set_instance_parameter_value intel_vvp_dil_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_dil_0 NUMBER_OF_COLOR_PLANES $nplanes
        set_instance_parameter_value intel_vvp_dil_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_dil_0 MAX_WIDTH              [get_parameter_value DIL_MAX_WIDTH]
        set_instance_parameter_value intel_vvp_dil_0 MEM_BUFF_BASE_ADDR     [get_parameter_value DIL_MEM_BUFF_BASE_ADDR]
        set_instance_parameter_value intel_vvp_dil_0 MEM_BUFF_LINE_STRIDE   [get_parameter_value DIL_MEM_BUFF_LINE_STRIDE]
        set_instance_parameter_value intel_vvp_dil_0 WRITE_FIFO_DEPTH       [get_parameter_value DIL_WRITE_FIFO_DEPTH]
        set_instance_parameter_value intel_vvp_dil_0 READ_FIFO_DEPTH        [get_parameter_value DIL_READ_FIFO_DEPTH]
        set_instance_parameter_value intel_vvp_dil_0 PACKING                [get_parameter_value DIL_PACKING]
        set_instance_parameter_value intel_vvp_dil_0 CLOCKS_ARE_SEPARATE    [get_parameter_value DIL_CLOCKS_ARE_SEPARATE]
        set_instance_parameter_value intel_vvp_dil_0 P_AV_MM_DATA_WIDTH     [get_parameter_value DIL_AV_MM_DATA_WIDTH]
        set_instance_parameter_value intel_vvp_dil_0 P_AV_MM_ADDR_WIDTH     [get_parameter_value DIL_AV_MM_ADDR_WIDTH]
        set_instance_parameter_value intel_vvp_dil_0 WRITE_BURST_TARGET     [get_parameter_value DIL_WRITE_BURST_TARGET]
        set_instance_parameter_value intel_vvp_dil_0 READ_BURST_TARGET      [get_parameter_value DIL_READ_BURST_TARGET]
        set_instance_parameter_value intel_vvp_dil_0 DIL_MODE               [get_parameter_value DIL_MODE]
        set_instance_parameter_value intel_vvp_dil_0 BOB_DIL_MODE           [get_parameter_value DIL_BOB_MODE]
        set_instance_parameter_value intel_vvp_dil_0 SEPARATE_SLAVE_CLOCK   [get_parameter_value DIL_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_dil_0 RUNTIME_CONTROL        [get_parameter_value DIL_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_dil_0 ENABLE_DEBUG           [get_parameter_value DIL_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_dil_0 FIFO                   [get_parameter_value DIL_FIFO]
        add_connection clock_in.out_clk   intel_vvp_dil_0.main_clock
        add_connection reset_in.out_reset intel_vvp_dil_0.main_reset
        if {$need_mm && [get_parameter_value DIL_RUNTIME_CONTROL]} {
            add_connection mm_bridge_0.m0 intel_vvp_dil_0.av_mm_control_agent
            set_connection_parameter_value \
                mm_bridge_0.m0/intel_vvp_dil_0.av_mm_control_agent baseAddress 0x0000
        }
    }

    # -----------------------------------------------------------------------
    # Chroma Resampler — first in main chain
    # -----------------------------------------------------------------------
    if {$do_crs} {
        add_instance intel_vvp_crs_0 intel_vvp_crs 24.5.1
        set_instance_parameter_value intel_vvp_crs_0 EXTERNAL_MODE           [get_parameter_value CRS_EXTERNAL_MODE]
        set_instance_parameter_value intel_vvp_crs_0 PIPELINE_READY          [get_parameter_value CRS_PIPELINE_READY]
        set_instance_parameter_value intel_vvp_crs_0 MAX_WIDTH               [get_parameter_value CRS_MAX_WIDTH]
        set_instance_parameter_value intel_vvp_crs_0 RUNTIME_CONTROL         [get_parameter_value CRS_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_crs_0 ENABLE_DEBUG            [get_parameter_value CRS_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_crs_0 P_UPDATE_CMD_SUPPORTED  0
        set_instance_parameter_value intel_vvp_crs_0 P_CORE_CTRL_ID          0
        set_instance_parameter_value intel_vvp_crs_0 SEPARATE_SLAVE_CLOCK    [get_parameter_value CRS_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_crs_0 BPS                     $bps
        set_instance_parameter_value intel_vvp_crs_0 PIXELS_IN_PARALLEL_IN   $pip
        set_instance_parameter_value intel_vvp_crs_0 PIXELS_IN_PARALLEL_OUT  $pip
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_TO_422      [get_parameter_value CRS_SUPPORT_444_TO_422]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_TO_420      [get_parameter_value CRS_SUPPORT_444_TO_420]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_TO_444      [get_parameter_value CRS_SUPPORT_422_TO_444]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_TO_420      [get_parameter_value CRS_SUPPORT_422_TO_420]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_TO_422      [get_parameter_value CRS_SUPPORT_420_TO_422]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_TO_444      [get_parameter_value CRS_SUPPORT_420_TO_444]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_PASS        [get_parameter_value CRS_SUPPORT_420_PASS]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_PASS        [get_parameter_value CRS_SUPPORT_422_PASS]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_PASS        [get_parameter_value CRS_SUPPORT_444_PASS]
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_ALGORITHM         [get_parameter_value CRS_HORIZ_ALGORITHM]
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_CO_SITING         [get_parameter_value CRS_HORIZ_CO_SITING]
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_ENABLE_LUMA_ADAPT [get_parameter_value CRS_HORIZ_ENABLE_LUMA_ADAPT]
        set_instance_parameter_value intel_vvp_crs_0 VERT_ALGORITHM          [get_parameter_value CRS_VERT_ALGORITHM]
        set_instance_parameter_value intel_vvp_crs_0 VERT_CO_SITING          [get_parameter_value CRS_VERT_CO_SITING]
        set_instance_parameter_value intel_vvp_crs_0 VERT_ENABLE_LUMA_ADAPT  [get_parameter_value CRS_VERT_ENABLE_LUMA_ADAPT]
        set_instance_parameter_value intel_vvp_crs_0 NO_BLANKING             [get_parameter_value CRS_NO_BLANKING]
        add_connection clock_in.out_clk   intel_vvp_crs_0.main_clock
        add_connection reset_in.out_reset intel_vvp_crs_0.main_reset
        if {$need_mm && [get_parameter_value CRS_RUNTIME_CONTROL]} {
            add_connection mm_bridge_0.m0 intel_vvp_crs_0.av_mm_control_agent
            set_connection_parameter_value \
                mm_bridge_0.m0/intel_vvp_crs_0.av_mm_control_agent baseAddress 0x0200
        }
    }

    # -----------------------------------------------------------------------
    # Clipper — second in main chain
    # -----------------------------------------------------------------------
    if {$do_clipper} {
        add_instance intel_vvp_clipper_0 intel_vvp_clipper 24.5.1
        set_instance_parameter_value intel_vvp_clipper_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_clipper_0 NUMBER_OF_COLOR_PLANES $nplanes
        set_instance_parameter_value intel_vvp_clipper_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_clipper_0 EXTERNAL_MODE          [get_parameter_value CL_EXTERNAL_MODE]
        set_instance_parameter_value intel_vvp_clipper_0 RUNTIME_CONTROL        [get_parameter_value CL_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_clipper_0 SEPARATE_SLAVE_CLOCK   [get_parameter_value CL_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_clipper_0 ENABLE_DEBUG           [get_parameter_value CL_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_clipper_0 CLIPPING_METHOD        [get_parameter_value CL_CLIPPING_METHOD]
        set_instance_parameter_value intel_vvp_clipper_0 LEFT_OFFSET            [get_parameter_value CL_LEFT_OFFSET]
        set_instance_parameter_value intel_vvp_clipper_0 TOP_OFFSET             [get_parameter_value CL_TOP_OFFSET]
        set_instance_parameter_value intel_vvp_clipper_0 RIGHT_OFFSET           [get_parameter_value CL_RIGHT_OFFSET]
        set_instance_parameter_value intel_vvp_clipper_0 BOTTOM_OFFSET          [get_parameter_value CL_BOTTOM_OFFSET]
        set_instance_parameter_value intel_vvp_clipper_0 RECTANGLE_WIDTH        [get_parameter_value CL_RECTANGLE_WIDTH]
        set_instance_parameter_value intel_vvp_clipper_0 RECTANGLE_HEIGHT       [get_parameter_value CL_RECTANGLE_HEIGHT]
        add_connection clock_in.out_clk   intel_vvp_clipper_0.main_clock
        add_connection reset_in.out_reset intel_vvp_clipper_0.main_reset
        if {$need_mm && [get_parameter_value CL_RUNTIME_CONTROL]} {
            add_connection mm_bridge_0.m0 intel_vvp_clipper_0.av_mm_control_agent
            set_connection_parameter_value \
                mm_bridge_0.m0/intel_vvp_clipper_0.av_mm_control_agent baseAddress 0x0400
        }
    }

    # -----------------------------------------------------------------------
    # Protocol Converter — third in main chain
    # -----------------------------------------------------------------------
    if {$do_pconv} {
        add_instance intel_vvp_protocol_conv_0 intel_vvp_protocol_conv 24.6.0
        set_instance_parameter_value intel_vvp_protocol_conv_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_protocol_conv_0 NUMBER_OF_COLOR_PLANES $nplanes
        set_instance_parameter_value intel_vvp_protocol_conv_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_protocol_conv_0 RUNTIME_CONTROL        0
        set_instance_parameter_value intel_vvp_protocol_conv_0 ENABLE_DEBUG           [get_parameter_value PCONV_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_protocol_conv_0 SEPARATE_SLAVE_CLOCK   [get_parameter_value PCONV_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_protocol_conv_0 PIPELINE_READY         [get_parameter_value PCONV_PIPELINE_READY]
        set_instance_parameter_value intel_vvp_protocol_conv_0 INPUT_MODE             $pconv_in
        set_instance_parameter_value intel_vvp_protocol_conv_0 OUTPUT_MODE            $pconv_out
        set_instance_parameter_value intel_vvp_protocol_conv_0 CLIP_LONG_FIELDS       [get_parameter_value PCONV_CLIP_LONG_FIELDS]
        set_instance_parameter_value intel_vvp_protocol_conv_0 ENABLE_TIMEOUT         [get_parameter_value PCONV_ENABLE_TIMEOUT]
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
    # Scaler — fourth/last in main chain
    # -----------------------------------------------------------------------
    if {$do_scaler} {
        add_instance intel_vvp_scaler_0 intel_vvp_scaler 24.5.1
        set_instance_parameter_value intel_vvp_scaler_0 EXTERNAL_MODE          $sc_ext
        set_instance_parameter_value intel_vvp_scaler_0 PIPELINE_READY         [get_parameter_value SC_PIPELINE_READY]
        set_instance_parameter_value intel_vvp_scaler_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_scaler_0 NUMBER_OF_COLOR_PLANES $sc_planes
        set_instance_parameter_value intel_vvp_scaler_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_444             $sc_en_444
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_422             $sc_en_422
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_420             $sc_en_420
        set_instance_parameter_value intel_vvp_scaler_0 RUNTIME_CONTROL        [get_parameter_value SC_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_DEBUG           [get_parameter_value SC_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_scaler_0 SEPARATE_SLAVE_CLOCK   [get_parameter_value SC_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_scaler_0 P_UPDATE_CMD_SUPPORTED 0
        set_instance_parameter_value intel_vvp_scaler_0 P_CORE_CTRL_ID         0
        set_instance_parameter_value intel_vvp_scaler_0 MAX_IN_WIDTH           [get_parameter_value SC_MAX_IN_WIDTH]
        set_instance_parameter_value intel_vvp_scaler_0 MAX_OUT_WIDTH          [get_parameter_value SC_MAX_OUT_WIDTH]
        set_instance_parameter_value intel_vvp_scaler_0 OUTPUT_HEIGHT          [get_parameter_value SC_OUTPUT_HEIGHT]
        set_instance_parameter_value intel_vvp_scaler_0 NO_BLANKING            [get_parameter_value SC_NO_BLANKING]
        set_instance_parameter_value intel_vvp_scaler_0 RUNTIME_LOAD           [get_parameter_value SC_RUNTIME_LOAD]
        set_instance_parameter_value intel_vvp_scaler_0 MEM_INIT               [get_parameter_value SC_MEM_INIT]
        set_instance_parameter_value intel_vvp_scaler_0 ALGORITHM              [get_parameter_value SC_ALGORITHM]
        set_instance_parameter_value intel_vvp_scaler_0 EDGE_MIRROR            [get_parameter_value SC_EDGE_MIRROR]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_V               [get_parameter_value SC_ENABLE_V]
        set_instance_parameter_value intel_vvp_scaler_0 V_PARTIAL_SCALING      [get_parameter_value SC_V_PARTIAL_SCALING]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_420_MIRROR      [get_parameter_value SC_ENABLE_420_MIRROR]
        set_instance_parameter_value intel_vvp_scaler_0 V_TAPS                 [get_parameter_value SC_V_TAPS]
        set_instance_parameter_value intel_vvp_scaler_0 V_PHASES               [get_parameter_value SC_V_PHASES]
        set_instance_parameter_value intel_vvp_scaler_0 V_BANKS                [get_parameter_value SC_V_BANKS]
        set_instance_parameter_value intel_vvp_scaler_0 V_COEFF_SIGNED         [get_parameter_value SC_V_COEFF_SIGNED]
        set_instance_parameter_value intel_vvp_scaler_0 V_COEFF_INT_BITS       [get_parameter_value SC_V_COEFF_INT_BITS]
        set_instance_parameter_value intel_vvp_scaler_0 V_COEFF_FRAC_BITS      [get_parameter_value SC_V_COEFF_FRAC_BITS]
        set_instance_parameter_value intel_vvp_scaler_0 V_PRES_FRAC_BITS       [get_parameter_value SC_V_PRES_FRAC_BITS]
        set_instance_parameter_value intel_vvp_scaler_0 V_COEFF_FUNCTION       [get_parameter_value SC_V_COEFF_FUNCTION]
        set_instance_parameter_value intel_vvp_scaler_0 V_INIT_FILE            [get_parameter_value SC_V_INIT_FILE]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_H               [get_parameter_value SC_ENABLE_H]
        set_instance_parameter_value intel_vvp_scaler_0 H_PARTIAL_SCALING      [get_parameter_value SC_H_PARTIAL_SCALING]
        set_instance_parameter_value intel_vvp_scaler_0 HALF_RATE_420          [get_parameter_value SC_HALF_RATE_420]
        set_instance_parameter_value intel_vvp_scaler_0 H_TAPS                 [get_parameter_value SC_H_TAPS]
        set_instance_parameter_value intel_vvp_scaler_0 H_PHASES               [get_parameter_value SC_H_PHASES]
        set_instance_parameter_value intel_vvp_scaler_0 H_BANKS                [get_parameter_value SC_H_BANKS]
        set_instance_parameter_value intel_vvp_scaler_0 H_COEFF_SIGNED         [get_parameter_value SC_H_COEFF_SIGNED]
        set_instance_parameter_value intel_vvp_scaler_0 H_COEFF_INT_BITS       [get_parameter_value SC_H_COEFF_INT_BITS]
        set_instance_parameter_value intel_vvp_scaler_0 H_COEFF_FRAC_BITS      [get_parameter_value SC_H_COEFF_FRAC_BITS]
        set_instance_parameter_value intel_vvp_scaler_0 H_COEFF_FUNCTION       [get_parameter_value SC_H_COEFF_FUNCTION]
        set_instance_parameter_value intel_vvp_scaler_0 H_INIT_FILE            [get_parameter_value SC_H_INIT_FILE]
        add_connection clock_in.out_clk   intel_vvp_scaler_0.main_clock
        add_connection reset_in.out_reset intel_vvp_scaler_0.main_reset
        if {$need_mm && [get_parameter_value SC_RUNTIME_CONTROL]} {
            add_connection mm_bridge_0.m0 intel_vvp_scaler_0.av_mm_control_agent
            set_connection_parameter_value \
                mm_bridge_0.m0/intel_vvp_scaler_0.av_mm_control_agent baseAddress 0x0600
        }
    }

    # -----------------------------------------------------------------------
    # Main video chain: CRS -> Clipper -> PConv -> Scaler
    # DIL is separate — not chained
    # -----------------------------------------------------------------------
    set last_out ""

    if {$do_crs} {
        set last_out "intel_vvp_crs_0.axi4s_vid_out"
    }
    if {$do_clipper} {
        if {$last_out ne ""} {
            add_connection $last_out intel_vvp_clipper_0.axi4s_vid_in
        }
        set last_out "intel_vvp_clipper_0.axi4s_vid_out"
    }
    if {$do_pconv} {
        if {$last_out ne ""} {
            add_connection $last_out intel_vvp_protocol_conv_0.axi4s_vid_in
        }
        set last_out "intel_vvp_protocol_conv_0.axi4s_vid_out"
    }
    if {$do_scaler} {
        if {$last_out ne ""} {
            add_connection $last_out intel_vvp_scaler_0.axi4s_vid_in
        }
        set last_out "intel_vvp_scaler_0.axi4s_vid_out"
    }

    # -----------------------------------------------------------------------
    # Exports
    # -----------------------------------------------------------------------
    add_interface clk clock end
    set_interface_property clk EXPORT_OF clock_in.in_clk

    add_interface reset reset end
    set_interface_property reset EXPORT_OF reset_in.in_reset

    if {$need_mm} {
        add_interface av_mm_control avalon end
        set_interface_property av_mm_control EXPORT_OF mm_bridge_0.s0
    }

    # DIL always exported as separate in/out
    if {$do_dil} {
        add_interface dil_axi4s_vid_in axi4stream end
        set_interface_property dil_axi4s_vid_in EXPORT_OF intel_vvp_dil_0.axi4s_vid_in
        add_interface dil_axi4s_vid_out axi4stream start
        set_interface_property dil_axi4s_vid_out EXPORT_OF intel_vvp_dil_0.axi4s_vid_out
    }

    # Main chain: s_axis_video_in = first active IP (CRS or below)
    if {$do_crs} {
        add_interface s_axis_video_in axi4stream end
        set_interface_property s_axis_video_in EXPORT_OF intel_vvp_crs_0.axi4s_vid_in
    } elseif {$do_clipper} {
        add_interface s_axis_video_in axi4stream end
        set_interface_property s_axis_video_in EXPORT_OF intel_vvp_clipper_0.axi4s_vid_in
    } elseif {$do_pconv} {
        add_interface s_axis_video_in axi4stream end
        set_interface_property s_axis_video_in EXPORT_OF intel_vvp_protocol_conv_0.axi4s_vid_in
    } elseif {$do_scaler} {
        add_interface s_axis_video_in axi4stream end
        set_interface_property s_axis_video_in EXPORT_OF intel_vvp_scaler_0.axi4s_vid_in
    }

    # m_axis_video_out = last active IP in main chain
    if {$last_out ne ""} {
        add_interface m_axis_video_out axi4stream start
        set_interface_property m_axis_video_out EXPORT_OF $last_out
    }
}
