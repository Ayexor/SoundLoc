/*
 * xcorr.cc
 *
 *  Created on: Nov 28, 2016
 *      Author: marco
 */

#include "xparameters.h"
#include "xcorr.h"
#include <SDM_Decimator.h>
#include "irq.h"
//#include "XCorr_l.h"

#define DECIMATION		40
#define ORDER			3
//#define XCORR_TRESHOLD	1000.0f

// hardware defined defines
#define IRQ_ENA			4 //3. bit
#define TAU_ADDR_WIDTH	6
#define CIC				XPAR_SDM_DECIMATOR_S_AXI_BASEADDR
#define XCORR			XPAR_XCORR_S_AXI_BASEADDR
// calculated defines
#define TAU_MIN			(1-(1<<(TAU_ADDR_WIDTH-1)))
#define TAU_MAX			((1<<(TAU_ADDR_WIDTH-1))-1)
#define TAU_CNT			(TAU_MAX - TAU_MIN + 1)

#define XCORR_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XCORR_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))




void XCORR_Init(void) {
	XCORR_mWriteReg(XCORR, 0, 0b1); // clear correlation (RAM)
	for (volatile int delay = 16 * 1024 * 2; delay; --delay)
		;	// wait cycles to clear RAM  (*2 just to be sure)
	XCORR_mWriteReg(XCORR, 0, 0b0); // start correlation
}

void XCORR_GetTau(s32* tau01, s32* tau02) {
	int corr01[TAU_CNT];
	int corr02[TAU_CNT];
	int idx;
//	float treshold01, treshold02;
	s32 maxidx01, maxidx02;

	for (volatile int delay = DECIMATION * 40 * 12; delay; --delay)
		;

	irqEna();
	do {
		irqWait();

		for (idx = TAU_MIN; idx <= TAU_MAX; idx++) {
			s32 addr = 0x0FC & (4 * idx);
			corr01[idx - TAU_MIN] = XCORR_mReadReg(XCORR, 0x200 | addr); // read xcorr01
			corr02[idx - TAU_MIN] = XCORR_mReadReg(XCORR, 0x300 | addr); // read xcorr02
		}

//		for (idx = TAU_MIN; idx <= TAU_MAX; idx++)
//			std::cout << corr01[idx - TAU_MIN] << "," << corr02[idx - TAU_MIN] << std::endl;

		maxidx01 = TAU_MIN;
		maxidx02 = TAU_MIN;
		for (idx = TAU_MIN; idx <= TAU_MAX; idx++) {
			if (corr01[idx - TAU_MIN] > corr01[maxidx01 - TAU_MIN])
				maxidx01 = idx;
			if (corr02[idx - TAU_MIN] > corr02[maxidx02 - TAU_MIN])
				maxidx02 = idx;
		}

//		if (!(maxidx01 | maxidx02)) {
//			treshold01 = 0.5f * treshold01 + 0.25f * corr01[-TAU_MIN];
//			treshold02 = 0.5f * treshold02 + 0.25f * corr02[-TAU_MIN];
//		}

//		treshold01 =
//				(treshold01 > XCORR_TRESHOLD ? treshold01 : XCORR_TRESHOLD);
//		treshold02 =
//				(treshold02 > XCORR_TRESHOLD ? treshold02 : XCORR_TRESHOLD);
//		treshold = 0;
	} while (
//			(corr01[maxidx01 - TAU_MIN] < (int) treshold01)
//			||
//			(corr02[maxidx02 - TAU_MIN] < (int) treshold02)
//			||
			(!(maxidx01 | maxidx02))
			);
	irqDis();

//	std::cout << "xcorr01_max: " << corr01[maxidx01 - TAU_MIN]
//			<< " xcorr02_max: " << corr02[maxidx02 - TAU_MIN] << std::endl;

	*tau01 = maxidx01;
	*tau02 = maxidx02;
}

