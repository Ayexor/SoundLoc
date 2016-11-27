/*
 * sig.h
 *
 *  Created on: 25.11.2016
 *      Author: Roy
 */

#ifndef SRC_SIG_H_
#define SRC_SIG_H_

#include "xil_types.h"

extern const s16 sin_lut[600];

s16 getSin(int x, int tau);

#endif /* SRC_SIG_H_ */
