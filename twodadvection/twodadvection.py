#!/usr/bin/env python
from __future__ import print_function
import numpy as np
import dask.array as da
from dask.multiprocessing import get as mp_get
import time
import argparse


def advect(dens, dx, dy, dt, u):
    """
    second-order upwind method for 2d advection
    Advects density in some subdomain by velocity u,
    given timestep dt and grid spacing (dx, dy).
    """
    gradx = np.zeros_like(dens)
    grady = np.zeros_like(dens)

    if u[0] > 0.:
        gradx[2:, :] = (3*dens[2:, :] - 4*dens[1:-1, :] + dens[:-2, :])/(2.*dx)
    else:
        gradx[:-2, :] = (-dens[2:, :] + 4*dens[1:-1, :] - 3*dens[:-2, :])/(2.*dx)

    if u[1] > 0.:
        grady[:, 2:] = (3*dens[:, 2:] - 4*dens[:, 1:-1] + dens[:, :-2])/(2.*dy)
    else:
        grady[:, :-2] = (-dens[:, 2:] + 4*dens[:, 1:-1] - 3*dens[:, :-2])/(2.*dy)

    return dens - dt*(u[0]*gradx + u[1]*grady)


def dask_step(subdomain, nguard, dx, dy, dt, u):
    """
    map_overlap applies a function to a subdomain of a dask array,
    filling the guardcells in first
    """
    return subdomain.map_overlap(advect, depth=nguard, boundary='periodic',
                                 dx=dx, dy=dy, dt=dt, u=u)


def initial_conditions(x, y, initial_posx=0.3, initial_posy=0.3, sigma=0.15):
    """Returns a tuple describing the state at the point:
        (x, y, density(x,y))"""
    xx, yy = np.meshgrid(x, y)
    density = np.exp(-((xx-initial_posx)**2 + (yy-initial_posy)**2)/(sigma**2))
    return density


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--ntimesteps', type=np.int, default=100)
    parser.add_argument('-g', '--ngrid', type=np.int, default=101)
    parser.add_argument('-p', '--plot', action="store_true")
    args = parser.parse_args()

    nsteps = args.ntimesteps
    npts = args.ngrid

    x = np.arange(npts, dtype=np.double)/(npts-1)
    y = np.arange(npts, dtype=np.double)/(npts-1)

    u = np.array([1., 1.], dtype=np.double)
    speed = np.sqrt(np.dot(u, u))
    cfl = 0.125

    dx = x[1]-x[0]
    dy = y[1]-y[0]
    dt = cfl*min(dx, dy)/speed

    dens = initial_conditions(x, y)
    subdomain_init = da.from_array(dens, chunks=((npts+1)//2, (npts+1)//2))

    # These create the steps, but they don't actually perform the execution...
    subdomain = dask_step(subdomain_init, 2, dx, dy, dt, u)
    for step in range(1, nsteps):
        subdomain = dask_step(subdomain, 2, dx, dy, dt, u)

    # _this_ performs the execution
    start = time.clock()
    subdomain = subdomain.compute(num_workers=2, get=mp_get)
    print(time.clock() - start, " seconds")

    if args.plot:
        # Plot pretty results
        import matplotlib.pylab as plt
        import matplotlib.cm as cm

        def plot_numpy_array(data, x, y, colorbar=False):
            """
            Plots a subdomain
            """
            extent = (min(x), max(x), min(y), max(y))
            levels = np.linspace(np.min(data), np.max(data), num=5)

            im = plt.imshow(data, interpolation='bilinear', origin='lower',
                            cmap=cm.Blues, extent=extent)
            if colorbar:
                plt.colorbar(im, orientation='vertical', shrink=0.8)
            plt.contour(x, y, data, levels, origin='lower', linewidths=2)

        def plot_dask_array(dadata, x, y, colorbar=False):
            """
            Gathers the dask array to a single numpy array and plots it,
            for the purposes of a demo (obv. wildly implausible for a real
            simulation)
            """
            data = np.array(dadata)
            plot_numpy_array(data, x, y, colorbar)

        plt.subplots(1, 3)
        plt.subplot(1, 3, 1)
        plot_dask_array(subdomain_init, x, y)
        plt.subplot(1, 3, 2)
        plot_dask_array(subdomain, x, y)
        plt.subplot(1, 3, 3)
        plot_dask_array(subdomain-subdomain_init, x, y)
        plt.show()
