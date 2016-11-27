/*
 * leddisplay.cc
 *
 *  Created on: Nov 26, 2016
 *      Author: marco
 */

#include <iostream>
#include "xgpio.h"
#include "AXI_SH_595.h"
#include "leddisplay.h"

#define SH_ADDR (void*)XPAR_AXI_SH_595_0_S_AXI_BASEADDR
//volatile unsigned int cnt, val, idx=0x5555;		// FIXME get rid of these
XGpio led;

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

void LedDisplay_Direction(double direction)
{
	uint32_t val = 0;
	double halfstep = 5.625;

	// FIXME solve with algorithm?
	if(direction >= 360.0) std::cout << "LedDisplay_Direction: angle too big" << std::endl;
	else if(direction >= (360-1*halfstep)) val |= (1<<7);
	else if(direction >= (360-3*halfstep)) val |= (3<<7);
	else if(direction >= (360-5*halfstep)) val |= (1<<8);
	else if(direction >= (360-7*halfstep)) val |= (3<<8);
	else if(direction >= (360-9*halfstep)) val |= (1<<9);
	else if(direction >= (360-11*halfstep)) val |= (3<<9);
	else if(direction >= (360-13*halfstep)) val |= (1<<10);
	else if(direction >= (360-15*halfstep)) val |= (3<<10);
	else if(direction >= (360-17*halfstep)) val |= (1<<11);
	else if(direction >= (360-19*halfstep)) val |= (3<<11);
	else if(direction >= (360-21*halfstep)) val |= (1<<12);
	else if(direction >= (360-23*halfstep)) val |= (3<<12);
	else if(direction >= (360-25*halfstep)) val |= (1<<13);
	else if(direction >= (360-27*halfstep)) val |= (3<<13);
	else if(direction >= (360-29*halfstep)) val |= (1<<14);
	else if(direction >= (360-31*halfstep)) val |= (3<<14);
	else if(direction >= (360-33*halfstep)) val |= (1<<15);
	else if(direction >= (360-35*halfstep)) val |= (1<<15) | (1<<0);
	else if(direction >= (360-37*halfstep)) val |= (1<<0);
	else if(direction >= (360-39*halfstep)) val |= (3<<0);
	else if(direction >= (360-41*halfstep)) val |= (1<<1);
	else if(direction >= (360-43*halfstep)) val |= (3<<1);
	else if(direction >= (360-45*halfstep)) val |= (1<<2);
	else if(direction >= (360-47*halfstep)) val |= (3<<2);
	else if(direction >= (360-49*halfstep)) val |= (1<<3);
	else if(direction >= (360-51*halfstep)) val |= (3<<3);
	else if(direction >= (360-53*halfstep)) val |= (1<<4);
	else if(direction >= (360-55*halfstep)) val |= (3<<4);
	else if(direction >= (360-57*halfstep)) val |= (1<<5);
	else if(direction >= (360-59*halfstep)) val |= (3<<5);
	else if(direction >= (360-61*halfstep)) val |= (1<<6);
	else if(direction >= (360-63*halfstep)) val |= (3<<6);
	else if(direction >= (360-64*halfstep)) val |= (1<<7);
	else std::cout << "LedDisplay_Direction: angle is probably negative" << std::endl;


	while(!AXI_SH_595_ready(SH_ADDR));
	AXI_SH_595_programm_sh(SH_ADDR, val);
}
