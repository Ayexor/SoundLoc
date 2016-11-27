/*
 * Empty C++ Application
 */

#include "xil_printf.h"
#include "mb_interface.h"
#include "xparameters.h"
#include "SDM_Decimator.h"
#include "AXI_SH_595.h"
#include "xintc.h"
#include "XCorr.h"

//#include "XCorrTest.h"


#define DECIMATION	40
#define ORDER		3
#define IRQ_ENA		0b100
#define TAU_MAX		16
#define SAMPLE_CNT	3*19000
#define CIC			XPAR_CIC_S_AXI_BASEADDR
#define SH			XPAR_SH_S_AXI_BASEADDR
#define XCORR		XPAR_XCORR_S_AXI_BASEADDR

typedef struct {
	int corr01[TAU_MAX];
	int corr02[TAU_MAX];
} TauStore ;

int irg_flag = 1;


//TauStore tau[SAMPLE_CNT];
s16 val[SAMPLE_CNT]; 	// pointer to stored values
//int top; // index to topmost element in val[]. initialized to SIZE! Decrement by pushing values


void logTau(XIntc* pIntc);
void logVal(XIntc* pIntc);
void isr(void* arg);
int initIRQ(XIntc* pIntc);



int main() {
	XIntc intc;
	int result;

	SDM_DECIM_setStatus(CIC, 0x0); // reset

	AXI_SH_595_init(SH, 0x1);
	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 1 << 15);
	while(!AXI_SH_595_ready(SH));

	SDM_DECIM_setStatus(CIC, 0b1001); // run, 3rd Order
	SDM_DECIM_setDecimation(CIC, DECIMATION);

	result = initIRQ(&intc);
	if (result){
		xil_printf("IRQ Init failed. Result: %d\nAbort..\n", result);
		return 1;
	}

//	logTau(&intc);
	logVal(&intc);

//	test();
	return 0;
}

//void logTau(XIntc* pIntc) {
//	int sample_cnt, idx;
//	while(!AXI_SH_595_ready(SH));
//	AXI_SH_595_programm_sh(SH, 1 << 6);
//
//	SDM_DECIM_setStatus(CIC, 0b1101); // run, 3rd Order, IRQ (bs not inverted)
//
//	while(!AXI_SH_595_ready(SH));
//	AXI_SH_595_programm_sh(SH, 1 << 5);
//
//	XCORR_mWriteReg(XCORR, 0, 0b1); // clear correlation
//	for (int delay = 100000; delay; --delay);
//	XCORR_mWriteReg(XCORR, 0, 0b0); // start correlation
//	for (int delay = 100000; delay; --delay);
//
//	XIntc_Enable(pIntc, 0);
//
//	for (sample_cnt = 0; sample_cnt < SAMPLE_CNT; ++sample_cnt) {
//		while(irg_flag) ;
//		for(int delay = 100; delay; --delay);
//
//		irg_flag = 1;
//		for(idx = 0; idx < TAU_MAX; idx++){
//			tau[sample_cnt].corr01[idx] = XCORR_mReadReg(XCORR, 0b100000000 + 4*idx); // read xcorr01
//			tau[sample_cnt].corr02[idx] = XCORR_mReadReg(XCORR, 0b110000000 + 4*idx); // read xcorr02
//		}
//	}
//	XIntc_Disable(pIntc, 0);
//	while(!AXI_SH_595_ready(SH));
//	AXI_SH_595_programm_sh(SH, 1 << 4);
//
//	for (sample_cnt = 0; sample_cnt < SAMPLE_CNT; ++sample_cnt) {
//		for(idx = 0; idx < TAU_MAX; idx++){
//			xil_printf("%d,%d\n", tau[sample_cnt].corr01[idx], tau[sample_cnt].corr02[idx]);
//		}
//	}
//
//	while(!AXI_SH_595_ready(SH));
//	AXI_SH_595_programm_sh(SH, 0);
//}

void logVal(XIntc* pIntc) {
	int top;
	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 1 << 14);

	SDM_DECIM_setStatus(CIC, ORDER | IRQ_ENA); // setup CIC

	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 1 << 12);

	for (int delay = 10000000; delay; --delay); // wait, just for fun...

	top = SAMPLE_CNT;
	XIntc_Enable(pIntc, 0);

	while (top > 2) {
		while(irg_flag) ;

		irg_flag = 1;

		val[top - 0] = (s16) SDM_DECIM_getValue(CIC, 0);
		val[top - 1] = (s16) SDM_DECIM_getValue(CIC, 1);
		val[top - 2] = (s16) SDM_DECIM_getValue(CIC, 2);
		top -= 3;
	}
	XIntc_Disable(pIntc, 0);
	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 1 << 11);
	top = SAMPLE_CNT;
	while (top > 2) {
		xil_printf("%d,%d,%d\n", val[top], val[top - 1], val[top - 2]);
		top -= 3;
	}

	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 0);
}

int initIRQ(XIntc* pIntc){
	int result;

	microblaze_enable_interrupts();

	if(pIntc->IsStarted == XIL_COMPONENT_IS_STARTED){
		XIntc_Stop(pIntc);
//		return 1;
	}
	result = XIntc_Initialize(pIntc, XPAR_INTC_0_DEVICE_ID);
	if (result != XST_SUCCESS){
		xil_printf("IRQ Initialization failed\n");
		return 2;
	}
	result = XIntc_Start(pIntc, XIN_REAL_MODE);
	if(result !=XST_SUCCESS){
		xil_printf("IRQ start failed\n");
		return 3;
	}
	result = XIntc_Connect(pIntc, 0, isr, pIntc);
	if(result !=XST_SUCCESS){
		xil_printf("IRQ connection failed\n");
		return 4;
	}

	return 0;
}

void isr(void* arg){
//	xil_printf("IRQ");
	XIntc_Acknowledge(arg, 0);
	irg_flag = 0;
}

