#include <stdio.h>
#include <cuda.h>
#include <cuComplex.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#define BLOCK_SIZE 16 // Threads per block supported by the GPU


__global__ void dtpmv_kernel ( char UPLO, char TRANS, char DIAG,int N,double * A, double *X , double *T) {
	int elementId = blockIdx.x * BLOCK_SIZE + threadIdx.x; 

	if(elementId>=N) {
		return;
	}
	double sum = 0;
	if (UPLO == 'U' && TRANS == 'N' ) {
		for (int i = elementId; i<N ; i++) {
			sum += A[elementId *N + i - ((elementId+1)*elementId)/2 ] * X[i];
		}
	} else if (UPLO == 'L' && TRANS == 'N') {

		int temp = (elementId * (elementId +1)) /2;
		for (int i = 0; i <=elementId; i++ ) {
			sum += A[temp+i] * X[i];
		}

	} else if (UPLO == 'U' && TRANS == 'T') {
		for (int i = elementId;i>=0; i--) {
			sum += A[i*N + elementId- ((i+1)*i)/2]*X[i];
		}
	} else {
		for (int i = elementId;i < N; i++) {
			sum += A[i*N + elementId- ((2*N-i-1)*i)/2 ]*X[i];;
		}
	}
	
	T[elementId] = sum;
}

int Ceil (int n , int m) {
	if (n%m == 0) {
		return n/m;
	} else {
		return n/m +1;
	}
}

void dtpmv(char UPLO, char TRANS, char DIAG, int N, double * A, double * X) {

	double * d_A, *d_X, *d_T;
	int size_a = (N*(N+1))/2;

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaEventRecord(start,0);
	cudaMalloc((void**) &d_A, sizeof(double)*size_a );
	cudaMalloc((void**) &d_X, sizeof(double)*N );
	cudaMalloc((void**) &d_T, sizeof(double)*N );

	cudaMemcpy(d_A, A , sizeof(double) *size_a, cudaMemcpyHostToDevice);
	cudaMemcpy(d_X, X, sizeof(double) * N, cudaMemcpyHostToDevice);
	// cudaMemcpy(d_T, X, sizeof(double) * N, cudaMemcpyHostToDevice);
	
	/*Determine Kernel Parameters*/
	int num_blocks = Ceil(N, BLOCK_SIZE);

	/*Launch Kernel*/
	dtpmv_kernel <<<num_blocks, BLOCK_SIZE >>> (UPLO, TRANS, DIAG, N, d_A, d_X, d_T);


	/* Copy Memory Back to Host */
	cudaMemcpy(X, d_T, sizeof(double) * N , cudaMemcpyDeviceToHost);


	/* Free Device Memory*/
	cudaFree(d_A);
	cudaFree(d_X);
	cudaFree(d_T);

	cudaEventRecord(stop, 0);
	float timeElapsed;
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&timeElapsed, start, stop);
	printf("Time Elapsed : %f\n", timeElapsed);
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
	
	for (int i= 0; i<size_a;i++) {
		scanf("%lf", &A[i]);
	}

	for (int i= 0; i<N;i++) {
		scanf("%lf", X + i);
	}

	dtpmv(UPLO, TRANS, DIAG, N, A, X);

	/* Display Output */
	FILE * fp;
	fp = fopen("Results/dtpmv_gpu_last.txt", "w");
	for(int i =0; i<N;i++) {
		fprintf(fp,"%f ", X[i]);
	}
	fclose(fp);
}
