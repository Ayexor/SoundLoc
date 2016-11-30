/*
 * xcorr.cc
 *
 *  Created on: Nov 28, 2016
 *      Author: marco
 */

//#include <iostream>
#include "xcorr.h"
#include "../drivers/SDM_Decimator_v1_0/src/SDM_Decimator.h"
#include "xgpio.h"
#include "../drivers/XCorr_v1_0/src/XCorr_l.h"

#define DECIMATION		28		// hat mal funktioniert mit 1kS buffer, 3rd order, R=20 und 2 discard bits, f_bs = 100/31 MHz
#define ORDER			3		// funktioniert gut mit 8kS buffer, 2nd order, R = 64, f_bs = 100/31 MHz und ohne discard bits
#define XCORR_TRESHOLD	50000	// max delay = 42mm / (340 m/s) * f_sample

// hardware defined defines
#define IRQ_ENA			4 //3. bit
#define TAU_ADDR_WIDTH	6
#define CIC				XPAR_CIC_S_AXI_BASEADDR
#define XCORR			XPAR_XCORR_0_S_AXI_BASEADDR
// calculated defines
#define TAU_CNT			(TAU_MAX - TAU_MIN + 1)
#define TAU_MIN			(1-(1<<(TAU_ADDR_WIDTH-1)))
#define TAU_MAX			((1<<(TAU_ADDR_WIDTH-1))-1)

static XGpio irqPolled;

void XCORR_Init(void) {
	SDM_DECIM_setStatus(CIC, 0x0); // reset
	XGpio_Initialize(&irqPolled, XPAR_IRQ_DEVICE_ID);
	XGpio_InterruptGlobalEnable(&irqPolled);

	SDM_DECIM_setStatus(CIC, ORDER | IRQ_ENA); // setup CIC
	SDM_DECIM_setDecimation(CIC, DECIMATION);

	XCORR_mWriteReg(XCORR, 0, 0b1); // clear correlation (RAM)
	for (int delay = 12 * 1024 * 2; delay; --delay)
		;	// wait cycles to clear RAM  (*2 just to be sure)
	XCORR_mWriteReg(XCORR, 0, 0b0); // start correlation
}

void XCORR_GetTau(s32* tau01, s32* tau02) {
	int corr01[TAU_CNT];
	int corr02[TAU_CNT];
	int idx, irq_flag;
	double treshold01, treshold02;
	s32 maxidx01, maxidx02;

	XGpio_InterruptEnable(&irqPolled, 1); // enable interrupt
	XGpio_InterruptClear(&irqPolled, 1);
	irq_flag = 0;

	for (volatile int delay = DECIMATION * 40 * 12; delay; --delay)
		;

	do {
//		for (int loop_cnt = 100; loop_cnt; --loop_cnt) { // debug print values
		while (!irq_flag) {
			irq_flag = XGpio_InterruptGetStatus(&irqPolled); // wait on new valid correlation data
		}

		for (idx = TAU_MIN; idx <= TAU_MAX; idx++) {
			s32 addr = 0b0011111100 & (4 * idx);
			corr01[idx - TAU_MIN] = XCORR_mReadReg(XCORR, 0b1000000000 | addr); // read xcorr01
			corr02[idx - TAU_MIN] = XCORR_mReadReg(XCORR, 0b1100000000 | addr); // read xcorr02
		}
//			for (idx = TAU_MIN; idx <= TAU_MAX; idx++) {
//				std::cout << corr01[idx - TAU_MIN] << ","
//						<< corr02[idx - TAU_MIN] << std::endl;
//			}
		XGpio_InterruptClear(&irqPolled, 1);
		XGpio_InterruptDisable(&irqPolled, 1);

		maxidx01 = TAU_MIN;
		maxidx02 = TAU_MIN;
		for (idx = TAU_MIN; idx <= TAU_MAX; idx++) {
			if (corr01[idx - TAU_MIN] > corr01[maxidx01 - TAU_MIN])
				maxidx01 = idx;
			if (corr02[idx - TAU_MIN] > corr02[maxidx02 - TAU_MIN])
				maxidx02 = idx;
		}
//		}
//		while (1)
//			; //debug end
		if (!(maxidx01 | maxidx02)) {
			treshold01 = 0.25 * treshold01 + 0.5 * corr01[-TAU_MIN];
			treshold02 = 0.25 * treshold02 + 0.5 * corr02[-TAU_MIN];
		}

		treshold01 =
				(treshold01 > XCORR_TRESHOLD ? treshold01 : XCORR_TRESHOLD);
		treshold02 =
				(treshold02 > XCORR_TRESHOLD ? treshold02 : XCORR_TRESHOLD);
//		treshold = 0;
	} while ((corr01[maxidx01 - TAU_MIN] < treshold01)
			|| (corr02[maxidx02 - TAU_MIN] < treshold02)
			|| (!(maxidx01 | maxidx02)));

//	std::cout << "xcorr01_max: " << corr01[maxidx01 - TAU_MIN]
//			<< " xcorr02_max: " << corr02[maxidx02 - TAU_MIN] << std::endl;

	*tau01 = maxidx01;
	*tau02 = maxidx02;
}
