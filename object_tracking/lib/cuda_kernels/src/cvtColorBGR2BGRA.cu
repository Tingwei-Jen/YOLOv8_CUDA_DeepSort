#include "cuda_kernel.h"
#include <stdio.h>
#include <iostream>

#define BLOCK_SIZE 32

__global__ void cvtColorBGR2BGRA_shared_kernel(unsigned char *d_bgra, unsigned char *d_bgr, int width)
{
    // +1 for padding due to bank conflict
    __shared__ unsigned char sharedMemory [BLOCK_SIZE][BLOCK_SIZE+1][3];

	// global index	
	int indexX = threadIdx.x + blockIdx.x * blockDim.x;
	int indexY = threadIdx.y + blockIdx.y * blockDim.y;
	// local index
	int localIndexX = threadIdx.x;
	int localIndexY = threadIdx.y;
    // array index
    int index = indexY * width + indexX;

    // reading from global memory in coalesed manner in shared memory
    sharedMemory[localIndexX][localIndexY][0] = d_bgr[index*3];  // b
    sharedMemory[localIndexX][localIndexY][1] = d_bgr[index*3+1];  // g
    sharedMemory[localIndexX][localIndexY][2] = d_bgr[index*3+2];  // r

    // writing into global memory in coalesed fashion via data in shared memory
    d_bgra[index*4] = sharedMemory[localIndexX][localIndexY][0];   // b
    d_bgra[index*4+1] = sharedMemory[localIndexX][localIndexY][1]; // g
    d_bgra[index*4+2] = sharedMemory[localIndexX][localIndexY][2];   // r
    d_bgra[index*4+3] = 255;
}

void cvtColorBGR2BGRA(unsigned char *d_bgra, unsigned char *d_bgr, int width, int height)
{
    dim3 blockSize(BLOCK_SIZE, BLOCK_SIZE, 1);
	dim3 gridSize( (width+BLOCK_SIZE-1)/BLOCK_SIZE, (height+BLOCK_SIZE-1)/BLOCK_SIZE, 1);
    cvtColorBGR2BGRA_shared_kernel<<<gridSize, blockSize>>>(d_bgra, d_bgr, width);   
    cudaDeviceSynchronize();
}
