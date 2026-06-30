/**
 * \brief  Common definitions for an intel_vvp_core_instance and associated functions
 *
 * The base definition of an intel_vvp_core_instance structure (derived for each
 * core) and the functions to access/modify it
 * 
 * \see Video & Vision IP Suite User Guide
 * \see intel_vvp_core_regs.h
 */
    
#ifndef __INTEL_VVP_CORE_H__
#define __INTEL_VVP_CORE_H__

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

#include "intel_vvp_core_io.h"
#include "intel_vvp_core_irq.h"

#define INTEL_VVP_VENDOR_ID 0x6AF7u   ///< IntelFPGA vendor id

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

typedef struct intel_vvp_core_interrupt_instance_s
{
    intel_vvp_core_interrupt_handle irq_handle;
    bool     isr_registered;
    bool     irq_enabled;
} intel_vvp_core_interrupt_instance;

/**
 * \brief The base definition for an intel_vvp_core_instance.
 * 
 * This is the base definition for an intel_vvp_core_instance. It contains the fields that are shared
 * by all intel_vvp_core instances.
 */
typedef struct intel_vvp_core_instance_s
{
    intel_vvp_core_base base;          ///< accessor object, it partially defines how register accesses can be done \see intel_vvp_core_io.h
    uint16_t vendor_id;                ///< instance vendor_id, compile-time constant for the hardware and set at initialization
    uint16_t product_id;               ///< instance product_id, compile-time constant for the hardware and set at initialization
    uint8_t  qpds_major;               ///< instance major version, compile-time constant for the hardware and set at initialization
    uint8_t  qpds_update;              ///< instance update version, compile-time constant for the hardware and set at initialization
    uint8_t  qpds_patch;               ///< instance patch version, compile-time constant for the hardware and set at initialization
    uint8_t  regmap_version;           ///< instance register map version, compile-time constant for the hardware and set at initialization
    intel_vvp_core_interrupt_instance irq_instance; ///< interrupt instance; run-time structure that stores the interrupt handle and other interrupt related data
} intel_vvp_core_instance;

typedef enum {
    kIntelVvpCoreOk          =  0,
    kIntelVvpCoreVidErr      = -1,
    kIntelVvpCorePidErr      = -2,
    kIntelVvpCoreInstanceErr = -3,
    kIntelVvpCoreNullPtrErr  = -4,
    kIntelVvpCoreIsrNotRegisteredErr = -5,
    kIntelVvpCoreIrqNotEnabledErr = -6,
    kIntelVvpCoreIrqOSErr = -7
} eIntelVvpCoreErrors;

/**
 * \brief Initialise a vvp_core instance
 * 
 * Initialization function for a VVP core instance, attempts accesses to the core
 * to initialize the fields of the intel_vvp_core_instance instance
 * 
 * \private
 * \param[in]  instance, the intel_vvp_core_instance to initialize
 * \param[in]  base, the accessor for the core (on Nios, this is simply the base address of the core)
 * \param[in]  expected_product_id, the expected product_id for hte core
 * \return     kIntelVvpCoreOk in case of success,
 *             kIntelVvpCoreVidErr if the vendor id of the core is not the IntelFPGA vendor ID (0x6AF7).
 *             kIntelVvpCorePidErr if the product_id does not match with the expectation
 *             kIntelVvpCoreInstanceErr if the instance is a null pointer
 *             The initialization stops early if the vendor ID/product ID are not a match
 *             and the second register, containing version numbers, is not read
 * \pre        base is a proper accessor for an Intel VVP core
 */
eIntelVvpCoreErrors intel_vvp_core_init(intel_vvp_core_instance *instance, intel_vvp_core_base base, uint16_t expected_product_id);

