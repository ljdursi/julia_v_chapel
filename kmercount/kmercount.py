#!/usr/bin/env python
from __future__ import print_function
import argparse
import collections


def kmer_counts(filename, k):
    sequences = readfasta(filename)
    counts = collections.defaultdict(int)
    for sequence in sequences:
        for i in range(len(sequence)-k+1):
            kmer = sequence[i:i+k]
            counts[kmer] += 1
    return counts


def readfasta(filename):
    sequences = []
    cursequence = ""

    def updatelists():
        if len(cursequence) is not 0:
            sequences.append(cursequence)

    with open(filename, 'r') as infile:
        for line in infile:
            if line[0] == ">":
                updatelists()
                cursequence = ""
            else:
                cursequence += line.strip()

        updatelists()

    return sequences


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', default="input.fa")
    parser.add_argument('-k', type=int, default=11)
    args = parser.parse_args()

    counts = kmer_counts(args.input, args.k)
    for kmer, count in counts.items():
        print(kmer, count)
