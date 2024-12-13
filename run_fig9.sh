#!/bin/bash

# script_dir
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# bin dir
bin_dir=$script_dir/doradd/app/pipeline-profile

pushd $bin_dir
git submodule update --init
make clean && make
popd

# Output file for aggregated results
OUTPUT_FILE="pipeline_results.txt"

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Array of core counts to test
CORE_COUNTS=(2 3 4 8 12 16 20 24)

# Experiment type (read or write)
MODES=("read" "write")

# Run experiments
for mode in "${MODES[@]}"; do
  for cnt in "${CORE_COUNTS[@]}"; do
    echo "Running experiment with $cnt cores in $mode mode..."
    
    # Run the experiment and capture the output
    OUTPUT=$(sudo $bin_dir/pipeline "$cnt" "$mode" 2>&1)
    
    # Extract the last throughput line from the output
    LAST_THROUGHPUT=$(echo "$OUTPUT" | grep -oE '[0-9.]+ txn/s' | tail -n 1 | awk '{print $0}')
    echo $LAST_THROUGHPUT
    
    # Record the result
    if [[ -n "$LAST_THROUGHPUT" ]]; then
      echo "Pipeline cores: $cnt; $mode Throughput: $LAST_THROUGHPUT" >> "$OUTPUT_FILE"
    else
      echo "Pipeline cores: $cnt; $mode Throughput: ERROR (no throughput reported)" >> "$OUTPUT_FILE"
    fi
  done
done

echo "Results aggregated in $OUTPUT_FILE"
