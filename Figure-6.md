# Figure 6 - Comparison with Non-deterministic Systems

To understand the overhead of determinism, we run experiments comparing DORADD and two other non-deterministic systems, i.e., **Non-deter-spinlock** and **Non-deter-async**. 

- [DORADD](https://github.com/doradd-rt/doradd-server/tree/single-dispatcher) is the main baseline (located in single-dispatcher branch under doradd-server).
- [Non-deter-spinlock](https://github.com/doradd-rt/doradd-server/tree/non-deter) is a spinlock-based non-deterministic baseline (located in non-deter branch under doradd-server).
- [Non-deter-async-mutex](https://github.com/doradd-rt/caladan) runs Caladan with its asynchronous mutex.

## Step 0 - Testbed Setup

This experiment needs to run on two Cloudlab **d6515** nodes (one client node and one server node). The client node generates loads, sends requests to the server node, and measures the performance. We provides the instructions and Cloudlab profile here [FIXME] to setup the environment and install the dependencies required. After instantiating the Cloudlab nodes, you should find `~/rpc-dpdk-client` located on the client node, `~/doradd-server` and `~/caladan` on the server node. For caladan, we enable the performance mode and built with `DIRECTPATH` .

### Step 0.1 - Network Config

Currently, we need to specify the mac addresses in `~/rpc-dpdk-client` (client node) and `~/doradd-server` (server node) before building the source code.

You need to lookup the mac addresses on both client and server nodes separately and update the ARP entries on both nodes. For d6515 nodes, the mac address of an interface you should looking for is `enp65s0f0np0` (via running `ip link show enp65s0f0np0` ). 

For instance, if the client mac address for this interface is `1c:34:da:41:ce:f4` and the server mac address is `1c:34:da:41:ca:bc`. Given we manually set the client IP address is `<subnet>.3` and server IP address is `<subnet>.2` , you need to update the 2nd entry in `src/arp-config.h` as server mac address `1c:34:da:41:ca:bc` , the 3rd entry as client mac address `1c:34:da:41:ce:f4`  based our pre-set L2 forwarding rule. After updating both arp configs (client and server), you should see the `src/arp-config.h` looking like:

```c
const char *arp_entries[] = {
    "DE:AD:BE:EF:7B:15", 
    "1c:34:da:41:ca:bc", // SERVER
    "1c:34:da:41:ce:f4", // CLIENT
    "b8:ca:3a:6a:bc:58", 
    "b8:ca:3a:6a:b9:20", 
    "b8:ca:3a:69:cc:10",
};
```

### Step 0.2 - Build

- Build the client (on client node)
    
    ```bash
    pushd rpc-dpdk-client/src/build
    ninja
    popd
    ```
    
- Build DORADD (on server node)
    
    ```bash
    pushd doradd-server/src/build
    ninja
    popd
    ```
    
- Build Caladan (on server node)
    
    ```bash
    pushd caladan
    make clean && make
    pushd ksched
    make clean && make
    popd
    sudo ./scripts/setup_machine.sh
    
    # build apps
    pushd apps/synthetic
    cargo clean
    cargo update
    cargo build --release
    popd
    popd
    ```
    

## Hello-World Example (kick-the-tire)

### 1. Run DORADD

1. Start the server
    
    ```
    sudo taskset -c 4-12 ~/doradd-server/src/build/server 
    ```
    
2. Start the client
    
    ```
    sudo ~/rpc-dpdk-client/src/build/client -l 4-8 -- -i 1000 -s ~/rpc-dpdk-client/scripts/gen-replay-log/ycsb_uniform_no_cont.txt -a ycsb -t 192.168.1.2 -d 10 -l /tmp/hello-world-1.log
    ```
    
    You should see the latency and throughput printed out after 10 seconds.
    

### 2. Run Caladan

1. Start the iokernel
    
    ```
    sudo ~/caladan/iokerneld ias noht
    ```
    
2. Start the server (on another tmux pane)
    
    ```
    sudo ~/caladan/apps/synthetic/target/release/synthetic 192.168.1.2:5000 --config server.config --mode spawner-server
    ```
    
    Note: Caladan requires a calibration phase to get the accurate fake work cycles. We have done this calibration on d6515 and [set the cycles](https://github.com/doradd-rt/caladan/blob/52adfd1c5b403e3d89fb69f20db2aa569f5a4adc/apps/synthetic/src/fakework.rs#L124) accordingly. If you run on our caladan fork on other types of machines, you should first run calibration as below.
    
    ```
    sudo ~/caladan/apps/synthetic/target/release/synthetic 192.168.1.2:5000 --config server.config --mode spawner-server --calibrate
    ```
    
3. Start the client

   Note: unlike running for DORADD, you need to specify the udp port here via `-p 5000`
    
    ```
    sudo ~/rpc-dpdk-client/src/build/client -l 4-8 -- -i 1000 -s ~/rpc-dpdk-client/scripts/gen-replay-log/ycsb_uniform_no_cont.txt -a ycsb -t 192.168.1.2 -d 10 -l /tmp/hello-world-2.log -p 5000
    ```
    
    You should see the latency and throughput printed out after 10 seconds.
    

## Experiments (Estimated duration: 2h)

The entire experiment involves three server variants and different synthetic workloads (5usec/100usec, uniform/zipfian). We provide a setup script on the server node (build) to ease the benchmarking before real runs.

1. Run DORADD for all 5usec workloads 
    1. Setup and build for 5usec workload on the server (server node)
        
        ```
        ./server_setup.sh DORADD 5
        ```
        
    2. Start the server (server node)
        
        ```
        sudo taskset -c 4-12 ~/doradd-server/src/build/server
        ```
        
    3. Start the client (client node)
        
        ```bash
        ./run_uniform.sh DORADD 5 # 15 mins
        ./run_zipfian.sh DORADD 5 # 5 mins
        ```
        
2. Run DORADD for all 100usec workloads
    1. Setup and build for 5usec workload on the server (server node)
        
        ```
        ./server_setup.sh DORADD 100
        ```
        
    2. Start the server (server node)
        
        ```
        sudo taskset -c 4-12 ~/doradd-server/src/build/server
        ```
        
    3. Start the client (client node)
        
        ```bash
        ./run_uniform.sh DORADD 100 # 15 mins
        ./run_zipfian.sh DORADD 100 # 5 mins
        ```
        

Then we can change to other two server variants, Non-deter-spin and Non-deter-async. 

You should replace the DORADD in above commands with `Non-deter-spin` , then repeat the above process. For instance, `<.sh> Non-deter-spin 5` or  `<.sh> Non-deter-spin 100` 

For `Non-deter-async` , other than replacing the name, at step b, you should use below commands to launch the server. Then repeat the above steps.

```bash
sudo ~/caladan/iokerneld ias noht # start the iokernel
sudo ~/caladan/apps/synthetic/target/release/synthetic 192.168.1.2:5000 --config server.config --mode spawner-server
```

## Results

The results are located in `~/ppopp-artifcat/results` on the client node. The naming of the log is `<DORADD/Non-deter-spin/Non-deter-async>-<uniform/zipfian>-<5/100>usec.txt` . On each line, the first is throughput (rps) and the second is p99 latency (usec).

## Troubleshooting

### 1. Network configuration

If you see the see client printing zero throughput, it might mean 1) the request/reply is not forwarded successfully, you should check step 0.1 of this readme to make sure the MAC address is carefully set.

### 2. Overloaded Caladan

When the server node running the caladan (i.e., Non-deter-async), under high load, it might show following and crash. You need to decrease the client incoming loads by increasing the -i (interarrival) when running the rpc-dpdk-client.

```bash
[125.333531] CPU 02| <0> FATAL: runtime/net/directpath/mlx5/mlx5_rxtx.c:347 ASSERTION 'mlx5_refill_rxqueue(v, rx_cnt)' FAILED IN 'mlx5_gather_rx'
./apps/synthetic/target/release/synthetic(+0x5514f)[0x5597ddccb14f]
./apps/synthetic/target/release/synthetic(+0x551b5)[0x5597ddccb1b5]
./apps/synthetic/target/release/synthetic(+0x6d85e)[0x5597ddce385e]
./apps/synthetic/target/release/synthetic(+0x69aa0)[0x5597ddcdfaa0]
./apps/synthetic/target/release/synthetic(+0x59a50)[0x5597ddccfa50]
```

### 3. DPDK process
DORADD and Caladan process needs to launch separately and only one can exist at any given point of time. When you see `EAL: Cannot create lock on '/var/run/dpdk/rte/config'. Is another primary process running?`, you migh have forgotten to terminate the another one when try to launching a new server process.
