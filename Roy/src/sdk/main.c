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
//#include "xgpio.h"

//#include "math.h"

//#include "XCorrTest.h"


#define DECIMATION		64
#define ORDER			2
#define IRQ_ENA			0b100
#define TAU_ADDR_WIDTH	5
#define TAU_SCNT		300
#define MIC_SCNT		3*2
#define CIC				XPAR_CIC_S_AXI_BASEADDR
#define SH				XPAR_SH_S_AXI_BASEADDR
#define XCORR			XPAR_XCORR_0_S_AXI_BASEADDR

#define TAU_CNT			(TAU_MAX - TAU_MIN + 1)
#define TAU_MIN			(1-(1<<(TAU_ADDR_WIDTH-1)))
#define TAU_MAX			((1<<(TAU_ADDR_WIDTH-1))-1)

typedef struct {
	int corr01[TAU_CNT];
	int corr02[TAU_CNT];
} TauStore ;

int irg_flag = 1;
//XGpio tauSet;


TauStore tau[TAU_SCNT];
s16 val[MIC_SCNT]; 	// pointer to stored values

void logTau(XIntc* pIntc);
void logVal(XIntc* pIntc);
void isr(void* arg);
int initIRQ(XIntc* pIntc);



int main() {
	XIntc intc;
	int result;

//	xil_printf("TAU_CNT = %d\nTAU_MIN = %d\nTAU_MAX = %d\n", TAU_CNT, TAU_MIN, TAU_MAX);
//	return 0;

//	for(int x = -1; x<2;++x)
//		for(int y = -1; y<2;++y)
//			xil_printf("atan2(%d, %d) = %d\n", x, y, 135+(int)(atan2(x,y)*180.0/M_PI));
//	return 0;

	SDM_DECIM_setStatus(CIC, 0x0); // reset

	AXI_SH_595_init(SH, 0x1);
	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 1 << 15);
	while(!AXI_SH_595_ready(SH));

//	XGpio_Initialize(&tauSet, XPAR_TAU_SET_DEVICE_ID);

//	XGpio_DiscreteWrite(&tauSet, 2, 0); // set reset of dummy_data
//	XGpio_DiscreteWrite(&tauSet, 1, 0x31);
//	for (int delay = 100; delay; --delay);
//	XGpio_DiscreteWrite(&tauSet, 2, 1); // release reset of dummy_data

	SDM_DECIM_setStatus(CIC, ORDER | IRQ_ENA); // setup CIC
	SDM_DECIM_setDecimation(CIC, DECIMATION);

	result = initIRQ(&intc);
	if (result){
		xil_printf("IRQ Init failed. Result: %d\nAbort..\n", result);
		return 1;
	}

	logTau(&intc);
//	logVal(&intc);

//	test();
	return 0;
}

void logTau(XIntc* pIntc) {
	int sample_cnt, idx;
	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 1 << 6);

	XCORR_mWriteReg(XCORR, 0, 0b1); // clear correlation
	for (int delay = 300000; delay; --delay);
	XCORR_mWriteReg(XCORR, 0, 0b0); // start correlation

	for (int delay = 4000000; delay; --delay);

	XIntc_Enable(pIntc, 0);

	for (sample_cnt = 0; sample_cnt < TAU_SCNT; ++sample_cnt) {
		while(irg_flag) ;

		irg_flag = 1;
		for(idx = TAU_MIN; idx <= TAU_MAX; idx++){
			u32 addr = 0b0011111100 & (4*idx);
			tau[sample_cnt].corr01[idx+TAU_MIN] = XCORR_mReadReg(XCORR, 0b1000000000 | addr); // read xcorr01
			tau[sample_cnt].corr02[idx+TAU_MIN] = XCORR_mReadReg(XCORR, 0b1100000000 | addr); // read xcorr02
		}
	}
	XIntc_Disable(pIntc, 0);
	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 1 << 4);

	for (sample_cnt = 0; sample_cnt < TAU_SCNT; ++sample_cnt) {
		for(idx = TAU_MIN; idx <= TAU_MAX; idx++){
			xil_printf("%d,%d\n", tau[sample_cnt].corr01[idx+TAU_MIN], tau[sample_cnt].corr02[idx+TAU_MIN]);
		}
	}

	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 0);
}

void logVal(XIntc* pIntc) {
	int top;

	while(!AXI_SH_595_ready(SH));
	AXI_SH_595_programm_sh(SH, 1 << 12);

	for (int delay = 10000000; delay; --delay); // wait, just for fun...

	top = MIC_SCNT;
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
	top = MIC_SCNT;
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

