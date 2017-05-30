#!/bin/bash

readonly INFILE=ecoli.fa
readonly BASE=kmercount

echo "# Julia"
time julia ./${BASE}.jl "${INFILE}" > julia-out.txt 

echo ""
echo "# Chapel"
echo "## Compile:"
export CHPL_TARGET_ARCH="native"
unset CHPL_COMM
unset GASNET_SPAWNFN
time chpl --fast ${BASE}.chpl -o ${BASE}_chpl 
echo "## Run:"
time ./${BASE}_chpl --input_filename="${INFILE}" --dataParTasksPerLocale=1 > chapel-out.txt

echo ""
echo "# Python"
time python ./${BASE}.py -i "${INFILE}" > python-out.txt 

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
