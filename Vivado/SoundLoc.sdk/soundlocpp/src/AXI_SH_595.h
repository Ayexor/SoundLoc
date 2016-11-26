/*------------------------------------------------------------------------------
 * AXI Lite Peripheral for Shift Registers 74xx595
 * Roy Seitz, 2016-10-10 (rseitz@hsr.ch)
 * Supports up to 4 8bit shift registers in dasy chain (32 Bit total width)
 * Unused data pins should be left unconnected. If one register is not fully
 * used (e.g. only 4 bits), remaining bits  are undefined.
 * => UNUSED DATA PINS MUST BE LEFT UNCONNECTED.
 *----------------------------------------------------------------------------
 * Usage:
 *  1.	Set Status register by calling AXI_SH_595_init()
 *  2.	Programm SH by calling AXI_SH_595_programm_sh()
 * (3.)	If needed, wait until programming is done (AXI_SH_595_ready()==1)
 *----------------------------------------------------------------------------
 * Register Description
 * REG 0: 	Write only register with data to write to the SH595
 * REG 1: 	write '1' to programm SH. 
 *			Read returns '1' if Logic is ready to accept Data
 * REG 2: 	Status Register (Read/Write)
 *				bit 0:	Low active reset
 *				bit 1:	Low active output enable (if C_USE_OE_N = true)
 *----------------------------------------------------------------------------
 * Constants:
 *	AXI_SH_595_DATA_OFFSET:			Offset of data register (REG 0).
 *									Read / Write register containing Data to 
 *									write to SH
 *	AXI_SH_595_START_READY_OFFSET:	Offset of Start / Ready register (REG 1)
 *									Read returns Ready Flag
 *									Write '1' starts programming of SH
 *	AXI_SH_595_STATUS_OFFSET:		Offset of Status register (REG 2)
 * 									Bit 0: RSTn, Bit1: OEn
 *
 *----------------------------------------------------------------------------
 */
#ifndef AXI_SH_595_H
#define AXI_SH_595_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xil_io.h"
#include "xstatus.h"

#define AXI_SH_595_DATA_OFFSET 0
#define AXI_SH_595_START_READY_OFFSET 4
#define AXI_SH_595_STATUS_OFFSET 8

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a AXI_SH_595 register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the AXI_SH_595device.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void AXI_SH_595_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define AXI_SH_595_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((int)(BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a AXI_SH_595 register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the AXI_SH_595 device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 AXI_SH_595_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define AXI_SH_595_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((int)(BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Initialize device.
 * 
 * @param 	mask	mask written to satus register
 *					| Bit |      Purpose             | Default |
 *					|   0 | Low active reset         |    0    |
 *					|   1 | Low active output Enable |    0    | 
 *
 * @return	returns 0 if initialization was successfull;
 */
int AXI_SH_595_init(void * baseaddr_p, uint32_t mask);

/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the AXI_SH_595 instance to be worked on.
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
//XStatus AXI_SH_595_Reg_SelfTest(void * baseaddr_p);

/**
 *
 * Start Device and programm shift registers
 * 
 * Initializes programming sequence. DATA_REG is set to data and
 * data transfer is started.
 * 
 * If shift register is set to less than 32 bit, only the corresponding 
 * number of LSB's are sent. (e.g. with 10 bits, only data & 0x3FF)
 * 
 * While device is busy, AXI_SH_595_ready() returns 0
 *
 * @param   baseaddr_p is the base address of the AXI_SH_595 instance to be worked on.
 *
 * @param	data is the data to be written to the SH_595.
 * 
 * @note	Call AXI_SH_595_ready() before calling AXI_SH_595_programm_sh().
 *			If AXI_SH_595_programm_sh() is called while Device is busy results
 *			in undefined behavior.
 *
 */
void AXI_SH_595_programm_sh(void * baseaddr_p, uint32_t data);

/**
 *
 * Check wheter shift register block is ready to start programming.
 * 
 * While state machine is running, AXI_SH_595_ready() returns 0.
 * Calling AXI_SH_595_programm_sh() while device is busy results in undefined behavior.
 *
 * @param   baseaddr_p is the base address of the AXI_SH_595 instance to be worked on.
 *
 */
uint32_t AXI_SH_595_ready(void * baseaddr_p);

#endif // AXI_SH_595_H
