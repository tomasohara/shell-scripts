#! /bin/bash
#
# Run nvidia-smi in background N times with a delay of S seconds
#
n=40
s=0.25
if [ "$1" != "" ]; then n="$1"; fi
if [ "$2" != "" ]; then s="$2"; fi
for (( i=0; i<$n; i++ )); do  nvidia-smi; sleep $s; done

