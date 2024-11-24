# Figure 5 - DORADD v.s. Caracal

This experiment compares DORADD with Caracal, the state-of-the-art deterministic parallel system, using YCSB and TPCC-NP benchmarks. This experiment needs to run on our provided local testbed, i.e.,  a server equipped with an Intel Xeon Gold 5318N CPU 24 cores. For artifact reviewers, please provide us your ssh pub key so that we can grant the access.

---

## Setup

1. Clone and pull the submodule
    
    ```bash
    git clone https://github.com/doradd-rt/ppopp-artifact.git
    git submodule update --init --recursive
    ```
    
    - DORADD is located in `./doradd`
    - Caracal is located in `./caracal`  which contains two other submodules
        - `felis` - the source code of Caracal
        - `felis-controller` - the controller script of Caracal
2. Prepare input log for workloads
    ```bash
    pushd doradd/scripts/ycsb
    ./prepare_log.sh
    popd

    pushd doradd/scripts/tpcc
    ./prepare_log.sh
    popd
    ```
    Then you should find input logs named as `ycsb_uniform_<cont>.txt` in `doradd/scripts/ycsb` and `tpcc_<cont>.txt` in `doradd/scripts/tpcc/input-log`.
      
3. Huge-page setting
    - DORADD allocates hugepages in runtime, so before running
        
        ```
        sudo su -c "echo 0 >  /proc/sys/vm/nr_hugepages"
        ```
        
    - Caracal uses the hugepages pre-set in the system, so you should
        
        ```
        sudo su -c "echo 51200 >  /proc/sys/vm/nr_hugepages"
        ```
        
4. Set CPU frequency as performance mode
    
    ```
    ./doradd/scripts/set_perf_freq.sh
    ```
    

## Hello-world Example

1. DORADD - Please refer to `./doradd/README.md` 
2. Caracal - Please refer to `./caracal/felis/README.md` and `./caracal/felis-controller/README.md`

## Experiments
[TODO] add time

### DORADD
   ```bash
   pushd doradd/scripts/ycsb
   ./run_all_ycsb.sh # run ycsb
   popd

   pushd doradd/scripts/tpcc
   ./run_all_tpcc.sh # run tpcc
   popd
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

- YCSB results: `doradd/src/bench/build/{no/mod/high}_cont.res`
- TPCC-NP results: `doradd/scripts/tpcc/stats/tpcc_{no/mod/high/split}_cont.res`.
- On each row, the first number is p99 latency in usec, and the second is the throughput (request per second). For example,
  ```
  18 249810
  20 499757
  .. ......
  ```
   

### Caracal
Please refer to `./caracal/README.md` for comprehensive instructions

