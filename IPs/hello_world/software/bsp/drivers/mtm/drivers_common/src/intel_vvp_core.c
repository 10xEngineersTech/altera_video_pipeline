#include "intel_vvp_core.h"
#include "intel_vvp_core_regs.h"

eIntelVvpCoreErrors intel_vvp_core_init(intel_vvp_core_instance *instance, intel_vvp_core_base base, uint16_t expected_product_id)
{
    int init_ret;
    uint32_t read_reg;

    // Abort initialization and return kIntelVvpCoreInstanceErr if instance is a null pointer
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    ((intel_vvp_core_instance*)instance)->base = base;
    read_reg = INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_VID_PID_REG);
    ((intel_vvp_core_instance*)instance)->vendor_id  = INTEL_VVP_CORE_READ_FIELD(read_reg, VID_PID_VENDOR_ID);
    ((intel_vvp_core_instance*)instance)->product_id = INTEL_VVP_CORE_READ_FIELD(read_reg, VID_PID_PRODUCT_ID);

    init_ret = kIntelVvpCoreOk;
    if (INTEL_VVP_VENDOR_ID != ((intel_vvp_core_instance*)instance)->vendor_id)
    {
        // Complete initialization and return kIntelVvpCoreVidErr if vendor mismatch
        init_ret = kIntelVvpCoreVidErr;
    } else if (expected_product_id != ((intel_vvp_core_instance*)instance)->product_id)
    {
        // Complete initialization and return kIntelVvpCorePidErr if vendor mismatch
        init_ret = kIntelVvpCorePidErr;
    }
    if (kIntelVvpCoreOk == init_ret)
    {
        // Proceed with a read to the version register if, and only if, the pid_vid register matches with expectations
        read_reg = INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_VERSION_REG);
        ((intel_vvp_core_instance*)instance)->qpds_major     = INTEL_VVP_CORE_READ_FIELD(read_reg, VERSION_QPDS_MAJOR);
        ((intel_vvp_core_instance*)instance)->qpds_update    = INTEL_VVP_CORE_READ_FIELD(read_reg, VERSION_QPDS_UPDATE);
        ((intel_vvp_core_instance*)instance)->qpds_patch     = INTEL_VVP_CORE_READ_FIELD(read_reg, VERSION_QPDS_PATCH);
        ((intel_vvp_core_instance*)instance)->regmap_version = INTEL_VVP_CORE_READ_FIELD(read_reg, VERSION_REGMAP_VERSION);
    }

    intel_vvp_core_interrupt_instance zero_irq_instance = {};

    ((intel_vvp_core_instance*)instance)->irq_instance = zero_irq_instance;

    return init_ret;
}

eIntelVvpCoreErrors intel_vvp_core_init_interrupt(void *instance, intel_vvp_core_interrupt_handle irq_handle)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    ((intel_vvp_core_instance*)instance)->irq_instance.irq_handle = irq_handle;
    ((intel_vvp_core_instance*)instance)->irq_instance.isr_registered = false;
    ((intel_vvp_core_instance*)instance)->irq_instance.irq_enabled = false;

    return kIntelVvpCoreOk;
}

uint16_t intel_vvp_core_get_vendor_id(void *instance)
{
    if (instance == NULL) return 0xFFFF;

    return ((intel_vvp_core_instance *)instance)->vendor_id;
}

uint16_t intel_vvp_core_get_product_id(void *instance)
{
    if (instance == NULL) return 0xFFFF;

    return ((intel_vvp_core_instance *)instance)->product_id;
}

uint8_t intel_vvp_core_get_qpds_major(void *instance)
{
    if (instance == NULL) return 0xFF;
    return ((intel_vvp_core_instance *)instance)->qpds_major;
}

uint8_t intel_vvp_core_get_qpds_update(void *instance)
{
    if (instance == NULL) return 0xFF;

    return ((intel_vvp_core_instance *)instance)->qpds_update;
}

uint8_t intel_vvp_core_get_qpds_patch(void *instance)
{
    if (instance == NULL) return 0xFF;

    return ((intel_vvp_core_instance *)instance)->qpds_patch;
}

uint8_t intel_vvp_core_get_register_map_version(void *instance)
{
    if (instance == NULL) return 0xFF;

    return ((intel_vvp_core_instance *)instance)->regmap_version;
}

uint32_t intel_vvp_core_get_img_info_width(void *instance)
{
    if (instance == NULL) return 0xFFFFFFFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IMG_INFO_WIDTH_REG);
}

uint32_t intel_vvp_core_get_img_info_height(void *instance)
{
    if (instance == NULL) return 0xFFFFFFFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IMG_INFO_HEIGHT_REG);
}

uint8_t intel_vvp_core_get_img_info_interlace(void *instance)
{
    if (instance == NULL) return 0xFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IMG_INFO_INTERLACE_REG);
}

