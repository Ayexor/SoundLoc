/*
 * xcorr.h
 *
 *  Created on: Nov 28, 2016
 *      Author: marco
 */

#ifndef XCORR_H_
#define XCORR_H_

#include "xil_types.h"

/* Initialize the hardware and clear the buffers */
extern void XCORR_Init(void);

/* Get the latest tau from the cross-correlation */
extern void XCORR_GetTau(s32* tau01, s32* tau02);

#endif /* XCORR_H_ */
