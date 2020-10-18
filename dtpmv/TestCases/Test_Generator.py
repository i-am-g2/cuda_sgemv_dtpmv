from random import randint
from random import uniform
import sys
import numpy as np
np.set_printoptions(suppress=True,
   formatter={'float_kind':'{:f}'.format})


# Trans = 'N' if randint(1,10)>5 else 'T'
Trans = 'N'
Alpha = uniform(0, 1024)
Beta = uniform(0, 1024)
M = N = int(sys.argv[1])

A_Mat = [[uniform(0,1024) for x in range(N)] for y in range(N)]

X_vec = [uniform(0,1024) for i in range(N)]
print('U', 'N' , 'D' , N)

t = (N* (N+1))/2
for elem in A_Mat:
	for x in elem:
		t = t -1
		print(x, end=" ")
		if t == 0: 
			break
	# print()
	if t == 0: 
		break
print()
for elem in X_vec:
	print(elem, end=" ")
print()
