/*
 * uart.cc
 *
 *  Created on: 30.12.2016
 *      Author: Roy
 */

#include "xparameters.h"
#include "xil_printf.h"
#include "xuartlite.h"
#include "uart.h"

XUartLite uart;
static volatile int txEmpty = 1;

void uartInit(void){
	XUartLite_Initialize(&uart, XPAR_UARTLITE_0_DEVICE_ID);
	XUartLite_EnableInterrupt(&uart);
	XUartLite_SetRecvHandler(&uart, uart_Rx_handle, 0);
	XUartLite_SetSendHandler(&uart, uart_Tx_handle, 0);
}

void uartSend(u8* data, u32 numByte){
	txEmpty = 0;
	XUartLite_Send(&uart, data, numByte);
}

void uart_isr(void*) {
	XUartLite_InterruptHandler(&uart);
}
void uart_isr_fast(void) {
	XUartLite_InterruptHandler(&uart);
}

void uart_Rx_handle(void *CallBackRef, unsigned int ByteCount){

}
void uart_Tx_handle(void *CallBackRef, unsigned int ByteCount){
//	xil_printf("\n\nuart_Tx_handle: Sent a Total of %d Bytes!\n", ByteCount);
	txEmpty = 1;
}

void waitTxEmpty(){
	while(!txEmpty)
		;
}
