#include <stdio.h>
#include <stdbool.h>

#include "system.h"                 /* INTEL_VVP_TPG_0_BASE, INTEL_VVP_SCALER_0_BASE */
#include "intel_vvp_core.h"         /* kIntelVvpCoreOk, set_img_info_*               */
#include "intel_vvp_tpg.h"          /* TPG driver API                                */
#include "intel_vvp_scaler.h"       /* Scaler driver API                             */

/* Pipeline: TPG -> Scaler -> exported.
 * Tune these to your design. The TPG generates IN_W x IN_H; the scaler
 * resizes that to OUT_W x OUT_H. */
#define IN_W   1920
#define IN_H   1080
#define OUT_W  1280
#define OUT_H   720

/**
 * Configure the TPG (video source): set the output frame size, select a
 * pattern and start generating. Leaves the TPG running on success.
 *
 * \return kIntelVvpCoreOk on success, a non-zero error code otherwise.
 */
static int setup_tpg(intel_vvp_tpg_instance *tpg, uint32_t width, uint32_t height)
{
    int rc;

    /* READS the core ID/version regs to validate the IP, then caches the
     * compile-time params: LITE_MODE_REG, DEBUG_ENABLED_REG, NUM_PATTERNS_REG,
     * BPS_REG, PIP_REG. Also calls stop() internally -> CONTROL_REG = 0. */
    rc = intel_vvp_tpg_init(tpg, (intel_vvp_core_base) INTEL_VVP_TPG_0_BASE);
    if (rc != kIntelVvpCoreOk) {
        printf("TPG init FAILED, rc=%d\n", rc);
        return rc;
    }

    /* No register access here: these getters return the values cached in the
     * instance struct by intel_vvp_tpg_init() above. */
    printf("TPG:    patterns=%u bps=%u pip=%u lite=%d\n",
           intel_vvp_tpg_get_num_patterns(tpg),
           intel_vvp_tpg_get_bits_per_sample(tpg),
           intel_vvp_tpg_get_pixels_in_parallel(tpg),
           (int) intel_vvp_tpg_get_lite_mode(tpg));

    /* WRITES CONTROL_REG = 0 (clears the GO bit) so we reconfigure cleanly. */
    intel_vvp_tpg_stop(tpg);

    /* In lite mode the output frame size is set via the core img-info
     * registers; in full mode the TPG emits it in-band.
     * WRITES the core IMG_INFO width/height regs (shared intel_vvp_core map). */
    if (intel_vvp_tpg_get_lite_mode(tpg)) {
        intel_vvp_core_set_img_info_width(tpg, width);   /* -> core IMG_INFO_WIDTH  */
        intel_vvp_core_set_img_info_height(tpg, height); /* -> core IMG_INFO_HEIGHT */
    }

    /* WRITES PATTERN_SELECT_REG = 0 (selects pattern slot 0). */
    rc = intel_vvp_tpg_set_pattern(tpg, 0);          /* slot 0 (fixed at IP-gen time) */
    if (rc != kIntelVvpCoreOk) printf("tpg set_pattern(0) rc=%d\n", rc);

    /* WRITES BARS_SELECT_REG = INTEL_VVP_TPG_COLOR_BARS. */
    rc = intel_vvp_tpg_set_bars_type(tpg, kIntelVvpTpgColorBars);
    if (rc != kIntelVvpCoreOk) printf("tpg set_bars_type rc=%d\n", rc);

    /* Full mode only: WRITES COMMIT_REG to latch the staged register writes
     * above at the next frame boundary (lite mode applies them immediately). */
    if (!intel_vvp_tpg_get_lite_mode(tpg)) {
        rc = intel_vvp_tpg_commit_writes(tpg);
        if (rc != kIntelVvpCoreOk) printf("tpg commit rc=%d\n", rc);
    }

    /* WRITES CONTROL_REG = GO_MSK (sets the GO bit -> generation starts). */
    rc = intel_vvp_tpg_start(tpg);
    if (rc != kIntelVvpCoreOk) {
        printf("TPG start FAILED, rc=%d\n", rc);
        return rc;
    }

    return kIntelVvpCoreOk;
}

/**
 * Configure the Scaler: set its input size (lite mode) and output size for
 * whichever axis has scaling enabled, then commit. The scaler has no
 * start/stop; it processes the stream once configured.
 *
 * \return kIntelVvpCoreOk on success, a non-zero error code otherwise.
 */
