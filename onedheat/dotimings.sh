#!/bin/bash

readonly BASE="onedheat"

echo "# Julia"
time julia ./${BASE}.jl 

echo ""
echo "# Chapel"
echo "## Compile:"
export CHPL_TARGET_ARCH="native"
time chpl --fast ${BASE}.chpl -o ${BASE}_chpl 
echo "## Run:"
time ./${BASE}_chpl 

echo ""
echo "# Python"
time python ./${BASE}.py 

