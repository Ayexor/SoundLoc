
/***************************** Include Files *******************************/
#include "ArtyIO.h"
#include "xparameters.h"

#define ARTYIO_BASEADDR XPAR_ARTYIO_S00_AXI_BASEADDR
/************************** Function Definitions ***************************/

u32 ARTYIO_ReadCtrl() {
	return ARTYIO_mReadReg(ARTYIO_BASEADDR, ARTYIO_REG_CTRL_OFFSET);
}

void ARTYIO_WriteCtrl(u32 data) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_CTRL_OFFSET, data);
}

void ARTYIO_Enable(u32 mask) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_CTRL_SET_OFFSET, mask);
}

void ARTYIO_Disable(u32 mask) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_CTRL_CLEAR_OFFSET, mask);
}

/********************** Function for IRQ Register  ***********************/

u32 ARTYIO_ReadIrqPend() {
	return ARTYIO_mReadReg(ARTYIO_BASEADDR, ARTYIO_REG_IRQ_PEND_OFFSET);
}

void ARTYIO_ClearIrqPend(u32 mask) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_IRQ_PEND_OFFSET, mask);
}

/********************** Function for SW BTN Register  ***********************/

u32 ARTYIO_ReadSwBtn() {
	return ARTYIO_mReadReg(ARTYIO_BASEADDR, ARTYIO_REG_SW_BTN_OFFSET);
}

/*********************** Function for LED Register  ************************/

u32 ARTYIO_ReadLED() {
	return ARTYIO_mReadReg(ARTYIO_BASEADDR, ARTYIO_REG_LED_OFFSET);
}

void ARTYIO_WriteLed(u32 data) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_LED_OFFSET, data);
}

void ARTYIO_SetLed(u32 mask) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_LED_SET_OFFSET, mask);
}

void ARTYIO_ClearLed(u32 mask) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_LED_CLEAR_OFFSET, mask);
}

/*********************** Function for RGB Register *************************/

void ARTYIO_WriteRgb(u32 RgbId, u32 data) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_RGB0_OFFSET + RgbId*4, data);
}

void ARTYIO_WriteRgbY(u32 data) {
	ARTYIO_mWriteReg(ARTYIO_BASEADDR, ARTYIO_REG_RGB_Y_OFFSET, data);
}
