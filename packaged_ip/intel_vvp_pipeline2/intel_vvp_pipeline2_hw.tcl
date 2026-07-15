package require qsys
# ============================================================================
# Module identity
# ============================================================================
set_module_property NAME                 intel_vvp_pipeline2
set_module_property DISPLAY_NAME         "Intel VVP Video Processing Subsystem"
set_module_property VERSION              1.0
set_module_property DESCRIPTION          "Altera VVP pipeline subsystem - DIL, CRS, CSC, Clipper, PC0, Scaler with unified MM bridge. Optional features: Frame Rate Conversion (VFB) and Picture-in-Picture (Mixer)"
set_module_property GROUP                "Video & Image Processing"
set_module_property AUTHOR               "Project"

set_module_property COMPOSITION_CALLBACK   compose
set_module_property VALIDATION_CALLBACK    validate

# ============================================================================
# GENERAL parameters
# ============================================================================
add_parameter TOPOLOGY STRING "FULL"
set_parameter_property TOPOLOGY DISPLAY_NAME        "Video processing mode"
set_parameter_property TOPOLOGY ALLOWED_RANGES       {FULL SCALER_ONLY CSC_ONLY CRS_ONLY CRS_CSC CLIP_SCL DIL_ONLY}
set_parameter_property TOPOLOGY AFFECTS_ELABORATION  true
set_parameter_property TOPOLOGY HDL_PARAMETER        false

add_parameter BPS INTEGER 8
set_parameter_property BPS DISPLAY_NAME        "Bits per color sample"
set_parameter_property BPS ALLOWED_RANGES       {8 10 12 16}
set_parameter_property BPS AFFECTS_ELABORATION  true
set_parameter_property BPS HDL_PARAMETER        false

add_parameter NUMBER_OF_COLOR_PLANES INTEGER 3
set_parameter_property NUMBER_OF_COLOR_PLANES DISPLAY_NAME        "Number of color planes"
set_parameter_property NUMBER_OF_COLOR_PLANES ALLOWED_RANGES       {1 2 3 4}
set_parameter_property NUMBER_OF_COLOR_PLANES AFFECTS_ELABORATION  true
set_parameter_property NUMBER_OF_COLOR_PLANES HDL_PARAMETER        false

add_parameter PIXELS_IN_PARALLEL INTEGER 1
set_parameter_property PIXELS_IN_PARALLEL DISPLAY_NAME        "Number of pixels in parallel"
set_parameter_property PIXELS_IN_PARALLEL ALLOWED_RANGES       {1 2 4 6 8}
set_parameter_property PIXELS_IN_PARALLEL AFFECTS_ELABORATION  true
set_parameter_property PIXELS_IN_PARALLEL HDL_PARAMETER        false

add_parameter INPUT_PROTOCOL STRING "ALTERA_SV_FULL"
set_parameter_property INPUT_PROTOCOL DISPLAY_NAME        "Input protocol variant"
set_parameter_property INPUT_PROTOCOL ALLOWED_RANGES       {"ALTERA_SV_FULL:Altera Streaming Video Full" "ALTERA_SV_LITE:Altera Streaming Video Lite" "AVALON_ST:Avalon Streaming Video"}
set_parameter_property INPUT_PROTOCOL AFFECTS_ELABORATION  true
set_parameter_property INPUT_PROTOCOL HDL_PARAMETER        false

add_parameter OUTPUT_PROTOCOL STRING "ALTERA_SV_LITE"
set_parameter_property OUTPUT_PROTOCOL DISPLAY_NAME        "Output protocol variant"
set_parameter_property OUTPUT_PROTOCOL ALLOWED_RANGES       {"ALTERA_SV_FULL:Altera Streaming Video Full" "ALTERA_SV_LITE:Altera Streaming Video Lite" "AVALON_ST:Avalon Streaming Video"}
set_parameter_property OUTPUT_PROTOCOL AFFECTS_ELABORATION  true
set_parameter_property OUTPUT_PROTOCOL HDL_PARAMETER        false

# -- Optional features (combinable with any video processing mode) ----------
add_parameter ENABLE_FRC INTEGER 0
set_parameter_property ENABLE_FRC DISPLAY_NAME        "Frame rate conversion (memory frame buffer)"
set_parameter_property ENABLE_FRC DISPLAY_HINT         boolean
set_parameter_property ENABLE_FRC DESCRIPTION          "Appends a Video Frame Buffer after the processing chain. Frames are written to and read back from DDR4 memory; rate mismatch is absorbed by frame drop/repeat. By default a DDR4 EMIF is included in the subsystem and its memory I/Os are exported (see the FRC tab)."
set_parameter_property ENABLE_FRC AFFECTS_ELABORATION  true
set_parameter_property ENABLE_FRC HDL_PARAMETER        false

add_parameter ENABLE_PIP INTEGER 0
set_parameter_property ENABLE_PIP DISPLAY_NAME        "Picture-in-picture (mixer overlay)"
set_parameter_property ENABLE_PIP DISPLAY_HINT         boolean
set_parameter_property ENABLE_PIP DESCRIPTION          "Appends a Mixer after the processing chain (and after the frame buffer when FRC is also enabled). Layer 0 is an internal uniform-color background TPG, layer 1 is the pipeline video; additional layer inputs are exported."
set_parameter_property ENABLE_PIP AFFECTS_ELABORATION  true
set_parameter_property ENABLE_PIP HDL_PARAMETER        false

# ============================================================================
# DEINTERLACER parameters
# ============================================================================
add_parameter DIL_MODE STRING "BOB"
set_parameter_property DIL_MODE DISPLAY_NAME        "Deinterlacing mode"
set_parameter_property DIL_MODE ALLOWED_RANGES       {BOB WEAVE MOTION_ADAPTIVE}
set_parameter_property DIL_MODE AFFECTS_ELABORATION  true
set_parameter_property DIL_MODE HDL_PARAMETER        false

add_parameter DIL_BOB_MODE STRING "DEINTERLACE_F0_AND_F1"
set_parameter_property DIL_BOB_MODE DISPLAY_NAME        "Bob deinterlacing mode"
set_parameter_property DIL_BOB_MODE ALLOWED_RANGES       {DEINTERLACE_F0_ONLY DEINTERLACE_F1_ONLY DEINTERLACE_F0_AND_F1}
set_parameter_property DIL_BOB_MODE HDL_PARAMETER        false

add_parameter DIL_MAX_WIDTH INTEGER 2048
set_parameter_property DIL_MAX_WIDTH DISPLAY_NAME        "Maximum field width"
set_parameter_property DIL_MAX_WIDTH ALLOWED_RANGES {2048 4096 8192 16384}
set_parameter_property DIL_MAX_WIDTH HDL_PARAMETER        false

add_parameter DIL_EXTERNAL_MODE INTEGER 0
set_parameter_property DIL_EXTERNAL_MODE DISPLAY_NAME        "Lite mode"
set_parameter_property DIL_EXTERNAL_MODE DISPLAY_HINT         boolean
set_parameter_property DIL_EXTERNAL_MODE AFFECTS_ELABORATION  true
set_parameter_property DIL_EXTERNAL_MODE HDL_PARAMETER        false

add_parameter DIL_AV_MM_DATA_WIDTH INTEGER 256
set_parameter_property DIL_AV_MM_DATA_WIDTH DISPLAY_NAME        "Local port data width (bits)"
set_parameter_property DIL_AV_MM_DATA_WIDTH ALLOWED_RANGES       {16 32 64 128 256 512 1024}
set_parameter_property DIL_AV_MM_DATA_WIDTH HDL_PARAMETER        false

add_parameter DIL_AV_MM_ADDR_WIDTH INTEGER 32
set_parameter_property DIL_AV_MM_ADDR_WIDTH DISPLAY_NAME        "Local port address width (bits)"
set_parameter_property DIL_AV_MM_ADDR_WIDTH ALLOWED_RANGES       "8:32"
set_parameter_property DIL_AV_MM_ADDR_WIDTH HDL_PARAMETER        false

add_parameter DIL_WRITE_FIFO_DEPTH INTEGER 256
set_parameter_property DIL_WRITE_FIFO_DEPTH DISPLAY_NAME        "Write FIFO depth"
set_parameter_property DIL_WRITE_FIFO_DEPTH ALLOWED_RANGES       {32 64 128 256 512 1024 2048}
set_parameter_property DIL_WRITE_FIFO_DEPTH HDL_PARAMETER        false

add_parameter DIL_WRITE_BURST_TARGET INTEGER 16
set_parameter_property DIL_WRITE_BURST_TARGET DISPLAY_NAME        "Write burst target"
set_parameter_property DIL_WRITE_BURST_TARGET ALLOWED_RANGES       {2 4 8 16 32 64}
set_parameter_property DIL_WRITE_BURST_TARGET HDL_PARAMETER        false

add_parameter DIL_READ_FIFO_DEPTH INTEGER 256
set_parameter_property DIL_READ_FIFO_DEPTH DISPLAY_NAME        "Read FIFO depth"
set_parameter_property DIL_READ_FIFO_DEPTH ALLOWED_RANGES       {32 64 128 256 512 1024 2048}
set_parameter_property DIL_READ_FIFO_DEPTH HDL_PARAMETER        false

add_parameter DIL_READ_BURST_TARGET INTEGER 16
set_parameter_property DIL_READ_BURST_TARGET DISPLAY_NAME        "Read burst target"
set_parameter_property DIL_READ_BURST_TARGET ALLOWED_RANGES       {2 4 8 16 32 64}
set_parameter_property DIL_READ_BURST_TARGET HDL_PARAMETER        false

add_parameter DIL_MEM_BUFF_BASE_ADDR INTEGER 0
set_parameter_property DIL_MEM_BUFF_BASE_ADDR DISPLAY_NAME        "Field memory base address"
set_parameter_property DIL_MEM_BUFF_BASE_ADDR HDL_PARAMETER        false

add_parameter DIL_MEM_BUFF_LINE_STRIDE INTEGER 8192
set_parameter_property DIL_MEM_BUFF_LINE_STRIDE DISPLAY_NAME        "Interline stride (bytes)"
set_parameter_property DIL_MEM_BUFF_LINE_STRIDE HDL_PARAMETER        false

add_parameter DIL_PACKING STRING "PERFECT"
set_parameter_property DIL_PACKING DISPLAY_NAME        "Packing method"
set_parameter_property DIL_PACKING ALLOWED_RANGES       {PERFECT COLOR PIXEL}
set_parameter_property DIL_PACKING HDL_PARAMETER        false

add_parameter DIL_CLOCKS_ARE_SEPARATE INTEGER 0
set_parameter_property DIL_CLOCKS_ARE_SEPARATE DISPLAY_NAME        "Separate clock for memory interface"
set_parameter_property DIL_CLOCKS_ARE_SEPARATE DISPLAY_HINT         boolean
set_parameter_property DIL_CLOCKS_ARE_SEPARATE AFFECTS_ELABORATION  true
set_parameter_property DIL_CLOCKS_ARE_SEPARATE HDL_PARAMETER        false

add_parameter DIL_RUNTIME_CONTROL INTEGER 1
set_parameter_property DIL_RUNTIME_CONTROL DISPLAY_NAME        "Memory-mapped control interface"
set_parameter_property DIL_RUNTIME_CONTROL DISPLAY_HINT         boolean
set_parameter_property DIL_RUNTIME_CONTROL AFFECTS_ELABORATION  true
set_parameter_property DIL_RUNTIME_CONTROL HDL_PARAMETER        false

add_parameter DIL_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property DIL_SEPARATE_SLAVE_CLOCK DISPLAY_NAME        "Separate clock for control interface"
set_parameter_property DIL_SEPARATE_SLAVE_CLOCK DISPLAY_HINT         boolean
set_parameter_property DIL_SEPARATE_SLAVE_CLOCK AFFECTS_ELABORATION  true
set_parameter_property DIL_SEPARATE_SLAVE_CLOCK HDL_PARAMETER        false

add_parameter DIL_ENABLE_DEBUG INTEGER 0
set_parameter_property DIL_ENABLE_DEBUG DISPLAY_NAME        "Debug features"
set_parameter_property DIL_ENABLE_DEBUG DISPLAY_HINT         boolean
set_parameter_property DIL_ENABLE_DEBUG HDL_PARAMETER        false

add_parameter DIL_PIPELINE_READY INTEGER 0
set_parameter_property DIL_PIPELINE_READY DISPLAY_NAME        "Pipeline ready signals"
set_parameter_property DIL_PIPELINE_READY DISPLAY_HINT         boolean
set_parameter_property DIL_PIPELINE_READY HDL_PARAMETER        false

# ============================================================================
# CHROMA RESAMPLER parameters
# ============================================================================
add_parameter CRS_EXTERNAL_MODE INTEGER 0
set_parameter_property CRS_EXTERNAL_MODE DISPLAY_NAME        "Lite mode"
set_parameter_property CRS_EXTERNAL_MODE DISPLAY_HINT         boolean
set_parameter_property CRS_EXTERNAL_MODE AFFECTS_ELABORATION  true
set_parameter_property CRS_EXTERNAL_MODE HDL_PARAMETER        false

add_parameter CRS_MAX_WIDTH INTEGER 2048
set_parameter_property CRS_MAX_WIDTH DISPLAY_NAME        "Maximum field width"
set_parameter_property CRS_MAX_WIDTH ALLOWED_RANGES {2048 4096 8192 16384}
set_parameter_property CRS_MAX_WIDTH HDL_PARAMETER        false

add_parameter CRS_NO_BLANKING INTEGER 0
set_parameter_property CRS_NO_BLANKING DISPLAY_NAME        "Disable flush/fill between frames"
set_parameter_property CRS_NO_BLANKING DISPLAY_HINT         boolean
set_parameter_property CRS_NO_BLANKING HDL_PARAMETER        false

add_parameter CRS_SUPPORT_420_PASS INTEGER 0
set_parameter_property CRS_SUPPORT_420_PASS DISPLAY_NAME "4:2:0 passthrough"
set_parameter_property CRS_SUPPORT_420_PASS DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_420_PASS HDL_PARAMETER false

add_parameter CRS_SUPPORT_420_TO_422 INTEGER 0
set_parameter_property CRS_SUPPORT_420_TO_422 DISPLAY_NAME "4:2:0 to 4:2:2 conversion"
set_parameter_property CRS_SUPPORT_420_TO_422 DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_420_TO_422 HDL_PARAMETER false

add_parameter CRS_SUPPORT_420_TO_444 INTEGER 0
set_parameter_property CRS_SUPPORT_420_TO_444 DISPLAY_NAME "4:2:0 to 4:4:4 conversion"
set_parameter_property CRS_SUPPORT_420_TO_444 DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_420_TO_444 HDL_PARAMETER false

add_parameter CRS_SUPPORT_422_PASS INTEGER 0
set_parameter_property CRS_SUPPORT_422_PASS DISPLAY_NAME "4:2:2 passthrough"
set_parameter_property CRS_SUPPORT_422_PASS DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_422_PASS HDL_PARAMETER false

add_parameter CRS_SUPPORT_422_TO_420 INTEGER 0
set_parameter_property CRS_SUPPORT_422_TO_420 DISPLAY_NAME "4:2:2 to 4:2:0 conversion"
set_parameter_property CRS_SUPPORT_422_TO_420 DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_422_TO_420 HDL_PARAMETER false

add_parameter CRS_SUPPORT_422_TO_444 INTEGER 1
set_parameter_property CRS_SUPPORT_422_TO_444 DISPLAY_NAME "4:2:2 to 4:4:4 conversion"
set_parameter_property CRS_SUPPORT_422_TO_444 DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_422_TO_444 HDL_PARAMETER false

add_parameter CRS_SUPPORT_444_PASS INTEGER 1
set_parameter_property CRS_SUPPORT_444_PASS DISPLAY_NAME "4:4:4 passthrough"
set_parameter_property CRS_SUPPORT_444_PASS DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_444_PASS HDL_PARAMETER false

add_parameter CRS_SUPPORT_444_TO_420 INTEGER 0
set_parameter_property CRS_SUPPORT_444_TO_420 DISPLAY_NAME "4:4:4 to 4:2:0 conversion"
set_parameter_property CRS_SUPPORT_444_TO_420 DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_444_TO_420 HDL_PARAMETER false

add_parameter CRS_SUPPORT_444_TO_422 INTEGER 1
set_parameter_property CRS_SUPPORT_444_TO_422 DISPLAY_NAME "4:4:4 to 4:2:2 conversion"
set_parameter_property CRS_SUPPORT_444_TO_422 DISPLAY_HINT  boolean
set_parameter_property CRS_SUPPORT_444_TO_422 HDL_PARAMETER false

