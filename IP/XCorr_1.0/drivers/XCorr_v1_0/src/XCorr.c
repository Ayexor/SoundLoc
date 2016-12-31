

/***************************** Include Files *******************************/
#include "XCorr.h"

/************************** Function Definitions ***************************/

void XCORR_Init(int BaseAddress, int ReturnImm){
	XCORR_mWriteReg(BaseAddress, XCORR_REG0_CLEAR_RAM_OFFSET, 0b1); // clear RAM
	
	if(ReturnImm)
		return;
	
	while(XCORR_mReadReg(BaseAddress, 0)) // wait until ram is cleared
		;
}

void XCORR_GetTau(int BaseAddress, s32* tau01, s32* tau02){
	*tau01 = XCORR_mReadReg(BaseAddress, XCORR_REG1_XCORR01_OFFSET); // read xcorr01
	*tau02 = XCORR_mReadReg(BaseAddress, XCORR_REG2_XCORR02_OFFSET); // read xcorr02
}