# -*- coding: utf-8 -*-
"""Untitled6.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1AC-bTPI-VeB1KQcWdrExiCVWfoF2IAoi
"""

X = [2,4,8,16,32,64,128,256,512,1024]
X= [1,2,3,4,5,6,7,8,9,10]
cpu_o3 = [0.001000, 0.001000 , 0.002000, 0.002000 , 0.002000, 0.007000 ,0.026000 ,0.097000 , 0.378000, 1.559000  ]
cpu_normal = [0.002000, 0.002000, 0.002000, 0.003000 , 0.005000, 0.015000, 0.056000, 0.220000, 0.873000, 3.473000]

GPU_CUBLAS = [
0.143936,
0.123136,
0.158304,
0.123904,
0.126496,
0.123296,
0.127968,
0.147648,
0.211872,
0.652000
]

CPU_8 = [
0.002700,
0.004653,
0.003284,
0.013968,
0.008161,
0.017612,
0.045952,
0.118012,
0.278098,
0.587982
]

GPU_Self= [
0.240000,
0.240064,
0.251456,
0.261376,
0.241856,
0.243680,
0.258080,
0.292000,
0.418048,
1.036544
]

CPU_N_THREAD = [
0.010812,	
0.011888,	
0.023960,	
0.031971,	
0.068477,	
0.109841,	
0.241875,	
0.400537,	
0.621271,	
0.939994
]

CPU_GO_single = [
0.000174,
0.000223,
0.000320,
0.000798,
0.002512,
0.009329,
0.037809,
0.149455,
0.583689,
2.333565,
]

# Commented out IPython magic to ensure Python compatibility.
import matplotlib.pyplot as plt
# %matplotlib inline

plt.plot(X,CPU_GO_single , marker ='o', label='CPU_GO_single')
plt.plot(X, CPU_N_THREAD, marker ='o', label= 'CPU_N_THREAD' )
plt.plot(X, GPU_Self, marker ='o', label= 'GPU')
plt.plot(X, CPU_8,marker ='o' , label= 'CPU_8_Pooled_THREAD')
plt.plot(X, cpu_o3, marker ='o', label= 'CPU_O3')
plt.plot(X, cpu_normal,marker ='o', label= 'CPU')
plt.plot(X, GPU_CUBLAS,marker ='o', label= 'GPU_CUBLAS')
plt.legend()
plt.xlabel("Log base 2 of Matrix Dimension")
plt.ylabel("Time in ms")
plt.savefig('Comparision.svg', dpi=300)
plt.show()

