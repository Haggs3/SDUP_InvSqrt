#include <stdio.h>
#include "stdlib.h"
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xaxidma.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "math.h"

#define ARRAY_LENGTH 18

volatile int TxDone;
volatile int RxDone;

const float test[ARRAY_LENGTH] = {
		1.0, 2.0, 3.0, 4.0, 16.0, 256.0, NAN, INFINITY, 1000000.0, -1.0, -2.0, -0.5, 0.5, 0.25, 0.125, 0.1, 0.000001, 0.0
};

u32* dma_input;
u32* hw_results;
float sw_results[ARRAY_LENGTH];

static void TxIntrHandler(void *Callback)
{
	u32 IrqStatus;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DMA_TO_DEVICE);

	/* If no interrupt is asserted, we do not do anything */
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {
		return;
	}
	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {
		TxDone = 1;
	}
}

static void RxIntrHandler(void *Callback)
{
	u32 IrqStatus;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DEVICE_TO_DMA);

	/* If no interrupt is asserted, we do not do anything */
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {
		return;
	}
	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {
		RxDone = 1;
	}
}

static void SetupIntrSystem(XAxiDma * AxiDmaPtr, u16 TxIntrId, u16 RxIntrId)
{
	XScuGic_Config *IntcConfig;
	XScuGic Intc;

	/* Initialize the interrupt controller driver */
	IntcConfig = XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
	XScuGic_CfgInitialize(&Intc, IntcConfig, IntcConfig->CpuBaseAddress);
	XScuGic_SetPriorityTriggerType(&Intc, TxIntrId, 0xA0, 0x3);
	XScuGic_SetPriorityTriggerType(&Intc, RxIntrId, 0xA0, 0x3);
	/*
	 * Connect the device driver handler that will be called when an interrupt for the device occurs,
	 * the handler defined above performs the specific interrupt processing for the device.
	 */
	XScuGic_Connect(&Intc, TxIntrId, (Xil_InterruptHandler)TxIntrHandler, AxiDmaPtr);
	XScuGic_Connect(&Intc, RxIntrId, (Xil_InterruptHandler)RxIntrHandler, AxiDmaPtr);

	XScuGic_Enable(&Intc, TxIntrId);
	XScuGic_Enable(&Intc, RxIntrId);

	/* Enable interrupts from the hardware */
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, (void *)&Intc);
	Xil_ExceptionEnable();
}

static void SetupDMA(XAxiDma * AxiDmaPtr)
{
	XAxiDma_Config *Config;
	Config = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);

	/* Initialize DMA engine */
	XAxiDma_CfgInitialize(AxiDmaPtr, Config);

	/* Set up Interrupt system  */
	SetupIntrSystem(AxiDmaPtr, XPAR_FABRIC_AXIDMA_0_MM2S_INTROUT_VEC_ID, XPAR_FABRIC_AXIDMA_0_S2MM_INTROUT_VEC_ID);

	/* Disable all interrupts before setup */
	XAxiDma_IntrDisable(AxiDmaPtr, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrDisable(AxiDmaPtr, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

	/* Enable all interrupts */
	XAxiDma_IntrEnable(AxiDmaPtr, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(AxiDmaPtr, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
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
	XAxiDma AxiDma;

	xil_printf("\r\n--- Inverse Square Root Pipelined DMA Test start ---\r\n");

	dma_input = (u32*)malloc(ARRAY_LENGTH*sizeof(u32));
	hw_results = (u32*)calloc(ARRAY_LENGTH, sizeof(u32));
	RxDone = 0;
	TxDone = 0;

	for(u8 i = 0; i < ARRAY_LENGTH; i++) {
		dma_input[i] = *((u32*)&test[i]);
	}
	for(u8 i = 0; i < ARRAY_LENGTH; i++) {
		sw_results[i] = Q_rsqrt(test[i]);
	}

	SetupDMA(&AxiDma);
	Xil_DCacheDisable();

	/* Send a packet */
	XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) hw_results, sizeof(u32)*ARRAY_LENGTH, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) dma_input, sizeof(u32)*ARRAY_LENGTH, XAXIDMA_DMA_TO_DEVICE);

	while (!TxDone || !RxDone);
	/*
	* Test finished, check data
	*/
	float in, out, sw_result;
	for (u8 i = 0; i < ARRAY_LENGTH; i++) {
		in = *(float*)&dma_input[i];
		out = *(float*)&hw_results[i];
		sw_result = sw_results[i];
		printf("Input: %f,\tHW Output: %f,\tSW Result: %f,\tDifference: %f \n", in, out, sw_result, out - sw_result);
	}

	xil_printf("\r\n--- Inverse Square Root Pipelined DMA Test finish ---\r\n");

	free(dma_input);
	free(hw_results);
	cleanup_platform();
	return 0;
}