add_parameter CRS_HORIZ_ALGORITHM STRING "BILINEAR"
set_parameter_property CRS_HORIZ_ALGORITHM DISPLAY_NAME        "Horizontal resampling algorithm"
set_parameter_property CRS_HORIZ_ALGORITHM ALLOWED_RANGES       {NEAREST_NEIGHBOUR BILINEAR FILTERED}
set_parameter_property CRS_HORIZ_ALGORITHM AFFECTS_ELABORATION  true
set_parameter_property CRS_HORIZ_ALGORITHM HDL_PARAMETER        false

add_parameter CRS_HORIZ_CO_SITING STRING "LEFT"
set_parameter_property CRS_HORIZ_CO_SITING DISPLAY_NAME        "Horizontal chroma siting"
set_parameter_property CRS_HORIZ_CO_SITING ALLOWED_RANGES       {LEFT CENTER}
set_parameter_property CRS_HORIZ_CO_SITING HDL_PARAMETER        false

add_parameter CRS_HORIZ_ENABLE_LUMA_ADAPT INTEGER 0
set_parameter_property CRS_HORIZ_ENABLE_LUMA_ADAPT DISPLAY_NAME        "Horizontal luma adaptive resampling"
set_parameter_property CRS_HORIZ_ENABLE_LUMA_ADAPT DISPLAY_HINT         boolean
set_parameter_property CRS_HORIZ_ENABLE_LUMA_ADAPT HDL_PARAMETER        false

add_parameter CRS_VERT_ALGORITHM STRING "BILINEAR"
set_parameter_property CRS_VERT_ALGORITHM DISPLAY_NAME        "Vertical resampling algorithm"
set_parameter_property CRS_VERT_ALGORITHM ALLOWED_RANGES       {NEAREST_NEIGHBOUR BILINEAR FILTERED}
set_parameter_property CRS_VERT_ALGORITHM AFFECTS_ELABORATION  true
set_parameter_property CRS_VERT_ALGORITHM HDL_PARAMETER        false

add_parameter CRS_VERT_CO_SITING STRING "TOP"
set_parameter_property CRS_VERT_CO_SITING DISPLAY_NAME        "Vertical chroma siting"
set_parameter_property CRS_VERT_CO_SITING ALLOWED_RANGES       {TOP CENTER}
set_parameter_property CRS_VERT_CO_SITING HDL_PARAMETER        false

add_parameter CRS_VERT_ENABLE_LUMA_ADAPT INTEGER 0
set_parameter_property CRS_VERT_ENABLE_LUMA_ADAPT DISPLAY_NAME        "Vertical luma adaptive resampling"
set_parameter_property CRS_VERT_ENABLE_LUMA_ADAPT DISPLAY_HINT         boolean
set_parameter_property CRS_VERT_ENABLE_LUMA_ADAPT HDL_PARAMETER        false

add_parameter CRS_RUNTIME_CONTROL INTEGER 1
set_parameter_property CRS_RUNTIME_CONTROL DISPLAY_NAME        "Memory-mapped control interface"
set_parameter_property CRS_RUNTIME_CONTROL DISPLAY_HINT         boolean
set_parameter_property CRS_RUNTIME_CONTROL AFFECTS_ELABORATION  true
set_parameter_property CRS_RUNTIME_CONTROL HDL_PARAMETER        false

add_parameter CRS_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property CRS_SEPARATE_SLAVE_CLOCK DISPLAY_NAME        "Separate clock for control interface"
set_parameter_property CRS_SEPARATE_SLAVE_CLOCK DISPLAY_HINT         boolean
set_parameter_property CRS_SEPARATE_SLAVE_CLOCK AFFECTS_ELABORATION  true
set_parameter_property CRS_SEPARATE_SLAVE_CLOCK HDL_PARAMETER        false

add_parameter CRS_ENABLE_DEBUG INTEGER 0
set_parameter_property CRS_ENABLE_DEBUG DISPLAY_NAME        "Debug features"
set_parameter_property CRS_ENABLE_DEBUG DISPLAY_HINT         boolean
set_parameter_property CRS_ENABLE_DEBUG HDL_PARAMETER        false

add_parameter CRS_PIPELINE_READY INTEGER 0
set_parameter_property CRS_PIPELINE_READY DISPLAY_NAME        "Pipeline ready signals"
set_parameter_property CRS_PIPELINE_READY DISPLAY_HINT         boolean
set_parameter_property CRS_PIPELINE_READY HDL_PARAMETER        false

# ============================================================================
# CSC parameters
# ============================================================================
add_parameter CSC_EXTERNAL_MODE INTEGER 0
set_parameter_property CSC_EXTERNAL_MODE DISPLAY_NAME        "Lite mode"
set_parameter_property CSC_EXTERNAL_MODE DISPLAY_HINT         boolean
set_parameter_property CSC_EXTERNAL_MODE AFFECTS_ELABORATION  true
set_parameter_property CSC_EXTERNAL_MODE HDL_PARAMETER        false

add_parameter CSC_BPS_IN INTEGER 8
set_parameter_property CSC_BPS_IN DISPLAY_NAME        "Input bits per color sample"
set_parameter_property CSC_BPS_IN ALLOWED_RANGES       "8:16"
set_parameter_property CSC_BPS_IN HDL_PARAMETER        false

add_parameter CSC_BPS_OUT INTEGER 8
set_parameter_property CSC_BPS_OUT DISPLAY_NAME        "Output bits per color sample"
set_parameter_property CSC_BPS_OUT ALLOWED_RANGES       "8:16"
set_parameter_property CSC_BPS_OUT HDL_PARAMETER        false

add_parameter CSC_COLOR_SPACE_OUT STRING "YCbCr"
set_parameter_property CSC_COLOR_SPACE_OUT DISPLAY_NAME        "Output color space"
set_parameter_property CSC_COLOR_SPACE_OUT ALLOWED_RANGES       {RGB YCbCr MONO}
set_parameter_property CSC_COLOR_SPACE_OUT HDL_PARAMETER        false

add_parameter CSC_COEFF_FRAC_BITS INTEGER 12
set_parameter_property CSC_COEFF_FRAC_BITS DISPLAY_NAME        "Coefficient and summand fractional bits"
set_parameter_property CSC_COEFF_FRAC_BITS ALLOWED_RANGES       "0:24"
set_parameter_property CSC_COEFF_FRAC_BITS HDL_PARAMETER        false

add_parameter CSC_COEFF_SIGNED INTEGER 1
set_parameter_property CSC_COEFF_SIGNED DISPLAY_NAME        "Coefficients are signed"
set_parameter_property CSC_COEFF_SIGNED DISPLAY_HINT         boolean
set_parameter_property CSC_COEFF_SIGNED HDL_PARAMETER        false

add_parameter CSC_COEFF_INT_BITS INTEGER 2
set_parameter_property CSC_COEFF_INT_BITS DISPLAY_NAME        "Coefficient integer bits"
set_parameter_property CSC_COEFF_INT_BITS ALLOWED_RANGES       "0:16"
set_parameter_property CSC_COEFF_INT_BITS HDL_PARAMETER        false

add_parameter CSC_SUMMAND_SIGNED INTEGER 1
set_parameter_property CSC_SUMMAND_SIGNED DISPLAY_NAME        "Summands are signed"
set_parameter_property CSC_SUMMAND_SIGNED DISPLAY_HINT         boolean
set_parameter_property CSC_SUMMAND_SIGNED HDL_PARAMETER        false

add_parameter CSC_SUMMAND_INT_BITS INTEGER 8
set_parameter_property CSC_SUMMAND_INT_BITS DISPLAY_NAME        "Summand integer bits"
set_parameter_property CSC_SUMMAND_INT_BITS ALLOWED_RANGES       "0:20"
set_parameter_property CSC_SUMMAND_INT_BITS HDL_PARAMETER        false

add_parameter CSC_BIN_PT_SHIFT INTEGER 0
set_parameter_property CSC_BIN_PT_SHIFT DISPLAY_NAME        "Move binary point right"
set_parameter_property CSC_BIN_PT_SHIFT ALLOWED_RANGES       "-16:16"
set_parameter_property CSC_BIN_PT_SHIFT HDL_PARAMETER        false

add_parameter CSC_ROUNDING STRING "HALF_UP"
set_parameter_property CSC_ROUNDING DISPLAY_NAME        "Remove fraction bits by"
set_parameter_property CSC_ROUNDING ALLOWED_RANGES       {"HALF_UP:Round values - half up" "HALF_EVEN:Round values - half even" "TRUNCATE:Truncate values to integer"}
set_parameter_property CSC_ROUNDING HDL_PARAMETER        false

add_parameter CSC_C00 FLOAT 0.2126
set_parameter_property CSC_C00 DISPLAY_NAME "Coefficient 0-0 (A row 0)"
set_parameter_property CSC_C00 HDL_PARAMETER false

add_parameter CSC_C01 FLOAT 0.7152
set_parameter_property CSC_C01 DISPLAY_NAME "Coefficient 0-1 (B row 0)"
set_parameter_property CSC_C01 HDL_PARAMETER false

add_parameter CSC_C02 FLOAT 0.0722
set_parameter_property CSC_C02 DISPLAY_NAME "Coefficient 0-2 (C row 0)"
set_parameter_property CSC_C02 HDL_PARAMETER false

add_parameter CSC_S0 FLOAT 0.0
set_parameter_property CSC_S0 DISPLAY_NAME "Summand row 0"
set_parameter_property CSC_S0 HDL_PARAMETER false

add_parameter CSC_C10 FLOAT -0.1146
set_parameter_property CSC_C10 DISPLAY_NAME "Coefficient 1-0 (A row 1)"
set_parameter_property CSC_C10 HDL_PARAMETER false

add_parameter CSC_C11 FLOAT -0.3854
set_parameter_property CSC_C11 DISPLAY_NAME "Coefficient 1-1 (B row 1)"
set_parameter_property CSC_C11 HDL_PARAMETER false

add_parameter CSC_C12 FLOAT 0.5000
set_parameter_property CSC_C12 DISPLAY_NAME "Coefficient 1-2 (C row 1)"
set_parameter_property CSC_C12 HDL_PARAMETER false

add_parameter CSC_S1 FLOAT 128.0
set_parameter_property CSC_S1 DISPLAY_NAME "Summand row 1"
set_parameter_property CSC_S1 HDL_PARAMETER false

add_parameter CSC_C20 FLOAT 0.5000
set_parameter_property CSC_C20 DISPLAY_NAME "Coefficient 2-0 (A row 2)"
set_parameter_property CSC_C20 HDL_PARAMETER false

add_parameter CSC_C21 FLOAT -0.4542
set_parameter_property CSC_C21 DISPLAY_NAME "Coefficient 2-1 (B row 2)"
set_parameter_property CSC_C21 HDL_PARAMETER false

add_parameter CSC_C22 FLOAT -0.0458
set_parameter_property CSC_C22 DISPLAY_NAME "Coefficient 2-2 (C row 2)"
set_parameter_property CSC_C22 HDL_PARAMETER false

add_parameter CSC_S2 FLOAT 128.0
set_parameter_property CSC_S2 DISPLAY_NAME "Summand row 2"
set_parameter_property CSC_S2 HDL_PARAMETER false

add_parameter CSC_RUNTIME_CONTROL INTEGER 1
set_parameter_property CSC_RUNTIME_CONTROL DISPLAY_NAME        "Memory-mapped control interface"
set_parameter_property CSC_RUNTIME_CONTROL DISPLAY_HINT         boolean
set_parameter_property CSC_RUNTIME_CONTROL AFFECTS_ELABORATION  true
set_parameter_property CSC_RUNTIME_CONTROL HDL_PARAMETER        false

add_parameter CSC_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property CSC_SEPARATE_SLAVE_CLOCK DISPLAY_NAME        "Separate clock for control interface"
set_parameter_property CSC_SEPARATE_SLAVE_CLOCK DISPLAY_HINT         boolean
set_parameter_property CSC_SEPARATE_SLAVE_CLOCK AFFECTS_ELABORATION  true
set_parameter_property CSC_SEPARATE_SLAVE_CLOCK HDL_PARAMETER        false

add_parameter CSC_ENABLE_DEBUG INTEGER 0
set_parameter_property CSC_ENABLE_DEBUG DISPLAY_NAME        "Debug features"
set_parameter_property CSC_ENABLE_DEBUG DISPLAY_HINT         boolean
set_parameter_property CSC_ENABLE_DEBUG HDL_PARAMETER        false

add_parameter CSC_PIPELINE_READY INTEGER 0
set_parameter_property CSC_PIPELINE_READY DISPLAY_NAME        "Pipeline ready signals"
set_parameter_property CSC_PIPELINE_READY DISPLAY_HINT         boolean
set_parameter_property CSC_PIPELINE_READY HDL_PARAMETER        false

# ============================================================================
# CLIPPER parameters
# ============================================================================
add_parameter CL_EXTERNAL_MODE INTEGER 0
set_parameter_property CL_EXTERNAL_MODE DISPLAY_NAME        "Lite mode"
set_parameter_property CL_EXTERNAL_MODE DISPLAY_HINT         boolean
set_parameter_property CL_EXTERNAL_MODE AFFECTS_ELABORATION  true
set_parameter_property CL_EXTERNAL_MODE HDL_PARAMETER        false

add_parameter CL_RUNTIME_CONTROL INTEGER 1
set_parameter_property CL_RUNTIME_CONTROL DISPLAY_NAME        "Memory-mapped control interface"
set_parameter_property CL_RUNTIME_CONTROL DISPLAY_HINT         boolean
set_parameter_property CL_RUNTIME_CONTROL AFFECTS_ELABORATION  true
set_parameter_property CL_RUNTIME_CONTROL HDL_PARAMETER        false

add_parameter CL_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property CL_SEPARATE_SLAVE_CLOCK DISPLAY_NAME        "Separate clock for control interface"
set_parameter_property CL_SEPARATE_SLAVE_CLOCK DISPLAY_HINT         boolean
set_parameter_property CL_SEPARATE_SLAVE_CLOCK AFFECTS_ELABORATION  true
set_parameter_property CL_SEPARATE_SLAVE_CLOCK HDL_PARAMETER        false

add_parameter CL_ENABLE_DEBUG INTEGER 0
set_parameter_property CL_ENABLE_DEBUG DISPLAY_NAME        "Debug features"
set_parameter_property CL_ENABLE_DEBUG DISPLAY_HINT         boolean
set_parameter_property CL_ENABLE_DEBUG HDL_PARAMETER        false

add_parameter CL_PIPELINE_READY INTEGER 0
set_parameter_property CL_PIPELINE_READY DISPLAY_NAME        "Pipeline ready signals"
set_parameter_property CL_PIPELINE_READY DISPLAY_HINT         boolean
set_parameter_property CL_PIPELINE_READY HDL_PARAMETER        false

add_parameter CL_CLIPPING_METHOD STRING "RECTANGLE"
set_parameter_property CL_CLIPPING_METHOD DISPLAY_NAME        "Clipping method"
set_parameter_property CL_CLIPPING_METHOD ALLOWED_RANGES       {"RECTANGLE:Clipping with output dimensions" "OFFSETS:Clipping with offsets"}
set_parameter_property CL_CLIPPING_METHOD AFFECTS_ELABORATION  true
set_parameter_property CL_CLIPPING_METHOD HDL_PARAMETER        false

add_parameter CL_LEFT_OFFSET INTEGER 0
set_parameter_property CL_LEFT_OFFSET DISPLAY_NAME        "Left offset / X start"
set_parameter_property CL_LEFT_OFFSET ALLOWED_RANGES       "0:16383"
set_parameter_property CL_LEFT_OFFSET HDL_PARAMETER        false

add_parameter CL_TOP_OFFSET INTEGER 0
set_parameter_property CL_TOP_OFFSET DISPLAY_NAME        "Top offset / Y start"
set_parameter_property CL_TOP_OFFSET ALLOWED_RANGES       "0:16383"
set_parameter_property CL_TOP_OFFSET HDL_PARAMETER        false

add_parameter CL_RIGHT_OFFSET INTEGER 0
set_parameter_property CL_RIGHT_OFFSET DISPLAY_NAME        "Right offset"
set_parameter_property CL_RIGHT_OFFSET ALLOWED_RANGES       "0:16383"
set_parameter_property CL_RIGHT_OFFSET HDL_PARAMETER        false

