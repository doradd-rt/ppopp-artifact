# Figure 7 - Primary-backup Replication

To show an end-to-end usecase, we build a primary-backup replication system atop DORADD and showcase the introduced substantial benefits. Two baselines used are 

- single-threaded replication: represented by only using one worker core
- non-replicated one: one client node and only one server node without using backup node (thus the result for this baseline is already in Figure 6 results)

---

## **Step 0 - Testbed Setup**

This experiment needs to run on three Cloudlab **d6515** nodes (one client node, one primary node, and one backup node). The main workflow is following (as shown in the diagram of Fig.7): the client node generates loads, sends requests to the primary node; the primary forwards to the backup; the backup acknowledge back to the primary; finally, the primary executes the request and reply to the client. We provides the instructions and Cloudlab profile here [FIXME] to setup the environment and install the dependencies required. After instantiating the Cloudlab nodes, you should find `~/rpc-dpdk-client` located on the client node, `~/doradd-server` on the primary and backup server node.

### **Step 0.1 - Network Config**

Currently, we need to specify the mac addresses in `~/rpc-dpdk-client` (client node) and `~/doradd-server` (primary and backup nodes) before building the source code.

You need to lookup the mac addresses on each node separately and update the ARP entries on all the nodes. For d6515 nodes, the mac address of an interface you should looking for is `enp65s0f0np0` (via running `ip link show <iface>` ).

For example, if the client mac address for this interface is `1c:34:da:41:ce:f4` , the primary mac address is `1c:34:da:41:ca:bc` , and the backup mac address is `1c:34:da:41:6a:b8`. Given we manually set the client IP address is `<subnet>.3` , primary IP address is `<subnet>.2` , backup IP address is `<subnet>.4` you need to update the 2nd entry in `src/arp-config.h` as primary mac address `1c:34:da:41:ca:bc` , the 3rd entry as client mac address `1c:34:da:41:ce:f4` , the 4th entry as `1c:34:da:41:6a:b8` given our pre-set L2 forwarding rule. After updating all three arp configs (client, primary, backup), you should see the `src/arp-config.h` looking like:

```c
const char *arp_entries[] = {
    "DE:AD:BE:EF:7B:15",
    "1c:34:da:41:ca:bc", // PRIMARY
    "1c:34:da:41:ce:f4", // CLIENT
    "1c:34:da:41:6a:b8", // BACKUP
    "b8:ca:3a:6a:b9:20",
    "b8:ca:3a:69:cc:10",
};
```

### **Step 0.2 - Build**

- Build the client (on client node)
    
    ```
    pushd rpc-dpdk-client/src/build
    ninja
    popd
    ```
    
- Build the primary (on server1 node)
    
    ```
    pushd doradd-server/src/build
    git checkout primary
    ninja
    popd
    ```
    
- Build the backup (on server2 node)
    
    ```
    pushd doradd-server/src/build
    git checkout backup
    ninja
    popd
    ```
    

## **Hello-World Example (kick-the-tire)**

1. Start the primary
    
    ```
    sudo taskset -c 1-12 ~/doradd-server/src/build/server
    ```
    
2. Start the backup
    
    ```
    sudo taskset -c 1-12 ~/doradd-server/src/build/server
    ```
    
3. Start the client
    
    ```
    sudo ~/rpc-dpdk-client/src/build/client -l 4-8 -- -i 1000 -s ~/rpc-dpdk-client/scripts/gen-replay-log/ycsb_uniform_no_cont.txt -a ycsb -t 192.168.1.2 -d 10 -l /tmp/hello-world-1.log
    ```
    
    You should see the latency and throughput printed out after 10 seconds.
    

## **Experiments (Estimated duration: 20min)**

The entire experiments involves two variants. We provide a setup script on the server node (build) to ease the benchmarking before real runs.

1. Run DORADD
    1. Start the **primary** and the **backup** (server nodes)
        
        ```
        sudo taskset -c 1-12 ~/doradd-server/src/build/server
        ```
        
        Note: with 1 rpc handler core, 3 core dispatcher pipeline and 8 worker cores
        
    2. Start the client (client node)
        
        ```
        ./run_replication.sh DORADD
        ```
        
2. Run single-threaded replication
    1. Start the **primary** and the **backup** (server nodes)
        
        ```
        sudo taskset -c 1-5 ~/doradd-server/src/build/server
        ```
        
        Note: we still enable dispatcher pipelines here but only with one worker core
        
    2. Start the client (client node)
        
        ```
        ./run_replication.sh Single-threaded
        ```
        

## **Results**

The results are located in `~/ppopp-artifact/replication-results` on the client node. The naming of the log is `<DORADD/Single-threaded>.txt` . On each line, the first is throughput (rps) and the second is p99 latency (usec). The non-replication result is in `~/ppopp-artifact/results/DORADD-uniform-5.txt` once you finish the run for figure 6.

## **Troubleshooting**

**1. Network configuration**

If you see the see client printing zero throughput, it might mean 1) the request/reply is not forwarded successfully, you should check step 0.1 of this readme to make sure the MAC address is carefully set.