static int setup_scaler(intel_vvp_scaler_instance *scaler,
                        uint32_t in_w, uint32_t in_h,
                        uint32_t out_w, uint32_t out_h)
{
    int rc;

    /* READS the core ID/version regs to validate the IP, then caches the
     * compile-time params: LITE_MODE_REG, DEBUG_ENABLED_REG,
     * PIXELS_IN_PARALLEL_REG, MAX_INPUT_WIDTH_REG, MAX_OUTPUT_WIDTH_REG,
     * ALGORITHM_REG, and (depending on algo) the V_/H_ SCALING_ENABLED,
     * NUM_TAPS, NUM_PHASES, NUM_BANKS and COEFFS_* regs. No writes. */
    rc = intel_vvp_scaler_init(scaler, (intel_vvp_core_base) INTEL_VVP_SCALER_0_BASE);
    if (rc != kIntelVvpCoreOk) {
        printf("Scaler init FAILED, rc=%d\n", rc);
        return rc;
    }

    /* No register access here: these getters return values cached in the
     * instance struct by intel_vvp_scaler_init() above. */
    printf("Scaler: hscale=%d vscale=%d max_in_w=%u max_out_w=%u lite=%d\n",
           (int) intel_vvp_scaler_is_horizontal_scaling_enabled(scaler),
           (int) intel_vvp_scaler_is_vertical_scaling_enabled(scaler),
           intel_vvp_scaler_get_max_input_width(scaler),
           intel_vvp_scaler_get_max_output_width(scaler),
           (int) intel_vvp_scaler_get_lite_mode(scaler));

    /* In lite mode the scaler needs its INPUT size (= TPG output); in full
     * mode the input size arrives in-band from the TPG.
     * WRITES the core IMG_INFO width/height regs (shared intel_vvp_core map). */
    if (intel_vvp_scaler_get_lite_mode(scaler)) {
        intel_vvp_core_set_img_info_width(scaler, in_w);   /* -> core IMG_INFO_WIDTH  */
        intel_vvp_core_set_img_info_height(scaler, in_h);  /* -> core IMG_INFO_HEIGHT */
    }

    /* Set the OUTPUT size only for the axis that has scaling enabled in HW. */
    if (intel_vvp_scaler_is_horizontal_scaling_enabled(scaler)) {
        /* WRITES OUTPUT_WIDTH_REG (rejected if 0 or > MAX_OUTPUT_WIDTH_REG). */
        rc = intel_vvp_scaler_set_output_width(scaler, out_w);
        if (rc != kIntelVvpCoreOk) printf("scaler set_output_width rc=%d\n", rc);
    }
    if (intel_vvp_scaler_is_vertical_scaling_enabled(scaler)) {
        /* WRITES OUTPUT_HEIGHT_REG (rejected if 0). */
        rc = intel_vvp_scaler_set_output_height(scaler, out_h);
        if (rc != kIntelVvpCoreOk) printf("scaler set_output_height rc=%d\n", rc);
    }

    /* Full mode only: WRITES COMMIT_REG to latch the OUTPUT_WIDTH/HEIGHT writes
     * above at the next frame interval (lite mode latches immediately). */
    if (!intel_vvp_scaler_get_lite_mode(scaler)) {
        rc = intel_vvp_scaler_commit_writes(scaler);
        if (rc != kIntelVvpCoreOk) printf("scaler commit rc=%d\n", rc);
    }

    return kIntelVvpCoreOk;
}

int main(void)
{
    intel_vvp_tpg_instance    tpg;
    intel_vvp_scaler_instance scaler;

    printf("hello hamza! TPG @ 0x%08x -> Scaler @ 0x%08x\n",
           INTEL_VVP_TPG_0_BASE, INTEL_VVP_SCALER_0_BASE);

    /* Configure the scaler first so it is ready before frames arrive, then
     * start the TPG source. */
    if (setup_scaler(&scaler, IN_W, IN_H, OUT_W, OUT_H) != kIntelVvpCoreOk)
        return -1;

    if (setup_tpg(&tpg, IN_W, IN_H) != kIntelVvpCoreOk)
        return -1;

    /* Each is_running() READS that IP's STATUS_REG and returns its RUNNING bit. */
    printf("Pipeline running: tpg=%d scaler=%d  (%dx%d -> %dx%d)\n",
           (int) intel_vvp_tpg_is_running(&tpg),
           (int) intel_vvp_scaler_is_running(&scaler),
           IN_W, IN_H, OUT_W, OUT_H);
    return 0;
}
