# Caracal

This directory includes two submodules: `felis` and `felis-controller`, along with scripts to run **YCSB** and **TPCC-NP** benchmarks.

- `felis` contains Caracal's C++ source code.
- `felis-controller` is Caracal's controller script, written in Scala.

## Run

1. Install dependency
    
    ```
    ./install_dependencies.sh
    ```
    
2. Setup hugepages
    
    ```
    sudo su -c "echo 51200 > /proc/sys/vm/nr_hugepages"
    ```
    
3. Run YCSB [Estimated time: 45min]
    
    ```
    ./run_ycsb.sh
    ```
    
4. Run TPCC-NP [Estimated time: 15min]
    
    ```bash
    # backup raw results
    mv felis/results/ felis/ycsb-results
    
    ./run_tpcc.sh
    ```

## Results

- The results will be located in `felis-controller/scripts`.
- The log is named as `<ycsb/tpcc>_<no/mid/high>_cont.txt.`
- The log format is following

```
es100-res
0.44 426.0
0.44 409.8
0.43 380.1
0.43 345.5
0.43 303.6
0.44 252.6
0.43 65.0
0.25 0.6
0.17 0.8
0.12 1.0
0.1 1.2
```
- es100 means using epoch size 100
- the left column is throughput in Mrps
- the right column is tail latency in millisecond
