#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
src_dir=$script_dir/doradd/app
build_dir=$src_dir/build

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  # TODO: mod flag as core_count
  flag=0
  contention=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -c | --contention)
      contention="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${contention-}" ]] && die "Missing required parameter: contention"
  case "$contention" in
    "no" | "mod" | "high" | "split")
        # echo "contention: $contention"
        ;;
    *)
        echo "Error: Invalid parameter. It must be 'no', 'mod', 'high', or 'split'."
        exit 1
        ;;
  esac

  # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors

# script logic here

check_pattern() {
  # Check if the line matches the expected pattern
  # $1: line_number, $2: file, $3: pattern
  if ! sed -n "$1p" "$2" | grep -qF "$3"; then
    msg "Error: Line $1 in $2 does not match split macro."
    exit 1
  fi
}

split_txn_setup() {
  # Uncomment WAREHOUSE_SPLIT macro to enable dorad-split

  local file="${src_dir}/CMakeLists.txt"
  local pattern="#add_compile_definitions(WAREHOUSE_SPLIT)"
  local line_number=67

  check_pattern $line_number $file $pattern

  # Modify the line by removing a '#' at the beginning
  sed -i "${line_number}s/^#//" "$file"
  cd ${build_dir} && ninja
}

check_cmake_build() {
  mkdir -p $build_dir && cd $build_dir
  cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-DRPC_LATENCY -DLOG_LATENCY"
  ninja
}

contention_setup() {
  # config warehouse cnts and replayed logs
  local file="${src_dir}/tpcc/constants.hpp"
  local pattern="const uint32_t NUM_WAREHOUSES = *"
  local line_number=9

  check_pattern $line_number $file $pattern

  set_warehouse() {
    sed -i "${line_number}s/= [0-9]\{1,2\}/= $1/" "$file"
  }

  set_tbl_size() {
    for line in 111 112; do
      sed -i "${line}s/ [0-9]\{1,2\}/ $1/" "$file"
    done
  }

  case "$contention" in
    "no" )
      msg "no contention"
      set_warehouse 23
      set_tbl_size 1
      ;;
    "mod" )
      msg "mod contention"
      set_warehouse 8
      set_tbl_size 2
      ;;
    "high" )
      msg "high contention"
      set_warehouse 1
      set_tbl_size 30
      ;;
    "split" )
      msg "high contention (split)"
      set_warehouse 1
      set_tbl_size 30
      split_txn_setup
      ;;
 esac
  check_cmake_build
  cd ${build_dir} && ninja
}

contention_setup
