

/***************************** Include Files *******************************/
#include "SDM_Dezimator.h"

/************************** Function Definitions ***************************/

void SDM_DECIM_setStatus(int BaseAddress, int Status){
	SDM_DECIMATOR_mWriteReg(BaseAddress, SDM_DECIMATOR_S_AXI_REG0_STATUS_OFFSET, Status);
}

int SDM_DECIM_getStatus(int BaseAddress){
	return SDM_DECIMATOR_mReadReg(BaseAddress, SDM_DECIMATOR_S_AXI_REG0_STATUS_OFFSET);
}

void SDM_DECIM_setDecimation(int BaseAddress, unsigned int Decimation){
	SDM_DECIMATOR_mWriteReg(BaseAddress, SDM_DECIMATOR_S_AXI_REG1_DECIMATION_OFFSET, Decimation);
}

unsigned int SDM_DECIM_getDecimation(int BaseAddress){
	return SDM_DECIMATOR_mReadReg(BaseAddress, SDM_DECIMATOR_S_AXI_REG1_DECIMATION_OFFSET);
}

int SDM_DECIM_geVal(int BaseAddress){
	return SDM_DECIMATOR_mReadReg(BaseAddress, SDM_DECIMATOR_S_AXI_REG2_VALUE_OFFSET);
}
