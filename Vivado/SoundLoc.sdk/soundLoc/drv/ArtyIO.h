
#ifndef ARTYIO_H
#define ARTYIO_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xil_io.h"

/******************* DEFINITIONS *********************/

#define ARTYIO_REG_CTRL_OFFSET 0
#define ARTYIO_REG_IRQ_PEND_OFFSET 4
#define ARTYIO_REG_CTRL_SET_OFFSET 8
#define ARTYIO_REG_CTRL_CLEAR_OFFSET 12
#define ARTYIO_REG_SW_BTN_OFFSET 16
#define ARTYIO_REG_LED_OFFSET 20
#define ARTYIO_REG_LED_SET_OFFSET 24
#define ARTYIO_REG_LED_CLEAR_OFFSET 28
#define ARTYIO_REG_RGB0_OFFSET 32
#define ARTYIO_REG_RGB1_OFFSET 36
#define ARTYIO_REG_RGB2_OFFSET 40
#define ARTYIO_REG_RGB3_OFFSET 44
#define ARTYIO_REG_RGB_Y_OFFSET 48

#define ARTYIO_IRQ_SW0_RISE_MASK	0x1000
#define ARTYIO_IRQ_SW1_RISE_MASK	0x2000
#define ARTYIO_IRQ_SW2_RISE_MASK	0x4000
#define ARTYIO_IRQ_SW3_RISE_MASK	0x8000
#define ARTYIO_IRQ_BTN0_RISE_MASK	0x0100
#define ARTYIO_IRQ_BTN1_RISE_MASK	0x0200
#define ARTYIO_IRQ_BTN2_RISE_MASK	0x0400
#define ARTYIO_IRQ_BTN3_RISE_MASK	0x0800
#define ARTYIO_IRQ_SW0_FALL_MASK	0x0010
#define ARTYIO_IRQ_SW1_FALL_MASK	0x0020
#define ARTYIO_IRQ_SW2_FALL_MASK	0x0040
#define ARTYIO_IRQ_SW3_FALL_MASK	0x0080
#define ARTYIO_IRQ_BTN0_FALL_MASK	0x0001
#define ARTYIO_IRQ_BTN1_FALL_MASK	0x0002
#define ARTYIO_IRQ_BTN2_FALL_MASK	0x0004
#define ARTYIO_IRQ_BTN3_FALL_MASK	0x0008

#define ARTYIO_IRQ_SW_RISE_MASK		0xF000
#define ARTYIO_IRQ_BTN_RISE_MASK	0x0F00
#define ARTYIO_IRQ_SW_FALL_MASK		0x00F0
#define ARTYIO_IRQ_BTN_FALL_MASK	0x000F

#define ARTYIO_IRQ_SW_ALL_MASK		0xF0F0
#define ARTYIO_IRQ_BTN_ALL_MASK		0x0F0F
#define ARTYIO_IRQ_RISE_ALL_MASK	0xFF00
#define ARTYIO_IRQ_FALL_ALL_MASK	0x00FF

#define ARTYIO_IRQ_ALL_MASK			0xFFFF

#define ARTYIO_ENA_LED0_MASK			0x10000000
#define ARTYIO_ENA_LED1_MASK			0x20000000
#define ARTYIO_ENA_LED2_MASK			0x40000000
#define ARTYIO_ENA_LED3_MASK			0x80000000
#define ARTYIO_ENA_RGB0_MASK			0x01000000
#define ARTYIO_ENA_RGB1_MASK			0x02000000
#define ARTYIO_ENA_RGB2_MASK			0x04000000
#define ARTYIO_ENA_RGB3_MASK			0x08000000
#define ARTYIO_ENA_SW0_MASK				0x00100000
#define ARTYIO_ENA_SW1_MASK				0x00200000
#define ARTYIO_ENA_SW2_MASK				0x00400000
#define ARTYIO_ENA_SW3_MASK				0x00800000
#define ARTYIO_ENA_BTN0_MASK			0x00010000
#define ARTYIO_ENA_BTN1_MASK			0x00020000
#define ARTYIO_ENA_BTN2_MASK			0x00040000
#define ARTYIO_ENA_BTN3_MASK			0x00080000
#define ARTYIO_ENA_IRQ_SW0_RISE_MASK	0x00001000
#define ARTYIO_ENA_IRQ_SW1_RISE_MASK	0x00002000
#define ARTYIO_ENA_IRQ_SW2_RISE_MASK	0x00004000
#define ARTYIO_ENA_IRQ_SW3_RISE_MASK	0x00008000
#define ARTYIO_ENA_IRQ_BTN0_RISE_MASK	0x00000100
#define ARTYIO_ENA_IRQ_BTN1_RISE_MASK	0x00000200
#define ARTYIO_ENA_IRQ_BTN2_RISE_MASK	0x00000400
#define ARTYIO_ENA_IRQ_BTN3_RISE_MASK	0x00000800
#define ARTYIO_ENA_IRQ_SW0_FALL_MASK	0x00000010
#define ARTYIO_ENA_IRQ_SW1_FALL_MASK	0x00000020
#define ARTYIO_ENA_IRQ_SW2_FALL_MASK	0x00000040
#define ARTYIO_ENA_IRQ_SW3_FALL_MASK	0x00000080
#define ARTYIO_ENA_IRQ_BTN0_FALL_MASK	0x00000001
#define ARTYIO_ENA_IRQ_BTN1_FALL_MASK	0x00000002
#define ARTYIO_ENA_IRQ_BTN2_FALL_MASK	0x00000004
#define ARTYIO_ENA_IRQ_BTN3_FALL_MASK	0x00000008

