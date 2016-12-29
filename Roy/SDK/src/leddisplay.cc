/*
 * leddisplay.cc
 *
 *  Created on: Nov 26, 2016
 *      Author: marco
 */

//#include <iostream>
#include <math.h>
#include "xparameters.h"
//#include "xgpio.h"
//#include "AXI_SH_595.h"
#include "AXI_SH_595.h"
#include "leddisplay.h"

//#define USE_LED_INTERPOL

#define M_SQRT1_3 0.577350269189626f
#define SH_ADDR XPAR_SH_S_AXI_BASEADDR
//volatile unsigned int cnt, val, idx=0x5555;		// FIXME get rid of these
//XGpio led;

void LedDisplay_Init(void)
{
	//XGpio_Initialize(&led, XPAR_AXI_GPIO_0_DEVICE_ID);
	AXI_SH_595_init(SH_ADDR, 0x3);
	//val = 5;
	//XGpio_DiscreteWrite(&led, 1, val);
}

void LedDisplay_Rotate(void)
{
	while(1)
	{
		//cnt = 50000000;
		//while(--cnt);
		//val ^= 0xf;
		//XGpio_DiscreteWrite(&led, 1, val);
		//AXI_SH_595_programm_sh(SH_ADDR, idx=~idx);
	}
}

void LedDisplay_Angle(float angle)
{
	uint32_t val = 0;
#ifdef USE_LED_INTERPOL
	const float halfstep = 360.0f/64.0f;
	const float step = 360.0f/32.0f;
#else
	const float halfstep = 360.0f/32.0f;
	const float step = 360.0f/16.0f;
#endif
	int angleInt;

	// adding halfstep results in correct rounding
	angleInt = (int)((angle+halfstep)/step) + 3; // led 4 corresponds to angle 0 -> +3

	while(angleInt > 15)
		angleInt -= 16;
	while(angleInt < 0)
		angleInt += 16;

	xil_printf("angleInt: %d\n", angleInt);

	val = 1 << (angleInt);

	while(!AXI_SH_595_ready(SH_ADDR));
	AXI_SH_595_programm_sh(SH_ADDR, val);
}

void LedDisplay_Coordinate(float x, float y)
{
	float angle = atan2f(x,y) * 180.0f / (float)M_PI;
//	std::cout << "LedDisplay_Coordinate: angle is " << angle << std::endl;
	LedDisplay_Angle(angle);
}

void LedDisplay_Tau(float tau12, float tau13)
{
	float x, y, angle;

	x = tau13;
	y = 2.0f*M_SQRT1_3 * tau12 - M_SQRT1_3 * tau13;


	angle = atan2f(y,x)*180.0f/(float)M_PI + 180.0f;
	LedDisplay_Angle(angle);
}
