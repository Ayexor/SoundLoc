
#ifndef MIC_LOG_H_
#define MIC_LOG_H_

#include "xil_types.h"

/* Log and print the microphon data */
void micLog(void);

/* Log and print the correlation data */
void corrLog(void);

/* Log and print both microphone and correlation data */
void dataLog(void);

/* Main application - calculates angle from correlation data and displays it on led ring */
void soundLoc();


#endif /* MIC_LOG_H_ */
