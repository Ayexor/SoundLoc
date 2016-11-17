/*------------------------------------------------------------------------------
 * AXI Lite Peripheral for 1st Order CIC decimation filter with
 * DSM bit stream as input
 * Roy Seitz, 2016-11-14 (rseitz@hsr.ch)
 * Decimation can be set from 0 to 2^D_WIDTH - 1.
 * Value format still is 32Bit signed. Note that this is independent of D_WIDTH
 * set in VHDL. D_WIDTH only affects width of VHDL internal registers.
 * AXI still operates on 32Bit width Data.
 *----------------------------------------------------------------------------
 * Usage:
 *  1.	Set Status register by SDM_DEZI_init()
 *  2.	Set decimation by calling SDM_DEZI_setDezimation()
 * (3.)	If needed, get value by calling SDM_DEZI_getVal()
 *----------------------------------------------------------------------------
 * Register Description
 * REG 0: 	Status Register (Read/Write)
 *				bit 0:	High active run (rst when '0')
 *				bit 1:	High active invert bitstream
 *				bit 2: 	Enable Interrupt irq_new_val
 * REG 1: 	Decimation Register
 * REG 2: 	Value Register
 *				Contains actual 32bit signed value
 *----------------------------------------------------------------------------
 */
#ifndef SDM_DECIMATOR_H
#define SDM_DECIMATOR_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xil_io.h"
#include "xstatus.h"

#define SDM_DECIMATOR_S_AXI_REG0_STATUS_OFFSET 0
#define SDM_DECIMATOR_S_AXI_REG1_DECIMATION_OFFSET 4
#define SDM_DECIMATOR_S_AXI_REG2_VALUE_OFFSET 8

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a SDM_DECIMATOR register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the SDM_DECIMATORdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void SDM_DECIMATOR_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define SDM_DECIMATOR_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a SDM_DECIMATOR register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the SDM_DECIMATOR device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 SDM_DECIMATOR_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define SDM_DECIMATOR_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/**
 *
 * Set Status Reg (REG0) to MASK
 *
 * @param   BaseAddress is the base address of the SDM_DECIMATOR device.
 * @param   Mask are the bits to write into Status Register (REG0)
 *
 */
void SDM_DECIM_setStatus(int BaseAddress, int Status);

/**
 *
 * Get Status Reg (REG0) to MASK
 *
 * @param   BaseAddress is the base address of the SDM_DECIMATOR device.
 *
 * @return  Content of Status Register (REG0)
 *
 */
int SDM_DECIM_getStatus(int BaseAddress);

/**
 *
 * Set decimation to Decimation
 *
 * @param   BaseAddress is the base address of the SDM_DECIMATOR device.
 * @param   Decimation is the value to be written to REG1
 *
 */
void SDM_DECIM_setDecimation(int BaseAddress, unsigned int decimation);

/**
 *
 * Get actual decimation (REG1)
 *
 * @param   BaseAddress is the base address of the SDM_DECIMATOR device.
 *
 * @return  Decimation (REG1)
 *
 */
unsigned int SDM_DECIM_getDecimation(int BaseAddress);

/**
 *
 * Get actual value (REG2)
 *
 * @param   BaseAddress is the base address of the SDM_DECIMATOR device.
 *
 * @return  Decimated 32bit signed Value (REG2)
 *
 */
int SDM_DECIM_geVal(int BaseAddress);

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the SDM_DECIMATOR instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus SDM_DECIMATOR_Reg_SelfTest(void * baseaddr_p);

#endif // SDM_DECIMATOR_H
