/*
 * leddisplay.h
 *
 *  Created on: Nov 26, 2016
 *      Author: marco
 */

#ifndef LEDDISPLAY_H_
#define LEDDISPLAY_H_

/* initialize the LED-Display*/
extern void LedDisplay_Init(void);

/* display a pattern where every second LED is lit alternatively */
extern void LedDisplay_Rotate(void);

/* display a direction on the Display where the angle is specified. 0 deg is next to microphone 1 */
extern void LedDisplay_Direction(double direction);

#endif /* LEDDISPLAY_H_ */
