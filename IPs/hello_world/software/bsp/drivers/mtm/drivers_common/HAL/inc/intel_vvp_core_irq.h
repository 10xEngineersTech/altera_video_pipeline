/**
 * \brief   Common Nios interrupt API defines for the Intel VVP FPGA IP Suite
 *
 * Common defines functions to register, enable and disable interrupts
 * on IP in the Video & Vision Processing Suite. These assume the user is running
 * a Nios V system, or a Nios II system with the Enhanced Interrupt API. 
 * 
 */

#ifndef __INTEL_VVP_CORE_IRQ_H__
#define __INTEL_VVP_CORE_IRQ_H__

#include "intel_vvp_core_io.h"

#include "alt_types.h"
#include "sys/alt_irq.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

typedef struct intel_vvp_core_instance_s intel_vvp_core_instance;

typedef alt_isr_func intel_vvp_core_isr_func; ///< Redefinition of Nios specific isr function prototype to generic intel_vvp_core version

typedef struct intel_vvp_core_interrupt_handle_s
{
    alt_u32 ic_id;          ///< The interrupt controller id provided by system.h
    alt_u32 irq;            ///< The IRQ number provided by system.h
} intel_vvp_core_interrupt_handle; // Common typename for interrupt handle (same as protodriver API), but platform specific impl

/**
 * \brief Define to register an interrupt service routine with the Nios Enhanced Interrupt API
 * 
 * It is highly recommended to use intel_vvp_core_generic_isr to acknolwedge interrupts by calling it within
 * your ISR; this means it is also recommended for isr_context to contain the intel_vvp_core_instance, such that
 * it can be passed to intel_vvp_core_generic_isr.
 *
 * \param[in]  instance, pointer to a intel_vvp_core_instance structure (or derived structure)
 * \param[in]  isr, the interrupt service routine; the callback prototype must precisely match intel_vvp_core_isr_func
 * \param[in]  isr_context, any user-defined data structure that is passed as the argument to the given ISR
 * \return     kIntelVvpCoreInstanceErr if instance is invalid, or the interrupt handle is uninitiailized
 *             kIntelVvpCoreNullPtrErr if either the provided ISR or isr_context are null pointers
 *             kIntelVvpCoreIrqOSErr if registering the ISR with the OS is unsuccessful
 *             kIntelVvpCoreOk in case of success
 * \pre        the instance has been initialised both with intel_vvp_core_init and intel_vvp_core_init_interrupt
 */
#define INTEL_VVP_CORE_REGISTER_ISR(instance, isr, isr_context)       intel_vvp_core_irq_register_isr((intel_vvp_core_instance *)(instance), (intel_vvp_core_isr_func)(isr), (void *)isr_context)

/**
 * \brief Define to enable an interrupt with the Nios Enhanced Interrupt API
 *
 * \param[in]  instance, pointer to a intel_vvp_core_instance structure (or derived structure)
 * \return     kIntelVVpCoreInstanceErr if instance is invalid
 *             kIntelVvpCoreIsrNotRegistered if an ISR has not been registered to the instance
 *             kIntelVvpCoreIrqOSErr if the OS fails to enable the interrupt
 *             kIntelVvpCoreOk in case of success
 * \pre        instance has been initialised with both intel_vvp_core_init and intel_vvp_core_init_interrupt, and
 *             an ISR has been registered.
 * \remarks    If an ISR has not been defined, the interrupt will fire but nothing will happen and the interrupt will remain high
 */
#define INTEL_VVP_CORE_ENABLE_INTERRUPT(instance)           intel_vvp_core_irq_enable_interrupt((intel_vvp_core_instance *)(instance))

/**
 * \brief Define to disable an interrupt with the Nios Enhanced Interrupt API
 *
 * \param[in]  instance, pointer to a intel_vvp_core_instance structure (or derived structure)
 * \return     kIntelVVpCoreInstanceErr if instance is invalid
 *             kIntelVvpCoreIsrNotRegistered if an ISR has not been registered to the instance
 *             kIntelVvpCoreIrqOSErr if the OS fails to disable the interrupt
 *             kIntelVvpCoreOk in case of success
 * \pre        interrupt_handle must contain a valid interrupt controller ID (typically 0 for a Nios system), and the
 *             corresponding IRQ number for the IP instance. Both values are found in "system.h" in a Nios system
 * \remarks    If an ISR has not been defined, the interrupt will fire but nothing will happen and the interrupt will remain high.
 */
#define INTEL_VVP_CORE_DISABLE_INTERRUPT(instance)          intel_vvp_core_irq_disable_interrupt((intel_vvp_core_instance *)(instance))

int intel_vvp_core_irq_register_isr(intel_vvp_core_instance* instance, intel_vvp_core_isr_func isr_func, void *isr_context);
int intel_vvp_core_irq_enable_interrupt(intel_vvp_core_instance* instance);
int intel_vvp_core_irq_disable_interrupt(intel_vvp_core_instance* instance);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif  // __INTEL_VVP_CORE_IRQ_H__
