/*
 * SDM.h
 *
 *  Created on: 29.12.2016
 *      Author: Roy
 */

#ifndef SRC_SDM_H_
#define SRC_SDM_H_

#include "xil_types.h"

void sdmReset(void);
void sdmInit();

void sdmGetMics(s32* mic0, s32* mic1, s32* mic2);
void sdmGetMics(s32* mic);
int sdmGetMic(int micNr);



#endif /* SRC_SDM_H_ */
