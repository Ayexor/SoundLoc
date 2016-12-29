
#include "xparameters.h"
#include "irq.h"
#include "SDM.h"
#include "SDM_Decimator.h"
#include "leddisplay.h"
#include "xcorr.h"


#define SAMPLE_CNT		1000
#define DELAY			100000

#define CNT_MEAN 50

s32 data[3*SAMPLE_CNT];

void micLog(void){
	int cnt;

	sdmReset();
	for(volatile int delay = 1000; --delay; );

	sdmInit();

	irqEna();

	for(volatile int delay = DELAY; --delay; )
		irqWait();

	for(cnt = 0; cnt < SAMPLE_CNT; ++cnt){
		irqWait();
		sdmGetMics(&data[3*cnt]);
//		data[3*cnt] = SDM_DECIM_getValue(CIC, 0);
//		data[3*cnt+1] = SDM_DECIM_getValue(CIC, 1);
//		data[3*cnt+2] = SDM_DECIM_getValue(CIC, 2);
	}
	irqDis();

	for(cnt = 0; cnt < SAMPLE_CNT; ++cnt){
		xil_printf("%d,%d,%d\n", data[3*cnt], data[3*cnt+1], data[3*cnt+2]);
	}
}

void soundLoc(){
	s32 tau01, tau02, cnt;
	float tau01_m, tau02_m;

	xil_printf("SoundLoc started...\n");
	XCORR_Init();
	sdmInit();
	LedDisplay_Init();
	xil_printf("Initialize done...\n");
	while(1)
	{
		tau01_m = 0.0f;
		tau02_m = 0.0f;
		for (cnt = CNT_MEAN; cnt; --cnt){
//			xil_printf("Get Taus...\n");
			XCORR_GetTau(&tau01, &tau02);
			tau01_m = tau01_m + tau01;
			tau02_m = tau02_m + tau02;
		}
//		tau01_m = tau01_m/CNT_MEAN;
//		tau02_m = tau02_m/CNT_MEAN;
//		xil_printf("Display Taus...\n");
		LedDisplay_Tau(tau01_m, tau02_m);
		xil_printf("Display updated: tau01 = %5d and tau02 = %5d\n", (int)tau01_m, (int)tau02_m);
	}

}
