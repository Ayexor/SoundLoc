/*
 * Empty C++ Application
 */

#include "mb_interface.h"
#include "xil_printf.h"
#include "irq.h"

//#include <iostream>
#include "micLog.h"
#include "leddisplay.h"
#include "uart.h"

int main()
{
	microblaze_enable_icache();
	microblaze_enable_dcache();
	microblaze_enable_interrupts();
	microblaze_enable_exceptions();

	uartInit();
	irqInit();

//	u8 str[] = "Hallo du schöne, heile Welt! Wundervoll, dass es dich gibt!\n";
//	uartSend(str, sizeof(str)-1);
//	waitTxEmpty();
//	LedDisplay_Init();	LedDisplay_Rotate();

//	micLog();
//	corrLog();
//	dataLog();

	soundLoc();

	waitTxEmpty();
//	while(1);

	return 0;
}


