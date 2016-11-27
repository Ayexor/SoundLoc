/*
 * Empty C++ Application
 */

//#include <stdio.h>
//#include <sstream>
//#undef str
#include "xil_printf.h"
#include "xparameters.h"
#include <iostream>
#include "leddisplay.h"

#include <Dense>

using namespace Eigen;

int main()
{
	double test = 0.0;

	Matrix2f m(2,2);
	m(0,0) = 3;
	m(1,0) = 2.5;
	m(0,1) = -1;
	m(1,1) = m(1,0) + m(0,1);
	std::cout << m << std::endl;

	xil_printf("Hello World\n\r");
	LedDisplay_Init();
	while(1)
	{
		LedDisplay_Direction(test);
		test += 0.05;
		if(test >= 360.0) test = 0;
	}
	while(1);
	return 0;
}
