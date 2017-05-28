from __future__ import print_function
import numpy as np

n = 500
B = np.random.rand(500, 500)
x = np.random.rand(500)

A = np.outer(x, np.transpose(x))
y = np.dot(B, x)

print(A[0,0])

A = np.eye(n)
y = np.linalg.solve(A, x)

print(np.sum(np.abs(x-y)))
