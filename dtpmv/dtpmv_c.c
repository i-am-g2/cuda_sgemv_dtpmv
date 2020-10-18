#include <stdio.h>
#include <time.h>
#include <stdlib.h>
	

void dtpmv( char UPLO, char TRANS, char DIAG,int N,double * A, double *X , double *T) {
	for (int elementId = 0; elementId < N; elementId ++) {
		
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
}

int main() {
	char UPLO, TRANS, DIAG; 
	int N; int Incx;
	double * A, *X, *T;
	/* 
		Test Cases are to be input
	*/
	
	scanf("%c %c %c %d",&UPLO,&TRANS, &DIAG,  &N);
	
	int size_a = (N* (N+1))/2;
	
	A = (double *) malloc(sizeof(double)*size_a);	
	X = (double *) malloc(sizeof(double)*N);
	T = (double *) malloc(sizeof(double)*N);

	for (int i= 0; i<size_a;i++) {
		scanf("%lf", &A[i]);
	}

	for (int i= 0; i<N;i++) {
		scanf("%lf", X + i);
	}

	clock_t start, end; double timeElapsed;
	start = clock();
	dtpmv(UPLO, TRANS, DIAG, N, A, X,T);
	end = clock();
	
	/* Display Output */
	FILE * fp;
	fp = fopen("Results/dtpmv_cpu_last.txt", "w");
	for(int i =0; i<N;i++) {
		fprintf(fp,"%f ", T[i]);
	}
	fclose(fp);
	printf("Time Elapsed : %lf\n", (((double) (end-start))/CLOCKS_PER_SEC)*1000.0);
}