/**
 * \brief Initialise the interrupt structure of a vvp_core instance
 * 
 * If an individual core does not support interrupts, then the calling _init protodriver function
 * should not call this function and leave the contents of instance->interrupt_instance as NULL
 * 
 * \param[in]  instance, the base intel_vvp_core_instance
 * \param[in]  irq_handle, the intialized interrupt handle
 * \return     kIntelVvpCoreOk in case of success,
 * \pre        instance is a valid intel_vvp_core_instance and was initialized
 * \pre        irq_handle is a valid intel_vvp_core_interrupt_handle and is initialized by the user
 */
eIntelVvpCoreErrors intel_vvp_core_init_interrupt(void *instance, intel_vvp_core_interrupt_handle irq_handle);


/**
 * \brief Query the vendor_id of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the vendor_id field in the intel_vvp_core_instance instance
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint16_t intel_vvp_core_get_vendor_id(void *instance);

/**
 * \brief Query the product_id of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the product_id field in the intel_vvp_core_instance instance
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint16_t intel_vvp_core_get_product_id(void *instance);

/**
 * \brief Query the QPDS major version of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the qpds_major field in the intel_vvp_core_instance instance
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t  intel_vvp_core_get_qpds_major(void *instance);

/**
 * \brief Query the QPDS update (minor) version of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the qpds_update field in the intel_vvp_core_instance instance
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t  intel_vvp_core_get_qpds_update(void *instance);

/**
 * \brief Query the QPDS patch (build) version of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the qpds_patch field in the intel_vvp_core_instance instance
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t  intel_vvp_core_get_qpds_patch(void *instance);

/**
 * \brief Query the register map version number of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the regmap_version field in the intel_vvp_core_instance instance
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t  intel_vvp_core_get_register_map_version(void *instance);

/**
 * \brief Query the image_info width register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the value returned from a read to the image_info width register
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint32_t intel_vvp_core_get_img_info_width(void *instance);

/**
 * \brief Query the image_info height register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the value returned from a read to the image_info height register
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint32_t intel_vvp_core_get_img_info_height(void *instance);

/**
 * \brief Query the image_info interlace register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the value returned from a read to the image_info interlace register
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t  intel_vvp_core_get_img_info_interlace(void *instance);

/**
 * \brief Query the image_info bps register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     bps register
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t intel_vvp_core_get_img_info_bps(void *instance);

/**
 * \brief Query the image_info colorspace register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the value returned from a read to the image_info colorspace register
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t  intel_vvp_core_get_img_info_colorspace(void *instance);

/**
 * \brief Query the image_info subsampling register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the value returned from a read to the image_info subsampling register
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t  intel_vvp_core_get_img_info_subsampling(void *instance);

/**
 * \brief Query the image_info cositing register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     the value returned from a read to the image_info cositing register
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
uint8_t  intel_vvp_core_get_img_info_cositing(void *instance);

/**
* \brief Query the image_info field count register of an instance
* 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
* \return      the value returned from a read to the image_info cositing register
* \pre         instance is a valid intel_vvp_core_instance and was successfully initialized 
* \remarks     the returned value may be meaningless depending on IP parameterization. In full mode and with debug enabled
*              the field count contained in the last image info packet should be returned
*/
uint16_t  intel_vvp_core_get_img_info_field_count(void *instance);


