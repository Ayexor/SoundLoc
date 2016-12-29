/*
 * Empty C++ Application
 */

#include "mb_interface.h"
#include "xil_printf.h"
#include "irq.h"

//#include <iostream>
#include "micLog.h"

int main()
{
	microblaze_enable_icache();
	microblaze_enable_dcache();
	microblaze_enable_interrupts();
	microblaze_enable_exceptions();

	irqInit();

//	micLog();

	soundLoc();

//	while(1);

	return 0;
}


