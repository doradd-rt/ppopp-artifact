#!/bin/bash

# Check if $1 and $2 are specified
if [[ -z "$1" || -z "$2" ]]; then
    echo -e "\033[0;31mError: Please specify both SERVER and WORKLOAD.\033[0m"
    echo "Usage: $0 <SERVER> <WORKLOAD>"
    echo "WORKLOAD options: 5 or 100"
    exit 1
fi

# Input Parameters
SERVER=$1 # DORADD/Non-deter-spin/Non-deter-async
WORKLOAD=$2 # 5/100

zipf_array=(0.50 0.80 0.90 0.95 0.99)

if ! [[ "$WORKLOAD" == "5" || "$WORKLOAD" == "100" ]]; then
    echo -e "${RED}Error: Invalid WORKLOAD value. Use 5 or 100.${RESET}"
    exit 1
fi

# Define color codes for highlighting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BOLD='\033[1m'
RESET='\033[0m'  # Reset to default

DURATION=50

# Script Directory
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
OUT_DIR=${script_dir}/results
mkdir -p $OUT_DIR

# Client and Replay Log Directories
CLIENT_SRC_DIR="$HOME/rpc-dpdk-client"

# Highlighted log output
echo -e "${BOLD}${BLUE}Running workload: ${WORKLOAD} on server: ${SERVER}${RESET}"
echo -e "${BOLD}${RED}Duration: ${DURATION} seconds${RESET}"

# Run the Client for zipfian log 
for zipf_s in "${zipf_array[@]}"; do
    OUT_LOG="${OUT_DIR}/${SERVER}_zipfian_${zipf_s}_${WORKLOAD}usec.log"
    REPLAY_LOG="${CLIENT_SRC_DIR}/scripts/gen-replay-log/ycsb_zipfian_${zipf_s}_no_cont.txt"

    # Validate Replay Log Exists
    if [[ ! -f $REPLAY_LOG ]]; then
      echo "Error: Replay log not found: $REPLAY_LOG"
      exit 1
    fi

    # Ensure Output Log Does Not Already Exist
    if [[ -f $OUT_LOG ]]; then
      echo "Error: Output log already exists: $OUT_LOG"
      exit 1
    fi

    echo -e "${BOLD}${GREEN}Replay log: ${REPLAY_LOG}${RESET}"
    echo -e "${BOLD}${YELLOW}Output log: ${OUT_LOG}${RESET}"
   
    sudo "${CLIENT_SRC_DIR}/src/build/client" \
        -l 1-10 -- -i 5 -s "$REPLAY_LOG" -a ycsb -t 192.168.1.2 -d "$DURATION" -l "$OUT_LOG"
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Client failed for interval ${i}"
        exit 1
    fi
done

echo -e "${BOLD}${BLUE}Worload completed successfully: ${WORKLOAD} on server: ${SERVER}${RESET}"
