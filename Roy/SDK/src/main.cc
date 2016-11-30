/*
 * Empty C++ Application
 */

#include "xil_printf.h"
//#include <iostream>
#include "leddisplay.h"
#include "xcorr.h"

#define CNT_MEAN 50


int main()
{
	s32 tau01, tau02, cnt, tau01_m, tau02_m;
	XCORR_Init();
	LedDisplay_Init();

	while(1)
	{
		tau01_m = 0;
		tau02_m = 0;
		for (cnt = CNT_MEAN; cnt; --cnt){
			XCORR_GetTau(&tau01, &tau02);
			tau01_m += tau01;
			tau02_m += tau02;
		}
		tau01 = tau01_m/CNT_MEAN;
		tau02 = tau02_m/CNT_MEAN;
		LedDisplay_Tau((double)tau01, (double)tau02);
//		std::cout << "tau01: " << tau01 << ", tau02: " << tau02 << std::endl;
//		for (volatile int delay = 1e5; --delay; )
//				;
	}
	return 0;
}
