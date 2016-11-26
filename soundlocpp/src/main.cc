/*
 * Empty C++ Application
 */

//#include <stdio.h>
//#include <sstream>
//#undef str
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "AXI_SH_595.h"
#include <iostream>

#include <Dense>

#define SH_ADDR (void*)XPAR_AXI_SH_595_0_S_AXI_BASEADDR

using namespace Eigen;

int main()
{
	Matrix2f m(2,2);
	m(0,0) = 3;
	m(1,0) = 2.5;
	m(0,1) = -1;
	m(1,1) = m(1,0) + m(0,1);
	//xil_printf(m);
	std::cout << m << std::endl;

	volatile unsigned int cnt, val, idx=0x5555;
	XGpio led;

	xil_printf("Hello World\n\r");

	XGpio_Initialize(&led, XPAR_AXI_GPIO_0_DEVICE_ID);
	AXI_SH_595_init(SH_ADDR, 0x3);

	val = 5;
	XGpio_DiscreteWrite(&led, 1, val);

	while(1)
	{
		cnt = 50000000;
	    while(--cnt);
	    val ^= 0xf;
	    XGpio_DiscreteWrite(&led, 1, val);
	    AXI_SH_595_programm_sh(SH_ADDR, idx=~idx);
	}
	return 0;
}
