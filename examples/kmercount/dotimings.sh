#!/bin/bash

readonly INFILE=ecoli.fa

echo "# Julia"
time julia ./kmercount.jl "${INFILE}" > julia-out.txt 

echo ""
echo "# Chapel"
echo "## Compile:"
time chpl --fast kmercount.chpl -o kmercount_chpl 
echo "## Run:"
time ./kmercount_chpl --input_filename="${INFILE}" > chapel-out.txt

echo ""
echo "# Python"
time python ./kmercount.py -i "${INFILE}" > python-out.txt 

sort julia-out.txt | grep -v "seconds" > julia-sorted-out.txt
sort python-out.txt > python-sorted-out.txt
sort chapel-out.txt > chapel-sorted-out.txt

echo "# comparing results:"
echo "## python-chapel"
diff python-sorted-out.txt chapel-sorted-out.txt
echo "## python-julia"
diff python-sorted-out.txt julia-sorted-out.txt
echo "## chapel-julia"
diff chapel-sorted-out.txt julia-sorted-out.txt
