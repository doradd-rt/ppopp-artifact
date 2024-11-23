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

# incoming load config for Non-deter-async
i_5=(5 8 12 20 25)
i_100=(125 125 150 200 250)
# Select the appropriate -i values array
if [[ "$WORKLOAD" == "5" ]]; then
    i_values=("${i_5[@]}")  # Use the 1st array
elif [[ "$WORKLOAD" == "100" ]]; then
    i_values=("${i_100[@]}")  # Use the 2nd array
else
    echo -e "\033[0;31mError: Invalid WORKLOAD value. Use 5 or 100.\033[0m"
    exit 1
fi

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

DURATION=60

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
for idx in "${!zipf_array[@]}"; do
    zipf_s=${zipf_array[$idx]}
    # Determine the -i value based on SERVER
    if [[ "$SERVER" == "Non-deter-async" ]]; then
        i_value=${i_values[$idx]}  # Use the specific values
    else
        i_value=2
    fi
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
        -l 1-10 -- -i $i_value -s "$REPLAY_LOG" -a ycsb -t 192.168.1.2 -d "$DURATION" -l "$OUT_LOG" -p 5000
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Client failed for interval ${i}"
        exit 1
    fi
done

echo -e "${BOLD}${BLUE}Worload completed successfully: ${WORKLOAD} on server: ${SERVER}${RESET}"