add_parameter CL_BOTTOM_OFFSET INTEGER 0
set_parameter_property CL_BOTTOM_OFFSET DISPLAY_NAME        "Bottom offset"
set_parameter_property CL_BOTTOM_OFFSET ALLOWED_RANGES       "0:16383"
set_parameter_property CL_BOTTOM_OFFSET HDL_PARAMETER        false

add_parameter CL_OUTPUT_WIDTH INTEGER 1920
set_parameter_property CL_OUTPUT_WIDTH DISPLAY_NAME        "Output width"
set_parameter_property CL_OUTPUT_WIDTH ALLOWED_RANGES       "1:16384"
set_parameter_property CL_OUTPUT_WIDTH HDL_PARAMETER        false

add_parameter CL_OUTPUT_HEIGHT INTEGER 1080
set_parameter_property CL_OUTPUT_HEIGHT DISPLAY_NAME        "Output height"
set_parameter_property CL_OUTPUT_HEIGHT ALLOWED_RANGES       "1:16384"
set_parameter_property CL_OUTPUT_HEIGHT HDL_PARAMETER        false

# ============================================================================
# PROTOCOL CONVERTER (PC0) parameters
# ============================================================================
add_parameter PC0_ENABLE_YCBCR_SWAP INTEGER 0
set_parameter_property PC0_ENABLE_YCBCR_SWAP DISPLAY_NAME        "YCbCr 444 color swap"
set_parameter_property PC0_ENABLE_YCBCR_SWAP DISPLAY_HINT         boolean
set_parameter_property PC0_ENABLE_YCBCR_SWAP HDL_PARAMETER        false

add_parameter PC0_VVP_USER_SUPPORT STRING "NONE_ALLOWED"
set_parameter_property PC0_VVP_USER_SUPPORT DISPLAY_NAME        "How Altera Streaming Video aux packets are handled"
set_parameter_property PC0_VVP_USER_SUPPORT ALLOWED_RANGES       {"NONE_ALLOWED:Disable aux input" "PASS:Pass all aux packets through" "EMBED:Embed aux packets"}
set_parameter_property PC0_VVP_USER_SUPPORT HDL_PARAMETER        false

add_parameter PC0_VIP_USER_SUPPORT STRING "DISCARD"
set_parameter_property PC0_VIP_USER_SUPPORT DISPLAY_NAME        "How Avalon-ST Video user packets are handled"
set_parameter_property PC0_VIP_USER_SUPPORT ALLOWED_RANGES       {"DISCARD:Discard all user packets" "PASS:Pass all user packets through"}
set_parameter_property PC0_VIP_USER_SUPPORT HDL_PARAMETER        false

add_parameter PC0_COLOR_SPACE STRING "YCbCr"
set_parameter_property PC0_COLOR_SPACE DISPLAY_NAME        "Video color space"
set_parameter_property PC0_COLOR_SPACE ALLOWED_RANGES       {RGB YCbCr}
set_parameter_property PC0_COLOR_SPACE HDL_PARAMETER        false

add_parameter PC0_CHROMA_SAMPLING STRING "422"
set_parameter_property PC0_CHROMA_SAMPLING DISPLAY_NAME        "Video chroma sampling"
set_parameter_property PC0_CHROMA_SAMPLING ALLOWED_RANGES       {444 422 420}
set_parameter_property PC0_CHROMA_SAMPLING HDL_PARAMETER        false

add_parameter PC0_CHROMA_SITING STRING "TOP_LEFT"
set_parameter_property PC0_CHROMA_SITING DISPLAY_NAME        "Video chroma siting"
set_parameter_property PC0_CHROMA_SITING ALLOWED_RANGES       {TOP_LEFT TOP_CENTER CENTER}
set_parameter_property PC0_CHROMA_SITING HDL_PARAMETER        false

add_parameter PC0_CLIP_LONG_FIELDS INTEGER 0
set_parameter_property PC0_CLIP_LONG_FIELDS DISPLAY_NAME        "Clip long fields"
set_parameter_property PC0_CLIP_LONG_FIELDS DISPLAY_HINT         boolean
set_parameter_property PC0_CLIP_LONG_FIELDS HDL_PARAMETER        false

add_parameter PC0_ENABLE_TIMEOUT INTEGER 0
set_parameter_property PC0_ENABLE_TIMEOUT DISPLAY_NAME        "Enable timeout"
set_parameter_property PC0_ENABLE_TIMEOUT DISPLAY_HINT         boolean
set_parameter_property PC0_ENABLE_TIMEOUT HDL_PARAMETER        false

add_parameter PC0_ENABLE_LOW_LATENCY INTEGER 0
set_parameter_property PC0_ENABLE_LOW_LATENCY DISPLAY_NAME        "Enable low latency mode (Lite output)"
set_parameter_property PC0_ENABLE_LOW_LATENCY DISPLAY_HINT         boolean
set_parameter_property PC0_ENABLE_LOW_LATENCY HDL_PARAMETER        false

add_parameter PC0_RUNTIME_CONTROL INTEGER 0
set_parameter_property PC0_RUNTIME_CONTROL DISPLAY_NAME        "Memory-mapped control interface"
set_parameter_property PC0_RUNTIME_CONTROL DISPLAY_HINT         boolean
set_parameter_property PC0_RUNTIME_CONTROL AFFECTS_ELABORATION  true
set_parameter_property PC0_RUNTIME_CONTROL HDL_PARAMETER        false

add_parameter PC0_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property PC0_SEPARATE_SLAVE_CLOCK DISPLAY_NAME        "Separate clock for control interface"
set_parameter_property PC0_SEPARATE_SLAVE_CLOCK DISPLAY_HINT         boolean
set_parameter_property PC0_SEPARATE_SLAVE_CLOCK AFFECTS_ELABORATION  true
set_parameter_property PC0_SEPARATE_SLAVE_CLOCK HDL_PARAMETER        false

add_parameter PC0_ENABLE_DEBUG INTEGER 0
set_parameter_property PC0_ENABLE_DEBUG DISPLAY_NAME        "Debug features"
set_parameter_property PC0_ENABLE_DEBUG DISPLAY_HINT         boolean
set_parameter_property PC0_ENABLE_DEBUG HDL_PARAMETER        false

add_parameter PC0_PIPELINE_READY INTEGER 0
set_parameter_property PC0_PIPELINE_READY DISPLAY_NAME        "Pipeline ready signals"
set_parameter_property PC0_PIPELINE_READY DISPLAY_HINT         boolean
set_parameter_property PC0_PIPELINE_READY HDL_PARAMETER        false

# ============================================================================
# SCALER parameters
# ============================================================================
add_parameter SC_EXTERNAL_MODE INTEGER 1
set_parameter_property SC_EXTERNAL_MODE DISPLAY_NAME        "Lite mode"
set_parameter_property SC_EXTERNAL_MODE DISPLAY_HINT         boolean
set_parameter_property SC_EXTERNAL_MODE AFFECTS_ELABORATION  true
set_parameter_property SC_EXTERNAL_MODE HDL_PARAMETER        false

add_parameter SC_ENABLE_444 INTEGER 1
set_parameter_property SC_ENABLE_444 DISPLAY_NAME        "4:4:4 chroma sampling"
set_parameter_property SC_ENABLE_444 DISPLAY_HINT         boolean
set_parameter_property SC_ENABLE_444 HDL_PARAMETER        false

add_parameter SC_ENABLE_422 INTEGER 0
set_parameter_property SC_ENABLE_422 DISPLAY_NAME        "4:2:2 chroma sampling"
set_parameter_property SC_ENABLE_422 DISPLAY_HINT         boolean
set_parameter_property SC_ENABLE_422 HDL_PARAMETER        false

add_parameter SC_ENABLE_420 INTEGER 0
set_parameter_property SC_ENABLE_420 DISPLAY_NAME        "4:2:0 chroma sampling"
set_parameter_property SC_ENABLE_420 DISPLAY_HINT         boolean
set_parameter_property SC_ENABLE_420 AFFECTS_ELABORATION  true
set_parameter_property SC_ENABLE_420 HDL_PARAMETER        false

add_parameter SC_NO_BLANKING INTEGER 0
set_parameter_property SC_NO_BLANKING DISPLAY_NAME        "Disable flush/fill between frames"
set_parameter_property SC_NO_BLANKING DISPLAY_HINT         boolean
set_parameter_property SC_NO_BLANKING HDL_PARAMETER        false

add_parameter SC_MAX_IN_WIDTH INTEGER 1920
set_parameter_property SC_MAX_IN_WIDTH DISPLAY_NAME        "Maximum input field width"
set_parameter_property SC_MAX_IN_WIDTH ALLOWED_RANGES       "1:65536"
set_parameter_property SC_MAX_IN_WIDTH HDL_PARAMETER        false

add_parameter SC_MAX_OUT_WIDTH INTEGER 1280
set_parameter_property SC_MAX_OUT_WIDTH DISPLAY_NAME        "Maximum output field width"
set_parameter_property SC_MAX_OUT_WIDTH ALLOWED_RANGES       "1:65536"
set_parameter_property SC_MAX_OUT_WIDTH HDL_PARAMETER        false

add_parameter SC_OUTPUT_HEIGHT INTEGER 720
set_parameter_property SC_OUTPUT_HEIGHT DISPLAY_NAME        "Output picture height"
set_parameter_property SC_OUTPUT_HEIGHT ALLOWED_RANGES       "1:65536"
set_parameter_property SC_OUTPUT_HEIGHT HDL_PARAMETER        false

add_parameter SC_RUNTIME_CONTROL INTEGER 1
set_parameter_property SC_RUNTIME_CONTROL DISPLAY_NAME        "Memory-mapped control interface"
set_parameter_property SC_RUNTIME_CONTROL DISPLAY_HINT         boolean
set_parameter_property SC_RUNTIME_CONTROL AFFECTS_ELABORATION  true
set_parameter_property SC_RUNTIME_CONTROL HDL_PARAMETER        false

add_parameter SC_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property SC_SEPARATE_SLAVE_CLOCK DISPLAY_NAME        "Separate clock for control interface"
set_parameter_property SC_SEPARATE_SLAVE_CLOCK DISPLAY_HINT         boolean
set_parameter_property SC_SEPARATE_SLAVE_CLOCK AFFECTS_ELABORATION  true
set_parameter_property SC_SEPARATE_SLAVE_CLOCK HDL_PARAMETER        false

add_parameter SC_ENABLE_DEBUG INTEGER 0
set_parameter_property SC_ENABLE_DEBUG DISPLAY_NAME        "Debug features"
set_parameter_property SC_ENABLE_DEBUG DISPLAY_HINT         boolean
set_parameter_property SC_ENABLE_DEBUG HDL_PARAMETER        false

add_parameter SC_PIPELINE_READY INTEGER 0
set_parameter_property SC_PIPELINE_READY DISPLAY_NAME        "Pipeline ready signals"
set_parameter_property SC_PIPELINE_READY DISPLAY_HINT         boolean
set_parameter_property SC_PIPELINE_READY HDL_PARAMETER        false

add_parameter SC_ALGORITHM STRING "POLYPHASE"
set_parameter_property SC_ALGORITHM DISPLAY_NAME        "Scaling algorithm"
set_parameter_property SC_ALGORITHM ALLOWED_RANGES       {NEAREST_NEIGHBOUR BILINEAR POLYPHASE}
set_parameter_property SC_ALGORITHM AFFECTS_ELABORATION  true
set_parameter_property SC_ALGORITHM HDL_PARAMETER        false

add_parameter SC_EDGE_MIRROR STRING "REPLICATE"
set_parameter_property SC_EDGE_MIRROR DISPLAY_NAME        "Edge behavior"
set_parameter_property SC_EDGE_MIRROR ALLOWED_RANGES       {"REPLICATE:Replicate edge pixel" "REFLECT:Mirror edge pixels"}
set_parameter_property SC_EDGE_MIRROR HDL_PARAMETER        false

add_parameter SC_RUNTIME_LOAD INTEGER 1
set_parameter_property SC_RUNTIME_LOAD DISPLAY_NAME        "Runtime coefficient updates"
set_parameter_property SC_RUNTIME_LOAD DISPLAY_HINT         boolean
set_parameter_property SC_RUNTIME_LOAD HDL_PARAMETER        false

add_parameter SC_MEM_INIT INTEGER 1
set_parameter_property SC_MEM_INIT DISPLAY_NAME        "Initialize coefficients at startup"
set_parameter_property SC_MEM_INIT DISPLAY_HINT         boolean
set_parameter_property SC_MEM_INIT AFFECTS_ELABORATION  true
set_parameter_property SC_MEM_INIT HDL_PARAMETER        false

add_parameter SC_ENABLE_V INTEGER 1
set_parameter_property SC_ENABLE_V DISPLAY_NAME        "Vertical scaling enabled"
set_parameter_property SC_ENABLE_V DISPLAY_HINT         boolean
set_parameter_property SC_ENABLE_V AFFECTS_ELABORATION  true
set_parameter_property SC_ENABLE_V HDL_PARAMETER        false

add_parameter SC_V_PARTIAL_SCALING INTEGER 0
set_parameter_property SC_V_PARTIAL_SCALING DISPLAY_NAME        "Vertical partial image scaling"
set_parameter_property SC_V_PARTIAL_SCALING DISPLAY_HINT         boolean
set_parameter_property SC_V_PARTIAL_SCALING HDL_PARAMETER        false

add_parameter SC_ENABLE_420_MIRROR INTEGER 0
set_parameter_property SC_ENABLE_420_MIRROR DISPLAY_NAME        "Mirror 420 chroma data"
set_parameter_property SC_ENABLE_420_MIRROR DISPLAY_HINT         boolean
set_parameter_property SC_ENABLE_420_MIRROR HDL_PARAMETER        false

add_parameter SC_V_TAPS INTEGER 4
set_parameter_property SC_V_TAPS DISPLAY_NAME        "Number of vertical taps"
set_parameter_property SC_V_TAPS ALLOWED_RANGES       {1 2 4 8 12 16 32 64}
set_parameter_property SC_V_TAPS HDL_PARAMETER        false

add_parameter SC_V_PHASES INTEGER 16
set_parameter_property SC_V_PHASES DISPLAY_NAME        "Number of vertical phases"
set_parameter_property SC_V_PHASES ALLOWED_RANGES       {2 4 8 16 32 64 128 256}
set_parameter_property SC_V_PHASES HDL_PARAMETER        false

add_parameter SC_V_BANKS INTEGER 1
set_parameter_property SC_V_BANKS DISPLAY_NAME        "Number of vertical banks"
set_parameter_property SC_V_BANKS ALLOWED_RANGES       {1 2 4 8 16}
set_parameter_property SC_V_BANKS HDL_PARAMETER        false

add_parameter SC_V_COEFF_SIGNED INTEGER 1
set_parameter_property SC_V_COEFF_SIGNED DISPLAY_NAME        "Use signed vertical coefficients"
set_parameter_property SC_V_COEFF_SIGNED DISPLAY_HINT         boolean
set_parameter_property SC_V_COEFF_SIGNED HDL_PARAMETER        false

add_parameter SC_V_COEFF_INT_BITS INTEGER 2
set_parameter_property SC_V_COEFF_INT_BITS DISPLAY_NAME        "Vertical coefficient integer bits"
set_parameter_property SC_V_COEFF_INT_BITS ALLOWED_RANGES       "0:17"
set_parameter_property SC_V_COEFF_INT_BITS HDL_PARAMETER        false

add_parameter SC_V_COEFF_FRAC_BITS INTEGER 10
set_parameter_property SC_V_COEFF_FRAC_BITS DISPLAY_NAME        "Vertical coefficient fraction bits"
set_parameter_property SC_V_COEFF_FRAC_BITS ALLOWED_RANGES       "1:18"
set_parameter_property SC_V_COEFF_FRAC_BITS HDL_PARAMETER        false

add_parameter SC_V_PRES_FRAC_BITS INTEGER 6
set_parameter_property SC_V_PRES_FRAC_BITS DISPLAY_NAME        "Fraction bits preserved between V and H scaling"
set_parameter_property SC_V_PRES_FRAC_BITS ALLOWED_RANGES       "0:18"
set_parameter_property SC_V_PRES_FRAC_BITS HDL_PARAMETER        false

add_parameter SC_V_COEFF_FUNCTION STRING "LANCZOS_3"
set_parameter_property SC_V_COEFF_FUNCTION DISPLAY_NAME        "Vertical coefficient function"
set_parameter_property SC_V_COEFF_FUNCTION ALLOWED_RANGES       {BICUBIC LANCZOS_1 LANCZOS_2 LANCZOS_3 LANCZOS_4}
set_parameter_property SC_V_COEFF_FUNCTION HDL_PARAMETER        false

