/*
 * Empty C++ Application
 */

#include "xil_printf.h"
#include <iostream>
#include "leddisplay.h"
#include "xcorr.h"

int main()
{
	s32 tau01, tau02;
	XCORR_Init();
	LedDisplay_Init();

	while(1)
	{
		XCORR_GetTau(&tau01, &tau02);
		LedDisplay_Tau((double)tau01, (double)tau02);
//		for (volatile int delay = 1e7; --delay; )
//				;
	}
	return 0;
}
