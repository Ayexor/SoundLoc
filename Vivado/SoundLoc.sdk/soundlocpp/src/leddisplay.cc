/*
 * leddisplay.cc
 *
 *  Created on: Nov 26, 2016
 *      Author: marco
 */

#include "xgpio.h"
#include "AXI_SH_595.h"
#include "leddisplay.h"

#define SH_ADDR (void*)XPAR_AXI_SH_595_0_S_AXI_BASEADDR
volatile unsigned int cnt, val, idx=0x5555;
XGpio led;

void LedDisplay_Init(void)
{
	XGpio_Initialize(&led, XPAR_AXI_GPIO_0_DEVICE_ID);
	AXI_SH_595_init(SH_ADDR, 0x3);
	val = 5;
	XGpio_DiscreteWrite(&led, 1, val);
}

void LedDisplay_Rotate(void)
{
	while(1)
	{
		cnt = 50000000;
		while(--cnt);
		val ^= 0xf;
		XGpio_DiscreteWrite(&led, 1, val);
		AXI_SH_595_programm_sh(SH_ADDR, idx=~idx);
	}
}
