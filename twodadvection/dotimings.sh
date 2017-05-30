#!/bin/bash

readonly BASE="twodadvection"
echo "# Julia"
time julia -p 1 ./${BASE}.jl 
time julia -p 8 ./${BASE}.jl 

echo ""
echo "# Chapel"
echo "## Compile:"
export CHPL_TARGET_ARCH="native"
time chpl --fast ${BASE}_stencildist.chpl -o ${BASE}_chpl 
echo "## Run:"
export SSH_SERVERS="127.0.0.1 127.0.0.1 127.0.0.1 127.0.0.1 127.0.0.1 127.0.0.1 127.0.0.1 127.0.0.1"
time ./${BASE}_chpl -nl 1 --dataParTasksPerLocale=8
time ./${BASE}_chpl -nl 8 --dataParTasksPerLocale=1

echo ""
echo "# Python"
time python ./${BASE}.py 