/**
 * \brief Write the image_info width register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \param[in]  width, the new width
 * \return     kIntelVvpCoreInstanceErr in case of errors (output parameters are unchanged), kIntelVvpCoreOk otherwise
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
eIntelVvpCoreErrors intel_vvp_core_set_img_info_width(void *instance, uint32_t width);

/**
 * \brief Write the image_info height register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \param[in]  height, the new height
 * \return     kIntelVvpCoreInstanceErr in case of errors, kIntelVvpCoreOk otherwise
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
eIntelVvpCoreErrors intel_vvp_core_set_img_info_height(void *instance, uint32_t height);

/**
 * \brief Write the image_info interlace register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \param[in]  interlace, the new interlace
 * \return     kIntelVvpCoreInstanceErr in case of errors, kIntelVvpCoreOk otherwise
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
eIntelVvpCoreErrors intel_vvp_core_set_img_info_interlace(void *instance, uint8_t interlace);

/**
 * \brief Write the image_info bps register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \param[in]  bps, the new bps value
 * \return     kIntelVvpCoreInstanceErr in case of errors, kIntelVvpCoreOk otherwise
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
eIntelVvpCoreErrors intel_vvp_core_set_img_info_bps(void *instance, uint8_t bps);

/**
 * \brief Write the image_info colorspace register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \param[in]  colorspace, the new colorspace
 * \return     kIntelVvpCoreInstanceErr in case of errors, kIntelVvpCoreOk otherwise
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
eIntelVvpCoreErrors intel_vvp_core_set_img_info_colorspace(void *instance, uint8_t colorspace);

/**
 * \brief Write the image_info subsampling register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \param[in]  subsampling, the new subsampling
 * \return     kIntelVvpCoreInstanceErr in case of errors, kIntelVvpCoreOk otherwise
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
eIntelVvpCoreErrors intel_vvp_core_set_img_info_subsampling(void *instance, uint8_t subsampling);

/**
 * \brief Write the image_info cositing register of an instance
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \param[in]  cositing, the new cositing
 * \return     kIntelVvpCoreInstanceErr in case of errors, kIntelVvpCoreOk otherwise
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
eIntelVvpCoreErrors intel_vvp_core_set_img_info_cositing(void *instance, uint8_t cositing);

/**
 * \brief Register an interrupt service routine. It is recommended that the provided ISR utilises intel_vvp_core_generic_isr
 *        to acknowledge the interrupt and return a snapshot of the interrupt status register.
 *
 * \param[in]   instance, an intel_vvp_core instance. Usually, this is an instance from a structure derived from intel_vvp_core
 * \param[in]   isr, a function pointer to the interrupt service routine.
 * \param[in]   isr_context, a pointer to a user-defined arbitrary data structure. If calling intel_vvp_core_generic_isr, then this structure
 *              should contain the instance at least, to pass as an argument.
 * \return      kIntelVvpCoreInstanceErr in case of instance errors
 *              kIntelVvpCoreNullPtrErr if either isr or isr_context are null pointers
 *              kIntelVvpCoreIrqOSErr in case of OS errors
 *              kIntelVvpCoreOk otherwise
 * \pre         instance is a valid intel_vvp_core_instance and was successfully initialized,
 *              and instance.irq_handle is a user initialized intel_vvp_core_interrupt_handle structure
 */
eIntelVvpCoreErrors intel_vvp_core_register_isr(void *instance, intel_vvp_core_isr_func isr, void *isr_context);

/**
 * \brief Enables interrupt handling in general for the instance
 * 
 * Enables interrupt handling in general, however does not affect instance specific interrupt bits (set via intel_vvp_core_set_interrupt_control)
 *
 * \param[in]   instance, an intel_vvp_core instance. Usually, this is an instance from a structure derived from intel_vvp_core
 * \return      kIntelVvpCoreInstanceErr in case of instance errors
 *              kIntelVvpCoreIrqOSErr in case of OS errors
 *              kIntelVvpCoreIsrNotRegisteredErr if an ISR was not registered to the instance
 *              kIntelVvpCoreOk otherwise
 * \pre         instance is a valid intel_vvp_core_instance and was successfully initialized,
 *              and instance.irq_handle is a user initialized intel_vvp_core_interrupt_handle structure         
 * \see         intel_vvp_core_set_interrupt_bits
 */
eIntelVvpCoreErrors intel_vvp_core_enable_interrupt(void *instance);