add_parameter SC_V_INIT_FILE STRING ""
set_parameter_property SC_V_INIT_FILE DISPLAY_NAME        "Vertical coefficient init file"
set_parameter_property SC_V_INIT_FILE DISPLAY_HINT         file
set_parameter_property SC_V_INIT_FILE HDL_PARAMETER        false

add_parameter SC_ENABLE_H INTEGER 1
set_parameter_property SC_ENABLE_H DISPLAY_NAME        "Horizontal scaling enabled"
set_parameter_property SC_ENABLE_H DISPLAY_HINT         boolean
set_parameter_property SC_ENABLE_H AFFECTS_ELABORATION  true
set_parameter_property SC_ENABLE_H HDL_PARAMETER        false

add_parameter SC_H_PARTIAL_SCALING INTEGER 0
set_parameter_property SC_H_PARTIAL_SCALING DISPLAY_NAME        "Horizontal partial image scaling"
set_parameter_property SC_H_PARTIAL_SCALING DISPLAY_HINT         boolean
set_parameter_property SC_H_PARTIAL_SCALING HDL_PARAMETER        false

add_parameter SC_HALF_RATE_420 INTEGER 0
set_parameter_property SC_HALF_RATE_420 DISPLAY_NAME        "Half rate 420"
set_parameter_property SC_HALF_RATE_420 DISPLAY_HINT         boolean
set_parameter_property SC_HALF_RATE_420 HDL_PARAMETER        false

add_parameter SC_H_TAPS INTEGER 4
set_parameter_property SC_H_TAPS DISPLAY_NAME        "Number of horizontal taps"
set_parameter_property SC_H_TAPS ALLOWED_RANGES       {1 2 4 8 12 16 32 64}
set_parameter_property SC_H_TAPS HDL_PARAMETER        false

add_parameter SC_H_PHASES INTEGER 16
set_parameter_property SC_H_PHASES DISPLAY_NAME        "Number of horizontal phases"
set_parameter_property SC_H_PHASES ALLOWED_RANGES       {2 4 8 16 32 64 128 256}
set_parameter_property SC_H_PHASES HDL_PARAMETER        false

add_parameter SC_H_BANKS INTEGER 1
set_parameter_property SC_H_BANKS DISPLAY_NAME        "Number of horizontal banks"
set_parameter_property SC_H_BANKS ALLOWED_RANGES       {1 2 4 8 16}
set_parameter_property SC_H_BANKS HDL_PARAMETER        false

add_parameter SC_H_COEFF_SIGNED INTEGER 1
set_parameter_property SC_H_COEFF_SIGNED DISPLAY_NAME        "Use signed horizontal coefficients"
set_parameter_property SC_H_COEFF_SIGNED DISPLAY_HINT         boolean
set_parameter_property SC_H_COEFF_SIGNED HDL_PARAMETER        false

add_parameter SC_H_COEFF_INT_BITS INTEGER 2
set_parameter_property SC_H_COEFF_INT_BITS DISPLAY_NAME        "Horizontal coefficient integer bits"
set_parameter_property SC_H_COEFF_INT_BITS ALLOWED_RANGES       "0:17"
set_parameter_property SC_H_COEFF_INT_BITS HDL_PARAMETER        false

add_parameter SC_H_COEFF_FRAC_BITS INTEGER 6
set_parameter_property SC_H_COEFF_FRAC_BITS DISPLAY_NAME        "Horizontal coefficient fraction bits"
set_parameter_property SC_H_COEFF_FRAC_BITS ALLOWED_RANGES       "1:8"
set_parameter_property SC_H_COEFF_FRAC_BITS HDL_PARAMETER        false

add_parameter SC_H_COEFF_FUNCTION STRING "LANCZOS_3"
set_parameter_property SC_H_COEFF_FUNCTION DISPLAY_NAME        "Horizontal coefficient function"
set_parameter_property SC_H_COEFF_FUNCTION ALLOWED_RANGES       {BICUBIC LANCZOS_1 LANCZOS_2 LANCZOS_3 LANCZOS_4}
set_parameter_property SC_H_COEFF_FUNCTION HDL_PARAMETER        false

add_parameter SC_H_INIT_FILE STRING ""
set_parameter_property SC_H_INIT_FILE DISPLAY_NAME        "Horizontal coefficient init file"
set_parameter_property SC_H_INIT_FILE DISPLAY_HINT         file
set_parameter_property SC_H_INIT_FILE HDL_PARAMETER        false

# ============================================================================
# FRAME RATE CONVERSION (FRC / Video Frame Buffer) parameters
# Defaults match the configuration validated on the frame_buf_addition branch
# (VFB + EMIF IO96B DDR4 + memory model simulation).
# ============================================================================
add_parameter FRC_MAX_WIDTH INTEGER 128
set_parameter_property FRC_MAX_WIDTH DISPLAY_NAME        "Maximum frame width"
set_parameter_property FRC_MAX_WIDTH ALLOWED_RANGES       "1:16384"
set_parameter_property FRC_MAX_WIDTH HDL_PARAMETER        false

add_parameter FRC_MAX_HEIGHT INTEGER 96
set_parameter_property FRC_MAX_HEIGHT DISPLAY_NAME        "Maximum frame height"
set_parameter_property FRC_MAX_HEIGHT ALLOWED_RANGES       "1:16384"
set_parameter_property FRC_MAX_HEIGHT HDL_PARAMETER        false

add_parameter FRC_FRAME_DROP_ENABLE INTEGER 1
set_parameter_property FRC_FRAME_DROP_ENABLE DISPLAY_NAME        "Enable dropping of input frames"
set_parameter_property FRC_FRAME_DROP_ENABLE DISPLAY_HINT         boolean
set_parameter_property FRC_FRAME_DROP_ENABLE HDL_PARAMETER        false

add_parameter FRC_FRAME_REPEAT_ENABLE INTEGER 1
set_parameter_property FRC_FRAME_REPEAT_ENABLE DISPLAY_NAME        "Enable repeating of output frames"
set_parameter_property FRC_FRAME_REPEAT_ENABLE DISPLAY_HINT         boolean
set_parameter_property FRC_FRAME_REPEAT_ENABLE HDL_PARAMETER        false

add_parameter FRC_DROP_BROKEN_FRAMES INTEGER 1
set_parameter_property FRC_DROP_BROKEN_FRAMES DISPLAY_NAME        "Drop broken frames"
set_parameter_property FRC_DROP_BROKEN_FRAMES DISPLAY_HINT         boolean
set_parameter_property FRC_DROP_BROKEN_FRAMES HDL_PARAMETER        false

add_parameter FRC_DROP_RPT_AUX INTEGER 1
set_parameter_property FRC_DROP_RPT_AUX DISPLAY_NAME        "Drop/repeat aux packets with frames"
set_parameter_property FRC_DROP_RPT_AUX DISPLAY_HINT         boolean
set_parameter_property FRC_DROP_RPT_AUX HDL_PARAMETER        false

add_parameter FRC_MAX_CONTROL_PACKETS INTEGER 0
set_parameter_property FRC_MAX_CONTROL_PACKETS DISPLAY_NAME        "Maximum stored control packets"
set_parameter_property FRC_MAX_CONTROL_PACKETS ALLOWED_RANGES       "0:16"
set_parameter_property FRC_MAX_CONTROL_PACKETS HDL_PARAMETER        false

add_parameter FRC_INCLUDE_EMIF INTEGER 1
set_parameter_property FRC_INCLUDE_EMIF DISPLAY_NAME        "Include DDR4 EMIF (IO96B) inside the subsystem"
set_parameter_property FRC_INCLUDE_EMIF DISPLAY_HINT         boolean
set_parameter_property FRC_INCLUDE_EMIF DESCRIPTION          "When enabled the DDR4 external memory interface is instantiated inside the subsystem and its memory I/Os (mem, mem_ck, mem_reset_n, oct, ref_clk) are exported - connect the DDR4 device or memory model to them at system level. When disabled the frame buffer's raw Avalon-MM read/write hosts are exported instead."
set_parameter_property FRC_INCLUDE_EMIF AFFECTS_ELABORATION  true
set_parameter_property FRC_INCLUDE_EMIF HDL_PARAMETER        false

add_parameter FRC_AV_MM_DATA_WIDTH INTEGER 256
set_parameter_property FRC_AV_MM_DATA_WIDTH DISPLAY_NAME        "Memory port data width (bits)"
set_parameter_property FRC_AV_MM_DATA_WIDTH ALLOWED_RANGES       {16 32 64 128 256 512 1024}
set_parameter_property FRC_AV_MM_DATA_WIDTH HDL_PARAMETER        false

add_parameter FRC_AV_MM_ADDR_WIDTH INTEGER 32
set_parameter_property FRC_AV_MM_ADDR_WIDTH DISPLAY_NAME        "Memory port address width (bits)"
set_parameter_property FRC_AV_MM_ADDR_WIDTH ALLOWED_RANGES       "8:32"
set_parameter_property FRC_AV_MM_ADDR_WIDTH HDL_PARAMETER        false

add_parameter FRC_WRITE_FIFO_DEPTH INTEGER 64
set_parameter_property FRC_WRITE_FIFO_DEPTH DISPLAY_NAME        "Write FIFO depth"
set_parameter_property FRC_WRITE_FIFO_DEPTH ALLOWED_RANGES       {32 64 128 256 512 1024 2048}
set_parameter_property FRC_WRITE_FIFO_DEPTH HDL_PARAMETER        false

add_parameter FRC_WRITE_BURST_TARGET INTEGER 8
set_parameter_property FRC_WRITE_BURST_TARGET DISPLAY_NAME        "Write burst target"
set_parameter_property FRC_WRITE_BURST_TARGET ALLOWED_RANGES       {2 4 8 16 32 64}
set_parameter_property FRC_WRITE_BURST_TARGET HDL_PARAMETER        false

add_parameter FRC_READ_FIFO_DEPTH INTEGER 64
set_parameter_property FRC_READ_FIFO_DEPTH DISPLAY_NAME        "Read FIFO depth"
set_parameter_property FRC_READ_FIFO_DEPTH ALLOWED_RANGES       {32 64 128 256 512 1024 2048}
set_parameter_property FRC_READ_FIFO_DEPTH HDL_PARAMETER        false

add_parameter FRC_READ_BURST_TARGET INTEGER 8
set_parameter_property FRC_READ_BURST_TARGET DISPLAY_NAME        "Read burst target"
set_parameter_property FRC_READ_BURST_TARGET ALLOWED_RANGES       {2 4 8 16 32 64}
set_parameter_property FRC_READ_BURST_TARGET HDL_PARAMETER        false

add_parameter FRC_PACKING STRING "PERFECT"
set_parameter_property FRC_PACKING DISPLAY_NAME        "Packing method"
set_parameter_property FRC_PACKING ALLOWED_RANGES       {PERFECT COLOR PIXEL}
set_parameter_property FRC_PACKING HDL_PARAMETER        false

add_parameter FRC_CLOCKS_ARE_SEPARATE INTEGER 1
set_parameter_property FRC_CLOCKS_ARE_SEPARATE DISPLAY_NAME        "Separate clock for memory interface"
set_parameter_property FRC_CLOCKS_ARE_SEPARATE DISPLAY_HINT         boolean
set_parameter_property FRC_CLOCKS_ARE_SEPARATE AFFECTS_ELABORATION  true
set_parameter_property FRC_CLOCKS_ARE_SEPARATE HDL_PARAMETER        false

add_parameter FRC_MEM_BUFF_BASE_ADDR INTEGER 0
set_parameter_property FRC_MEM_BUFF_BASE_ADDR DISPLAY_NAME        "Frame buffer memory base address"
set_parameter_property FRC_MEM_BUFF_BASE_ADDR HDL_PARAMETER        false

add_parameter FRC_MEM_BUFF_LINE_STRIDE INTEGER 512
set_parameter_property FRC_MEM_BUFF_LINE_STRIDE DISPLAY_NAME        "Interline stride (bytes)"
set_parameter_property FRC_MEM_BUFF_LINE_STRIDE HDL_PARAMETER        false

add_parameter FRC_RUNTIME_CONTROL INTEGER 1
set_parameter_property FRC_RUNTIME_CONTROL DISPLAY_NAME        "Memory-mapped control interface"
set_parameter_property FRC_RUNTIME_CONTROL DISPLAY_HINT         boolean
set_parameter_property FRC_RUNTIME_CONTROL AFFECTS_ELABORATION  true
set_parameter_property FRC_RUNTIME_CONTROL HDL_PARAMETER        false

add_parameter FRC_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property FRC_SEPARATE_SLAVE_CLOCK DISPLAY_NAME        "Separate clock for control interface"
set_parameter_property FRC_SEPARATE_SLAVE_CLOCK DISPLAY_HINT         boolean
set_parameter_property FRC_SEPARATE_SLAVE_CLOCK HDL_PARAMETER        false

add_parameter FRC_ENABLE_DEBUG INTEGER 0
set_parameter_property FRC_ENABLE_DEBUG DISPLAY_NAME        "Debug features"
set_parameter_property FRC_ENABLE_DEBUG DISPLAY_HINT         boolean
set_parameter_property FRC_ENABLE_DEBUG HDL_PARAMETER        false

# ============================================================================
# PIP (Picture-in-Picture / Mixer) parameters
# Defaults match the configuration validated on the frame_buf_addition branch
# (2-layer mixer, uniform-color background TPG, runtime programmed).
# ============================================================================
add_parameter PIP_NUM_LAYERS INTEGER 2
set_parameter_property PIP_NUM_LAYERS DISPLAY_NAME        "Number of mixer layers"
set_parameter_property PIP_NUM_LAYERS ALLOWED_RANGES       {2 3 4}
set_parameter_property PIP_NUM_LAYERS DESCRIPTION          "Layer 0 = internal background TPG, layer 1 = pipeline video. Layers 2 and above are exported as extra AXI4-S inputs."
set_parameter_property PIP_NUM_LAYERS AFFECTS_ELABORATION  true
set_parameter_property PIP_NUM_LAYERS HDL_PARAMETER        false

add_parameter PIP_BLENDING_MODE_1 INTEGER 0
set_parameter_property PIP_BLENDING_MODE_1 DISPLAY_NAME        "Layer 1 blending mode"
set_parameter_property PIP_BLENDING_MODE_1 ALLOWED_RANGES       "0:2"
set_parameter_property PIP_BLENDING_MODE_1 HDL_PARAMETER        false

add_parameter PIP_BLENDING_MODE_2 INTEGER 0
set_parameter_property PIP_BLENDING_MODE_2 DISPLAY_NAME        "Layer 2 blending mode"
set_parameter_property PIP_BLENDING_MODE_2 ALLOWED_RANGES       "0:2"
set_parameter_property PIP_BLENDING_MODE_2 HDL_PARAMETER        false

add_parameter PIP_BLENDING_MODE_3 INTEGER 0
set_parameter_property PIP_BLENDING_MODE_3 DISPLAY_NAME        "Layer 3 blending mode"
set_parameter_property PIP_BLENDING_MODE_3 ALLOWED_RANGES       "0:2"
set_parameter_property PIP_BLENDING_MODE_3 HDL_PARAMETER        false

add_parameter PIP_RUNTIME_CONTROL INTEGER 1
set_parameter_property PIP_RUNTIME_CONTROL DISPLAY_NAME        "Memory-mapped control interface"
set_parameter_property PIP_RUNTIME_CONTROL DISPLAY_HINT         boolean
set_parameter_property PIP_RUNTIME_CONTROL AFFECTS_ELABORATION  true
set_parameter_property PIP_RUNTIME_CONTROL HDL_PARAMETER        false

add_parameter PIP_SEPARATE_SLAVE_CLOCK INTEGER 0
set_parameter_property PIP_SEPARATE_SLAVE_CLOCK DISPLAY_NAME        "Separate clock for control interface"
set_parameter_property PIP_SEPARATE_SLAVE_CLOCK DISPLAY_HINT         boolean
set_parameter_property PIP_SEPARATE_SLAVE_CLOCK HDL_PARAMETER        false

add_parameter PIP_ENABLE_DEBUG INTEGER 0
set_parameter_property PIP_ENABLE_DEBUG DISPLAY_NAME        "Debug features"
set_parameter_property PIP_ENABLE_DEBUG DISPLAY_HINT         boolean
set_parameter_property PIP_ENABLE_DEBUG HDL_PARAMETER        false

