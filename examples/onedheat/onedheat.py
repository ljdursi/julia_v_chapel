#!/usr/bin/env python
from __future__ import print_function
from numba import jit
import numpy as np
import argparse
import time

@jit('f8[:](i4, i4, f8, f8, f8, f8, f8)', nopython=True)
def onedheat(ngrid, ntimesteps, kappa, xleft, xright, tleft, tright):
    dx = (xright-xleft)/(ngrid-1)
    dt = 0.25*dx*dx/kappa

    temp = np.zeros(ngrid+2, dtype=np.double)
    temp_new = np.zeros(ngrid+2, dtype=np.double)
    temp[0], temp[ngrid+1] = tleft, tright

    for iteration in range(ntimesteps):
        temp_new[1:ngrid] = temp[1:ngrid] + kappa*dt/(dx*dx)*\
            (temp[2:ngrid+1] - 2.*temp[1:ngrid] + temp[0:ngrid-1])

        temp[1:ngrid] = temp_new[1:ngrid]

    return temp[1:ngrid]

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--ntimesteps', type=np.int, default=10000)
    parser.add_argument('-g', '--ngrid', type=np.int, default=1001)
    parser.add_argument('-k', '--kappa', type=np.double, default=1.0)
    parser.add_argument('-L', '--xleft', type=np.double, default=0.)
    parser.add_argument('-R', '--xright', type=np.double, default=1.)
    parser.add_argument('-l', '--tleft', type=np.double, default=-1.)
    parser.add_argument('-r', '--tright', type=np.double, default=+1.)
    args = parser.parse_args()

    start = time.clock()
    temps = onedheat(args.ngrid, args.ntimesteps, args.kappa, args.xleft, args.xright, args.tleft, args.tright)
    print(time.clock() - start)
    print(temps[args.ngrid//2])
