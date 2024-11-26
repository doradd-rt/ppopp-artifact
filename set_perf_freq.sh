#!/bin/bash

core_count=$(nproc)

# Set the CPU frequency governor to "performance" for all available cores
for ((i=0; i<core_count; i++))
do
    cpufreq-set -g performance -c $i
done

echo "Set CPU frequency governor to 'performance' for all $core_count cores."
