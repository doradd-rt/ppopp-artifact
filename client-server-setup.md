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
    
    For instance, if you are using two c6525-25g nodes (with no-interswitch link), choose the 3rd mlx5 interface (port 2) below.
    
    ```bash
    enp65s0f0np0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
            inet6 fe80::e42:a1ff:fedd:5824  prefixlen 64  scopeid 0x20<link>
            ether 0c:42:a1:dd:58:24  txqueuelen 1000  (Ethernet)
            RX packets 18  bytes 1476 (1.4 KB)
            RX errors 0  dropped 0  overruns 0  frame 0
            TX packets 40  bytes 3112 (3.1 KB)
            TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
    ```
    
    in the `src/arp-config.h`, modify the 3rd entry as this mac address. Note: picking the 3rd entry is because that we set up a `192.168.1.3` as default ip (line 11 in `src/config.h`) for the client and we used the last digit for L2 forwarding.
    
    And you should also modify `PORT_ID` in `src/config.h` as 2 for c6525-25g nodes. 

    To figure out port mapping, use the `<DPDK_DIR>/usertools/dpdk-devbind.py -s`. You will see output similar to below.

    ```bash
    Network devices using kernel driver
    ===================================
    0000:01:00.0 'MT27800 Family [ConnectX-5] 1017' if=eno33np0 drv=mlx5_core unused=vfio-pci *Active*
    0000:01:00.1 'MT27800 Family [ConnectX-5] 1017' if=eno34np1 drv=mlx5_core unused=vfio-pci
    0000:41:00.0 'MT27800 Family [ConnectX-5] 1017' if=enp65s0f0np0 drv=mlx5_core unused=vfio-pci
    0000:41:00.1 'MT27800 Family [ConnectX-5] 1017' if=enp65s0f1np1 drv=mlx5_core unused=vfio-pci
    ```
    
6. Run the server
    ```bash
    sudo taskset -c 1-12 ./server
    ```
    
7. Run the client
    1. prepare the ycsb logs (**[TODO]**)
    2. run the client
    
    ```bash
    sudo ./client -l 4-12 -- -i 100 -s ~/rpc-dpdk-client/scripts/gen-replay-log/ycsb_uniform_no_cont.txt -a ycsb -t 192.168.1.2 -d 30 -l /tmp/test.log
    ```

### Issues / things to watch out for

1. Wrong with packet forwarding

   If you see log from server side as `Wrong msg: 3232235522, 3232235777\nUNKNOWN L3 PROTOCOL OR WRONG DST IP`, you need to checkout if you setup the portID and mac address accordingly as step 4.
