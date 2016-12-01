/*------------------------------------------------------------------------------
 * AXI Lite Peripheral for CIC decimation filter 
 * with programmable order up to 3.
 *
 * Roy Seitz, 2016-11-14 (rseitz@hsr.ch)
 * Decimation can be set from 0 to 2^D_WIDTH - 1.
 * Value format still is 32Bit signed. Note that this is independent of D_WIDTH
 * set in VHDL. D_WIDTH only affects width of VHDL internal registers.
 * AXI still operates on 32Bit width Data.
 *----------------------------------------------------------------------------
 * Usage:
 *  1.	Set status register by SDM_DECIM_setStatus()
 *  2.	Set decimation by calling SDM_DECIM_setDecimation()
 * (3.)	If needed, get value by calling SDM_DECIM_getValue()
 *----------------------------------------------------------------------------
 * Register description
 * REG 0: 	Status register (read/write)
 *				bit 1:0:	Order select
 *							Order 0 disables filter
 *				bit 2:		Enable interrupt on new value
 *				bit 3:		Enable IIR DC blocker
 *				bit 7:4:	IIR pole: by 1-2**unsigned(REG0(7:4))
 *				bit 11:8:	CIC post divide by 2**unsigned(REG0(11:8))
 * REG 1: 	Decimation register (unsigned D_WIDTH bit)
 * REG 2:4	32bit signed value register for mic0 to mic2
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
#define SDM_DECIMATOR_S_AXI_REG2_VALUE0_OFFSET 8
#define SDM_DECIMATOR_S_AXI_REG2_VALUE1_OFFSET 12
#define SDM_DECIMATOR_S_AXI_REG2_VALUE2_OFFSET 16
#define SDM_DECIMATOR_MIC1 1
#define SDM_DECIMATOR_MIC2 0
#define SDM_DECIMATOR_MIC3 2

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
 * Get Status Reg (REG0)
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
 * @param   Mic is the Microphon (0,1 or 2) that's value is to be read. 
 *				values other than 0 to 2 return 0
 *
 * @return  Decimated 32bit signed Value
 *
 */
int SDM_DECIM_getValue(int BaseAddress, int Mic);

#endif // SDM_DECIMATOR_H
