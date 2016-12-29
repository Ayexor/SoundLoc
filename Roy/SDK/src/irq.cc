/*
 * irq.cc
 *
 *  Created on: 28.12.2016
 *      Author: Roy
 */

#include "xparameters.h"
#include "irq.h"
#include "xintc.h"

#define IRQ_ID 		XPAR_INTC_XCORR_IRQ_INTR
//#define IRQ_ID 	XPAR_INTC_SDM_DECIMATOR_IRQ_NEW_VAL_INTR


static int irqFlag = 0;

static XIntc intc;


void isr(void* param) {
	irqFlag = 1;
	XIntc_Acknowledge(&intc, IRQ_ID);
}


void irqInit(void){
	if (intc.IsStarted != 0)
		XIntc_Stop(&intc);
	XIntc_Initialize(&intc, XPAR_INTC_0_DEVICE_ID);
	XIntc_Start(&intc, XIN_REAL_MODE);
	XIntc_Connect(&intc, IRQ_ID, isr, &intc);

}

void irqEna(void){
	XIntc_Enable(&intc, IRQ_ID);
}

void irqDis(void){
	XIntc_Disable(&intc, IRQ_ID);
}

void irqWait(void) {
	irqFlag = 0;
	while (!irqFlag) {
	}
}


