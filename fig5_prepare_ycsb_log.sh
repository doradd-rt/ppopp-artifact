#!/bin/bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Directory and source file
src_dir="${script_dir}/doradd/app/ycsb/gen-log"
src_cc="${src_dir}/generate_ycsb_zipf.cc"

out_dir=${script_dir}/fig5-input-log
mkdir -p $out_dir

cc_cmd="g++ -O3 ${src_cc}"

# Log file names
log_no_cont="ycsb_uniform_no_cont.txt"
log_mod_cont="ycsb_uniform_mod_cont.txt"
log_high_cont="ycsb_uniform_high_cont.txt"

# Function to compile and generate logs if the file doesn't exist
generate_log() {
    local distribution="$1"
    local contention="$2"
    local output_file="$3"
    local hot_keys="$4"

    # Check if the file already exists
    if [ ! -f "$output_file" ]; then
        echo "Generating $output_file..."

        # Adjust NrContKey based on the hot_keys parameter
        sed -i '30s/\(NrContKey = \)[0-9]\(;\)/\1'"$hot_keys"'\2/' $src_cc

        # Compile and run the generator
        pushd $src_dir
        $cc_cmd
        ./a.out -d "$distribution" -c "$contention"

        # Rename the output file
        mv ycsb_uniform_cont.txt "$output_file"
        popd
    else
        echo "$output_file already exists. Skipping generation."
    fi
}

# Check if all the files exist
if [ -f "$log_no_cont" ] && [ -f "$log_mod_cont" ] && [ -f "$log_high_cont" ]; then
    echo "All log files already exist. Skipping generation."
    exit 0
fi

# Generate logs as needed
## 1. No contention (uniform distribution)
if [ ! -f "$log_no_cont" ]; then
    echo "Generating $log_no_cont..."
    pushd $src_dir
    $cc_cmd
    ./a.out -d uniform -c no_cont
    mv ycsb_uniform_no_cont.txt ${out_dir}/ 
    popd
fi

## 2. Mod contention (3 hot keys + uniform distribution)
generate_log "uniform" "cont" "${out_dir}/$log_mod_cont" 3

## 3. High contention (7 hot keys + uniform distribution)
generate_log "uniform" "cont" "${out_dir}/$log_high_cont" 7

echo "Log generation complete."
popd
