/*
 * SDM.cc
 *
 *  Created on: 29.12.2016
 *      Author: Roy
 */

#include "xparameters.h"
#include "SDM.h"
#include "SDM_Decimator.h"

#define DECIMATION		70
#define ORDER			3
#define POST_DIVIDE		0x600	// 0x100 to 0xf00
#define IIR_ENA			0x8		// 0x8 or 0x0
#define IIR_SR			0x80	// 0x10 to 0xf0

#define IRQ_ENA			0x4 	//3. bit
#define SDM_STATUS		(ORDER | IRQ_ENA | IIR_ENA | IIR_SR | POST_DIVIDE)
#define CIC				XPAR_SDM_DECIMATOR_S_AXI_BASEADDR


void sdmReset(void){
	SDM_DECIM_setStatus(CIC, 0x0); // reset
}

void sdmInit(){
	SDM_DECIM_setStatus(CIC, SDM_STATUS); // setup decimation
	SDM_DECIM_setDecimation(CIC, DECIMATION);
}

void sdmGetMics(s32* mic0, s32* mic1, s32* mic2){
	*mic0 = SDM_DECIM_getValue(CIC, 0);
	*mic1 = SDM_DECIM_getValue(CIC, 1);
	*mic2 = SDM_DECIM_getValue(CIC, 2);
}

void sdmGetMics(s32* mic){
	for (int idx = 3; idx--; )
		mic[idx] = SDM_DECIM_getValue(CIC, idx);
}

int sdmGetMic(int micNr){
	return SDM_DECIM_getValue(CIC, micNr);
}
