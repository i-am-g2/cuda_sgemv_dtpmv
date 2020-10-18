#include <stdio.h>
#include "cublas_v2.h"
#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#define BLOCK_SIZE 16 // Threads per block supported by the GPU


__global__ void sgemv_kernel (char Trans, int M, int N, float Alpha, float *A, float * X, float * Y , float Beta) {
	int y_size = (Trans == 'n' || Trans == 'N')? M:N;
	int x_size = (Trans == 'n' || Trans == 'N')? N:M;
	int elementId = blockIdx.x * BLOCK_SIZE + threadIdx.x; 

	if(elementId<y_size) {
		
		float sum = 0;
		for (int i = 0 ;i <x_size;i++) {
			sum += A[elementId *x_size  + i]   * X[i]; 
		}
		sum = sum * Alpha;
		
		Y[elementId] = Y[elementId] * Beta + sum;

	}

}

int Ceil (int M , int x) {
	if(M%x ==0) {
		return M/x;
	} else {
		return M/x+1;
	}
}


void sgemv(char Trans, int M, int N, float Alpha,float* A, float * X, float*Y , float Beta) {
	float * d_A, *d_X, *d_Y;
	
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaEventRecord(start,0);

	cudaMalloc((void**) &d_A, sizeof(float) * M*N);
	cudaMemcpy(d_A, A , sizeof(float) * M*N , cudaMemcpyHostToDevice);

	if(Trans=='n' || Trans == 'N') {
		cudaMalloc((void**) &d_X, sizeof(float) *N);
		cudaMemcpy(d_X, X , sizeof(float) *N , cudaMemcpyHostToDevice);
		
		cudaMalloc((void**) &d_Y, sizeof(float) * M);
		cudaMemcpy(d_Y, Y , sizeof(float) * M , cudaMemcpyHostToDevice);
	} else {
		cudaMalloc((void**) &d_X, sizeof(float) * M);
		cudaMemcpy(d_X, X , sizeof(float) * M , cudaMemcpyHostToDevice);
		
		cudaMalloc((void**) &d_Y, sizeof(float) * N);
		cudaMemcpy(d_Y, Y , sizeof(float) *N , cudaMemcpyHostToDevice);
	}
	int y_size = (Trans == 'n' || Trans == 'N')? M:N;


	/*Determine Kernel Parameters*/
	int num_blocks = Ceil(y_size, BLOCK_SIZE);
	 

	/*Launch Kernel*/
	sgemv_kernel <<<num_blocks, BLOCK_SIZE >>> (Trans, M, N, Alpha , d_A, d_X, d_Y, Beta);


	/* Copy Memory Back to Host */
	if (Trans == 'n' || Trans == 'N') {
		cudaMemcpy(Y, d_Y, sizeof(float) * M , cudaMemcpyDeviceToHost);
	} else {
		cudaMemcpy(Y, d_Y, sizeof(float) * N, cudaMemcpyDeviceToHost);
	}


	/* Free Device Memory*/
	cudaFree(d_A);
	cudaFree(d_X);
	cudaFree(d_Y);
	
	cudaEventRecord(stop, 0);
	float timeElapsed;
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&timeElapsed, start, stop);
	printf("Time Elapsed : %f\n", timeElapsed);
}



int main(int argc, char * argv[]) {
	char Trans; 
	int M, N;
	float Alpha; float Beta;
	float* A; // Matrix A
	float * X;
	float * Y;
	int INCY = 1;


	/* 
		Test Cases are to be input
	*/
	
	scanf("%c %d %d %f %f",&Trans, &M, &N, &Alpha, &Beta );
	
	cudaMallocHost((void**) &A, sizeof(float) * M*N);
	int y_size, x_size; 
	
	if (Trans == 'N' || Trans == 'n') {
		cudaMallocHost((void**) &X, sizeof(float)*N);
		cudaMallocHost((void**) &Y, sizeof(float)*M);
		y_size = M;
		x_size = N;
	} else {
		cudaMallocHost((void**) &X, sizeof(float)*M);
		cudaMallocHost((void**) &Y, sizeof(float)*N);
		y_size = N;
		x_size = M;
	}
	
	//	printf("Y_Size %c %d %d %f %f\n", Trans, y_size, x_size, Alpha, Beta);
	for (int i= 0; i<M;i++) {
		for (int j = 0; j<N;j++) {
			scanf("%f", A + i*N + j);
		}
	}

	for (int i= 0; i<x_size;i++) {
		scanf("%f", X + i);
	}

	for (int i= 0; i<y_size;i++) {
		scanf("%f", Y + i);
	}


	sgemv(Trans, M, N , Alpha, A,X,Y,5);
	/* Display Output */
	FILE * fp;
	fp = fopen("Results/sgemv_gpu_last.txt", "w");
	for(int i =0; i<y_size;i++) {
		fprintf(fp,"%f ", Y[i]);
	}
	fclose(fp);

}
