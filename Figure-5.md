# Figure 5 - DORADD v.s. Caracal

This experiment compares DORADD with Caracal, the state-of-the-art deterministic parallel system, using YCSB and TPCC-NP benchmarks. This experiment needs to run on our provided local testbed, i.e.,  a server equipped with an Intel Xeon Gold 5318N CPU 24 cores. For artifact reviewers, please provide us your ssh pub key so that we can grant the access.

---

## Setup
0. Install the dependencies
    ```
    sudo apt-get update
    sudo apt-get install -y pkg-config libssl-dev clang libclang-dev build-essential ninja-build cmake cpufrequtils htop python3-pip
    pip install numpy
    ```

2. Clone and pull the submodule
    
    ```bash
    git clone https://github.com/doradd-rt/ppopp-artifact.git
    git submodule update --init --recursive
    ```
    
    - DORADD is located in `./doradd`
    - Caracal is located in `./caracal`  which contains two other submodules
        - `felis` - the source code of Caracal
        - `felis-controller` - the controller script of Caracal
3. Prepare input log for workloads
    ```bash
    ./fig5_prepare_ycsb_log.sh
    ./fig5_prepare_tpcc_log.sh
    ```
    Then you should find input logs named as `ycsb_uniform_<cont>.txt` in `./fig5-input-log`.
      
4. Huge-page setting
    - DORADD allocates hugepages in runtime, so before running
        
        ```
        sudo su -c "echo 0 >  /proc/sys/vm/nr_hugepages"
        ```
        
    - Caracal uses the hugepages pre-set in the system, so you should
        
        ```
        sudo su -c "echo 51200 >  /proc/sys/vm/nr_hugepages"
        ```
        
5. Set CPU frequency as performance mode
    
    ```
    ./set_perf_freq.sh
    ```
    

## Hello-world Example

1. DORADD - Please refer to `./doradd/README.md` 
2. Caracal - Please refer to `./caracal/felis/README.md` and `./caracal/felis-controller/README.md`

## Experiments

### DORADD
   ```bash
   ./run_doradd_ycsb.sh # run ycsb
   ./run_doradd_tpcc.sh # run tpcc
   ```
   Upon running, you should see similar following logs
   ```
    allocated huge pages
    Init and Run - Dispatcher Pipelines
    Hello deterministic world!
    allocated huge pages
    spawn - 249124.476628 tx/s
    exec  - 249124.476628 tx/s
    spawn - 249942.546956 tx/s
    exec  - 249941.297244 tx/s
    spawn - 249706.788359 tx/s
    exec  - 249706.788359 tx/s
    spawn - 249987.165034 tx/s
    exec  - 249987.165034 tx/s
    spawn - 249608.500923 tx/s
    exec  - 249608.500923 tx/s
    entire reqs are 1000000
    flush latency stats
    terminate called without an active exception
    ./ycsb/run_all_ycsb.sh: line 17: 299801 Aborted                 sudo taskset -c 4-11 ./ycsb -n 8 $log -i $ia
    exp:4000-latency.log
   ```

- YCSB results: `fig5-results/ycsb/{no/mod/high}_cont.res`
- TPCC-NP results: `fig5-results/tpcc/{no/mod/high/split}_cont.res`.
- On each row, the first number is p99 latency in usec, and the second is the throughput (request per second). For example,
  ```
  18 249810
  20 499757
  .. ......
  ```

### Caracal

Please refer to `./caracal/README.md` for comprehensive instructions
