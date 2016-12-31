
#ifndef XCORR_H
#define XCORR_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xil_io.h"
#include "xstatus.h"

#define XCORR_REG0_CLEAR_RAM_OFFSET 0
#define XCORR_REG1_XCORR01_OFFSET 4
#define XCORR_REG2_XCORR02_OFFSET 8


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a XCORR register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the XCORRdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void XCORR_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define XCORR_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a XCORR register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the XCORR device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 XCORR_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define XCORR_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/**
 *
 * Initialize XCorr and clear internal RAM.
 *
 * @param   BaseAddress is the base address of the XCORR device.
 * @param   if ReturnImm is 0, the function does not return until
 *          the internal RAM is cleared
 *
 * @return  None.
 *
 */
void XCORR_Init(int BaseAddress, int ReturnImm);

/**
 *
 * Read the two Taus from the XCORR device.
 *
 * @param   BaseAddress is the base address of the XCORR device.
 * @param   tau01 and tau02 are pointers where the values are to be stored.
 *
 * @return  None.
 *
 */
void XCORR_GetTau(int BaseAddress, s32* tau01, s32* tau02);

#endif // XCORR_H
