#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void sgemv(char Trans, int M, int N, float Alpha, float* A, float * X, float*Y , float Beta) {
	int y_size = (Trans == 'n' || Trans == 'N')? M:N;
	int x_size = (Trans == 'n' || Trans == 'N')? N:M;

	for(int i= 0; i<y_size; i++) {
		float sum = 0;
		for (int j = 0; j<x_size ; j++) {
			if (Trans == 'N' || Trans == 'n') {
				sum += A[i *x_size  + j] * X[j];
			} else {
				sum += A[j *y_size  + i] * X[j];
			}
		}
		sum *=  Alpha;
		Y[i] = Y[i] * Beta + sum;
	}	
}


int main() {
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
	
	A = (float * )malloc(sizeof(float) * M*N);
	
	if (Trans == 'N' || Trans == 'n') {
		X = (float * )malloc(sizeof(float) * N); 
		Y = (float * )malloc(sizeof(float) * M);
	} else {
		X = (float * )malloc(sizeof(float) * M); 
		Y = (float * )malloc(sizeof(float) * N);
	}

	int x_size = (Trans == 'N' || Trans == 'n')? N : M;
	int y_size = (Trans == 'N' || Trans == 'n')? M : N;

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

	clock_t start, end; float timeElapsed;

	start = clock();
	sgemv(Trans, M, N , Alpha, A,X,Y,Beta);
	end = clock();

	/* Display Output */
	
	FILE * fp;
	fp = fopen("Results/sgemv_cpu_last.txt", "w");
	for(int i =0; i<y_size;i++) {
		fprintf(fp,"%f ", Y[i]);
	}
	fclose(fp);

	printf("Time Elapsed : %lf\n", (((float) (end-start))/CLOCKS_PER_SEC)*1000.0);
}
