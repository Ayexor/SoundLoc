/*
 * Empty C++ Application
 */

#include "xmk.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "../drv/SDM_Dezimator.h"
#include "../drv/AXI_SH_595.h"
#include "math.h"

#define DECIMATION 750
const int MEAN_SMPL = 1024;

const int SH = XPAR_AXI_SH_595_S_AXI_BASEADDR;
const int MIC[3] = { XPAR_MIC1_S_AXI_BASEADDR, // mic1
		XPAR_MIC2_S_AXI_BASEADDR, // mic2
		XPAR_MIC3_S_AXI_BASEADDR }; // mic3

int main() {
	int idx, tmp;
	int mean[3];
	int std[3];
	AXI_SH_595_init(SH, 0x1);

	for (idx = 0; idx < 3; ++idx) {
		SDM_DECIM_setStatus(MIC[idx], 1);
		SDM_DECIM_setDecimation(MIC[idx], DECIMATION);
	}
	for (idx = 0; idx < 3; ++idx) {
		xil_printf("Mic %d\nStatus    : %6d\n", idx,
				SDM_DECIM_getStatus(MIC[idx]));
		xil_printf("Decimation: %6d\n", SDM_DECIM_getDecimation(MIC[idx]));
	}
	idx = 100000;
	while(--idx);

	for (int loop = 16; loop>=0; loop--) {
		AXI_SH_595_programm_sh(SH, loop);
		for (idx = 0; idx < 3; idx++) {
			mean[idx] = 0;
			std[idx] = 0;
		}

		for (int smpl = MEAN_SMPL; smpl; smpl--) {
			for (idx = 0; idx < 3; idx++) {
				tmp = SDM_DECIM_geVal(MIC[idx]);
				mean[idx] = mean[idx] + tmp;
				std[idx] = std[idx] + (tmp*tmp);
			}
			for (int dly = 750*32; dly; --dly)
				;
		}
		for (idx = 0; idx < 3; idx++){
			mean[idx] = mean[idx] /  MEAN_SMPL;
			std[idx] = std[idx] / MEAN_SMPL;
			std[idx] = sqrtf(std[idx] - (mean[idx]*mean[idx]));

		}
		xil_printf("MIC1: %6d, %6d, MIC2: %6d, %6d, MIC3: %6d, %6d\n", (int)mean[0], std[0], (int)mean[1], (int)std[1], (int)mean[2], (int)std[2]);
	}

	AXI_SH_595_programm_sh(SH, 0x0);

	return 0;
}
