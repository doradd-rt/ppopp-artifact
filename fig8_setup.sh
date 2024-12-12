#!/bin/bash

# Input Parameters
VERSION=$1 # v0/v1/v2/v3
KEYSPACE=$2 # 10k/100k/1M/10M/64M
KEY_PER_TX=$3 # 2/5/10/20

# Map argument to the corresponding number
case $KEYSPACE in
  10k)
    DB_SIZE=10000
    ;;
  100k)
    DB_SIZE=100000
    ;;
  1M)
    DB_SIZE=1000000
    ;;
  10M)
    DB_SIZE=10000000
    ;;
  64M)
    DB_SIZE=64000000
    ;;
  *)
    echo "Invalid argument. Please use one of: 10k, 100k, 1M, 10M, 64M."
    return 1
    ;;
esac

# Define color codes for highlighting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BOLD='\033[1m'
RESET='\033[0m'  # Reset to default

# Script Directory
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

doradd_dir=${script_dir}/doradd

build_dir=${doradd_dir}/src/bench/profile-build
mkdir -p $build_dir


input_gen_dir=${doradd_dir}/scripts/ycsb
input_log_dir=${input_gen_dir}/profile-log
mkdir -p $input_log_dir


setup_system_variant() {
  # Define build flags based on the version
  case $VERSION in
    v0)
      build_flags="-DRPC_LATENCY -DLOG_LATENCY"
      ;;
    v1)
      build_flags="-DRPC_LATENCY -DLOG_LATENCY -DPREFETCH"
      ;;
    v2)
      build_flags="-DRPC_LATENCY -DLOG_LATENCY -DPREFETCH -DCORE_PIPE -DTEST_TWO"
      ;;
    v3)
      build_flags="-DRPC_LATENCY -DLOG_LATENCY -DPREFETCH -DCORE_PIPE -DINDEXER"
      ;;
    *)
      echo "Invalid version specified. Use one of: v0, v1, v2, v3."
      return 1
      ;;
  esac

  # Run cmake with properly quoted flags
  pushd "$build_dir"
  cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="$build_flags"
  ninja
  popd
}

setup_parameters() {
  # setup KEYSPACE and KEY_PER_TX in the constants.hpp
  parameter_file=${doradd_dir}/src/bench/constants.hpp

  if [[ -f $parameter_file ]]; then
    sed -i "5s/^.*static constexpr uint32_t ROWS_PER_TX .*/static constexpr uint32_t ROWS_PER_TX = $KEY_PER_TX;/" "$parameter_file"
    sed -i "8s/^.*static const uint64_t DB_SIZE .*/static const uint64_t DB_SIZE = $DB_SIZE;/" "$parameter_file"
    echo "Updated ROW_COUNT to $DB_SIZE in $parameter_file."
  else
    echo "Error: parameter_file $parameter_file not found."
    return 1
  fi 

  # modify the rows_per_tx related
  ycsb_file=${doradd_dir}/src/bench/ycsb.cc
  rows_per_tx=$1
  echo "ROWS_PER_TX is $rows_per_tx"
  if ! [[ "$rows_per_tx" =~ ^[0-9]+$ ]]; then
    echo "Error: rows_per_tx must be a numeric value."
    return 1
  fi

  # 1. GET_COWN
  local new_line=""
  for ((i = 0; i < $rows_per_tx; i++)); do
    new_line+="GET_COWN($i); "
  done
  if ! sed -n '91p' "$ycsb_file" | grep -q "GET_COWN"; then
    echo "Warning: Line 91 in $ycsb_file does not contain 'GET_COWN'. Aborting replacement."
    return 1
  fi
  sed -i "91s|.*|$new_line|" "$ycsb_file"

  # 2. GET_ROW
  local new_line_1=""
  for ((i = 0; i < rows_per_tx; i++)); do
    new_line_1+="GET_ROW($i); "
  done
  if ! sed -n '93p' "$ycsb_file" | grep -q "GET_ROW"; then
    echo "Warning: Line 93 in $ycsb_file does not contain 'GET_ROW'. Aborting replacement."
    return 1
  fi
  sed -i "93s|.*|$new_line_1|" "$ycsb_file"

  # 3. When
  local new_line_2="when("
  for ((i = 0; i < rows_per_tx; i++)); do
    new_line_2+="row$i, "
  done
  new_line_2=${new_line_2%, }
  new_line_2+=") << [ws_cap, init_time]"
  if ! sed -n '98p' "$ycsb_file" | grep -q "row"; then
    echo "Warning: Line 98 in $ycsb_file does not contain 'row'. Aborting replacement."
    return 1
  fi
  sed -i "98s|.*|$new_line_2|" "$ycsb_file"

  # 4. acq_type
  local new_line_3="("
  for ((i = 0; i < rows_per_tx; i++)); do
    new_line_3+="AcqType acq_row$i, "
  done
  new_line_3=${new_line_3%, }
  new_line_3+=") {"
  if ! sed -n '103p' "$ycsb_file" | grep -q "Acq"; then
    echo "Warning: Line 103 in $ycsb_file does not contain 'Acq'. Aborting replacement."
    return 1
  fi
  sed -i "103s|.*|$new_line_3|" "$ycsb_file"

  # 5. txn
  local new_line_4=""
  for ((i = 0; i < rows_per_tx; i++)); do
    new_line_4+="TXN($i); "
  done
  if ! sed -n '107p' "$ycsb_file" | grep -q "TXN"; then
    echo "Warning: Line 107 in $ycsb_file does not contain 'TXN'. Aborting replacement."
    return 1
  fi
  sed -i "107s|.*|$new_line_4|" "$ycsb_file"
}

setup_input_gen() {
  local File="${input_gen_dir}/generate_ycsb_zipf.cc"
  
  # setup src code
  if [[ -f $File ]]; then
    sed -i "12s/^.*#define ROW_COUNT .*/#define ROW_COUNT $DB_SIZE/" "$File"
    sed -i "14s/^.*#define ROW_PER_TX .*/#define ROW_PER_TX $KEY_PER_TX/" "$File"
    echo "Updated ROW_COUNT to $DB_SIZE in $File."
  else
    echo "Error: File $File not found."
    return 1
  fi
}

check_and_gen_input_log() {
  # prepare input logs
  input_log="ycsb_uniform_no_cont_${KEYSPACE}_${KEY_PER_TX}.txt"
  input_log_path="${input_log_dir}/${input_log}"

  if [[ ! -f "$input_log_path" ]]; then
    setup_input_gen $KEYSPACE $KEY_PER_TX
    pushd $input_gen_dir
    g++ -O3 generate_ycsb_zipf.cc
    ./a.out -d uniform -c no_cont
    mv ycsb_uniform_no_cont.txt $input_log_path
    popd
  else
    echo "Input log existed; skip generating"
  fi
}

pushd $doradd_dir
git checkout perf-profile
popd

setup_parameters $KEY_PER_TX
setup_system_variant
check_and_gen_input_log

echo -e "${BOLD}${BLUE}Finish the setup for ${VERSION} system and key-space: ${KEYSPACE}, key-per-tx: ${KEY_PER_TX}${RESET}"
