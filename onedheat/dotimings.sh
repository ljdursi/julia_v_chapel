#!/bin/bash

readonly BASE="onedheat"

echo "# Julia"
time julia ./${BASE}.jl 

echo ""
echo "# Chapel"
echo "## Compile:"
export CHPL_TARGET_ARCH="native"
unset CHPL_COMM
unset GASNET_SPAWNFN
time chpl --fast ${BASE}.chpl -o ${BASE}_chpl 
echo "## Run:"
time ./${BASE}_chpl --dataParTasksPerLocale=1

echo ""
echo "# Python"
time python ./${BASE}.py 