# ============================================================================
# GUI LAYOUT - tabs
# ============================================================================

# -- General tab -------------------------------------------------------------
add_display_item "" general_tab group "General"
set_display_item_property general_tab DISPLAY_HINT "tab"

add_display_item general_tab gen_mode group "Pipeline mode"
add_display_item gen_mode TOPOLOGY         parameter
add_display_item gen_mode INPUT_PROTOCOL   parameter
add_display_item gen_mode OUTPUT_PROTOCOL  parameter

add_display_item general_tab gen_feat group "Features"
add_display_item gen_feat ENABLE_FRC parameter
add_display_item gen_feat ENABLE_PIP parameter

add_display_item general_tab gen_vdf group "Video data format"
add_display_item gen_vdf BPS                     parameter
add_display_item gen_vdf NUMBER_OF_COLOR_PLANES  parameter
add_display_item gen_vdf PIXELS_IN_PARALLEL      parameter

add_display_item general_tab gen_res group "Resolution"
add_display_item gen_res SC_MAX_IN_WIDTH  parameter
add_display_item gen_res SC_MAX_OUT_WIDTH parameter
add_display_item gen_res SC_OUTPUT_HEIGHT parameter

# -- Diagram tab -------------------------------------------------------------
add_display_item "" diagram_tab group "Diagram"
set_display_item_property diagram_tab DISPLAY_HINT "tab"
add_display_item diagram_tab diagram_html TEXT \
"<html><body style='font-family:sans-serif;font-size:12px;padding:10px'>
<b>VVPS - Active pipeline per mode</b><br><br>
<table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse'>
<tr style='background:#E6F1FB'><th>Mode</th><th>Active path</th><th>MM agents</th></tr>
<tr><td><b>Full pipeline</b></td><td>Input &rarr; DIL &rarr; CRS &rarr; CSC &rarr; Clipper &rarr; PC0 &rarr; Scaler &rarr; Output</td><td>DIL, CRS, CSC, Clipper, Scaler</td></tr>
<tr><td><b>Scaler only</b></td><td>Input &rarr; Scaler &rarr; Output</td><td>Scaler</td></tr>
<tr><td><b>CSC only</b></td><td>Input &rarr; CSC &rarr; Output</td><td>CSC</td></tr>
<tr><td><b>CRS only</b></td><td>Input &rarr; CRS &rarr; Output</td><td>CRS</td></tr>
<tr><td><b>CRS + CSC</b></td><td>Input &rarr; CRS &rarr; CSC &rarr; Output</td><td>CRS, CSC</td></tr>
<tr><td><b>Clipper + Scaler</b></td><td>Input &rarr; Clipper &rarr; PC0 &rarr; Scaler &rarr; Output</td><td>Clipper, Scaler</td></tr>
<tr><td><b>Deinterlacer only</b></td><td>Input &rarr; DIL &rarr; Output</td><td>DIL</td></tr>
</table><br>
<b>MM bridge (s0) - fixed byte address map:</b><br>
DIL: 0x0000-0x01FF &nbsp;|&nbsp; CRS: 0x0200-0x03FF &nbsp;|&nbsp;
CSC: 0x0400-0x05FF &nbsp;|&nbsp; Clipper: 0x0600-0x07FF &nbsp;|&nbsp; Scaler: 0x0800-0x0BFF<br>
<b>Feature agents (only when enabled):</b><br>
FRC Lite&rarr;Full conv: 0x0C00-0x0DFF &nbsp;|&nbsp; FRC Frame Buffer: 0x0E00-0x0FFF &nbsp;|&nbsp;
PIP Mixer: 0x1000-0x13FF &nbsp;|&nbsp; PIP background TPG: 0x1400-0x15FF<br><br>
<b>Features:</b><br>
FRC (frame rate conversion): chain output &rarr; (Lite&rarr;Full conv) &rarr; Video Frame Buffer &rarr; output.
A DDR4 EMIF (IO96B) is included in the subsystem by default; its memory I/Os (mem, mem_ck, mem_reset_n, oct, ref_clk)
are exported - connect the DDR4 device or simulation memory model to them at system level.
Alternatively disable 'Include DDR4 EMIF' to export the frame buffer's raw Avalon-MM read/write hosts instead.<br>
PIP (picture-in-picture): background TPG (layer 0) + pipeline video (layer 1) &rarr; Mixer &rarr; output.
FRC and PIP combine: video path becomes &hellip; &rarr; Frame Buffer &rarr; Mixer &rarr; output.<br><br>
<i>Note: TPG and PC1 (input source adapters) are external - configured outside this subsystem.</i>
</body></html>"

# -- DIL tab -----------------------------------------------------------------
add_display_item "" dil_tab group "Deinterlacer (DIL)"
set_display_item_property dil_tab DISPLAY_HINT "tab"

add_display_item dil_tab dil_vdf group "Video data format"
add_display_item dil_vdf DIL_EXTERNAL_MODE        parameter
add_display_item dil_vdf DIL_MAX_WIDTH            parameter

add_display_item dil_tab dil_params group "Deinterlacing"
add_display_item dil_params DIL_MODE              parameter
add_display_item dil_params DIL_BOB_MODE          parameter

add_display_item dil_tab dil_mem group "Memory - Weave and Motion adaptive only"
add_display_item dil_mem DIL_AV_MM_DATA_WIDTH     parameter
add_display_item dil_mem DIL_AV_MM_ADDR_WIDTH     parameter
add_display_item dil_mem DIL_WRITE_FIFO_DEPTH     parameter
add_display_item dil_mem DIL_WRITE_BURST_TARGET   parameter
add_display_item dil_mem DIL_READ_FIFO_DEPTH      parameter
add_display_item dil_mem DIL_READ_BURST_TARGET    parameter
add_display_item dil_mem DIL_MEM_BUFF_BASE_ADDR   parameter
add_display_item dil_mem DIL_MEM_BUFF_LINE_STRIDE parameter
add_display_item dil_mem DIL_PACKING              parameter
add_display_item dil_mem DIL_CLOCKS_ARE_SEPARATE  parameter

add_display_item dil_tab dil_ctrl group "Control"
add_display_item dil_ctrl DIL_RUNTIME_CONTROL      parameter
add_display_item dil_ctrl DIL_SEPARATE_SLAVE_CLOCK parameter
add_display_item dil_ctrl DIL_ENABLE_DEBUG         parameter
add_display_item dil_ctrl DIL_PIPELINE_READY       parameter

# -- CRS tab -----------------------------------------------------------------
add_display_item "" crs_tab group "Chroma resampler (CRS)"
set_display_item_property crs_tab DISPLAY_HINT "tab"

add_display_item crs_tab crs_vdf group "Video data format"
add_display_item crs_vdf CRS_EXTERNAL_MODE        parameter
add_display_item crs_vdf CRS_MAX_WIDTH            parameter
add_display_item crs_vdf CRS_NO_BLANKING          parameter

add_display_item crs_tab crs_samp group "Chroma sampling support"
add_display_item crs_samp CRS_SUPPORT_420_PASS    parameter
add_display_item crs_samp CRS_SUPPORT_420_TO_422  parameter
add_display_item crs_samp CRS_SUPPORT_420_TO_444  parameter
add_display_item crs_samp CRS_SUPPORT_422_PASS    parameter
add_display_item crs_samp CRS_SUPPORT_422_TO_420  parameter
add_display_item crs_samp CRS_SUPPORT_422_TO_444  parameter
add_display_item crs_samp CRS_SUPPORT_444_PASS    parameter
add_display_item crs_samp CRS_SUPPORT_444_TO_420  parameter
add_display_item crs_samp CRS_SUPPORT_444_TO_422  parameter

add_display_item crs_tab crs_horiz group "Horizontal resampling settings"
add_display_item crs_horiz CRS_HORIZ_ALGORITHM         parameter
add_display_item crs_horiz CRS_HORIZ_CO_SITING         parameter
add_display_item crs_horiz CRS_HORIZ_ENABLE_LUMA_ADAPT parameter

add_display_item crs_tab crs_vert group "Vertical resampling settings"
add_display_item crs_vert CRS_VERT_ALGORITHM            parameter
add_display_item crs_vert CRS_VERT_CO_SITING            parameter
add_display_item crs_vert CRS_VERT_ENABLE_LUMA_ADAPT    parameter

add_display_item crs_tab crs_ctrl group "Control settings"
add_display_item crs_ctrl CRS_RUNTIME_CONTROL       parameter
add_display_item crs_ctrl CRS_PIPELINE_READY        parameter
add_display_item crs_ctrl CRS_SEPARATE_SLAVE_CLOCK  parameter
add_display_item crs_ctrl CRS_ENABLE_DEBUG          parameter

# -- CSC tab -----------------------------------------------------------------
add_display_item "" csc_tab group "Color space conv. (CSC)"
set_display_item_property csc_tab DISPLAY_HINT "tab"

add_display_item csc_tab csc_vdf group "Video data format"
add_display_item csc_vdf CSC_EXTERNAL_MODE       parameter
add_display_item csc_vdf CSC_BPS_IN              parameter
add_display_item csc_vdf CSC_BPS_OUT             parameter
add_display_item csc_vdf CSC_COLOR_SPACE_OUT     parameter

add_display_item csc_tab csc_prec group "Operands - precision"
add_display_item csc_prec CSC_COEFF_FRAC_BITS    parameter
add_display_item csc_prec CSC_COEFF_SIGNED       parameter
add_display_item csc_prec CSC_COEFF_INT_BITS     parameter
add_display_item csc_prec CSC_SUMMAND_SIGNED     parameter
add_display_item csc_prec CSC_SUMMAND_INT_BITS   parameter
add_display_item csc_prec CSC_BIN_PT_SHIFT       parameter
add_display_item csc_prec CSC_ROUNDING           parameter

add_display_item csc_tab csc_coeff group "Coefficients and summand"
add_display_item csc_coeff CSC_C00  parameter
add_display_item csc_coeff CSC_C01  parameter
add_display_item csc_coeff CSC_C02  parameter
add_display_item csc_coeff CSC_S0   parameter
add_display_item csc_coeff CSC_C10  parameter
add_display_item csc_coeff CSC_C11  parameter
add_display_item csc_coeff CSC_C12  parameter
add_display_item csc_coeff CSC_S1   parameter
add_display_item csc_coeff CSC_C20  parameter
add_display_item csc_coeff CSC_C21  parameter
add_display_item csc_coeff CSC_C22  parameter
add_display_item csc_coeff CSC_S2   parameter

add_display_item csc_tab csc_ctrl group "Control"
add_display_item csc_ctrl CSC_RUNTIME_CONTROL      parameter
add_display_item csc_ctrl CSC_SEPARATE_SLAVE_CLOCK parameter
add_display_item csc_ctrl CSC_ENABLE_DEBUG         parameter
add_display_item csc_ctrl CSC_PIPELINE_READY       parameter

# -- Clipper tab -------------------------------------------------------------
add_display_item "" clip_tab group "Clipper"
set_display_item_property clip_tab DISPLAY_HINT "tab"

add_display_item clip_tab cl_clip group "Clipping"
add_display_item cl_clip CL_CLIPPING_METHOD    parameter
add_display_item cl_clip CL_LEFT_OFFSET        parameter
add_display_item cl_clip CL_TOP_OFFSET         parameter
add_display_item cl_clip CL_RIGHT_OFFSET       parameter
add_display_item cl_clip CL_BOTTOM_OFFSET      parameter
add_display_item cl_clip CL_OUTPUT_WIDTH       parameter
add_display_item cl_clip CL_OUTPUT_HEIGHT      parameter

add_display_item clip_tab cl_ctrl group "Control"
add_display_item cl_ctrl CL_EXTERNAL_MODE        parameter
add_display_item cl_ctrl CL_RUNTIME_CONTROL      parameter
add_display_item cl_ctrl CL_SEPARATE_SLAVE_CLOCK parameter
add_display_item cl_ctrl CL_ENABLE_DEBUG         parameter
add_display_item cl_ctrl CL_PIPELINE_READY       parameter

# -- PC0 tab -----------------------------------------------------------------
add_display_item "" pc0_tab group "Protocol conv. (PC0)"
set_display_item_property pc0_tab DISPLAY_HINT "tab"

add_display_item pc0_tab pc0_vdf group "Video data format"
add_display_item pc0_vdf PC0_ENABLE_YCBCR_SWAP  parameter

add_display_item pc0_tab pc0_proto group "Interface protocols"
add_display_item pc0_proto OUTPUT_PROTOCOL        parameter
add_display_item pc0_proto PC0_VVP_USER_SUPPORT   parameter
add_display_item pc0_proto PC0_VIP_USER_SUPPORT   parameter
add_display_item pc0_proto PC0_COLOR_SPACE        parameter
add_display_item pc0_proto PC0_CHROMA_SAMPLING    parameter
add_display_item pc0_proto PC0_CHROMA_SITING      parameter
add_display_item pc0_proto PC0_CLIP_LONG_FIELDS   parameter
add_display_item pc0_proto PC0_ENABLE_TIMEOUT     parameter
add_display_item pc0_proto PC0_ENABLE_LOW_LATENCY parameter

add_display_item pc0_tab pc0_ctrl group "Control"
add_display_item pc0_ctrl PC0_RUNTIME_CONTROL      parameter
add_display_item pc0_ctrl PC0_SEPARATE_SLAVE_CLOCK parameter
add_display_item pc0_ctrl PC0_ENABLE_DEBUG         parameter
add_display_item pc0_ctrl PC0_PIPELINE_READY       parameter

# -- Scaler tab --------------------------------------------------------------
add_display_item "" scl_tab group "Scaler"
set_display_item_property scl_tab DISPLAY_HINT "tab"

add_display_item scl_tab sc_vdf group "Video data format"
add_display_item sc_vdf SC_EXTERNAL_MODE    parameter
add_display_item sc_vdf SC_ENABLE_444       parameter
add_display_item sc_vdf SC_ENABLE_422       parameter
add_display_item sc_vdf SC_ENABLE_420       parameter
add_display_item sc_vdf SC_NO_BLANKING      parameter

add_display_item scl_tab sc_ctrl group "Control"
add_display_item sc_ctrl SC_RUNTIME_CONTROL      parameter
add_display_item sc_ctrl SC_SEPARATE_SLAVE_CLOCK parameter
add_display_item sc_ctrl SC_ENABLE_DEBUG         parameter
add_display_item sc_ctrl SC_PIPELINE_READY       parameter

add_display_item scl_tab sc_algo group "Scaling algorithm"
add_display_item sc_algo SC_ALGORITHM       parameter
add_display_item sc_algo SC_EDGE_MIRROR     parameter
add_display_item sc_algo SC_RUNTIME_LOAD    parameter
add_display_item sc_algo SC_MEM_INIT        parameter

add_display_item scl_tab sc_vscl group "Vertical scaling"
add_display_item sc_vscl SC_ENABLE_V          parameter
add_display_item sc_vscl SC_V_PARTIAL_SCALING parameter
add_display_item sc_vscl SC_ENABLE_420_MIRROR parameter
add_display_item sc_vscl SC_V_TAPS            parameter
add_display_item sc_vscl SC_V_PHASES          parameter
add_display_item sc_vscl SC_V_BANKS           parameter
add_display_item sc_vscl SC_V_COEFF_SIGNED    parameter
add_display_item sc_vscl SC_V_COEFF_INT_BITS  parameter
add_display_item sc_vscl SC_V_COEFF_FRAC_BITS parameter
add_display_item sc_vscl SC_V_PRES_FRAC_BITS  parameter
add_display_item sc_vscl SC_V_COEFF_FUNCTION  parameter
add_display_item sc_vscl SC_V_INIT_FILE       parameter

add_display_item scl_tab sc_hscl group "Horizontal scaling"
add_display_item sc_hscl SC_ENABLE_H          parameter
add_display_item sc_hscl SC_H_PARTIAL_SCALING parameter
add_display_item sc_hscl SC_HALF_RATE_420     parameter
add_display_item sc_hscl SC_H_TAPS            parameter
add_display_item sc_hscl SC_H_PHASES          parameter
add_display_item sc_hscl SC_H_BANKS           parameter
add_display_item sc_hscl SC_H_COEFF_SIGNED    parameter
add_display_item sc_hscl SC_H_COEFF_INT_BITS  parameter
add_display_item sc_hscl SC_H_COEFF_FRAC_BITS parameter
add_display_item sc_hscl SC_H_COEFF_FUNCTION  parameter
add_display_item sc_hscl SC_H_INIT_FILE       parameter

