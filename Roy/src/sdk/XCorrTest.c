/*
 * XCorrTest.c
 *
 *  Created on: 25.11.2016
 *      Author: Roy
 */

#include "XCorrTest.h"

//XGpio mic0, mic1, mic2, irqGen;
//int TAU01, TAU02;
//
//TauStore tau[SIZE];
//
//void test() {
//	AXI_SH_595_init(SH, 0x1);
//	while(!AXI_SH_595_ready(SH));
//	AXI_SH_595_programm_sh(SH, 1 << 15);
//
//	XGpio_Initialize(&mic0, XPAR_MIC0_DEVICE_ID);
//	XGpio_Initialize(&mic1, XPAR_MIC1_DEVICE_ID);
//	XGpio_Initialize(&mic2, XPAR_MIC2_DEVICE_ID);
//	XGpio_Initialize(&irqGen, XPAR_IRQ_GEN_DEVICE_ID);
//
//	AXI_SH_595_programm_sh(SH, 1 << 11);
//
//	setAllMic(0);
//	clearRam();
//	clearRam();
//	TAU01 = 10;
//	TAU02 = -8;
//	for (int cnt = 0; cnt < SIZE; ++cnt){
//		AXI_SH_595_programm_sh(SH, cnt);
//
//		clearRam();
//		genTau();
////		clearRam();
//
//		logTau(cnt);
////		TAU01++;
////		TAU02++;
//	}
//	AXI_SH_595_programm_sh(SH, 1 << 2);
//	printTau();
//	AXI_SH_595_programm_sh(SH, 0);
//
//}
//
//void genTau() {
//	int cnt;
//
//	for (cnt = 0; cnt < 512; ++cnt) {
//		setAllMic(cnt);
//		for (int delay = 5; delay; --delay)
//					;
//		pulseIrq();
//		for (int delay = 100; delay; --delay)
//			;
//	}
//}
//
//void logTau(int store) {
//	for (int idx = 0; idx < TAU_MAX; idx++) {
//		XCORR_mWriteReg(XCORR, 0, idx);
//		for(u32 delay = 4; delay; --delay);
//		tau[store].corr01[idx] = XCORR_mReadReg(XCORR, 4);
//		tau[store].corr02[idx] = XCORR_mReadReg(XCORR, 8);
//	}
//}
//
//void printTau() {
//	for (int store = 0; store < SIZE; ++store) {
//		for (int idx = 0; idx < TAU_MAX; idx++) {
//			xil_printf("%d,%d\n", tau[store].corr01[idx],
//					tau[store].corr02[idx]);
//		}
//	}
//
//}
//
//void setMic(int micNr, int x) {
//	switch (micNr) {
//	case 1:
////		XGpio_DiscreteWrite(&mic1, 1, 0);
//		XGpio_DiscreteWrite(&mic1, 1, getSin(x, TAU01));
//		break;
//	case 2:
////		XGpio_DiscreteWrite(&mic2, 1, 0);
//		XGpio_DiscreteWrite(&mic2, 1, getSin(x, TAU02));
//		break;
//	default: // 0
////		XGpio_DiscreteWrite(&mic0, 1, 0);
//		XGpio_DiscreteWrite(&mic0, 1, getSin(x, 0));
//		break;
//	}
//}
//
//void setAllMic(int x) {
//	if (0) {
//		XGpio_DiscreteWrite(&mic1, 1, 0);
//		XGpio_DiscreteWrite(&mic2, 1, 0);
//		XGpio_DiscreteWrite(&mic0, 1, 0);
//	} else {
//		XGpio_DiscreteWrite(&mic1, 1, getSin(x, TAU01));
//		XGpio_DiscreteWrite(&mic2, 1, getSin(x, TAU02));
//		XGpio_DiscreteWrite(&mic0, 1, getSin(x, 0));
//	}
//}
//
//void pulseIrq(void) {
//	XGpio_DiscreteWrite(&irqGen, 1, 0x1);
//	for (int delay = 1; delay; --delay)
//				;
//	XGpio_DiscreteWrite(&irqGen, 1, 0x0);
//}
//
//void clearRam(){
//	XCORR_mWriteReg(XCORR, 0, -1); // invalid tau -> clear ram
//	for(u32 delay = 100; delay; --delay);
//	XCORR_mWriteReg(XCORR, 0, 0); // valid tau -> normal operation
//
//}
