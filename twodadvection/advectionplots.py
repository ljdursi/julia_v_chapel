#!/usr/bin/env python
import matplotlib.pylab as plt
import matplotlib.cm as cm
import numpy as np
import argparse
import csv

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

def get_numpy_array(filename):
    """
    Reads a julia or chapel CSV into a numpy array
    """
    x = []
    y = []
    data = []
    with open(filename, 'r') as csvfile:
        csvreader = csv.reader(csvfile, delimiter=',')
        for row in csvreader:
            if row[0][0] == '#':
                continue
            x.append(int(row[0]))
            y.append(int(row[1]))
            data.append(float(row[2]))

    xarr = np.array(x)-1
    yarr = np.array(y)-1
    dataarr = np.zeros((max(xarr)+1, max(yarr)+1), dtype=np.double)
    for xi, yi, di in zip(xarr, yarr, data):
        dataarr[xi, yi] = di

    x = np.arange(min(xarr), max(xarr)+1)
    y = np.arange(min(yarr), max(yarr)+1)
    return dataarr, x, y


def plot_three(data1, data2, x, y):
    d1 = np.array(data1)
    d2 = np.array(data2)
    plt.subplots(1, 3)
    plt.subplot(1, 3, 1)
    plot_numpy_array(d1, x, y)
    plt.subplot(1, 3, 2)
    plot_dask_array(d2, x, y)
    plt.subplot(1, 3, 3)
    plot_dask_array(d2-d1, x, y)
    plt.show()

def plot_three_from_files(startfilename, endfilename):
    data1, x1, y1 = get_numpy_array(startfilename)
    data2, x2, y2 = get_numpy_array(endfilename)
    plot_three(data1, data2, x1, y1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('startfile', default="in.csv")
    parser.add_argument('-e', '--endfile', type=str)
    args = parser.parse_args()

    if args.endfile is not None:
        plot_three_from_files(args.startfile, args.endfile)
    else:
        data, x, y  = get_numpy_array(args.startfile)
        plot_numpy_array(data, x, y)
    plt.show()
