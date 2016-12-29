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
/* DOES NOT WORK RIGHT NOW */
extern void LedDisplay_Rotate(void);

/* display a direction on the Display where the angle is specified. 0 deg is in direction of microphone 1 */
extern void LedDisplay_Angle(float angle);

/* display a direction on the Display where a point coordinate is specified. origin is 0,0 */
extern void LedDisplay_Coordinate(float x, float y);

/* display a direction calculated from the taus directly */
extern void LedDisplay_Tau(float tau12, float tau13);

#endif /* LEDDISPLAY_H_ */
