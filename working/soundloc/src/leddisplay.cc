/*
 * leddisplay.cc
 *
 *  Created on: Nov 26, 2016
 *      Author: marco
 */

#include <iostream>
#include <math.h>
#include "xparameters.h"
//#include "xgpio.h"
//#include "AXI_SH_595.h"
#include "../drivers/AXI_SH_595_v1_0/src/AXI_SH_595.h"
#include "leddisplay.h"


#define PI 3.14159265
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

void LedDisplay_Angle(double angle)
{
	uint32_t val = 0;
	double halfstep = 5.625;

	angle = 360.0 - angle;
//	if (angle < 0.0)
//		angle = 0.0;
//	else if (angle > 360.0)
//		angle = 360.0;

	while(angle < 0.0)
		angle +=360.0;

	while(angle > 360.0)
		angle -=360.0;


	// FIXME solve with algorithm?
	if(angle > 360.0) std::cout << "LedDisplay_Angle: angle is too big" << std::endl;
	else if(angle >= (360.0-1*halfstep)) val = (1<<7);
	else if(angle >= (360.0-3*halfstep)) val = (3<<7);
	else if(angle >= (360.0-5*halfstep)) val = (1<<8);
	else if(angle >= (360.0-7*halfstep)) val = (3<<8);
	else if(angle >= (360.0-9*halfstep)) val = (1<<9);
	else if(angle >= (360.0-11*halfstep)) val = (3<<9);
	else if(angle >= (360.0-13*halfstep)) val = (1<<10);
	else if(angle >= (360.0-15*halfstep)) val = (3<<10);
	else if(angle >= (360.0-17*halfstep)) val = (1<<11);
	else if(angle >= (360.0-19*halfstep)) val = (3<<11);
	else if(angle >= (360.0-21*halfstep)) val = (1<<12);
	else if(angle >= (360.0-23*halfstep)) val = (3<<12);
	else if(angle >= (360.0-25*halfstep)) val = (1<<13);
	else if(angle >= (360.0-27*halfstep)) val = (3<<13);
	else if(angle >= (360.0-29*halfstep)) val = (1<<14);
	else if(angle >= (360.0-31*halfstep)) val = (3<<14);
	else if(angle >= (360.0-33*halfstep)) val = (1<<15);
	else if(angle >= (360.0-35*halfstep)) val = ((1<<15) | (1<<0));
	else if(angle >= (360.0-37*halfstep)) val = (1<<0);
	else if(angle >= (360.0-39*halfstep)) val = (3<<0);
	else if(angle >= (360.0-41*halfstep)) val = (1<<1);
	else if(angle >= (360.0-43*halfstep)) val = (3<<1);
	else if(angle >= (360.0-45*halfstep)) val = (1<<2);
	else if(angle >= (360.0-47*halfstep)) val = (3<<2);
	else if(angle >= (360.0-49*halfstep)) val = (1<<3);
	else if(angle >= (360.0-51*halfstep)) val = (3<<3);
	else if(angle >= (360.0-53*halfstep)) val = (1<<4);
	else if(angle >= (360.0-55*halfstep)) val = (3<<4);
	else if(angle >= (360.0-57*halfstep)) val = (1<<5);
	else if(angle >= (360.0-59*halfstep)) val = (3<<5);
	else if(angle >= (360.0-61*halfstep)) val = (1<<6);
	else if(angle >= (360.0-63*halfstep)) val = (3<<6);
	else if(angle >= (360.0-64*halfstep)) val = (1<<7);
	else std::cout << "LedDisplay_Angle: angle is probably negative" << std::endl;


	while(!AXI_SH_595_ready(SH_ADDR));
	AXI_SH_595_programm_sh(SH_ADDR, val);
}

void LedDisplay_Coordinate(double x, double y)
{
	double angle = atan2 (-x,-y) * 180.0 / PI;
	angle += 180.0;
	if (angle < 0) angle = 0;	//FIXME why is this even necessary?
	std::cout << "LedDisplay_Coordinate: angle is " << angle << std::endl;
	LedDisplay_Angle(angle);
}

void LedDisplay_Tau(double tau12, double tau13)
{
	double angle = atan2(tau12, tau13)*180/PI + 90;
	//[-180..180] => [0..360]
	angle += 15*sin(2*PI/180*angle) + 2.2*sin(4*PI/180*angle);
	//std::cout << "LedDisplay_Coordinate: angle is " << angle << std::endl;
//	std::cout << tau12 << "," << tau13 << std::endl;
	LedDisplay_Angle(angle);
}