# -- Frame Rate Conversion tab ------------------------------------------------
add_display_item "" frc_tab group "Frame rate conv. (FRC)"
set_display_item_property frc_tab DISPLAY_HINT "tab"

add_display_item frc_tab frc_frames group "Frame buffering"
add_display_item frc_frames FRC_MAX_WIDTH           parameter
add_display_item frc_frames FRC_MAX_HEIGHT          parameter
add_display_item frc_frames FRC_FRAME_DROP_ENABLE   parameter
add_display_item frc_frames FRC_FRAME_REPEAT_ENABLE parameter
add_display_item frc_frames FRC_DROP_BROKEN_FRAMES  parameter
add_display_item frc_frames FRC_DROP_RPT_AUX        parameter
add_display_item frc_frames FRC_MAX_CONTROL_PACKETS parameter

add_display_item frc_tab frc_mem group "Memory interface"
add_display_item frc_mem FRC_INCLUDE_EMIF         parameter
add_display_item frc_mem FRC_AV_MM_DATA_WIDTH     parameter
add_display_item frc_mem FRC_AV_MM_ADDR_WIDTH     parameter
add_display_item frc_mem FRC_WRITE_FIFO_DEPTH     parameter
add_display_item frc_mem FRC_WRITE_BURST_TARGET   parameter
add_display_item frc_mem FRC_READ_FIFO_DEPTH      parameter
add_display_item frc_mem FRC_READ_BURST_TARGET    parameter
add_display_item frc_mem FRC_PACKING              parameter
add_display_item frc_mem FRC_CLOCKS_ARE_SEPARATE  parameter
add_display_item frc_mem FRC_MEM_BUFF_BASE_ADDR   parameter
add_display_item frc_mem FRC_MEM_BUFF_LINE_STRIDE parameter

add_display_item frc_tab frc_ctrl group "Control"
add_display_item frc_ctrl FRC_RUNTIME_CONTROL      parameter
add_display_item frc_ctrl FRC_SEPARATE_SLAVE_CLOCK parameter
add_display_item frc_ctrl FRC_ENABLE_DEBUG         parameter

# -- PIP / Mixer tab -----------------------------------------------------------
add_display_item "" pip_tab group "PIP / Mixer"
set_display_item_property pip_tab DISPLAY_HINT "tab"

add_display_item pip_tab pip_layers group "Layers"
add_display_item pip_layers PIP_NUM_LAYERS      parameter
add_display_item pip_layers PIP_BLENDING_MODE_1 parameter
add_display_item pip_layers PIP_BLENDING_MODE_2 parameter
add_display_item pip_layers PIP_BLENDING_MODE_3 parameter

add_display_item pip_tab pip_ctrl group "Control"
add_display_item pip_ctrl PIP_RUNTIME_CONTROL      parameter
add_display_item pip_ctrl PIP_SEPARATE_SLAVE_CLOCK parameter
add_display_item pip_ctrl PIP_ENABLE_DEBUG         parameter

# ============================================================================
# VALIDATE - enforce parameter dependencies
# ============================================================================
proc validate {} {
    set dil_mode [get_parameter_value DIL_MODE]

    # DIL memory params only relevant for Weave/Motion Adaptive
    set mem_needed [expr {$dil_mode ne "BOB"}]
    set_parameter_property DIL_AV_MM_DATA_WIDTH   ENABLED $mem_needed
    set_parameter_property DIL_AV_MM_ADDR_WIDTH   ENABLED $mem_needed
    set_parameter_property DIL_WRITE_FIFO_DEPTH   ENABLED $mem_needed
    set_parameter_property DIL_WRITE_BURST_TARGET  ENABLED $mem_needed
    set_parameter_property DIL_READ_FIFO_DEPTH    ENABLED $mem_needed
    set_parameter_property DIL_READ_BURST_TARGET  ENABLED $mem_needed
    set_parameter_property DIL_MEM_BUFF_BASE_ADDR  ENABLED $mem_needed
    set_parameter_property DIL_MEM_BUFF_LINE_STRIDE ENABLED $mem_needed
    set_parameter_property DIL_PACKING            ENABLED $mem_needed
    set_parameter_property DIL_CLOCKS_ARE_SEPARATE ENABLED $mem_needed

    # Bob mode param only for Bob
    set_parameter_property DIL_BOB_MODE ENABLED [expr {$dil_mode eq "BOB"}]

    # CRS luma adapt only when Filtered
    set_parameter_property CRS_HORIZ_ENABLE_LUMA_ADAPT ENABLED \
        [expr {[get_parameter_value CRS_HORIZ_ALGORITHM] eq "FILTERED"}]
    set_parameter_property CRS_VERT_ENABLE_LUMA_ADAPT ENABLED \
        [expr {[get_parameter_value CRS_VERT_ALGORITHM] eq "FILTERED"}]

    # Scaler algorithm-dependent params
    set is_poly          [expr {[get_parameter_value SC_ALGORITHM] eq "POLYPHASE"}]
    set is_poly_or_bilin [expr {[get_parameter_value SC_ALGORITHM] ne "NEAREST_NEIGHBOUR"}]

    # Polyphase-only
    set_parameter_property SC_EDGE_MIRROR       ENABLED $is_poly
    set_parameter_property SC_RUNTIME_LOAD      ENABLED $is_poly
    set_parameter_property SC_MEM_INIT          ENABLED $is_poly
    set_parameter_property SC_V_TAPS            ENABLED $is_poly
    set_parameter_property SC_V_PHASES          ENABLED $is_poly
    set_parameter_property SC_V_BANKS           ENABLED $is_poly
    set_parameter_property SC_V_COEFF_SIGNED    ENABLED $is_poly
    set_parameter_property SC_V_COEFF_INT_BITS  ENABLED $is_poly
    set_parameter_property SC_V_COEFF_FUNCTION  ENABLED $is_poly
    set_parameter_property SC_H_TAPS            ENABLED $is_poly
    set_parameter_property SC_H_PHASES          ENABLED $is_poly
    set_parameter_property SC_H_BANKS           ENABLED $is_poly
    set_parameter_property SC_H_COEFF_SIGNED    ENABLED $is_poly
    set_parameter_property SC_H_COEFF_INT_BITS  ENABLED $is_poly
    set_parameter_property SC_H_COEFF_FUNCTION  ENABLED $is_poly

    # Bilinear AND polyphase
    set_parameter_property SC_V_COEFF_FRAC_BITS ENABLED $is_poly_or_bilin
    set_parameter_property SC_V_PRES_FRAC_BITS  ENABLED $is_poly_or_bilin
    set_parameter_property SC_H_COEFF_FRAC_BITS ENABLED $is_poly_or_bilin

    # Scaler 420-only params
    set has_420 [get_parameter_value SC_ENABLE_420]
    set_parameter_property SC_ENABLE_420_MIRROR ENABLED $has_420
    set_parameter_property SC_HALF_RATE_420     ENABLED $has_420

    # At least one chroma mode must be enabled
    set has_444 [get_parameter_value SC_ENABLE_444]
    set has_422 [get_parameter_value SC_ENABLE_422]
    if {!$has_444 && !$has_422 && !$has_420} {
        send_message error "Scaler: at least one chroma sampling mode (444, 422, or 420) must be enabled."
    }


    # Clipper offset vs rectangle params
    set is_rect [expr {[get_parameter_value CL_CLIPPING_METHOD] eq "RECTANGLE"}]
    set_parameter_property CL_RIGHT_OFFSET  ENABLED [expr {!$is_rect}]
    set_parameter_property CL_BOTTOM_OFFSET ENABLED [expr {!$is_rect}]
    set_parameter_property CL_OUTPUT_WIDTH  ENABLED $is_rect
    set_parameter_property CL_OUTPUT_HEIGHT ENABLED $is_rect

    # FRC params only relevant when the feature is on
    set frc_on [get_parameter_value ENABLE_FRC]
    foreach p {FRC_MAX_WIDTH FRC_MAX_HEIGHT FRC_FRAME_DROP_ENABLE
               FRC_FRAME_REPEAT_ENABLE FRC_DROP_BROKEN_FRAMES FRC_DROP_RPT_AUX
               FRC_MAX_CONTROL_PACKETS FRC_INCLUDE_EMIF
               FRC_AV_MM_DATA_WIDTH FRC_AV_MM_ADDR_WIDTH
               FRC_WRITE_FIFO_DEPTH FRC_WRITE_BURST_TARGET FRC_READ_FIFO_DEPTH
               FRC_READ_BURST_TARGET FRC_PACKING FRC_CLOCKS_ARE_SEPARATE
               FRC_MEM_BUFF_BASE_ADDR FRC_MEM_BUFF_LINE_STRIDE
               FRC_RUNTIME_CONTROL FRC_SEPARATE_SLAVE_CLOCK FRC_ENABLE_DEBUG} {
        set_parameter_property $p ENABLED $frc_on
    }
    if {$frc_on && ![get_parameter_value FRC_RUNTIME_CONTROL]} {
        send_message warning "FRC: the frame buffer output is started by a runtime register write (OUTPUT_CONTROL.GO). Without the memory-mapped control interface no frames will be produced."
    }

    # PIP params only relevant when the feature is on
    set pip_on [get_parameter_value ENABLE_PIP]
    set pip_layers [get_parameter_value PIP_NUM_LAYERS]
    foreach p {PIP_NUM_LAYERS PIP_BLENDING_MODE_1 PIP_RUNTIME_CONTROL
               PIP_SEPARATE_SLAVE_CLOCK PIP_ENABLE_DEBUG} {
        set_parameter_property $p ENABLED $pip_on
    }
    set_parameter_property PIP_BLENDING_MODE_2 ENABLED [expr {$pip_on && $pip_layers >= 3}]
    set_parameter_property PIP_BLENDING_MODE_3 ENABLED [expr {$pip_on && $pip_layers >= 4}]
}

# ============================================================================
# INSTANTIATE - called when IP is first dropped into the system
# ============================================================================
proc instantiate {name} {
}

