#include <stdio.h>
#include "stdlib.h"
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "math.h"
#include "InvSqrt.h"

#define ARRAY_LENGTH 18

#define INVSQRT_START_REG  INVSQRT_S_AXI_SLV_REG0_OFFSET
#define INVSQRT_INPUT_REG  INVSQRT_S_AXI_SLV_REG1_OFFSET
#define INVSQRT_OUTPUT_REG INVSQRT_S_AXI_SLV_REG2_OFFSET
#define INVSQRT_READY_REG  INVSQRT_S_AXI_SLV_REG3_OFFSET
#define INVSQRT_BASEADDR   XPAR_INVSQRT_0_S_AXI_BASEADDR

static float InvSqrt_Calculate(float number)
{
	u32 result_u32;
	float result_f;
	INVSQRT_mWriteReg(INVSQRT_BASEADDR, INVSQRT_INPUT_REG, *(u32*)&number);
	INVSQRT_mWriteReg(INVSQRT_BASEADDR, INVSQRT_START_REG, 1);
	while(INVSQRT_mReadReg(INVSQRT_BASEADDR, INVSQRT_READY_REG) == 0);
	result_u32 = INVSQRT_mReadReg(INVSQRT_BASEADDR, INVSQRT_OUTPUT_REG);
	result_f = *(float*)&result_u32;
	return result_f;
}

static float Q_rsqrt( float number )
{
	long i;
	float x2, y;
	const float threehalfs = 1.5F;

	x2 = number * 0.5F;
	y  = number;
	i  = * ( long * ) &y;                       // evil floating point bit level hacking
	i  = 0x5f3759df - ( i >> 1 );               // what the duck?
	y  = * ( float * ) &i;
	y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration
//	y  = y * ( threehalfs - ( x2 * y * y ) );   // 2nd iteration, this can be removed

	return y;
}

int main()
{
	init_platform();
	const float test_vector[ARRAY_LENGTH] = {
			1.0, 2.0, 3.0, 4.0, 16.0, 256.0, NAN, INFINITY, 1000000.0, -1.0, -2.0, -0.5, 0.5, 0.25, 0.125, 0.1, 0.000001, 0.0
	};

	float hw_result[ARRAY_LENGTH];
	float sw_result[ARRAY_LENGTH];

	xil_printf("\r\n--- Inverse Square Root Test start ---\r\n");

	for(u8 i = 0; i < ARRAY_LENGTH; i++) {
		sw_result[i] = Q_rsqrt(test_vector[i]);
		hw_result[i] = InvSqrt_Calculate(test_vector[i]);
	}

//	Xil_DCacheDisable();

	/*
	* Test finished, check data
	*/
	float in, hw, sw;
	for (u8 i = 0; i < ARRAY_LENGTH; i++) {
		in = test_vector[i];
		hw = hw_result[i];
		sw = sw_result[i];
		printf("Input: %f,\tHW Output: %f,\tSW Result: %f,\tDifference: %f \n", in, hw, sw, hw - sw);
	}

	xil_printf("\r\n--- Inverse Square Root Test finish ---\r\n");

	cleanup_platform();
	return 0;
}
