/*
 * irq.cc
 *
 *  Created on: 28.12.2016
 *      Author: Roy
 */

#include "xparameters.h"
#include "irq.h"
#include "xintc.h"
#include "uart.h"

#define IRQ_ID 		XPAR_INTC_XCORR_IRQ_INTR
#define UART_ID		XPAR_INTC_UART_INTERRUPT_INTR
//#define IRQ_ID 		XPAR_INTC_SDM_DECIMATOR_IRQ_NEW_VAL_INTR

static volatile int irqFlag = 0;

static XIntc intc;

#if (XPAR_INTC_HAS_FAST == 0)
void isr(void* param) __attribute__ ((interrupt_handler));
void isr(void* param) {
	irqFlag = 1;
//	xil_printf("IRQ\n");
	XIntc_Acknowledge(&intc, IRQ_ID);
}
#else
void isr_fast(void) __attribute__ ((fast_interrupt));
void isr_fast(void) {
	irqFlag = 1;
	//xil_printf("IRQ\n");
	//acknowledge sent by uB itself
}
#endif

void irqInit(void) {
	if (intc.IsStarted != 0)
		XIntc_Stop(&intc);

	XIntc_Initialize(&intc, XPAR_INTC_0_DEVICE_ID);
	XIntc_Start(&intc, XIN_REAL_MODE);

//	XIntc_Connect(&intc, UART_ID, uart_isr, 0);

#if (XPAR_INTC_HAS_FAST == 0)
	XIntc_Connect(&intc, IRQ_ID, isr, &intc);
	XIntc_Connect(&intc, UART_ID, XUartLite_InterruptHandler, &uart);
#else
	XIntc_ConnectFastHandler(&intc, IRQ_ID, isr_fast);
	XIntc_ConnectFastHandler(&intc, UART_ID, uart_isr_fast);
#endif

	XIntc_Enable(&intc, UART_ID);
}

void irqEna(void) {
	XIntc_Enable(&intc, IRQ_ID);
}

void irqDis(void) {
	XIntc_Disable(&intc, IRQ_ID);
}

void irqWait(void) {
	irqFlag = 0;
	while (!irqFlag) {
	}

}

