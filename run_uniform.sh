#!/bin/bash
#
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

# Determine the `i` array based on WORKLOAD (5usec or 100usec)
if [[ "$WORKLOAD" == "5" ]]; then
    i_array=(100 50 25 20 15 10 9 8 7 6 5 4 3 2 1)
elif [[ "$WORKLOAD" == "100" ]]; then
    i_array=(100 50 25 20 18 16 15 14 13 12 11 10)
else
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
OUT_LOG="${OUT_DIR}/${SERVER}_uniform_${WORKLOAD}.log"

# Client and Replay Log Directories
CLIENT_SRC_DIR="$HOME/rpc-dpdk-client"
REPLAY_LOG="${CLIENT_SRC_DIR}/scripts/gen-replay-log/ycsb_uniform_no_cont.txt"

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

# Highlighted log output
echo -e "${BOLD}${BLUE}Running workload: ${WORKLOAD} on server: ${SERVER}${RESET}"
echo -e "${BOLD}${GREEN}Replay log: ${REPLAY_LOG}${RESET}"
echo -e "${BOLD}${YELLOW}Output log: ${OUT_LOG}${RESET}"
echo -e "${BOLD}${RED}Duration: ${DURATION} seconds${RESET}"

# Run the Client for Each Load Interval
for i in "${i_array[@]}"; do
    echo -e "${BOLD}${GREEN}Running client with interval ${i} (log: ${OUT_LOG})${RESET}"
    
    sudo "${CLIENT_SRC_DIR}/src/build/client" \
        -l 1-10 -- -i "$i" -s "$REPLAY_LOG" -a ycsb -t 192.168.1.2 -d "$DURATION" -l "$OUT_LOG"
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Client failed for interval ${i}"
        exit 1
    fi
done

echo -e "${BOLD}${BLUE}Worload completed successfully: ${WORKLOAD} on server: ${SERVER}${RESET}"
