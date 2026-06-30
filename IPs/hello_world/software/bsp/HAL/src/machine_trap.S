/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2020-2021 Intel Corporation, Santa Clara, California, USA.    *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

/*
 * This is the base machine-mode trap exception handler for Nios V.  This only
 * saves the caller saved registers, any callee saved registers will be saved by
 * handle_trap, if needed.
*/ 

#include "linker.h"
#include "system.h"

    .section .exceptions.entry.label, "xa"

    .align 2

    .globl trap_vector
    .globl __alt_exception_stack_pointer
    .globl __alt_exception_stack_limit
    .type trap_vector, @function

trap_vector:

    /*
     * The code for detecting a likely fatal ECC exception is
     * linked here before the normal exception handler code if required.
     * This is handled by the linker script and putting that code
     * in the .exceptions.entry.ecc_fatal section.
     */

    /*
     * Now start the normal exception handler code.
     */

    .section .exceptions.entry, "xa"

    /* Determine architecture byte size */
#if __riscv_xlen == 32
    #define XBYTES 4
    #define XST sw
    #define XLD lw

    #define FBYTES 4
    #define FPST fsw
    #define FPLD flw
#else //__riscv_xlen == 64
    #define XBYTES 8
    #define XST sd
    #define XLD ld

#if __riscv_flen == 32
    #define FBYTES 4
    #define FPST fsw
    #define FPLD flw
#else //__riscv_flen == 64
    #define FBYTES 8
    #define FPST fsd
    #define FPLD fld
#endif
#endif

    /* Does the architecture have shadow registers? */
    /* TODO: replace this with variant definition
       Variant  ALT_CPU_NIOSV_CORE_VARIANT
       reserved  0
       M         1
       M_nopipe  2
       G         3
       C         4       
     */
#define NIOSV_M_ARCH 1
#define NIOSV_Mnopipe_ARCH 2
#define NIOSV_G_ARCH 3
#define NIOSV_C_ARCH 4
#if ALT_CPU_NIOSV_CORE_VARIANT == NIOSV_C_ARCH
    #define ALT_CPU_HAS_SRF 1
#elif ALT_CPU_NIOSV_CORE_VARIANT == NIOSV_G_ARCH
    #ifdef ALT_CPU_NUM_SRF_BANKS
        #if ALT_CPU_NUM_SRF_BANKS > 1
            #define ALT_CPU_HAS_SRF 1
        #endif
    #endif
#endif

/**
 * @brief ABI Calling Convention

 +----------+----------+----------------------------------+--------+----------+
 | Register | ABI Name | Description                      | Saver  | Shadowed |
 +----------+----------+----------------------------------+--------+----------+
 | x0       | zero     | Hardwired to zero                |  ---   | No       |
 | x1       | ra       | Return address                   | Caller | No       |
 | x2       | sp       | Stack pointer                    | Callee | No       |
 | x3       | gp       | Global pointer                   |  ---   | No       |
 | x4       | tp       | Thread pointer                   |  ---   | No       |
 | x5-x7    | t0-t2    | Temporaries                      | Caller | No       |
 | x8       | s0/fp    | Saved register/frame pointer     | Callee | RVE      |
 | x9       | s1       | Saved register                   | Callee | RVE      |
 | x10-x11  | a0-a1    | Function arguments/return values | Caller | RVE      |
 | x12-x15  | a2-a5    | Function arguments               | Caller | RVE      |
 | x16-x17  | a6-a7    | Function arguments               | Caller | Yes      |
 | x18-x27  | s2-s11   | Saved registers                  | Callee | Yes      |
 | x28-x31  | t3-t6    | Temporaries                      | Caller | Yes      |
 +----------+----------+----------------------------------+--------+----------+
 | f0-f7    | ft0-ft7  | FP temporaries                   | Caller | Yes      |
 | f8-f9    | fs0-fs1  | FP saved registers               | Callee | Yes      |
 | f10-f11  | fa0-fa1  | FP arguments/return values       | Caller | Yes      |
 | f12-f17  | fa2-fa7  | FP function arguments            | Caller | Yes      |
 | f18-f27  | fs2-fs11 | FP saved registers               | Callee | Yes      |
 | f28-f31  | ft8-ft11 | FP Temporaries                   | Caller | Yes      |
 +----------+----------+----------------------------------+--------+----------+

 */


#ifdef ALT_EXCEPTION_STACK

    /* Save callee saved registers s0, s1 */
    /* RVE No need to save these as they fall into the shadow register range for RVE */
#ifndef __riscv_e
    addi sp, sp, -2 * XBYTES
    XST  s0, 0(sp)
    XST  s1, XBYTES(sp)
