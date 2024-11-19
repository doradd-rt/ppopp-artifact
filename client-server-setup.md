# Instructions

1. Install dependencies and setup DPDK on Ubuntu 22.04 
    
    ```bash
    sudo apt update
    sudo apt install -y meson python3-pyelftools cmake pkg-config
    
    wget https://content.mellanox.com/ofed/MLNX_OFED-24.04-0.6.6.0/MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64.tgz --no-check-certificate
    tar -xvzf MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64.tgz
    pushd MLNX_OFED_LINUX-24.04-0.6.6.0-ubuntu22.04-x86_64
    sudo ./mlnxofedinstall --force --upstream-libs --dpdk
    sudo /etc/init.d/openibd restart
    popd
    ```
    
2. Setup the client 
    
    ```bash
    git submodule update --init
    make dpdk
    cd scripts && sudo ./hugepages.sh 
    cd ../src && mkdir build && cd build
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DYCSB=True -DEXPONENTIAL=True
    ```
    
3. Setup the server
    
    ```bash
    git submodule update --init
    make dpdk
    cd scripts && sudo ./hugepages.sh 
    cd ../src && mkdir build && cd build
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release
    ```
    
4. Modify the port id and mac address accordingly
    
    **[TODO]**: add setup for d6515 or other potential nodes?
    
    For instance, if you are using two c6525-25g nodes (with no-interswitch link), choose the mlx5 interface - `enp65s0f0np0`. Then you should obtain (1) its **mac address** (using `ip link` or `ifconfig`) and 2) **dpdk port id** as follows.
    To figure out port mapping, use the `<DPDK_DIR>/usertools/dpdk-devbind.py -s`. You will see output similar to below. Given `enp65s0f0np0` is the 3rd port listed, `PORT_ID` is 2.
    ```bash
    Network devices using kernel driver
    ===================================
    0000:01:00.0 'MT27800 Family [ConnectX-5] 1017' if=eno33np0 drv=mlx5_core unused=vfio-pci *Active*
    0000:01:00.1 'MT27800 Family [ConnectX-5] 1017' if=eno34np1 drv=mlx5_core unused=vfio-pci
    0000:41:00.0 'MT27800 Family [ConnectX-5] 1017' if=enp65s0f0np0 drv=mlx5_core unused=vfio-pci
    0000:41:00.1 'MT27800 Family [ConnectX-5] 1017' if=enp65s0f1np1 drv=mlx5_core unused=vfio-pci
    ```
    Then, one should make the following modifications on each of the used machines.

    1. in the `src/arp-config.h`, modify the Nth entry in `char* apr_entries[]` as this mac address (using `ip link` or `ifconfig`). `N` is aligned to the last digit of the local ip (given the configured L2 forwarding rule). For instance, picking the 3rd entry is because that we set up a `192.168.1.3` as default ip (line 11 in `src/config.h`) for the client. 
    
    2. in `src/config.h`, modify `PORT_ID` as 2.

    
6. Run the server

    ```bash
    sudo taskset -c 1-12 ./server
    ```
    
    
8. Run the client
    1. prepare the ycsb logs (**[TODO]**)
    2. run the client
    
    ```bash
    sudo ./client -l 4-12 -- -i 100 -s ~/rpc-dpdk-client/scripts/gen-replay-log/ycsb_uniform_no_cont.txt -a ycsb -t 192.168.1.2 -d 30 -l /tmp/test.log
    ```

### Issues / things to watch out for

1. Wrong with packet forwarding

   If you see log from server side as `Wrong msg: 3232235522, 3232235777\nUNKNOWN L3 PROTOCOL OR WRONG DST IP`, you need to checkout if you setup the portID and mac address accordingly as step 4.