/**
 * \brief Disables interrupt handling in general for the instance
 * 
 * Disables interrupt handling in general, however does not affect instance specific interrupt bits (set via intel_vvp_core_set_interrupt_control)
 *
 * \param[in]   instance, an intel_vvp_core instance. Usually, this is an instance from a structure derived from intel_vvp_core
 * \return      kIntelVvpCoreInstanceErr in case of instance errors
 *              kIntelVvpCoreIrqOSErr in case of OS errors
 *              kIntelVvpCoreIsrNotRegisteredErr if an ISR was not registered to the instance
 *              kIntelVvpCoreIrqNotEnabledErr if interrupts were not enabled on the instance
 *              kIntelVvpCoreOk otherwise
 * \pre         instance is a valid intel_vvp_core_instance and was successfully initialized,
 *              and instance.irq_handle is a user initialized intel_vvp_core_interrupt_handle structure
 * \see         intel_vvp_core_set_interrupt_bits
 */
eIntelVvpCoreErrors intel_vvp_core_disable_interrupt(void *instance);

/**
 * \brief Write to the interrupt control register of an instance
 * 
 * Write 1 to the bit corresponding to the interrupt you wish to enable, or 0 to disable
 * 
 * \param[in]   instance, an intel_vvp_core instance. Usually, this is an instance from a structure derived from intel_vvp_core
 * \param[in]   bit_field, a bit field representing the interrupt bits
 * \return      kIntelVvpCoreInstanceErr in case of instance errors
 *              kIntelVvpCoreOk otherwise
 * \pre         instance is a valid intel_vvp_core_instance and was successfully initialized 
 */
eIntelVvpCoreErrors intel_vvp_core_set_interrupt_control(void *instance, uint8_t bit_field);

/**
 * \brief Returns the contents of the interrupt control register of an instance
 * 
 * \param[in]   instance, an intel_vvp_core instance. Usually, this is an instance from a structure derived from intel_vvp_core
 * \return      the value returned from a read to the interrupt control register, or 0xFF in case of error
 * \pre         instance is a valid intel_vvp_core_instance and was successfully initialized
 */
uint32_t intel_vvp_core_get_interrupt_control(void *instance);

/**
 * \brief Write to the interrupt status register of an instance
 * 
 * Acknolwedge an interrupt by writing a 1 to the corresponding bit
 *
 * \param[in]   instance, an intel_vvp_core instance. Usually, this is an instance from a structure derived from intel_vvp_core
 * \param[in]   mask, a bit field representing the interrupt acknowledge bits
 * \return      kIntelVvpCoreInstanceErr in case of instance errors
 *              kIntelVvpCoreOk otherwise
 */
eIntelVvpCoreErrors intel_vvp_core_set_interrupt_status(void *instance, uint32_t bit_field);

/**
 * \brief Returns the contents of the interrupt status register of an instance
 * 
 * An interrupt has fired when the corresponding bit is 1
 *
 * \param[in]   instance, an intel_vvp_core instance. Usually, this is an instance from a structure derived from intel_vvp_core
 * \param[in]   bit_field, the bit field corresponding to the bits to acknolwedge
 * \return      the value returned from a read to the interrupt status register, or 0xFF in case of error
 */
uint32_t intel_vvp_core_get_interrupt_status(void *instance);

/**
 * \brief Basic interrupt service routine to acknolwedge the fired interrupts from a VVP instance. If multiple
 *        interrupts are fired at the same time, all interrupts bits are acknolwedged. 
 *        It is intended for this generic ISR to be called by a user-provided ISR (that is registered) initially,
 *        then to use the returned snapshot of interrupt status register as needed.
 * 
 * \param[in]  instance, an intel_vvp_core instance. Usually, this an instance from a structure derived from intel_vvp_core
 * \return     a bit field of the fired interrupts (read of irq status register)
 * \pre        instance is a valid intel_vvp_core_instance and was successfully initialized,
 *             and instance.irq_handle is a user initialized intel_vvp_core_interrupt_handle structure
 */
uint32_t intel_vvp_core_generic_isr(void *instance);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif  /* __INTEL_VVP_CORE_H__ */
