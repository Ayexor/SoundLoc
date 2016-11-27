

/***************************** Include Files *******************************/
#include "AXI_SH_595.h"

/************************** Function Definitions ***************************/

/**
 *
 * Initialize device.
 * 
 * @param 	mask	mask written to satus register
 *					--------------------------------------------
 *					| Bit |      Purpose             | Default |
 *					|   0 | Low active reset         |    0    |
 *					|   1 | Low active output Enable |    0    | 
 *					--------------------------------------------
 *
 * @return	returns 0 if initialization was successfull;
 */
int AXI_SH_595_init(void * baseaddr_p, uint32_t mask){
	AXI_SH_595_mWriteReg(baseaddr_p, AXI_SH_595_STATUS_OFFSET, mask);
	
	return AXI_SH_595_mReadReg(baseaddr_p, AXI_SH_595_STATUS_OFFSET) == mask;
}

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
void AXI_SH_595_programm_sh(void * baseaddr_p, uint32_t data){
	AXI_SH_595_mWriteReg(baseaddr_p, AXI_SH_595_DATA_OFFSET, data);
	AXI_SH_595_mWriteReg(baseaddr_p, AXI_SH_595_START_READY_OFFSET, 1);
}

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
uint32_t AXI_SH_595_ready(void * baseaddr_p){
	return AXI_SH_595_mReadReg(baseaddr_p, AXI_SH_595_START_READY_OFFSET);
}
