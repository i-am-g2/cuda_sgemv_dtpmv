#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include "cublas_v2.h"
#define BLOCK_SIZE 16 // Threads per block supported by the GPU

void dtpmv(char UPLO, char TRANS, char DIAG, int N, double * A, double * X) {

	double * d_A, *d_X;
	int size_a = (N*(N+1))/2;

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	cudaEventRecord(start, 0);

	cudaMalloc((void**) &d_A, sizeof(double)*size_a );
	cudaMalloc((void**) &d_X, sizeof(double)*N );

	cudaMemcpy(d_A, A , sizeof(double) *size_a, cudaMemcpyHostToDevice);
	cudaMemcpy(d_X, X, sizeof(double) * N, cudaMemcpyHostToDevice);
	
	cublasHandle_t handle;
	cublasCreate_v2(&handle);

	auto cudaUPLOMode = CUBLAS_FILL_MODE_UPPER;
	auto transMode = CUBLAS_OP_N;
	if (UPLO == 'L') {
		cudaUPLOMode = CUBLAS_FILL_MODE_LOWER;
	}
	if (TRANS=='T') {
		transMode = CUBLAS_OP_T;
	}

	cublasDtpmv(handle, cudaUPLOMode, transMode, CUBLAS_DIAG_NON_UNIT,N, d_A, d_X, 1);

	/* Copy Memory Back to Host */
	cudaMemcpy(X, d_X, sizeof(double) * N , cudaMemcpyDeviceToHost);

	/* Free Device Memory*/
	cudaFree(d_A);
	cudaFree(d_X);

	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	float timeElapsed;
	cudaEventElapsedTime (&timeElapsed, start, stop);
	printf("Time Elapsed : %f ms\n", timeElapsed);
}



int main() {
	char UPLO, TRANS, DIAG; 
	int N; int Incx;
	double * A, *X;
	/* 
		Test Cases are to be input
	*/
	
	scanf("%c %c %c %d",&UPLO,&TRANS, &DIAG,  &N);
	
	int size_a = (N* (N+1))/2;
	cudaMallocHost((void**) &A, sizeof(double)*size_a );
	cudaMallocHost((void**) &X, sizeof(double)*N);
	
	for (int i =0; i<N;i++) {
		for(int j = 0;j<N;j++) {
			if(i>j) {continue;}
			scanf("%lf", &A[i + (j*(j+1))/2]);
		}
	}
	
	for (int i= 0; i<N;i++) {
		scanf("%lf", X + i);
	}

	dtpmv(UPLO, TRANS, DIAG, N, A, X);

	// Display Outpu
	FILE * fp;
	fp = fopen("Results/dtpmv_cublas_last.txt", "w");
	for(int i =0; i<N;i++) {
		fprintf(fp,"%f ", X[i]);
	}
	fclose(fp);

}
