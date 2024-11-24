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
    pushd doradd/scripts/
    ./ycsb/prepare_log.sh
    ./tpcc/prepare_log.sh
    popd
    ```
      
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
1. DORADD
   ```bash
   pushd doradd/scripts
   ./ycsb/run_all_ycsb.sh # run ycsb
   ./tpcc/run_all_tpcc.sh # run tpcc
   popd
   ```
   The results is located at `doradd/scripts/ycsb/{no/mod/high}_cont.res` and `doradd/scripts/tpcc/stats/tpcc_{no/mod/high/split}_cont.res`.

2. Caracal - Please refer to `./caracal/README.md` for comprehensive instructions

