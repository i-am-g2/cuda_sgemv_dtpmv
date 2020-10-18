package main

import (
	"fmt"
	"math/rand"
	"runtime"
	"sync"
	"time"
)

func makeMatrix(M, N int) [][]float32 {
	A := make([][]float32, M)
	for i := 0; i < M; i++ {
		A[i] = make([]float32, N)
	}
	return A
}

func multiply(A [][]float32, X, Y []float32, i int, alpha, beta float32, waitGroup *sync.WaitGroup) {
	defer waitGroup.Done()
	var sum float32 = 0.0
	for j := 0; j < len(X); j++ {
		sum += A[i][j] * X[j]
	}
	sum = sum * alpha
	Y[i] = beta*Y[i] + sum
}

func multiplyB(A [][]float32, X, Y []float32, i int, alpha, beta float32) {
	var sum float32 = 0.0
	for j := 0; j < len(X); j++ {
		sum += A[i][j] * X[j]
	}
	sum = sum * alpha
	Y[i] = beta*Y[i] + sum
}

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())
	// fmt.Println(runtime.NumCPU())
	var N, M int
	var alpha, beta float32
	alpha, beta = rand.Float32()*1024, rand.Float32()*1024
	// fmt.Scan(&N)
	fmt.Scan(&M, &N)
	A := makeMatrix(M, N) // Rows , Column
	X := make([]float32, N)
	Y := make([]float32, M)

	for i := 0; i < M; i++ {
		for j := 0; j < N; j++ {
			// fmt.Scan(&A[i][j])
			A[i][j] = rand.Float32() * 1024
		}
	}

	for i := 0; i < N; i++ {
		X[i] = rand.Float32() * 1024
		// fmt.Scan(&X[i])
	}
	for i := 0; i < M; i++ {
		// fmt.Scan(&Y[i])
		Y[i] = rand.Float32() * 1024
	}
	// fmt.Println("I/O Done")

	Y_Copy := make([]float32, len(Y))
	copy(Y, Y_Copy)

	start := time.Now()
	var waitGroup sync.WaitGroup
	for i := 0; i < M; i++ {
		waitGroup.Add(1)
		go multiply(A, X, Y, i, alpha, beta, &waitGroup)
	}
	waitGroup.Wait()
	end := time.Since(start)

	fmt.Printf("CPU N Threaded : %f\t", time.Duration.Seconds(end)*1000.0)

	t2 := time.Now()
	for i := 0; i < M; i++ {
		multiplyB(A, X, Y_Copy, i, alpha, beta)
	}
	e2 := time.Since(t2)
	fmt.Printf("CPU single Thread : %f\n", time.Duration.Seconds(e2)*1000.0)

}
