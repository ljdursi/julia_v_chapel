#!/bin/bash

readonly BASE="onedheat"
export CHPL_RT_NUM_THREADS_PER_LOCALE=1

echo "# Julia"
time julia ./${BASE}.jl 

echo ""
echo "# Chapel"
echo "## Compile:"
time chpl --fast ${BASE}.chpl -o ${BASE}_chpl 
echo "## Run:"
time ./${BASE}_chpl 

echo ""
echo "# Python"
time python ./${BASE}.py 

