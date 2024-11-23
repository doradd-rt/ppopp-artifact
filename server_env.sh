#!/bin/bash
# setup script on the server side before running 

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

# src code dir
DORADD_DIR="$HOME/doradd-server"
CALADAN_DIR="$HOME/caladan"

if ! [[ "$WORKLOAD" == "5" || "$WORKLOAD" == "100" ]]; then
    echo -e "${RED}Error: Invalid WORKLOAD value. Use 5 or 100.${RESET}"
    exit 1
fi

# Validate SERVER
if [[ "$SERVER" != "DORADD" && "$SERVER" != "Non-deter-spin" && "$SERVER" != "Non-deter-async" ]]; then
    echo -e "\033[0;31mError: Invalid SERVER value. Use DORADD, Non-deter-spin, or Non-deter-async.\033[0m"
    exit 1
fi

# Define functions for each server type
setup_doradd() {
    echo "Setting up server for DORADD with workload $WORKLOAD"
    pushd $DORADD_DIR
    git checkout -- src/ycsb.h
    git checkout single-dispatcher 

    # set workload spin time
    NEW_LINE="static constexpr long SPIN_TIME = $1'000;"
    FILE="$DORADD_DIR/src/ycsb.h"
    sed -i "11s|.*|$NEW_LINE|" "$FILE"

    pushd src/build
    ninja
    popd

    popd
}

setup_non_deter_spin() {
    echo "Setting up server for Non-deter-spin with workload $WORKLOAD"
    pushd $DORADD_DIR
    git checkout -- src/ycsb.h
    git checkout non-deter 

    # set workload spin time
    NEW_LINE="static constexpr long SPIN_TIME = $1'000;"
    FILE="$DORADD_DIR/src/ycsb.h"
    sed -i "13s|.*|$NEW_LINE|" "$FILE"

    pushd src/build
    ninja
    popd

    popd
}

setup_non_deter_async() {
    echo "Setting up server for Non-deter-async with workload $WORKLOAD"
}

# Match SERVER and call appropriate function
case "$SERVER" in
    "DORADD")
        setup_doradd $WORKLOAD
        ;;
    "Non-deter-spin")
        setup_non_deter_spin $WORKLOAD
        ;;
    "Non-deter-async")
        setup_non_deter_async $WORKLOAD
        ;;
esac

echo "Server setup completed for $SERVER with workload $WORKLOAD"
