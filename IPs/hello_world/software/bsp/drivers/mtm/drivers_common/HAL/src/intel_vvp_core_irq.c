#include "intel_vvp_core_irq.h"

#include "intel_vvp_core.h"
#include "intel_vvp_core_regs.h"
#include "sys/alt_irq.h"
#include "system.h"

int intel_vvp_core_irq_register_isr(intel_vvp_core_instance *instance, intel_vvp_core_isr_func isr, void *isr_context)
{
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
    int retcode;
    intel_vvp_core_interrupt_instance irq_instance;
    intel_vvp_core_interrupt_handle irq_handle;

    if (instance == NULL) return kIntelVvpCoreInstanceErr;
    if (isr == NULL) return kIntelVvpCoreNullPtrErr;
    if (isr_context == NULL) return kIntelVvpCoreNullPtrErr;

    irq_instance = instance->irq_instance;
    irq_handle = irq_instance.irq_handle;

    if (irq_handle.ic_id == -1 || irq_handle.irq == -1) return kIntelVvpCoreIrqOSErr;

    retcode = alt_ic_isr_register(
        irq_handle.ic_id,
        irq_handle.irq,
        (alt_isr_func)isr,
        (void*)isr_context,
        0x0
    );
    
    if (retcode) return kIntelVvpCoreIrqOSErr;

    irq_instance.isr_registered = true;

    return kIntelVvpCoreOk;
#else
    return kIntelVvpCoreIrqOSErr;
#endif // ALT_ENHANCED_INTERRUPT_API_PRESENT
}

int intel_vvp_core_irq_enable_interrupt(intel_vvp_core_instance *instance)
{
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
    int retcode;
    intel_vvp_core_interrupt_instance irq_instance = instance->irq_instance;
    intel_vvp_core_interrupt_handle irq_handle = irq_instance.irq_handle;

    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    if (irq_handle.ic_id == -1 || irq_handle.irq == -1) return kIntelVvpCoreIrqOSErr;

    if (irq_instance.isr_registered) {
        retcode = alt_ic_irq_enable(irq_handle.ic_id, irq_handle.irq);
    } else {
        return kIntelVvpCoreIsrNotRegisteredErr;
    }

    if (retcode) return kIntelVvpCoreIrqOSErr;

    irq_instance.irq_enabled = true;
    return kIntelVvpCoreOk;
#else
    return kIntelVvpCoreIrqOSErr;
#endif // ALT_ENHANCED_INTERRUPT_API_PRESENT
}

int intel_vvp_core_irq_disable_interrupt(intel_vvp_core_instance *instance)
{
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
    int retcode;
    intel_vvp_core_interrupt_instance irq_instance = instance->irq_instance;
    intel_vvp_core_interrupt_handle irq_handle = irq_instance.irq_handle;

    if (instance == NULL) return kIntelVvpCoreInstanceErr;

    if (irq_handle.ic_id == -1 || irq_handle.irq == -1) return kIntelVvpCoreIrqOSErr;

    if (irq_instance.irq_enabled == false) return kIntelVvpCoreIrqNotEnabledErr;

    if (irq_instance.isr_registered) {
        retcode = alt_ic_irq_disable(irq_handle.ic_id, irq_handle.irq);
    } else {
        return kIntelVvpCoreIsrNotRegisteredErr;
    }

    if (retcode) return kIntelVvpCoreIrqOSErr;

    irq_instance.irq_enabled = false;

    return kIntelVvpCoreOk;
#else
    return kIntelVvpCoreIrqOSErr;
#endif // ALT_ENHANCED_INTERRUPT_API_PRESENT
}