#endif

    /* Compare against the exception stack bounds */    
    la s0, __alt_exception_stack_pointer
    la s1, __alt_exception_stack_limit
    bgtu sp, s0, not_nested_exc
    bltu sp, s1, not_nested_exc

nested_exc:
    /* This saves the stack pointer onto the stack to keep the loading of
       the stack pointer below the same for both cases (nested vs non-nested) */
    XST  sp, -XBYTES(sp)
    addi sp, sp, -XBYTES    
    j save_registers
    
not_nested_exc:
    /* Load the exception stack pointer into s0 */
    la s0, __alt_exception_stack_pointer - XBYTES
    
    /* Save the current stack pointer into the exception stack, and load the 
       exception stack pointer (s0 holds the memory address of the exception stack) */      
    XST sp, 0(s0)
    mv  sp, s0

#endif /* ALT_EXCEPTION_STACK */

save_registers:
    /* Save caller-saved registers on the stack */
#ifdef ALT_CPU_HAS_SRF

#ifdef __riscv_e
    addi sp, sp, -4 * XBYTES
#else //not RVE
    addi sp, sp, -10 * XBYTES
#endif

#else //no shadow registers

#ifdef __riscv_e
    addi sp, sp, -10 * XBYTES
#elif (__riscv_flen == 32 || __riscv_flen == 64)
    addi sp, sp, -(16 * XBYTES + 20 * FBYTES)
#else
    addi sp, sp, -16 * XBYTES
#endif

#endif


    /* rv32e, rv32i and rv32if */
    XST ra,  0 * XBYTES(sp)
    XST t0,  1 * XBYTES(sp)
    XST t1,  2 * XBYTES(sp)
    XST t2,  3 * XBYTES(sp)

    /* These are shadowd in RVE */
#ifdef __riscv_e
#ifndef ALT_CPU_HAS_SRF
    XST a0,  4 * XBYTES(sp)
    XST a1,  5 * XBYTES(sp)
    XST a2,  6 * XBYTES(sp)
    XST a3,  7 * XBYTES(sp)
    XST a4,  8 * XBYTES(sp)
    XST a5,  9 * XBYTES(sp)
#endif
#endif

    /* rv32i and rv32if */
#ifndef __riscv_e
    XST a0,  4 * XBYTES(sp)
    XST a1,  5 * XBYTES(sp)
    XST a2,  6 * XBYTES(sp)
    XST a3,  7 * XBYTES(sp)
    XST a4,  8 * XBYTES(sp)
    XST a5,  9 * XBYTES(sp)
    /* These are shadowed */
#ifndef ALT_CPU_HAS_SRF
    XST a6, 10 * XBYTES(sp)
    XST a7, 11 * XBYTES(sp)
    XST t3, 12 * XBYTES(sp)
    XST t4, 13 * XBYTES(sp)
    XST t5, 14 * XBYTES(sp)
    XST t6, 15 * XBYTES(sp)
#endif
#endif

    /* All floating point registers are shadowed */
#if (__riscv_flen == 32 || __riscv_flen == 64)
#ifndef ALT_CPU_HAS_SRF
    FPST ft0,  (16 * XBYTES +  0 * FBYTES)(sp)
    FPST ft1,  (16 * XBYTES +  1 * FBYTES)(sp)
    FPST ft2,  (16 * XBYTES +  2 * FBYTES)(sp)
    FPST ft3,  (16 * XBYTES +  3 * FBYTES)(sp)
    FPST ft4,  (16 * XBYTES +  4 * FBYTES)(sp)
    FPST ft5,  (16 * XBYTES +  5 * FBYTES)(sp)
    FPST ft6,  (16 * XBYTES +  6 * FBYTES)(sp)
    FPST ft7,  (16 * XBYTES +  7 * FBYTES)(sp)
    FPST ft8,  (16 * XBYTES +  8 * FBYTES)(sp)
    FPST ft9,  (16 * XBYTES +  9 * FBYTES)(sp)
    FPST ft10, (16 * XBYTES + 10 * FBYTES)(sp)
    FPST ft11, (16 * XBYTES + 11 * FBYTES)(sp)
    FPST fa0,  (16 * XBYTES + 12 * FBYTES)(sp)
    FPST fa1,  (16 * XBYTES + 13 * FBYTES)(sp)
    FPST fa2,  (16 * XBYTES + 14 * FBYTES)(sp)
    FPST fa3,  (16 * XBYTES + 15 * FBYTES)(sp)
    FPST fa4,  (16 * XBYTES + 16 * FBYTES)(sp)
    FPST fa5,  (16 * XBYTES + 17 * FBYTES)(sp)
    FPST fa6,  (16 * XBYTES + 18 * FBYTES)(sp)
    FPST fa7,  (16 * XBYTES + 19 * FBYTES)(sp)
