package main

import (
	"fmt"
	"math/rand"
	"runtime"
	"time"
)

func makeMatrix(M, N int) [][]float32 {
	A := make([][]float32, M)
	for i := 0; i < M; i++ {
		A[i] = make([]float32, N)
	}
	return A
}

type Result struct {
	id    int
	value float32
}

func worker(A [][]float32, X, Y []float32, jobs <-chan int, alpha, beta float32, resultch chan<- Result) {
	for i := range jobs {
		// fmt.Println("Working", i)
		var sum float32 = 0.0
		for j := 0; j < len(X); j++ {
			sum += A[i][j] * X[j]
		}
		sum = sum * alpha
		res := beta*Y[i] + sum
		print()
		resultch <- Result{id: i, value: res}
	}

}

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())
	// fmt.Println(runtime.NumCPU())

	var N, M int
	var alpha, beta float32

	fmt.Scan(&M, &N)
	alpha = rand.Float32() * 1024
	beta = rand.Float32() * 1024

	A := makeMatrix(M, N) // Rows , Column
	X := make([]float32, N)
	Y := make([]float32, M)

	for i := 0; i < M; i++ {
		for j := 0; j < N; j++ {
			A[i][j] = rand.Float32() * 1024
			// fmt.Scan(&A[i][j])
		}
	}

	for i := 0; i < N; i++ {
		// fmt.Scan(&X[i])
		X[i] = rand.Float32() * 1024
	}
	for i := 0; i < M; i++ {
		Y[i] = rand.Float32() * 1024
		// fmt.Scan(&Y[i])
	}
	// fmt.Println("I/O Done")

	jobs := make(chan int, M)
	resultCh := make(chan Result, M)

	/* Start worker */
	for w := 0; w < 8; w++ {
		go worker(A, X, Y, jobs, alpha, beta, resultCh)
	}

	st := time.Now()
	/* Produce Job */
	for i := 0; i < M; i++ {
		jobs <- i
	}
	close(jobs)

	for i := 0; i < M; i++ {
		tmp := <-resultCh
		Y[tmp.id] = tmp.value
	}
	en := time.Since(st)
	fmt.Printf("CPU Thread Pooled %f\n", time.Duration.Seconds(en)*1000.0)

	// fmt.Scan(&N)
	// fmt.Println(Y)

}
