#!/bin/bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

doradd_dir=$script_dir/doradd
# set doradd branch
pushd $doradd_dir
git checkout perf-profile
popd

result_dir=$script_dir/fig8-results
mkdir -p $result_dir

run_one() {
  # rm old results
  rm -rf $result_dir/*.log

  # setup
  $script_dir/fig8_setup.sh $1 $2 $3 

  # run one
  $script_dir/run_perf_breakdown.sh $1 $2 $3

  pushd $result_dir
  log_name=$(ls exp*)
  agg_log="$1_$2_$3.txt"

  # get the throughput
  awk '/^[0-9]+\.[0-9]+$/ {last_float=$0} END {print last_float}' $log_name > $agg_log
  popd
}

run_fig8_a() {
  for v in v0 v1 v2 v3; do 
    for c in 10k 100k 1M 10M 64M; do
      run_one $v $c 10
    done
  done
}

run_fig8_b() {
  for v in v0 v1 v2 v3; do 
    for n in 2 5 10 20; do
      run_one $v 10M $n
    done
  done
}

run_fig8_a
run_fig8_b
