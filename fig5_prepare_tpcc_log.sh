#!/bin/bash

# Set up script and log directories
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
gen_script=$script_dir/doradd/app/tpcc/gen-log

# Create the log directory if it doesn't exist
mkdir -p $script_dir/input-log
final_log=$script_dir/fig5-input-log

# Function to generate logs if they don't already exist
generate_log() {
  local log_name=$1
  local warehouses=$2

  # Check if the log file already exists
  if [ -f "$final_log/$log_name" ]; then
    echo "$log_name already exists, skipping generation."
  else
    echo "Generating $log_name..."
    python $gen_script/generate_tpcc.py --warehouses "$warehouses"
    mv tpcc.txt "$final_log/$log_name"
  fi
}

# Generate logs with different contention levels
generate_log "tpcc_no_cont.txt" 23
generate_log "tpcc_mod_cont.txt" 8
generate_log "tpcc_high_cont.txt" 1

echo "Finished preparing logs for tpcc."