uint8_t intel_vvp_core_get_img_info_bps(void *instance)
{
    if (instance == NULL) return 0;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IMG_INFO_BPS_REG);
}

uint8_t intel_vvp_core_get_img_info_colorspace(void *instance)
{
    if (instance == NULL) return 0xFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IMG_INFO_COLORSPACE_REG);
}

uint8_t intel_vvp_core_get_img_info_subsampling(void *instance)
{
    if (instance == NULL) return 0xFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IMG_INFO_SUBSAMPLING_REG);
}

uint8_t intel_vvp_core_get_img_info_cositing(void *instance)
{
    if (instance == NULL) return 0xFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IMG_INFO_COSITING_REG);
}

uint16_t intel_vvp_core_get_img_info_field_count(void *instance)
{
    if (instance == NULL) return 0xFFFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IMG_INFO_FIELD_COUNT_REG);
}

eIntelVvpCoreErrors intel_vvp_core_set_img_info_width(void *instance, uint32_t width)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IMG_INFO_WIDTH_REG, width);
    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_set_img_info_height(void *instance, uint32_t height)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IMG_INFO_HEIGHT_REG, height);
    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_set_img_info_interlace(void *instance, uint8_t interlace)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IMG_INFO_INTERLACE_REG, interlace);
    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_set_img_info_bps(void *instance, uint8_t bps)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IMG_INFO_BPS_REG, bps);
    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_set_img_info_colorspace(void *instance, uint8_t colorspace)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IMG_INFO_COLORSPACE_REG, colorspace);
    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_set_img_info_subsampling(void *instance, uint8_t subsampling)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IMG_INFO_SUBSAMPLING_REG, subsampling);
    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_set_img_info_cositing(void *instance, uint8_t cositing)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IMG_INFO_COSITING_REG, cositing);
    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_register_isr(void *instance, intel_vvp_core_isr_func isr, void *isr_context)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;
    if (isr == NULL) return kIntelVvpCoreNullPtrErr;
    if (isr_context == NULL) return kIntelVvpCoreNullPtrErr;

    if (INTEL_VVP_CORE_REGISTER_ISR(instance, isr, isr_context)) return kIntelVvpCoreIrqOSErr;

    ((intel_vvp_core_instance*)instance)->irq_instance.isr_registered = true;

    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_enable_interrupt(void *instance)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    if (((intel_vvp_core_instance*)instance)->irq_instance.isr_registered == false) return kIntelVvpCoreIsrNotRegisteredErr;

    if (INTEL_VVP_CORE_ENABLE_INTERRUPT(instance)) return kIntelVvpCoreIrqOSErr;

    ((intel_vvp_core_instance*)instance)->irq_instance.irq_enabled = true;

    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_disable_interrupt(void *instance)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    if (((intel_vvp_core_instance*)instance)->irq_instance.isr_registered == false) return kIntelVvpCoreIsrNotRegisteredErr;

    if (((intel_vvp_core_instance*)instance)->irq_instance.irq_enabled == false) return kIntelVvpCoreIrqNotEnabledErr;

    if (INTEL_VVP_CORE_DISABLE_INTERRUPT(instance)) return kIntelVvpCoreIrqOSErr;

    ((intel_vvp_core_instance*)instance)->irq_instance.irq_enabled = false;

    return kIntelVvpCoreOk;
}

eIntelVvpCoreErrors intel_vvp_core_set_interrupt_control(void *instance, uint8_t bit_field)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IRQ_CONTROL_REG, bit_field);

    return kIntelVvpCoreOk;
}

uint32_t intel_vvp_core_get_interrupt_control(void *instance)
{
    if (instance == NULL) return 0xFFFFFFFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IRQ_CONTROL_REG);
}

eIntelVvpCoreErrors intel_vvp_core_set_interrupt_status(void *instance, uint32_t bit_field)
{
    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    INTEL_VVP_CORE_REG_IOWR(instance, INTEL_VVP_CORE_IRQ_STATUS_REG, bit_field);

    return kIntelVvpCoreOk;
}

uint32_t intel_vvp_core_get_interrupt_status(void *instance)
{
    if (instance == NULL) return 0xFFFFFFFF;

    return INTEL_VVP_CORE_REG_IORD(instance, INTEL_VVP_CORE_IRQ_STATUS_REG);
}

uint32_t intel_vvp_core_generic_isr(void *instance)
{
    uint32_t irq_status;
    intel_vvp_core_instance *core_instance;
    
    core_instance = (intel_vvp_core_instance*)instance;
    irq_status = INTEL_VVP_CORE_REG_IORD(core_instance, INTEL_VVP_CORE_IRQ_STATUS_REG);

    INTEL_VVP_CORE_REG_IOWR(core_instance, INTEL_VVP_CORE_IRQ_STATUS_REG, irq_status);

    return irq_status;
}