#define ARTYIO_ENA_LED_MASK			0xF0000000
#define ARTYIO_ENA_RGB_MASK			0x0F000000
#define ARTYIO_ENA_SW_MASK			0x00F00000
#define ARTYIO_ENA_BTN_MASK			0x000F0000
#define ARTYIO_ENA_IRQ_RISE_MASK	0x0000FF00
#define ARTYIO_ENA_IRQ_FALL_MASK	0x000000FF
#define ARTYIO_ENA_IRQ_ALL_MASK		0x0000FFFF
#define ARTYIO_ENA_ALL_MASK			0xFFFFFFFF

#define ARTYIO_SW0_MASK	0x10
#define ARTYIO_SW1_MASK	0x20
#define ARTYIO_SW2_MASK	0x40
#define ARTYIO_SW3_MASK	0x80

#define ARTYIO_BTN0_MASK	0x01
#define ARTYIO_BTN1_MASK	0x02
#define ARTYIO_BTN2_MASK	0x04
#define ARTYIO_BTN3_MASK	0x08

#define ARTYIO_LED0_MASK	0x1
#define ARTYIO_LED1_MASK	0x2
#define ARTYIO_LED2_MASK	0x4
#define ARTYIO_LED3_MASK	0x8



/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a ARTYIO register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the ARTYIOdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void ARTYIO_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define ARTYIO_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a ARTYIO register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the ARTYIO device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 ARTYIO_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define ARTYIO_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the ARTYIO instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus ARTYIO_Reg_SelfTest();

/*********************** Function for CTRL Register ************************/

/**
 *
 * Reads CTRL Register.
 *
 * @return Content of REG_CTRL
 *
 */
u32 ARTYIO_ReadCtrl();

/**
 *
 * Sets CTRL Register to 'data'.
 *
 * @param   data is the data written to REG_CTRL
 *
 * @return None.
 *
 */
void ARTYIO_WriteCtrl(u32 data);

/**
 *
 * Sets masked bits in CTRL Register.
 *
 * @param   mask: bits to set
 * 				One may use ARTYIO_ENA_*
 *
 * @return None.
 *
 */
void ARTYIO_Enable(u32 mask);

/**
 *
 * Clear masked bits in CTRL Register.
 *
 * @param   mask: bits to clear
 * 				One may use ARTYIO_ENA_*
 *
 * @return None.
 *
 */
void ARTYIO_Disable(u32 mask);

/********************** Function for IRQ Register  ***********************/

/**
 *
 * Reads pending IRQ.
 *
 * @return Content of REG_IRQ_PEND
 *
 */
u32 ARTYIO_ReadIrqPend();

/**
 *
 * Clear masked pending IRQ.
 *
 * @param   mask: IRQs to clear
 *
 * @return None.
 *
 */
void ARTYIO_ClearIrqPend(u32 mask);


/********************** Function for SW BTN Register  ***********************/

/**
 *
 * Reads SW BTN Register.
 *
 * @return Content of REG_SW_BTN
 *
 */
u32 ARTYIO_ReadSwBtn();

/*********************** Function for LED Register  ************************/

/**
 *
 * Reads LED Register.
 *
 * @return Content of REG_LED
 *
 */
u32 ARTYIO_ReadLED();

/**
 *
 * Sets LED Register to 'data'.
 *
 * @param   data is the data written to REG_LED
 *
 * @return None.
 *
 */
void ARTYIO_WriteLed(u32 data);

/**
 *
 * Sets masked bits in LED Register.
 *
 * @param   mask: bits to set
 *
 * @return None.
 *
 */
void ARTYIO_SetLed(u32 mask);

/**
 *
 * Clear masked bits in LED Register.
 *
 * @param   mask: bits to clear
 *
 * @return None.
 *
 */
void ARTYIO_ClearLed(u32 mask);

/*********************** Function for RGB Register *************************/

/**
 *
 * Sets RGBx Register RgbId to 'data'.
 *
 * @param   RgbId is the ID of the RGB LED (0-3)
 *
 * @param   data is the data written to RGBx (0-255)
 *
 * @return None.
 *
 */
void ARTYIO_WriteRgb(u32 RgbId, u32 data);

/**
 *
 * Sets RGB brightness Register to 'data'.
 *
 * @param   data is the data written to RGB_Y (0-255)
 *
 * @return None.
 *
 */
void ARTYIO_WriteRgbY(u32 data);

#endif // ARTYIO_H
