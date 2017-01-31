#include "xparameters.h"
#include "irq.h"
#include "SDM.h"
#include "SDM_Decimator.h"
#include "leddisplay.h"
#include "xxcorr.h"
#include "uart.h"

#define SAMPLE_CNT		100000
#define DELAY			30001

#define CNT_MEAN 1

//s16 data[5*SAMPLE_CNT];
s16 data[5 * SAMPLE_CNT];

void micLog(void) {
	int cnt;

//	sdmReset();
//	for(volatile int delay = 1000; --delay; );

	sdmInit();

	irqEna();

	for (volatile int delay = DELAY; --delay;)
		irqWait();

//	xil_printf("Start Logging...\n");
	for (cnt = 0; cnt < SAMPLE_CNT; ++cnt) {
		irqWait();
		data[3 * cnt] = sdmGetMic(0) / 8;
		data[3 * cnt + 1] = sdmGetMic(1) / 8;
		data[3 * cnt + 2] = sdmGetMic(2) / 8;
//		sdmGetMics(&data[3*cnt]);
	}
	irqDis();

//	xil_printf("Start Sending...\n");

	uartSend((u8*) data, sizeof(s16) * 3 * SAMPLE_CNT);
	waitTxEmpty();

//	for(cnt = 0; cnt < SAMPLE_CNT; ++cnt){
//		xil_printf("%d,%d,%d\n", data[3*cnt], data[3*cnt+1], data[3*cnt+2]);
//	}
}

void corrLog(void) {
	int cnt;
	int tau[2];

	sdmReset();
//	XCORR_Init(XCORR, 0);
	sdmInit();

	irqEna();
//	for(volatile int delay = DELAY; --delay; )
//		irqWait();

	for (cnt = 0; cnt < SAMPLE_CNT; ++cnt) {
		irqWait();

//		tau[0] = XCORR_mReadReg(XCORR, 0x4); // read xcorr01
//		tau[1] = XCORR_mReadReg(XCORR, 0x8); // read xcorr02
//		xil_printf("%d,%d\n", tau01, tau02);
		uartSend((u8*) tau, sizeof(tau));
	}
	irqDis();

}

void dataLog(void) {
	int cnt;
	s32 tau01, tau02, mic0, mic1, mic2;

//	sdmReset();
//	for(volatile int delay = 1000; --delay; );

	sdmInit();

//	XCORR_Init(XCORR, TRUE);

	irqEna();

	for (volatile int delay = DELAY; --delay;)
		irqWait();

//	XCORR_Init(XCORR, FALSE);

	xil_printf("Start Logging...\n");
	for (cnt = 0; cnt < SAMPLE_CNT; ++cnt) {
		irqWait();
		sdmGetMics(&mic0, &mic1, &mic2);
//		tau01 = XCORR_mReadReg(XCORR, 0x4); // read xcorr01
//		tau02 = XCORR_mReadReg(XCORR, 0x8); // read xcorr02

		data[5 * cnt] = mic0;
		data[5 * cnt + 1] = mic1;
		data[5 * cnt + 2] = mic2;
		data[5 * cnt + 3] = tau01;
		data[5 * cnt + 4] = tau02;
	}
	irqDis();

	for (cnt = 0; cnt < SAMPLE_CNT; ++cnt) {
		xil_printf("%d,%d,%d,%d,%d\n", data[5 * cnt], data[5 * cnt + 1],
				data[5 * cnt + 2], data[5 * cnt + 3], data[5 * cnt + 4]);
	}
}

void soundLoc() {
	register s32 cnt;
	int tau[2];
	float tau01_m, tau02_m;
	XXcorr xcorr;

	xil_printf("SoundLoc started...\n");
	sdmInit();
	LedDisplay_Init();
	irqEna();
	XXcorr_Initialize(&xcorr, XPAR_XCORR_DEVICE_ID);
	XXcorr_Set_treshold(&xcorr, 20000);
	xil_printf("Initialize done...\n");

//	XXcorr_Start(&xcorr);

	while (1) {
		tau01_m = 0.0f;
		tau02_m = 0.0f;
		for (cnt = CNT_MEAN; cnt; --cnt) {
//			xil_printf("Get Taus...\n");
			irqWait();

			do {
				tau[0] = XXcorr_Get_tau_0(&xcorr);
				tau[1] = XXcorr_Get_tau_1(&xcorr);
			} while (!(tau[0] || tau[1]));
			xil_printf("Got Taus: [%9d, %9d]\n", tau[0], tau[1]);
			tau01_m = tau01_m + (float) tau[0];
			tau02_m = tau02_m + (float) tau[1];
		}

//		xil_printf("Display Taus...\n");
		LedDisplay_Tau(tau01_m, tau02_m);
//		xil_printf("Display updated: tau01 = %5d and tau02 = %5d\n", (int)tau01_m, (int)tau02_m);
	}
	irqDis();
}