# ============================================================================
# COMPOSE - builds the internal Qsys subsystem
# ============================================================================
proc compose {} {
    set topo [get_parameter_value TOPOLOGY]
    set bps  [get_parameter_value BPS]
    set npl  [get_parameter_value NUMBER_OF_COLOR_PLANES]
    set pip  [get_parameter_value PIXELS_IN_PARALLEL]
    set in_proto  [get_parameter_value INPUT_PROTOCOL]
    set out_proto [get_parameter_value OUTPUT_PROTOCOL]

    # -- Determine active IPs per mode ---------------------------------------
    switch $topo {
        FULL        { set do_dil 1; set do_crs 1; set do_csc 1; set do_clip 1; set do_pc0 1; set do_scl 1 }
        SCALER_ONLY { set do_dil 0; set do_crs 0; set do_csc 0; set do_clip 0; set do_pc0 0; set do_scl 1 }
        CSC_ONLY    { set do_dil 0; set do_crs 0; set do_csc 1; set do_clip 0; set do_pc0 0; set do_scl 0 }
        CRS_ONLY    { set do_dil 0; set do_crs 1; set do_csc 0; set do_clip 0; set do_pc0 0; set do_scl 0 }
        CRS_CSC     { set do_dil 0; set do_crs 1; set do_csc 1; set do_clip 0; set do_pc0 0; set do_scl 0 }
        CLIP_SCL    { set do_dil 0; set do_crs 0; set do_csc 0; set do_clip 1; set do_pc0 1; set do_scl 1 }
        DIL_ONLY    { set do_dil 1; set do_crs 0; set do_csc 0; set do_clip 0; set do_pc0 0; set do_scl 0 }
        default     { set do_dil 0; set do_crs 0; set do_csc 0; set do_clip 0; set do_pc0 0; set do_scl 0 }
    }

    # -- Optional features (combinable with any mode) ------------------------
    set do_frc [get_parameter_value ENABLE_FRC]
    set do_pip [get_parameter_value ENABLE_PIP]

    # When CRS or CSC are in the chain the internal pipeline runs at 3 planes
    # (444).  DIL and CRS input see $npl; Clipper and beyond see $internal_npl.
    set internal_npl [expr {($do_crs || $do_csc) ? 3 : $npl}]

    # -- Determine if MM bridge needed ---------------------------------------
    # FRC and PIP always bring the bridge: the frame buffer is started and the
    # lite->full converter / background TPG are programmed at runtime.
    set need_mm [expr {
        ($do_dil  && [get_parameter_value DIL_RUNTIME_CONTROL])  ||
        ($do_crs  && [get_parameter_value CRS_RUNTIME_CONTROL])  ||
        ($do_csc  && [get_parameter_value CSC_RUNTIME_CONTROL])  ||
        ($do_clip && [get_parameter_value CL_RUNTIME_CONTROL])   ||
        ($do_scl  && [get_parameter_value SC_RUNTIME_CONTROL])   ||
        $do_frc || $do_pip
    }]

    # -- Infrastructure ------------------------------------------------------
    add_instance clock_in altera_clock_bridge 19.2.0
    set_instance_parameter_value clock_in NUM_CLOCK_OUTPUTS   1
    set_instance_parameter_value clock_in EXPLICIT_CLOCK_RATE 150000000

    add_instance reset_in altera_reset_bridge 19.2.0
    set_instance_parameter_value reset_in NUM_RESET_OUTPUTS 1
    set_instance_parameter_value reset_in ACTIVE_LOW_RESET  0
    set_instance_parameter_value reset_in SYNCHRONOUS_EDGES deassert
    set_instance_parameter_value reset_in USE_RESET_REQUEST 0
    set_instance_parameter_value reset_in SYNC_RESET        0
    add_connection clock_in.out_clk reset_in.clk

    # -- MM bridge -----------------------------------------------------------
    # 12-bit byte addressed (4KB) covers the 5 core IPs x 512B.
    # With FRC/PIP the map extends to 0x15FF, so grow to 13-bit (8KB).
    if {$need_mm} {
        add_instance mm_bridge_0 altera_avalon_mm_bridge 20.1.0
        set_instance_parameter_value mm_bridge_0 DATA_WIDTH            32
        set_instance_parameter_value mm_bridge_0 ADDRESS_WIDTH         [expr {($do_frc || $do_pip) ? 13 : 12}]
        set_instance_parameter_value mm_bridge_0 ADDRESS_UNITS         SYMBOLS
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

    # -- Helper: connect IP to MM bridge at given byte base address ----------
    proc mm_connect {ip_inst ip_port base} {
        add_connection mm_bridge_0.m0 ${ip_inst}.${ip_port}
        set_connection_parameter_value \
            mm_bridge_0.m0/${ip_inst}.${ip_port} baseAddress $base
    }

    # -- DIL -----------------------------------------------------------------
    if {$do_dil} {
        add_instance intel_vvp_dil_0 intel_vvp_dil 24.5.1
        set_instance_parameter_value intel_vvp_dil_0 EXTERNAL_MODE          [get_parameter_value DIL_EXTERNAL_MODE]
        set_instance_parameter_value intel_vvp_dil_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_dil_0 NUMBER_OF_COLOR_PLANES $internal_npl
        set_instance_parameter_value intel_vvp_dil_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_dil_0 MAX_WIDTH              [get_parameter_value DIL_MAX_WIDTH]
        set_instance_parameter_value intel_vvp_dil_0 DIL_MODE               [get_parameter_value DIL_MODE]
        set_instance_parameter_value intel_vvp_dil_0 BOB_DIL_MODE           [get_parameter_value DIL_BOB_MODE]
        set_instance_parameter_value intel_vvp_dil_0 RUNTIME_CONTROL        [get_parameter_value DIL_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_dil_0 SEPARATE_SLAVE_CLOCK   [get_parameter_value DIL_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_dil_0 ENABLE_DEBUG           [get_parameter_value DIL_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_dil_0 PIPELINE_READY         [get_parameter_value DIL_PIPELINE_READY]
        set_instance_parameter_value intel_vvp_dil_0 MEM_BUFF_BASE_ADDR     [get_parameter_value DIL_MEM_BUFF_BASE_ADDR]
        set_instance_parameter_value intel_vvp_dil_0 MEM_BUFF_LINE_STRIDE   [get_parameter_value DIL_MEM_BUFF_LINE_STRIDE]
        set_instance_parameter_value intel_vvp_dil_0 WRITE_FIFO_DEPTH       [get_parameter_value DIL_WRITE_FIFO_DEPTH]
        set_instance_parameter_value intel_vvp_dil_0 WRITE_BURST_TARGET     [get_parameter_value DIL_WRITE_BURST_TARGET]
        set_instance_parameter_value intel_vvp_dil_0 READ_FIFO_DEPTH        [get_parameter_value DIL_READ_FIFO_DEPTH]
        set_instance_parameter_value intel_vvp_dil_0 READ_BURST_TARGET      [get_parameter_value DIL_READ_BURST_TARGET]
        set_instance_parameter_value intel_vvp_dil_0 P_AV_MM_DATA_WIDTH     [get_parameter_value DIL_AV_MM_DATA_WIDTH]
        set_instance_parameter_value intel_vvp_dil_0 P_AV_MM_ADDR_WIDTH     [get_parameter_value DIL_AV_MM_ADDR_WIDTH]
        set_instance_parameter_value intel_vvp_dil_0 PACKING                [get_parameter_value DIL_PACKING]
        set_instance_parameter_value intel_vvp_dil_0 CLOCKS_ARE_SEPARATE    [get_parameter_value DIL_CLOCKS_ARE_SEPARATE]
        add_connection clock_in.out_clk   intel_vvp_dil_0.main_clock
        add_connection reset_in.out_reset intel_vvp_dil_0.main_reset
        if {$need_mm && [get_parameter_value DIL_RUNTIME_CONTROL]} {
            mm_connect intel_vvp_dil_0 av_mm_control_agent 0x0000
        }
    }

    # -- CRS -----------------------------------------------------------------
    if {$do_crs} {
        add_instance intel_vvp_crs_0 intel_vvp_crs 24.5.1
        set_instance_parameter_value intel_vvp_crs_0 EXTERNAL_MODE            [get_parameter_value CRS_EXTERNAL_MODE]
        set_instance_parameter_value intel_vvp_crs_0 BPS                      $bps
        set_instance_parameter_value intel_vvp_crs_0 PIXELS_IN_PARALLEL_IN    $pip
        set_instance_parameter_value intel_vvp_crs_0 PIXELS_IN_PARALLEL_OUT   $pip
        set_instance_parameter_value intel_vvp_crs_0 MAX_WIDTH                [get_parameter_value CRS_MAX_WIDTH]
        set_instance_parameter_value intel_vvp_crs_0 NO_BLANKING              [get_parameter_value CRS_NO_BLANKING]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_PASS         [get_parameter_value CRS_SUPPORT_420_PASS]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_TO_422       [get_parameter_value CRS_SUPPORT_420_TO_422]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_420_TO_444       [get_parameter_value CRS_SUPPORT_420_TO_444]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_PASS         [get_parameter_value CRS_SUPPORT_422_PASS]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_TO_420       [get_parameter_value CRS_SUPPORT_422_TO_420]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_422_TO_444       [get_parameter_value CRS_SUPPORT_422_TO_444]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_PASS         [get_parameter_value CRS_SUPPORT_444_PASS]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_TO_420       [get_parameter_value CRS_SUPPORT_444_TO_420]
        set_instance_parameter_value intel_vvp_crs_0 SUPPORT_444_TO_422       [get_parameter_value CRS_SUPPORT_444_TO_422]
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_ALGORITHM          [get_parameter_value CRS_HORIZ_ALGORITHM]
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_CO_SITING          [get_parameter_value CRS_HORIZ_CO_SITING]
        set_instance_parameter_value intel_vvp_crs_0 HORIZ_ENABLE_LUMA_ADAPT  [get_parameter_value CRS_HORIZ_ENABLE_LUMA_ADAPT]
        set_instance_parameter_value intel_vvp_crs_0 VERT_ALGORITHM           [get_parameter_value CRS_VERT_ALGORITHM]
        set_instance_parameter_value intel_vvp_crs_0 VERT_CO_SITING           [get_parameter_value CRS_VERT_CO_SITING]
        set_instance_parameter_value intel_vvp_crs_0 VERT_ENABLE_LUMA_ADAPT   [get_parameter_value CRS_VERT_ENABLE_LUMA_ADAPT]
        set_instance_parameter_value intel_vvp_crs_0 RUNTIME_CONTROL          [get_parameter_value CRS_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_crs_0 SEPARATE_SLAVE_CLOCK     [get_parameter_value CRS_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_crs_0 ENABLE_DEBUG             [get_parameter_value CRS_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_crs_0 PIPELINE_READY           [get_parameter_value CRS_PIPELINE_READY]
        add_connection clock_in.out_clk   intel_vvp_crs_0.main_clock
        add_connection reset_in.out_reset intel_vvp_crs_0.main_reset
        if {$need_mm && [get_parameter_value CRS_RUNTIME_CONTROL]} {
            mm_connect intel_vvp_crs_0 av_mm_control_agent 0x0200
        }
    }

    # -- CSC -----------------------------------------------------------------
    if {$do_csc} {
        add_instance intel_vvp_csc_0 intel_vvp_csc 24.5.1
        set_instance_parameter_value intel_vvp_csc_0 EXTERNAL_MODE              [get_parameter_value CSC_EXTERNAL_MODE]
        set_instance_parameter_value intel_vvp_csc_0 BPS_IN                     [get_parameter_value CSC_BPS_IN]
        set_instance_parameter_value intel_vvp_csc_0 BPS_OUT                    [get_parameter_value CSC_BPS_OUT]
        set_instance_parameter_value intel_vvp_csc_0 PIXELS_IN_PARALLEL         $pip
        set_instance_parameter_value intel_vvp_csc_0 OUTPUT_COLORSPACE          0
        set_instance_parameter_value intel_vvp_csc_0 COEF_SUM_FRACTION_BITS     [get_parameter_value CSC_COEFF_FRAC_BITS]
        set_instance_parameter_value intel_vvp_csc_0 COEFFICIENT_SIGNED         [get_parameter_value CSC_COEFF_SIGNED]
        set_instance_parameter_value intel_vvp_csc_0 COEFFICIENT_INT_BITS       [get_parameter_value CSC_COEFF_INT_BITS]
        set_instance_parameter_value intel_vvp_csc_0 SUMMAND_SIGNED             [get_parameter_value CSC_SUMMAND_SIGNED]
        set_instance_parameter_value intel_vvp_csc_0 SUMMAND_INT_BITS           [get_parameter_value CSC_SUMMAND_INT_BITS]
        set_instance_parameter_value intel_vvp_csc_0 MOVE_BINARY_POINT_RIGHT    [get_parameter_value CSC_BIN_PT_SHIFT]
        set_instance_parameter_value intel_vvp_csc_0 REMOVE_FRACTION_METHOD     1
        set_instance_parameter_value intel_vvp_csc_0 RUNTIME_CONTROL            [get_parameter_value CSC_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_csc_0 SEPARATE_SLAVE_CLOCK       [get_parameter_value CSC_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_csc_0 ENABLE_DEBUG               [get_parameter_value CSC_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_csc_0 PIPELINE_READY             [get_parameter_value CSC_PIPELINE_READY]
        add_connection clock_in.out_clk   intel_vvp_csc_0.main_clock
        add_connection reset_in.out_reset intel_vvp_csc_0.main_reset
        if {$need_mm && [get_parameter_value CSC_RUNTIME_CONTROL]} {
            mm_connect intel_vvp_csc_0 av_mm_control_agent 0x0400
        }
    }

    # -- CLIPPER -------------------------------------------------------------
    if {$do_clip} {
        add_instance intel_vvp_clipper_0 intel_vvp_clipper 24.5.1
        set_instance_parameter_value intel_vvp_clipper_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_clipper_0 NUMBER_OF_COLOR_PLANES $internal_npl
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
        set_instance_parameter_value intel_vvp_clipper_0 RECTANGLE_WIDTH        [get_parameter_value CL_OUTPUT_WIDTH]
        set_instance_parameter_value intel_vvp_clipper_0 RECTANGLE_HEIGHT       [get_parameter_value CL_OUTPUT_HEIGHT]
        add_connection clock_in.out_clk   intel_vvp_clipper_0.main_clock
        add_connection reset_in.out_reset intel_vvp_clipper_0.main_reset
        if {$need_mm && [get_parameter_value CL_RUNTIME_CONTROL]} {
            mm_connect intel_vvp_clipper_0 av_mm_control_agent 0x0600
        }
    }

    # -- PC0 -----------------------------------------------------------------
    if {$do_pc0} {
        add_instance intel_vvp_protocol_conv_0 intel_vvp_protocol_conv 24.6.0
        set_instance_parameter_value intel_vvp_protocol_conv_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_protocol_conv_0 NUMBER_OF_COLOR_PLANES $internal_npl
        set_instance_parameter_value intel_vvp_protocol_conv_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_protocol_conv_0 INPUT_MODE             "INTERNAL"
        set_instance_parameter_value intel_vvp_protocol_conv_0 OUTPUT_MODE            "EXTERNAL"
        set_instance_parameter_value intel_vvp_protocol_conv_0 RUNTIME_CONTROL        [get_parameter_value PC0_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_protocol_conv_0 SEPARATE_SLAVE_CLOCK   [get_parameter_value PC0_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_protocol_conv_0 ENABLE_DEBUG           [get_parameter_value PC0_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_protocol_conv_0 PIPELINE_READY         [get_parameter_value PC0_PIPELINE_READY]
        set_instance_parameter_value intel_vvp_protocol_conv_0 ENABLE_YCBCR_SWAP      [get_parameter_value PC0_ENABLE_YCBCR_SWAP]
        set_instance_parameter_value intel_vvp_protocol_conv_0 VVP_USER_SUPPORT       [get_parameter_value PC0_VVP_USER_SUPPORT]
        set_instance_parameter_value intel_vvp_protocol_conv_0 VIP_USER_SUPPORT       [get_parameter_value PC0_VIP_USER_SUPPORT]
        set_instance_parameter_value intel_vvp_protocol_conv_0 COLOR_SPACE            [get_parameter_value PC0_COLOR_SPACE]
        set_instance_parameter_value intel_vvp_protocol_conv_0 CHROMA_SAMPLING        [get_parameter_value PC0_CHROMA_SAMPLING]
        set_instance_parameter_value intel_vvp_protocol_conv_0 CHROMA_SITING          [get_parameter_value PC0_CHROMA_SITING]
        set_instance_parameter_value intel_vvp_protocol_conv_0 CLIP_LONG_FIELDS       [get_parameter_value PC0_CLIP_LONG_FIELDS]
        set_instance_parameter_value intel_vvp_protocol_conv_0 ENABLE_TIMEOUT         [get_parameter_value PC0_ENABLE_TIMEOUT]
        add_connection clock_in.out_clk   intel_vvp_protocol_conv_0.main_clock
        add_connection reset_in.out_reset intel_vvp_protocol_conv_0.main_reset
    }

    # -- SCALER --------------------------------------------------------------
    if {$do_scl} {
        add_instance intel_vvp_scaler_0 intel_vvp_scaler 24.5.1
        set_instance_parameter_value intel_vvp_scaler_0 EXTERNAL_MODE          [get_parameter_value SC_EXTERNAL_MODE]
        set_instance_parameter_value intel_vvp_scaler_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_scaler_0 NUMBER_OF_COLOR_PLANES $internal_npl
        set_instance_parameter_value intel_vvp_scaler_0 PIXELS_IN_PARALLEL     $pip
        # When the internal pipeline runs at 3 planes (444), the scaler input is
        # always 444 — force ENABLE_444 on so the scaler accepts that format.
        set sc_enable_444 [expr {($internal_npl == 3) ? 1 : [get_parameter_value SC_ENABLE_444]}]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_444             $sc_enable_444
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_422             [get_parameter_value SC_ENABLE_422]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_420             [get_parameter_value SC_ENABLE_420]
        set_instance_parameter_value intel_vvp_scaler_0 NO_BLANKING            [get_parameter_value SC_NO_BLANKING]
        set_instance_parameter_value intel_vvp_scaler_0 MAX_IN_WIDTH           [get_parameter_value SC_MAX_IN_WIDTH]
        set_instance_parameter_value intel_vvp_scaler_0 MAX_OUT_WIDTH          [get_parameter_value SC_MAX_OUT_WIDTH]
        set_instance_parameter_value intel_vvp_scaler_0 OUTPUT_HEIGHT          [get_parameter_value SC_OUTPUT_HEIGHT]
        set_instance_parameter_value intel_vvp_scaler_0 RUNTIME_CONTROL        [get_parameter_value SC_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_scaler_0 SEPARATE_SLAVE_CLOCK   [get_parameter_value SC_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_scaler_0 ENABLE_DEBUG           [get_parameter_value SC_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_scaler_0 PIPELINE_READY         [get_parameter_value SC_PIPELINE_READY]
        set_instance_parameter_value intel_vvp_scaler_0 ALGORITHM              [get_parameter_value SC_ALGORITHM]
        set_instance_parameter_value intel_vvp_scaler_0 EDGE_MIRROR            [get_parameter_value SC_EDGE_MIRROR]
        set_instance_parameter_value intel_vvp_scaler_0 RUNTIME_LOAD           [get_parameter_value SC_RUNTIME_LOAD]
        set_instance_parameter_value intel_vvp_scaler_0 MEM_INIT               [get_parameter_value SC_MEM_INIT]
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
            mm_connect intel_vvp_scaler_0 av_mm_control_agent 0x0800
        }
    }

    # -- Chain main video path: CRS -> CSC -> Clipper -> PC0 -> Scaler ------
    set last_out ""

    if {$do_crs} { set last_out "intel_vvp_crs_0.axi4s_vid_out" }

    if {$do_csc} {
        if {$last_out ne ""} { add_connection $last_out intel_vvp_csc_0.axi4s_vid_in }
        set last_out "intel_vvp_csc_0.axi4s_vid_out"
    }
    if {$do_clip} {
        if {$last_out ne ""} { add_connection $last_out intel_vvp_clipper_0.axi4s_vid_in }
        set last_out "intel_vvp_clipper_0.axi4s_vid_out"
    }
    if {$do_pc0} {
        if {$last_out ne ""} { add_connection $last_out intel_vvp_protocol_conv_0.axi4s_vid_in }
        set last_out "intel_vvp_protocol_conv_0.axi4s_vid_out"
    }
    if {$do_scl} {
        if {$last_out ne ""} { add_connection $last_out intel_vvp_scaler_0.axi4s_vid_in }
        set last_out "intel_vvp_scaler_0.axi4s_vid_out"
    }

    # In FULL mode: DIL output feeds into the CRS input
    if {$do_dil && $do_crs} {
        add_connection intel_vvp_dil_0.axi4s_vid_out intel_vvp_crs_0.axi4s_vid_in
    }

    # In DIL_ONLY mode the features (if any) consume the DIL output
    if {$do_dil && !$do_crs && ($do_frc || $do_pip)} {
        set last_out "intel_vvp_dil_0.axi4s_vid_out"
    }

    # ========================================================================
    # FEATURES - appended after the processing chain
    # Chain: ... -> [Lite->Full conv] -> [FRC frame buffer] -> [PIP mixer] -> out
    # Validated configuration ported from the frame_buf_addition branch
    # (VFB + EMIF IO96B DDR4 + memory model, 2-layer mixer).
    # ========================================================================

    # -- Is the current chain output Lite (no backpressure)? -----------------
    # The frame buffer and the mixer are Full-protocol IPs; a Lite chain
    # output must first pass through a Lite->Full protocol converter.
    set chain_is_lite 0
    if {$do_scl} {
        set chain_is_lite [get_parameter_value SC_EXTERNAL_MODE]
    } elseif {$do_pc0} {
        set chain_is_lite 1
    } elseif {$do_clip} {
        set chain_is_lite [get_parameter_value CL_EXTERNAL_MODE]
    } elseif {$do_csc} {
        set chain_is_lite [get_parameter_value CSC_EXTERNAL_MODE]
    } elseif {$do_crs} {
        set chain_is_lite [get_parameter_value CRS_EXTERNAL_MODE]
    } elseif {$do_dil} {
        set chain_is_lite [get_parameter_value DIL_EXTERNAL_MODE]
    }

    # -- Lite->Full converter (runtime programmed with the frame dimensions) -
    if {($do_frc || $do_pip) && $chain_is_lite && $last_out ne ""} {
        add_instance ltf_conv_0 intel_vvp_protocol_conv 24.6.0
        set_instance_parameter_value ltf_conv_0 BPS                    $bps
        set_instance_parameter_value ltf_conv_0 NUMBER_OF_COLOR_PLANES $internal_npl
        set_instance_parameter_value ltf_conv_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value ltf_conv_0 INPUT_MODE             "EXTERNAL"
        set_instance_parameter_value ltf_conv_0 OUTPUT_MODE            "INTERNAL"
        set_instance_parameter_value ltf_conv_0 RUNTIME_CONTROL        1
        set_instance_parameter_value ltf_conv_0 ENABLE_YCBCR_SWAP      0
        set_instance_parameter_value ltf_conv_0 VVP_USER_SUPPORT       "NONE_ALLOWED"
        set_instance_parameter_value ltf_conv_0 VIP_USER_SUPPORT       "DISCARD"
        set_instance_parameter_value ltf_conv_0 COLOR_SPACE            [get_parameter_value PC0_COLOR_SPACE]
        set_instance_parameter_value ltf_conv_0 CHROMA_SAMPLING        [expr {($internal_npl == 3) ? "444" : [get_parameter_value PC0_CHROMA_SAMPLING]}]
        set_instance_parameter_value ltf_conv_0 CHROMA_SITING          [get_parameter_value PC0_CHROMA_SITING]
        # Clip long fields so a mis-programmed source cannot corrupt buffered frames
        set_instance_parameter_value ltf_conv_0 CLIP_LONG_FIELDS       1
        set_instance_parameter_value ltf_conv_0 ENABLE_TIMEOUT         0
        add_connection clock_in.out_clk   ltf_conv_0.main_clock
        add_connection reset_in.out_reset ltf_conv_0.main_reset
        add_connection $last_out ltf_conv_0.axi4s_vid_in
        set last_out "ltf_conv_0.axi4s_vid_out"
        # 0x0C00: the scaler agent spans 0x0800-0x0BFF (runtime coefficient
        # load region), so the feature agents start above it
        mm_connect ltf_conv_0 av_mm_control_agent 0x0C00
    }

    # -- FRC: Video Frame Buffer (write + read through external memory) ------
    if {$do_frc} {
        add_instance intel_vvp_vfb_0 intel_vvp_vfb 24.5.1
        set_instance_parameter_value intel_vvp_vfb_0 BPS                           $bps
        set_instance_parameter_value intel_vvp_vfb_0 NUMBER_OF_COLOR_PLANES        $internal_npl
        set_instance_parameter_value intel_vvp_vfb_0 PIXELS_IN_PARALLEL            $pip
        set_instance_parameter_value intel_vvp_vfb_0 MAX_WIDTH                     [get_parameter_value FRC_MAX_WIDTH]
        set_instance_parameter_value intel_vvp_vfb_0 MAX_HEIGHT                    [get_parameter_value FRC_MAX_HEIGHT]
        set_instance_parameter_value intel_vvp_vfb_0 FRAME_DROP_ENABLE             [get_parameter_value FRC_FRAME_DROP_ENABLE]
        set_instance_parameter_value intel_vvp_vfb_0 FRAME_REPEAT_ENABLE           [get_parameter_value FRC_FRAME_REPEAT_ENABLE]
        set_instance_parameter_value intel_vvp_vfb_0 DROP_BROKEN_FRAMES            [get_parameter_value FRC_DROP_BROKEN_FRAMES]
        set_instance_parameter_value intel_vvp_vfb_0 DROP_RPT_AUX_PKTS_WITH_FRAMES [get_parameter_value FRC_DROP_RPT_AUX]
        set_instance_parameter_value intel_vvp_vfb_0 MAX_CONTROL_PACKETS           [get_parameter_value FRC_MAX_CONTROL_PACKETS]
        set_instance_parameter_value intel_vvp_vfb_0 EXTERNAL_MODE                 0
        set_instance_parameter_value intel_vvp_vfb_0 RUNTIME_CONTROL               [get_parameter_value FRC_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_vfb_0 SEPARATE_SLAVE_CLOCK          [get_parameter_value FRC_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_vfb_0 ENABLE_DEBUG                  [get_parameter_value FRC_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_vfb_0 P_AV_MM_DATA_WIDTH            [get_parameter_value FRC_AV_MM_DATA_WIDTH]
        set_instance_parameter_value intel_vvp_vfb_0 P_AV_MM_ADDR_WIDTH            [get_parameter_value FRC_AV_MM_ADDR_WIDTH]
        set_instance_parameter_value intel_vvp_vfb_0 WRITE_FIFO_DEPTH              [get_parameter_value FRC_WRITE_FIFO_DEPTH]
        set_instance_parameter_value intel_vvp_vfb_0 WRITE_BURST_TARGET            [get_parameter_value FRC_WRITE_BURST_TARGET]
        set_instance_parameter_value intel_vvp_vfb_0 READ_FIFO_DEPTH               [get_parameter_value FRC_READ_FIFO_DEPTH]
        set_instance_parameter_value intel_vvp_vfb_0 READ_BURST_TARGET             [get_parameter_value FRC_READ_BURST_TARGET]
        set_instance_parameter_value intel_vvp_vfb_0 PACKING                       [get_parameter_value FRC_PACKING]
        set_instance_parameter_value intel_vvp_vfb_0 CLOCKS_ARE_SEPARATE           [get_parameter_value FRC_CLOCKS_ARE_SEPARATE]
        set_instance_parameter_value intel_vvp_vfb_0 MEM_BUFF_BASE_ADDR            [get_parameter_value FRC_MEM_BUFF_BASE_ADDR]
        set_instance_parameter_value intel_vvp_vfb_0 MEM_BUFF_LINE_STRIDE          [get_parameter_value FRC_MEM_BUFF_LINE_STRIDE]
        add_connection clock_in.out_clk   intel_vvp_vfb_0.main_clock
        add_connection reset_in.out_reset intel_vvp_vfb_0.main_reset
        if {$last_out ne ""} { add_connection $last_out intel_vvp_vfb_0.axi4s_vid_in }
        set last_out "intel_vvp_vfb_0.axi4s_vid_out"
        if {[get_parameter_value FRC_RUNTIME_CONTROL]} {
            mm_connect intel_vvp_vfb_0 av_mm_control_agent 0x0E00
        }

        # -- Internal DDR4 EMIF (IO96B) ---------------------------------------
        # Wiring replicated from the validated frame_buf_addition system:
        # both VFB memory hosts on the EMIF AXI4 target, everything in the
        # main clock domain. The memory-side I/Os are exported below; the
        # DDR4 device / memory model connects to them at system level.
        if {[get_parameter_value FRC_INCLUDE_EMIF]} {
            add_instance frc_emif_0 emif_io96b_ddr4comp 4.0.0
            # DDR4-3200W, one x32 channel of 8Gb x16 dies - timing auto-derives
            set_instance_parameter_value frc_emif_0 MEM_SPEEDBIN               "3200W"
            set_instance_parameter_value frc_emif_0 MEM_DIE_DENSITY_GBITS      8
            set_instance_parameter_value frc_emif_0 MEM_DIE_DQ_WIDTH           16
            set_instance_parameter_value frc_emif_0 MEM_CHANNEL_DATA_DQ_WIDTH  32
            set_instance_parameter_value frc_emif_0 CTRL_PERFORMANCE_PROFILE   "SEQ"
            add_connection clock_in.out_clk   frc_emif_0.s0_axi4_clock_in
            add_connection clock_in.out_clk   frc_emif_0.s0_axi4lite_clock
            add_connection reset_in.out_reset frc_emif_0.core_init_n
            add_connection reset_in.out_reset frc_emif_0.s0_axi4lite_reset_n
            add_connection intel_vvp_vfb_0.av_mm_mem_write_host frc_emif_0.s0_axi4
            add_connection intel_vvp_vfb_0.av_mm_mem_read_host  frc_emif_0.s0_axi4
            if {[get_parameter_value FRC_CLOCKS_ARE_SEPARATE]} {
                add_connection clock_in.out_clk   intel_vvp_vfb_0.mem_clock
                add_connection reset_in.out_reset intel_vvp_vfb_0.mem_reset
            }
        }
    }

    # -- PIP: uniform-color background TPG + mixer ----------------------------
    if {$do_pip} {
        set pip_layers [get_parameter_value PIP_NUM_LAYERS]

        add_instance pip_bg_tpg_0 intel_vvp_tpg 24.5.1
        set_instance_parameter_value pip_bg_tpg_0 BPS                $bps
        set_instance_parameter_value pip_bg_tpg_0 PIXELS_IN_PARALLEL $pip
        set_instance_parameter_value pip_bg_tpg_0 RUNTIME_CONTROL    1
        set_instance_parameter_value pip_bg_tpg_0 EXTERNAL_MODE      0
        set_instance_parameter_value pip_bg_tpg_0 NUM_CORES          1
        set_instance_parameter_value pip_bg_tpg_0 CORE_PATTERN_0     1
        set_instance_parameter_value pip_bg_tpg_0 CORE_COL_SPACE_0   0
        set_instance_parameter_value pip_bg_tpg_0 OUTPUT_FORMAT      [expr {($internal_npl == 2) ? "4.2.2" : "4.4.4"}]
        add_connection clock_in.out_clk   pip_bg_tpg_0.main_clock
        add_connection reset_in.out_reset pip_bg_tpg_0.main_reset

        add_instance intel_vvp_mixer_0 intel_vvp_mixer 24.5.1
        set_instance_parameter_value intel_vvp_mixer_0 BPS                    $bps
        set_instance_parameter_value intel_vvp_mixer_0 NUMBER_OF_COLOR_PLANES $internal_npl
        set_instance_parameter_value intel_vvp_mixer_0 PIXELS_IN_PARALLEL     $pip
        set_instance_parameter_value intel_vvp_mixer_0 NUM_LAYERS             $pip_layers
        set_instance_parameter_value intel_vvp_mixer_0 EXTERNAL_MODE          0
        set_instance_parameter_value intel_vvp_mixer_0 RUNTIME_CONTROL        [get_parameter_value PIP_RUNTIME_CONTROL]
        set_instance_parameter_value intel_vvp_mixer_0 SEPARATE_SLAVE_CLOCK   [get_parameter_value PIP_SEPARATE_SLAVE_CLOCK]
        set_instance_parameter_value intel_vvp_mixer_0 ENABLE_DEBUG           [get_parameter_value PIP_ENABLE_DEBUG]
        set_instance_parameter_value intel_vvp_mixer_0 BLENDING_MODE_1        [get_parameter_value PIP_BLENDING_MODE_1]
        if {$pip_layers >= 3} {
            set_instance_parameter_value intel_vvp_mixer_0 BLENDING_MODE_2 [get_parameter_value PIP_BLENDING_MODE_2]
        }
        if {$pip_layers >= 4} {
            set_instance_parameter_value intel_vvp_mixer_0 BLENDING_MODE_3 [get_parameter_value PIP_BLENDING_MODE_3]
        }
        add_connection clock_in.out_clk   intel_vvp_mixer_0.main_clock
        add_connection reset_in.out_reset intel_vvp_mixer_0.main_reset

        # Layer 0 = background TPG, layer 1 = pipeline video
        add_connection pip_bg_tpg_0.axi4s_vid_out intel_vvp_mixer_0.axi4s_vid_0_in
        if {$last_out ne ""} { add_connection $last_out intel_vvp_mixer_0.axi4s_vid_1_in }
        set last_out "intel_vvp_mixer_0.axi4s_vid_out"

        if {[get_parameter_value PIP_RUNTIME_CONTROL]} {
            mm_connect intel_vvp_mixer_0 av_mm_control_agent 0x1000
        }
        mm_connect pip_bg_tpg_0 av_mm_control_agent 0x1400
    }

    # -- Exports -------------------------------------------------------------
    add_interface clk clock end
    set_interface_property clk EXPORT_OF clock_in.in_clk
    add_interface reset reset end
    set_interface_property reset EXPORT_OF reset_in.in_reset

    if {$need_mm} {
        add_interface s0 avalon end
        set_interface_property s0 EXPORT_OF mm_bridge_0.s0
    }

    # DIL ports
    if {$do_dil} {
        if {[get_parameter_value DIL_MODE] ne "BOB"} {
            add_interface dil_mem_write_host avalon start
            set_interface_property dil_mem_write_host EXPORT_OF intel_vvp_dil_0.av_mm_mem_write_host
            add_interface dil_mem_read_host avalon start
            set_interface_property dil_mem_read_host EXPORT_OF intel_vvp_dil_0.av_mm_mem_read_host
        }

        if {!$do_crs} {
            # DIL-only: export DIL input; DIL output goes to the features when
            # enabled, otherwise it is exported as the main output directly
            add_interface s_axis_video_in axi4stream end
            set_interface_property s_axis_video_in EXPORT_OF intel_vvp_dil_0.axi4s_vid_in
            if {!($do_frc || $do_pip)} {
                add_interface m_axis_video_out axi4stream start
                set_interface_property m_axis_video_out EXPORT_OF intel_vvp_dil_0.axi4s_vid_out
            }
        } else {
            # FULL mode: DIL feeds CRS; expose DIL input port
            add_interface s_axis_video_in axi4stream end
            set_interface_property s_axis_video_in EXPORT_OF intel_vvp_dil_0.axi4s_vid_in
        }
    }

    # Main chain input - first non-DIL IP
    if {!$do_dil} {
        if {$do_crs} {
            add_interface s_axis_video_in axi4stream end
            set_interface_property s_axis_video_in EXPORT_OF intel_vvp_crs_0.axi4s_vid_in
        } elseif {$do_csc} {
            add_interface s_axis_video_in axi4stream end
            set_interface_property s_axis_video_in EXPORT_OF intel_vvp_csc_0.axi4s_vid_in
        } elseif {$do_clip} {
            add_interface s_axis_video_in axi4stream end
            set_interface_property s_axis_video_in EXPORT_OF intel_vvp_clipper_0.axi4s_vid_in
        } elseif {$do_pc0} {
            add_interface s_axis_video_in axi4stream end
            set_interface_property s_axis_video_in EXPORT_OF intel_vvp_protocol_conv_0.axi4s_vid_in
        } elseif {$do_scl} {
            add_interface s_axis_video_in axi4stream end
            set_interface_property s_axis_video_in EXPORT_OF intel_vvp_scaler_0.axi4s_vid_in
        }
    }

    # Main chain output - last active IP (with features: frame buffer / mixer)
    if {$last_out ne "" && !($do_dil && !$do_crs && !($do_frc || $do_pip))} {
        add_interface m_axis_video_out axi4stream start
        set_interface_property m_axis_video_out EXPORT_OF $last_out
    }

    # -- FRC exports ----------------------------------------------------------
    if {$do_frc} {
        if {[get_parameter_value FRC_INCLUDE_EMIF]} {
            # EMIF inside: export the DDR4 memory-side I/Os for the memory
            # device / simulation memory model
            add_interface frc_emif_ref_clk clock end
            set_interface_property frc_emif_ref_clk EXPORT_OF frc_emif_0.ref_clk
            add_interface frc_emif_mem conduit end
            set_interface_property frc_emif_mem EXPORT_OF frc_emif_0.mem_0
            add_interface frc_emif_mem_ck conduit end
            set_interface_property frc_emif_mem_ck EXPORT_OF frc_emif_0.mem_ck_0
            add_interface frc_emif_mem_reset_n conduit end
            set_interface_property frc_emif_mem_reset_n EXPORT_OF frc_emif_0.mem_reset_n
            add_interface frc_emif_oct conduit end
            set_interface_property frc_emif_oct EXPORT_OF frc_emif_0.oct_0
        } else {
            # No internal EMIF: export the raw memory hosts (connect to an
            # external EMIF/DDR controller at system level)
            add_interface frc_mem_write_host avalon start
            set_interface_property frc_mem_write_host EXPORT_OF intel_vvp_vfb_0.av_mm_mem_write_host
            add_interface frc_mem_read_host avalon start
            set_interface_property frc_mem_read_host EXPORT_OF intel_vvp_vfb_0.av_mm_mem_read_host
            if {[get_parameter_value FRC_CLOCKS_ARE_SEPARATE]} {
                # Drive from the memory/EMIF user clock domain at system level
                # (the validated design drove this from the same clock as 'clk')
                add_interface frc_mem_clock clock end
                set_interface_property frc_mem_clock EXPORT_OF intel_vvp_vfb_0.mem_clock
                add_interface frc_mem_reset reset end
                set_interface_property frc_mem_reset EXPORT_OF intel_vvp_vfb_0.mem_reset
            }
        }
    }

    # -- PIP exports: additional mixer layer inputs (layers 2 and above) -----
    if {$do_pip} {
        set pip_layers [get_parameter_value PIP_NUM_LAYERS]
        for {set i 2} {$i < $pip_layers} {incr i} {
            add_interface s_axis_pip_layer${i}_in axi4stream end
            set_interface_property s_axis_pip_layer${i}_in EXPORT_OF intel_vvp_mixer_0.axi4s_vid_${i}_in
        }
    }
}
