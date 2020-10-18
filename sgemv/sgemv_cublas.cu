#include <stdio.h>
#define IDX2C(i,j,ld) (((j)*(ld))+(i))
#include <cuda.h>
#include <cuda_runtime.h>
#include "cublas_v2.h"

/* Cublas Works in Column Major and 1 based indexing :: TAKE CARE OF THIS*/

void sgemv(char Trans, int M, int N, float Alpha, float* A, float * X, float*Y , float Beta) {
	float * d_A, *d_X, *d_Y;

	cublasHandle_t handle;
	cublasCreate_v2(&handle);
	
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	cudaEventRecord(start, 0);

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
	

	if (Trans == 'N') {
		cublasSgemv(
					handle, CUBLAS_OP_N,  
					M, N, 
					&Alpha, 
					d_A, M, 
					d_X, 1,
					&Beta, 
					d_Y, 1 
				);
	} else {
		cublasSgemv(handle, CUBLAS_OP_T,  M, N, &Alpha,  d_A, M, d_X, 1,&Beta, d_Y, 1 );
	}


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

	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);	
	float timeElapsed;
	cudaEventElapsedTime (&timeElapsed, start, stop);
	printf("Time Elapsed : %f ms\n", timeElapsed);
}



int main(int argc , char * argv[]) {
	char Trans; 
	int M, N;
	float Alpha; float Beta;
	float* A; // Matrix A
	float * X;
	float * Y;
	const int INCY = 1;

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
	

	for (int i= 0; i<M;i++) {
		for (int j = 0; j<N;j++) {
			scanf("%f", A + j*M + i);
		}
	}

	for (int i= 0; i<x_size;i++) {
		scanf("%f", X + i);
	}

	for (int i= 0; i<y_size;i++) {
		scanf("%f", Y + i);
	}

	/* Cublas Call */
	


	sgemv(Trans, M, N , Alpha, A,X,Y,Beta);
	/* Display Output */
	FILE * fp;
	fp = fopen("Results/sgemv_cublas_last.txt", "w");
	for(int i =0; i<y_size;i++) {
		fprintf(fp,"%lf ", Y[i]);
	}
	fclose(fp);

}
