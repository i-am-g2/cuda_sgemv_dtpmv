
CPU_C=sgemv_cpu.c
GPU_CUBLAS=sgemv_cublas.cu
GPU_Self=sgemv_gpu.cu

gcc -O3 $CPU_C
echo "----------------------------------------"
echo "CPU Implementation with -O3 optimisation level"
for ((i = 2 ; i <= 1024  ; i = i * 2)); do
	echo -n -e "Dimension : $i $i\t\t\t" &&	./a.out < TestCases/case_$i.txt
done

gcc $CPU_C
echo "----------------------------------------"
echo "CPU Implementation with NO optimisation level"
for ((i = 2 ; i <= 1024  ; i = i * 2)); do
	echo -n -e "Dimension : $i $i\t\t\t" &&	./a.out < TestCases/case_$i.txt
done

nvcc $GPU_CUBLAS -lcublas 
echo "----------------------------------------"
echo "GPU Implementation with Cublas"
for ((i = 2 ; i <= 1024  ; i = i * 2)); do
	echo -n -e "Dimension : $i $i\t\t\t" &&	./a.out < TestCases/case_$i.txt
done


nvcc $GPU_Self 
echo "----------------------------------------"
echo "GPU Implementation Self "
for ((i = 2 ; i <= 1024  ; i = i * 2)); do
	echo -n -e "Dimension : $i $i\t\t\t" &&	./a.out < TestCases/case_$i.txt
done

# go build go_cpu.go
echo "----------------------------------------"
echo "CPU Implementation with Go "
for ((i = 2 ; i <= 1024  ; i = i * 2)); do
	echo -n -e "Dimension : $i $i\t\t\t" 
	echo "$i $i"| ./go_cpu  
done



# go build go_cpu_pooled.go
echo "----------------------------------------"
echo "CPU Implementation with 8 Pooled Threads "
for ((i = 2 ; i <= 1024  ; i = i * 2)); do
	echo -n -e "Dimension : $i $i\t\t\t" 
	echo "$i $i"| ./go_cpu_pooled
done