#endif
#endif
   
    /* Call handle_trap to dispatch the correct handler, if available */
    csrr a0, mcause
    csrr a1, mepc
    csrr a2, mtval
    jal handle_trap
    csrw mepc, a0

    /* Restore caller-saved registers */

    /* rv32e, rv32i and rv32if */
    XLD ra,  0 * XBYTES(sp)
    XLD t0,  1 * XBYTES(sp)
    XLD t1,  2 * XBYTES(sp)
    XLD t2,  3 * XBYTES(sp)
    /* These registers are shadowed in RVE */
#ifdef __riscv_e
#ifndef ALT_CPU_HAS_SRF
    XLD a0,  4 * XBYTES(sp)
    XLD a1,  5 * XBYTES(sp)
    XLD a2,  6 * XBYTES(sp)
    XLD a3,  7 * XBYTES(sp)
    XLD a4,  8 * XBYTES(sp)
    XLD a5,  9 * XBYTES(sp)
#endif
#endif

    /* rv32i and rv32if */
#ifndef __riscv_e
    XLD a0,  4 * XBYTES(sp)
    XLD a1,  5 * XBYTES(sp)
    XLD a2,  6 * XBYTES(sp)
    XLD a3,  7 * XBYTES(sp)
    XLD a4,  8 * XBYTES(sp)
    XLD a5,  9 * XBYTES(sp)
    /* These registers are shadowed */
#ifndef ALT_CPU_HAS_SRF
    XLD a6, 10 * XBYTES(sp)
    XLD a7, 11 * XBYTES(sp)
    XLD t3, 12 * XBYTES(sp)
    XLD t4, 13 * XBYTES(sp)
    XLD t5, 14 * XBYTES(sp)
    XLD t6, 15 * XBYTES(sp)
#endif
#endif	

    /* All floating point registers are shadowed */
#if (__riscv_flen == 32 || __riscv_flen == 64)
#ifndef ALT_CPU_HAS_SRF
    FPLD ft0,  (16 * XBYTES +  0 * FBYTES)(sp)
    FPLD ft1,  (16 * XBYTES +  1 * FBYTES)(sp)
    FPLD ft2,  (16 * XBYTES +  2 * FBYTES)(sp)
    FPLD ft3,  (16 * XBYTES +  3 * FBYTES)(sp)
    FPLD ft4,  (16 * XBYTES +  4 * FBYTES)(sp)
    FPLD ft5,  (16 * XBYTES +  5 * FBYTES)(sp)
    FPLD ft6,  (16 * XBYTES +  6 * FBYTES)(sp)
    FPLD ft7,  (16 * XBYTES +  7 * FBYTES)(sp)
    FPLD ft8,  (16 * XBYTES +  8 * FBYTES)(sp)
    FPLD ft9,  (16 * XBYTES +  9 * FBYTES)(sp)
    FPLD ft10, (16 * XBYTES + 10 * FBYTES)(sp)
    FPLD ft11, (16 * XBYTES + 11 * FBYTES)(sp)
    FPLD fa0,  (16 * XBYTES + 12 * FBYTES)(sp)
    FPLD fa1,  (16 * XBYTES + 13 * FBYTES)(sp)
    FPLD fa2,  (16 * XBYTES + 14 * FBYTES)(sp)
    FPLD fa3,  (16 * XBYTES + 15 * FBYTES)(sp)
    FPLD fa4,  (16 * XBYTES + 16 * FBYTES)(sp)
    FPLD fa5,  (16 * XBYTES + 17 * FBYTES)(sp)
    FPLD fa6,  (16 * XBYTES + 18 * FBYTES)(sp)
    FPLD fa7,  (16 * XBYTES + 19 * FBYTES)(sp)
#endif
#endif

#ifdef ALT_CPU_HAS_SRF

#ifdef __riscv_e
    addi sp, sp, 4 * XBYTES
#else //not RVE
    addi sp, sp, 10 * XBYTES
#endif

#else //no shadow registers

#ifdef __riscv_e
    addi sp, sp, 10 * XBYTES
#elif (__riscv_flen == 32 || __riscv_flen == 64)
    addi sp, sp, (16 * XBYTES + 20 * FBYTES)
#else
    addi sp, sp, 16 * XBYTES
#endif

#endif


#ifdef ALT_EXCEPTION_STACK
    /* Load in the previous stack pointer */
    XLD s0, 0(sp)
    addi sp, sp, XBYTES
    mv sp, s0

    /* Load callee saved registers s0, s1 */
    /* RVE: No need to restore these, because we didn't need to save them */
#ifndef __riscv_e
    XLD s0, 0(sp)
    XLD s1, XBYTES(sp)
    addi sp, sp, 2 * XBYTES
#endif
#endif

    mret
