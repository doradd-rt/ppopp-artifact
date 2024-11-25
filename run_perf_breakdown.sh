#!/bin/bash

# Input Parameters
VERSION=$1 # v0/v1/v2/v3
KEYSPACE=$2 # 10k/100k/1M/10M/64M
KEY_PER_TX=$3 # 2/5/10/20

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

BIN=${script_dir}/doradd/src/bench/profile-build/ycsb
INPUT_LOG=${script_dir}/doradd/scripts/ycsb/profile-log/ycsb_uniform_no_cont_${KEYSPACE}_${KEY_PER_TX}.txt

sudo taskset -c 4-12 $BIN -n 8 $INPUT_LOG -i exp:1 
