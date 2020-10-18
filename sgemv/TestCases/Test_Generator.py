from random import randint
from random import uniform
import sys
import numpy as np
np.set_printoptions(suppress=True,
   formatter={'float_kind':'{:f}'.format})


# Trans = 'N' if randint(1,10)>5 else 'T'
Trans = 'N'
# M = randint(1, 1024)
# N = randint(1, 1024)
Alpha = uniform(0, 1024)
Beta = uniform(0, 1024)
M = N = int(sys.argv[1])

A_Mat = [[uniform(0,1024) for x in range(N)] for y in range(M)]

if Trans == 'N':	
	X_vec = [uniform(0,1024) for i in range(N)]
	Y_vec = [uniform(0,1024) for i in range(M)]
	
	# print(M,N)
	npx = np.array(X_vec).reshape(N,1)
	npy = np.array(Y_vec).reshape(M,1)
	npa = np.array(A_Mat)
	# print(npa.shape, npx.shape)
	ANS_V =  Alpha * np.matmul(npa ,npx ) + Beta*npy  
	# print(ANS_V.astype(float))
else :
	X_vec = [uniform(0,1024) for i in range(M)]
	Y_vec = [uniform(0,1024) for i in range(N)]
	# ANS_V = Beta*np.array(Y_vec) + Alpha * np.matmul(np.transpose(np.array(A_Mat)) , np.transpose(np.array([X_vec])) )

print(Trans, M , N , Alpha , Beta)
for elem in A_Mat:
	for x in elem:
		print(x, end=" ")
	print()

for elem in X_vec:
	print(elem, end=" ")
print()
for elem in Y_vec:
	print(elem, end=" ")
print()


print("--------------------------------")
print(ANS_V)

